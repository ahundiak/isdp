DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION CMCmain()
  DEFINE	elem_no INTEGER

  CALL ERRORLOG ("Enter in  Compartment report")
  MESSAGE "Compartment report in progress... please wait"

  START REPORT CMCform TO "CMCform"
    OUTPUT TO REPORT CMCform ()
  FINISH REPORT CMCform

  LET elem_no = 0
  CALL CMCquery ()

  PREPARE cmb_stmt FROM q_stmt
  DECLARE cmb_curs CURSOR FOR cmb_stmt

  START REPORT CMCmaterial TO "CMCmaterial"
     FOREACH cmb_curs INTO p_cmb.*
	IF STATUS < 0 THEN
	   CALL ERRORLOG ("No rows found in query")
	   SLEEP 3
	   EXIT FOREACH
	ELSE
	   LET elem_no = elem_no + 1
	   CALL CMCconvert()
	   OUTPUT TO REPORT CMCmaterial ( elem_no )
	END IF
     END FOREACH
  FINISH REPORT CMCmaterial

  START REPORT CMCend TO PIPE "CMC.sh"
     OUTPUT TO REPORT CMCend ()
  FINISH REPORT CMCend 
  

  MESSAGE "Compartment Space Class report achieved"
  CALL ERRORLOG ("Exit from Compartment report")
END FUNCTION


REPORT CMCform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "==============================="
      PRINT COLUMN 20, "|   COMPARTMENT MATERIAL LIST   |"
      PRINT COLUMN 20, "==============================="
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
            COLUMN 21, "[", COLUMN 23, p_cm.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_cm.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_cm.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_cm.zone CLIPPED, COLUMN 28, "]"
END REPORT

