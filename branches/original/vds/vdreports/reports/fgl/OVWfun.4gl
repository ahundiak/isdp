DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION OVWform_input()


  CLEAR SCREEN
#  IF p_vds.prj_units_set = 1 THEN 
	OPEN FORM frm0 FROM "OVWimp"
#  ELSE  
#        OPEN FORM frm0 FROM "OVWmet"
#  END IF
  DISPLAY FORM frm0
  INPUT p_frm0.*, p_vds.prj_number FROM sc_frm0.*

  SELECT UNIQUE "nfmadmin".vds_project.prj_number,
                "nfmadmin".vds_project.prj_name,
                "nfmadmin".vds_project.prj_location,
                "nfmadmin".vds_project.prj_units_set
  INTO  p_vds.*
  FROM  "nfmadmin".vds_project
  WHERE prj_number LIKE p_vds.prj_number


  CLEAR SCREEN
  OPEN FORM frm1 FROM "OVW1"
  DISPLAY FORM frm1
  INPUT p_frm1.* FROM sc_frm1.*

  CALL null_to_joker (p_frm1.bm_cat) RETURNING q_bm.assembly_cat
  CALL null_to_joker (p_frm1.bm_nam) RETURNING q_bm.assembly_nam
  CALL null_to_joker (p_frm1.bm_ver) RETURNING q_bm.assembly_ver
  CALL null_to_joker (p_frm1.bm_zn)  RETURNING q_bm.zone_number
  CALL null_to_joker (p_frm1.bm_as)  RETURNING q_bm.apprv_stat
  CALL null_to_joker (p_frm1.bm_cs)  RETURNING q_bm.constr_stat

  CALL null_to_joker (p_frm1.pl_cat) RETURNING q_pl.assembly_cat
  CALL null_to_joker (p_frm1.pl_nam) RETURNING q_pl.assembly_nam
  CALL null_to_joker (p_frm1.pl_ver) RETURNING q_pl.assembly_ver
  CALL null_to_joker (p_frm1.pl_zn)  RETURNING q_pl.zone_number
  CALL null_to_joker (p_frm1.pl_as)  RETURNING q_pl.apprv_stat
  CALL null_to_joker (p_frm1.pl_cs)  RETURNING q_pl.constr_stat


  CLEAR SCREEN
  OPEN FORM frm2 FROM "OVW2"
  DISPLAY FORM frm2
  INPUT p_frm2.* FROM sc_frm2.*

  CALL null_to_joker (p_frm2.hv_cat) RETURNING q_hv.assembly_cat
  CALL null_to_joker (p_frm2.hv_nam) RETURNING q_hv.assembly_nam
  CALL null_to_joker (p_frm2.hv_ver) RETURNING q_hv.assembly_ver
  CALL null_to_joker (p_frm2.hv_sn)  RETURNING q_hv.system_name
  CALL null_to_joker (p_frm2.hv_zn)  RETURNING q_hv.zone_number
  CALL null_to_joker (p_frm2.hv_as)  RETURNING q_hv.apprv_stat
  CALL null_to_joker (p_frm2.hv_cs)  RETURNING q_hv.constr_stat

  CALL null_to_joker (p_frm2.rw_cat) RETURNING q_rw.assembly_cat
  CALL null_to_joker (p_frm2.rw_nam) RETURNING q_rw.assembly_nam
  CALL null_to_joker (p_frm2.rw_ver) RETURNING q_rw.assembly_ver
  CALL null_to_joker (p_frm2.rw_sn)  RETURNING q_rw.system_name
  CALL null_to_joker (p_frm2.rw_zn)  RETURNING q_rw.zone_number
  CALL null_to_joker (p_frm2.rw_as)  RETURNING q_rw.apprv_stat
  CALL null_to_joker (p_frm2.rw_cs)  RETURNING q_rw.constr_stat


  CLEAR SCREEN
  OPEN FORM frm3 FROM "OVW3"
  DISPLAY FORM frm3
  INPUT p_frm3.* FROM sc_frm3.*

  CALL null_to_joker (p_frm3.pp_cat) RETURNING q_pp.assembly_cat
  CALL null_to_joker (p_frm3.pp_nam) RETURNING q_pp.assembly_nam
  CALL null_to_joker (p_frm3.pp_ver) RETURNING q_pp.assembly_ver
  CALL null_to_joker (p_frm3.pp_sn)  RETURNING q_pp.system_name
  CALL null_to_joker (p_frm3.pp_zn)  RETURNING q_pp.zone_number
  CALL null_to_joker (p_frm3.pp_as)  RETURNING q_pp.apprv_stat
  CALL null_to_joker (p_frm3.pp_cs)  RETURNING q_pp.constr_stat

  CALL null_to_joker (p_frm3.eq_cat) RETURNING q_eq.assembly_cat
  CALL null_to_joker (p_frm3.eq_nam) RETURNING q_eq.assembly_nam
  CALL null_to_joker (p_frm3.eq_ver) RETURNING q_eq.assembly_ver
  CALL null_to_joker (p_frm3.eq_zn)  RETURNING q_eq.zone_number
  CALL null_to_joker (p_frm3.eq_as)  RETURNING q_eq.apprv_stat
  CALL null_to_joker (p_frm3.eq_cs)  RETURNING q_eq.constr_stat

  CLEAR SCREEN

END FUNCTION 
