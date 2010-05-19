--                                  --
--    Electrical Dynamic Posting    -- 
--                                  --

create table VCSCH_GUIDE     -- Cable harness/conduit (diagram) --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(55),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 ESTIM_LENGTH     real
);

create table VCSCH_ECABLE     -- Electrical cables (diagram) --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(55),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 FR_EQPT_TAG      char(20),
 FR_EQPT_SEQNO    integer,
 FR_EQPT_CAT      char(20),
 FR_EQPT_NAM      char(30),
 FR_EQPT_VER      char(12),

 FR_TERM_TAG      char(55),
 FR_TERM_SEQNO    integer,
 FR_TERM_CAT      char(20),
 FR_TERM_NAM      char(30),
 FR_TERM_VER      char(12),

 TO_EQPT_TAG      char(20),
 TO_EQPT_SEQNO    integer,
 TO_EQPT_CAT      char(20),
 TO_EQPT_NAM      char(30),
 TO_EQPT_VER      char(12),

 TO_TERM_TAG      char(55),
 TO_TERM_SEQNO    integer,
 TO_TERM_CAT      char(20),
 TO_TERM_NAM      char(30),
 TO_TERM_VER      char(12),

 ESTIM_LENGTH     real,
 TAIL_LENGTH      real
);

create table VCSCH_FCABLE     -- Fiberoptic cables (diagram) --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(55),
 COMP_CODE        char(20),
 ADDITIONAL_LABEL char(20),

 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),

 FR_EQPT_TAG      char(20),
 FR_EQPT_SEQNO    integer,
 FR_EQPT_CAT      char(20),
 FR_EQPT_NAM      char(30),
 FR_EQPT_VER      char(12),

 FR_TERM_TAG      char(55),
 FR_TERM_SEQNO    integer,
 FR_TERM_CAT      char(20),
 FR_TERM_NAM      char(30),
 FR_TERM_VER      char(12),

 TO_EQPT_TAG      char(20),
 TO_EQPT_SEQNO    integer,
 TO_EQPT_CAT      char(20),
 TO_EQPT_NAM      char(30),
 TO_EQPT_VER      char(12),

 TO_TERM_TAG      char(55),
 TO_TERM_SEQNO    integer,
 TO_TERM_CAT      char(20),
 TO_TERM_NAM      char(30),
 TO_TERM_VER      char(12),
 
 ESTIM_LENGTH     real,
 TAIL_LENGTH      real
);

create table VCSCH_ETERM     -- Electrical terminals  (diagram) --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(55),
 COMP_CODE        char(20),

 EQPT_TAG         char(20),
 EQPT_SEQNO       integer,
 EQPT_CAT         char(20),
 EQPT_NAM         char(30),
 EQPT_VER         char(12),

 ADDITIONAL_LABEL char(20),
 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),
 IMPLIED_QTY      real
);

create table VCSCH_EBKSHELL     -- Backshell (diagram) --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 COMP_CODE        char(20),

 EQPT_TAG         char(20),
 EQPT_SEQNO       integer,
 EQPT_CAT         char(20),
 EQPT_NAM         char(30),
 EQPT_VER         char(12),

 TERM_TAG         char(55),
 TERM_SEQNO       integer,
 TERM_CAT         char(20),
 TERM_NAM         char(30),
 TERM_VER         char(12),
 
 ADDITIONAL_LABEL char(20),
 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1),
 IMPLIED_QTY      real
);

create table VCSCH_FTERM     -- Fiberoptic terminals (diagram) --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(55),
 COMP_CODE        char(20),

 EQPT_TAG         char(20),
 EQPT_SEQNO       integer,
 EQPT_CAT         char(20),
 EQPT_NAM         char(30),
 EQPT_VER         char(12),

 ADDITIONAL_LABEL char(20),
 SYSTEM_NAME      char(12),
 UNIT_NUMBER      char(12),
 COMP_NOTE        char(40),

 APPRV_STAT       char(12),
 CONSTR_STAT      char(12),
 CHG_NO           char(12),
 NO_MTO_FLAG      char(1)
);

