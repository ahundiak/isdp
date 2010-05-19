DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION RWWquery ()

  LET w_reg =
" AND (\"nfmadmin\".rway_dynamic.comp_code   = \"nfmadmin\".rway_comp_type.comp_code ",
"AND \"nfmadmin\".rway_dynamic.rway_type    = \"nfmadmin\".rway_comp_type.comp_type) ",
"AND (\"nfmadmin\".rway_dynamic.no_mto_flag = ' ') ",
"AND (\"nfmadmin\".rway_dynamic.comp_code   = \"nfmadmin\".rway_comps.comp_code ",
"AND \"nfmadmin\".rway_dynamic.width_g      = \"nfmadmin\".rway_comps.width_g ",
"AND \"nfmadmin\".rway_dynamic.depth_g      = \"nfmadmin\".rway_comps.depth_g ",
"AND \"nfmadmin\".rway_dynamic.width_r      = \"nfmadmin\".rway_comps.width_r ",
"AND \"nfmadmin\".rway_dynamic.depth_r      = \"nfmadmin\".rway_comps.depth_r ",
"AND \"nfmadmin\".rway_dynamic.rway_type    = \"nfmadmin\".rway_comps.rway_type) ",
"AND (\"nfmadmin\".rway_dynamic.spec_name   = \"nfmadmin\".rway_spec.vendor_code ",
"AND \"nfmadmin\".rway_comps.vendor_no      = \"nfmadmin\".rway_spec.vendor_no) ",
"AND (\"nfmadmin\".rway_codelist.list_num   = 1510 ",
"AND \"nfmadmin\".rway_dynamic.chg_no       = \"nfmadmin\".rway_codelist.code_num) ",
"AND (\"nfmadmin\".vds_units.param_name     = 'thk' ",
"AND \"nfmadmin\".vds_units.units_set       = ", p_vds.prj_units_set USING "<<", " ",
"AND \"nfmadmin\".vds_convert.units_in      = \"nfmadmin\".rway_spec.units_set ",
"AND \"nfmadmin\".vds_convert.units_out     = \"nfmadmin\".vds_units.units_code) ",
"AND \"nfmadmin\".rway_spec.prj_no = ",default_prj_no

  LET f_reg =
"\"nfmadmin\".rway_codelist, ",
"\"nfmadmin\".rway_comp_type, ",
"OUTER \"nfmadmin\".rway_comps, ",
"\"nfmadmin\".rway_dynamic, ",
"\"nfmadmin\".rway_spec, ",
"OUTER \"nfmadmin\".vds_convert, ",
"\"nfmadmin\".vds_units"

##########################  Create RWW query ###################################
  LET s_stmt =
"\"nfmadmin\".rway_comp_type.comp_descr, ",
"\"nfmadmin\".rway_comps.short_code, ",
"\"nfmadmin\".rway_comps.unit_wt, ",
"\"nfmadmin\".rway_dynamic.addl_weight, ",
"\"nfmadmin\".rway_dynamic.chg_no, ",
"\"nfmadmin\".rway_dynamic.comp_code, ",
"\"nfmadmin\".rway_dynamic.comp_seqno, ",
"\"nfmadmin\".rway_dynamic.depth_g, ",
"\"nfmadmin\".rway_dynamic.depth_r, ",
"\"nfmadmin\".rway_dynamic.loc_x, ",
"\"nfmadmin\".rway_dynamic.loc_y, ",
"\"nfmadmin\".rway_dynamic.loc_z, ",
"\"nfmadmin\".rway_dynamic.duct_length, ",
"\"nfmadmin\".rway_dynamic.weight_grp, ",
"\"nfmadmin\".rway_dynamic.width_g, ",
"\"nfmadmin\".rway_dynamic.width_r, ",
"\"nfmadmin\".rway_codelist.long_txt, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "\"nfmadmin\".rway_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".rway_dynamic.chg_no, ",
"\"nfmadmin\".rway_dynamic.weight_grp, ",
"\"nfmadmin\".rway_dynamic.comp_code, ",
"\"nfmadmin\".rway_dynamic.width_g, ",
"\"nfmadmin\".rway_dynamic.width_r"

   CALL RPTquery ( 0, 1)
