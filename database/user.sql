-------------------------------------------------------------------------------------------------------
-- DATABASE USER AND PERMISSIONS
-------------------------------------------------------------------------------------------------------

CREATE USER IF NOT EXISTS 'nordicrent_app'@'127.0.0.1'
    IDENTIFIED BY 'toor';

GRANT SELECT, INSERT, UPDATE, DELETE
ON nordicrent.*
TO 'nordicrent_app'@'127.0.0.1';

SHOW GRANTS FOR 'nordicrent_app'@'127.0.0.1';