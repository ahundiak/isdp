DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BMGmain ()

  DEFINE	cit_cnt	INTEGER,
		i	INTEGER
		

  CALL ERRORLOG("Enter in Drawing Beam BOM report")
  MESSAGE "Drawing Beam BOM report in progress... please wait"

  START REPORT BMGform TO "BMGform"
    OUTPUT TO REPORT BMGform ()
  FINISH REPORT BMGform

  START REPORT BMGheader TO "BMGheader"
    OUTPUT TO REPORT BMGheader ()
  FINISH REPORT BMGheader

  IF drawing_flag = 0 THEN CALL ERRORLOG ( "No drawing beams found")
  ELSE                     CALL ERRORLOG ( "Reporting from drawing checkin")
  END IF

  IF drawing_flag = 0 THEN
     MESSAGE "No beams checked in for specified drawing"
     SLEEP 3
     
  ELSE
     LET cit_cnt = 1
     CALL BMGquery1 ()
     PREPARE bmd_stmt1 FROM q_stmt
     DECLARE bmd_curs1 CURSOR FOR bmd_stmt1
     FOREACH bmd_curs1 INTO p_bmd1[cit_cnt].*
        IF STATUS < 0 THEN
           CALL ERRORLOG("No rows found in group query")
           MESSAGE "No rows found in group query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           IF cit_cnt > 5000 THEN
              CALL ERRORLOG("Beam drawing report truncated to 5000 groups")
              MESSAGE "Beam drawing report truncated to 5000 groups"
              SLEEP 3
              EXIT FOREACH
           ELSE
              LET cit_cnt = cit_cnt + 1
           END IF
        END IF
     END FOREACH
     LET cit_cnt = cit_cnt - 1

     FOR i = 1 TO cit_cnt
        CALL BMGquery2 (i)
        PREPARE bmd_stmt2 FROM q_stmt
        DECLARE bmd_curs2 CURSOR FOR bmd_stmt2
        START REPORT BMGmaterial TO PIPE "BMG.sh"
           FOREACH bmd_curs2 INTO p_bmd2.*
              IF STATUS < 0 THEN
                 CALL ERRORLOG ("No rows found in the query")
                 SLEEP 3
                 EXIT FOREACH
              ELSE
                 CALL BMGconvert ()
                 OUTPUT TO REPORT BMGmaterial (i)
              END IF
           END FOREACH
        FINISH REPORT BMGmaterial
     END FOR
  END IF


  START REPORT BMGend TO pipe "BMG.sh"
    OUTPUT TO REPORT BMGend ()
  FINISH REPORT BMGend


  MESSAGE "Drawing Beam BOM report achieved"
  CALL ERRORLOG("Exit from Drawing Beam BOM report")
END FUNCTION


REPORT BMGform ()

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

REPORT BMGheader ()

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 7

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0
      LET g_wgt = 0.0
      LET g_srf = 0.0

      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------",
            COLUMN 121,"--------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 46 , "M A T E R I A L   L I S T",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------",
            COLUMN 121,"--------"
      PRINT COLUMN 1,  "ITEM", 
            COLUMN 8,  "GEOM", 
            COLUMN 14, "MATERIAL", 
            COLUMN 25, "GRADE", 
            COLUMN 34, "DESCRIPTION",
	    COLUMN 52, "TOTAL LENGTH", 
            COLUMN 68, "UNIT WEIGHT",
	    COLUMN 83, "TOTAL WEIGHT",
            COLUMN 99, "END TR 1",
            COLUMN 117, "END TR 2"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 50, " (FT & IN)",
	       COLUMN 68, " (LB/FT)",
	       COLUMN 83, " (LB)"
      ELSE
         PRINT COLUMN 52, " (M)",
	       COLUMN 68, " (KG/M)",
	       COLUMN 83, " (KG)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------",
            COLUMN 121,"--------"
END REPORT


REPORT BMGmaterial (num)
  DEFINE	num		INTEGER
  DEFINE 	lin_wgt  	FLOAT,
  		tot_wgt   	FLOAT,
		feet		INTEGER,
		inch		INTEGER

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 1

    FORMAT

      ON EVERY ROW
         LET g_pce = g_pce + p_bmd2.grp_num
         LET g_wgt = g_wgt + (p_bmd2.grp_vol * p_bmd2.density)
         LET g_srf = g_srf + p_bmd2.grp_srf
	 
         CALL BMGdescription () RETURNING tot_wgt, lin_wgt

         IF p_vds.prj_units_set = 1 THEN
            CALL foot_and_inch (p_bmd2.grp_len) RETURNING feet, inch
            PRINT COLUMN 1,  p_bmd1[num].item_no CLIPPED,
                  COLUMN 8,  p_bmd2.short_txt CLIPPED,
                  COLUMN 14, p_bmd2.material CLIPPED,
                  COLUMN 25, p_bmd2.grade CLIPPED,
                  COLUMN 34, p_bmd2.f_part_num CLIPPED,
                  COLUMN 52, feet USING "###&\'", "-", inch USING "#&\"",
                  COLUMN 68, lin_wgt USING "#####.&",
                  COLUMN 83, tot_wgt USING "#######.&",
		  COLUMN 99, p_bmd2.end0 CLIPPED,
		  COLUMN 117, p_bmd2.end1 CLIPPED
         ELSE
            PRINT COLUMN 1,  p_bmd1[num].item_no CLIPPED,
                  COLUMN 8, p_bmd2.short_txt CLIPPED,
                  COLUMN 14, p_bmd2.material CLIPPED,
                  COLUMN 25, p_bmd2.grade CLIPPED,
                  COLUMN 34, p_bmd2.f_part_num CLIPPED,
                  COLUMN 52, p_bmd2.grp_len USING "#####.&&",
                  COLUMN 68, lin_wgt USING "#####.&",
	          COLUMN 83, tot_wgt USING "########.&",
		  COLUMN 99, p_bmd2.end0 CLIPPED,
		  COLUMN 117, p_bmd2.end1 CLIPPED
         END IF
   
END REPORT


REPORT BMGend ()

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
