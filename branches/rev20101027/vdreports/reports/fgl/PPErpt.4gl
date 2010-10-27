DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPEmain ()

  CALL update_piping_on()

  CALL ERRORLOG ("Enter in  Piping Error report")
  MESSAGE "Piping Error report in progress... please wait"

  START REPORT PPEform TO "PPEform"
    OUTPUT TO REPORT PPEform ()
  FINISH REPORT PPEform

  CALL PPEquery ()
  PREPARE ppe_stmt FROM q_stmt
  DECLARE ppe_curs CURSOR FOR ppe_stmt

  START REPORT PPEmaterial TO PIPE "PPE.sh"
     FOREACH ppe_curs INTO p_ppe.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT PPEmaterial (p_ppe.seq_number)
         END IF
     END FOREACH
  
  FINISH REPORT PPEmaterial

  MESSAGE "Piping Error report achieved"
  CALL ERRORLOG ("Exit from Piping Error report")
END FUNCTION



REPORT PPEform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "================================="
      PRINT COLUMN 20, "| PIPING ERROR COMPONENT REPORT |"
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


REPORT PPEmaterial (p_4gl)
  DEFINE p_4gl RECORD seq_number LIKE "nfmadmin".piping_dynamic.seq_number END RECORD

  DEFINE	npd_g_frac	CHAR(30),
         	npd_r_frac	CHAR(30)


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
            COLUMN 46 , "P I P I N G   E R R O R",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 43 , "C O M P O N E N T  R E P O R T"
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "----------------------------------------"

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"

      BEFORE GROUP OF p_4gl.seq_number
      SKIP 1 LINE
      PRINT COLUMN 1,  "SYSTEM : ",
            COLUMN 10,  p_ppe.seq_number CLIPPED
      SKIP 1 LINE
      PRINT COLUMN 19,  "NPD", 
            COLUMN 28,  "NPD"

      CASE p_vds.prj_units_set
         WHEN 1
            PRINT COLUMN 1,   "SPEC",
                  COLUMN 11,  "COMP",
                  COLUMN 19,  "GRN", 
                  COLUMN 28,  "RED",
                  COLUMN 37,  "OPT", 
                  COLUMN 42,  "X (IN)",
                  COLUMN 54,  "Y (IN)", 
                  COLUMN 66,  "Z (IN)",
	          COLUMN 78, "DESCRIPTION"
         WHEN 10
         WHEN 20
            PRINT COLUMN 1,   "SPEC",
                  COLUMN 11,  "COMP",
                  COLUMN 19,  "GRN", 
                  COLUMN 28,  "RED",
                  COLUMN 37,  "OPT", 
                  COLUMN 42,  "X (MM)",
                  COLUMN 54,  "Y (MM)", 
                  COLUMN 66,  "Z (MM)",
	          COLUMN 78, "DESCRIPTION"
      END CASE

      PRINT COLUMN 1,   "========",
            COLUMN 11,  "======",
            COLUMN 19,  "=======", 
            COLUMN 28,  "=======",
            COLUMN 37,  "===", 
            COLUMN 42,  "==========",
            COLUMN 54,  "==========", 
            COLUMN 66,  "==========",
	    COLUMN 78,  "========================================"


      ON EVERY ROW
      CALL size_of_element ( p_ppe.npd_g, 0.0) RETURNING npd_g_frac
      CALL size_of_element ( p_ppe.npd_r, 0.0) RETURNING npd_r_frac

      CASE p_vds.prj_units_set
         WHEN 1
            PRINT COLUMN 1,   p_ppe.spec_name CLIPPED,
                  COLUMN 11,  p_ppe.comp_code CLIPPED,
                  COLUMN 19,  npd_g_frac CLIPPED, "\"",
                  COLUMN 28,  npd_r_frac CLIPPED, "\"",
                  COLUMN 37,  p_ppe.opt_code USING "##&",
                  COLUMN 42,  p_ppe.loc_x USING "#######.&", 
	          COLUMN 54,  p_ppe.loc_y USING "#######.&",
	          COLUMN 66,  p_ppe.loc_z USING "#######.&", 
	          COLUMN 78, "\UNKNOWN"
         WHEN 10
            PRINT COLUMN 1,   p_ppe.spec_name CLIPPED,
                  COLUMN 11,  p_ppe.comp_code CLIPPED,
                  COLUMN 19,  npd_g_frac CLIPPED, "\"",
                  COLUMN 28,  npd_r_frac CLIPPED, "\"",
                  COLUMN 37,  p_ppe.opt_code USING "##&",
                  COLUMN 42,  p_ppe.loc_x USING "######&.", 
	          COLUMN 54,  p_ppe.loc_y USING "######&.",
	          COLUMN 66,  p_ppe.loc_z USING "######&.", 
	          COLUMN 78, "\UNKNOWN"
         WHEN 20
            PRINT COLUMN 1,   p_ppe.spec_name CLIPPED,
                  COLUMN 11,  p_ppe.comp_code CLIPPED,
                  COLUMN 19,  npd_g_frac CLIPPED,
                  COLUMN 28,  npd_r_frac CLIPPED,
                  COLUMN 37,  p_ppe.opt_code USING "##&",
                  COLUMN 42,  p_ppe.loc_x USING "######&.", 
	          COLUMN 54,  p_ppe.loc_y USING "######&.",
	          COLUMN 66,  p_ppe.loc_z USING "######&.", 
	          COLUMN 78, "\UNKNOWN"
      END CASE
END REPORT
