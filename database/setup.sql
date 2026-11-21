-- Active: 1792410319231@@127.0.0.1@3306@nordicrent


---------------------------------------------------------------------------------------------------------
-- Create database and verify it is used
---------------------------------------------------------------------------------------------------------
--DROP DATABASE IF EXISTS nordicrent;

CREATE DATABASE IF NOT EXISTS nordicrent;

USE nordicrent;

SELECT DATABASE();

-------------------------------------------------------------------------------------------------------
-- Create table 'customers'
-------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS customers(
    customer_id   INT          AUTO_INCREMENT   PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(20),
    city          VARCHAR(50) 
)ENGINE=InnoDB    DEFAULT  CHARSET=utf8mb4; 

-- Show customers table structure
DESCRIBE customers;

-------------------------------------------------------------------------------------------------------
-- Create table 'depots'
-------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS depots(
    depot_id       INT          AUTO_INCREMENT   PRIMARY KEY, 
    depot_name     VARCHAR(50)  NOT NULL         UNIQUE,
    district       VARCHAR(50)  NOT NULL,
    phone          VARCHAR(20)
)ENGINE=InnoDB    DEFAULT  CHARSET=utf8mb4; 

-- Show depots table structure
DESCRIBE depots;

-------------------------------------------------------------------------------------------------------
-- Create table 'categories'
-------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS categories(
    category_id    INT           AUTO_INCREMENT   PRIMARY KEY, 
    category_name  VARCHAR(100)  NOT NULL         UNIQUE
)ENGINE=InnoDB    DEFAULT  CHARSET=utf8mb4;

-- Show categories table structure
DESCRIBE categories;

-------------------------------------------------------------------------------------------------------
-- Create table 'equipment'
-------------------------------------------------------------------------------------------------------
-- Each equipment type is stored only once per depot.
-- The same equipment can be booked multiple times by different customers.
-- This project assumes an unlimited supply of each equipment type,
-- so no stock quantity is stored in this table.

CREATE TABLE IF NOT EXISTS equipment(
    equipment_id   INT            AUTO_INCREMENT   PRIMARY KEY, 
    equipment_name VARCHAR(100)   NOT NULL,
    daily_price    DECIMAL(10,2)  NOT NULL,
    category_id    INT            NOT NULL,
    depot_id       INT            NOT NULL,          

    FOREIGN KEY (category_id) REFERENCES categories(category_id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
    FOREIGN KEY (depot_id) REFERENCES depots(depot_id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
   
    UNIQUE (equipment_name, depot_id),
    CHECK (daily_price >= 0)
)ENGINE=InnoDB    DEFAULT  CHARSET=utf8mb4;

-- Show equipment table structure
DESCRIBE equipment;

-------------------------------------------------------------------------------------------------------
-- Create table 'bookings'
-------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS bookings(
    booking_id      INT        AUTO_INCREMENT    PRIMARY KEY,
    customer_id     INT        NOT NULL,
    depot_id        INT        NOT NULL,
    start_date      DATE       NOT NULL,
    end_date        DATE       NOT NULL,
    booking_status  ENUM('pending', 'confirmed', 'cancelled', 'completed')
                    NOT NULL    DEFAULT 'pending',

    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
    FOREIGN KEY(depot_id) REFERENCES depots(depot_id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,

    CHECK (end_date > start_date)
)ENGINE=InnoDB    DEFAULT  CHARSET=utf8mb4;

-- Show bookings table structure
DESCRIBE bookings;

-------------------------------------------------------------------------------------------------------
-- Create table 'booking_lines'
-------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS booking_lines(
    booking_line_id   INT     AUTO_INCREMENT    PRIMARY KEY,
    booking_id        INT     NOT NULL,
    equipment_id      INT     NOT NULL,
    quantity          INT     NOT NULL,

    FOREIGN KEY(booking_id) REFERENCES bookings(booking_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
    FOREIGN KEY(equipment_id) REFERENCES equipment(equipment_id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE,

    UNIQUE (booking_id, equipment_id),
    CHECK (quantity > 0)
)ENGINE=InnoDB    DEFAULT  CHARSET=utf8mb4;

-- Show booking_lines table structure
DESCRIBE booking_lines;

-------------------------------------------------------------------------------------------------------
-- Show all database tables
-------------------------------------------------------------------------------------------------------

SHOW TABLES;



