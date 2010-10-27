# 4/24/96 slj - Changed and to or to eliminate divide by 0 error #
DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BMWquery ()

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

##########################  Create BMW query ###################################
   LET s_stmt =
"\"nfmadmin\".struct_bm_dynamic.chg_no, ",
"\"nfmadmin\".struct_bm_dynamic.comp_seqno, ",
"\"nfmadmin\".struct_bm_dynamic.weight_grp, ",
"\"nfmadmin\".struct_bm_dynamic.f_part_num, ",
"\"nfmadmin\".struct_bm_dynamic.memb_cut_leng, ",
"\"nfmadmin\".struct_bm_dynamic.volume, ",
"\"nfmadmin\".struct_bm_dynamic.cog_x, ",
"\"nfmadmin\".struct_bm_dynamic.cog_y, ",
"\"nfmadmin\".struct_bm_dynamic.cog_z, ",
"\"nfmadmin\".struct_bm_dynamic.material, ",
"\"nfmadmin\".struct_bm_dynamic.grade, ",
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

   LET o_stmt =
"\"nfmadmin\".struct_bm_dynamic.chg_no, ",
"\"nfmadmin\".struct_bm_dynamic.weight_grp, ",
"\"nfmadmin\".struct_bm_dynamic.f_part_num, ",
"\"nfmadmin\".struct_bm_dynamic.material"

   CALL RPTquery ( 0, 1)


END FUNCTION

FUNCTION BMWdescription ()
  DEFINE BMWlin_wgt     FLOAT,
         BMWcut_len     FLOAT,
         BMWcur_wgt     FLOAT,
         BMWvcg         FLOAT,
         BMWlcg         FLOAT,
         BMWtcg         FLOAT,
         BMWvmom        FLOAT,
         BMWlmom        FLOAT,
         BMWtmom        FLOAT


  LET BMWcur_wgt = (p_bmw.bm_vol * p_bmw.density)
  IF BMWcur_wgt IS NULL OR BMWcur_wgt = "" OR BMWcur_wgt = " " THEN
     LET BMWcur_wgt = 0.0
  END IF

  LET BMWcut_len = p_bmw.bm_len
  IF BMWcut_len IS NULL OR BMWcut_len = "" OR BMWcut_len = " " THEN
     LET BMWcut_len = 0.0
  END IF

# Changed from and to OR to eliminate divide by 0 error - slj 4/24/96 #
  IF BMWcur_wgt = 0.0 OR BMWcut_len = 0.0 THEN
     LET BMWlin_wgt = 0.0
  ELSE 
     LET BMWlin_wgt = BMWcur_wgt / BMWcut_len
  END IF

  LET BMWvcg     = p_bmw.cog_z - def_vcog
  IF BMWvcg IS NULL OR BMWvcg = "" OR BMWvcg = " " THEN
     LET BMWvcg = 0.0
  END IF

  LET BMWlcg     = p_bmw.cog_x - def_lcog
  IF BMWlcg IS NULL OR BMWlcg = "" OR BMWlcg = " " THEN
     LET BMWlcg = 0.0
  END IF

  LET BMWtcg     = p_bmw.cog_y - def_tcog
  IF BMWtcg IS NULL OR BMWtcg = "" OR BMWtcg = " " THEN
     LET BMWtcg = 0.0
  END IF

  LET BMWvmom    = BMWvcg * BMWcur_wgt
  IF BMWvmom IS NULL OR BMWvmom = "" OR BMWvmom = " " THEN
     LET BMWvmom = 0.0
  END IF

  LET BMWlmom    = BMWlcg * BMWcur_wgt
  IF BMWlmom IS NULL OR BMWlmom = "" OR BMWlmom = " " THEN
     LET BMWlmom = 0.0
  END IF

  LET BMWtmom    = BMWtcg * BMWcur_wgt
  IF BMWtmom IS NULL OR BMWtmom = "" OR BMWtmom = " " THEN
     LET BMWtmom = 0.0
  END IF

  RETURN BMWlin_wgt, BMWcut_len, BMWcur_wgt,
         BMWvcg, BMWlcg, BMWtcg,
         BMWvmom, BMWlmom, BMWtmom
END FUNCTION

FUNCTION BMWconvert ()
  # Convert length values
  CALL length_unit_convert (p_bmw.bm_len, 1, p_vds.prj_units_set)
       RETURNING p_bmw.bm_len
  CALL length_unit_convert (p_bmw.bm_vol, 3, p_vds.prj_units_set)
       RETURNING p_bmw.bm_vol
  CALL length_unit_convert (p_bmw.cog_x, 1, p_vds.prj_units_set)
       RETURNING p_bmw.cog_x
  CALL length_unit_convert (p_bmw.cog_y, 1, p_vds.prj_units_set)
       RETURNING p_bmw.cog_y
  CALL length_unit_convert (p_bmw.cog_z, 1, p_vds.prj_units_set)
       RETURNING p_bmw.cog_z

  # Convert density value
  CALL unit_convert ( p_bmw.cnvr_fctr,
                      p_bmw.cnvr_offset,
                      p_bmw.rndoff_fctr,
                      p_bmw.density) RETURNING p_bmw.density
END FUNCTION
