// MongoDB database connection
'use strict';

const { MongoClient } = require('mongodb');

// Create MongoDB client
const client = new MongoClient(
    process.env.MONGO_URI || 'mongodb://127.0.0.1:27017'
);

// Store the reports collection
let reports;


// Connect to MongoDB and select database and collection
async function connectMongo() {

    await client.connect();

    const db = client.db(process.env.MONGO_DB || 'nordicrent');

    reports = db.collection('reports');
}


// Return the reports collection
function reportsCollection() {

    if (!reports) {
        throw new Error('MongoDB is not connected');
    }

    return reports;
}


// Close the MongoDB connection
async function closeMongo() {

    await client.close();
}


// Export functions so server.js can use them
module.exports = {
    connectMongo,
    reportsCollection
};
