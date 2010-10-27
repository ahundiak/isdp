DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVWmain ()
  DEFINE p_calc RECORD comp_wt_star	CHAR(1),
		       insul_star	CHAR(1)
                END RECORD

  CALL ERRORLOG ("Enter in  Hvac Weight report")
  MESSAGE "Hvac Weight report in progress... please wait"

  START REPORT HVWform TO "HVWform"
    OUTPUT TO REPORT HVWform ()
  FINISH REPORT HVWform

  CALL HVWquery ()
  PREPARE hvw_stmt FROM q_stmt
  DECLARE hvw_curs CURSOR FOR hvw_stmt

  START REPORT HVWmaterial TO PIPE "HVW.sh"
     FOREACH hvw_curs INTO p_hvw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in main query")
           MESSAGE "No rows found in main query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL HVWstar (p_calc.*)
	        RETURNING p_calc.comp_wt_star, p_calc.insul_star
           OUTPUT TO REPORT HVWmaterial ( p_calc.*, p_hvw.weight_grp)
        END IF
     END FOREACH
  FINISH REPORT HVWmaterial

  MESSAGE "Hvac Weight report completed"
  CALL ERRORLOG ("Exit from Hvac Weight report")
END FUNCTION



REPORT HVWform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "================================="
      PRINT COLUMN 20, "| HVAC WEIGHT CONTROL WORKSHEET |"
      PRINT COLUMN 20, "================================="
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
            COLUMN 21, "[", COLUMN 23, p_hv.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_hv.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_hv.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_hv.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_hv.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_hv.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_hv.constr_stat CLIPPED, COLUMN 32, "]"
      SKIP 1 LINE
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


REPORT HVWmaterial ( r_calc, p_4gl)
  DEFINE r_calc RECORD comp_wt_star	CHAR(1),
		       insul_star	CHAR(1)
                END RECORD
  DEFINE p_4gl RECORD weight_grp LIKE "nfmadmin".hvac_dynamic.weight_grp END RECORD 
  DEFINE HVWdesc	CHAR(40),
	 HVWww	FLOAT,
	 HVWiw	FLOAT,
	 HVWtw	FLOAT,
	 HVWvcg   	FLOAT,
	 HVWlcg   	FLOAT,
	 HVWtcg   	FLOAT,
	 HVWvmom   	FLOAT,
	 HVWlmom   	FLOAT,
	 HVWtmom   	FLOAT

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce  = 0
      LET g_wgt = 0.0
      LET g_vmm      = 0.0
      LET g_lmm      = 0.0
      LET g_tmm      = 0.0
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 59 , "H V A C",
            COLUMN 108, "Page - 1"
      PRINT COLUMN 48 , "W E I G H T     C O N T R O L"
      PRINT COLUMN 54 , "W O R K S H E E T"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      PRINT COLUMN 38 , "COMP WT",
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
      PRINT COLUMN 1  , "SHIP ALT #: ", p_hvw.ship_alt CLIPPED,
      	    COLUMN 31 , "WT GROUP #: ", p_hvw.weight_grp USING "&&&"
      SKIP 1 LINE

    ON EVERY ROW
      CALL HVWdescription () RETURNING HVWdesc, 
		                       HVWww, HVWiw, HVWtw,
		                       HVWvcg, HVWlcg, HVWtcg,
		                       HVWvmom, HVWlmom, HVWtmom
      LET g_pce = g_pce + 1
      LET g_wgt = g_wgt + HVWtw
      LET g_vmm = g_vmm + HVWvmom
      LET g_lmm = g_lmm + HVWlmom
      LET g_tmm = g_tmm + HVWtmom
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , p_hvw.comp_seqno USING "<<<<<",
	       COLUMN 7  , HVWdesc CLIPPED,
               COLUMN 38 , HVWww USING "####&.&", r_calc.comp_wt_star CLIPPED,
	       COLUMN 47 , HVWiw USING "####&.&", r_calc.insul_star CLIPPED,
	       COLUMN 56 , HVWtw USING "####&.&",
	       COLUMN 64 , HVWvcg USING "----&.&",
	       COLUMN 72 , HVWlcg USING "----&.&",
	       COLUMN 80 , HVWtcg USING "----&.&",
	       COLUMN 88 , HVWvmom USING "----------&.&",
	       COLUMN 102, HVWlmom USING "----------&.&",
	       COLUMN 116, HVWtmom USING "----------&.&"
      ELSE
         PRINT COLUMN 1  , p_hvw.comp_seqno USING "<<<<<",
	       COLUMN 7  , HVWdesc CLIPPED,
               COLUMN 38 , HVWww USING "####&.&", r_calc.comp_wt_star CLIPPED,
	       COLUMN 47 , HVWiw USING "####&.&", r_calc.insul_star CLIPPED,
	       COLUMN 56 , HVWtw USING "####&.&",
	       COLUMN 64 , HVWvcg USING "---&.&&",
	       COLUMN 72 , HVWlcg USING "---&.&&",
	       COLUMN 80 , HVWtcg USING "---&.&&",
	       COLUMN 88 , HVWvmom USING "----------&.&",
	       COLUMN 102, HVWlmom USING "----------&.&",
	       COLUMN 116, HVWtmom USING "----------&.&"
      END IF

      on last row
      SKIP 2 LINES
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "================================================"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 32,  g_wgt USING "GRAND TOTAL WEIGHT: ######&.& LB",
               COLUMN 71,  g_vmm / g_wgt USING "VCG: ----&.& FT",
               COLUMN 90,  g_lmm / g_wgt USING "LCG: ----&.& FT",
               COLUMN 109, g_tmm / g_wgt USING "TCG: ----&.& FT"
      ELSE
         PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 32,  g_wgt USING "GRAND TOTAL WEIGHT: ######&.& KG",
               COLUMN 71,  g_vmm / g_wgt USING "VCG: ---&.&& M",
               COLUMN 90,  g_lmm / g_wgt USING "LCG: ---&.&& M",
               COLUMN 109, g_tmm / g_wgt USING "TCG: ---&.&& M"
      END IF
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "================================================"
END REPORT
