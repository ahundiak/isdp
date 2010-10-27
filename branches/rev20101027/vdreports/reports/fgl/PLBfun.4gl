DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PLBquery ()

   LET w_reg =
" AND (\"nfmadmin\".vds_units.param_name           = 'density' ",
"AND \"nfmadmin\".vds_units.units_set             = ", p_vds.prj_units_set USING "<<", ") ",
"AND (\"nfmadmin\".struct_codelist.list_num       = 423 ",
"AND \"nfmadmin\".struct_codelist.code_num        = \"nfmadmin\".struct_pl_dynamic.memb_geom) ",
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

##########################  Create PLB query ###################################
   LET s_stmt =
"\"nfmadmin\".struct_pl_dynamic.material, ",
"\"nfmadmin\".struct_pl_dynamic.grade, ",
"\"nfmadmin\".struct_pl_dynamic.volume, ",
"\"nfmadmin\".struct_pl_dynamic.plate_length, ",
"\"nfmadmin\".struct_pl_dynamic.plate_width, ",
"\"nfmadmin\".struct_pl_dynamic.plate_thk, ",
"\"nfmadmin\".struct_pl_dynamic.surface_area, ",
"COUNT (*), ",
"SUM (\"nfmadmin\".struct_pl_dynamic.surface_area), ",
"SUM (\"nfmadmin\".struct_pl_dynamic.volume), ",
"\"nfmadmin\".struct_codelist.short_txt, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "struct_pl_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET g_stmt =
"\"nfmadmin\".struct_pl_dynamic.material, ",
"\"nfmadmin\".struct_pl_dynamic.grade, ",
"\"nfmadmin\".struct_codelist.short_txt, ",
"\"nfmadmin\".struct_pl_dynamic.plate_length, ",
"\"nfmadmin\".struct_pl_dynamic.plate_width, ",
"\"nfmadmin\".struct_pl_dynamic.plate_thk, ",
"\"nfmadmin\".struct_pl_dynamic.volume, ",
"\"nfmadmin\".struct_pl_dynamic.surface_area, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   LET o_stmt =
"\"nfmadmin\".struct_pl_dynamic.material, ",
"\"nfmadmin\".struct_pl_dynamic.grade, ",
"\"nfmadmin\".struct_codelist.short_txt, ",
"\"nfmadmin\".struct_pl_dynamic.plate_length, ",
"\"nfmadmin\".struct_pl_dynamic.plate_width, ",
"\"nfmadmin\".struct_pl_dynamic.plate_thk, ",
"\"nfmadmin\".struct_pl_dynamic.volume, ",
"\"nfmadmin\".struct_pl_dynamic.surface_area, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CALL RPTquery ( 1, 1)
END FUNCTION

FUNCTION PLBconvert ()
  # Convert length values
  CALL length_unit_convert (p_plb.pl_vol, 3, p_vds.prj_units_set)
       RETURNING p_plb.pl_vol
  CALL length_unit_convert (p_plb.pl_len, 1, p_vds.prj_units_set)
       RETURNING p_plb.pl_len
  CALL length_unit_convert (p_plb.pl_wid, 1, p_vds.prj_units_set)
       RETURNING p_plb.pl_wid
  CALL length_unit_convert (p_plb.pl_thk, 1, p_vds.prj_units_set)
       RETURNING p_plb.pl_thk
  CALL length_unit_convert (p_plb.pl_srf, 2, p_vds.prj_units_set)
       RETURNING p_plb.pl_srf
  CALL length_unit_convert (p_plb.sum_srf, 2, p_vds.prj_units_set)
       RETURNING p_plb.sum_srf
  CALL length_unit_convert (p_plb.sum_vol, 3, p_vds.prj_units_set)
       RETURNING p_plb.sum_vol

  # Convert density value
  CALL unit_convert ( p_plb.cnvr_fctr,
                      p_plb.cnvr_offset,
                      p_plb.rndoff_fctr,
                      p_plb.density)     RETURNING p_plb.density
END FUNCTION

FUNCTION PLBdescription ()
  DEFINE 	wgt     FLOAT

  LET wgt = p_plb.sum_vol * p_plb.density

  RETURN wgt

END FUNCTION
