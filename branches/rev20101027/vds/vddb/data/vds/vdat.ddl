-- 11 Jan 1998 Art Hundiak
-- These are the tables for the Assembly Tree
-- More documentation will be available later

-- ************************************************
-- User defined production data example
-- The name of the table must be added to vdat_postable
-- You must add an entry to vdat_nodes in order to link this table
-- With one or more set types
--
create table VDAT_U_PROD_TABLE
(
FILE_KEY	integer,    -- Required, unique file identifier

SET_KEY		integer,    -- Required, unique set identifier
SET_NAME	char(20),   -- Required, set name
SET_TYPE	char(20),   -- Required, set type

COMP_SEQNO      integer,    -- Component (plate, beam etc) sequence number	
COMP_PATH       char(100),  -- Optional, Component's ISDP path
COMP_NAME       char(40),   -- Optional, Component's IDSP name

ASSEMBLY_CAT    char(20),   -- Components file information, required for
ASSEMBLY_NAM    char(30),   -- standard queries
ASSEMBLY_VER    char(12),
ASSEMBLY_KEY    integer,    

LEAF_SEQNO	integer,    -- Leaf object information, tells you which
LEAF_CAT        char(20),   -- file the set was created in, These are
LEAF_NAM        char(30),   -- all optional, the Assembly Manager relies
LEAF_VER        char(12),   -- on file_key for the same information
LEAF_CLASS	char(20),   -- Future use

U_PRI_PROCESS   char(40),   -- User define attributes
U_SEC_PROCESS   char(40),   -- You can use vdat_attrs to assign values
U_PRI_PRC_LOC   char(40),
U_SEC_PRC_LOC   char(40)

);

-- ************************************************
-- Assembly Tree Pieces Data
-- The name of the table must be added to vdat_postable
-- You must add an entry to vdat_nodes in order to link this table
-- With one or more set types
--

create table VDAT_PIECES   		
(
FILE_KEY	integer,   -- Required, unique file identifier

SET_KEY		integer,    -- Required, unique set identifier
SET_NAME	char(20),   -- Required, set name
SET_TYPE	char(20),   -- Required, set type

COMP_SEQNO      integer,    -- Component (plate, beam etc) sequence number	
COMP_PATH       char(100),  -- Optional, Component's ISDP path
COMP_NAME       char(40),   -- Optional, Component's IDSP name

ASSEMBLY_CAT    char(20),   -- Components file information, required for
ASSEMBLY_NAM    char(30),   -- standard queries
ASSEMBLY_VER    char(12),
ASSEMBLY_KEY    integer,    

LEAF_SEQNO	integer,    -- Leaf object information, tells you which
LEAF_CAT        char(20),   -- file the set was created in, These are
LEAF_NAM        char(30),   -- all optional, the Assembly Manager relies
LEAF_VER        char(12),   -- on file_key for the same information
LEAF_CLASS	char(20),   -- Future use

NODE_ORDER       integer,   -- Order within a node
NODE_QTY         integer,   -- Number of identical NODES(future)
NODE_PATH        char(80),  -- 

PARENT_PATH      char(80),
PARENT_SEQNO	 integer,   -- Parents objid for reconstructing

PIECE_NUM        char(20),  -- User define attributes

NODE_DESC        char(80),  -- User defined information.
U_PRI_PROCESS    char(40),
U_SEC_PROCESS    char(40),

SIZE_X           double,     -- Size of Stage (length)
SIZE_Y           double,     -- Size of Stage (depth)
SIZE_Z           double,     -- Size of Stage (height)

VOLUME           double,     -- Volume of Stage.
WEIGHT           double,     -- Weight of Structural Components.

COG_X            double,     -- Center of Gravity.
COG_Y            double,     -- Center of Gravity.
COG_Z            double      -- Center of Gravity.

);

