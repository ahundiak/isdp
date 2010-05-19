DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPNquery ()

  LET w_reg =
" AND \"nfmadmin\".piping_dynamic.comp_code   = \"nfmadmin\".piping_comp_type.comp_code ",
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

##########################  Create PPN query ###################################
  LET s_stmt =
"sha.long_txt, ",
"pdg.long_txt, ",
"pdr.long_txt, ",
"\"nfmadmin\".piping_comps.material, ",
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
"\"nfmadmin\".piping_dynamic.constr_stat, ",
"\"nfmadmin\".piping_dynamic.spec_name, ",
"\"nfmadmin\".piping_dynamic.bend_sweep, ",
"\"nfmadmin\".piping_dynamic.chg_no, ",
"\"nfmadmin\".piping_dynamic.comp_seqno, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"\"nfmadmin\".piping_dynamic.insul_thk, ",
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

   CALL RPTquery ( 0, 0)
END FUNCTION

FUNCTION PPNpost_query ()
  DEFINE f_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       pdm_part_num     LIKE "nfmadmin".piping_commod_code.pdm_part_num
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
  DEFINE query_str CHAR(300),
         tmp_npd_r FLOAT

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

      LET f_calc.sch_thk_tmp_g = p_ppn.sch_thk_g
      LET f_calc.sch_thk_tmp_r = p_ppn.sch_thk_r

      IF  p_ppn.sch_thk_ovr IS NOT NULL
      AND p_ppn.sch_thk_ovr != " "
      AND p_ppn.sch_thk_ovr != ""  THEN
        IF  f_calc.sch_thk_tmp_g IS NOT NULL
        AND f_calc.sch_thk_tmp_g != ""
        AND f_calc.sch_thk_tmp_g != " "
        AND p_ppn.sch_thk_ovr   != "NREQD"  THEN
          LET f_calc.sch_thk_tmp_g = p_ppn.sch_thk_ovr
        ELSE
          LET f_calc.sch_thk_tmp_r = p_ppn.sch_thk_ovr
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
        WHERE spec_no      = p_ppn.spec_no
        AND   comp_code    = "PIPING"
        AND   p_ppn.npd_g BETWEEN size_g_low AND size_g_high
        AND   opt_code     = 1
      END IF

      IF f_calc.sch_thk_tmp_r = "MATCH" THEN

        IF p_ppn.npd_r = 0.0 THEN LET tmp_npd_r = p_ppn.npd_g
        ELSE                       LET tmp_npd_r = p_ppn.npd_r
        END IF

        SELECT unique sch_thk_g
        INTO  f_calc.sch_thk_tmp_r
        FROM  "nfmadmin".piping_comps
        WHERE spec_no      = p_ppn.spec_no
        AND   comp_code    = "PIPING"
        AND   tmp_npd_r BETWEEN size_g_low AND size_g_high
        AND   opt_code     = 1
      END IF

      SELECT unique pdm_part_num
      INTO f_calc.pdm_part_num
      FROM "nfmadmin".piping_commod_code
      WHERE si_comm_code = p_ppn.part_no_prfx
      AND   size_g       = p_ppn.npd_g
      AND   size_r       = p_ppn.npd_r
      AND   sch_thk_g    = f_calc.sch_thk_tmp_g
      AND   sch_thk_r    = f_calc.sch_thk_tmp_r

      IF STATUS = NOTFOUND THEN
        SELECT unique pdm_part_num
        INTO f_calc.pdm_part_num
        FROM "nfmadmin".piping_commod_code
        WHERE si_comm_code = p_ppn.part_no_prfx
        AND   size_g       = p_ppn.npd_g
        AND   size_r       = p_ppn.npd_r
        AND   sch_thk_g    = p_ppn.sch_thk_g
        AND   sch_thk_r    = p_ppn.sch_thk_r

        LET f_star.dry_wgt = "*"
        LET f_star.wet_wgt = "*"
        LET f_star.ins_wgt = "*"
        LET f_star.tot_wgt = "*"
      END IF

      IF p_ppn.comp_cat = 0 THEN
        LET query_str =
          "SELECT dry_wt,wet_wt,surf_area,pod1,pod1,pod1,pod1,pod1,pod1 FROM \"nfmadmin\".",
          p_ppn.family_name CLIPPED,
          " WHERE n_itemname = \"", f_calc.pdm_part_num CLIPPED, "\""
      ELSE
        IF p_ppn.comp_cat = 12 THEN
          LET query_str =
            "SELECT dry_wt,wet_wt,surf_area,br,dim_1,dim_2,br,br,br FROM \"nfmadmin\".",
            p_ppn.family_name CLIPPED,
            " WHERE n_itemname = \"", f_calc.pdm_part_num CLIPPED, "\""
        ELSE
          IF p_ppn.comp_numcp = 1 THEN
            LET query_str =
              "SELECT dry_wt,wet_wt,surf_area,fc1,b1,fc1,b1,fc1,b1 FROM \"nfmadmin\".",
              p_ppn.family_name CLIPPED,
              " WHERE n_itemname = \"", f_calc.pdm_part_num CLIPPED, "\""
          ELSE
            IF p_ppn.comp_numcp = 2 THEN
              LET query_str =
                "SELECT dry_wt,wet_wt,surf_area,fc1,b1,fc2,b2,fc1,b1 FROM \"nfmadmin\".",
                p_ppn.family_name CLIPPED,
                " WHERE n_itemname = \"", f_calc.pdm_part_num CLIPPED, "\""
            ELSE
              LET query_str =
                "SELECT dry_wt,wet_wt,surf_area,fc1,b1,fc2,b2,fc3,b3 FROM \"nfmadmin\".",
                p_ppn.family_name CLIPPED,
                " WHERE n_itemname = \"", f_calc.pdm_part_num CLIPPED, "\""
            END IF
          END IF
        END IF
      END IF

  RETURN f_calc.*, f_args.*, f_star.*, query_str

