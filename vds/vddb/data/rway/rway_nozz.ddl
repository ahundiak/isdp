create table RWAY_NOZZLE                  -- Raceway Nozzle table for I/ROUTE
(
 VENDOR_NO      smallint,
 SHAPE          smallint,
 WIDTH          real,
 DEPTH          real,
 UNITS_SET      smallint,
 D1             real,
 T1             real,
 B1             real,
 F1             real,
 MACRO_NAME     char(20)
);

create table RWAY_NOZZ_DYNAMIC        -- Raceway Nozzle dynamic data --
(
  COMP_SEQNO     integer     NOT NULL,
  ASSEMBLY_CAT   char(20)    NOT NULL,
  ASSEMBLY_NAM   char(30)    NOT NULL,
  ASSEMBLY_VER   char(12)    NOT NULL,
  EQP_NUMBER     char(12),
  EQP_ID_NO      integer,
  WIDTH_G        real,
  DEPTH_G        real,
  TAG_NUMBER     char(20),
  SYSTEM_NAME    char(12),
  ZONE_NUMBER    char(4),
  MATERIAL       char(12),
  WEIGHT_GRP     smallint,
  SHOCK_GRADE    char(8),
  APPRV_STAT     char(8),
  CONSTR_STAT    char(8),
  CHG_NO         smallint,
  LOC_X          double,
  LOC_Y          double,
  LOC_Z          double,
  PRI_X          double,
  PRI_Y          double,
  PRI_Z          double,
  SEC_X          double,
  SEC_Y          double,
  SEC_Z          double,
  ERR_CMP_FLG    char(1)
);
