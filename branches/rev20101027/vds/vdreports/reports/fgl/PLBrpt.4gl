DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PLBmain ()

  DEFINE	elem_no	INTEGER

  CALL ERRORLOG ("Enter in  Plate BOM report")
  MESSAGE "Plate BOM report in progress... please wait"

  START REPORT PLBform TO "PLBform"
     OUTPUT TO REPORT PLBform ()
  FINISH REPORT PLBform

  LET elem_no = 0
  CALL PLBquery ()
  PREPARE plb_stmt FROM q_stmt
  DECLARE plb_curs CURSOR FOR plb_stmt

  START REPORT PLBmaterial TO "PLBmaterial"
     FOREACH plb_curs INTO p_plb.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in the query")
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL PLBconvert ()
           LET elem_no = elem_no + 1
           OUTPUT TO REPORT PLBmaterial (elem_no)
        END IF
     END FOREACH
  FINISH REPORT PLBmaterial

  START REPORT PLBend TO PIPE "PLB.sh"
    OUTPUT TO REPORT PLBend ()
  FINISH REPORT PLBend

  MESSAGE "Plate BOM report achieved"
  CALL ERRORLOG ("Exit from Plate BOM report")
END FUNCTION


REPORT PLBform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "================================="
      PRINT COLUMN 20, "|  STRUCTURAL PLATE BOM REPORT  |"
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
END REPORT


