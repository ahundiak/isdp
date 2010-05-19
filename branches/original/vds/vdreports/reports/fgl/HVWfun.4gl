DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVWquery ()

   LET w_reg =
" AND \"nfmadmin\".hvac_dynamic.comp_code     = \"nfmadmin\".hvac_comps.comp_code ",
"AND \"nfmadmin\".hvac_dynamic.shape_code    = \"nfmadmin\".hvac_comps.shape_code ",
"AND \"nfmadmin\".hvac_dynamic.spec_name     = \"nfmadmin\".hvac_spec.hvac_class ",
"AND \"nfmadmin\".hvac_comps.tblno           = \"nfmadmin\".hvac_spec.class_no ",
"AND (a.list_num = 1510         AND \"nfmadmin\".hvac_dynamic.chg_no   = a.code_num) ",
"AND (b.list_num = 330          AND \"nfmadmin\".hvac_comps.shape_code = b.code_num) ",
"AND (\"nfmadmin\".vds_units.param_name      = 'thk' ",
"AND \"nfmadmin\".vds_units.units_set        = ", p_vds.prj_units_set USING "<<", " ",
"AND \"nfmadmin\".vds_convert.units_in       = \"nfmadmin\".hvac_spec.units_set ",
"AND \"nfmadmin\".vds_convert.units_out      = \"nfmadmin\".vds_units.units_code) ",
"AND \"nfmadmin\".hvac_spec.prj_no = ",default_prj_no

   LET f_reg =
"OUTER (\"nfmadmin\".hvac_codelist a), ",
"OUTER (\"nfmadmin\".hvac_codelist b), ",
"\"nfmadmin\".hvac_comps, ",
"\"nfmadmin\".hvac_dynamic, ",
"\"nfmadmin\".hvac_spec, ",
"OUTER \"nfmadmin\".vds_convert, ",
"\"nfmadmin\".vds_units"

##########################  Create HVW query ###################################
   LET s_stmt =
"a.long_txt, ",
"b.long_txt, ",
"\"nfmadmin\".hvac_comps.short_code, ",
"\"nfmadmin\".hvac_dynamic.chg_no, ",
"\"nfmadmin\".hvac_dynamic.comp_code, ",
"\"nfmadmin\".hvac_dynamic.comp_seqno, ",
"\"nfmadmin\".hvac_dynamic.depth_g, ",
"\"nfmadmin\".hvac_dynamic.depth_r, ",
"\"nfmadmin\".hvac_dynamic.duct_thk, ",
"\"nfmadmin\".hvac_dynamic.insul_thk, ",
"\"nfmadmin\".hvac_dynamic.loc_x, ",
"\"nfmadmin\".hvac_dynamic.loc_y, ",
"\"nfmadmin\".hvac_dynamic.loc_z, ",
"\"nfmadmin\".hvac_dynamic.shape_code, ",
"\"nfmadmin\".hvac_dynamic.surf_area, ",
"\"nfmadmin\".hvac_dynamic.weight_grp, ",
"\"nfmadmin\".hvac_dynamic.width_g, ",
"\"nfmadmin\".hvac_dynamic.width_r, ",
"\"nfmadmin\".hvac_spec.d_thk, ",
"\"nfmadmin\".hvac_spec.mtl_density, ",
"\"nfmadmin\".hvac_spec.weight_mult, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "hvac_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".hvac_dynamic.chg_no, ",
"\"nfmadmin\".hvac_dynamic.weight_grp, ",
"\"nfmadmin\".hvac_dynamic.comp_code, ",
"\"nfmadmin\".hvac_dynamic.width_g, ",
"\"nfmadmin\".hvac_dynamic.width_r"

   CALL RPTquery ( 0, 1)
END FUNCTION

FUNCTION HVWstar (f_calc)
  DEFINE f_calc RECORD comp_wt_star     CHAR(1),
                       insul_star       CHAR(1)
                END RECORD
           LET f_calc.comp_wt_star = ""
           LET f_calc.insul_star = ""

           IF p_hvw.duct_thk = 0.0 THEN
              LET p_hvw.duct_thk = p_hvw.d_thk
              LET f_calc.comp_wt_star = "*"
           END IF

           IF p_hvw.surf_area = 0.0 THEN LET f_calc.comp_wt_star = "*"
           END IF

           IF p_hvw.mtl_density = 0.0 OR p_hvw.mtl_density IS NULL THEN
           LET p_hvw.mtl_density = 489.5424
           END IF

           IF p_hvw.weight_mult < 1.0 THEN LET p_hvw.weight_mult = 1.0
           END IF
END FUNCTION

