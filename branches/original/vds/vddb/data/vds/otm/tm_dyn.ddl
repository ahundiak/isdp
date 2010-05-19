create table TM_TEST_DYNAMIC
(
 COMP_SEQNO     integer,   -- Node Number
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),

 FILE_KEY       integer,
 TREE_KEY       integer,   -- Not currently used
 SORT_KEY       integer,

 TREE_TYPE      char(15),
 TREE_NAME      char(31),
 TREE_REV       char(3),
 NODE_TYPE      char(15),
 NODE_NAME      char(31),

 PARENT_SEQNO   integer,    -- Parent Node Number

 -- Custom attributes follow

 AVHULL         char(5),
 CONTRACTHULL   char(8),
 ZONE_NUM       int,
 UNIT_NUM       int,
 COMPT_NUM      char(20),

 MODEL_KEY      int,
 MODEL_OBJID    int
);

create index tm_test_dyn_i1 on tm_test_dynamic(file_key,tree_type,tree_name,sort_key);

-------------------------------------------------------------------------
-- Pallet Assys

create table TM_PALLET_DYNAMIC
(
 COMP_SEQNO     integer,   -- Node Number
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),

 FILE_KEY       integer,
 TREE_KEY       integer,   -- Not currently used
 SORT_KEY       integer,

 TREE_TYPE      char(15),
 TREE_NAME      char(31),
 TREE_REV       char(3),
 NODE_TYPE      char(15),
 NODE_NAME      char(31),

 PARENT_SEQNO   integer,    -- Parent Node Number

 -- Custom attributes follow

 PALLET_CODE    char(19),
 TREE_INDEX     char(40),
 MINO           char(19),
 COPICS_NUM     char(19),
 NOMENCLATURE   char(80),
 PART_DESCR     char(80),
 PART_REMARKS   char(80),
 PART_REV       char(3),
 PART_NO        char(24),
 ISDP_NAME      char(80),
 ISDP_PATH      char(80),
 STOCK          char(25),
 MOD_LENGTH     real,
 QTY            real,
 UNIT_MEASURE   char(2),
 MODEL_KEY      int,
 MODEL_OBJID    int
);

create index tm_pallet_dyn_i1 on tm_pallet_dynamic(file_key,tree_type,tree_name,sort_key);

--------------------------------------------------------
-- Outfit tree

create table TM_OUTFIT_DYNAMIC     -- Outfit Tree Posting Table --
(
 COMP_SEQNO     integer,   -- Node Number
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),

 FILE_KEY       integer,
 TREE_KEY       integer,   -- Not currently used
 SORT_KEY       integer,

 TREE_TYPE      char(15),
 TREE_NAME      char(31),
 TREE_REV       char(3),
 NODE_TYPE      char(15),
 NODE_NAME      char(31),

 PARENT_SEQNO   integer,    -- Parent Node Number

 -- Custom attributes follow

 PARENT_TREE_INDEX   char(40),
 TREE_INDEX          char(40),
 PART_TYPE           int,
 AVHULL              char(5),
 CONTRACTHULL        char(8),
 ZONE_NUM            int,
 UNIT_NUM            int,
 COMPT_NUM           char(20),
 COMM_CODE           char(4),
 COMMODITY           char(25),
 COST_CODE           char(8),
 DRAWING_NO          char(30),
 NODE_COUNT          int,
 FROZEN              char(6),
 WEIGHT              real,
 QTY                 real,
 UNIT_MEASURE        char(2),
 PART_SIZE           char(40),
 MATERIAL            char(25),
 GRADE               char(8),
 PLATE_THK           real,
 TREATMENT           char(80),
 CAGE                char(5),
 MINO                char(19),
 COPICS_STATUS       char(3),
 COPICS_NUM          char(19),
 LINE_IDENT          char(19),
 FIAN                char(20),
 PAINT_REF           char(24),
 ASSY_DESCR          char(80),
 ASSY_REMARKS        char(80),
 ASSY_DATE           char(20),
 ASSY_REV            char(3),
 NOMENCLATURE        char(80),
 PART_DESCR          char(80),
 PART_REMARKS        char(80),
 PART_REV            char(3),
 PART_NO             char(24),
 ISDP_NAME           char(80),
 ISDP_PATH           char(80),
 STOCK               char(25),
 MOD_LENGTH          real,
 DETAIL_NO           char(19),
 DETAIL_TYPE         int,
 DETAIL_SEQ          int,
 DETAIL_DIR	     char(8),
 DETAIL_LOC	     char(40),
 DETAIL_USR	     char(8),
 PALLET_CODE	     char(19),
 MODEL_KEY	     int,
 MODEL_OBJID         int
);

create index tm_outfit_dyn_i1 on tm_outfit_dynamic(file_key,tree_type,tree_name,sort_key);

---------------------------------------------------------------------
--
create table TM_CABLE_DYNAMIC     -- Cable Tree Posting Table --
(
 COMP_SEQNO     integer,   -- Node Number
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),

 FILE_KEY       integer,
 TREE_KEY       integer,   -- Not currently used
 SORT_KEY       integer,

 TREE_TYPE      char(15),
 TREE_NAME      char(31),
 TREE_REV       char(3),
 NODE_TYPE      char(15),
 NODE_NAME      char(31),

 PARENT_SEQNO   integer,    -- Parent Node Number

 -- Custom attributes follow

 PARENT_TREE_INDEX   char(40),
 TREE_INDEX          char(40),
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
 MODEL_KEY           int,
 MODEL_OBJID         int
);

create index tm_cable_dyn_i1 on tm_cable_dynamic(file_key,tree_type,tree_name,sort_key);

------------------------------------------------------------------------
-- 
create table TM_WWAY_DYNAMIC     -- WireWay Tree Posting Table --
(
 COMP_SEQNO     integer,   -- Node Number
 ASSEMBLY_CAT   char(20),
 ASSEMBLY_NAM   char(30),
 ASSEMBLY_VER   char(12),

 FILE_KEY       integer,
 TREE_KEY       integer,   -- Not currently used
 SORT_KEY       integer,

 TREE_TYPE      char(15),
 TREE_NAME      char(31),
 TREE_REV       char(3),
 NODE_TYPE      char(15),
 NODE_NAME      char(31),

 PARENT_SEQNO   integer,    -- Parent Node

 -- Custom attributes follow

 PARENT_TREE_INDEX   char(40),
 TREE_INDEX          char(40),
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
 MODEL_KEY           int,
 MODEL_OBJID         int
);

create index tm_wway_dyn_i1 on tm_wway_dynamic(file_key,tree_type,tree_name,sort_key);






