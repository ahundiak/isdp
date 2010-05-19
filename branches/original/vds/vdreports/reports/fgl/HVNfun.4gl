DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVNquery ()

   LET w_reg =
" AND \"nfmadmin\".hvac_dynamic.comp_code     = \"nfmadmin\".hvac_comps.comp_code ",
"AND \"nfmadmin\".hvac_dynamic.shape_code    = \"nfmadmin\".hvac_comps.shape_code ",
"AND \"nfmadmin\".hvac_dynamic.spec_name     = \"nfmadmin\".hvac_spec.hvac_class ",
"AND \"nfmadmin\".hvac_comps.tblno           = \"nfmadmin\".hvac_spec.class_no ",
"AND (a.list_num = 1510         AND \"nfmadmin\".hvac_dynamic.chg_no   = a.code_num) ",
"AND (b.list_num = 330          AND \"nfmadmin\".hvac_comps.shape_code = b.code_num) ",
"AND \"nfmadmin\".hvac_spec.prj_no = ",default_prj_no

   LET f_reg =
"OUTER (\"nfmadmin\".hvac_codelist a), ",
"OUTER (\"nfmadmin\".hvac_codelist b), ",
"\"nfmadmin\".hvac_comps, ",
"\"nfmadmin\".hvac_dynamic, ",
"\"nfmadmin\".hvac_spec"

##########################  Create HVN query ###################################
   LET s_stmt =
"a.long_txt, ",
"b.long_txt, ",
"\"nfmadmin\".hvac_comps.short_code, ",
"\"nfmadmin\".hvac_dynamic.material, ",
"\"nfmadmin\".hvac_dynamic.constr_stat, ",
"\"nfmadmin\".hvac_dynamic.spec_name, ",
"\"nfmadmin\".hvac_dynamic.chg_no, ",
"\"nfmadmin\".hvac_dynamic.comp_code, ",
"\"nfmadmin\".hvac_dynamic.comp_seqno, ",
"\"nfmadmin\".hvac_dynamic.depth_g, ",
"\"nfmadmin\".hvac_dynamic.depth_r, ",
"\"nfmadmin\".hvac_dynamic.duct_thk, ",
"\"nfmadmin\".hvac_dynamic.insul_thk, ",
"\"nfmadmin\".hvac_dynamic.shape_code, ",
"\"nfmadmin\".hvac_dynamic.surf_area, ",
"\"nfmadmin\".hvac_dynamic.weight_grp, ",
"\"nfmadmin\".hvac_dynamic.width_g, ",
"\"nfmadmin\".hvac_dynamic.width_r, ",
"\"nfmadmin\".hvac_spec.d_thk, ",
"\"nfmadmin\".hvac_spec.mtl_density, ",
"\"nfmadmin\".hvac_spec.weight_mult"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "hvac_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   CALL RPTquery ( 0, 0)
END FUNCTION

FUNCTION HVNconvert (f_calc)
  DEFINE f_calc RECORD comp_wt_star     CHAR(1),
                       insul_star       CHAR(1)
                END RECORD
  LET f_calc.comp_wt_star = ""
  LET f_calc.insul_star = ""

  IF p_hvn.duct_thk = 0.0 THEN
     LET p_hvn.duct_thk = p_hvn.d_thk
     LET f_calc.comp_wt_star = "*"
  END IF

  IF p_hvn.surf_area = 0.0 THEN LET f_calc.comp_wt_star = "*"
  END IF

  IF p_hvn.mtl_density = 0.0 OR p_hvn.mtl_density IS NULL THEN
     LET p_hvn.mtl_density = 489.5424
  END IF

  IF p_hvn.weight_mult < 1.0 THEN LET p_hvn.weight_mult = 1.0
  END IF

  RETURN f_calc.comp_wt_star, f_calc.comp_wt_star
END FUNCTION

FUNCTION HVNdescription ()
  DEFINE f_size RECORD  shape_code    LIKE      "nfmadmin".hvac_dynamic.shape_code,
                        shape_desc    LIKE      "nfmadmin".hvac_codelist.long_txt,
                        depth_g       LIKE      "nfmadmin".hvac_dynamic.depth_g,
                        depth_r       LIKE      "nfmadmin".hvac_dynamic.depth_r,
                        width_g       LIKE      "nfmadmin".hvac_dynamic.width_g,
                        width_r       LIKE      "nfmadmin".hvac_dynamic.width_r
                 END RECORD
  DEFINE HVNdesc	CHAR(40),
         HVNwet_wgt	FLOAT,
         HVNins_wgt	FLOAT,
         HVNtot_wgt	FLOAT,
	 tmp_desc	CHAR(40),
         tmp_size	CHAR(40)

  LET tmp_desc = p_hvn.short_code CLIPPED, ",", p_hvn.shape_desc CLIPPED, ","

  LET f_size.shape_code = p_hvn.shape_code
  LET f_size.shape_desc = p_hvn.shape_desc
  LET f_size.depth_g    = p_hvn.depth_g
  LET f_size.width_g    = p_hvn.width_g
  IF p_hvn.depth_r = 0.0 THEN LET f_size.depth_r = p_hvn.depth_g
  ELSE                        LET f_size.depth_r = p_hvn.depth_r END IF
  IF p_hvn.width_r = 0.0 THEN LET f_size.width_r = p_hvn.width_g
  ELSE                        LET f_size.width_r = p_hvn.width_r END IF

  CALL element_size (f_size.*) RETURNING tmp_size

  LET HVNdesc    = tmp_desc CLIPPED, tmp_size CLIPPED

  LET HVNwet_wgt = p_hvn.surf_area * p_hvn.duct_thk * p_hvn.mtl_density *
                       p_hvn.weight_mult / 1728.0
  IF HVNwet_wgt IS NULL OR HVNwet_wgt = "" OR HVNwet_wgt = " " THEN
     LET HVNwet_wgt = 0.0
  END IF

  LET HVNins_wgt = p_hvn.surf_area * p_hvn.insul_thk * 15.0 *
                       p_hvn.weight_mult / 1728.0
  IF HVNins_wgt IS NULL OR HVNins_wgt = "" OR HVNins_wgt = " " THEN
     LET HVNins_wgt = 0.0
  END IF

  LET HVNtot_wgt = HVNwet_wgt + HVNins_wgt
  IF HVNtot_wgt IS NULL OR HVNtot_wgt = "" OR HVNtot_wgt = " " THEN
     LET HVNtot_wgt = 0.0
  END IF

  RETURN HVNdesc, HVNwet_wgt, HVNins_wgt, HVNtot_wgt

END FUNCTION
