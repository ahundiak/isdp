-- $ID$
--**************************************************************************
-- I/VDS
--
-- File:        vds/vddb/vds / tm_sp14upd.ddl
--
-- Description:
--    Table definitions for Tree Manager applications.                     --
--                                                                         --
-- History:
--
-- Rev  By   Chk  Date      Description                                    --
-- ---  ---  ---  --------  ---------------------------------------------- --
-- 0    JS   JS   3/20/00   Initial version.                               --
-- 
--
--  Notes:                                                                 --
--  1. RIS does not like TABS in this file.                                --
--  2. Tables are generated by inputing this file to RIS as follows:       --
--     RIS> default schema schema.passwd;                                  --
--     RIS> read vds.ddl;                                                  --
--                                                                         --
--*************************************************************************--

create table TM_ELEC_DWG        -- Links dwg num to dwg code, title, section
(
       DWG_NUM        char(13),
       DWG_CODE       char(2),
       DWG_TITLE      char(240),
       SECT_NUM       char(2)
);

create table TM_CABLE_DYNAMIC     -- Cable Tree Posting Table --
(
       PARENT_TREE_INDEX   char(40),
       TREE_INDEX          char(40),
       PDM_CATALOG         char(20),
       PDM_PART            char(15),
       PDM_REV             char(15),
       NODE_NAME           char(24),
       NODE_TYPE           int,
       PART_TYPE           int,
       FROZEN              char(6),
       ASSY_REV            char(3),
       ASSY_DATE           char(20),
       PART_DATE           char(20),
       AV_HULL             char(5),
       DWG_NUM             char(30),
       DWG_REV             char(3),
       DWG_CODE            char(2),
       DWG_TITLE           char(240),
       LABOR_CODE          char(2),
       PAL_GROUP           char(2),
       COMPARTMENT         char(20),
       UNIT                char(4),
       CAGE                char(5),
       MINO                char(19),
       NOMENCLATURE        char(80),
       ASSY_DESCR          char(80),
       ASSY_REMARKS        char(80),
       PART_DESCR          char(80),
       PART_REMARKS        char(80),
       WEIGHT              char(20),
       WEIGHT_UNITS        char(8),
       PALLET              char(19),
       FILE_KEY	           int,
       MODEL_KEY           int,
       MODEL_OBJID         int
);


create table TM_WWAY_DYNAMIC     -- WireWay Tree Posting Table --
(
       PARENT_TREE_INDEX   char(40),
       TREE_INDEX          char(40),
       PDM_CATALOG         char(20),
       PDM_PART            char(15),
       PDM_REV             char(15),
       NODE_NAME           char(24),
       NODE_TYPE           int,
       PART_TYPE           int,
       FROZEN              char(6),
       ASSY_REV            char(3),
       ASSY_DATE           char(20),
       PART_DATE           char(20),
       NODE_COUNT          int,
       AV_HULL             char(5),
       ZONE                char(4),
       UNIT                char(4),
       COMPARTMENT         char(20),
       COM_CODE            char(4),
       COMMODITY           char(25),
       COST_CODE           char(8),
       DWG_NUM             char(30),
       DWG_REV             char(3),
       DWG_CODE            char(2),
       DWG_TITLE           char(240),
       LABOR_CODE          char(2),
       PAL_GROUP           char(24),
       CAGE                char(5),
       MINO                char(19),
       NOMENCLATURE        char(80),
       ASSY_DESCR          char(80),
       ASSY_REMARKS        char(80),
       PART_DESCR          char(80),
       PART_REMARKS        char(80),
       WEIGHT              char(20),
       WEIGHT_UNITS        char(8),
       QTY                 char(20),
       UNIT_MEASURE        char(2),
       FIAN                char(20),
       LINE_IDENT          char(19),
       PALLET              char(19),
       TIER_SPACING        char(19),
       METHOD_NO           char(19),
       METHOD_TYPE         char(19),
       PACKING_METHOD      char(19),
       COLLAR_TYPE         char(19),
       HOLE_NO             char(19),
       WELD_SYMBOL         char(19),
       ORIENTATION         char(19),
       FILE_KEY            int,
       MODEL_KEY           int,
       MODEL_OBJID         int
);



