USE libsystem;

-- Use this script to add a few library system tables
-- data pulled from https://mblc.state.ma.us/programs-and-support/library-networks/index.php
INSERT INTO library_system (library_sys_name) VALUES
    ("Metro Boston Library Network"),
    ("Old Colony Library Network"),
    ("Minuteman Library Network");

-- Add a few libraries. Have 5 libraries spread across 2 library systems.

-- Metro Boston Library locations come from here:
-- https://bpl.bibliocommons.com/locations/
-- Simplifying hours of operation to weekdays

CALL add_library("Metro Boston Library Network", "Charlestown",
        "179 Main St Charlestown, MA 02129", '10:00', '18:00', 5);
CALL add_library("Metro Boston Library Network", "Central Library in Copley Square",
        "700 Boylston Street Boston, MA 02116", '10:00', '8:00', 5);
CALL add_library("Metro Boston Library Network", "Jamaica Plain",
        "30 South Street Jamaica Plain, MA 02130", '10:00', '6:00', 5);
-- Reference: https://catalog.ocln.org/client/en_US/ocln/?rm=LIBRARY+LOCATI1%7C%7C%7C1%7C%7C%7C3%7C%7C%7Ctrue
CALL add_library("Old Colony Library Network", "Plymouth Public Library",
        "132 South Street Plymouth, MA 02360", '10:00', '9:00', 8);
CALL add_library("Old Colony Library Network", "Kingston Public Library",
        "6 Green Street Kingston, MA 02364", '10:00', '5:00', 4);
