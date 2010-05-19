DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BMBquery ()

   LET w_reg =
" AND (\"nfmadmin\".vds_units.param_name     = 'density' ",
"AND \"nfmadmin\".vds_units.units_set       = ", p_vds.prj_units_set USING "<<", ") ",
"AND (\"nfmadmin\".struct_codelist.list_num = 423 ",
"AND \"nfmadmin\".struct_codelist.code_num  = \"nfmadmin\".struct_bm_dynamic.memb_geom) ",
"AND (\"nfmadmin\".struct_grade.material    = \"nfmadmin\".struct_bm_dynamic.material ",
"AND \"nfmadmin\".struct_grade.grade        = \"nfmadmin\".struct_bm_dynamic.grade) ",
"AND (\"nfmadmin\".vds_convert.units_in     = \"nfmadmin\".struct_grade.density_units ",
"AND \"nfmadmin\".vds_convert.units_out     = \"nfmadmin\".vds_units.units_code)"

   LET f_reg =
"\"nfmadmin\".struct_bm_dynamic, ",
"\"nfmadmin\".struct_codelist, ",
"\"nfmadmin\".struct_grade, ",
"OUTER (\"nfmadmin\".vds_convert), ",
"\"nfmadmin\".vds_units"

##########################  Create BMB query ###################################
   LET s_stmt =
"\"nfmadmin\".struct_bm_dynamic.f_part_num, ",
"\"nfmadmin\".struct_bm_dynamic.material, ",
"\"nfmadmin\".struct_bm_dynamic.grade, ",
"COUNT (*), ",
"SUM (\"nfmadmin\".struct_bm_dynamic.memb_cut_leng), ",
"SUM (\"nfmadmin\".struct_bm_dynamic.surface_area), ",
"SUM (\"nfmadmin\".struct_bm_dynamic.volume), ",
"\"nfmadmin\".struct_codelist.short_txt, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "struct_bm_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET g_stmt =
"\"nfmadmin\".struct_bm_dynamic.f_part_num, ",
"\"nfmadmin\".struct_codelist.short_txt, ",
"\"nfmadmin\".struct_bm_dynamic.material, ",
"\"nfmadmin\".struct_bm_dynamic.grade, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   LET o_stmt =
"\"nfmadmin\".struct_bm_dynamic.f_part_num, ",
"\"nfmadmin\".struct_codelist.short_txt, ",
"\"nfmadmin\".struct_bm_dynamic.material, ",
"\"nfmadmin\".struct_bm_dynamic.grade, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CALL RPTquery ( 1, 1)
END FUNCTION


FUNCTION BMBdescription ()
  DEFINE BMBlin_wgt     FLOAT,
         BMBtot_wgt     FLOAT


  LET BMBtot_wgt = p_bmb.grp_vol * p_bmb.density
  IF BMBtot_wgt IS NULL OR BMBtot_wgt = "" OR BMBtot_wgt = " " THEN
    LET BMBtot_wgt = 0.0
  END IF

  LET BMBlin_wgt = BMBtot_wgt / p_bmb.grp_len

  RETURN BMBtot_wgt, BMBlin_wgt
END FUNCTION

FUNCTION BMBconvert ()
  # Convert length values
  CALL length_unit_convert (p_bmb.grp_len, 1, p_vds.prj_units_set)
       RETURNING p_bmb.grp_len
  CALL length_unit_convert (p_bmb.grp_srf, 2, p_vds.prj_units_set)
       RETURNING p_bmb.grp_srf
  CALL length_unit_convert (p_bmb.grp_vol, 3, p_vds.prj_units_set)
       RETURNING p_bmb.grp_vol

  # Convert density value
  CALL unit_convert ( p_bmb.cnvr_fctr,
                      p_bmb.cnvr_offset,
                      p_bmb.rndoff_fctr,
                      p_bmb.density) RETURNING p_bmb.density
END FUNCTION
