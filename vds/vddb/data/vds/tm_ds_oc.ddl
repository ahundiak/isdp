--**************************************************
-- Outfit Tree Manager tabe for computing COPICS info
-- PCT of MINO for Distributive System components
--
-- tm_ds_oc   Distributive System OPS to COPICS info
--
--***************************************************

create table TM_DS_OC
(
     CAGE_NUM       char(32),
     COP_SIZE       char(19),    -- Stock Length or LF
     COP_MAX_X      char(19),    -- Optional Max X size
     COP_MAX_Y      char(19)     -- optional Max Y size
);