END FUNCTION

FUNCTION RWWdescription ()
  DEFINE RWWdesc	CHAR(40),
         RWWcom_wgt	FLOAT,
         RWWadd_wgt	FLOAT,
         RWWvcg		FLOAT,
         RWWlcg		FLOAT,
         RWWtcg		FLOAT,
         RWWvmom	FLOAT,
         RWWlmom	FLOAT,
         RWWtmom	FLOAT,
	 tmp_desc	CHAR(20),
         tmp_size	CHAR(20),
         tmp_leng	FLOAT,
         conv_len       FLOAT,
	 sign		CHAR(5)

  IF p_vds.prj_units_set = 1 THEN
     LET conv_len = 12.0
     LET sign     = "\""
  ELSE
     LET conv_len = 1000.0
     LET sign     = ""
  END IF

  LET tmp_desc = p_rww.comp_descr CLIPPED, ","

  IF (p_rww.width_g = p_rww.width_r AND p_rww.depth_g = p_rww.depth_r)
  OR (p_rww.width_r = 0.0            AND p_rww.depth_r = 0.0) THEN
     LET tmp_size = p_rww.width_g USING "<<<&", "x",
                    p_rww.depth_g USING "<<<&", sign CLIPPED
  ELSE
     LET tmp_size = p_rww.width_g USING "<<<&", "x",
                    p_rww.depth_g USING "<<<&", ",",
                    p_rww.width_r USING "<<<&", "x",
                    p_rww.depth_r USING "<<<&", sign CLIPPED
  END IF

  LET RWWdesc    = tmp_desc CLIPPED, tmp_size CLIPPED

  IF p_rww.comp_descr = "Tray" THEN LET tmp_leng = p_rww.duct_length / conv_len
  ELSE                              LET tmp_leng = 1.0
  END IF

  LET RWWcom_wgt = p_rww.unit_wt * tmp_leng USING "####&.&"
  IF RWWcom_wgt IS NULL OR RWWcom_wgt = "" OR RWWcom_wgt = " " THEN
     LET RWWcom_wgt = 0.0
  END IF

  LET RWWadd_wgt = p_rww.addl_weight USING "####&.&"
  IF RWWadd_wgt IS NULL OR RWWadd_wgt = "" OR RWWadd_wgt = " " THEN
     LET RWWadd_wgt = 0.0
  END IF

  LET RWWvcg     = p_rww.loc_z / conv_len - def_vcog
  IF RWWvcg IS NULL OR RWWvcg = "" OR RWWvcg = " " THEN
     LET RWWvcg = 0.0
  END IF

  LET RWWlcg     = p_rww.loc_x / conv_len - def_lcog
  IF RWWlcg IS NULL OR RWWlcg = "" OR RWWlcg = " " THEN
     LET RWWlcg = 0.0
  END IF

  LET RWWtcg     = p_rww.loc_y / conv_len - def_tcog
  IF RWWtcg IS NULL OR RWWtcg = "" OR RWWtcg = " " THEN
     LET RWWtcg = 0.0
  END IF

  LET RWWvmom    = RWWvcg * (RWWcom_wgt + RWWadd_wgt)
  IF RWWvmom IS NULL OR RWWvmom = "" OR RWWvmom = " " THEN
     LET RWWvmom = 0.0
  END IF

  LET RWWlmom    = RWWlcg * (RWWcom_wgt + RWWadd_wgt)
  IF RWWlmom IS NULL OR RWWlmom = "" OR RWWlmom = " " THEN
     LET RWWlmom = 0.0
  END IF

  LET RWWtmom    = RWWtcg * (RWWcom_wgt + RWWadd_wgt)
  IF RWWtmom IS NULL OR RWWtmom = "" OR RWWtmom = " " THEN
     LET RWWtmom = 0.0
  END IF

  RETURN RWWdesc, RWWcom_wgt, RWWadd_wgt,
         RWWvcg, RWWlcg, RWWtcg,
         RWWvmom, RWWlmom, RWWtmom
END FUNCTION