-- ************************************************
-- Assembly Tree Node or Stages Data
-- The name of the table must be added to vdat_postable
-- You must add an entry to vdat_nodes in order to link this table
-- With one or more set types
--
create table VDAT_STAGES
(
FILE_KEY	integer,

SET_KEY		integer,    -- Required, unique set identifier
SET_NAME	char(20),   -- Required, set name
SET_TYPE	char(20),   -- Required, set type

NODE_SEQNO      integer,   -- Node object information
NODE_CAT     	char(20),
NODE_NAM     	char(30),
NODE_VER        char(12),
NODE_CLASS	char(20),

NODE_ORDER      integer,   -- Order within a node
NODE_QTY        integer,   -- Number of identical NODES.

NODE_TYPE       char(20),  -- Stage type
NODE_PATH       char(80),  -- Concatenated PathName.

PARENT_PATH     char(80),  -- Name of the  parent of assembly node.
PARENT_SEQNO	integer,   -- Parent objid

NODE_NAME       char(40),  -- User defined information
NODE_DESC       char(80),

U_ZONE	 	char(60),  -- Process Zone information.
U_AREA      	char(60),  -- Process AREA information.
U_STAGE		char(60),  -- Process STAGE information.
U_LUG_INFO      char(60),  -- LUG location information.

SIZE_X          double,	   -- Size of Stage (length)
SIZE_Y          double,	   -- Size of Stage (depth)
SIZE_Z          double,	   -- Size of Stage (height)

VOLUME          double,	   -- Volume of Stage.
WEIGHT          double,	   -- Weight of Structural Components.

COG_X           double,	   -- Center of Gravity.
COG_Y           double,	   -- Center of Gravity.
COG_Z           double 	   -- Center of Gravity.

);

-- ******************************************
-- Specify detail macros
create table VDAT_MACROS
(
MACRO_USE  char(20),
MACRO_NAME char(20),
MACRO_PPL  char(20)
);

-- ******************************************
-- Attributes with predefined lists of values
--
create table VDAT_ATTRS
(
ATTR_NAME       char(20),
ATTR_PROMPT     char(20),
ATTR_DESC       char(80),
ATTR_TYPE       integer,
ATTR_PPL        char(20)
);

-- ******************************************
-- Predefined values for attributes
--
create table VDAT_ATTR_VALUES
(
ATTR_NAME       char(20),
ATTR_SORT	integer,
ATTR_INT	integer,
ATTR_DBL	double,
ATTR_TXT	char(80),
ATTR_DESC       char(80)
);

-- ******************************************
-- Types of available sets
create table VDAT_SET_TYPES
(
SET_TYPE		char(20),
SET_TYPE_DESC		char(80)
);

-- ******************************************
-- Defines the nodes/leafs in a set
create table VDAT_SET_NODES	
(
SET_TYPE		char(20),
NODE_TYPE		char(20),	-- Ex: UNIT, PSU, PSA, etc.

NODE_LEVEL              integer,
NODE_DESC		char(80),
NODE_TABLE_NAME		char(20),

NODE_SYNTAX		char(80),	-- syntax definition: [0-999]
NODE_NAME_CONS		char(80),	-- Name Constraint (ex: Unique in UNIT or STAGE).
NODE_PATH_DESC		char(20),	-- 
NODE_PATH_SEP		char(2),	-- Seperator between nodes.
NODE_PATH_SWAP		integer,	-- Indicator to swap with child path.(Ex: "273-1-A-1" -> "273-1-1A")
NODE_PATH_PREFIX	char(20)	-- Print out control/prefix. Ex: "CPSU 273-1-1A"

);

-- *******************************************
-- All the postable tables to check
create table VDAT_POSTABLE
(
  TABLE_NAME		char(20)
);

-- *******************************************
-- Each posted set gets an entry
create table VDAT_SET_KEYS
(
FILE_KEY      integer,
SET_KEY       integer,

SET_SEQNO     integer,
SET_CAT       char(20),
SET_NAM       char(30),
SET_VER       char(12),

SET_NAME      char(20),
SET_TYPE      char(20),
SET_DESC      char(80)
);

-- *******************************************
-- Just for grins, each file posted
-- gets assigned an enviroment unique number
-- Aslo save file name for debugging
create table VDAT_FILE_KEYS
(
FILE_KEY       integer,
FILE_CAT       char(20),
FILE_NAM       char(30),
FILE_VER       char(12),
FILE_NAME      char(20)
);

-- *******************************************
-- Each file containing an object in the set
create table VDAT_SET_REF_KEYS
(
FILE_KEY  integer,
SET_KEY   integer,
REF_KEY	  integer
);

-- *******************************************
-- For enviroment unique keys
create table VDAT_KEYS
(
KEY_TYPE char(20),
KEY_NUM  integer
);
