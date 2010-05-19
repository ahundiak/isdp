
create table VCT_GUIDE     -- cable harness/conduit
(
 COMP_CODE        char(20),

 OWNER_ID         char(12),
 TIMEST           char(30),

 SHORT_DESC       char(40),
 STANDARD         char(32),
 ENVIRONMENT      char(12),
 FIRE_RESIST      char(12),
 SECURITY         char(12),
 FULL_DESC        char(240),
 VENDOR           char(32),
 CATALOG          char(20),
 STOCK_NO         char(20),

 WEIGHT           real,
 UNIT_COST        real,
 GN_DATA_1        real,
 GN_DATA_2        real,
 LCUNIT           smallint,

 INSUL_TYPE       char(8),
 INSUL_THK        real,
 DIAMETER         real,
 BEND_RAD         real
);

create table VCT_BKSHELL     -- terminal backshell
(
 COMP_CODE        char(20),

 OWNER_ID         char(12),
 TIMEST           char(30),

 MACRO_NAME       char(12),

 SHORT_DESC       char(40),
 STANDARD         char(32),
 ENVIRONMENT      char(12),
 FIRE_RESIST      char(12),
 SECURITY         char(12),
 FULL_DESC        char(240),
 VENDOR           char(32),
 CATALOG          char(20),
 STOCK_NO         char(20),
 WEIGHT           real,
 UNIT_COST        real,
 GN_DATA_1        real,
 GN_DATA_2        real,
 LCUNIT           smallint
);

