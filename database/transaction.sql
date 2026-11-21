-- Active: 1792410319231@@127.0.0.1@3306@nordicrent
USE nordicrent;
-------------------------------------------------------------------------------------------------------
-- TRANSACTION TESTING
-------------------------------------------------------------------------------------------------------

--Test 1: Successful booking (COMMIT)
START TRANSACTION;

INSERT INTO bookings
(customer_id, depot_id, start_date, end_date)
VALUES (1, 1, '2026-11-20', '2026-11-23');

--use last_insert_id to get the latest id according to auto-increament
SET @booking_id = LAST_INSERT_ID();

INSERT INTO booking_lines
(booking_id, equipment_id, quantity)
VALUES
(@booking_id, 2, 1),
(@booking_id, 3, 2);

COMMIT;

-- Verify that the booking and booking lines were saved
SELECT * FROM bookings
WHERE booking_id = @booking_id;

SELECT * FROM booking_lines
WHERE booking_id = @booking_id;

-------------------------------------------------------------------------------------------------------

-- Test 2: Failed booking (ROLLBACK)
-- Expected result: The invalid equipment_id should cause a foreign key error.
-- The booking and the first booking line should not be saved after ROLLBACK.

START TRANSACTION;

INSERT INTO bookings
(customer_id, depot_id, start_date, end_date)
VALUES (1, 1, '2026-11-25', '2026-11-28');

SET @booking_id = LAST_INSERT_ID();

-- First booking line: valid
INSERT INTO booking_lines
(booking_id, equipment_id, quantity)
VALUES
(@booking_id, 2, 1);

-- Second booking line: invalid equipment_id
INSERT INTO booking_lines
(booking_id, equipment_id, quantity)
VALUES
(@booking_id, 999999, 1);

ROLLBACK;

-- Verify that the booking was not saved
SELECT * FROM bookings
WHERE booking_id = @booking_id;

-- Verify that no booking lines were saved
SELECT * FROM booking_lines
WHERE booking_id = @booking_id;

