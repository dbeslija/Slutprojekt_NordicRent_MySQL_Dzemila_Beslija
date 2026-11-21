-------------------------------------------------------------------------------------------------------
-- Testing constraints, JOINs and subqueries
-------------------------------------------------------------------------------------------------------

-- Constraint testing
-- CHECK constraint: quantity must be greater than 0.
-- Expected result: The UPDATE should fail because quantity must be greater than 0.
-- Actual result: Check constraint 'booking_lines_chk_1' is violated.

SELECT * FROM booking_lines;

UPDATE booking_lines
SET quantity = 0
WHERE booking_line_id = 1;



-- ENUM constraint: booking_status only accepts the values
-- 'pending', 'confirmed', 'cancelled' and 'completed'.
-- Expected result: The UPDATE should fail because 'reserved' is not an allowed value.
-- Actual result: Data truncated for column 'booking_status' at row 1.

UPDATE bookings
SET booking_status = 'reserved'
WHERE booking_id = 1;

-------------------------------------------------------------------------------------------------------
-- JOIN testing
-------------------------------------------------------------------------------------------------------

-- Display detailed booking information by joining four tables:
-- bookings, customers, booking_lines and equipment.
-- Expected result: 8 rows showing bookings with customer names,
-- equipment names and quantities.
-- Actual result: 8 rows with the current seed data.
SELECT
    bookings.booking_id,
    customers.first_name,
    customers.last_name,
    equipment.equipment_name,
    booking_lines.quantity
FROM bookings
JOIN customers
    ON bookings.customer_id = customers.customer_id
JOIN booking_lines
    ON bookings.booking_id = booking_lines.booking_id
JOIN equipment
    ON booking_lines.equipment_id = equipment.equipment_id;

-------------------------------------------------------------------------------------------------------
-- Subquery testing
-------------------------------------------------------------------------------------------------------

-- Non-correlated subquery
-- Display all customers who have made at least one booking.
-- Customers without bookings are excluded from the result.


SELECT customer_id, first_name, last_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM bookings
);


-- Correlated subquery
-- Display customers who have made more than one booking.
-- The inner query uses customer_id from the outer query.

SELECT
    customers.customer_id,
    customers.first_name,
    customers.last_name
FROM customers 
WHERE (
    SELECT COUNT(*)
    FROM bookings 
    WHERE bookings.customer_id = customers.customer_id
) > 1;

-------------------------------------------------------------------------------------------------------
-- Aggregate query with GROUP BY
-------------------------------------------------------------------------------------------------------

-- Count the number of bookings per customer.
-- LEFT JOIN also includes customers without any bookings.
-- ORDER BY displays customers with the most bookings first.
SELECT
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    COUNT(bookings.booking_id) AS total_bookings
FROM customers
LEFT JOIN bookings
    ON customers.customer_id = bookings.customer_id
GROUP BY
    customers.customer_id
ORDER BY total_bookings DESC;