create table VCSCH_JUMP     -- Terminal Jumpers (diagram) --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),
 
 JUMPERID         integer,
 COMP_CODE        char(20),

 EQPT_TAG         char(20),
 EQPT_SEQNO       integer,
 EQPT_CAT         char(20),
 EQPT_NAM         char(30),
 EQPT_VER         char(12),

 TERM_TAG         char(55),
 TERM_SEQNO       integer,
 TERM_CAT         char(20),
 TERM_NAM         char(30),
 TERM_VER         char(12),

 COMP_NOTE        char(40),
 CNT_VS_MAX       char(1),
 NO_MTO_FLAG      char(1)
);

create table VCSCH_JMPLOC     -- Terminal Jumper Locations (diagram) --
(
 COMP_SEQNO        integer,
 ASSEMBLY_CAT      char(20),
 ASSEMBLY_NAM      char(30),
 ASSEMBLY_VER      char(12),

 JUMPERID          integer,
 COMP_CODE         char(20),

 TERM_MOD          char(12),
 TERM_POS          char(12)
);

create table VCSCH_ELEAD     -- Electrical leads --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(55),
 CON_NAME         char(12),
 SIGNALNAME       char(12),

 COMP_CODE        char(20),

 FR_EQPT_TAG      char(20),
 FR_EQPT_SEQNO    integer,
 FR_EQPT_CAT      char(20),
 FR_EQPT_NAM      char(30),
 FR_EQPT_VER      char(12),

 FR_TERM_TAG      char(55),
 FR_TERM_SEQNO    integer,
 FR_TERM_CAT      char(20),
 FR_TERM_NAM      char(30),
 FR_TERM_VER      char(12),
 FR_TERM_MOD      char(12),
 FR_TERM_POS      char(12),

 TO_EQPT_TAG      char(20),
 TO_EQPT_SEQNO    integer,
 TO_EQPT_CAT      char(20),
 TO_EQPT_NAM      char(30),
 TO_EQPT_VER      char(12),

 TO_TERM_TAG      char(55),
 TO_TERM_SEQNO    integer,
 TO_TERM_CAT      char(20),
 TO_TERM_NAM      char(30),
 TO_TERM_VER      char(12),
 TO_TERM_MOD      char(12),
 TO_TERM_POS      char(12)
);

create table VCSCH_FLEAD     -- Fiberoptic leads --
(
 COMP_SEQNO       integer,
 ASSEMBLY_CAT     char(20),
 ASSEMBLY_NAM     char(30),
 ASSEMBLY_VER     char(12),

 TAG_NUMBER       char(55),
 CON_NAME         char(12),
 SIGNALNAME       char(12),

 COMP_CODE        char(20),

 FR_EQPT_TAG      char(20),
 FR_EQPT_SEQNO    integer,
 FR_EQPT_CAT      char(20),
 FR_EQPT_NAM      char(30),
 FR_EQPT_VER      char(12),

 FR_TERM_TAG      char(55),
 FR_TERM_SEQNO    integer,
 FR_TERM_CAT      char(20),
 FR_TERM_NAM      char(30),
 FR_TERM_VER      char(12),
 FR_CON_SPL       char(20),
 FR_TERM_MOD      char(12),
 FR_TERM_POS      char(12),

 TO_EQPT_TAG      char(20),
 TO_EQPT_SEQNO    integer,
 TO_EQPT_CAT      char(20),
 TO_EQPT_NAM      char(30),
 TO_EQPT_VER      char(12),

 TO_TERM_TAG      char(55),
 TO_TERM_SEQNO    integer,
 TO_TERM_CAT      char(20),
 TO_TERM_NAM      char(30),
 TO_TERM_VER      char(12),
 TO_CON_SPL       char(20),
 TO_TERM_MOD      char(12),
 TO_TERM_POS      char(12)
);

create table VRSCH_EQUIP_DYN     -- PID Equipment --
(
 COMP_SEQNO     integer,
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),

 EQP_FAMILY     char(20),
 EQP_PARTNO     char(30),
 EQP_PARTREV    char(12),
 NOMENCLATURE   char(32),

 EQP_NUMBER     char(20),
 EQP_DESCR      char(40),
 EQP_TYPE       char(12),
 
 UNIT_NUMBER    char(6),
 COMPT_NUMBER   char(20),
 ESWBS          char(5),
 HSC            char(14),
 REMARKS        char(40),
 CAGE           char(5),
 
 APPRV_STAT     char(12),
 CONSTR_STAT    char(12),
 CHG_NO         char(12),
 NO_MTO_FLAG    char(1)
);
