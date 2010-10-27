DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPDquery1 ()

  LET w_reg = " \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

  LET f_reg =
"\"nfmadmin\".piping_dynamic"

##########################  Create PPD query 1 #################################
  LET s_stmt =
"\"nfmadmin\".piping_dynamic.dgn_press, ",
"\"nfmadmin\".piping_dynamic.dgn_temp, ",
"\"nfmadmin\".piping_dynamic.fluid_code, ",
"\"nfmadmin\".piping_dynamic.insul_type, ",
"\"nfmadmin\".piping_dynamic.insul_thk, ",
"\"nfmadmin\".piping_dynamic.op_press, ",
"\"nfmadmin\".piping_dynamic.op_temp, ",
"\"nfmadmin\".piping_dynamic.paint_code, ",
"\"nfmadmin\".piping_dynamic.spec_grav, ",
"\"nfmadmin\".piping_dynamic.spec_name, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_dynamic.tracing_code"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "\"nfmadmin\".piping_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET g_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_dynamic.spec_name, ",
"\"nfmadmin\".piping_dynamic.fluid_code, ",
"\"nfmadmin\".piping_dynamic.insul_type, ",
"\"nfmadmin\".piping_dynamic.insul_thk, ",
"\"nfmadmin\".piping_dynamic.tracing_code, ",
"\"nfmadmin\".piping_dynamic.paint_code, ",
"\"nfmadmin\".piping_dynamic.op_temp, ",
"\"nfmadmin\".piping_dynamic.op_press, ",
"\"nfmadmin\".piping_dynamic.spec_grav, ",
"\"nfmadmin\".piping_dynamic.dgn_temp, ",
"\"nfmadmin\".piping_dynamic.dgn_press"

   CALL RPTquery ( 1, 0)
END FUNCTION

FUNCTION PPDdisplay_null (i)
  DEFINE	i 	INTEGER

  IF p_ppd1[i].seq_number  IS NULL THEN
     CALL ERRORLOG("piping_dynamic.seq_number  IS NULL")
     MESSAGE "piping_dynamic.seq_number  IS NULL"
  END IF

  IF p_ppd1[i].spec_name    IS NULL THEN
     CALL ERRORLOG("piping_dynamic.spec_name    IS NULL")
     MESSAGE "piping_dynamic.spec_name    IS NULL"
  END IF

  IF p_ppd1[i].fluid_code   IS NULL THEN
     CALL ERRORLOG("piping_dynamic.fluid_code   IS NULL")
     MESSAGE "piping_dynamic.fluid_code   IS NULL"
  END IF

  IF p_ppd1[i].insul_type   IS NULL THEN
     CALL ERRORLOG("piping_dynamic.insul_type   IS NULL")
     MESSAGE "piping_dynamic.insul_type   IS NULL"
  END IF

  IF p_ppd1[i].insul_thk    IS NULL THEN
     CALL ERRORLOG("piping_dynamic.insul_thk    IS NULL")
     MESSAGE "piping_dynamic.insul_thk    IS NULL"
  END IF

  IF p_ppd1[i].tracing_code IS NULL THEN
     CALL ERRORLOG("piping_dynamic.tracing_code IS NULL")
     MESSAGE "piping_dynamic.tracing_code IS NULL"
  END IF

  IF p_ppd1[i].paint_code   IS NULL THEN
     CALL ERRORLOG("piping_dynamic.paint_code   IS NULL")
     MESSAGE "piping_dynamic.paint_code   IS NULL"
  END IF

  IF p_ppd1[i].op_temp      IS NULL THEN
     CALL ERRORLOG("piping_dynamic.op_temp      IS NULL")
     MESSAGE "piping_dynamic.op_temp      IS NULL"
  END IF

  IF p_ppd1[i].op_press     IS NULL THEN
     CALL ERRORLOG("piping_dynamic.op_press     IS NULL")
     MESSAGE "piping_dynamic.op_press     IS NULL"
  END IF

  IF p_ppd1[i].spec_grav    IS NULL THEN
     CALL ERRORLOG("piping_dynamic.spec_grav    IS NULL")
     MESSAGE "piping_dynamic.spec_grav    IS NULL"
  END IF

  IF p_ppd1[i].dgn_temp     IS NULL THEN
     CALL ERRORLOG("piping_dynamic.dgn_temp     IS NULL")
     MESSAGE "piping_dynamic.dgn_temp     IS NULL"
  END IF

  IF p_ppd1[i].dgn_press    IS NULL THEN
     CALL ERRORLOG("piping_dynamic.dgn_press    IS NULL")
     MESSAGE "piping_dynamic.dgn_press    IS NULL"
  END IF

END FUNCTION

