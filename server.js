/*
NordicRent API server.
Handles HTTP requests and coordinates data operations between MySQL and MongoDB.
*/

'use strict';

require('dotenv').config();

const express = require('express');
// Database connections
const pool = require('./connections/mysql');
const {
    connectMongo,
    reportsCollection
} = require('./connections/mongodb');

// Input validation functions
const {
    positiveId,
    validEquipment,
    validBooking,
    validReport
} = require('./validation');

// Create Express application
const app = express();

// Parse incoming JSON request bodies
app.use(express.json());


// Database error handling

function dbFailure(error, res) {

    if ([
        'ER_DUP_ENTRY',
        'ER_NO_REFERENCED_ROW_2',
        'ER_ROW_IS_REFERENCED_2'
    ].includes(error.code)) {

        return res.status(409).json({
            error: 'Database constraint rejected the change'
        });
    }

    console.error('MySQL failure:', error.code || error.message);

    return res.status(500).json({
        error: 'Database operation failed'
    });
}


// GET – Retrieve all equipment

app.get('/api/equipment', async (req, res) => {

    try {

        const [rows] = await pool.execute(
            `SELECT
                e.equipment_id,
                e.equipment_name,
                e.daily_price,
                c.category_name,
                d.depot_name

            FROM equipment AS e

            JOIN categories AS c
                ON e.category_id = c.category_id

            JOIN depots AS d
                ON e.depot_id = d.depot_id

            ORDER BY e.equipment_id`
        );

        return res.json(rows);

    } catch (error) {

        return dbFailure(error, res);

    }

});

// POST – Create equipment

app.post('/api/equipment', async (req, res) => {

    // Validate incoming equipment data
    if (!validEquipment(req.body)) {
        return res.status(400).json({
            error: 'Invalid equipment data'
        });
    }

    try {

        const {
            equipment_name,
            daily_price,
            category_id,
            depot_id
        } = req.body;

        const [result] = await pool.execute(
            `INSERT INTO equipment
                (equipment_name, daily_price, category_id, depot_id)
             VALUES (?, ?, ?, ?)`,
            [equipment_name, daily_price, category_id, depot_id]
        );

        return res.status(201).json({
            message: 'Equipment created successfully',
            equipment_id: result.insertId
        });

    } catch (error) {
        return dbFailure(error, res);
    }
});

// PUT – Update equipment

app.put('/api/equipment/:id', async (req, res) => {

    try {

        const { id } = req.params;

        // Validate ID and incoming equipment data
        if (!positiveId(id) || !validEquipment(req.body)) {
            return res.status(400).json({
                error: 'Invalid equipment data'
            });
        }

        const {
            equipment_name,
            daily_price,
            category_id,
            depot_id
        } = req.body;

        // Check that the equipment exists
        const [equipment] = await pool.execute(
            `SELECT equipment_id
             FROM equipment
             WHERE equipment_id = ?`,
            [id]
        );

        if (equipment.length === 0) {
            return res.status(404).json({
                error: 'Equipment not found'
            });
        }

        // Update equipment
        await pool.execute(
            `UPDATE equipment
             SET
                equipment_name = ?,
                daily_price = ?,
                category_id = ?,
                depot_id = ?
             WHERE equipment_id = ?`,
            [
                equipment_name,
                daily_price,
                category_id,
                depot_id,
                id
            ]
        );

        return res.json({
            message: 'Equipment updated successfully',
            equipment_id: Number(id)
        });

    } catch (error) {

        return dbFailure(error, res);

    }

});

// DELETE – Remove equipment
app.delete('/api/equipment/:id', async (req, res) => {

    try {

        const { id } = req.params;

        // Validate equipment ID
        if (!positiveId(id)) {
            return res.status(400).json({
                error: 'Invalid equipment ID'
            });
        }

        const [result] = await pool.execute(
            `DELETE FROM equipment
             WHERE equipment_id = ?`,
            [id]
        );

        // Check if any equipment was deleted
        if (result.affectedRows === 0) {
            return res.status(404).json({
                error: 'Equipment not found'
            });
        }

        return res.json({
            message: 'Equipment deleted successfully',
            equipment_id: Number(id)
        });

    } catch (error) {

        return dbFailure(error, res);

    }

});