FUNCTION HVWdescription ()
  DEFINE f_size RECORD  shape_code    LIKE      "nfmadmin".hvac_dynamic.shape_code,
                        shape_desc    LIKE      "nfmadmin".hvac_codelist.long_txt,
                        depth_g       LIKE      "nfmadmin".hvac_dynamic.depth_g,
                        depth_r       LIKE      "nfmadmin".hvac_dynamic.depth_r,
                        width_g       LIKE      "nfmadmin".hvac_dynamic.width_g,
                        width_r       LIKE      "nfmadmin".hvac_dynamic.width_r
                 END RECORD
  DEFINE HVWdesc	CHAR(40),
         HVWwet_wgt	FLOAT,
         HVWins_wgt	FLOAT,
         HVWtot_wgt	FLOAT,
         HVWvcg		FLOAT,
         HVWlcg		FLOAT,
         HVWtcg		FLOAT,
         HVWvmom	FLOAT,
         HVWlmom	FLOAT,
         HVWtmom	FLOAT,
	 tmp_desc	CHAR(40),
         tmp_size	CHAR(40),
	 conv_len	FLOAT,
	 conv_vol	FLOAT,
	 conv_wgt	FLOAT

  IF p_vds.prj_units_set = 1 THEN
     LET conv_len = 12.0
     LET conv_vol = conv_len * conv_len * conv_len
     LET conv_wgt = 1.0 / conv_vol
  ELSE
     LET conv_len = 1000.0
     LET conv_vol = conv_len * conv_len * conv_len
     LET conv_wgt = 0.454 / 25.4 / 25.4 / 25.4 / 12.0 / 12.0 / 12.0
  END IF

  LET tmp_desc = p_hvw.short_code clipped, ",", p_hvw.shape_desc clipped, ","

  LET f_size.shape_code = p_hvw.shape_code
  LET f_size.shape_desc = p_hvw.shape_desc
  LET f_size.depth_g    = p_hvw.depth_g
  LET f_size.width_g    = p_hvw.width_g
  IF p_hvw.depth_r = 0.0 THEN LET f_size.depth_r = p_hvw.depth_g
  ELSE                        LET f_size.depth_r = p_hvw.depth_r END IF
  IF p_hvw.width_r = 0.0 THEN LET f_size.width_r = p_hvw.width_g
  ELSE                        LET f_size.width_r = p_hvw.width_r END IF

  CALL element_size (f_size.*) RETURNING tmp_size

  LET HVWdesc    = tmp_desc clipped, tmp_size clipped

  LET HVWwet_wgt = p_hvw.surf_area * p_hvw.duct_thk * p_hvw.mtl_density *
                   p_hvw.weight_mult / conv_vol
  IF HVWwet_wgt IS NULL OR HVWwet_wgt = "" OR HVWwet_wgt = " " THEN
     LET HVWwet_wgt = 0.0
  END IF

  LET HVWins_wgt = p_hvw.surf_area * p_hvw.insul_thk * 15.0 *
                   p_hvw.weight_mult * conv_wgt
  IF HVWins_wgt IS NULL OR HVWins_wgt = "" OR HVWins_wgt = " " THEN
     LET HVWins_wgt = 0.0
  END IF

  LET HVWtot_wgt = HVWwet_wgt + HVWins_wgt
  IF HVWtot_wgt IS NULL OR HVWtot_wgt = "" OR HVWtot_wgt = " " THEN
     LET HVWtot_wgt = 0.0
  END IF

  LET HVWvcg = p_hvw.loc_z / conv_len - def_vcog
  IF HVWvcg IS NULL OR HVWvcg = "" OR HVWvcg = " " THEN LET HVWvcg = 0.0
  END IF

  LET HVWlcg = p_hvw.loc_x / conv_len - def_lcog
  IF HVWlcg IS NULL OR HVWlcg = "" OR HVWlcg = " " THEN LET HVWlcg = 0.0
  END IF

  LET HVWtcg = p_hvw.loc_y / conv_len - def_tcog
  IF HVWtcg IS NULL OR HVWtcg = "" OR HVWtcg = " " THEN LET HVWtcg = 0.0
  END IF

  LET HVWvmom = HVWvcg * HVWtot_wgt
  IF HVWvmom IS NULL OR HVWvmom = "" OR HVWvmom = " " THEN LET HVWvmom = 0.0
  END IF

  LET HVWlmom = HVWlcg * HVWtot_wgt
  IF HVWlmom IS NULL OR HVWlmom = "" OR HVWlmom = " " THEN LET HVWlmom = 0.0
  END IF

  LET HVWtmom = HVWtcg * HVWtot_wgt
  IF HVWtmom IS NULL OR HVWtmom = "" OR HVWtmom = " " THEN LET HVWtmom = 0.0
  END IF

  RETURN HVWdesc, HVWwet_wgt, HVWins_wgt, HVWtot_wgt,
         HVWvcg, HVWlcg, HVWtcg,
         HVWvmom, HVWlmom, HVWtmom
END FUNCTION
