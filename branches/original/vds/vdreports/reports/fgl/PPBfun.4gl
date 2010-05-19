DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPBquery ()
  CALL PPunits_set ("npd_g") RETURNING eq_unit_flag

  CASE eq_unit_flag
     WHEN 0

        LET w_reg =
" AND \"nfmadmin\".piping_dynamic.comp_code    = \"nfmadmin\".piping_comp_type.comp_code ",
"AND \"nfmadmin\".piping_comps.short_code      = \"nfmadmin\".piping_comp_type.comp_shcode ",
"AND \"nfmadmin\".piping_dynamic.spec_name     = \"nfmadmin\".piping_spec.spec_name ",
"AND \"nfmadmin\".piping_spec.spec_no          = \"nfmadmin\".piping_comps.spec_no ",
"AND \"nfmadmin\".piping_dynamic.comp_code     = \"nfmadmin\".piping_comps.comp_code ",
"AND \"nfmadmin\".piping_dynamic.npd_g         BETWEEN  \"nfmadmin\".piping_comps.size_g_low ",
"                                 AND      \"nfmadmin\".piping_comps.size_g_high ",
"AND \"nfmadmin\".piping_dynamic.npd_r         BETWEEN  \"nfmadmin\".piping_comps.size_r_low ",
"                                 AND      \"nfmadmin\".piping_comps.size_r_high ",
"AND \"nfmadmin\".piping_dynamic.opt_code      = \"nfmadmin\".piping_comps.opt_code ",
"AND \"nfmadmin\".piping_dynamic.no_mto_flag   = ' ' ",
"AND (epd.list_num = 330 AND epd.code_num = \"nfmadmin\".piping_comps.prep_g) ",
"AND (mat.list_num = 145 AND mat.code_num = \"nfmadmin\".piping_comps.material) ",
"AND (gsd.list_num = 575 AND gsd.code_num = \"nfmadmin\".piping_comps.geom_std) ",
"AND (cad.list_num = 421 AND cad.code_num = \"nfmadmin\".piping_comp_type.comp_cat) ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"OUTER (\"nfmadmin\".piping_codelist epd), ",
"OUTER (\"nfmadmin\".piping_codelist mat), ",
"OUTER (\"nfmadmin\".piping_codelist gsd), ",
"OUTER (\"nfmadmin\".piping_codelist cad), ",
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPB query ###################################
        LET s_stmt =
"\"nfmadmin\".piping_dynamic.bend_sweep, ",
"\"nfmadmin\".piping_dynamic.npd_g, ",
"\"nfmadmin\".piping_dynamic.npd_r, ",
"SUM (\"nfmadmin\".piping_dynamic.pipe_length), ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comps.commodity, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"\"nfmadmin\".piping_comps.geom_std, ",
"\"nfmadmin\".piping_comps.material, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.prep_r, ",
"\"nfmadmin\".piping_comps.rating_g, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_comps.spec_no, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"epd.long_txt, ",
"mat.long_txt, ",
"gsd.long_txt, ",
"cad.long_txt, ",
"COUNT (*)"

        CASE drawing_flag
           WHEN 0 LET f_stmt = f_reg CLIPPED
           WHEN 1 LET f_stmt = "piping_cit, ", f_reg CLIPPED
        END CASE

        LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

        LET g_stmt =
"\"nfmadmin\".piping_comps.commodity, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.prep_r, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.bend_sweep, ",
"\"nfmadmin\".piping_dynamic.npd_g, ",
"\"nfmadmin\".piping_dynamic.npd_r, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"\"nfmadmin\".piping_comps.geom_std, ",
"\"nfmadmin\".piping_comps.material, ",
"\"nfmadmin\".piping_comps.rating_g, ",
"\"nfmadmin\".piping_comps.spec_no, ",
"epd.long_txt, ",
"mat.long_txt, ",
"gsd.long_txt, ",
"cad.long_txt"

        LET o_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comps.commodity, ",
"\"nfmadmin\".piping_dynamic.npd_g DESC, ",
"\"nfmadmin\".piping_dynamic.npd_r DESC, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr"

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
"AND (epd.list_num = 330 AND epd.code_num = \"nfmadmin\".piping_comps.prep_g) ",
"AND (mat.list_num = 145 AND mat.code_num = \"nfmadmin\".piping_comps.material) ",
"AND (gsd.list_num = 575 AND gsd.code_num = \"nfmadmin\".piping_comps.geom_std) ",
"AND (cad.list_num = 421 AND cad.code_num = \"nfmadmin\".piping_comp_type.comp_cat) ",
"AND (npdg.tblno                = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdg.npd_equiv             = \"nfmadmin\".piping_dynamic.npd_g) ",
"AND (npdr.tblno                = \"nfmadmin\".piping_spec.npd_tblno ",
"AND npdr.npd_equiv             = \"nfmadmin\".piping_dynamic.npd_r) ",
"AND \"nfmadmin\".piping_spec.prj_no = ", default_prj_no

        LET f_reg =
"OUTER (\"nfmadmin\".piping_codelist epd), ",
"OUTER (\"nfmadmin\".piping_codelist mat), ",
"OUTER (\"nfmadmin\".piping_codelist gsd), ",
"OUTER (\"nfmadmin\".piping_codelist cad), ",
"\"nfmadmin\".piping_comp_type, ",
"\"nfmadmin\".piping_comps, ",
"\"nfmadmin\".piping_dynamic, ",
"\"nfmadmin\".piping_npd_allowed npdg, ",
"\"nfmadmin\".piping_npd_allowed npdr, ",
"\"nfmadmin\".piping_spec"

##########################  Create PPB query ###################################
        LET s_stmt =
"\"nfmadmin\".piping_dynamic.bend_sweep, ",
"npdg.npd, ",
"npdr.npd, ",
"SUM (\"nfmadmin\".piping_dynamic.pipe_length), ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comps.commodity, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"\"nfmadmin\".piping_comps.geom_std, ",
"\"nfmadmin\".piping_comps.material, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.prep_r, ",
"\"nfmadmin\".piping_comps.rating_g, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_comps.spec_no, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"epd.long_txt, ",
"mat.long_txt, ",
"gsd.long_txt, ",
"cad.long_txt, ",
"COUNT (*)"

        CASE drawing_flag
           WHEN 0 LET f_stmt = f_reg CLIPPED
           WHEN 1 LET f_stmt = "\"nfmadmin\".piping_cit, ", f_reg CLIPPED
        END CASE

        LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

        LET g_stmt =
"\"nfmadmin\".piping_comps.commodity, ",
"\"nfmadmin\".piping_comps.prep_g, ",
"\"nfmadmin\".piping_comps.prep_r, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr, ",
"\"nfmadmin\".piping_dynamic.bend_sweep, ",
"npdg.npd, ",
"npdr.npd, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comps.comp_code, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comp_type.comp_descr, ",
"\"nfmadmin\".piping_comps.geom_std, ",
"\"nfmadmin\".piping_comps.material, ",
"\"nfmadmin\".piping_comps.rating_g, ",
"\"nfmadmin\".piping_comps.spec_no, ",
"epd.long_txt, ",
"mat.long_txt, ",
"gsd.long_txt, ",
"cad.long_txt"

        LET o_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_comp_type.comp_cat, ",
"\"nfmadmin\".piping_comps.commodity, ",
"npdg.npd DESC, ",
"npdr.npd DESC, ",
"\"nfmadmin\".piping_comps.sch_thk_g, ",
"\"nfmadmin\".piping_comps.sch_thk_r, ",
"\"nfmadmin\".piping_dynamic.sch_thk_ovr"

  END CASE

   CALL RPTquery ( 1, 1)
END FUNCTION

FUNCTION PPBpost_query ()

	DEFINE	tmp_npd_r	FLOAT

	IF p_ppb.sch_thk_g = "MATCH" THEN
           SELECT UNIQUE sch_thk_g
           INTO   p_ppb.sch_thk_g
           FROM   "nfmadmin".piping_comps
           WHERE  spec_no     = p_ppb.spec_no
           AND    comp_code   = "PIPING"
           AND    p_ppb.npd_g BETWEEN size_g_low AND size_g_high
           AND    opt_code    = 1
	END IF

	IF p_ppb.sch_thk_r = "MATCH" THEN
           IF p_ppb.npd_r = 0.0 THEN LET tmp_npd_r = p_ppb.npd_g
           ELSE                      LET tmp_npd_r = p_ppb.npd_r
           END IF

           SELECT UNIQUE sch_thk_g
           INTO   p_ppb.sch_thk_r
           FROM   "nfmadmin".piping_comps
           WHERE  spec_no   = p_ppb.spec_no
           AND    comp_code = "PIPING"
           AND    tmp_npd_r BETWEEN size_g_low AND size_g_high
           AND    opt_code  = 1
	END IF
END FUNCTION

FUNCTION PPBdescription ()

  DEFINE s_d		CHAR(20),
         r_s		CHAR(20),
         comma		CHAR(2),
         tri		CHAR(30)

  DEFINE desc_str	CHAR(240),
	 desc1		CHAR(40),
	 desc2		CHAR(37),
	 desc3		CHAR(37),
	 desc4		CHAR(37),
	 desc5		CHAR(37),
	 desc6		CHAR(37),
	 elem_size	CHAR(30),
         quantity	CHAR(13)
  DEFINE divider	INTEGER

  LET s_d   = p_ppb.comp_descr
  LET r_s   = ""
  LET comma = ""

  # DISPLAY "CHECK 1"
  # RATING_G == NULL OR BLANK
  IF p_ppb.rating_g IS NULL OR p_ppb.rating_g LIKE " %" THEN
    # SCH_THK_G == NULL, BLANK OR NREQD AND SCH_THK_R == NULL, BLANK OR NREQD
    IF  (p_ppb.sch_thk_g IS NULL    OR 
         p_ppb.sch_thk_g LIKE " %"  OR 
         p_ppb.sch_thk_g = "NREQD")
    AND (p_ppb.sch_thk_r IS NULL    OR 
         p_ppb.sch_thk_r LIKE " %"  OR 
         p_ppb.sch_thk_r = "NREQD") THEN
    ELSE
      LET comma = ","
      # SCH_THK_G == NULL, BLANK OR NREQD
      IF p_ppb.sch_thk_g IS NULL    OR
         p_ppb.sch_thk_g LIKE " %"  OR
         p_ppb.sch_thk_g = "NREQD" THEN
        # SCH_THK_OVR == NULL, BLANK
        IF p_ppb.sch_thk_ovr IS NULL OR p_ppb.sch_thk_ovr LIKE " %" THEN
           LET r_s = p_ppb.sch_thk_r CLIPPED
        ELSE
           LET r_s = p_ppb.sch_thk_ovr CLIPPED
        END IF
      ELSE 
        # SCH_THK_R == NULL, BLANK OR NREQD
        IF p_ppb.sch_thk_r IS NULL    OR
           p_ppb.sch_thk_r LIKE " %"  OR
           p_ppb.sch_thk_r = "NREQD" THEN
          # SCH_THK_OVR == NULL, BLANK
          IF p_ppb.sch_thk_ovr IS NULL OR p_ppb.sch_thk_ovr LIKE "  %" THEN
             LET r_s = p_ppb.sch_thk_g CLIPPED
          ELSE
             LET r_s = p_ppb.sch_thk_ovr CLIPPED
          END IF
        ELSE
          # SCH_THK_OVR == NULL, BLANK
          IF p_ppb.sch_thk_ovr IS NULL OR p_ppb.sch_thk_ovr LIKE " %" THEN
             LET r_s   = p_ppb.sch_thk_g CLIPPED, "x",
                         p_ppb.sch_thk_r CLIPPED
          ELSE
             LET r_s   = p_ppb.sch_thk_ovr CLIPPED, "x",
                         p_ppb.sch_thk_r CLIPPED
          END IF
        END IF
      END IF
    END IF
  ELSE
    LET r_s = p_ppb.rating_g
    LET comma = ","
  END IF

  # DISPLAY "CHECK 2"
  IF  (p_ppb.bend_sweep IS NOT NULL
  AND  p_ppb.bend_sweep != 45.0
  AND  p_ppb.bend_sweep != 90.0)
  AND (p_ppb.comp_cat = 1 OR p_ppb.comp_cat = 12) THEN
    LET tri = "TRIMMED TO ", p_ppb.bend_sweep USING "-<<&.&&", " DEG, "
  ELSE
    LET tri = ""
  END IF
 
  DISPLAY "."
  LET desc_str = s_d CLIPPED, ", ",
  		 r_s CLIPPED, comma,
  		 p_ppb.end_prep_desc CLIPPED, ", ",
  		 tri CLIPPED,
  		 p_ppb.material_desc CLIPPED, ", ",
  		 p_ppb.geom_std_desc CLIPPED

  # DISPLAY "CHECK 4"
  CALL element_desc ( desc_str, 1 + LENGTH(desc_str) )
       RETURNING desc1, desc2, desc3, desc4, desc5, desc6

  # DISPLAY "CHECK 5"
  CALL size_of_element ( p_ppb.npd_g, p_ppb.npd_r) RETURNING elem_size

  # DISPLAY "CHECK 6"
  IF p_ppb.comp_cat = 0 THEN
    LET divider = 16
    CALL element_length (p_ppb.pipe_length, divider) RETURNING quantity
  ELSE
    LET quantity = p_ppb.item_num USING "<<<<<"
  END IF

  # DISPLAY "CHECK 7"
  RETURN desc1, desc2, desc3, desc4, desc5, desc6, elem_size, quantity

  # DISPLAY "CHECK 8"
END FUNCTION