// POST – Create booking with SQL transaction
app.post('/api/bookings', async (req, res) => {

    let connection;

    try {

        // Validate booking data
        if (!validBooking(req.body)) {
            return res.status(400).json({
                error: 'Invalid booking data'
            });
        }

        const {
            customer_id,
            depot_id,
            start_date,
            end_date,
            booking_lines
        } = req.body;

        // Get a connection from the pool
        connection = await pool.getConnection();

        // Start transaction
        await connection.beginTransaction();

        // Insert booking
        const [bookingResult] = await connection.execute(
            `INSERT INTO bookings
                (customer_id, depot_id, start_date, end_date)
             VALUES (?, ?, ?, ?)`,
            [customer_id, depot_id, start_date, end_date]
        );

        // Get the newly created booking_id
        const bookingId = bookingResult.insertId;

        // Insert each equipment item into booking_lines
        for (const line of booking_lines) {

            await connection.execute(
                `INSERT INTO booking_lines
                    (booking_id, equipment_id, quantity)
                 VALUES (?, ?, ?)`,
                [bookingId, line.equipment_id, line.quantity]
            );

        }

        // Save all changes
        await connection.commit();

        return res.status(201).json({
            message: 'Booking created successfully',
            booking_id: bookingId
        });

    } catch (error) {

        // Undo all changes if something fails
        if (connection) {
            try {
                await connection.rollback();
            } catch (rollbackError) {
                console.error('Rollback failed:', rollbackError.message);
            }
        }

        return dbFailure(error, res);

    } finally {

        // Release connection back to the pool
        if (connection) {
            connection.release();
        }

    }

});

// POST – Create equipment report in MongoDB
app.post('/api/reports', async (req, res) => {

    try {

        // Validate incoming report data
        if (!validReport(req.body)) {
            return res.status(400).json({
                error: 'Invalid report data'
            });
        }

        const {
            equipmentId,
            notes,
            checklist,
            damageFlag
        } = req.body;

        // Check that the equipment exists in MySQL
        const [equipment] = await pool.execute(
            `SELECT equipment_id
             FROM equipment
             WHERE equipment_id = ?`,
            [equipmentId]
        );

        if (equipment.length === 0) {
            return res.status(404).json({
                error: 'Equipment not found'
            });
        }

        // Save report in MongoDB
        const result = await reportsCollection().insertOne({

            equipmentId: Number(equipmentId),
            notes,
            checklist,
            damageFlag,
            createdAt: new Date()

        });

        return res.status(201).json({
            message: 'Report created successfully',
            reportId: result.insertedId
        });

    } catch (error) {

        console.error('Report creation failed:', error.message);

        return res.status(500).json({
            error: 'Could not save report'
        });

    }

});

// GET – Retrieve equipment reports from MongoDB
app.get('/api/reports/equipment/:id', async (req, res) => {

    try {

        const { id } = req.params;

        // Validate equipment ID
        if (!positiveId(id)) {
            return res.status(400).json({
                error: 'Invalid equipment ID'
            });
        }

        const equipmentId = Number(id);

        const reports = await reportsCollection()
            .find({ equipmentId: equipmentId })
            .sort({ createdAt: -1 })
            .toArray();

        return res.json(reports);

    } catch (error) {

        console.error('MongoDB failure:', error.message);

        return res.status(500).json({
            error: 'Could not retrieve reports'
        });

    }

});

// Start server and connect to databases

const PORT = process.env.PORT || 3000;


async function startServer() {

    try {

        // Connect to MongoDB before starting the server
        await connectMongo();

        console.log('Connected to MongoDB');

        // Check MySQL connection
        await pool.query('SELECT 1');

        console.log('Connected to MySQL');

        // Start Express server
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });

    } catch (error) {

        console.error('Could not start server:', error.message);

        process.exit(1);

    }

}

startServer();