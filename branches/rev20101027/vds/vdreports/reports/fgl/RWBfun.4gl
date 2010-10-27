DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION RWBquery ()

  LET w_reg =
#" AND rway_dynamic.no_mto_flag = ' ' ",
#"AND (rway_codelist.list_num  = 422 ",
#"AND rway_dynamic.chg_no      = rway_codelist.code_num ",
#"AND rway_codelist.code_num   = rway_comp_type.comp_rptcat) ",
#"AND (vds_units.param_name    = 'thk' ",
#"AND vds_units.units_set      = ", p_vds.prj_units_set USING "<<", " ",
#"AND vds_convert.units_in     = rway_spec.units_set ",
#"AND vds_convert.units_out    = vds_units.units_code)"
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
"AND (\"nfmadmin\".rway_codelist.list_num   = 422 ",
"AND \"nfmadmin\".rway_codelist.code_num    = \"nfmadmin\".rway_comp_type.comp_rptcat) ",
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

##########################  Create RWB query ###################################
  LET s_stmt =
"\"nfmadmin\".rway_comp_type.comp_descr, ",
"\"nfmadmin\".rway_comp_type.comp_rptcat, ",
"\"nfmadmin\".rway_dynamic.comp_code, ",
"\"nfmadmin\".rway_dynamic.depth_g, ",
"\"nfmadmin\".rway_dynamic.depth_r, ",
"\"nfmadmin\".rway_dynamic.material, ",
"\"nfmadmin\".rway_dynamic.spec_name, ",
"SUM (\"nfmadmin\".rway_dynamic.duct_length), ",
"\"nfmadmin\".rway_dynamic.width_g, ",
"\"nfmadmin\".rway_dynamic.width_r, ",
"\"nfmadmin\".rway_dynamic.system_name, ",
"COUNT (*), ",
"\"nfmadmin\".rway_codelist.long_txt, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "\"nfmadmin\".rway_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET g_stmt =
"\"nfmadmin\".rway_dynamic.spec_name, ",
"\"nfmadmin\".rway_dynamic.comp_code, ",
"\"nfmadmin\".rway_dynamic.width_g, ",
"\"nfmadmin\".rway_dynamic.depth_g, ",
"\"nfmadmin\".rway_dynamic.width_r, ",
"\"nfmadmin\".rway_dynamic.depth_r, ",
"\"nfmadmin\".rway_comp_type.comp_descr, ",
"\"nfmadmin\".rway_comp_type.comp_rptcat, ",
"\"nfmadmin\".rway_dynamic.material, ",
"\"nfmadmin\".rway_dynamic.system_name, ",
"\"nfmadmin\".rway_codelist.long_txt, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   LET o_stmt =
"\"nfmadmin\".rway_dynamic.system_name, ",
"\"nfmadmin\".rway_comp_type.comp_rptcat, ",
"\"nfmadmin\".rway_dynamic.spec_name, ",
"\"nfmadmin\".rway_dynamic.comp_code, ",
"\"nfmadmin\".rway_dynamic.width_g DESC, ",
"\"nfmadmin\".rway_dynamic.depth_g DESC, ",
"\"nfmadmin\".rway_dynamic.width_r DESC, ",
"\"nfmadmin\".rway_dynamic.depth_r DESC"

   CALL RPTquery ( 1, 1)
END FUNCTION

FUNCTION RWBdescription ()
  DEFINE dummy    CHAR(240),
         RWBdesc1 CHAR(40),
         RWBdesc2 CHAR(37),
         RWBdesc3 CHAR(37),
         RWBdesc4 CHAR(37),
         RWBdesc5 CHAR(37),
         RWBdesc6 CHAR(37),
	 RWBsize  CHAR(18),
	 RWBquty  CHAR(13),
	 e_siz    CHAR(18),
	 e_len    CHAR(13),
         divider  INTEGER,
	 sign	  CHAR(5)

  IF p_vds.prj_units_set = 1 THEN LET sign = "\""
  ELSE				  LET sign = " MM"
  END IF 

  LET divider = 16

  LET dummy = p_rwb.comp_descr CLIPPED, ", ",
	      p_rwb.material CLIPPED, ", ",
	      p_rwb.spec_name CLIPPED

  CALL element_desc (dummy, 1+LENGTH(dummy))
       RETURNING RWBdesc1, RWBdesc2, RWBdesc3, RWBdesc4, RWBdesc5, RWBdesc6

  IF (p_rwb.width_g = p_rwb.width_r AND p_rwb.depth_g = p_rwb.depth_r)
  OR (p_rwb.width_r = 0.0           AND p_rwb.depth_r = 0.0) THEN
     LET RWBsize = p_rwb.width_g USING "<<<&", "x", 
                   p_rwb.depth_g USING "<<<&", sign CLIPPED
  ELSE
     LET RWBsize = p_rwb.width_g USING "<<<&", "x", 
                   p_rwb.depth_g USING "<<<&", ",",
                   p_rwb.width_r USING "<<<&", "x",
                   p_rwb.depth_r USING "<<<&", sign CLIPPED
  END IF

  IF p_rwb.comp_descr = "Tray" THEN
     IF p_vds.prj_units_set = 1 THEN
        LET divider = 4
        CALL element_length (p_rwb.duct_length, divider) RETURNING e_len
        LET RWBquty = e_len CLIPPED
     ELSE
        LET e_len = p_rwb.duct_length / 1000.0
        LET RWBquty = e_len USING "####&.&&"
     END IF
  ELSE
    LET RWBquty = p_rwb.item_num USING "<<<<&"
  END IF

  RETURN RWBdesc1, RWBdesc2, RWBdesc3, RWBdesc4, RWBdesc5, RWBdesc6, 
         RWBsize, RWBquty
END FUNCTION
