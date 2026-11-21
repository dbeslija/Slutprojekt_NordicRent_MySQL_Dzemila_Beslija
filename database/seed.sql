-------------------------------------------------------------------------------------------------------
-- Seed data for the NordicRent database.
-- Populates all tables with sample data for testing.
-- Run after setup.sql.
-------------------------------------------------------------------------------------------------------

USE nordicrent;

-------------------------------------------------------------------------------------------------------
-- Insert customers
-------------------------------------------------------------------------------------------------------   
INSERT INTO customers(first_name, last_name, email, phone, city)
VALUES
      ('Dzemila', 'Beslija', 'dzemila.beslija@example.com', '0701234567', 'Mölndal'),
      ('Anna', 'Andersson', 'anna.andersson@example.com', '0702345678', 'Göteborg'),
      ('Erik', 'Johansson', 'erik.johansson@example.com', '0703456789', 'Mölndal'),
      ('Maria', 'Svensson', 'maria.svensson@example.com', '0704567890', 'Göteborg');

-- Display all customers
SELECT * FROM customers;

-------------------------------------------------------------------------------------------------------
-- Insert depots
-------------------------------------------------------------------------------------------------------
INSERT INTO depots(depot_name, district, phone)
VALUES 
      ('NordicRent Göteborg City', 'Centrum', '031123456'),
      ('NordicRent Göteborg Frölunda', 'Frölunda', '031789123');

-- Display all depots
SELECT* FROM depots;

-------------------------------------------------------------------------------------------------------
-- Insert categories
-------------------------------------------------------------------------------------------------------
INSERT INTO categories(category_name)
VALUES
    ('Camping'),
    ('Water Sports'),
    ('Winter Sports');

-- Display categories
SELECT * FROM categories;

-------------------------------------------------------------------------------------------------------
-- Insert equipment
-------------------------------------------------------------------------------------------------------
-- INSERT INTO ... SELECT would also be possible.
-- This method retrieves IDs directly from related tables
-- instead of entering them manually as I do here.

INSERT INTO equipment(equipment_name, daily_price, category_id, depot_id)
VALUES 
    ('Tent', 60.00, 1, 1),
    ('Sleeping bag', 35.00, 1, 2),
    ('Camping stove', 40.00, 1, 1),
    ('Hiking backpack', 35.00, 1, 1),
    ('Kayak', 100.00, 2, 1),
    ('Life jacket', 30.00, 2, 2),
    ('Wetsuit', 50.00, 2, 2),
    ('Ice skates', 30.00, 3, 1),
    ('Skis', 80.00, 3, 1),
    ('Ski helmet', 25.00, 3, 2),
    ('Snowboard', 90.00, 3, 1);

-- Display equipment
SELECT * FROM equipment;

-------------------------------------------------------------------------------------------------------
-- Insert bookings
-------------------------------------------------------------------------------------------------------
-- Initial bookings.
-- Run this INSERT only once to avoid duplicate rows.

-- INSERT INTO bookings(customer_id, depot_id, start_date, end_date, booking_status)
-- VALUES
--     (1, 1, '2026-12-10', '2026-12-12', 'confirmed'),
--     (2, 2, '2026-12-15', '2026-12-17', 'pending'),
--     (3, 1, '2026-12-20', '2026-12-23', 'completed');


-- Add two extra bookings for customer 1 to create variation in the number of bookings per customer.
-- This makes it possible to practice queries using COUNT(), GROUP BY and ORDER BY.

-- booking number 4
INSERT INTO bookings (customer_id, depot_id, start_date, end_date, booking_status)
SELECT customers.customer_id, depots.depot_id, '2027-01-10', '2027-01-12', 'confirmed'
FROM customers
CROSS JOIN depots
WHERE customers.email = 'dzemila.beslija@example.com'
AND depots.depot_name = 'NordicRent Göteborg City'
AND NOT EXISTS (
    SELECT 1
    FROM bookings
    WHERE bookings.customer_id = customers.customer_id
    AND bookings.depot_id = depots.depot_id
    AND bookings.start_date = '2027-01-10'
    AND bookings.end_date = '2027-01-12'
);

-- booking number 5
INSERT INTO bookings (customer_id, depot_id, start_date, end_date, booking_status)
SELECT customers.customer_id, depots.depot_id, '2027-02-10', '2027-02-12', 'pending'
FROM customers
CROSS JOIN depots
WHERE customers.email = 'dzemila.beslija@example.com'
AND depots.depot_name = 'NordicRent Göteborg City'
AND NOT EXISTS (
    SELECT 1
    FROM bookings
    WHERE bookings.customer_id = customers.customer_id
    AND bookings.depot_id = depots.depot_id
    AND bookings.start_date = '2027-02-10'
    AND bookings.end_date = '2027-02-12'
);



-- Display bookings
SELECT * FROM bookings;

-------------------------------------------------------------------------------------------------------
-- Insert booking_lines
-------------------------------------------------------------------------------------------------------
INSERT INTO booking_lines(booking_id, equipment_id, quantity)
VALUES
    (1, 1, 2),
    (2, 2, 1),
    (2, 3, 2),
    (3, 1, 1),
    (3, 4, 2),
    (3, 5, 1),
    (4, 6, 2),
    (5, 8, 1);

-- Display all booking lines
SELECT * FROM booking_lines;

-------------------------------------------------------------------------------------------------------