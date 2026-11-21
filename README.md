# NordicRent


## Project Description

NordicRent is a rental management API for managing customers, equipment, depots and bookings. The API uses MySQL for relational data and MongoDB for equipment condition reports.

## Technologies Used

- Node.js
- Express
- MySQL
- MongoDB

## Installation

1. Clone the repository.
2. Install dependencies:


   npm install

3. Create a `.env` file based on `.env.example`.
4. Update the `.env` file with your own MySQL and MongoDB connection details.

Note: The .env file is not included in the repository for security reasons. The .env.example file contains a template with the required environment variables.

## Database Setup

1. Start the MySQL server.
2. Execute `database/setup.sql` to create the database and tables.
3. Execute `database/seed.sql` to insert the sample data.
4. Execute `database/user.sql` to create the application database user and grant permissions.
5. Start the MongoDB server.

Make sure both MySQL and MongoDB are running before starting the API.

## Running the Application

Start the API from the project folder:


node server.js

The API runs on the port configured in the .env file.

## Project Structure

- server.js – Express API and routes.
- connections/ – MySQL and MongoDB database connections.
- validation.js – Input validation functions.
- database/setup.sql – Creates the database and tables.
- database/seed.sql – Inserts sample data.
- database/queries.sql – Contains SQL queries.
- database/transaction.sql – Demonstrates COMMIT and ROLLBACK.
- database/user.sql – Creates the application database user.
- object-example.js -Creates a object example in js
- erdiagram.md - ER diagram and description
- database_tests.md -Tests 
- mongodb/ - MonogDB report
- .env.example – Example environment configuration.




