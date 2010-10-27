DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVBquery ()

   LET w_reg =
" AND \"nfmadmin\".hvac_dynamic.comp_code     = \"nfmadmin\".hvac_comp_type.comp_code ",
"AND \"nfmadmin\".hvac_dynamic.spec_name     = \"nfmadmin\".hvac_spec.hvac_class ",
"AND \"nfmadmin\".hvac_dynamic.no_mto_flag   = ' ' ",
"AND (cad.list_num = 421        AND cad.code_num = \"nfmadmin\".hvac_comp_type.comp_cat) ",
"AND (shd.list_num = 330        AND shd.code_num = \"nfmadmin\".hvac_dynamic.shape_code) ",
"AND (\"nfmadmin\".vds_units.param_name      = 'thk' ",
"AND \"nfmadmin\".vds_units.units_set        = ", p_vds.prj_units_set USING "<<", " ",
"AND \"nfmadmin\".vds_convert.units_in       = \"nfmadmin\".hvac_spec.units_set ",
"AND \"nfmadmin\".vds_convert.units_out      = \"nfmadmin\".vds_units.units_code) ",
"AND \"nfmadmin\".hvac_spec.prj_no = ",default_prj_no

   LET f_reg =
"OUTER (\"nfmadmin\".hvac_codelist cad), ",
"OUTER (\"nfmadmin\".hvac_codelist shd), ",
"\"nfmadmin\".hvac_comp_type, ",
"\"nfmadmin\".hvac_dynamic, ",
"\"nfmadmin\".hvac_spec, ",
"OUTER (\"nfmadmin\".vds_convert), ",
"\"nfmadmin\".vds_units"

##########################  Create HVB query ###################################
   LET s_stmt =
"\"nfmadmin\".hvac_comp_type.comp_descr, ",
"\"nfmadmin\".hvac_comp_type.comp_rptcat, ",
"\"nfmadmin\".hvac_dynamic.comp_code, ",
"\"nfmadmin\".hvac_dynamic.depth_g, ",
"\"nfmadmin\".hvac_dynamic.depth_r, ",
"SUM ( \"nfmadmin\".hvac_dynamic.duct_length), ",
"\"nfmadmin\".hvac_dynamic.material, ",
"\"nfmadmin\".hvac_dynamic.duct_thk, ",
"\"nfmadmin\".hvac_dynamic.width_g, ",
"\"nfmadmin\".hvac_dynamic.width_r, ",
"\"nfmadmin\".hvac_dynamic.shape_code, ",
"\"nfmadmin\".hvac_dynamic.system_name, ",
"cad.long_txt, ",
"shd.long_txt, ",
"COUNT (*), ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "hvac_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET g_stmt =
"\"nfmadmin\".hvac_dynamic.comp_code, ",
"\"nfmadmin\".hvac_dynamic.width_g, ",
"\"nfmadmin\".hvac_dynamic.depth_g, ",
"\"nfmadmin\".hvac_dynamic.width_r, ",
"\"nfmadmin\".hvac_dynamic.depth_r, ",
"\"nfmadmin\".hvac_dynamic.shape_code, ",
"\"nfmadmin\".hvac_comp_type.comp_descr, ",
"\"nfmadmin\".hvac_comp_type.comp_rptcat, ",
"\"nfmadmin\".hvac_dynamic.material, ",
"\"nfmadmin\".hvac_dynamic.duct_thk, ",
"\"nfmadmin\".hvac_dynamic.system_name, ",
"cad.long_txt, ",
"shd.long_txt, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   LET o_stmt =
"\"nfmadmin\".hvac_dynamic.system_name, ",
"\"nfmadmin\".hvac_comp_type.comp_rptcat, ",
"\"nfmadmin\".hvac_dynamic.comp_code, ",
"\"nfmadmin\".hvac_dynamic.width_g DESC, ",
"\"nfmadmin\".hvac_dynamic.depth_g DESC, ",
"\"nfmadmin\".hvac_dynamic.width_r DESC, ",
"\"nfmadmin\".hvac_dynamic.depth_r DESC, ",
"\"nfmadmin\".hvac_dynamic.shape_code"

   CALL RPTquery ( 1, 1)
END FUNCTION
                                       
FUNCTION HVBdescription ()
  DEFINE f_size RECORD  shape_code    LIKE      "nfmadmin".hvac_dynamic.shape_code,
                        shape_desc    LIKE      "nfmadmin".hvac_codelist.long_txt,
                        depth_g       LIKE      "nfmadmin".hvac_dynamic.depth_g,
                        depth_r       LIKE      "nfmadmin".hvac_dynamic.depth_r,
                        width_g       LIKE      "nfmadmin".hvac_dynamic.width_g,
                        width_r       LIKE      "nfmadmin".hvac_dynamic.width_r
                 END RECORD
  DEFINE dummy    CHAR(240),
         HVBdesc1 CHAR(40),
         HVBdesc2 CHAR(37),
         HVBdesc3 CHAR(37),
         HVBdesc4 CHAR(37),
         HVBdesc5 CHAR(37),
         HVBdesc6 CHAR(37),
	 HVBsize  CHAR(30),
	 HVBquty  CHAR(13),
	 e_thk    CHAR(10),
	 e_siz    CHAR(18),
	 e_len    CHAR(13),
         divider  INTEGER

  IF p_vds.prj_units_set = 1 THEN
     LET divider = 16
     CALL fraction_format(p_hvb.duct_thk, divider) RETURNING e_thk

     LET dummy = p_hvb.comp_descr CLIPPED, ", ",
	         p_hvb.material CLIPPED, ", ",
	         e_thk CLIPPED, "\" thk, ",
	         p_hvb.shape_desc CLIPPED
  ELSE
     LET dummy = p_hvb.comp_descr CLIPPED, ", ",
	         p_hvb.material CLIPPED, ",",
	         p_hvb.duct_thk USING "-&", " MM, ",
	         p_hvb.shape_desc CLIPPED
  END IF

  CALL element_desc (dummy, 1+length(dummy))
       RETURNING HVBdesc1, HVBdesc2, HVBdesc3, HVBdesc4, HVBdesc5, HVBdesc6

  LET f_size.shape_code = p_hvb.shape_code
  LET f_size.shape_desc = p_hvb.shape_desc
  LET f_size.depth_g    = p_hvb.depth_g
  LET f_size.width_g    = p_hvb.width_g
  IF p_hvb.depth_r = 0.0 THEN LET f_size.depth_r = p_hvb.depth_g
  ELSE                        LET f_size.depth_r = p_hvb.depth_r END IF
  IF p_hvb.width_r = 0.0 THEN LET f_size.width_r = p_hvb.width_g
  ELSE                        LET f_size.width_r = p_hvb.width_r END IF

  CALL element_size (f_size.*) RETURNING HVBsize

  IF p_hvb.comp_descr = "Duct" THEN
     IF p_vds.prj_units_set = 1 THEN
        LET divider = 4
        CALL element_length (p_hvb.duct_length, divider) RETURNING e_len
     ELSE
        LET e_len = p_hvb.duct_length / 1000.0 USING "<<<&.&&&"
     END IF
     LET HVBquty = e_len CLIPPED
  ELSE
     LET HVBquty = p_hvb.item_num USING "<<<<&"
  END IF

  RETURN HVBdesc1, HVBdesc2, HVBdesc3, HVBdesc4, HVBdesc5, HVBdesc6, 
         HVBsize, HVBquty
END FUNCTION
