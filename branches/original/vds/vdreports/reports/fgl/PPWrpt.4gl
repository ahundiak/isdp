DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPWmain ()
  DEFINE p_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
  		       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
		       pdm_part_num	LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE p_attr RECORD arg1		CHAR(10),
		       arg2		CHAR(10),
		       arg3		CHAR(10),
		       arg4		CHAR(10),
		       arg5		CHAR(10),
		       arg6		CHAR(10)
                END RECORD
  DEFINE p_args RECORD dry_wt		FLOAT,
		       wet_wt		FLOAT,
		       surf_area	FLOAT,
		       arg1		FLOAT,
		       arg2		FLOAT,
		       arg3		FLOAT,
		       arg4		FLOAT,
		       arg5		FLOAT,
		       arg6		FLOAT
                END RECORD
  DEFINE p_star RECORD dry_wgt		CHAR(1),
		       wet_wgt		CHAR(1),
		       ins_wgt		CHAR(1),
		       tot_wgt		CHAR(1)
                END RECORD
  DEFINE query_str	CHAR(300)

  CALL update_piping_off()

  CALL ERRORLOG ("Enter in  Piping Weight report")
  MESSAGE "Piping Weight report in progress... please wait"

  START REPORT PPWform TO "PPWform"
    OUTPUT TO REPORT PPWform ()
  FINISH REPORT PPWform

  START REPORT PPWmaterial TO pipe "PPW.sh"

  CALL PPWquery ()
  PREPARE ppw_stmt1 FROM q_stmt
  DECLARE ppw_curs1 CURSOR FOR ppw_stmt1

  FOREACH ppw_curs1 INTO p_ppw.*
    IF STATUS < 0 THEN
      CALL ERRORLOG ("No rows found in main query")
      MESSAGE "No rows found in main query"
      SLEEP 3
      EXIT FOREACH
    ELSE

#            DISPLAY "family_name = ", p_ppw.family_name CLIPPED
#            DISPLAY "part_no_prfx = ", p_ppw.part_no_prfx CLIPPED
#            DISPLAY "size_g = ", p_ppw.npd_g CLIPPED
#            DISPLAY "size_r = ", p_ppw.npd_r CLIPPED
#            DISPLAY "sch_thk_g = ", p_ppw.sch_thk_g CLIPPED
#            DISPLAY "sch_thk_r = ", p_ppw.sch_thk_r CLIPPED

      CALL PPWpost_query ()
           RETURNING p_calc.*, p_attr.*, p_args.*, p_star.*, query_str

      PREPARE ppw_stmt2 FROM query_str
      DECLARE ppw_curs2 CURSOR FOR ppw_stmt2

      FOREACH ppw_curs2 INTO p_args.*
         IF STATUS < 0 THEN
            CALL ERRORLOG ("No rows found in secondary query")
            MESSAGE "No rows found in secondary query"
            SLEEP 3
            DISPLAY "family_name = ", p_ppw.family_name CLIPPED
            DISPLAY "n_itemname   = ", p_calc.pdm_part_num CLIPPED
            SLEEP 3
            EXIT FOREACH
         ELSE
            CALL PPWconvert ( p_calc.*, p_attr.*, p_args.*) RETURNING p_args.*
         END IF
      END FOREACH

      OUTPUT TO REPORT PPWmaterial ( p_ppw.weight_grp,
                                     p_calc.*,
                                     p_args.*,
                                     p_star.*)
    END IF
  END FOREACH
  FINISH REPORT PPWmaterial
  MESSAGE "Piping Weight report completed"
  CALL ERRORLOG ("Exit from Piping Weight report")
END FUNCTION



