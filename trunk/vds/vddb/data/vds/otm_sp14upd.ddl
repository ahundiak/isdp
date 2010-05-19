--**************************************************
--otm update for sp14, HvacTree additional tables
--
-- tm_hvac_imp_matl  for implied materials lookup
--
-- tm_hvac_im_ps     for implied materials product structure
--
--***************************************************

create table TM_HVAC_IMP_MATL
(
     EQP_FAMILY     char(24),
     EQP_PARTNO     char(40),
     COMP_CODE      char(8),
     CAGE_MINO      char(40),
     FAST_ASSY      char(40)
);

create table TM_HVAC_IM_PS
(
     FAST_ASSY      char(40),
     UNIT_MEAS      char(3),
     ASSY_QTY       real,
     ASSY_PART      char(40)
);