END FUNCTION

FUNCTION PPNdescription ( f_calc, f_args, f_star)
  DEFINE f_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       pdm_part_num     LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE f_args RECORD dry_wt          FLOAT,
                       wet_wt          FLOAT,
                       surf_area       FLOAT,
                       arg1            FLOAT,
                       arg2            FLOAT,
                       arg3            FLOAT,
                       arg4            FLOAT,
                       arg5            FLOAT,
                       arg6            FLOAT
                END RECORD
  DEFINE f_star RECORD dry_wgt          CHAR(1),
                       wet_wgt          CHAR(1),
                       ins_wgt          CHAR(1),
                       tot_wgt          CHAR(1)
                END RECORD
  DEFINE PPNdesc     	CHAR(30),
         PPNdry_wgt  	FLOAT,
         PPNwet_wgt  	FLOAT,
         PPNins_wgt    	FLOAT,
         PPNtot_wgt	FLOAT
  DEFINE temp1		CHAR(30),
	 temp2		CHAR(30),
         short_num	CHAR(10),
         eq_length	FLOAT,
         wt1		FLOAT,
         wt2		FLOAT,
         wt3		FLOAT

  CALL tzero(p_ppn.npd_g) RETURNING short_num
  LET temp1 = p_ppn.short_code CLIPPED, ",", short_num CLIPPED

  IF p_ppn.comp_code = "" OR p_ppn.comp_code = " " THEN
     LET PPNdesc    = "SPRT ", p_ppn.tag_number CLIPPED
     LET PPNdry_wgt = p_ppn.weight

    IF PPNdry_wgt <= 1.0 THEN LET f_star.dry_wgt = "*"
    END IF

    LET PPNwet_wgt = 0.0
    LET PPNins_wgt = 0.0

  ELSE
    IF p_ppn.short_code = "PIPE" THEN
       IF p_ppn.sch_thk_ovr IS NOT NULL AND p_ppn.sch_thk_ovr != " " THEN
          LET PPNdesc = temp1 CLIPPED, "\",", p_ppn.sch_thk_ovr CLIPPED
       ELSE
          LET PPNdesc = temp1 CLIPPED, "\",", p_ppn.sch_thk_g CLIPPED
       END IF
    ELSE
      IF p_ppn.npd_r > 0.0 AND p_ppn.npd_r != p_ppn.npd_g THEN
         CALL tzero(p_ppn.npd_r) RETURNING short_num
         LET temp2 = temp1 CLIPPED, "x", short_num CLIPPED, "\","
      ELSE
         LET temp2 = temp1 CLIPPED, "\","
      END IF

      IF p_ppn.prep_r > 0.0 AND p_ppn.prep_r != p_ppn.prep_g THEN
         LET PPNdesc = temp2 CLIPPED, p_ppn.prep_desc_g CLIPPED,
                       "x", p_ppn.prep_desc_r CLIPPED
      ELSE
         LET PPNdesc = temp2 CLIPPED, p_ppn.prep_desc_g CLIPPED
      END IF
    END IF
  END IF


  IF p_ppn.comp_cat = 0 THEN
     LET eq_length = p_ppn.pipe_length / 12.0
     IF p_ppn.pipe_length * f_args.dry_wt < 1.0 THEN
       LET f_star.dry_wgt = "*"
     END IF
  ELSE
    IF p_ppn.comp_cat = 12 THEN
       LET eq_length = ( f_args.arg1 * p_ppn.bend_sweep * 3.141592 / 180.0 +
		         f_args.arg2 + f_args.arg3 ) / 12.0
    ELSE
       LET eq_length = 1.0
    END IF
  END IF

  LET PPNdry_wgt  = eq_length * f_args.dry_wt
 
  IF PPNdry_wgt <= 0.0 THEN
     LET PPNdry_wgt = 0.0
     LET f_star.dry_wgt = "*"
  END IF

  IF PPNdry_wgt IS NULL OR PPNdry_wgt = "" OR PPNdry_wgt = " " THEN
     LET PPNdry_wgt = 0.0
  END IF
 
  IF p_ppn.spec_grav IS NULL OR p_ppn.spec_grav <= 0.0 THEN
     LET p_ppn.spec_grav = 1.0
     LET f_star.wet_wgt = "*"
  END IF

  LET PPNwet_wgt  = eq_length * f_args.wet_wt * p_ppn.spec_grav

  IF PPNwet_wgt <= 0.0 AND p_ppn.comp_cat != 0 AND p_ppn.comp_cat != 12 THEN
     LET wt1 = 3.141592 / 4.0 * 
               f_args.arg2    * 
               f_args.arg2    * 
               f_args.arg1    * 
               62.4           * 
               p_ppn.spec_grav / 1728.0
     LET wt2 = 3.141592 / 4.0 * 
               f_args.arg4    * 
               f_args.arg4    * 
               f_args.arg3    * 
               62.4           * 
               p_ppn.spec_grav / 1728.0
     LET wt3 = 3.141592 / 4.0 * 
               f_args.arg6    * 
               f_args.arg6    * 
               f_args.arg5    * 
               62.4           * 
               p_ppn.spec_grav / 1728.0
     LET f_star.wet_wgt = "*"

     IF p_ppn.comp_numcp = 1 THEN LET PPNwet_wgt = wt1
     ELSE
        IF p_ppn.comp_numcp = 2 THEN LET PPNwet_wgt = wt1 + wt2
        ELSE                          LET PPNwet_wgt = wt1 + wt2 + wt3
        END IF
     END IF
  END IF
  IF PPNwet_wgt IS NULL OR PPNwet_wgt = "" OR PPNwet_wgt = " " THEN
     LET PPNwet_wgt = 0.0
  END IF

  LET PPNins_wgt  = f_args.surf_area * 
                    eq_length        * 
                    p_ppn.insul_thk * 
                    15.0 / 1728.0

  IF PPNins_wgt <= 0.0 AND p_ppn.comp_cat != 0 AND p_ppn.comp_cat != 12 THEN
     LET wt1 = 3.141592         * 
               f_args.arg2      *
               f_args.arg1      * 
               p_ppn.insul_thk * 
               15.0 / 1728.0
     LET wt2 = 3.141592         * 
               f_args.arg4      * 
               f_args.arg3      * 
               p_ppn.insul_thk * 
               15.0 / 1728.0
     LET wt3 = 3.141592         * 
               f_args.arg6      * 
               f_args.arg5      * 
               p_ppn.insul_thk * 
               15.0 / 1728.0
     IF p_ppn.comp_numcp = 1 THEN
        LET PPNins_wgt = wt1
     ELSE
        IF p_ppn.comp_numcp = 2 THEN
           LET PPNins_wgt = wt1 + wt2
        ELSE
           LET PPNins_wgt = wt1 + wt2 + wt3
        END IF
     END IF
  END IF
  IF PPNins_wgt IS NULL OR PPNins_wgt = "" OR PPNins_wgt = " " THEN
     LET PPNins_wgt = 0.0
  END IF

  LET PPNtot_wgt = PPNdry_wgt + PPNwet_wgt + PPNins_wgt
  IF PPNtot_wgt IS NULL OR PPNtot_wgt = "" OR PPNtot_wgt = " " THEN
     LET PPNtot_wgt = 0.0
  END IF

  RETURN PPNdesc, PPNdry_wgt, PPNwet_wgt, PPNins_wgt, PPNtot_wgt,
         f_star.dry_wgt, f_star.wet_wgt, f_star.ins_wgt, f_star.tot_wgt
END FUNCTION


FUNCTION tzero (number)
  DEFINE number FLOAT,
         i_val  INTEGER,
         s_num  CHAR(6)

  LET i_val = number / 1

  IF number - i_val = 0.0 THEN LET s_num = i_val USING "<<<<<<"
  ELSE                         LET s_num = number USING "<<<.<<" END IF

  RETURN s_num
END FUNCTION
