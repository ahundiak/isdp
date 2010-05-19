DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BMBmain ()
  DEFINE	elem_no INTEGER
		
  CALL ERRORLOG("Enter in  Beam BOM report")
  MESSAGE "Beam BOM report in progress... please wait"

  START REPORT BMBform TO "BMBform"
     OUTPUT TO REPORT BMBform ()
  FINISH REPORT BMBform

  LET elem_no = 0
  CALL BMBquery ()
  PREPARE bmb_stmt FROM q_stmt
  DECLARE bmb_curs CURSOR FOR bmb_stmt

  START REPORT BMBmaterial TO "BMBmaterial"
     FOREACH bmb_curs INTO p_bmb.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in the query")
           SLEEP 3
           EXIT FOREACH
        ELSE
           LET elem_no = elem_no + 1
           CALL BMBconvert ()
           OUTPUT TO REPORT BMBmaterial (elem_no)
        END IF
     END FOREACH
  FINISH REPORT BMBmaterial

  START REPORT BMBend TO pipe "BMB.sh"
    OUTPUT TO REPORT BMBend ()
  FINISH REPORT BMBend


  MESSAGE "Beam BOM report achieved"
  CALL ERRORLOG("Exit from Beam BOM report")
END FUNCTION


REPORT BMBform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "============================="
      PRINT COLUMN 20, "| STRUCTURAL MEMBERS REPORT |"
      PRINT COLUMN 20, "============================="
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
            COLUMN 21, "[", COLUMN 23, p_bm.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_bm.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_bm.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_bm.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_bm.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
	    COLUMN 21, "[", COLUMN 23, p_bm.constr_stat CLIPPED, COLUMN 32, "]"
END REPORT