FUNCTION PPDclarify (i)
  DEFINE	i 	INTEGER

  IF p_ppd1[i].fluid_code IS NULL OR p_ppd1[i].fluid_code = "" THEN
     LET p_ppd1[i].fluid_code = " "
  END IF

  IF p_ppd1[i].insul_type IS NULL OR p_ppd1[i].insul_type = "" THEN
     LET p_ppd1[i].insul_type = " "
  END IF

  IF p_ppd1[i].paint_code IS NULL OR p_ppd1[i].paint_code = "" THEN
     LET p_ppd1[i].paint_code = " "
  END IF

  IF p_ppd1[i].spec_name IS NULL OR p_ppd1[i].spec_name = "" THEN
     LET p_ppd1[i].spec_name = " "
  END IF

  IF p_ppd1[i].seq_number IS NULL OR p_ppd1[i].seq_number = "" THEN
     LET p_ppd1[i].seq_number = " "
  END IF

  IF p_ppd1[i].tracing_code IS NULL OR p_ppd1[i].tracing_code = "" THEN
     LET p_ppd1[i].tracing_code = " "
  END IF
END FUNCTION

FUNCTION PPDquery2 (i)
  DEFINE	i 	INTEGER

  CALL PPunits_set ("npd_g") RETURNING eq_unit_flag
  CALL RPTwhere_begin (6) 	# regenerate begining of WHERE clause in w_stmt

  CASE eq_unit_flag

     WHEN 0

        LET w_reg =
" AND (\"nfmadmin\".piping_dynamic.seq_number   = '", p_ppd1[i].seq_number CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.seq_number   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.spec_name    = '", p_ppd1[i].spec_name CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.spec_name    IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.fluid_code   = '", p_ppd1[i].fluid_code CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.fluid_code   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.insul_type   = '", p_ppd1[i].insul_type CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.insul_type   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.insul_thk = ", p_ppd1[i].insul_thk USING "###.###########",
" OR \"nfmadmin\".piping_dynamic.insul_thk    IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.tracing_code = '", p_ppd1[i].tracing_code CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.tracing_code IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.paint_code   = '", p_ppd1[i].paint_code CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.paint_code   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.op_temp   = ", p_ppd1[i].op_temp   USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.op_temp      IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.op_press  = ", p_ppd1[i].op_press  USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.op_press     IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.spec_grav = ", p_ppd1[i].spec_grav USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.spec_grav    IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.dgn_temp  = ", p_ppd1[i].dgn_temp  USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.dgn_temp     IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.dgn_press = ", p_ppd1[i].dgn_press USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.dgn_press    IS NULL ) ",
"AND \"nfmadmin\".piping_dynamic.comp_code    = \"nfmadmin\".piping_comp_type.comp_code ",
"AND \"nfmadmin\".piping_comps.short_code     = \"nfmadmin\".piping_comp_type.comp_shcode ",
"AND \"nfmadmin\".piping_dynamic.spec_name    = \"nfmadmin\".piping_spec.spec_name ",
"AND \"nfmadmin\".piping_spec.spec_no         = \"nfmadmin\".piping_comps.spec_no ",
"AND \"nfmadmin\".piping_dynamic.comp_code    = \"nfmadmin\".piping_comps.comp_code ",
"AND \"nfmadmin\".piping_dynamic.npd_g        BETWEEN \"nfmadmin\".piping_comps.size_g_low ",
"                                AND     \"nfmadmin\".piping_comps.size_g_high ",
"AND \"nfmadmin\".piping_dynamic.npd_r        BETWEEN \"nfmadmin\".piping_comps.size_r_low ",
"                                AND     \"nfmadmin\".piping_comps.size_r_high ",
"AND \"nfmadmin\".piping_dynamic.opt_code     = \"nfmadmin\".piping_comps.opt_code ",
"AND \"nfmadmin\".piping_dynamic.no_mto_flag  = ' ' ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPD query 2 #################################
        LET s_stmt =
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"\"nfmadmin\".piping_dynamic.comp_note, ",
"\"nfmadmin\".piping_dynamic.dgn_press, ",
"\"nfmadmin\".piping_dynamic.dgn_temp, ",
"\"nfmadmin\".piping_dynamic.fluid_code, ",
"\"nfmadmin\".piping_dynamic.insul_type, ",
"\"nfmadmin\".piping_dynamic.insul_thk, ",
"\"nfmadmin\".piping_dynamic.loc_x, ",
"\"nfmadmin\".piping_dynamic.loc_y, ",
"\"nfmadmin\".piping_dynamic.loc_z, ",
"\"nfmadmin\".piping_dynamic.npd_g, ",
"\"nfmadmin\".piping_dynamic.npd_r, ",
"\"nfmadmin\".piping_dynamic.op_press, ",
"\"nfmadmin\".piping_dynamic.op_temp, ",
"\"nfmadmin\".piping_dynamic.opt_code, ",
"\"nfmadmin\".piping_dynamic.paint_code, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.spec_grav, ",
"\"nfmadmin\".piping_dynamic.spec_name, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_dynamic.tag_number, ",
"\"nfmadmin\".piping_dynamic.tracing_code"

        CASE drawing_flag
           WHEN 0 LET f_stmt = f_reg CLIPPED
           WHEN 1 LET f_stmt = "\"nfmadmin\".piping_cit, ", f_reg CLIPPED
        END CASE
     
        LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

     WHEN 1

        LET w_reg =
