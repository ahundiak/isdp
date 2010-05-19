--
--    output DB tables    POSTING -- 

create table VCDYN_GUIDE     -- cable harness/conduit
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

create table VCDYN_ECABLE     -- Electrical cables  --
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

create table VCDYN_ELEAD     -- Electrical leads  --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(30),
 LEADID           char(12),
 SIGNALNAME       char(12),

 COMP_CODE        char(21),

 FLAGSET          smallint,

 FROMEQ           char(20),
 FROMCINO         char(20),
 FROMTAG          char(20),
 FROMMOD          char(12),
 FROMPOS          char(12),

 TOEQ             char(20),
 TOCINO           char(20),
 TOTAG            char(20),
 TOMOD            char(12),
 TOPOS            char(12)
);

create table VCDYN_FCABLE     -- Fiberoptic cables  --
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

create table VCDYN_FLEAD     -- Fiberoptic leads  --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(30),
 LEADID           char(12),
 SIGNALNAME       char(12),

 COMP_CODE        char(20),
 CON_MATCH        char(12),

 FLAGSET          smallint,

 FROMEQ           char(20),
 FROMCINO         char(20),
 FROMTAG          char(20),
 FROMMOD          char(12),
 FROMPOS          char(12),

 TOEQ             char(20),
 TOCINO           char(20),
 TOTAG            char(20),
 TOMOD            char(12),
 TOPOS            char(12)
);

create table VCDYN_ETERM     -- Electrical terminals  --
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


create table VCDYN_FTERM     -- Fiberoptic terminals  --
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

create table VCDYN_EBKSHELL     -- Backshells/Connection Components --
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
