-- $ID$
--**************************************************************************
-- I/VDS
--
-- File:	vds/vddb/vds / vds.ddl
--
-- Description:
--    Table definitions for VDS applications.                                 --
--                                                                         --
-- History:
--
-- Rev  By   Chk  Date      Description                                    --
-- ---  ---  ---  --------  ---------------------------------------------- --
-- 0    BJ   BJ   2/10/91   Initial version.                               --
--                                                                         --
-- Notes:                                                                  --
--  1. RIS does not like TABS in this file.                                --
--  2. Tables are generated by inputing this file to RIS as follows:       --
--     RIS> default schema schema.passwd;                                  --
--     RIS> read vds.ddl;                                                  --
--                                                                         --
--*************************************************************************--

create table PIPING_PID_DYN	-- Piping PID Dynamic attributes --
(
 COMP_SEQNO     integer,
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),
 SPEC_NAME      char(8),
 COMP_CODE      char(6),
 NPD_G          real,
 NPD_R          real,
 OPT_CODE       smallint,
 TAG_NUMBER     char(20),
 SYSTEM_NAME    char(12),
 FLUID_CODE     char(4),
 SEQ_NUMBER     char(8),
 UNIT_NUMBER    char(4),
 ZONE_NUMBER    char(4),
 SCH_THK_OVR    char(8),
 COMP_NOTE      char(30),
 INSUL_TYPE     char(4),
 INSUL_THK      real,
 TRACING_CODE   char(4),
 PAINT_CODE     char(4),
 OP_TEMP        real,
 OP_PRESS       real,
 DGN_TEMP       real,
 DGN_PRESS      real,
 SPEC_GRAV      real,
 APPRV_STAT     char(8),
 CONSTR_STAT    char(8),
 WEIGHT_GRP     smallint,
 CHG_NO         smallint,
 NO_MTO_FLAG    char(1),
 BEND_SWEEP     double,			
 PIPE_LENGTH    real,
 FLOW_DIR       integer,
 FLD_WELD       integer,
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

create table PIPING_PID_NOZ_DYN     -- Piping PID Nozzle dynamic data --
(
 COMP_SEQNO     integer,
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),
 EQP_NUMBER     char(20),
 EQP_ID_NO      integer,
 TAG_NUMBER     char(20),
 NPD_G          real,
 RATING_G       char(8),
 PREP_G         char(8),
 SCH_THK_G      char(8),
 GEOM_STD       smallint,
 END_STD_G      char(8),
 SERVICE        char(8),
 N_APPRV_STAT   char(8),
 N_CONSTR_STAT  char(8),
 SPEC_NAME      char(8),
 OPT_CODE       smallint,
 SYSTEM_NAME    char(12),
 FLUID_CODE     char(4),
 SEQ_NUMBER     char(8),
 UNIT_NUMBER    char(4),
 ZONE_NUMBER    char(4),
 SCH_THK_OVR    char(8),
 INSUL_TYPE     char(4),
 INSUL_THK      real,
 TRACING_CODE   char(4),
 PAINT_CODE     char(4),
 OP_TEMP        real,
 OP_PRESS       real,
 DGN_TEMP       real,
 DGN_PRESS      real,
 SPEC_GRAV      real,
 APPRV_STAT     char(8),
 CONSTR_STAT    char(8),
 WEIGHT_GRP     smallint,
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

create table HVAC_PID_DYN                -- Hvac PID Dynamic data --
(
 COMP_SEQNO     integer,
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),
 SPEC_NAME      char(8),
 COMP_CODE      char(6),
 SHAPE_CODE     smallint,
 WIDTH_G        real,
 DEPTH_G        real,
 WIDTH_R        real,
 DEPTH_R        real,
 BEND_RAD       real,
 TRANS_LEN      real,
 TRANS_ANG      real,
 VEND_CODE      char(8),
 TAG_NUMBER     char(20),
 SYSTEM_NAME    char(12),
 SEQ_NUMBER     char(8),
 ZONE_NUMBER    char(4),
 MATERIAL       char(12),
 DUCT_THK       real,
 SURF_AREA      real,
 INSUL_TYPE     char(4),
 INSUL_THK      real,
 LINING_TYPE    char(4),
 LINING_THK     real,
 ADDNL_WT       real,
 WEIGHT_GRP     smallint,
 SHOCK_GRADE    char(8),
 COMP_NOTE      char(30),
 MAX_FRICT      real,
 MAX_VELOC      real,
 MIN_VELOC      real,
 CONST_DIM      smallint,
 APPRV_STAT     char(8),
 CONSTR_STAT    char(8),
 CHG_NO         smallint,
 NO_MTO_FLAG    char(1),
 DUCT_LENGTH    real,
 BEND_SWEEP     real,
 SIZE_METHOD    char(8),
 FLOW_RATE      real,
 VELOC_CALC     real,
 PRESS_DROP     real,
 EQUIV_DIA      real,
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

create table HVAC_PID_NOZ_DYN                -- Hvac PID Nozzle dynamic data --
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
  INSUL_TYPE     char(4),
  INSUL_THK      real,
  LINING_TYPE    char(4),
  LINING_THK     real,
  WEIGHT_GRP     smallint,
  SHOCK_GRADE    char(8),
  MAX_FRICT      real,
  MAX_VELOC      real,
  MIN_VELOC      real,
  CONST_DIM      smallint,
  APPRV_STAT     char(8),
  CONSTR_STAT    char(8),
  CHG_NO         smallint,
  SIZE_METHOD    char(8),
  FLOW_RATE      real,
  VELOC_CALC     real,
  PRESS_DROP     real,
  EQUIV_DIA      real,
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
