DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PLWmain ()

  CALL ERRORLOG ("Enter in  Plate Weight report")
  MESSAGE "Plate Weight report in progress... please wait"

  START REPORT PLWform TO "PLWform"
    OUTPUT TO REPORT PLWform ()
  FINISH REPORT PLWform

  CALL PLWquery ()
  PREPARE plw_stmt FROM q_stmt
  DECLARE plw_curs CURSOR FOR plw_stmt

  START REPORT PLWmaterial TO "PLWmaterial"
     FOREACH plw_curs INTO p_plw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           MESSAGE "No rows found in query"
           SLEEP 3
           EXIT FOREACH
         ELSE
           CALL PLWconvert ()
           OUTPUT TO REPORT PLWmaterial (p_plw.weight_grp)
         END IF
     END FOREACH
  FINISH REPORT PLWmaterial


  START REPORT PLWend TO pipe "PLW.sh"
    OUTPUT TO REPORT PLWend ()
  FINISH REPORT PLWend


  MESSAGE "Plate Weight report achieved"
  CALL ERRORLOG ("Exit from Plate Weight report")
END FUNCTION


REPORT PLWform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "============================================="
      PRINT COLUMN 20, "| STRUCTURAL PLATE WEIGHT CONTROL WORKSHEET |"
      PRINT COLUMN 20, "============================================="
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
      PRINT COLUMN 35, "REPORTING CRITERIA"
      PRINT COLUMN 35, "=================="
      SKIP 1 LINE
      PRINT COLUMN 1 , "ASSEMBLY CATALOG",
            COLUMN 21, "[", COLUMN 23, p_pl.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_pl.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_pl.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_pl.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_pl.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_pl.constr_stat CLIPPED, COLUMN 32, "]"
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


REPORT PLWmaterial (p_4gl)
  DEFINE p_4gl RECORD weight_grp LIKE "nfmadmin".struct_pl_dynamic.weight_grp END RECORD

  DEFINE PLWdesc        CHAR(30),
         PLWcur_wgt     FLOAT,
         PLWvcg         FLOAT,
         PLWlcg         FLOAT,
         PLWtcg         FLOAT,
         PLWvmom        FLOAT,
         PLWlmom        FLOAT,
         PLWtmom        FLOAT

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce  = 0
      LET g_wgt = 0.0
      LET g_vmm = 0.0
      LET g_lmm = 0.0
      LET g_tmm = 0.0

      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 45 , "S T R U C T U R A L  P L A T E S",
            COLUMN 116, "Page - 1"
      PRINT COLUMN 47 , "W E I G H T    C O N T R O L"
      PRINT COLUMN 52 , "W O R K S H E E T"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"
      PRINT COLUMN 1  , "ITEM",
            COLUMN 7  , "DESCRIPTION",
            COLUMN 25 , "UNIT WT",
	    COLUMN 35 , "VOLUME",
	    COLUMN 45 , "WEIGHT",
	    COLUMN 56 , "VCG",
	    COLUMN 65 , "LCG",
	    COLUMN 74 , "TCG",
	    COLUMN 82 , "VERT MOMENT",
	    COLUMN 97 , "LONG MOMENT",
	    COLUMN 112, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT  COLUMN 25 , "(LB/FT^3)",
                COLUMN 36 , "(FT^3)",
                COLUMN 46 , "(LB)",
                COLUMN 56 , "(FT)",
                COLUMN 65 , "(FT)",
                COLUMN 74 , "(FT)",
                COLUMN 84 , "(FT-LB)",
                COLUMN 99 , "(FT-LB)",
                COLUMN 114, "(FT-LB)"
      ELSE
         PRINT  COLUMN 25 , "(KG/M^3)",
                COLUMN 36 , "(M^3)",
                COLUMN 46 , "(KG)",
                COLUMN 56 , "(M)",
                COLUMN 65 , "(M)",
                COLUMN 74 , "(M)",
                COLUMN 84 , "(KG-M)",
                COLUMN 99 , "(KG-M)",
                COLUMN 114, "(KG-M)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"

    PAGE HEADER
      LET p_pce = 0
      LET p_wgt = 0.0
      LET p_vmm = 0.0
      LET p_lmm = 0.0
      LET p_tmm = 0.0

      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"
      PRINT COLUMN 1  , "ITEM",
            COLUMN 7  , "DESCRIPTION",
            COLUMN 25 , "UNIT WT",
	    COLUMN 35 , "VOLUME",
	    COLUMN 45 , "WEIGHT",
	    COLUMN 56 , "VCG",
	    COLUMN 65 , "LCG",
	    COLUMN 74 , "TCG",
	    COLUMN 82 , "VERT MOMENT",
	    COLUMN 97 , "LONG MOMENT",
	    COLUMN 112, "TRAN MOMENT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT  COLUMN 25 , "(LB/FT^3)",
                COLUMN 36 , "(FT^3)",
                COLUMN 46 , "(LB)",
                COLUMN 56 , "(FT)",
                COLUMN 65 , "(FT)",
                COLUMN 74 , "(FT)",
                COLUMN 84 , "(FT-LB)",
                COLUMN 99 , "(FT-LB)",
                COLUMN 114, "(FT-LB)"
      ELSE
         PRINT  COLUMN 25 , "(KG/M^3)",
                COLUMN 36 , "(M^3)",
                COLUMN 46 , "(KG)",
                COLUMN 56 , "(M)",
                COLUMN 65 , "(M)",
                COLUMN 74 , "(M)",
                COLUMN 84 , "(KG-M)",
                COLUMN 99 , "(KG-M)",
                COLUMN 114, "(KG-M)"
      END IF
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------------"

      BEFORE GROUP OF p_4gl.weight_grp
      SKIP 1 LINE
      PRINT COLUMN 1 , "SHIP ALT #:", p_plw.long_txt CLIPPED,
            COLUMN 31, "WT GROUP #:", p_plw.weight_grp USING "&&&"
      SKIP 1 LINE

      ON EVERY ROW
      CALL PLWdescription () RETURNING PLWdesc, PLWcur_wgt,
                     		       PLWvcg, PLWlcg, PLWtcg,
                     		       PLWvmom, PLWlmom, PLWtmom

