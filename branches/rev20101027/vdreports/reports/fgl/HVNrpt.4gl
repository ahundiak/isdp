DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVNmain ()
  DEFINE p_calc RECORD comp_wt_star	CHAR(1),
		       insul_star	CHAR(1)
                END RECORD

  IF p_vds.prj_units_set != 1 THEN
     CALL nsts_error ()
     MESSAGE nsts_err_msg
     SLEEP 3
     CALL ERRORLOG (nsts_err_msg)
     GOTO abort
  END IF


  CALL ERRORLOG ("Enter in  Hvac Nsts report")
  MESSAGE "Hvac Nsts report in progress... please wait"

  START REPORT HVNform to "HVNform"
    OUTPUT to REPORT HVNform ()
  FINISH REPORT HVNform

  CALL HVNquery ()
  PREPARE hvn_stmt FROM q_stmt
  DECLARE hvn_curs CURSOR FOR hvn_stmt

  START REPORT HVNmaterial TO PIPE "HVN.sh"
     FOREACH hvn_curs INTO p_hvn.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           MESSAGE "No rows found in query"
           SLEEP 3
           EXIT FOREACH
        ELSE
	   CALL HVNconvert (p_calc.*)
                RETURNING p_calc.comp_wt_star, p_calc.insul_star
           OUTPUT TO REPORT HVNmaterial (p_calc.*)
        END IF
     END FOREACH

  FINISH REPORT HVNmaterial

  MESSAGE "Hvac Nsts report completed"
  CALL ERRORLOG ("Exit from Hvac Nsts report")

  LABEL abort:
END FUNCTION



REPORT HVNform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "==============================="
      PRINT COLUMN 20, "| HVAC NSTS CONTROL WORKSHEET |"
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
            COLUMN 21, "[", COLUMN 23, p_hv.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_hv.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_hv.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_hv.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_hv.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_hv.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_hv.constr_stat CLIPPED, COLUMN 32, "]"
END REPORT


REPORT HVNmaterial (r_calc)
  DEFINE r_calc RECORD comp_wt_star	CHAR(1),
		       insul_star	CHAR(1)
                END RECORD
  DEFINE HVNdesc	CHAR(40),
	 HVNwet_wgt	FLOAT,
	 HVNins_wgt	FLOAT,
	 HVNtot_wgt	FLOAT,
         element_no     INTEGER,
         sce            CHAR(3)

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
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 47 , "H V A C  N S T S  R E P O R T",
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
            COLUMN 5  , "ITEM",
            COLUMN 10 , "QTY",
            COLUMN 15 , "DESCRIPTION",
            COLUMN 38 , "MIC",
            COLUMN 42 , "PP",
            COLUMN 45 , "CAST",
            COLUMN 51 , "MTL SPEC",
            COLUMN 60 , "MTL REQ",
            COLUMN 70 , "NEW OR MFR",
            COLUMN 82 , "SCE",
            COLUMN 86 , "SERVICE",
            COLUMN 94 , "TEST",
            COLUMN 100, "APL",
            COLUMN 107, "UNIT",
            COLUMN 115, "REMARKS"
      PRINT COLUMN 1  , "NO",
            COLUMN 6  , "NO",
            COLUMN 10 , "REQD",
            COLUMN 38 , "LVL",
            COLUMN 42 , "CL",
            COLUMN 45 , "CAT",
            COLUMN 71 , "PART NO",
            COLUMN 94 , "PRESS",
            COLUMN 108, "WT"
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
            COLUMN 5  , "ITEM",
            COLUMN 10 , "QTY",
            COLUMN 15 , "DESCRIPTION",
            COLUMN 38 , "MIC",
            COLUMN 42 , "PP",
            COLUMN 45 , "CAST",
            COLUMN 51 , "MTL SPEC",
            COLUMN 60 , "MTL REQ",
            COLUMN 70 , "NEW OR MFR",
            COLUMN 82 , "SCE",
            COLUMN 86 , "SERVICE",
            COLUMN 94 , "TEST",
            COLUMN 100, "APL",
            COLUMN 107, "UNIT",
            COLUMN 115, "REMARKS"
      PRINT COLUMN 1  , "NO",
            COLUMN 6  , "NO",
            COLUMN 10 , "REQD",
            COLUMN 38 , "LVL",
            COLUMN 42 , "CL",
            COLUMN 45 , "CAT",
            COLUMN 71 , "PART NO",
            COLUMN 94 , "PRESS",
            COLUMN 108, "WT"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"

    ON EVERY ROW
      LET element_no = element_no + 1
      CALL HVNdescription () 
           RETURNING HVNdesc, 
		     HVNwet_wgt, HVNins_wgt, HVNtot_wgt


      IF p_hvn.constr_stat != " "
      OR p_hvn.constr_stat != ""
      OR p_hvn.constr_stat IS NOT NULL THEN LET sce = p_hvn.constr_stat
      ELSE
         				       LET sce = "U/F"
      END IF

      IF p_hvn.ship_alt = "undefined"
      OR p_hvn.ship_alt = "Undefined" THEN LET p_hvn.ship_alt = " "
      END IF


      PRINT COLUMN 1  , p_hvn.ship_alt CLIPPED,
            COLUMN 5  , element_no USING "##&",
            COLUMN 11 , "1",
            COLUMN 15 , HVNdesc CLIPPED,
            COLUMN 41 ,
            COLUMN 42 ,
            COLUMN 45 ,
            COLUMN 51 , p_hvn.material CLIPPED,
            COLUMN 61 ,
            COLUMN 71 , p_hvn.comp_code CLIPPED,
            COLUMN 82 , sce CLIPPED,
            COLUMN 89 , p_hvn.spec_name CLIPPED,
            COLUMN 94 ,
            COLUMN 100,
            COLUMN 107, HVNtot_wgt USING "####&.&",
            COLUMN 115, " "


END REPORT
