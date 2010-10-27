DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PLNmain ()

  IF p_vds.prj_units_set != 1 THEN
     CALL nsts_error ()
     MESSAGE nsts_err_msg
     SLEEP 3
     CALL ERRORLOG (nsts_err_msg)
     GOTO abort
  END IF
 

  CALL ERRORLOG ("Enter in  Plate NSTS report")
  MESSAGE "Plate NSTS report in progress... please wait"

  START REPORT PLNform TO "PLNform"
    OUTPUT TO REPORT PLNform ()
  finish REPORT PLNform

  CALL PLNquery ()
  PREPARE pln_stmt FROM q_stmt
  DECLARE pln_curs CURSOR FOR pln_stmt

  START REPORT PLNmaterial TO PIPE "PLN.sh"
     FOREACH pln_curs INTO p_pln.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in the query")
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL PLNconvert ()
           OUTPUT TO REPORT PLNmaterial ()
        END IF
     END FOREACH
  FINISH REPORT PLNmaterial

  MESSAGE "Plate NSTS report achieved"
  CALL ERRORLOG ("Exit from Plate NSTS report")

  LABEL abort:
END FUNCTION


REPORT PLNform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    first PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "=================================="
      PRINT COLUMN 20, "|  STRUCTURAL PLATE NSTS REPORT  |"
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


REPORT PLNmaterial ()

  DEFINE	elem_no		INTEGER,
  		temp_len	CHAR(15),
  		temp_wid	CHAR(15),
  		temp_thk	CHAR(15),
  		sce		CHAR(3)


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
            COLUMN 40 , "S T R U C T U R A L  P L A T E  R E P O R T",
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
            COLUMN 29,  "DESCRIPTION", 
            COLUMN 57,  "NO", 
            COLUMN 61,  "SIZE",
            COLUMN 67,  "MTL SPEC",
            COLUMN 77,  "MTL REQ", 
            COLUMN 86,  "NEW/MFR",
	    COLUMN 94,  "SCE",
            COLUMN 99,  "APL",
            COLUMN 104, "UNIT WT.",
            COLUMN 117, "REMARKS"
         PRINT COLUMN 1,   "NO", 
               COLUMN 6,   "NO",
               COLUMN 10,  "REQD",
               COLUMN 56,  "USED", 
               COLUMN 61,  "MOD",
               COLUMN 87,  "PT NO",
               COLUMN 99,  "NO.",
               COLUMN 104, " (LB)"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
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
            COLUMN 29,  "DESCRIPTION", 
            COLUMN 57,  "NO", 
            COLUMN 61,  "SIZE",
            COLUMN 67,  "MTL SPEC",
            COLUMN 77,  "MTL REQ", 
            COLUMN 86,  "NEW/MFR",
	    COLUMN 94,  "SCE",
            COLUMN 99,  "APL",
            COLUMN 104, "UNIT WT.",
            COLUMN 117, "REMARKS"
         PRINT COLUMN 1,   "NO", 
               COLUMN 6,   "NO",
               COLUMN 10,  "REQD",
               COLUMN 56,  "USED", 
               COLUMN 61,  "MOD",
               COLUMN 87,  "PT NO",
               COLUMN 99,  "NO.",
               COLUMN 104, " (LB)"
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------------------"


      ON EVERY ROW
      LET elem_no = elem_no + 1

      CALL PLNdescription ()

      CALL element_length  ( p_pln.pl_len, 32) RETURNING temp_len
      CALL element_length  ( p_pln.pl_wid, 32) RETURNING temp_wid
      CALL fraction_format ( p_pln.pl_thk, 32) RETURNING temp_thk

      PRINT COLUMN 1,   p_pln.long_txt CLIPPED,
            COLUMN 5,   elem_no USING "##&", 
            COLUMN 10,  " 1",
            COLUMN 15,  "PLATE,", temp_len CLIPPED, "X",
                        temp_wid CLIPPED, "X", temp_thk clipped, "\"",
            COLUMN 56,
            COLUMN 61,
            COLUMN 70,  p_pln.material CLIPPED,
     	    COLUMN 80,  p_pln.grade CLIPPED,
	    COLUMN 86,
	    COLUMN 94,  sce CLIPPED,
	    COLUMN 99, 
	    COLUMN 104, p_pln.pl_vol * p_pln.density USING "########.&",
	    COLUMN 117, " "
END REPORT
