DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BMGquery1 ()

   LET s_stmt =
"\"nfmadmin\".struct_bm_cit.assembly_cat, ",
"\"nfmadmin\".struct_bm_cit.assembly_nam, ",
"\"nfmadmin\".struct_bm_cit.assembly_rev, ",
"\"nfmadmin\".struct_bm_cit.item_no, ",
"\"nfmadmin\".struct_bm_cit.comp_seqno"

   LET f_stmt =
"\"nfmadmin\".struct_bm_cit"

   LET w_stmt =
    "\"nfmadmin\".struct_bm_cit.dwg_cat LIKE '", q_bm.assembly_cat CLIPPED, "' ",
"AND \"nfmadmin\".struct_bm_cit.dwg_nam LIKE '", q_bm.assembly_nam CLIPPED, "' ",
"AND \"nfmadmin\".struct_bm_cit.dwg_rev LIKE '", q_bm.assembly_ver CLIPPED, "' ",
"AND \"nfmadmin\".struct_bm_cit.item_no != 666"

   LET o_stmt =
"\"nfmadmin\".struct_bm_cit.item_no"

   CALL RPTquery ( 0, 1)
END FUNCTION

FUNCTION BMGquery2 (num)
   DEFINE	num	INTEGER

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
"\"nfmadmin\".vds_convert.rndoff_fctr, ",
"\"nfmadmin\".struct_bm_dynamic.end_treatment0, ",
"\"nfmadmin\".struct_bm_dynamic.end_treatment1"

   LET f_stmt =
"\"nfmadmin\".struct_bm_dynamic, ",
"\"nfmadmin\".struct_codelist, ",
"\"nfmadmin\".struct_grade, ",
"OUTER (\"nfmadmin\".vds_convert), ",
"\"nfmadmin\".vds_units"

   LET w_stmt =
"    (\"nfmadmin\".struct_bm_dynamic.assembly_cat LIKE '", p_bmd1[num].assembly_cat, "'",
" OR \"nfmadmin\".struct_bm_dynamic.assembly_cat  IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.assembly_nam LIKE '", p_bmd1[num].assembly_nam, "'",
" OR \"nfmadmin\".struct_bm_dynamic.assembly_nam  IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.assembly_ver LIKE '", p_bmd1[num].assembly_rev, "'",
" OR \"nfmadmin\".struct_bm_dynamic.assembly_ver  IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.comp_seqno   = "    , p_bmd1[num].comp_seqno ,
" OR \"nfmadmin\".struct_bm_dynamic.comp_seqno    IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.zone_number  LIKE '", q_bm.zone_number CLIPPED,  "'",
" OR \"nfmadmin\".struct_bm_dynamic.zone_number   IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.apprv_stat   LIKE '", q_bm.apprv_stat CLIPPED,   "'",
" OR \"nfmadmin\".struct_bm_dynamic.apprv_stat    IS NULL) ",
"AND (\"nfmadmin\".struct_bm_dynamic.constr_stat  LIKE '", q_bm.constr_stat CLIPPED,  "'",
" OR \"nfmadmin\".struct_bm_dynamic.constr_stat   IS NULL) ",
"AND (\"nfmadmin\".vds_units.param_name          = 'density' ",
"AND \"nfmadmin\".vds_units.units_set            = ", p_vds.prj_units_set USING "<<", ") ",
"AND (\"nfmadmin\".struct_codelist.list_num      = 423 ",
"AND \"nfmadmin\".struct_codelist.code_num       = \"nfmadmin\".struct_bm_dynamic.memb_geom) ",
"AND (\"nfmadmin\".struct_grade.material         = \"nfmadmin\".struct_bm_dynamic.material ",
"AND \"nfmadmin\".struct_grade.grade             = \"nfmadmin\".struct_bm_dynamic.grade) ",
"AND (\"nfmadmin\".vds_convert.units_in          = \"nfmadmin\".struct_grade.density_units ",
"AND \"nfmadmin\".vds_convert.units_out          = \"nfmadmin\".vds_units.units_code)"

   LET g_stmt =
"\"nfmadmin\".struct_bm_dynamic.f_part_num, ",
"\"nfmadmin\".struct_codelist.short_txt, ",
"\"nfmadmin\".struct_bm_dynamic.material, ",
"\"nfmadmin\".struct_bm_dynamic.grade, ",
"\"nfmadmin\".struct_grade.density, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr, ",
"\"nfmadmin\".struct_bm_dynamic.end_treatment0, ",
"\"nfmadmin\".struct_bm_dynamic.end_treatment1"

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

FUNCTION BMGdescription ()
  DEFINE BMBlin_wgt     FLOAT,
         BMBtot_wgt     FLOAT


  LET BMBtot_wgt = p_bmd2.grp_vol * p_bmd2.density
  IF BMBtot_wgt IS NULL OR BMBtot_wgt = "" OR BMBtot_wgt = " " THEN
    LET BMBtot_wgt = 0.0
  END IF

  LET BMBlin_wgt = BMBtot_wgt / p_bmd2.grp_len

  RETURN BMBtot_wgt, BMBlin_wgt
END FUNCTION

FUNCTION BMGconvert ()
  # Convert length values
  CALL length_unit_convert ( p_bmd2.grp_len, 1, p_vds.prj_units_set)
       RETURNING p_bmd2.grp_len
  CALL length_unit_convert ( p_bmd2.grp_srf, 2, p_vds.prj_units_set)
       RETURNING p_bmd2.grp_srf
  CALL length_unit_convert ( p_bmd2.grp_vol, 3, p_vds.prj_units_set)
       RETURNING p_bmd2.grp_vol

  # Convert density value
  CALL unit_convert ( p_bmd2.cnvr_fctr,
                      p_bmd2.cnvr_offset,
                      p_bmd2.rndoff_fctr,
                      p_bmd2.density) RETURNING p_bmd2.density
END FUNCTION
