create table VRSCH_EQUIP_DYN

(
 COMP_SEQNO     integer,
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),
 EQP_FAMILY     char(20),
 EQP_PARTNO     char(30),
 EQP_PARTREV    char(12),
 EQP_NUMBER     char(20),
 EQP_ID_NO      integer,
 EQP_DESCR      char(40),
 EQP_TYPE       char(12),
 
 UNIT_NUMBER    char(6),
 COMPT_NUMBER   char(20),
 CINO           char(20),
 ESWBS          char(5),
 HSC            char(14),
 REMARKS        char(40),
 AII_DWG_NO     char(30),
 LP_INSC        char(40),
 LP_FIG_NO      char(6),
 LP_TYPE        char(12),
 LP_CAT         char(12),
 DRAWING_CODE   char(12),
 MFR_NAME       char(20),
 MFR_PART_NO    char(40),
 MFR_DWG_NO     char(30),
 VEN_NAME       char(20),
 CAGE           char(5),
 
 APPRV_STAT     char(12),
 CONSTR_STAT    char(12),
 CHG_NO         char(12),
 NO_MTO_FLAG    char(1)
);
