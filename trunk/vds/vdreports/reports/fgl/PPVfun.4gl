DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPVquery()
  CALL PPunits_set ("npd_g") RETURNING eq_unit_flag

  CASE eq_unit_flag
     WHEN 0

        LET w_reg =
" AND \"nfmadmin\".piping_dynamic.comp_code   = \"nfmadmin\".piping_comp_type.comp_code ",
"AND \"nfmadmin\".piping_comps.short_code    = \"nfmadmin\".piping_comp_type.comp_shcode ",
"AND \"nfmadmin\".piping_dynamic.spec_name   = \"nfmadmin\".piping_spec.spec_name ",
"AND \"nfmadmin\".piping_spec.spec_no        = \"nfmadmin\".piping_comps.spec_no ",
"AND \"nfmadmin\".piping_dynamic.comp_code   = \"nfmadmin\".piping_comps.comp_code ",
"AND \"nfmadmin\".piping_dynamic.npd_g       BETWEEN  \"nfmadmin\".piping_comps.size_g_low ",
"                               AND      \"nfmadmin\".piping_comps.size_g_high ",
"AND \"nfmadmin\".piping_dynamic.npd_r       BETWEEN  \"nfmadmin\".piping_comps.size_r_low ",
"                               AND      \"nfmadmin\".piping_comps.size_r_high ",
"AND \"nfmadmin\".piping_dynamic.opt_code    = \"nfmadmin\".piping_comps.opt_code ",
"AND \"nfmadmin\".piping_comp_type.comp_cat  = 4 ",
"AND \"nfmadmin\".piping_dynamic.no_mto_flag = ' ' ",
"AND \"nfmadmin\".piping_comps.rating_g      IS NOT NULL ",
"AND \"nfmadmin\".piping_comps.rating_g      != ' ' ",
"AND (\"nfmadmin\".piping_codelist.list_num  = 330 ",
"AND \"nfmadmin\".piping_codelist.code_num   = \"nfmadmin\".piping_comps.prep_g) ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"OUTER (\"nfmadmin\".piping_codelist), ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPV query ###################################
  LET s_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_dynamic.npd_g, ",
"\"nfmadmin\".piping_dynamic.npd_r, ",
"\"nfmadmin\".piping_dynamic.comp_note, ",
"\"nfmadmin\".piping_comps.short_code, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.rating_g, ",
"\"nfmadmin\".piping_comps.commodity, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"\"nfmadmin\".piping_codelist.long_txt"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "piping_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"\"nfmadmin\".piping_comps.npd_g DESC, ",
"\"nfmadmin\".piping_comps.npd_r DESC"

     WHEN 1

        LET w_reg =
" AND \"nfmadmin\".piping_dynamic.comp_code   = \"nfmadmin\".piping_comp_type.comp_code ",
"AND \"nfmadmin\".piping_comps.short_code    = \"nfmadmin\".piping_comp_type.comp_shcode ",
"AND \"nfmadmin\".piping_dynamic.spec_name   = \"nfmadmin\".piping_spec.spec_name ",
"AND \"nfmadmin\".piping_spec.spec_no        = \"nfmadmin\".piping_comps.spec_no ",
"AND \"nfmadmin\".piping_dynamic.comp_code   = \"nfmadmin\".piping_comps.comp_code ",
"AND npdg.npd BETWEEN piping_comps.size_g_low AND \"nfmadmin\".piping_comps.size_g_high ",
"AND npdr.npd BETWEEN piping_comps.size_r_low AND \"nfmadmin\".piping_comps.size_r_high ",
"AND \"nfmadmin\".piping_dynamic.opt_code    = \"nfmadmin\".piping_comps.opt_code ",
"AND \"nfmadmin\".piping_comp_type.comp_cat  = 4 ",
"AND \"nfmadmin\".piping_dynamic.no_mto_flag = ' ' ",
"AND \"nfmadmin\".piping_comps.rating_g      IS NOT NULL ",
"AND \"nfmadmin\".piping_comps.rating_g      != ' ' ",
"AND (\"nfmadmin\".piping_codelist.list_num  = 330 ",
"AND \"nfmadmin\".piping_codelist.code_num   = \"nfmadmin\".piping_comps.prep_g) ",
"AND (npdg.tblno                  = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdg.npd_equiv               = \"nfmadmin\".piping_dynamic.npd_g) ",
"AND (npdr.tblno                  = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdr.npd_equiv               = \"nfmadmin\".piping_dynamic.npd_r) ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"OUTER (\"nfmadmin\".piping_codelist), ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_npd_allowed npdg, ",
"\"nfmadmin\".piping_npd_allowed npdr, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPV query ###################################
  LET s_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"npdg.npd, ",
"npdr.npd, ",
"\"nfmadmin\".piping_dynamic.comp_note, ",
"\"nfmadmin\".piping_comps.short_code, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.rating_g, ",
"\"nfmadmin\".piping_comps.commodity, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"\"nfmadmin\".piping_codelist.long_txt"


   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "piping_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"npdg.npd DESC, ",
"npdr.npd DESC"
  END CASE

   CALL RPTquery ( 0, 1)
END FUNCTION

FUNCTION PPVdescription ()
  DEFINE	PPVdesc	CHAR(40),
		siz	FLOAT,
		PPVsize	CHAR(30)

  IF p_ppv.rating_g IS NOT NULL AND p_ppv.rating_g != " " THEN
     LET PPVdesc = p_ppv.comp_descr CLIPPED, "\, ",
                       p_ppv.rating_g CLIPPED, "\, ",
                       p_ppv.long_txt CLIPPED
  ELSE LET PPVdesc = p_ppv.comp_descr CLIPPED, "\, ", p_ppv.long_txt CLIPPED
  END IF

  IF p_ppv.npd_r != 0.0 AND p_ppv.npd_r != p_ppv.npd_g THEN
     LET siz = p_ppv.npd_r * p_ppv.npd_g
  ELSE
     LET siz = p_ppv.npd_g
  END IF
  CALL size_of_element ( siz, 0) RETURNING PPVsize

  RETURN PPVdesc, PPVsize
END FUNCTION
