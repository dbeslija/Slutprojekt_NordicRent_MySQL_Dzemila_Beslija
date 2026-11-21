/* 
Validation functions for incoming API data.
Checks that submitted data has the correct format and valid values 
before it is processed or stored in the databases.
*/

'use strict';

// Check that an ID is a positive integer
function positiveId(value) {
    return /^[1-9]\d*$/.test(String(value ?? ''))
        && Number.isSafeInteger(Number(value));
}


// Check that the submitted data is an object
// Arrays and null are not accepted
function isObject(value) {
    return value !== null
        && typeof value === 'object'
        && !Array.isArray(value);
}


// Check that equipment data is valid
function validEquipment(body) {
    return isObject(body)

        // Equipment name must be a non-empty string
        && typeof body.equipment_name === 'string'
        && body.equipment_name.trim().length > 0
        && body.equipment_name.trim().length <= 100

        // Daily price must be a valid number with up to two decimals
        // The value must fit the MySQL DECIMAL(10,2) column
        && (
            typeof body.daily_price === 'number'
            || (
                typeof body.daily_price === 'string'
                && body.daily_price.trim() !== ''
            )
        )
        && Number.isFinite(Number(body.daily_price))
        && Number(body.daily_price) >= 0
        && Number(body.daily_price) <= 99999999.99
        && /^\d+(\.\d{1,2})?$/.test(String(body.daily_price).trim())

        // Category and depot must have positive IDs
        && positiveId(body.category_id)
        && positiveId(body.depot_id);
}


// Check that a date has the format YYYY-MM-DD
// Also checks that the date actually exists
function validDate(value) {
    if (
        typeof value !== 'string'
        || !/^\d{4}-\d{2}-\d{2}$/.test(value)
    ) {
        return false;
    }

    const [year, month, day] = value.split('-').map(Number);

    const date = new Date(Date.UTC(year, month - 1, day));

    return year >= 1000
        && date.getUTCFullYear() === year
        && date.getUTCMonth() === month - 1
        && date.getUTCDate() === day;
}


// Check that booking data is valid
function validBooking(body) {
    return isObject(body)

        // Customer and depot must have positive IDs
        && positiveId(body.customer_id)
        && positiveId(body.depot_id)

        // Both dates must be valid
        && validDate(body.start_date)
        && validDate(body.end_date)

        // End date cannot be before start date
        && body.start_date <= body.end_date

        // Booking must contain at least one equipment item
        && Array.isArray(body.booking_lines)
        && body.booking_lines.length > 0

        // Each booking line must contain valid equipment ID and quantity
        && body.booking_lines.every(line =>
            isObject(line)
            && positiveId(line.equipment_id)
            && Number.isSafeInteger(line.quantity)
            && line.quantity > 0
            && line.quantity <= 2147483647
        )

        // The same equipment cannot occur twice in one booking
        && new Set(
            body.booking_lines.map(line => Number(line.equipment_id))
        ).size === body.booking_lines.length;
}


// Check that equipment report data is valid
function validReport(body) {
    return isObject(body)
        && positiveId(body.equipmentId)
        && typeof body.notes === 'string'
        && Array.isArray(body.checklist)
        && body.checklist.every(item =>
            typeof item === 'string'
        )
        && typeof body.damageFlag === 'boolean';
}

// Export validation functions
module.exports = {
    positiveId,
    isObject,
    validEquipment,
    validDate,
    validBooking,
    validReport
};