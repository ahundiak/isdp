DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PLNquery ()

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

##########################  Create PLN query ###################################
   LET s_stmt =
"\"nfmadmin\".struct_pl_dynamic.material, ",
"\"nfmadmin\".struct_pl_dynamic.grade, ",
"\"nfmadmin\".struct_pl_dynamic.volume, ",
"\"nfmadmin\".struct_pl_dynamic.plate_length, ",
"\"nfmadmin\".struct_pl_dynamic.plate_width, ",
"\"nfmadmin\".struct_pl_dynamic.plate_thk, ",
"\"nfmadmin\".struct_pl_dynamic.constr_stat, ",
"\"nfmadmin\".struct_pl_dynamic.chg_no, ",
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

   CALL RPTquery ( 0, 0)
END FUNCTION

FUNCTION PLNconvert ()

  # Convert volume value
  CALL length_unit_convert (p_pln.pl_vol, 3, p_vds.prj_units_set)
       RETURNING p_pln.pl_vol

  # Convert density value
  CALL unit_convert ( p_pln.cnvr_fctr,
                      p_pln.cnvr_offset,
                      p_pln.rndoff_fctr,
                      p_pln.density) RETURNING p_pln.density
END FUNCTION

FUNCTION PLNdescription ()

      IF p_pln.constr_stat = " "
      OR p_pln.constr_stat = ""
      OR p_pln.constr_stat IS NULL THEN LET p_pln.constr_stat = "U/F"
      END IF

      IF p_pln.long_txt = "undefined" THEN LET p_pln.long_txt = " "
      END IF

END FUNCTION
