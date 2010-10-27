DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION RWNmain ()

  IF p_vds.prj_units_set != 1 THEN
     CALL nsts_error ()
     MESSAGE nsts_err_msg
     SLEEP 3
     CALL ERRORLOG (nsts_err_msg)
     GOTO abort
  END IF


  CALL ERRORLOG ("Enter in  Rway Nsts report")
  MESSAGE "Rway Nsts report in progress... please wait"

  START REPORT RWNform TO "RWNform"
    OUTPUT TO REPORT RWNform ()
  FINISH REPORT RWNform

  CALL RWNquery ()
  PREPARE rwn_stmt FROM q_stmt
  DECLARE rwn_curs CURSOR FOR rwn_stmt
  START REPORT RWNmaterial TO PIPE "RWN.sh"
     FOREACH rwn_curs INTO p_rwn.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in main query")
           MESSAGE "No rows found in main query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT RWNmaterial ()
        END IF
     END FOREACH

  FINISH REPORT RWNmaterial

  MESSAGE "Rway Nsts report completed"
  CALL ERRORLOG ("Exit from Rway Nsts report")

  LABEL abort:
END FUNCTION



REPORT RWNform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "=================================="
      PRINT COLUMN 20, "| RACEWAY NSTS CONTROL WORKSHEET |"
      PRINT COLUMN 20, "=================================="
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
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_rw.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_rw.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_rw.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_rw.constr_stat CLIPPED, COLUMN 32, "]"
END REPORT


REPORT RWNmaterial ()
  DEFINE RWNdesc	CHAR(30),
	 RWNcom_wgt	FLOAT,
         element_no     INTEGER,
         sce            CHAR(10),
         mat            CHAR(15)

  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
            LET element_no = 0
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      PRINT COLUMN 1  , "DATE:",
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 47 , "R W A Y  N S T S  R E P O R T",
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
            COLUMN 43 , "MTL SPEC",
            COLUMN 53 , "MTL REQ",
            COLUMN 62 , "NEW OR MFR",
            COLUMN 74 , "SCE",
            COLUMN 89 , "UNIT",
            COLUMN 110, "REMARKS"
      PRINT COLUMN 1  , "NO",
            COLUMN 7  , "NO",
            COLUMN 12 , "REQD",
            COLUMN 63 , "PART NO",
            COLUMN 90 , "WT"
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
            COLUMN 43 , "MTL SPEC",
            COLUMN 53 , "MTL REQ",
            COLUMN 62 , "NEW OR MFR",
            COLUMN 74 , "SCE",
            COLUMN 89 , "UNIT",
            COLUMN 110, "REMARKS"
      PRINT COLUMN 1  , "NO",
            COLUMN 7  , "NO",
            COLUMN 12 , "REQD",
            COLUMN 63 , "PART NO",
            COLUMN 90 , "WT"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"

    ON EVERY ROW
      LET element_no = element_no + 1
      CALL RWNdescription () RETURNING RWNdesc, RWNcom_wgt

      IF p_rwn.constr_stat != " "
      OR p_rwn.constr_stat != ""
      OR p_rwn.constr_stat IS NOT NULL THEN LET sce = p_rwn.constr_stat
      ELSE 				     LET sce = "U/F"
      END IF

      IF p_rwn.ship_alt = "undefined" THEN LET p_rwn.ship_alt = " "
      END IF

      IF p_rwn.d_material = "carbon steel" THEN LET mat = "steel"
         ELSE 					 LET mat = p_rwn.d_material
      END IF

      PRINT COLUMN 1  , p_rwn.ship_alt CLIPPED,
	    COLUMN 7  , element_no USING "##&",
            COLUMN 13 , "1",
	    COLUMN 18 , RWNdesc CLIPPED,
	    COLUMN 43 , mat CLIPPED,
	    COLUMN 53 , 
	    COLUMN 63 , p_rwn.comp_code CLIPPED,
	    COLUMN 74 , sce CLIPPED,
	    COLUMN 79 , 
	    COLUMN 87 , RWNcom_wgt USING "####&.&",
	    COLUMN 110, mat CLIPPED
END REPORT
