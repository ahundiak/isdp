--*************************************************************************--
--                                                                         --
-- Table definitions for VDS drawing support                               --
--                                                                         --
--     OPE_FMT_*      - Table layouts                                      --
--     OPE_SUM_*      - Summarization criteria                             --
--     OPE_SORT_*     - Sort criteria                                      --
--     OPE_ADS_*      - Attribute driven symbology                         --
--     OPE_EXPR_TABLE - Express Table                          		   --
--     OPE_DATA_TABLE - Express Data Table                          	   --
--                                                                         --
--*************************************************************************--

create table OPE_FMT_TABLE        -- table layout master --
(
 TABLE_NAME       char(12),
 TABLE_TYPE       char(12),
 TABLE_DIRECT     smallint,
 TIMESTAMP_0      char(24),
 USERID_0         char(12),
 TABLE_DESC       char(80),
 SUM_FILE         char(12),
 SORT_FILE        char(12),
 LC_UNIT          smallint
);

create table OPE_FMT_ALIGN         -- Coordinate alignment table --
(
 TABLE_NAME       char(12),
 GROUP_TYPE       smallint,
 ALIGN_CODE       smallint,
 ALIGN_VALUE      real
);

create table OPE_FMT_COL            -- data column declarations --
(
 TABLE_NAME       char(12),
 COL_SEQNO        smallint,
 COL_CHARS        smallint,
 COL_WDT          real,
 COL_HGT          real,
 COL_CHARWDT      real,
 COL_CHARSPC      real,
 COL_CHARHGT      real,
 COL_LINSPC       real,
 LTOP_STYLE       smallint,
 LTOP_WGT         smallint,
 LBOT_STYLE       smallint,
 LBOT_WGT         smallint,
 LLFT_STYLE       smallint,
 LLFT_WGT         smallint,
 LRGT_STYLE       smallint,
 LRGT_WGT         smallint,
 TL_BR            smallint,
 BL_TR            smallint
);

create table OPE_FMT_HDTR            -- header/trailer field declarations --
(
 TABLE_NAME       char(12),
 GROUP_TYPE       smallint,
 FIELDID          char(12),
 FLD_CHARS        smallint,
 FLD_CHARWDT      real,
 FLD_CHARSPC      real,
 FLD_CHARHGT      real,
 FLD_LINSPC       real,
 ALG_LCOL         smallint,
 ALG_RCOL         smallint,
 ALG_TOP          smallint,
 ALG_BOT          smallint,
 LTOP_STYLE       smallint,
 LTOP_WGT         smallint,
 LBOT_STYLE       smallint,
 LBOT_WGT         smallint,
 LLFT_STYLE       smallint,
 LLFT_WGT         smallint,
 LRGT_STYLE       smallint,
 LRGT_WGT         smallint,
 TL_BR            smallint,
 BL_TR            smallint
);

create table OPE_FMT_FILL         -- Data fill field (columns and headers) --
(
 TABLE_NAME       char(12),
 GROUP_TYPE       smallint,
 LIN_SEQNO        smallint,
 COL_SEQNO        smallint,
 FIELDID          char(12),
 FLD_TYPE         smallint,
 DATA_TYPE        smallint,
 DEC_PLACES       smallint,
 JUSTIF           smallint,
 ID_WEIGHT        smallint,
 ID_FONT          char(12),
 ID_NAME          char(80),
 ID_TEXT          char(240)
);


create table OPE_SUM_TABLE        -- summarization table master --
(
 TABLE_NAME       char(12),
 TIMESTAMP_0      char(24),
 USERID_0         char(12),
 TABLE_DESC       char(80)
);

create table OPE_SUM_QTY           -- summarization table quantities --
(
 TABLE_NAME       char(12),
 TABLE_CAT        char(12),
 TABLE_SUBCAT     char(12),
 QTY_FLAG         smallint,
 QTY_EXP          char(80)
);

create table OPE_SUM_MATCH         -- summarization table attributes --
(
 TABLE_NAME       char(12),
 TABLE_CAT        char(12),
 TABLE_SUBCAT     char(12),
 TABLE_INDEX      smallint,
 SUM_ATTR         char(24),
 SUM_REL          smallint,
 SUM_VAL          smallint,
 SUM_EXP          char(80)
);

create table OPE_SORT_TABLE        -- sorting table master --
(
 TABLE_NAME       char(12),
 TIMESTAMP_0      char(24),
 USERID_0         char(12),
 TABLE_DESC       char(80)
);

create table OPE_SORT_KEYS         -- sorting table keys --
(
 TABLE_NAME       char(12),
 SORT_INDEX       smallint,
 SORT_ORDER       smallint,
 SORT_TYPE        smallint,
 SORT_ATTR        char(24)
);

create table OPE_ADS_TABLE        -- ads table master --
(
 TABLE_NAME       char(12),
 TIMESTAMP_0      char(24),
 USERID_0         char(12),
 TABLE_DESC       char(80),
 LC_UNIT          smallint
);

create table OPE_ADS_REC           -- ads table records --
(
 TABLE_NAME       char(12),
 ADS_SYMBOL       char(12),
 ADS_ATTNAM       char(80),
 ADS_DATTYP       smallint,
 ADS_REL          smallint,
 ADS_DATTVAL      real,
 ADS_CATTVAL      char(80),
 ADS_SIDE         smallint,
 ADS_OFFSET       real,
 ADS_CHHGT        real,
 ADS_CHWDT        real,
 ADS_CHSPC        real,
 ADS_CHWGT        smallint,
 ADS_FONT         char(12)
);

create table OPE_EXPR_TABLE             -- expression table master --
(
        EXPR_TYPE                       char(12),
        TABLE_NAME                      char(12),
        TIMESTAMP_0                     char(24),
        USERID_0                        char(12),
        EXPR_DESC                       char(80),
        DATA_TYPE                       smallint
);
 
create table OPE_DATA_TABLE             -- Text buffer table --
(
        TABLE_NAME                      char(12),
        DATA_GROUP                      char(4),
        DATA_SEQN                       smallint,
        DATA_INFO                       char(240)
);