REPORT PLBmaterial (row_no)
  DEFINE	row_no		INTEGER,
  	 	sum_wt		FLOAT,
  	 	thk_frac	CHAR(10),
  	 	temp_len	CHAR(15),
  	 	temp_wid	CHAR(15)

  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce  = 0
      LET g_srf  = 0.0
      LET g_wgt  = 0.0

      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 40 , "S T R U C T U R A L  P L A T E  R E P O R T",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 1,   "ITEM",
            COLUMN 8,   "NO. PIECES", 
            COLUMN 21,  "GEOM", 
            COLUMN 29,  "MATERIAL", 
            COLUMN 39,  "GRADE", 
            COLUMN 51,  "SIZE",
            COLUMN 75,  "SURF. AREA",
            COLUMN 90,  "THICKNESS", 
            COLUMN 102, "VOLUME",
	    COLUMN 111, "DENSITY",
            COLUMN 122, "TOT. WEIGHT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 21,  "(F/C)", 
               COLUMN 51,  "(FT & INxFT & IN)",
               COLUMN 75,  "(FT^2)",
               COLUMN 90,  "(IN)", 
               COLUMN 102, "(FT^3)",
	       COLUMN 111, "(LB/FT^3)",
               COLUMN 122, "(LB)"
      ELSE
         PRINT COLUMN 21,  "(F/C)", 
               COLUMN 51,  "(MxM)",
               COLUMN 75,  "(M^2)",
               COLUMN 90,  "(MM)", 
               COLUMN 102, "(M^3)",
	       COLUMN 111, "(KG/M^3)",
               COLUMN 122, "(KG)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"

    PAGE HEADER
      LET p_pce = 0
      LET p_wgt = 0.0
      LET p_srf = 0.0

      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 1,   "ITEM",
            COLUMN 8,   "NO. PIECES", 
            COLUMN 21,  "GEOM", 
            COLUMN 29,  "MATERIAL", 
            COLUMN 39,  "GRADE", 
            COLUMN 51,  "SIZE",
            COLUMN 75,  "SURF. AREA",
            COLUMN 90,  "THICKNESS", 
            COLUMN 102, "VOLUME",
	    COLUMN 111, "DENSITY",
            COLUMN 122, "TOT. WEIGHT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 21,  "(F/C)", 
               COLUMN 51,  "(FT-INxFT-IN)",
               COLUMN 75,  "(FT^2)",
               COLUMN 90,  "(IN)", 
               COLUMN 102, "(FT^3)",
	       COLUMN 111, "(LB/FT^3)",
               COLUMN 122, "(LB)"
      ELSE
         PRINT COLUMN 21,  "(F/C)", 
               COLUMN 51,  "(MxM)",
               COLUMN 75,  "(M^2)",
               COLUMN 90,  "(MM)", 
               COLUMN 102, "(M^3)",
	       COLUMN 111, "(KG/M^3)",
               COLUMN 122, "(KG)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81,  "----------------------------------------------------"

    ON EVERY ROW
      CALL PLBdescription () RETURNING sum_wt

      LET p_pce = p_pce + p_plb.sum_item
      LET p_wgt = p_wgt + sum_wt
      LET p_srf = p_srf + p_plb.sum_srf

      LET g_pce  = g_pce  + p_plb.sum_item
      LET g_wgt  = g_wgt  + sum_wt
      LET g_srf  = g_srf  + p_plb.sum_srf

      IF p_vds.prj_units_set = 1 THEN
         CALL fraction_format ( p_plb.pl_thk * 12.0, 32) RETURNING thk_frac 
         CALL element_length  ( p_plb.pl_len * 12.0, 32) RETURNING temp_len
         CALL element_length  ( p_plb.pl_wid * 12.0, 32) RETURNING temp_wid
         PRINT COLUMN 1,   row_no USING "<<<<",
               COLUMN 8,   p_plb.sum_item USING "##&",
               COLUMN 21,  p_plb.short_txt CLIPPED,
               COLUMN 29,  p_plb.material CLIPPED,
               COLUMN 39,  p_plb.grade CLIPPED,
               COLUMN 45,  temp_len CLIPPED, " x ", temp_wid clipped, 
               COLUMN 75,  p_plb.pl_srf USING "######.#&", 
	       COLUMN 90,  thk_frac CLIPPED, "\"", 
	       COLUMN 102, p_plb.pl_vol USING "###.###&", 
	       COLUMN 111, p_plb.density USING "####.##&", 
	       COLUMN 122, sum_wt USING "#######.&"
      ELSE
         PRINT COLUMN 1,   row_no USING "<<<<",
               COLUMN 8,   p_plb.sum_item USING "##&",
               COLUMN 21,  p_plb.short_txt CLIPPED,
               COLUMN 29,  p_plb.material CLIPPED,
               COLUMN 39,  p_plb.grade CLIPPED,
               COLUMN 45,  p_plb.pl_len USING "#####.##&",
                           " x ", p_plb.pl_wid USING "#####.##&", 
               COLUMN 72,  p_plb.pl_srf USING "#######.&", 
	       COLUMN 90,  p_plb.pl_thk * 1000.0 USING "####.&", 
	       COLUMN 99,  p_plb.pl_vol USING "##.####&", 
	       COLUMN 111, p_plb.density USING "#####.#&", 
	       COLUMN 122, sum_wt USING "########.&"
      END IF

      PAGE TRAILER
         PRINT COLUMN 1,  "----------------------------------------",
               COLUMN 41, "----------------------------------------",
               COLUMN 81, "----------------------------------------------------"
         IF p_vds.prj_units_set = 1 THEN
	 PRINT
	   COLUMN 1,   p_pce USING "PAGE ITEM COUNT: <<<<",
	   COLUMN 35,  p_wgt USING "PAGE TOTAL WEIGHT: <<<<<<<<.< LB",
	   COLUMN 75,  p_srf USING "PAGE TOTAL SURFACE AREA: <<<<<<<<<<.< SQ FT"
         ELSE
	 PRINT
           COLUMN 1,   p_pce USING "PAGE ITEM COUNT: <<<<",
	   COLUMN 35,  p_wgt USING "PAGE TOTAL WEIGHT: <<<<<<<<.< KG",
	   COLUMN 75,  p_srf USING "PAGE TOTAL SURFACE AREA: <<<<<<<<<<.< M^2"
         END IF
         PRINT COLUMN 1,  "----------------------------------------",
               COLUMN 41, "----------------------------------------",
               COLUMN 81, "----------------------------------------------------"

      ON LAST ROW
         SKIP TO TOP of PAGE
END REPORT


REPORT PLBend ()

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
            COLUMN 81,  "========================================"
      IF p_vds.prj_units_set = 1 THEN
         PRINT
	   COLUMN 1,  g_pce USING "GRAND TOTAL PIECES: <<<<<",
           COLUMN 35, g_wgt USING "GRAND TOTAL WEIGHT: <<<<<<<<<.< LB",
           COLUMN 75, g_srf USING "GRAND TOTAL SURFACE AREA: <<<<<<<<<<.< SQ FT"
      ELSE
         PRINT
	   COLUMN 1,  g_pce USING "GRAND TOTAL PIECES: <<<<<",
           COLUMN 35, g_wgt USING "GRAND TOTAL WEIGHT: <<<<<<<<<.< KG",
           COLUMN 75, g_srf USING "GRAND TOTAL SURFACE AREA: <<<<<<<<<<.< M^2"
      END IF
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "========================================"
END REPORT
