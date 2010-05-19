DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION EQNmain ()

  IF p_vds.prj_units_set != 1 THEN
     CALL nsts_error ()
     MESSAGE nsts_err_msg
     SLEEP 3
     CALL ERRORLOG (nsts_err_msg)
     GOTO abort
  END IF


  CALL ERRORLOG ("Enter in  Equipment Nsts report")
  MESSAGE "Equipment Nsts report in progress... please wait"

  START REPORT EQNform TO "EQNform"
    OUTPUT TO REPORT EQNform ()
  FINISH REPORT EQNform

  CALL EQNquery ()
  PREPARE eqn_stmt FROM q_stmt
  DECLARE eqn_curs CURSOR FOR eqn_stmt

  START REPORT EQNmaterial TO PIPE "EQN.sh"
     FOREACH eqn_curs INTO p_eqn.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT EQNmaterial ()
        END IF
     END FOREACH
  FINISH REPORT EQNmaterial

  MESSAGE "Equipment Nsts report achieved"
  CALL ERRORLOG ("Exit from Equipment Nsts report")

  LABEL abort:
END FUNCTION


REPORT EQNform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "=========================================="
      PRINT COLUMN 20, "|    EQUIPMENT NSTS CONTROL WORKSHEET    |"
      PRINT COLUMN 20, "=========================================="
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


REPORT EQNmaterial ()
  DEFINE EQNdesc        CHAR(20),
         EQNwet_wgt     FLOAT,
         elem_no        INTEGER


  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
            LET elem_no = 0
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 47 , "  E Q U I P M E N T  N S T S  R E P O R T",
            COLUMN 108, "Page - 1"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      SKIP 2 LINES
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      PRINT COLUMN 40 , "LIST OF MATERIAL (QUANTITY FOR ONE SHIP)"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      PRINT COLUMN 1  , "S/A",
            COLUMN 6  , "ITEM",
            COLUMN 12 , "QTY",
            COLUMN 18 , "DESCRIPTION",
            COLUMN 46 , "SOURCE",
            COLUMN 57 , "ORD",
            COLUMN 63 , "FND",
            COLUMN 69 , "APL NO.",
            COLUMN 78 , "UNIT",
            COLUMN 87 , "NO.",
            COLUMN 105, "REMARKS"
      PRINT COLUMN 1  , "NO",
            COLUMN 7  , "NO",
            COLUMN 12 , "REQD",
            COLUMN 57 , "ON",
            COLUMN 63 , "ON",
            COLUMN 79 , "WT.",
            COLUMN 86 , "WATTS"
      PRINT COLUMN 45 , "N",
            COLUMN 49 , "E",
            COLUMN 53 , "R",
            COLUMN 57 , "REF",
            COLUMN 63 , "REF"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"





    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      PRINT COLUMN 40 , "LIST OF MATERIAL (QUANTITY FOR ONE SHIP)"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      PRINT COLUMN 1  , "S/A",
            COLUMN 6  , "ITEM",
            COLUMN 12 , "QTY",
            COLUMN 18 , "DESCRIPTION",
            COLUMN 46 , "SOURCE",
            COLUMN 57 , "ORD",
            COLUMN 63 , "FND",
            COLUMN 69 , "APL NO.",
            COLUMN 78 , "UNIT",
            COLUMN 87 , "NO.",
            COLUMN 105, "REMARKS"
      PRINT COLUMN 1  , "NO",
            COLUMN 7  , "NO",
            COLUMN 12 , "REQD",
            COLUMN 57 , "ON",
            COLUMN 63 , "ON",
            COLUMN 79 , "WT.",
            COLUMN 86 , "WATTS"
      PRINT COLUMN 45 , "N",
            COLUMN 49 , "E",
            COLUMN 53 , "R",
            COLUMN 57 , "REF",
            COLUMN 63 , "REF"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"


      ON EVERY ROW
      LET elem_no = elem_no + 1
      CALL EQNdescription () 
           RETURNING EQNdesc, EQNwet_wgt

      PRINT COLUMN 1,   p_eqn.long_txt CLIPPED ,
            COLUMN 7,   elem_no USING "##&",
            COLUMN 13,  "1",
            COLUMN 18,  EQNdesc CLIPPED,
            COLUMN 45,  
            COLUMN 49,
            COLUMN 53,
            COLUMN 57,
            COLUMN 63,
            COLUMN 69,
            COLUMN 78,  EQNwet_wgt USING "####.&",
            COLUMN 87,  
            COLUMN 93,  " " 

END REPORT
