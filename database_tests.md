# NordicRent – Database Tests

For the SQL queries, see `database/queries.sql` and `database/transaction.sql`.

## JOIN Test

- Expected result: Retrieve data from four related tables.
- Observed result: 8 rows returned successfully.
- Status: PASS

## Constraint Test

- Expected result: CHECK and ENUM constraints should reject invalid values.
- Observed result: Both constraints rejected invalid values.
- Status: PASS

## ROLLBACK Test

- Expected result: The failed booking transaction should be rolled back without saving the booking or its booking lines.
- Observed result: The transaction was rolled back, and neither the booking nor its booking lines were saved.
- Status: PASS