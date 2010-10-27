DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION RWWmain ()

  CALL ERRORLOG ("Enter in  Rway Weight report")
  MESSAGE "Rway Weight report in progress... please wait"

  START REPORT RWWform TO "RWWform"
    OUTPUT TO REPORT RWWform ()
  FINISH REPORT RWWform

  CALL RWWquery ()
  PREPARE rww_stmt FROM q_stmt
  DECLARE rww_curs CURSOR FOR rww_stmt

  START REPORT RWWmaterial TO PIPE "RWW.sh"
     FOREACH rww_curs INTO p_rww.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in main query")
           MESSAGE "No rows found in main query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT RWWmaterial (p_rww.weight_grp)
        END IF
     END FOREACH
  FINISH REPORT RWWmaterial

  MESSAGE "Rway Weight report completed"
  CALL ERRORLOG ("Exit from Rway Weight report")
END FUNCTION



REPORT RWWform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "===================================="
      PRINT COLUMN 20, "| RACEWAY WEIGHT CONTROL WORKSHEET |"
      PRINT COLUMN 20, "===================================="
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
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_rw.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_rw.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_rw.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_rw.constr_stat CLIPPED, COLUMN 32, "]"
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


REPORT RWWmaterial (p_4gl)
  DEFINE p_4gl RECORD weight_grp LIKE "nfmadmin".rway_dynamic.weight_grp END RECORD
  DEFINE RWWdesc	CHAR(40),
	 RWWcom_wgt	FLOAT,
	 RWWadd_wgt	FLOAT,
	 RWWvcg   	FLOAT,
	 RWWlcg   	FLOAT,
	 RWWtcg   	FLOAT,
	 RWWvmom   	FLOAT,
	 RWWlmom   	FLOAT,
	 RWWtmom   	FLOAT

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0
      LET g_wgt = 0.0
      LET g_vmm = 0.0
      LET g_lmm = 0.0
      LET g_tmm = 0.0
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 56 , "R A C E W A Y",
            COLUMN 108, "Page - 1"
      PRINT COLUMN 48 , "W E I G H T     C O N T R O L"
      PRINT COLUMN 54 , "W O R K S H E E T"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"
      PRINT COLUMN 44 , "COMP WT",
            COLUMN 53 , "ADDN'L WT",
            COLUMN 64 , "VCG",
            COLUMN 72 , "LCG",
            COLUMN 80 , "TCG",
            COLUMN 88 , "VERT MOMENT",
            COLUMN 102, "LONG MOMENT",
            COLUMN 116, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 45 , "(LB)",
               COLUMN 55 , "(LB)",
               COLUMN 64 , "(FT)",
               COLUMN 72 , "(FT)",
               COLUMN 80 , "(FT)",
               COLUMN 90 , "(FT-LB)",
               COLUMN 104, "(FT-LB)",
               COLUMN 118, "(FT-LB)"
      ELSE
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 45 , "(KG)",
               COLUMN 55 , "(KG)",
               COLUMN 64 , "(M)",
               COLUMN 72 , "(M)",
               COLUMN 80 , "(M)",
               COLUMN 90 , "(KG-M)",
               COLUMN 104, "(KG-M)",
               COLUMN 118, "(KG-M)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "------------------------------------------------"

    BEFORE GROUP OF p_4gl.weight_grp
      SKIP 1 LINE
      PRINT COLUMN 1  , "SHIP ALT #: ", p_rww.ship_alt CLIPPED,
      	    COLUMN 31 , "WT GROUP #: ", p_rww.weight_grp USING "&&&"
      SKIP 1 LINE

    ON EVERY ROW
      CALL RWWdescription () RETURNING RWWdesc, 
		     		       RWWcom_wgt, RWWadd_wgt,
		     		       RWWvcg, RWWlcg, RWWtcg,
		     		       RWWvmom, RWWlmom, RWWtmom
      LET g_pce = g_pce + 1
      LET g_wgt = g_wgt + RWWcom_wgt + RWWadd_wgt
      LET g_vmm = g_vmm + RWWvmom
      LET g_lmm = g_lmm + RWWlmom
      LET g_tmm = g_tmm + RWWtmom

      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , p_rww.comp_seqno USING "<<<<<",
	       COLUMN 7  , RWWdesc CLIPPED,
               COLUMN 44 , RWWcom_wgt USING "####&.&",
	       COLUMN 53 , RWWadd_wgt USING "####&.&",
	       COLUMN 63 , RWWvcg USING "----&.&",
	       COLUMN 71 , RWWlcg USING "----&.&",
	       COLUMN 79 , RWWtcg USING "----&.&",
	       COLUMN 87 , RWWvmom USING "----------&.&",
	       COLUMN 101, RWWlmom USING "----------&.&",
	       COLUMN 115, RWWtmom USING "----------&.&"
      ELSE
         PRINT COLUMN 1  , p_rww.comp_seqno USING "<<<<<",
	       COLUMN 7  , RWWdesc CLIPPED,
               COLUMN 44 , RWWcom_wgt USING "####&.&",
	       COLUMN 53 , RWWadd_wgt USING "####&.&",
	       COLUMN 63 , RWWvcg USING "---&.&&",
	       COLUMN 71 , RWWlcg USING "---&.&&",
	       COLUMN 79 , RWWtcg USING "---&.&&",
	       COLUMN 87 , RWWvmom USING "----------&.&",
	       COLUMN 101, RWWlmom USING "----------&.&",
	       COLUMN 115, RWWtmom USING "----------&.&"
      END IF

      ON LAST ROW
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