REPORT CMCmaterial( row_no )
  DEFINE row_no  INTEGER

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0
      LET g_srf = 0.0
      LET g_vol = 0.0

      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "-----------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 51 , "C O M P A R T M E N T A T I O N   S P A C E - C L A S S",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 49 , "A R E A   V O L U M E   R E P O R T" 
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "-----------------------------------------------"
      SKIP 1 LINE

      IF p_vds.report_units = 1 THEN
        PRINT COLUMN 1,   "ITEM",
            COLUMN 7,   "SPACE CLASS",
            COLUMN 20,  "DESCRIPTION",
            COLUMN 73,  "CENTER OF VOLUME (FT)",
            COLUMN 108, "ALLOC AR",
            COLUMN 118, "ALLOC VOL"
        PRINT COLUMN 76,  "X",
            COLUMN 83,  "Y",
            COLUMN 90,  "Z",
            COLUMN 108, "  (SQ FT)",
            COLUMN 118, "  (CU FT)"
      ELSE
        PRINT COLUMN 1,   "ITEM",
            COLUMN 7,   "SPACE CLASS",
            COLUMN 20,  "DESCRIPTION",
            COLUMN 73,  "CENTER OF VOLUME (M)",
            COLUMN 108, "ALLOC AR",
            COLUMN 118, "ALLOC VOL"
        PRINT COLUMN 76,  "X",
            COLUMN 83,  "Y",
            COLUMN 90,  "Z",
            COLUMN 108, "  (SQ M)",
            COLUMN 118, "  (CU M)"
      END IF

      PRINT COLUMN 1,   "====",
            COLUMN 7,   "===========",
            COLUMN 20,  "==========================================================", 
            COLUMN 73,  "====================",
	    COLUMN 108, "========",
	    COLUMN 118, "========="

    PAGE HEADER
      LET p_pce = 0
      LET p_srf = 0.0
      LET p_vol = 0.0

      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"

      SKIP 1 LINE
      IF p_vds.report_units = 1 THEN
        PRINT COLUMN 1,   "ITEM",
            COLUMN 7,   "SPACE CLASS",
            COLUMN 20,  "DESCRIPTION",
            COLUMN 73,  "CENTER OF VOLUME (FT)",
            COLUMN 108, "ALLOC AR",
            COLUMN 118, "ALLOC VOL"
        PRINT COLUMN 76,  "X",
            COLUMN 83,  "Y",
            COLUMN 90,  "Z",
            COLUMN 108, "  (SQ FT)",
            COLUMN 118, "  (CU FT)"
      ELSE
        PRINT COLUMN 1,   "ITEM",
            COLUMN 7,   "SPACE CLASS",
            COLUMN 20,  "DESCRIPTION",
            COLUMN 73,  "CENTER OF VOLUME (M)",
            COLUMN 108, "ALLOC AR",
            COLUMN 118, "ALLOC VOL"
        PRINT COLUMN 76,  "X",
            COLUMN 83,  "Y",
            COLUMN 90,  "Z",
            COLUMN 108, "  (SQ M)",
            COLUMN 118, "  (CU M)"
      END IF

      PRINT COLUMN 1,   "====",
            COLUMN 7,   "==========================================================", 
            COLUMN 73,  "====================",
            COLUMN 95,  "===========",
	    COLUMN 108, "========",
	    COLUMN 118, "========="

      ON EVERY ROW

	 LET p_pce = p_pce + 1
	 LET g_pce = g_pce + 1
	 LET p_srf = p_srf + p_cmb.floor_area
	 LET g_srf = g_srf + p_cmb.floor_area
	 LET p_vol = p_vol + p_cmb.volume
	 LET g_vol = g_vol + p_cmb.volume

         PRINT COLUMN 1,   row_no USING "###&",
               COLUMN 7,   p_cmb.space_class CLIPPED,
               COLUMN 20,  p_cmb.descript CLIPPED,    
               COLUMN 68,  p_cmb.cog_x USING "----&.&&",
               COLUMN 78,  p_cmb.cog_y USING "----&.&&",
               COLUMN 87,  p_cmb.cog_z USING "----&.&&",
	       COLUMN 108, p_cmb.floor_area USING "####&.&&",
	       COLUMN 118, p_cmb.volume USING "#####&.&&"

    PAGE TRAILER
         PRINT COLUMN 1,   "----------------------------------------",
               COLUMN 41,  "----------------------------------------",
               COLUMN 81,  "-----------------------------------------------"
      IF p_vds.report_units = 1 THEN
         PRINT COLUMN 1,   p_pce USING "PAGE ITEM COUNT: <<<<<",
               COLUMN 35,  p_srf USING "PAGE TOTAL AREA: <<<<<<<.< SQ FT",
               COLUMN 75,  p_vol USING "PAGE TOTAL VOLUME: <<<<<<.< CU FT"
      ELSE
         PRINT COLUMN 1,   p_pce USING "PAGE ITEM COUNT: <<<<<",
               COLUMN 35,  p_srf USING "PAGE TOTAL AREA: <<<<<<<.< SQ M",
               COLUMN 75,  p_vol USING "PAGE TOTAL VOLUME: <<<<<<.< CU M"
      END IF

         PRINT COLUMN 1,   "----------------------------------------",
	       COLUMN 41,  "----------------------------------------",
               COLUMN 81,  "-----------------------------------------------"
    ON LAST ROW
	SKIP TO TOP OF PAGE

END REPORT

REPORT CMCend ()

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
            COLUMN 81,  "==============================================="
      IF p_vds.report_units = 1 THEN
        PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: <<<<<",
            COLUMN 35,  g_srf USING "GRAND TOTAL AREA: <<<<<<<.< SQ FT",
            COLUMN 75,  g_vol USING "GRAND TOTAL VOLUME: <<<<<<.< CU FT"
      ELSE
        PRINT COLUMN 1,   g_pce USING "GRAND TOTAL PIECES: <<<<<",
            COLUMN 35,  g_srf USING "GRAND TOTAL AREA: <<<<<<<.< SQ M",
            COLUMN 75,  g_vol USING "GRAND TOTAL VOLUME: <<<<<<.< CU M"
      END IF

      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "==============================================="
END REPORT