" AND (\"nfmadmin\".piping_dynamic.seq_number   = '", p_ppd1[i].seq_number CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.seq_number   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.spec_name    = '", p_ppd1[i].spec_name CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.spec_name    IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.fluid_code   = '", p_ppd1[i].fluid_code CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.fluid_code   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.insul_type   = '", p_ppd1[i].insul_type CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.insul_type   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.insul_thk = ", p_ppd1[i].insul_thk USING "###.###########",
" OR \"nfmadmin\".piping_dynamic.insul_thk    IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.tracing_code = '", p_ppd1[i].tracing_code CLIPPED, "'",
" OR \"nfmadmin\".piping_dynamic.tracing_code IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.paint_code   = '", p_ppd1[i].paint_code CLIPPED,  "'",
" OR \"nfmadmin\".piping_dynamic.paint_code   IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.op_temp   = ", p_ppd1[i].op_temp   USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.op_temp      IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.op_press  = ", p_ppd1[i].op_press  USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.op_press     IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.spec_grav = ", p_ppd1[i].spec_grav USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.spec_grav    IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.dgn_temp  = ", p_ppd1[i].dgn_temp  USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.dgn_temp     IS NULL ) ",
"AND (\"nfmadmin\".piping_dynamic.dgn_press = ", p_ppd1[i].dgn_press USING "####.##########",
" OR \"nfmadmin\".piping_dynamic.dgn_press    IS NULL ) ",
"AND \"nfmadmin\".piping_dynamic.comp_code    = \"nfmadmin\".piping_comp_type.comp_code ",
"AND \"nfmadmin\".piping_comps.short_code     = \"nfmadmin\".piping_comp_type.comp_shcode ",
"AND \"nfmadmin\".piping_dynamic.spec_name    = \"nfmadmin\".piping_spec.spec_name ",
"AND \"nfmadmin\".piping_spec.spec_no         = \"nfmadmin\".piping_comps.spec_no ",
"AND \"nfmadmin\".piping_dynamic.comp_code    = \"nfmadmin\".piping_comps.comp_code ",
"AND npdg.npd BETWEEN \"nfmadmin\".piping_comps.size_g_low AND \"nfmadmin\".piping_comps.size_g_high ",
"AND npdr.npd BETWEEN \"nfmadmin\".piping_comps.size_r_low AND \"nfmadmin\".piping_comps.size_r_high ",
"AND \"nfmadmin\".piping_dynamic.opt_code     = \"nfmadmin\".piping_comps.opt_code ",
"AND \"nfmadmin\".piping_dynamic.no_mto_flag  = ' ' ",
"AND (npdg.tblno                = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdg.npd_equiv             = \"nfmadmin\".piping_dynamic.npd_g) ",
"AND (npdr.tblno                = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdr.npd_equiv             = \"nfmadmin\".piping_dynamic.npd_r) ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_npd_allowed npdg, ",
"\"nfmadmin\".piping_npd_allowed npdr, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPD query 2 #################################
        LET s_stmt =
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"\"nfmadmin\".piping_dynamic.comp_note, ",
"\"nfmadmin\".piping_dynamic.dgn_press, ",
"\"nfmadmin\".piping_dynamic.dgn_temp, ",
"\"nfmadmin\".piping_dynamic.fluid_code, ",
"\"nfmadmin\".piping_dynamic.insul_type, ",
"\"nfmadmin\".piping_dynamic.insul_thk, ",
"\"nfmadmin\".piping_dynamic.loc_x, ",
"\"nfmadmin\".piping_dynamic.loc_y, ",
"\"nfmadmin\".piping_dynamic.loc_z, ",
"npdg.npd, ",
"npdr.npd, ",
"\"nfmadmin\".piping_dynamic.op_press, ",
"\"nfmadmin\".piping_dynamic.op_temp, ",
"\"nfmadmin\".piping_dynamic.opt_code, ",
"\"nfmadmin\".piping_dynamic.paint_code, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.spec_grav, ",
"\"nfmadmin\".piping_dynamic.spec_name, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_dynamic.tag_number, ",
"\"nfmadmin\".piping_dynamic.tracing_code"

        CASE drawing_flag
           WHEN 0 LET f_stmt = f_reg CLIPPED
           WHEN 1 LET f_stmt = "\"nfmadmin\".piping_cit, ", f_reg CLIPPED
        END CASE

        LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   END CASE

   CALL RPTquery ( 0, 0)
END FUNCTION

FUNCTION PPDconvert ()

  IF p_ppd2.tag_number IS NULL OR p_ppd2.tag_number = "" THEN
     LET p_ppd2.tag_number = " -"
  END IF

  IF p_ppd2.sch_thk_ovr IS NULL OR p_ppd2.sch_thk_ovr = "" THEN
     LET p_ppd2.sch_thk_ovr = " -"
  END IF

  IF p_ppd2.comp_note IS NULL OR p_ppd2.comp_note = "" THEN
     LET p_ppd2.comp_note = " -"
  END IF

END FUNCTION
