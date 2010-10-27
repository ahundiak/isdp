DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"


FUNCTION BMNquery ()

   LET w_reg =
" AND (\"nfmadmin\".vds_units.param_name     = 'density' ",
"AND \"nfmadmin\".vds_units.units_set       = ", p_vds.prj_units_set USING "<<", ") ",
"AND (\"nfmadmin\".struct_codelist.list_num = 1510) ",
"AND (\"nfmadmin\".struct_codelist.code_num = \"nfmadmin\".struct_bm_dynamic.chg_no) ",
"AND (\"nfmadmin\".struct_grade.material    = \"nfmadmin\".struct_bm_dynamic.material) ",
"AND (\"nfmadmin\".struct_grade.grade       = \"nfmadmin\".struct_bm_dynamic.grade) ",
"AND (\"nfmadmin\".vds_convert.units_in     = \"nfmadmin\".struct_grade.density_units ",
"AND \"nfmadmin\".vds_convert.units_out     = \"nfmadmin\".vds_units.units_code)"

   LET f_reg =
"\"nfmadmin\".struct_bm_dynamic, ",
"OUTER (\"nfmadmin\".struct_codelist), ",
"\"nfmadmin\".struct_grade, ",
"OUTER (\"nfmadmin\".vds_convert), ",
"\"nfmadmin\".vds_units"

##########################  Create BMN query ###################################
   LET s_stmt =
"\"nfmadmin\".struct_bm_dynamic.material, ",
"\"nfmadmin\".struct_bm_dynamic.grade, ",
"\"nfmadmin\".struct_bm_dynamic.volume, ",
"\"nfmadmin\".struct_bm_dynamic.f_part_num, ",
"\"nfmadmin\".struct_bm_dynamic.constr_stat, ",
"\"nfmadmin\".struct_bm_dynamic.chg_no, ",
"\"nfmadmin\".struct_codelist.long_txt, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "struct_bm_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   CALL RPTquery ( 0, 0)

END FUNCTION


FUNCTION BMNdescription ()
   IF p_bmn.constr_stat = " "
   OR p_bmn.constr_stat = ""
   OR p_bmn.constr_stat IS NULL THEN LET p_bmn.constr_stat = "U/F"
   END IF

   IF p_bmn.long_txt = "undefined" THEN LET p_bmn.long_txt = " "
   END IF
END FUNCTION

FUNCTION BMNconvert ()
   # Convert length values
   CALL length_unit_convert (p_bmn.volume, 3, p_vds.prj_units_set)
        RETURNING p_bmn.volume

   # Convert density value
   CALL unit_convert ( p_bmn.cnvr_fctr,
                       p_bmn.cnvr_offset,
                       p_bmn.rndoff_fctr,
                       p_bmn.density) RETURNING p_bmn.density
END FUNCTION
