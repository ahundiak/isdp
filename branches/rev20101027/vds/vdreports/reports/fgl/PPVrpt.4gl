DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPVmain ()

  CALL update_piping_off()

  CALL ERRORLOG ("Enter in  Piping Valve report")
  MESSAGE "Piping Valve report in progress... please wait"

  START REPORT PPVform TO "PPVform"
    OUTPUT TO REPORT PPVform ()
  FINISH REPORT PPVform

  CALL PPVquery ()
  PREPARE ppv_stmt FROM q_stmt
  DECLARE ppv_curs CURSOR FOR ppv_stmt
  START REPORT PPVlist TO pipe "PPV.sh"
  FOREACH ppv_curs INTO p_ppv.*
    IF STATUS < 0 THEN
       CALL ERRORLOG ("No rows found in query")
       SLEEP 3
       EXIT FOREACH
    ELSE
       OUTPUT TO REPORT PPVlist (p_ppv.seq_number)
     END IF
  END FOREACH
  
  FINISH REPORT PPVlist

  MESSAGE "Piping Valve report achieved"
  CALL ERRORLOG ("Exit from Piping Valve report")
END FUNCTION



REPORT PPVform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "============================="
      PRINT COLUMN 20, "|     PIPING VALVE LIST     |"
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
            COLUMN 21, "[", COLUMN 23, p_pp.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_pp.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_pp.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_pp.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_pp.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_pp.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_pp.constr_stat CLIPPED, COLUMN 32, "]"
END REPORT


REPORT PPVlist (p_4gl)
  DEFINE p_4gl RECORD seq_number LIKE "nfmadmin".piping_dynamic.seq_number END RECORD

  DEFINE	PPVdesc	CHAR(40),
		PPVsize	CHAR(30)

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 46 , "P I P I N G",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 43 , "V A L V E  L I S T"
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------"

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"

      BEFORE GROUP OF p_4gl.seq_number
      SKIP 1 LINE
      PRINT COLUMN 1,  "SYSTEM : ",
            COLUMN 10,  p_ppv.seq_number CLIPPED
      SKIP 1 LINE
      PRINT COLUMN 1,   "ITEM",
            COLUMN 9,   "DESCRIPTION",
            COLUMN 51,  "SIZE", 
            COLUMN 63,  "COMMODITY",
            COLUMN 81,  "REMARKS"
      PRINT COLUMN 1,   "======",
            COLUMN 9,   "========================================",
            COLUMN 51,  "==========", 
            COLUMN 63,  "================",
            COLUMN 81,  "==============================" 


      ON EVERY ROW
         CALL PPVdescription () RETURNING PPVdesc, PPVsize
         PRINT COLUMN 1,   p_ppv.short_code CLIPPED,
               COLUMN 9,   PPVdesc CLIPPED, 
               COLUMN 51,  PPVsize CLIPPED,
               COLUMN 63,  p_ppv.commodity CLIPPED,
               COLUMN 81,  p_ppv.comp_note CLIPPED

END REPORT