REPORT PPWform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE length 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "==================================="
      PRINT COLUMN 20, "| PIPING WEIGHT CONTROL WORKSHEET |"
      PRINT COLUMN 20, "==================================="
      SKIP 4 LINES
      PRINT COLUMN 1 , "PROJECT NO",
            COLUMN 20, "[", COLUMN 22, p_vds.prj_number, COLUMN 39, "]"
      PRINT COLUMN 1 , "PROJECT NAME",
            COLUMN 20, "[", COLUMN 22, p_vds.prj_name, COLUMN 63, "]"
      PRINT COLUMN 1 , "PROJECT LOCATION",
            COLUMN 20, "[", COLUMN 22, p_vds.prj_location, COLUMN 63, "]"
      SKIP 2 LINES
      PRINT COLUMN 1 , "REPORT DATE",
            COLUMN 20, "[", COLUMN 22, TODAY USING "mm-dd-yyyy", COLUMN 34, "]"
      PRINT COLUMN 1 , "REQUEST BY",
            COLUMN 20, "[", COLUMN 22, rpt_req, COLUMN 26, "]"
      PRINT COLUMN 1 , "DESCRIPTION",
            COLUMN 20, "[", COLUMN 22, rpt_dsc1, COLUMN 63, "]"
      PRINT COLUMN 20, "[", COLUMN 22, rpt_dsc2, COLUMN 63, "]"
      SKIP 4 LINES
      PRINT COLUMN 23, "REPORTING CRITERIA"
      PRINT COLUMN 23, "=================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_pp.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_pp.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_pp.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_pp.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_pp.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_pp.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_pp.constr_stat CLIPPED, COLUMN 32, "]"
      SKIP 3 LINES
      PRINT COLUMN 35, "REFERENCE COORDINATE"
      PRINT COLUMN 35, "===================="
      SKIP 1 LINE
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 34, "L [",
               COLUMN 38, def_lcog * 12.0 USING "-----&.&&&",
               COLUMN 49, "INCH ]"
         PRINT COLUMN 34, "T [",
               COLUMN 38, def_tcog * 12.0 USING "-----&.&&&",
               COLUMN 49, "INCH ]"
         PRINT COLUMN 34, "V [",
               COLUMN 38, def_vcog * 12.0 USING "-----&.&&&",
               COLUMN 49, "INCH ]"
      ELSE
         PRINT COLUMN 34, "L [",
               COLUMN 38, def_lcog * 1000.0 USING "-----&.&&&",
               COLUMN 49, "MM ]"
         PRINT COLUMN 34, "T [",
               COLUMN 38, def_tcog * 1000.0 USING "-----&.&&&",
               COLUMN 49, "MM ]"
         PRINT COLUMN 34, "V [",
               COLUMN 38, def_vcog * 1000.0 USING "-----&.&&&",
               COLUMN 49, "MM ]"
      END IF
END REPORT


