--
--    output DB tables    POSTING -- 
--    This doesn't contain the Table for "Leads" 

create table VCSCH_GUIDE     -- cable harness/conduit
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(30),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 LENGTH           real,

 COG_X            real,
 COG_Y            real,
 COG_Z            real
);

create table VCSCH_ECABLE     -- Electrical cables  --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(30),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 FROMEQ           char(20),
 FROMCINO         char(20),
 FROMTG           char(20),

 TOEQ             char(20),
 TOCINO           char(20),
 TOTG             char(20),

 LENGTH           real,

 COG_X            real,
 COG_Y            real,
 COG_Z            real 
);

create table VCSCH_FCABLE     -- Fiberoptic cables  --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(30),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 FROMEQ           char(20),
 FROMCINO         char(20),
 FROMTG           char(20),

 TOEQ             char(20),
 TOCINO           char(20),
 TOTG             char(20),
 
 LENGTH           real,

 COG_X            real,
 COG_Y            real,
 COG_Z            real 
);

create table VCSCH_ETERM     -- Electrical terminals  --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 EQ_TAG           char(20),
 EQ_CINO          char(20),
 TAG_NUMBER       char(30),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 COG_X            real,
 COG_Y            real,
 COG_Z            real
);


create table VCSCH_EBKSHELL     -- Backshell --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TERM_TAG         char(30),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),
 NO_MTO_FLAG      char(1),
 UNIT_NUMBER      char(12),
 SYSTEM_NAME      char(12),
 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 COMP_NOTE        char(40)
);

create table VCSCH_FTERM     -- Fiberoptic terminals  --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 EQ_TAG           char(20),
 EQ_CINO          char(20),
 TAG_NUMBER       char(30),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 COG_X            real,
 COG_Y            real,
 COG_Z            real
);
