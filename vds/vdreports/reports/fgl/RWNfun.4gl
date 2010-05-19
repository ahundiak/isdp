DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION RWNquery ()

  LET w_reg =
" AND \"nfmadmin\".rway_dynamic.comp_code   = \"nfmadmin\".rway_comp_type.comp_code ",
"AND \"nfmadmin\".rway_dynamic.rway_type   = \"nfmadmin\".rway_comp_type.comp_type ",
"AND \"nfmadmin\".rway_dynamic.no_mto_flag = ' ' ",
"AND \"nfmadmin\".rway_dynamic.comp_code   = \"nfmadmin\".rway_comps.comp_code ",
"AND \"nfmadmin\".rway_dynamic.width_g     = \"nfmadmin\".rway_comps.width_g ",
"AND \"nfmadmin\".rway_dynamic.depth_g     = \"nfmadmin\".rway_comps.depth_g ",
"AND \"nfmadmin\".rway_dynamic.width_r     = \"nfmadmin\".rway_comps.width_r ",
"AND \"nfmadmin\".rway_dynamic.depth_r     = \"nfmadmin\".rway_comps.depth_r ",
"AND \"nfmadmin\".rway_dynamic.rway_type   = \"nfmadmin\".rway_comps.rway_type ",
"AND \"nfmadmin\".rway_dynamic.spec_name   = \"nfmadmin\".rway_spec.vendor_code ",
"AND \"nfmadmin\".rway_comps.vendor_no     = \"nfmadmin\".rway_spec.vendor_no ",
"AND (\"nfmadmin\".rway_codelist.list_num  = 1510 ",
"AND  \"nfmadmin\".rway_dynamic.chg_no     = \"nfmadmin\".rway_codelist.code_num) ",
"AND \"nfmadmin\".rway_spec.prj_no = ",default_prj_no

  LET f_reg =
"OUTER \"nfmadmin\".rway_codelist, ",
"\"nfmadmin\".rway_comp_type, ",
"OUTER \"nfmadmin\".rway_comps, ",
"\"nfmadmin\".rway_dynamic, ",
"\"nfmadmin\".rway_spec"

##########################  Create RWN query ###################################
  LET s_stmt =
"\"nfmadmin\".rway_comp_type.comp_descr, ",
"\"nfmadmin\".rway_comps.unit_wt, ",
"\"nfmadmin\".rway_spec.d_material, ",
"\"nfmadmin\".rway_dynamic.chg_no, ",
"\"nfmadmin\".rway_dynamic.comp_code, ",
"\"nfmadmin\".rway_dynamic.constr_stat, ",
"\"nfmadmin\".rway_dynamic.depth_g, ",
"\"nfmadmin\".rway_dynamic.depth_r, ",
"\"nfmadmin\".rway_dynamic.duct_length, ",
"\"nfmadmin\".rway_dynamic.weight_grp, ",
"\"nfmadmin\".rway_dynamic.width_g, ",
"\"nfmadmin\".rway_dynamic.width_r, ",
"\"nfmadmin\".rway_codelist.long_txt"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "\"nfmadmin\".rway_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   CALL RPTquery ( 0, 0)
END FUNCTION

FUNCTION RWNdescription ()
  DEFINE RWNdesc	CHAR(30),
         RWNcom_wgt	FLOAT,
	 tmp_desc	CHAR(20),
         tmp_size	CHAR(20),
         tmp_leng	FLOAT

  LET tmp_desc = p_rwn.comp_descr CLIPPED, ","

  IF  (p_rwn.width_g = p_rwn.width_r AND p_rwn.depth_g = p_rwn.depth_r)
  OR  (p_rwn.width_r = 0.0            AND p_rwn.depth_r = 0.0) THEN
    LET tmp_size = p_rwn.width_g USING "<<<&", "x",
                   p_rwn.depth_g USING "<<<&", "\""
  ELSE
    LET tmp_size = p_rwn.width_g USING "<<<&", "x",
                   p_rwn.depth_g USING "<<<&", ",",
                   p_rwn.width_r USING "<<<&", "x",
                   p_rwn.depth_r USING "<<<&", "\""
  END IF

  LET RWNdesc    = tmp_desc CLIPPED, tmp_size CLIPPED

  IF p_rwn.comp_descr = "Tray" THEN LET tmp_leng = p_rwn.duct_length / 12.0
  ELSE 				     LET tmp_leng = 1.0
  END IF

  LET RWNcom_wgt = (p_rwn.unit_wt * tmp_leng) USING "####&.&"
  IF RWNcom_wgt IS NULL OR RWNcom_wgt = "" OR RWNcom_wgt = " " THEN LET RWNcom_wgt = 0.0
  END IF

  RETURN RWNdesc, RWNcom_wgt
END FUNCTION