REPORT PPWmaterial ( p_4gl, r_calc, r_args, r_star)
  DEFINE p_4gl RECORD weight_grp LIKE "nfmadmin".piping_dynamic.weight_grp END RECORD
  DEFINE r_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
  		       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
		       pdm_part_num	LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE r_args RECORD dry_wt           FLOAT,
		       wet_wt		FLOAT,
		       surf_area	FLOAT,
		       arg1		FLOAT,
		       arg2		FLOAT,
		       arg3		FLOAT,
		       arg4		FLOAT,
		       arg5		FLOAT,
		       arg6		FLOAT
                END RECORD
  DEFINE r_star RECORD dry_wgt		CHAR(1),
		       wet_wgt		CHAR(1),
		       ins_wgt		CHAR(1),
		       tot_wgt		CHAR(1)
                END RECORD
  DEFINE PPWdesc     CHAR(20),
	 PPWdry_wgt  FLOAT,
	 PPWwet_wgt  FLOAT,
	 PPWins_wgt  FLOAT,
	 PPWtot_wgt FLOAT,
	 PPWvcg      FLOAT,
	 PPWlcg      FLOAT,
	 PPWtcg      FLOAT,
	 PPWvmom     FLOAT,
	 PPWlmom     FLOAT,
	 PPWtmom     FLOAT

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE length 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce  = 0
      LET g_wgt = 0.0
      LET g_vmm = 0.0
      LET g_lmm = 0.0
      LET g_tmm = 0.0

      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 57 , "P I P I N G",
            COLUMN 120, "Page - 1"
      PRINT COLUMN 48 , "W E I G H T     C O N T R O L"
      PRINT COLUMN 54 , "W O R K S H E E T"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      PRINT COLUMN 29 , "DRY WGT",
            COLUMN 38 , "CONTENT",
            COLUMN 47 , "INSUL",
            COLUMN 55 , "TOTAL WT",
            COLUMN 65 , "VCG",
            COLUMN 73 , "LCG",
            COLUMN 81 , "TCG",
            COLUMN 88 , "VERT MOMENT",
            COLUMN 102, "LONG MOMENT",
            COLUMN 116, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 30 , "(LB)",
               COLUMN 39 , "(LB)",
               COLUMN 47 , "(LB)",
               COLUMN 57 , "(LB)",
               COLUMN 65 , "(FT)",
               COLUMN 73 , "(FT)",
               COLUMN 81 , "(FT)",
               COLUMN 90 , "(FT-LB)",
               COLUMN 104, "(FT-LB)",
               COLUMN 118, "(FT-LB)"
      ELSE
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 30 , "(KG)",
               COLUMN 39 , "(KG)",
               COLUMN 47 , "(KG)",
               COLUMN 57 , "(KG)",
               COLUMN 65 , "(M)",
               COLUMN 73 , "(M)",
               COLUMN 81 , "(M)",
               COLUMN 90 , "(KG-M)",
               COLUMN 104, "(KG-M)",
               COLUMN 118, "(KG-M)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"

    BEFORE GROUP OF p_4gl.weight_grp
      SKIP 1 LINE
      PRINT COLUMN 1  , "SHIP ALT #: ", p_ppw.ship_alt CLIPPED,
            COLUMN 31 , "WT GROUP #: ", p_ppw.weight_grp USING "&&&"
      SKIP 1 LINE

    ON EVERY ROW
      CALL PPWdescription ( r_calc.*, r_args.*, r_star.*) 
           RETURNING PPWdesc,
		     PPWdry_wgt,
		     PPWwet_wgt,
		     PPWins_wgt,
		     PPWtot_wgt,
		     PPWvcg,
		     PPWlcg,
		     PPWtcg,
		     PPWvmom,
		     PPWlmom,
		     PPWtmom,
                     r_star.dry_wgt,
                     r_star.wet_wgt,
                     r_star.ins_wgt,
                     r_star.tot_wgt

      LET g_pce = g_pce + 1
      LET g_wgt = g_wgt + PPWtot_wgt
      LET g_vmm = g_vmm + PPWvmom
      LET g_lmm = g_lmm + PPWlmom
      LET g_tmm = g_tmm + PPWtmom

      PRINT COLUMN 1 , g_pce USING "<<<<<"

      PRINT COLUMN 1  , p_ppw.comp_seqno USING "<<<<<",
	    COLUMN 7  , PPWdesc CLIPPED,
	    COLUMN 29 , PPWdry_wgt USING "----&.&", r_star.dry_wgt CLIPPED,
	    COLUMN 38 , PPWwet_wgt USING "----&.&", r_star.wet_wgt CLIPPED,
	    COLUMN 47 , PPWins_wgt USING "----&.&", r_star.ins_wgt CLIPPED,
	    COLUMN 56 , PPWtot_wgt USING "----&.&", r_star.tot_wgt CLIPPED,
	    COLUMN 64 , PPWvcg USING "---&.&",
	    COLUMN 72 , PPWlcg USING "---&.&",
	    COLUMN 80 , PPWtcg USING "---&.&",
	    COLUMN 88 , PPWvmom USING "----------&.&",
	    COLUMN 102, PPWlmom USING "----------&.&",
	    COLUMN 116, PPWtmom USING "----------&.&"

      ON LAST ROW
      SKIP 2 LINES
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "================================================"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,  g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 34, g_wgt USING "GRAND TOTAL WEIGHT: ######&.& LB",
               COLUMN 75, g_vmm / g_wgt USING "VCG: ----&.& FT",
               COLUMN 93, g_lmm / g_wgt USING "LCG: ----&.& FT",
               COLUMN 111, g_tmm / g_wgt USING "TCG: ----&.& FT"
      ELSE
         PRINT COLUMN 1,  g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 34, g_wgt USING "GRAND TOTAL WEIGHT: ######&.& KG",
               COLUMN 75, g_vmm / g_wgt USING "VCG: ----&.& M",
               COLUMN 93, g_lmm / g_wgt USING "LCG: ----&.& M",
               COLUMN 111, g_tmm / g_wgt USING "TCG: ----&.& M"
      END IF
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "================================================"
END REPORT