REPORT BMBmaterial (row_no)

  DEFINE	row_no   	INTEGER

  DEFINE 	lin_wgt  	FLOAT,
  		tot_wgt   	FLOAT,
		feet		INTEGER,
		inch		INTEGER

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0
      LET g_wgt = 0.0
      LET g_srf = 0.0

      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 46 , "M A T E R I A L   L I S T",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------"
      PRINT COLUMN 1,  "ITEM", 
            COLUMN 8,  "NO. PIECES", 
            COLUMN 21, "GEOM", 
            COLUMN 27, "MATERIAL", 
            COLUMN 41, "GRADE", 
            COLUMN 50, "DESCRIPTION",
	    COLUMN 68, "TOTAL LENGTH", 
            COLUMN 84, "UNIT WEIGHT",
	    COLUMN 99, "TOTAL WEIGHT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 68, " (FT & IN)",
	       COLUMN 84, " (LB/FT)",
	       COLUMN 99, " (LB)"
      ELSE
         PRINT COLUMN 68, " (M)",
	       COLUMN 84, " (KG/M)",
	       COLUMN 99, " (KG)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------"

    PAGE HEADER
      LET p_pce = 0
      LET p_wgt = 0.0
      LET p_srf = 0.0

      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------"
      PRINT COLUMN 1,  "ITEM", 
            COLUMN 8,  "NO. PIECES", 
            COLUMN 21, "GEOM", 
            COLUMN 27, "MATERIAL", 
            COLUMN 41, "GRADE", 
            COLUMN 50, "DESCRIPTION",
	    COLUMN 68, "TOTAL LENGTH", 
            COLUMN 84, "UNIT WEIGHT",
	    COLUMN 99, "TOTAL WEIGHT"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 68, " (FT & IN)",
               COLUMN 84, " (LB/FT)",
	       COLUMN 99, " (LB)"
      ELSE
         PRINT COLUMN 68, " (M)",
	       COLUMN 84, " (KG/M)",
	       COLUMN 99, " (KG)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------"

      ON EVERY ROW

         LET p_pce = p_pce + p_bmb.grp_num
         LET g_pce = g_pce + p_bmb.grp_num
         LET p_wgt = p_wgt + (p_bmb.grp_vol * p_bmb.density)
         LET g_wgt = g_wgt + (p_bmb.grp_vol * p_bmb.density)
         LET p_srf = p_srf + p_bmb.grp_srf
         LET g_srf = g_srf + p_bmb.grp_srf
	 
         CALL BMBdescription () RETURNING tot_wgt, lin_wgt
 
         IF p_vds.prj_units_set = 1 THEN
            CALL foot_and_inch (p_bmb.grp_len) RETURNING feet, inch
            PRINT COLUMN 1,  row_no USING "<<<<",
                  COLUMN 8,  p_bmb.grp_num USING "###&",
                  COLUMN 21, p_bmb.short_txt CLIPPED,
                  COLUMN 27, p_bmb.material CLIPPED,
                  COLUMN 41, p_bmb.grade CLIPPED,
                  COLUMN 50, p_bmb.f_part_num CLIPPED,
                  COLUMN 68, feet USING "###&\'", "-", inch USING "#&\"",
                  COLUMN 84, lin_wgt USING "#####.&",
                  COLUMN 99, tot_wgt USING "#######.&" 
         ELSE
            PRINT COLUMN 1,  row_no USING "<<<<",
                  COLUMN 8,  p_bmb.grp_num USING "###&",
                  COLUMN 21, p_bmb.short_txt CLIPPED,
                  COLUMN 27, p_bmb.material CLIPPED,
                  COLUMN 41, p_bmb.grade CLIPPED,
                  COLUMN 50, p_bmb.f_part_num CLIPPED,
                  COLUMN 68, p_bmb.grp_len USING "#####.&&",
                  COLUMN 84, lin_wgt USING "#####.&",
	          COLUMN 99, tot_wgt USING "########.&" 
         END IF
   
      PAGE TRAILER
         PRINT COLUMN 1,   "----------------------------------------",
               COLUMN 41,  "----------------------------------------",
               COLUMN 81,  "----------------------------------"
         IF p_vds.prj_units_set = 1 THEN
	    PRINT
              COLUMN 1,  p_pce USING "PAGE ITEM COUNT: <<<<<",
	      COLUMN 35, p_wgt USING "PAGE TOTAL WEIGHT: <<<<<<<<.< LB",
	      COLUMN 75, p_srf USING "PAGE TOTAL SURFACE AREA: <<<<<<<<.< SQ FT"
         ELSE
	    PRINT
	      COLUMN 1,  p_pce USING "PAGE ITEM COUNT: <<<<<",
	      COLUMN 35, p_wgt USING "PAGE TOTAL WEIGHT: <<<<<<<<.< KG",
	      COLUMN 75, p_srf USING "PAGE TOTAL SURFACE AREA: <<<<<<<<.< M^2"
         END IF
         PRINT COLUMN 1,   "----------------------------------------",
               COLUMN 41,  "----------------------------------------",
               COLUMN 81,  "----------------------------------"

      ON LAST ROW
         SKIP TO TOP OF PAGE
END REPORT


REPORT BMBend ()

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
            COLUMN 81,  "=================================="

      IF p_vds.prj_units_set = 1 THEN
         PRINT
           COLUMN 1,  g_pce USING "GRAND TOTAL PIECES: <<<<<",
           COLUMN 35, g_wgt USING "GRAND TOTAL WEIGHT: <<<<<<<<.< LB",
           COLUMN 75, g_srf USING "GRAND TOTAL SURFACE AREA: <<<<<<<.< SQ FT"
      ELSE
         PRINT
	   COLUMN 1,  g_pce USING "GRAND TOTAL PIECES: <<<<<",
           COLUMN 35, g_wgt USING "GRAND TOTAL WEIGHT: <<<<<<<<.< KG",
           COLUMN 75, g_srf USING "GRAND TOTAL SURFACE AREA: <<<<<<<.< M^2"
      END IF
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "=================================="
END REPORT
