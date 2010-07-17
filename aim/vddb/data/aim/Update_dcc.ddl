
-- $Id: Update_dcc.ddl,v 1.1 2002/05/06 19:40:17 ahundiak Exp $
--**************************************************************************
-- I/VDS
--
-- File:	aim/vddb/data/aim/Update_dcc.ddl
--
-- Description:
--    Table definitions for CM related VDS applications.                              --
--                                                                         --
-- History:
--
-- Rev  By   Chk  Date      Description                                    --
-- ---  ---  ---  --------  ---------------------------------------------- --
-- 1    SSR       NOV24 99  changed data type of dcc_time
-- 0    ssr       AUG17 99  creation                                        -- 
--                                                                         --
-- Notes:                                                                  --
--  1. RIS does not like TABS in this file.                                --
--  2. Tables are generated by inputing this file to RIS as follows:       --
--     RIS> default schema schema.passwd;                                  --
--     RIS> read Update_dcc.ddl;                                            --
--                                                                         --
--*************************************************************************--

drop table DCC_HISTORY;                 -- Drop the old table --
                                       -- It had dcc_time as char type--

create table DCC_HISTORY               -- table for history --
(
 DCC_TIME	timestamp,
 PDU_CATALOG    char(30),
 PDU_PART       char(30),
 PDU_REVISION	char(10),
 NFM_USR        char(9),
 WRK_USR        char(9),
 WRK_NODE       char(30)
);
