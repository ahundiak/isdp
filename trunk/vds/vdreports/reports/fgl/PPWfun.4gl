DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPWquery ()
  CALL PPunits_set ("npd_g") RETURNING eq_unit_flag

  CASE eq_unit_flag

     WHEN 0

        LET w_reg =
" AND \"nfmadmin\".piping_dynamic.comp_code  = \"nfmadmin\".piping_comp_type.comp_code ",
"AND \"nfmadmin\".piping_comps.short_code    = \"nfmadmin\".piping_comp_type.comp_shcode ",
"AND \"nfmadmin\".piping_dynamic.spec_name   = \"nfmadmin\".piping_spec.spec_name ",
"AND \"nfmadmin\".piping_spec.spec_no        = \"nfmadmin\".piping_comps.spec_no ",
"AND \"nfmadmin\".piping_dynamic.comp_code   = \"nfmadmin\".piping_comps.comp_code ",
"AND \"nfmadmin\".piping_dynamic.npd_g       BETWEEN \"nfmadmin\".piping_comps.size_g_low ",
"                               AND     \"nfmadmin\".piping_comps.size_g_high ",
"AND \"nfmadmin\".piping_dynamic.npd_r       BETWEEN \"nfmadmin\".piping_comps.size_r_low ",
"                               AND     \"nfmadmin\".piping_comps.size_r_high ",
"AND \"nfmadmin\".piping_dynamic.opt_code    = \"nfmadmin\".piping_comps.opt_code ",
"AND \"nfmadmin\".piping_dynamic.no_mto_flag = ' ' ",
"AND (sha.list_num = 1510       AND sha.code_num = \"nfmadmin\".piping_dynamic.chg_no) ",
"AND (pdg.list_num =  330       AND pdg.code_num = \"nfmadmin\".piping_comps.prep_g) ",
"AND (pdr.list_num =  330       AND pdr.code_num = \"nfmadmin\".piping_comps.prep_r) ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"OUTER (\"nfmadmin\".piping_codelist sha), ",
"OUTER (\"nfmadmin\".piping_codelist pdg), ",
"OUTER (\"nfmadmin\".piping_codelist pdr), ",
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPW query ###################################
        LET s_stmt =
"sha.long_txt, ",
"pdg.long_txt, ",
"pdr.long_txt, ",
"\"nfmadmin\".piping_comps.family_name, ",
"\"nfmadmin\".piping_comps.part_no_prfx, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.prep_r, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_comps.short_code, ",
"\"nfmadmin\".piping_comps.spec_no, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comp_type.comp_numcp, ",
"\"nfmadmin\".piping_dynamic.bend_sweep, ",
"\"nfmadmin\".piping_dynamic.chg_no, ",
"\"nfmadmin\".piping_dynamic.comp_seqno, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"\"nfmadmin\".piping_dynamic.insul_thk, ",
"\"nfmadmin\".piping_dynamic.loc_x, ",
"\"nfmadmin\".piping_dynamic.loc_y, ",
"\"nfmadmin\".piping_dynamic.loc_z, ",
"\"nfmadmin\".piping_dynamic.npd_g, ",
"\"nfmadmin\".piping_dynamic.npd_r, ",
"\"nfmadmin\".piping_dynamic.pipe_length, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.spec_grav, ",
"\"nfmadmin\".piping_dynamic.weight_grp"

        CASE drawing_flag
           WHEN 0 LET f_stmt = f_reg CLIPPED
           WHEN 1 LET f_stmt = "\"nfmadmin\".piping_cit, ", f_reg CLIPPED
        END CASE

        LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

        LET o_stmt =
"\"nfmadmin\".piping_dynamic.chg_no, ",
"\"nfmadmin\".piping_dynamic.weight_grp, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"\"nfmadmin\".piping_dynamic.npd_g, ",
"\"nfmadmin\".piping_dynamic.npd_r"

     WHEN 1

        LET w_reg =
" AND \"nfmadmin\".piping_dynamic.comp_code  = \"nfmadmin\".piping_comp_type.comp_code ",
"AND \"nfmadmin\".piping_comps.short_code    = \"nfmadmin\".piping_comp_type.comp_shcode ",
"AND \"nfmadmin\".piping_dynamic.spec_name   = \"nfmadmin\".piping_spec.spec_name ",
"AND \"nfmadmin\".piping_spec.spec_no        = \"nfmadmin\".piping_comps.spec_no ",
"AND \"nfmadmin\".piping_dynamic.comp_code   = \"nfmadmin\".piping_comps.comp_code ",
"AND npdg.npd BETWEEN \"nfmadmin\".piping_comps.size_g_low AND \"nfmadmin\".piping_comps.size_g_high ",
"AND npdr.npd BETWEEN \"nfmadmin\".piping_comps.size_r_low AND \"nfmadmin\".piping_comps.size_r_high ",
"AND \"nfmadmin\".piping_dynamic.opt_code    = \"nfmadmin\".piping_comps.opt_code ",
"AND \"nfmadmin\".piping_dynamic.no_mto_flag = ' ' ",
"AND (sha.list_num = 1510       AND sha.code_num = \"nfmadmin\".piping_dynamic.chg_no) ",
"AND (pdg.list_num =  330       AND pdg.code_num = \"nfmadmin\".piping_comps.prep_g) ",
"AND (pdr.list_num =  330       AND pdr.code_num = \"nfmadmin\".piping_comps.prep_r) ",
"AND (npdg.tblno                = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdg.npd_equiv             = \"nfmadmin\".piping_dynamic.npd_g) ",
"AND (npdr.tblno                = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdr.npd_equiv             = \"nfmadmin\".piping_dynamic.npd_r) ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"OUTER (\"nfmadmin\".piping_codelist sha), ",
"OUTER (\"nfmadmin\".piping_codelist pdg), ",
"OUTER (\"nfmadmin\".piping_codelist pdr), ",
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_npd_allowed npdg, ",
"\"nfmadmin\".piping_npd_allowed npdr, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPW query ###################################
        LET s_stmt =
"sha.long_txt, ",
"pdg.long_txt, ",
"pdr.long_txt, ",
"\"nfmadmin\".piping_comps.family_name, ",
"\"nfmadmin\".piping_comps.part_no_prfx, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.prep_r, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_comps.short_code, ",
"\"nfmadmin\".piping_comps.spec_no, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comp_type.comp_numcp, ",
"\"nfmadmin\".piping_dynamic.bend_sweep, ",
"\"nfmadmin\".piping_dynamic.chg_no, ",
"\"nfmadmin\".piping_dynamic.comp_seqno, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"\"nfmadmin\".piping_dynamic.insul_thk, ",
"\"nfmadmin\".piping_dynamic.loc_x, ",
"\"nfmadmin\".piping_dynamic.loc_y, ",
"\"nfmadmin\".piping_dynamic.loc_z, ",
"npdg.npd, ",
"npdr.npd, ",
"\"nfmadmin\".piping_dynamic.pipe_length, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.spec_grav, ",
"\"nfmadmin\".piping_dynamic.weight_grp"

        CASE drawing_flag
           WHEN 0 LET f_stmt = f_reg CLIPPED
           WHEN 1 LET f_stmt = "\"nfmadmin\".piping_cit, ", f_reg CLIPPED
        END CASE

        LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

        LET o_stmt =
"\"nfmadmin\".piping_dynamic.chg_no, ",
"\"nfmadmin\".piping_dynamic.weight_grp, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"npdg.npd, ",
"npdr.npd"

   END CASE

   CALL RPTquery ( 0, 1)

#DISPLAY "Query for Piping Weight Report: ", q_stmt CLIPPED
#DISPLAY "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

END FUNCTION

FUNCTION PPWpost_query ()
  DEFINE f_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       pdm_part_num     LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE f_attr RECORD arg1             CHAR(10),
                       arg2             CHAR(10),
                       arg3             CHAR(10),
                       arg4             CHAR(10),
                       arg5             CHAR(10),
                       arg6             CHAR(10)
                END RECORD
  DEFINE f_args RECORD dry_wt           FLOAT,
                       wet_wt           FLOAT,
                       surf_area        FLOAT,
                       arg1             FLOAT,
                       arg2             FLOAT,
                       arg3             FLOAT,
                       arg4             FLOAT,
                       arg5             FLOAT,
                       arg6             FLOAT
                END RECORD
  DEFINE f_star RECORD dry_wgt          CHAR(1),
                       wet_wgt          CHAR(1),
                       ins_wgt          CHAR(1),
                       tot_wgt          CHAR(1)
                END RECORD
  DEFINE query_str      CHAR(300),
         tmp_npd_r      FLOAT

      LET f_args.dry_wt    = 0.0
      LET f_args.wet_wt    = 0.0
      LET f_args.surf_area = 0.0
      LET f_args.arg1      = 0.0
      LET f_args.arg2      = 0.0
      LET f_args.arg3      = 0.0
      LET f_args.arg4      = 0.0
      LET f_args.arg5      = 0.0
      LET f_args.arg6      = 0.0
      LET f_star.dry_wgt = " "
      LET f_star.wet_wgt = " "
      LET f_star.ins_wgt = " "
      LET f_star.tot_wgt = " "

      LET f_calc.sch_thk_tmp_g = p_ppw.sch_thk_g
      LET f_calc.sch_thk_tmp_r = p_ppw.sch_thk_r

#            DISPLAY "family_name = ", p_ppw.family_name CLIPPED
#            DISPLAY "part_no_prfx = ", p_ppw.part_no_prfx CLIPPED
#            DISPLAY "size_g = ", p_ppw.npd_g CLIPPED
#            DISPLAY "size_r = ", p_ppw.npd_r CLIPPED
#            DISPLAY "sch_thk_g = ", p_ppw.sch_thk_g CLIPPED
#            DISPLAY "sch_thk_r = ", p_ppw.sch_thk_r CLIPPED

      IF  p_ppw.sch_thk_ovr IS NOT NULL
      AND p_ppw.sch_thk_ovr != " "
      AND p_ppw.sch_thk_ovr != "" THEN
         IF  f_calc.sch_thk_tmp_g IS NOT NULL
         AND f_calc.sch_thk_tmp_g != ""
         AND f_calc.sch_thk_tmp_g != " "
         AND p_ppw.sch_thk_ovr   != "NREQD" THEN
             LET f_calc.sch_thk_tmp_g = p_ppw.sch_thk_ovr
         ELSE
             LET f_calc.sch_thk_tmp_r = p_ppw.sch_thk_ovr
         END IF
      END IF

      IF f_calc.sch_thk_tmp_g = "CALC" THEN LET f_star.dry_wgt = "*"
      ELSE                                  LET f_star.dry_wgt = " "
      END IF

      IF f_calc.sch_thk_tmp_g = "NREQD" THEN LET f_calc.sch_thk_tmp_g = " "
      END IF

      IF f_calc.sch_thk_tmp_r = "NREQD" THEN LET f_calc.sch_thk_tmp_r = " "
      END IF

      IF f_calc.sch_thk_tmp_g = "MATCH" THEN
         SELECT unique sch_thk_g
         INTO  f_calc.sch_thk_tmp_g
         FROM  piping_comps
         WHERE spec_no      = p_ppw.spec_no
         AND   comp_code    = "PIPING"
         AND   p_ppw.npd_g BETWEEN size_g_low AND size_g_high
         AND   opt_code     = 1
      END IF

      IF f_calc.sch_thk_tmp_r = "MATCH" THEN

         IF p_ppw.npd_r = 0.0 THEN LET tmp_npd_r = p_ppw.npd_g
         ELSE                      LET tmp_npd_r = p_ppw.npd_r
         END IF

         SELECT unique sch_thk_g
         INTO  f_calc.sch_thk_tmp_r
         FROM  piping_comps
         WHERE spec_no      = p_ppw.spec_no
         AND   comp_code    = "PIPING"
         AND   tmp_npd_r BETWEEN size_g_low AND size_g_high
         AND   opt_code     = 1
      END IF

   IF f_calc.sch_thk_tmp_r IS NULL OR f_calc.sch_thk_tmp_r = "" THEN
      SELECT unique pdm_part_num
      INTO f_calc.pdm_part_num
      FROM "nfmadmin".piping_commod_code
      WHERE si_comm_code = p_ppw.part_no_prfx
      AND   size_g       = p_ppw.npd_g
      AND   size_r       = p_ppw.npd_r
      AND   sch_thk_g    = f_calc.sch_thk_tmp_g
   ELSE
      SELECT unique pdm_part_num
      INTO f_calc.pdm_part_num
      FROM "nfmadmin".piping_commod_code
      WHERE si_comm_code = p_ppw.part_no_prfx
      AND   size_g       = p_ppw.npd_g
      AND   size_r       = p_ppw.npd_r
      AND   sch_thk_g    = f_calc.sch_thk_tmp_g
      AND   sch_thk_r    = f_calc.sch_thk_tmp_r
   END IF
      IF STATUS = NOTFOUND THEN
        SELECT unique pdm_part_num
        INTO f_calc.pdm_part_num
        FROM "nfmadmin".piping_commod_code
        WHERE si_comm_code = p_ppw.part_no_prfx
        AND   size_g       = p_ppw.npd_g
        AND   size_r       = p_ppw.npd_r
        AND   sch_thk_g    = p_ppw.sch_thk_g
        AND   sch_thk_r    = p_ppw.sch_thk_r

        LET f_star.dry_wgt = "*"
        LET f_star.wet_wgt = "*"
        LET f_star.ins_wgt = "*"
        LET f_star.tot_wgt = "*"
      END IF
#            DISPLAY "n_itemname   = ", f_calc.pdm_part_num CLIPPED

      CASE p_ppw.comp_cat
         WHEN 0
            LET f_attr.arg1 = "pod1"
            LET f_attr.arg2 = "pod1"
            LET f_attr.arg3 = "pod1"
            LET f_attr.arg4 = "pod1"
            LET f_attr.arg5 = "pod1"
            LET f_attr.arg6 = "pod1"
         WHEN 12
            LET f_attr.arg1 = "br"
            LET f_attr.arg2 = "dim_1"
            LET f_attr.arg3 = "dim_2"
            LET f_attr.arg4 = "pod1"
            LET f_attr.arg5 = "pod2"
            LET f_attr.arg6 = "br"
         OTHERWISE
            CASE p_ppw.comp_numcp
               WHEN 1
                  LET f_attr.arg1 = "fc1"
                  LET f_attr.arg2 = "b1"
                  LET f_attr.arg3 = "fc1"
                  LET f_attr.arg4 = "b1"
                  LET f_attr.arg5 = "fc1"
                  LET f_attr.arg6 = "b1"
               WHEN 2
                  LET f_attr.arg1 = "fc1"
                  LET f_attr.arg2 = "b1"
                  LET f_attr.arg3 = "fc2"
                  LET f_attr.arg4 = "b2"
                  LET f_attr.arg5 = "fc1"
                  LET f_attr.arg6 = "b1"
               OTHERWISE
                  LET f_attr.arg1 = "fc1"
                  LET f_attr.arg2 = "b1"
                  LET f_attr.arg3 = "fc2"
                  LET f_attr.arg4 = "b2"
                  LET f_attr.arg5 = "fc3"
                  LET f_attr.arg6 = "b3"
            END CASE
      END CASE

      LET query_str = "SELECT dry_wt, wet_wt, surf_area, ",
                      f_attr.arg1 CLIPPED, ", ",
                      f_attr.arg2 CLIPPED, ", ",
                      f_attr.arg3 CLIPPED, ", ",
                      f_attr.arg4 CLIPPED, ", ",
                      f_attr.arg5 CLIPPED, ", ",
                      f_attr.arg6 CLIPPED,
                      " FROM \"nfmadmin\".", p_ppw.family_name CLIPPED,
                      " WHERE n_itemname = \'", f_calc.pdm_part_num CLIPPED, "\'"

  RETURN f_calc.*, f_attr.*, f_args.*, f_star.*, query_str
END FUNCTION

FUNCTION PPWconvert ( f_calc, f_attr, f_args)
  DEFINE f_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       pdm_part_num     LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE f_attr RECORD arg1             CHAR(10),
                       arg2             CHAR(10),
                       arg3             CHAR(10),
                       arg4             CHAR(10),
                       arg5             CHAR(10),
                       arg6             CHAR(10)
                END RECORD
  DEFINE f_args RECORD dry_wt           FLOAT,
                       wet_wt          	FLOAT,
                       surf_area       	FLOAT,
                       arg1            	FLOAT,
                       arg2            	FLOAT,
                       arg3            	FLOAT,
                       arg4            	FLOAT,
                       arg5            	FLOAT,
                       arg6            	FLOAT
                END RECORD
  DEFINE	hardcode	SMALLINT

            IF p_ppw.comp_cat = 0 OR p_ppw.comp_cat = 12 THEN
               IF p_vds.prj_units_set = 1 THEN LET hardcode = 851
               ELSE                            LET hardcode = 861
               END IF
               CALL ROUTEunits_convert ( "dry_uwt",
					 p_ppw.family_name,
                                         f_calc.pdm_part_num,
                                         f_args.dry_wt,
                                         hardcode ) RETURNING f_args.dry_wt
               CALL ROUTEunits_convert ( "wet_uwt",
					 p_ppw.family_name,
                                         f_calc.pdm_part_num,
                                         f_args.wet_wt,
                                         hardcode ) RETURNING f_args.wet_wt
            ELSE
               IF p_vds.prj_units_set = 1 THEN LET hardcode = 801
               ELSE                            LET hardcode = 811
               END IF
               CALL ROUTEunits_convert ( "dry_wt",
					 p_ppw.family_name,
                                         f_calc.pdm_part_num,
                                         f_args.dry_wt,
                                         hardcode ) RETURNING f_args.dry_wt
               CALL ROUTEunits_convert ( "wet_wt",
					 p_ppw.family_name,
                                         f_calc.pdm_part_num,
                                         f_args.wet_wt,
                                         hardcode ) RETURNING f_args.wet_wt
            END IF

            IF p_vds.prj_units_set = 1 THEN LET hardcode = 502
            ELSE                            LET hardcode = 513
            END IF
            CALL ROUTEunits_convert ( "surf_area",
				      p_ppw.family_name,
                                      f_calc.pdm_part_num,
                                      f_args.surf_area,
                                      hardcode ) RETURNING f_args.surf_area

            IF p_vds.prj_units_set = 1 THEN LET hardcode = 1
            ELSE                            LET hardcode = 11
            END IF
            CALL ROUTEunits_convert ( f_attr.arg1,
				      p_ppw.family_name,
                                      f_calc.pdm_part_num,
                                      f_args.arg1,
                                      hardcode ) RETURNING f_args.arg1
            CALL ROUTEunits_convert ( f_attr.arg2,
				      p_ppw.family_name,
                                      f_calc.pdm_part_num,
                                      f_args.arg2,
                                      hardcode ) RETURNING f_args.arg2
            CALL ROUTEunits_convert ( f_attr.arg3,
				      p_ppw.family_name,
                                      f_calc.pdm_part_num,
                                      f_args.arg3,
                                      hardcode ) RETURNING f_args.arg3
            CALL ROUTEunits_convert ( f_attr.arg4,
				      p_ppw.family_name,
                                      f_calc.pdm_part_num,
                                      f_args.arg4,
                                      hardcode ) RETURNING f_args.arg4
            CALL ROUTEunits_convert ( f_attr.arg5,
				      p_ppw.family_name,
                                      f_calc.pdm_part_num,
                                      f_args.arg5,
                                      hardcode ) RETURNING f_args.arg5
            CALL ROUTEunits_convert ( f_attr.arg6,
				      p_ppw.family_name,
                                      f_calc.pdm_part_num,
                                      f_args.arg6,
                                      hardcode ) RETURNING f_args.arg6

  RETURN f_args.*
END FUNCTION

FUNCTION PPWdescription ( f_calc, f_args, f_star)
  DEFINE f_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       pdm_part_num     LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE f_args RECORD dry_wt           FLOAT,
                       wet_wt          	FLOAT,
                       surf_area       	FLOAT,
                       arg1            	FLOAT,
                       arg2            	FLOAT,
                       arg3            	FLOAT,
                       arg4            	FLOAT,
                       arg5            	FLOAT,
                       arg6            	FLOAT
                END RECORD
  DEFINE f_star RECORD dry_wgt          CHAR(1),
                       wet_wgt          CHAR(1),
                       ins_wgt          CHAR(1),
                       tot_wgt          CHAR(1)
                END RECORD
  DEFINE PPWdesc     	CHAR(20),
         PPWdry_wgt  	FLOAT,
         PPWwet_wgt  	FLOAT,
         PPWins_wgt    	FLOAT,
         PPWtot_wgt	FLOAT,
         PPWvcg      	FLOAT,
         PPWlcg      	FLOAT,
         PPWtcg      	FLOAT,
         PPWvmom     	FLOAT,
         PPWlmom     	FLOAT,
         PPWtmom     	FLOAT
  DEFINE temp1		CHAR(20),
	 temp2		CHAR(20),
         short_num	CHAR(30),
         eq_length	FLOAT,
         wt1		FLOAT,
         wt2		FLOAT,
         wt3		FLOAT,
	 int_len	FLOAT,
	 ext_len	FLOAT,
	 ext_wgt	FLOAT

  CALL size_of_element ( p_ppw.npd_g, 0) RETURNING short_num
  LET temp1 = p_ppw.short_code CLIPPED, ",", short_num CLIPPED

  IF p_ppw.comp_code = "" OR p_ppw.comp_code = " " THEN
     LET PPWdesc    = "SPRT ", p_ppw.tag_number CLIPPED
     LET PPWdry_wgt = p_ppw.weight

     IF PPWdry_wgt <= 1.0 THEN LET f_star.dry_wgt = "*"
     END IF

     LET PPWwet_wgt = 0.0
     LET PPWins_wgt = 0.0

  ELSE
     IF p_ppw.short_code = "PIPE" THEN
        IF p_ppw.sch_thk_ovr IS NOT NULL AND p_ppw.sch_thk_ovr != " " THEN
           LET PPWdesc = temp1 CLIPPED, ",", p_ppw.sch_thk_ovr CLIPPED
        ELSE
           LET PPWdesc = temp1 CLIPPED, ",", p_ppw.sch_thk_g CLIPPED
        END IF
     ELSE
        CALL size_of_element ( p_ppw.npd_g, p_ppw.npd_r) RETURNING short_num
        LET temp2 = p_ppw.short_code CLIPPED, ",", short_num CLIPPED

        IF p_ppw.prep_r > 0.0 AND p_ppw.prep_r != p_ppw.prep_g THEN
           LET PPWdesc = temp2 CLIPPED, p_ppw.prep_desc_g CLIPPED,
                         "x", p_ppw.prep_desc_r CLIPPED
        ELSE
           LET PPWdesc = temp2 CLIPPED, p_ppw.prep_desc_g CLIPPED
        END IF
     END IF
  END IF

  IF p_vds.prj_units_set = 1 THEN
     LET int_len = 12.0		# IN/FT
     LET ext_len = 1.0		# FT/FT
     LET ext_wgt = 1.0		# LB/LB
  ELSE
     LET int_len = 1000.0	# MM/M
     LET ext_len = 0.3048	# M/FT
     LET ext_wgt = 0.454	# KG/LB
  END IF

  CASE p_ppw.comp_cat
     WHEN 0
        LET eq_length = p_ppw.pipe_length
           IF p_ppw.pipe_length * f_args.dry_wt < 1.0 THEN
              LET f_star.dry_wgt = "*"
           END IF
        LET eq_length = eq_length / int_len
     WHEN 12
        LET eq_length  = (f_args.arg2 + f_args.arg3) + (f_args.arg1 *
                         p_ppw.bend_sweep * 3.141592 / 180.0)
        LET eq_length = eq_length / int_len
     OTHERWISE
        LET eq_length  = 1.0
  END CASE

  LET PPWdry_wgt = eq_length * f_args.dry_wt

  IF PPWdry_wgt <= 0.0 THEN
     LET PPWdry_wgt = 0.0
     LET f_star.dry_wgt = "*"
  END IF

  IF PPWdry_wgt IS NULL OR PPWdry_wgt = "" OR PPWdry_wgt = " " THEN
     LET PPWdry_wgt = 0.0
  END IF
 
  IF p_ppw.spec_grav IS NULL OR p_ppw.spec_grav <= 0.0 THEN
     LET p_ppw.spec_grav = 1.0
     LET f_star.wet_wgt = "*"
  END IF

  LET PPWwet_wgt = eq_length * f_args.wet_wt * p_ppw.spec_grav

  IF PPWwet_wgt <= 0.0 AND p_ppw.comp_cat != 0 AND p_ppw.comp_cat != 12 THEN
     LET wt1 = f_args.arg2 * f_args.arg2 * f_args.arg1
     LET wt2 = f_args.arg4 * f_args.arg4 * f_args.arg3
     LET wt3 = f_args.arg6 * f_args.arg6 * f_args.arg5
     LET f_star.wet_wgt = "*"

     IF p_ppw.comp_numcp = 1 THEN LET PPWwet_wgt = wt1
     ELSE
        IF p_ppw.comp_numcp = 2 THEN LET PPWwet_wgt = wt1 + wt2
        ELSE                         LET PPWwet_wgt = wt1 + wt2 + wt3
        END IF
     END IF

     LET PPWwet_wgt = 3.141592 / 4.0  *
                      PPWwet_wgt      / int_len / int_len / int_len *
		      62.4            * ext_wgt / ext_len / ext_len / ext_len *
                      p_ppw.spec_grav
  ELSE IF PPWwet_wgt <= 0.0 AND (p_ppw.comp_cat = 0 OR p_ppw.comp_cat = 12) THEN
       LET PPWwet_wgt = f_args.arg2 * f_args.arg2 * eq_length
       LET PPWwet_wgt = 3.141592 / 4.0 * PPWwet_wgt / int_len / int_len
                   * 62.4 * ext_wgt / ext_len / ext_len * p_ppw.spec_grav
     END IF
  END IF

  IF PPWwet_wgt IS NULL OR PPWwet_wgt = "" OR PPWwet_wgt = " " THEN
     LET PPWwet_wgt = 0.0
  END IF

  LET PPWins_wgt = f_args.surf_area * 
                   eq_length        *
                   p_ppw.insul_thk  / int_len *
                   15.0 	    * ext_wgt / ext_len / ext_len / ext_len

  IF PPWins_wgt <= 0.0 AND p_ppw.comp_cat != 0 AND p_ppw.comp_cat != 12 THEN
     LET wt1 = f_args.arg2 * f_args.arg1 * p_ppw.insul_thk  
     LET wt2 = f_args.arg4 * f_args.arg3 * p_ppw.insul_thk  
     LET wt3 = f_args.arg6 * f_args.arg5 * p_ppw.insul_thk  
              

     IF p_ppw.comp_numcp = 1 THEN    LET PPWins_wgt = wt1
     ELSE
        IF p_ppw.comp_numcp = 2 THEN LET PPWins_wgt = wt1 + wt2
        ELSE 			     LET PPWins_wgt = wt1 + wt2 + wt3
        END IF
     END IF

     LET PPWins_wgt = 3.141592 * PPWins_wgt / int_len / int_len / int_len *
                      15.0 * ext_wgt / ext_len / ext_len /ext_len
  END IF

  IF PPWins_wgt IS NULL OR PPWins_wgt = "" OR PPWins_wgt = " " THEN
     LET PPWins_wgt = 0.0
  END IF

  LET PPWtot_wgt = PPWdry_wgt + PPWwet_wgt + PPWins_wgt
  IF PPWtot_wgt IS NULL OR PPWtot_wgt = "" OR PPWtot_wgt = " " THEN
     LET PPWtot_wgt = 0.0

  END IF

  LET PPWvcg      = p_ppw.loc_z / int_len - def_vcog
  IF PPWvcg IS NULL OR PPWvcg = "" OR PPWvcg = " " THEN
     LET PPWvcg = 0.0
  END IF

  LET PPWlcg      = p_ppw.loc_x / int_len - def_lcog
  IF PPWlcg IS NULL OR PPWlcg = "" OR PPWlcg = " " THEN
     LET PPWlcg = 0.0
  END IF

  LET PPWtcg      = p_ppw.loc_y / int_len - def_tcog
  IF PPWtcg IS NULL OR PPWtcg = "" OR PPWtcg = " " THEN
     LET PPWtcg = 0.0
  END IF

  LET PPWvmom     = PPWvcg * PPWtot_wgt
  IF PPWvmom IS NULL OR PPWvmom = "" OR PPWvmom = " " THEN
     LET PPWvmom = 0.0
  END IF

  LET PPWlmom     = PPWlcg * PPWtot_wgt
  IF PPWlmom IS NULL OR PPWlmom = "" OR PPWlmom = " " THEN
     LET PPWlmom = 0.0
  END IF

  LET PPWtmom     = PPWtcg * PPWtot_wgt
  IF PPWtmom IS NULL OR PPWtmom = "" OR PPWtmom = " " THEN
     LET PPWtmom = 0.0
  END IF

  RETURN PPWdesc, PPWdry_wgt, PPWwet_wgt, PPWins_wgt, PPWtot_wgt,
         PPWvcg, PPWlcg, PPWtcg, PPWvmom, PPWlmom, PPWtmom,
         f_star.dry_wgt, f_star.wet_wgt, f_star.ins_wgt, f_star.tot_wgt
END FUNCTION
