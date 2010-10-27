DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION CMTmain()

  DEFINE        elem_no INTEGER
  DEFINE        cnt 	INTEGER
  DEFINE        i 	INTEGER

#  CALL STARTLOG("CMT.log")  	## used only when running independantly
#  CALL RPTform_input(10,9)

  CALL ERRORLOG ("Enter in  Compartment Tracking report")
  MESSAGE "Compartment Tracking report in progress... please wait"

  START REPORT CMTform TO "CMTform"
    OUTPUT TO REPORT CMTform ()
  FINISH REPORT CMTform

  LET elem_no = 0
  LET cnt = 1
  CALL CMTquery1()

#DISPLAY "query stmt::: ", q_stmt CLIPPED

  PREPARE cmt_stmt1 FROM q_stmt
  DECLARE cmt_curs1 CURSOR FOR cmt_stmt1

     FOREACH cmt_curs1 INTO p_cmt1[cnt].*
	IF STATUS < 0 THEN
	   CALL ERRORLOG ("No rows found in query")
	   SLEEP 3
	   EXIT FOREACH
	ELSE
	   IF cnt > 5000 THEN
	      CALL ERRORLOG("Compartment Report truncated to 5000 groups")
	      MESSAGE "Compartment Report truncated to 5000 groups"
	      SLEEP 3
	      EXIT FOREACH
	   ELSE
	      LET cnt = cnt + 1
	   END IF
	END IF
     END FOREACH
     LET cnt = cnt - 1


     FOR i = 1 TO cnt
	IF p_cmt1[i].qnty > 1 THEN
	   CALL CMTquery2(i)
#DISPLAY "query stmt::: ", q_stmt CLIPPED
	   PREPARE cmt_stmt2 FROM q_stmt 
	   DECLARE cmt_curs2 CURSOR FOR cmt_stmt2
  	   START REPORT CMTmaterial TO "CMTmaterial"
	   FOREACH cmt_curs2 INTO p_cmt2.*
	      IF STATUS < 0 THEN
	         CALL ERRORLOG ("No rows found in query")
	         SLEEP 3
	         EXIT FOREACH
	      ELSE
	   	 LET elem_no = elem_no + 1
	     	 OUTPUT TO REPORT CMTmaterial ( elem_no )
	      END IF
	   END FOREACH
           FINISH REPORT CMTmaterial
	END IF
     END FOR

  START REPORT CMTend TO PIPE "CMT.sh"
     OUTPUT TO REPORT CMTend ()
  FINISH REPORT CMTend 
  
  MESSAGE "Compartment Tracking report achieved"
  CALL ERRORLOG ("Exit from Compartment Tracking report")

END FUNCTION


REPORT CMTform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "================================="
      PRINT COLUMN 20, "|   COMPARTMENT TRACKING LIST   |"
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
END REPORT

REPORT CMTmaterial( row_no )
  DEFINE row_no  INTEGER

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      LET g_pce = 0

      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "-----------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 51 , "C O M P A R T M E N T",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 46 , "T R A C K I N G   L I S T" 
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "-----------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1,   "ITEM",
            COLUMN 7,   "COMPART NAME",
	    COLUMN 20,  "PART NUMBER",
	    COLUMN 35,  "PART REV",
            COLUMN 49,  "DESCRIPTION",
	    COLUMN 75,  "ASSEMBLY CATALOG",
	    COLUMN 95,  "ASSEMBLY NAME",
	    COLUMN 115, "ASSEMBLY REV"
      PRINT COLUMN 1,   "======",
            COLUMN 7,   "==================", 
	    COLUMN 20,  "=================",
	    COLUMN 35,  "=============",
            COLUMN 49,  "====================",
            COLUMN 75,  "===============",
	    COLUMN 95,  "=================",
	    COLUMN 115, "================="

    PAGE HEADER
      LET p_pce = 0

      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"

      SKIP 1 LINE
      PRINT COLUMN 1,   "ITEM",
            COLUMN 10,   "COMPART NAME",
	    COLUMN 20,  "PART NUMBER",
	    COLUMN 35,  "PART REV",
            COLUMN 49,  "DESCRIPTION",
	    COLUMN 75,  "ASSEMBLY CATALOG",
	    COLUMN 95,  "ASSEMBLY NAME",
	    COLUMN 115, "ASSEMBLY REV"
      PRINT COLUMN 1,   "======",
            COLUMN 10,   "==================", 
	    COLUMN 20,  "=================",
	    COLUMN 35,  "=============",
            COLUMN 49,  "====================",
            COLUMN 75,  "===============",
	    COLUMN 95,  "=================",
	    COLUMN 115, "================="


      ON EVERY ROW

	 LET p_pce = p_pce + 1
	 LET g_pce = g_pce + 1

         PRINT COLUMN 1,   row_no USING "#####&",
               COLUMN 10,   p_cmt2.cmp_name CLIPPED,    
               COLUMN 20,  p_cmt2.partno CLIPPED,    
               COLUMN 35,  p_cmt2.partrev CLIPPED,    
               COLUMN 49,  p_cmt2.descript CLIPPED,
	       COLUMN 75,  p_cmt2.assembly_cat CLIPPED,
	       COLUMN 95,  p_cmt2.assembly_nam CLIPPED,
	       COLUMN 115, p_cmt2.assembly_ver CLIPPED

    PAGE TRAILER
         PRINT COLUMN 1,   "----------------------------------------",
               COLUMN 41,  "----------------------------------------",
               COLUMN 81,  "----------------------------------"
	 PRINT COLUMN 1,  p_pce USING "PAGE ITEM COUNT: <<<<<"
         PRINT COLUMN 1,   "----------------------------------------",
               COLUMN 41,  "----------------------------------------",
               COLUMN 81,  "----------------------------------"
    ON LAST ROW
	SKIP TO TOP OF PAGE

END REPORT

REPORT CMTend ()

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
      PRINT COLUMN 1,  g_pce USING "GRAND TOTAL PIECES: <<<<<"
      PRINT COLUMN 1,   "========================================",
            COLUMN 41,  "========================================",
            COLUMN 81,  "=================================="
END REPORT
