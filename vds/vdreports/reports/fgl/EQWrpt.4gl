DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION EQWmain ()

  CALL ERRORLOG ("Enter in  Equipment Weight report")
  MESSAGE "Equipment Weight report in progress... please wait"

  START REPORT EQWform to "EQWform"
    OUTPUT to REPORT EQWform ()
  FINISH REPORT EQWform

  CALL EQWquery ()
  PREPARE eqw_stmt FROM q_stmt
  DECLARE eqw_curs CURSOR FOR eqw_stmt

  START REPORT EQWmaterial TO PIPE "EQW.sh"
     FOREACH eqw_curs INTO p_eqw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT EQWmaterial (p_eqw.weight_grp)
        END IF
     END FOREACH
  FINISH REPORT EQWmaterial

  MESSAGE "Equipment Weight report achieved"
  CALL ERRORLOG ("Exit from Equipment Weight report")
END FUNCTION


REPORT EQWform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE length 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "============================================"
      PRINT COLUMN 20, "|    EQUIPMENT WEIGHT CONTROL WORKSHEET    |"
      PRINT COLUMN 20, "============================================"
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
            COLUMN 21, "[", COLUMN 23, p_eq.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_eq.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_eq.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_eq.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_eq.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_eq.constr_stat CLIPPED, COLUMN 32, "]"
      SKIP 4 LINES
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


REPORT EQWmaterial (p_4gl)
  DEFINE p_4gl RECORD wgt_grp LIKE "nfmadmin".equip_dynamic.weight_grp END RECORD
  DEFINE EQWdesc        CHAR(20),
         EQWdry_wgt     FLOAT,
         EQWwet_wgt     FLOAT,
         EQWvcg         FLOAT,
         EQWlcg         FLOAT,
         EQWtcg         FLOAT,
         EQWvmom        FLOAT,
         EQWlmom        FLOAT,
         EQWtmom        FLOAT

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE length 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0
      LET g_wgt = 0.0
      LET g_vmm = 0.0
      LET g_lmm = 0.0
      LET g_tmm = 0.0
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 49 , "  E Q U I P M E N T ",
            COLUMN 116, "Page - 1"
      PRINT COLUMN 47 , "W E I G H T    C O N T R O L"
      PRINT COLUMN 52 , "W O R K S H E E T"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"
      PRINT COLUMN 35 , "DRY WT",
	    COLUMN 44 , "OPER WT",
	    COLUMN 53 , "VCG",
	    COLUMN 61 , "LCG",
	    COLUMN 69 , "TCG",
	    COLUMN 77 , "VERT MOMENT",
	    COLUMN 92 , "LONG MOMENT",
	    COLUMN 107, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 35 , "(LB)",
               COLUMN 44 , "(LB)",
               COLUMN 53 , "(FT)",
               COLUMN 61 , "(FT)",
               COLUMN 69 , "(FT)",
               COLUMN 77 , "(FT-LB)",
               COLUMN 92 , "(FT-LB)",
               COLUMN 107, "(FT-LB)"
      ELSE
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 35 , "(KG)",
               COLUMN 44 , "(KG)",
               COLUMN 53 , "(M)",
               COLUMN 61 , "(M)",
               COLUMN 69 , "(M)",
               COLUMN 77 , "(KG-M)",
               COLUMN 92 , "(KG-M)",
               COLUMN 107, "(KG-M)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"
      PRINT COLUMN 35 , "DRY WT",
	    COLUMN 44 , "OPER WT",
	    COLUMN 53 , "VCG",
	    COLUMN 61 , "LCG",
	    COLUMN 69 , "TCG",
	    COLUMN 77 , "VERT MOMENT",
	    COLUMN 92 , "LONG MOMENT",
	    COLUMN 107, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 35 , "(LB)",
               COLUMN 44 , "(LB)",
               COLUMN 53 , "(FT)",
               COLUMN 61 , "(FT)",
               COLUMN 69 , "(FT)",
               COLUMN 77 , "(FT-LB)",
               COLUMN 92 , "(FT-LB)",
               COLUMN 107, "(FT-LB)"
      ELSE
         PRINT COLUMN 1  , "ITEM",
               COLUMN 8  , "DESCRIPTION",
               COLUMN 35 , "(KG)",
               COLUMN 44 , "(KG)",
               COLUMN 53 , "(M)",
               COLUMN 61 , "(M)",
               COLUMN 69 , "(M)",
               COLUMN 77 , "(KG-M)",
               COLUMN 92 , "(KG-M)",
               COLUMN 107, "(KG-M)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"

      BEFORE GROUP OF p_4gl.wgt_grp
      SKIP 1 LINE
      PRINT COLUMN 1 , "SHIP ALT #:",
            COLUMN 13, p_eqw.long_txt CLIPPED,
            COLUMN 31, "WT GROUP #:",
            COLUMN 43, p_eqw.weight_grp USING "&&&"
      SKIP 1 LINE

      ON EVERY ROW
      CALL EQWdescription () 
           RETURNING EQWdesc, EQWdry_wgt, EQWwet_wgt,
                     EQWvcg, EQWlcg, EQWtcg,
                     EQWvmom, EQWlmom, EQWtmom

      LET g_wgt = g_wgt + EQWwet_wgt
      LET g_pce = g_pce + 1
      LET g_vmm = g_vmm + EQWwet_wgt * EQWvcg
      LET g_lmm = g_lmm + EQWwet_wgt * EQWlcg
      LET g_tmm = g_tmm + EQWwet_wgt * EQWtcg

      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   p_eqw.comp_seqno USING "<<<<<",
               COLUMN 8,   EQWdesc CLIPPED,
               COLUMN 35,  EQWdry_wgt USING "#####.&",
               COLUMN 44,  EQWwet_wgt USING "#####.&",
               COLUMN 54,  EQWvcg USING "----&.&",
               COLUMN 61,  EQWlcg USING "----&.&",
               COLUMN 69,  EQWtcg USING "----&.&",
	       COLUMN 77,  EQWvmom USING "----------&.&",
	       COLUMN 92,  EQWlmom USING "----------&.&",
	       COLUMN 107, EQWtmom USING "----------&.&"
      ELSE
         PRINT COLUMN 1,   p_eqw.comp_seqno USING "<<<<<",
               COLUMN 8,   EQWdesc CLIPPED,
               COLUMN 35,  EQWdry_wgt USING "#####.&",
               COLUMN 44,  EQWwet_wgt USING "#####.&",
               COLUMN 54,  EQWvcg USING "---&.&&",
               COLUMN 61,  EQWlcg USING "---&.&&",
               COLUMN 69,  EQWtcg USING "---&.&&",
	       COLUMN 77,  EQWvmom USING "----------&.&",
	       COLUMN 92,  EQWlmom USING "----------&.&",
	       COLUMN 107, EQWtmom USING "----------&.&"
      END IF

      ON LAST ROW
      SKIP 2 LINES
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "==========================================="
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
            COLUMN 81,  "==========================================="
END REPORT
