
-- $ID$
--**************************************************************************
-- I/VDS
--
-- File:	vds/vddb/vds /nfmwf.ddl
--
-- Description:
-- Insert a column cm_wf_enabled to specify whether a workflow in CM managed --
-- defailt value is NULL a cm enabled workflow should have value Y         --
-- User needs to update the cell with a RIS sql statement like             --
-- update nfmworkflow set cm_wf_enabled = 'Y' where n_workflowno = <>      --
-- History:
--
-- Rev  By   Chk  Date      Description                                    --
-- ---  ---  ---  --------  ---------------------------------------------- --
-- 0    ssr       NOV24 99  creation                                        -- 
--                                                                         --
-- Notes:                                                                  --
--  1. RIS does not like TABS in this file.                                --
--  2. Tables are generated by inputing this file to RIS as follows:       --
--     RIS> default schema schema.passwd;                                  --
--     RIS> read nfmwf.ddl;                                            --
--                                                                         --
--*************************************************************************--

alter table nfmworkflow
add cm_wf_enabled char(1);
