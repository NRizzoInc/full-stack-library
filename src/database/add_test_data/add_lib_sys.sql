USE libsystem;

-- Use this script to add a few library system tables
-- data pulled from https://mblc.state.ma.us/programs-and-support/library-networks/index.php
INSERT INTO library_system (library_sys_name) VALUES
    ("Metro Boston Library Network"),
    ("Fenway Library Organization"),
    ("Minuteman Library Network");

-- Add a few libraries. At least cover 2 library systems
INSERT INTO library (library_system, library_name, address, hours_of_operation, )