#DISPLAY "\nPLWdescription is returning : "
#DISPLAY "\tPLWdesc    : <", PLWdesc CLIPPED, ">"
#DISPLAY "\tPLWcur_wgt = ", PLWcur_wgt USING "#######.###"
#DISPLAY "\tPLWvcg     = ", PLWvcg USING "#######.###"
#DISPLAY "\tPLWlcg     = ", PLWlcg USING "#######.###"
#DISPLAY "\tPLWtcg     = ", PLWtcg USING "#######.###"
#DISPLAY "\tPLWvmom    = ", PLWvmom USING "#######.###"
#DISPLAY "\tPLWlmom    = ", PLWlmom USING "#######.###"
#DISPLAY "\tPLWtmom    = ", PLWtmom USING "#######.###"
#DISPLAY "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

      LET p_pce = p_pce + 1
      LET p_wgt = p_wgt + PLWcur_wgt
      LET p_vmm = p_vmm + PLWvmom
      LET p_lmm = p_lmm + PLWlmom
      LET p_tmm = p_tmm + PLWtmom

      LET g_pce = g_pce + 1
      LET g_wgt = g_wgt + PLWcur_wgt
      LET g_vmm = g_vmm + PLWvmom
      LET g_lmm = g_lmm + PLWlmom
      LET g_tmm = g_tmm + PLWtmom

      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   p_plw.comp_seqno USING "<<<<<",
               COLUMN 7,   PLWdesc CLIPPED,
               COLUMN 25,  p_plw.density USING "####.#&",
               COLUMN 35,  p_plw.pl_vol USING "####.#&",
               COLUMN 43,  PLWcur_wgt USING "######&.&",
               COLUMN 54,  PLWvcg USING "----&.&",
               COLUMN 63,  PLWlcg USING "----&.&",
               COLUMN 72,  PLWtcg USING "----&.&",
	       COLUMN 81,  PLWvmom USING "----------&.&",
	       COLUMN 96,  PLWlmom USING "----------&.&",
	       COLUMN 111, PLWtmom USING "----------&.&"
      ELSE
         PRINT COLUMN 1,   p_plw.comp_seqno USING "<<<<<",
               COLUMN 7,   PLWdesc CLIPPED,
               COLUMN 25,  p_plw.density USING "#####.&",
               COLUMN 35,  p_plw.pl_vol USING "##.###&",
               COLUMN 43,  PLWcur_wgt USING "######&.&",
               COLUMN 54,  PLWvcg USING "---&.&&",
               COLUMN 63,  PLWlcg USING "---&.&&",
               COLUMN 72,  PLWtcg USING "---&.&&",
	       COLUMN 81,  PLWvmom USING "----------&.&",
	       COLUMN 96,  PLWlmom USING "----------&.&",
	       COLUMN 111, PLWtmom USING "----------&.&"
      END IF

      PAGE TRAILER
      PRINT COLUMN 1,   "----------------------------------------",
            COLUMN 41,  "----------------------------------------",
            COLUMN 81,  "-------------------------------------------"
      IF p_wgt != 0 THEN
        IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   p_pce USING "PAGE ITEM COUNT: ####",
               COLUMN 32,  p_wgt USING "PAGE TOTAL WEIGHT: ######&.& LB",
               COLUMN 71,  p_vmm / p_wgt  USING "VCG: ----&.& FT",
               COLUMN 90,  p_lmm / p_wgt  USING "LCG: ----&.& FT",
               COLUMN 109, p_tmm / p_wgt  USING "TCG: ----&.& FT"
        ELSE
         PRINT COLUMN 1,   p_pce USING "PAGE ITEM COUNT: ####",
               COLUMN 32,  p_wgt USING "PAGE TOTAL WEIGHT: ######&.& KG",
               COLUMN 71,  p_vmm / p_wgt USING "VCG: ---&.&& M",
               COLUMN 90,  p_lmm / p_wgt USING "LCG: ---&.&& M",
               COLUMN 109, p_tmm / p_wgt USING "TCG: ---&.&& M"
        END IF
      ELSE
        IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   p_pce USING "PAGE ITEM COUNT: ####",
               COLUMN 32,  p_wgt USING "PAGE TOTAL WEIGHT: ######&.& LB",
               COLUMN 71,  "VCG: ----0.0 FT",
               COLUMN 90,  "LCG: ----0.0 FT",
               COLUMN 109, "TCG: ----0.0 FT"
        ELSE
         PRINT COLUMN 1,   p_pce USING "PAGE ITEM COUNT: ####",
               COLUMN 32,  p_wgt USING "PAGE TOTAL WEIGHT: ######&.& KG",
               COLUMN 71,  "VCG: ---0.00 M",
               COLUMN 90,  "LCG: ---0.00 M",
               COLUMN 109, "TCG: ---0.00 M"
        END IF
      END IF
      PRINT COLUMN 1,   "----------------------------------------",
            COLUMN 41,  "----------------------------------------",
            COLUMN 81,  "-------------------------------------------"

      ON LAST ROW
         SKIP TO TOP OF PAGE
END REPORT


REPORT PLWend ()

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "==========================================="
      IF g_wgt != 0 THEN
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
      ELSE
        IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 32,  g_wgt USING "GRAND TOTAL WEIGHT: ######&.& LB",
               COLUMN 71,  "VCG: ----0.0 FT",
               COLUMN 90,  "LCG: ----0.0 FT",
               COLUMN 109, "TCG: ----0.0 FT"
        ELSE
         PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: ####",
               COLUMN 32,  g_wgt USING "GRAND TOTAL WEIGHT: ######&.& KG",
               COLUMN 71,  "VCG: ---0.00 M",
               COLUMN 90,  "LCG: ---0.00 M",
               COLUMN 109, "TCG: ---0.00 M"
        END IF
      END IF
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "==========================================="
END REPORT
