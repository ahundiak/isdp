DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BMNmain ()

  IF p_vds.prj_units_set != 1 THEN
     CALL nsts_error ()
     MESSAGE nsts_err_msg
     SLEEP 3
     CALL ERRORLOG (nsts_err_msg)
     GOTO abort
  END IF


  CALL ERRORLOG ("Enter in  Beam NSTS report")
  MESSAGE "Beam NSTS report in progress... please wait"

  START REPORT BMNform TO "BMNform"
     OUTPUT TO REPORT BMNform ()
  FINISH REPORT BMNform

  CALL BMNquery ()
  PREPARE bmn_stmt FROM q_stmt
  DECLARE bmn_curs CURSOR FOR bmn_stmt

  START REPORT BMNmaterial TO PIPE "BMN.sh"
     FOREACH bmn_curs INTO p_bmn.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in the query")
           SLEEP 3
           EXIT FOREACH
        ELSE
	   CALL BMNconvert ()
           OUTPUT TO REPORT BMNmaterial ()
        END IF
     END FOREACH
  FINISH REPORT BMNmaterial

  MESSAGE "Beam NSTS report achieved"
  CALL ERRORLOG ("Exit from Beam NSTS report")

  LABEL abort:
END FUNCTION


REPORT BMNform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "================================="
      PRINT COLUMN 20, "|  STRUCTURAL BEAM NSTS REPORT  |"
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


REPORT BMNmaterial ()
  DEFINE	elem_no	INTEGER


  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66


  FORMAT
    FIRST PAGE HEADER
      LET elem_no = 0
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 40 , "S T R U C T U R A L  B E A M  R E P O R T",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      SKIP 2 LINES
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 40, "LIST OF MATERIAL (QUANTITY FOR ONE SHIP)"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 56,  "LAST"  
      PRINT COLUMN 1,   "S/A",
            COLUMN 5,   "ITEM", 
            COLUMN 10,  "QTY", 
            COLUMN 18,  "DESCRIPTION", 
            COLUMN 57,  "NO", 
            COLUMN 61,  "SIZE",
            COLUMN 67,  "MTL SPEC",
            COLUMN 77,  "MTL REQ", 
            COLUMN 86,  "NEW/MFR",
	    COLUMN 94,  "SCE",
            COLUMN 99,  "APL",
            COLUMN 104, "UNIT WT.",
            COLUMN 117, "REMARKS"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   "NO", 
               COLUMN 6,   "NO",
               COLUMN 10,  "REQD",
               COLUMN 56,  "USED", 
               COLUMN 61,  "MOD",
               COLUMN 87,  "PT NO",
               COLUMN 99,  "NO.",
               COLUMN 104, " (LB)"
      ELSE
         PRINT COLUMN 1,   "NO", 
               COLUMN 6,   "NO",
               COLUMN 10,  "REQD",
               COLUMN 56,  "USED", 
               COLUMN 61,  "MOD",
               COLUMN 87,  "PT NO",
               COLUMN 99,  "NO.",
               COLUMN 104, " (KG)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 line
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 1,  "LIST OF MATERIAL (QUANTITY FOR ONE SHIP)"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"
      PRINT COLUMN 56,  "LAST"  
      PRINT COLUMN 1,   "S/A",
            COLUMN 5,   "ITEM", 
            COLUMN 10,  "QTY", 
            COLUMN 18,  "DESCRIPTION", 
            COLUMN 57,  "NO", 
            COLUMN 61,  "SIZE",
            COLUMN 67,  "MTL SPEC",
            COLUMN 77,  "MTL REQ", 
            COLUMN 86,  "NEW/MFR",
	    COLUMN 94,  "SCE",
            COLUMN 99,  "APL",
            COLUMN 104, "UNIT WT.",
            COLUMN 117, "REMARKS"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   "NO", 
               COLUMN 6,   "NO",
               COLUMN 10,  "REQD",
               COLUMN 56,  "USED", 
               COLUMN 61,  "MOD",
               COLUMN 87,  "PT NO",
               COLUMN 99,  "NO.",
               COLUMN 104, " (LB)"
      ELSE
         PRINT COLUMN 1,   "NO", 
               COLUMN 6,   "NO",
               COLUMN 10,  "REQD",
               COLUMN 56,  "USED", 
               COLUMN 61,  "MOD",
               COLUMN 87,  "PT NO",
               COLUMN 99,  "NO.",
               COLUMN 104, " (KG)"
      END IF
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"


      ON EVERY ROW
         LET elem_no = elem_no + 1

      CALL BMNdescription ()

      PRINT COLUMN 1,   p_bmn.long_txt CLIPPED,
            COLUMN 5,   elem_no USING "##&", 
            COLUMN 10,  " 1",
            COLUMN 18,  p_bmn.f_part_num,
            COLUMN 56,
            COLUMN 61,
            COLUMN 70,  p_bmn.material CLIPPED,
	    COLUMN 80,  p_bmn.grade CLIPPED,
	    COLUMN 86,
	    COLUMN 94,  p_bmn.constr_stat CLIPPED,
	    COLUMN 99, 
	    COLUMN 104, p_bmn.volume * p_bmn.density USING "########.&",
	    COLUMN 117, " "

END REPORT
