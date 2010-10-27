DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PLWquery ()

   LET w_reg =
" AND (\"nfmadmin\".vds_units.param_name           = 'density' ",
"AND \"nfmadmin\".vds_units.units_set             = ", p_vds.prj_units_set USING "<<", ") ",
"AND (\"nfmadmin\".struct_codelist.list_num       = 1510 ",
"AND \"nfmadmin\".struct_codelist.code_num        = \"nfmadmin\".struct_pl_dynamic.chg_no) ",
"AND (\"nfmadmin\".struct_grade.material          = \"nfmadmin\".struct_pl_dynamic.material ",
"AND \"nfmadmin\".struct_grade.grade              = \"nfmadmin\".struct_pl_dynamic.grade) ",
"AND (\"nfmadmin\".vds_convert.units_in           = \"nfmadmin\".struct_grade.density_units ",
"AND \"nfmadmin\".vds_convert.units_out           = \"nfmadmin\".vds_units.units_code)"

   LET f_reg =
"OUTER (\"nfmadmin\".struct_codelist), ",
"\"nfmadmin\".struct_grade, ",
"\"nfmadmin\".struct_pl_dynamic, ",
"OUTER (\"nfmadmin\".vds_convert), ",
"\"nfmadmin\".vds_units"

##########################  Create PLW query ###################################
   LET s_stmt =
"\"nfmadmin\".struct_pl_dynamic.chg_no, ",
"\"nfmadmin\".struct_pl_dynamic.comp_seqno, ",
"\"nfmadmin\".struct_pl_dynamic.weight_grp, ",
"\"nfmadmin\".struct_pl_dynamic.plate_thk, ",
"\"nfmadmin\".struct_pl_dynamic.surface_area, ",
"\"nfmadmin\".struct_pl_dynamic.volume, ",
"\"nfmadmin\".struct_pl_dynamic.cog_x, ",
"\"nfmadmin\".struct_pl_dynamic.cog_y, ",
"\"nfmadmin\".struct_pl_dynamic.cog_z, ",
"\"nfmadmin\".struct_pl_dynamic.material, ",
"\"nfmadmin\".struct_pl_dynamic.grade, ",
"\"nfmadmin\".struct_codelist.long_txt, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "struct_pl_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".struct_pl_dynamic.chg_no, ",
"\"nfmadmin\".struct_pl_dynamic.weight_grp, ",
"\"nfmadmin\".struct_pl_dynamic.plate_thk, ",
"\"nfmadmin\".struct_pl_dynamic.material"

   CALL RPTquery ( 0, 1)
END FUNCTION

FUNCTION PLWconvert ()
  # Convert length values
  CALL length_unit_convert (p_plw.pl_thk, 1, p_vds.prj_units_set)
       RETURNING p_plw.pl_thk
  CALL length_unit_convert (p_plw.pl_srf, 2, p_vds.prj_units_set)
       RETURNING p_plw.pl_srf
  CALL length_unit_convert (p_plw.pl_vol, 3, p_vds.prj_units_set)
       RETURNING p_plw.pl_vol
  CALL length_unit_convert (p_plw.cog_x, 1, p_vds.prj_units_set)
       RETURNING p_plw.cog_x
  CALL length_unit_convert (p_plw.cog_y, 1, p_vds.prj_units_set)
       RETURNING p_plw.cog_y
  CALL length_unit_convert (p_plw.cog_z, 1, p_vds.prj_units_set)
       RETURNING p_plw.cog_z

  # Convert density value
  CALL unit_convert ( p_plw.cnvr_fctr,
                      p_plw.cnvr_offset,
                      p_plw.rndoff_fctr,
                      p_plw.density) RETURNING p_plw.density
END FUNCTION

FUNCTION PLWdescription ()
  DEFINE PLWdesc        CHAR(30),
         PLWcur_wgt     FLOAT,
         PLWvcg         FLOAT,
         PLWlcg         FLOAT,
         PLWtcg         FLOAT,
         PLWvmom        FLOAT,
         PLWlmom        FLOAT,
         PLWtmom        FLOAT,
	 conv_factor    FLOAT

  IF p_vds.prj_units_set = 1 THEN
     LET PLWdesc = "\PLT.-", p_plw.pl_thk * 12.0 USING "#&.&&&", "\" THK."
  ELSE
     LET PLWdesc = "\PLT.-", p_plw.pl_thk * 1000 USING "#&&&.&", " THK."
  END IF
 
  LET PLWcur_wgt = p_plw.pl_vol * p_plw.density
  IF PLWcur_wgt IS NULL OR PLWcur_wgt = "" OR PLWcur_wgt = " " THEN
     LET PLWcur_wgt = 0.0
  END IF

  LET PLWvcg     = p_plw.cog_z - def_vcog
  IF PLWvcg IS NULL OR PLWvcg = "" OR PLWvcg = " " THEN LET PLWvcg = 0.0
  END IF

  LET PLWlcg     = p_plw.cog_x - def_lcog
  IF PLWlcg IS NULL OR PLWlcg = "" OR PLWlcg = " " THEN LET PLWlcg = 0.0
  END IF

  LET PLWtcg     = p_plw.cog_y - def_tcog
  IF PLWtcg IS NULL OR PLWtcg = "" OR PLWtcg = " " THEN LET PLWtcg = 0.0
  END IF

  LET PLWvmom    = PLWvcg * PLWcur_wgt
  IF PLWvmom IS NULL OR PLWvmom = "" OR PLWvmom = " " THEN LET PLWvmom = 0.0
  END IF

  LET PLWlmom    = PLWlcg * PLWcur_wgt
  IF PLWlmom IS NULL OR PLWlmom = "" OR PLWlmom = " " THEN LET PLWlmom = 0.0
  END IF

  LET PLWtmom    = PLWtcg * PLWcur_wgt
  IF PLWtmom IS NULL OR PLWtmom = "" OR PLWtmom = " " THEN LET PLWtmom = 0.0
  END IF

#DISPLAY "\nPLWdescription returns : "
#DISPLAY "\tPLWdesc    : <", PLWdesc CLIPPED, ">"
#DISPLAY "\tPLWcur_wgt = ", PLWcur_wgt USING "#######.###"
#DISPLAY "\tPLWvcg     = ", PLWvcg USING "#######.###"
#DISPLAY "\tPLWlcg     = ", PLWlcg USING "#######.###"
#DISPLAY "\tPLWtcg     = ", PLWtcg USING "#######.###"
#DISPLAY "\tPLWvmom    = ", PLWvmom USING "#######.###"
#DISPLAY "\tPLWlmom    = ", PLWlmom USING "#######.###"
#DISPLAY "\tPLWtmom    = ", PLWtmom USING "#######.###"

RETURN PLWdesc, PLWcur_wgt,
       PLWvcg, PLWlcg, PLWtcg,
       PLWvmom, PLWlmom, PLWtmom
END FUNCTION
