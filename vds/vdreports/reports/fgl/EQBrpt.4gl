DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION EQBmain ()

  CALL ERRORLOG ("Enter in  Equipment BOM report")
  MESSAGE "Equipment BOM report in progress... please wait"

  START REPORT EQBform TO "EQBform"
    OUTPUT TO REPORT EQBform ()
  FINISH REPORT EQBform

  CALL EQBquery ()
  PREPARE eqb_stmt FROM q_stmt
  DECLARE eqb_curs CURSOR FOR eqb_stmt

  START REPORT EQBlist TO PIPE "EQB.sh"
     FOREACH eqb_curs INTO p_eqb.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT EQBlist  (p_eqb.eqp_type)
        END IF
     END FOREACH
  FINISH REPORT EQBlist 
  

  MESSAGE "Equipment BOM report achieved"
  CALL ERRORLOG ("Exit from Equipment BOM report")
END FUNCTION



REPORT EQBform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "==============================="
      PRINT COLUMN 20, "|   EQUIPMENT MATERIAL LIST   |"
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
END REPORT


REPORT EQBlist  (p_4gl)
  DEFINE p_4gl RECORD eqp_type LIKE "nfmadmin".equip_dynamic.eqp_type END RECORD
  DEFINE row_no  INTEGER


  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "-----------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 51 , "E Q U I P M E N T",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 46 , "M A T E R I A L   L I S T" 
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "-----------------------------------------------"

    LET row_no = 1

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"

      BEFORE GROUP OF p_4gl.eqp_type
      SKIP 1 LINE
      PRINT COLUMN 1,  "TYPE : ",
            COLUMN 10,  p_eqb.eqp_type CLIPPED
      SKIP 1 LINE
      PRINT COLUMN 1,   "ITEM",
            COLUMN 12,  "ITEM NUMBER",
            COLUMN 37,  "DESCRIPTION", 
            COLUMN 82,  "PART NUMBER"
      PRINT COLUMN 1,   "======",
            COLUMN 12,  "====================",
            COLUMN 37,  "========================================", 
            COLUMN 82,  "===================="


      ON EVERY ROW

      PRINT COLUMN 1,   row_no USING "#####&",
            COLUMN 12,  p_eqb.eqp_number CLIPPED,
            COLUMN 37,  p_eqb.eqp_descr CLIPPED,    
            COLUMN 82,  p_eqb.eqp_partno CLIPPED


      LET row_no = row_no + 1

END REPORT

