

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

create table VCT_JUMP     -- terminal jumpers
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
 MAX_POSITION     smallint,
 WEIGHT           real,
 UNIT_COST        real,
 GN_DATA_1        real,
 GN_DATA_2        real,
 LCUNIT           smallint
);

create table VCT_ECABLE        -- Electrical cables        elcab_tab --
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
 INS_BLOCK        char(12),
 TUBE_SIZE        char(4),
 LUG_SIZE         real,
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

create table VCT_ECMAP          -- Electrical leads list            --
(
 COMP_CODE        char(20),

 CON_NUM          smallint,
 CON_NAME         char(12),
 DEF_SIGNAL       char(12) 
);

create table VCT_ECOND          -- Electrical leads characteristics --
(
 COMP_CODE        char(20),
 CON_NAME         char(12),

 CON_MATERIAL     char(12),
 DIAMETER         real,
 CLAD_DIAM        real,
 SECT_CONDUCT     real,
 VOLTAGE          real,
 MAXCURRENT       real,
 RESISTANCE       real,
 MODAL_BW         real,
 LEN_SCALE_FACTOR real,
 RESIS_MEASURE_WL real,
 SENSITIV         real,
 AMP_60_40        real,
 AMP_60_50        real,
 AMP_400_40       real,
 AMP_400_50       real,
 DT_DATA_1        real,
 DT_DATA_2        real
);

create table VCT_ETERM      -- Electrical terminals --
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

create table VCT_EMOD        -- Electrical modules characteristics --
(
 COMP_CODE       char(20),

 MOD_CODE        char(12),
 MOD_NAME        char(40),
 POS_NAME1       char(12),
 IOTYPE1         smallint,
 POS_NAME2       char(12),
 IOTYPE2         smallint,
 CONNECTYPE      smallint,
 DEF_SIGNAL      char(12)
);

create table VCT_EPIN        -- Electrical pins characteristics --
(
 COMP_CODE       char(20),

 MOD_CODE        char(12),
 POS_NAME        char(12),

 ALT_DIRECT      char(6),
 MAX_CONNECT     smallint,
 WORK_VOLT       real,
 PEAK_VOLT       real,
 FREQUENCY       real,
 SENSITIV        real,
 POWER_MEAN      real,
 POWER_MAX       real,
 POWER_STD_DEV   real,
 SENSI_STD_DEV   real,
 RISE_TIME       real,
 PRECISION_CODE  real,
 DT_DATA_1       real,
 DT_DATA_2       real
);



create table VCT_FCABLE        -- Fiberoptic cables        focab_tab --
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
 INS_BLOCK        char(12),
 TUBE_SIZE        char(4),
 LUG_SIZE         real,
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

create table VCT_FCMAP          -- Fiberoptic leads list            --
(
 COMP_CODE        char(20),

 CON_NUM          smallint,
 CON_NAME         char(12),
 DEF_SIGNAL       char(12) 
);

create table VCT_FCOND         -- Fiberoptic leads       focab_lead --
(
 COMP_CODE        char(20),

 CON_NAME         char(12),
 CON_MATCH        char(12),

 DIAMETER         real,
 CLAD_DIAM        real,
 MODAL_BW         real,
 NUMERIC_APERTURE real,
 CHROM_DISP_SLOPE real,
 ZERO_DISP_SLOPE  real,
 ATTENUATION      real,
 ATTEN_MEASURE_WL real,
 LMT_PH_SPACE_ATT real,
 H_ORDER_MOD_LOSS real,
 LEN_SCALE_FACTOR real,
 SENSITIV         real,
 DT_DATA_1        real,
 DT_DATA_2        real
);

create table VCT_FTERM       -- Fiberoptic terminals --
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

create table VCT_FMOD         -- Fiberoptic modules characteristics --
(
 COMP_CODE       char(20),

 MOD_CODE        char(12),
 MOD_NAME        char(40),
 POS_NAME1       char(12),
 IOTYPE1         smallint,
 POS_NAME2       char(12),
 IOTYPE2         smallint,
 CONNECTYPE      smallint,
 DEF_SIGNAL      char(12)
);

create table VCT_FPIN         -- Fiberoptic pins characteristics --
(
 COMP_CODE       char(20),

 MOD_CODE        char(12),
 POS_NAME        char(12),
 CON_MATCH       char(20),

 BANDWIDTH       real,
 SPECTRAL_W      real,
 LAMBDA_C        real,
 ANG_DISTRIB     real,
 SENSITIV        real,
 POWER_MEAN      real,
 POWER_MAX       real,
 POWER_STD_DEV   real,
 SENSI_STD_DEV   real,
 RISE_TIME       real,
 DT_DATA_1       real,
 DT_DATA_2       real
);

create table VCT_FSEL         -- fiber optic connector/splice select    fosel --
(
 CON_MATCH         char(20),
 CON_SPL_DEF       char(20)
);

create table  VCT_FCON        -- Fiber optic connectors/splices     focon --
(
 CON_SPL_DEF      char(20),
 CNTYPE           char(12),

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

 MODAL_BW         real,
 NUMERIC_APERTURE real,
 CHROM_DISP_SLOPE real,
 ZERO_DISP_SLOPE  real,
 ATTENUATION      real,
 ATTEN_MEASURE_WL real,
 LMT_PH_SPACE_ATT real,
 H_ORDER_MOD_LOSS real,
 LEN_SCALE_FACTOR real,
 SENSITIV         real,
 DT_DATA_1        real,
 DT_DATA_2        real
);
