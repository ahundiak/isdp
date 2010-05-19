DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVEmain ()

  CALL ERRORLOG ("Enter in  Hvac Error report")
  MESSAGE "Hvac Error report in progress... please wait"

  START REPORT HVEform TO "HVEform"
    OUTPUT TO REPORT HVEform ()
  FINISH REPORT HVEform

  CALL HVEquery ()
  PREPARE hve_stmt FROM q_stmt
  DECLARE hve_curs CURSOR FOR hve_stmt

  START REPORT HVEerror TO PIPE "HVE.sh"
     FOREACH hve_curs INTO p_hve.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           MESSAGE "No rows found in query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT HVEerror (p_hve.system_name)
        END IF
     END FOREACH
  
  FINISH REPORT HVEerror

  MESSAGE "Hvac Error report achieved"
  CALL ERRORLOG ("Exit from Hvac Error report")
END FUNCTION



REPORT HVEform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "==============================="
      PRINT COLUMN 20, "| HVAC ERROR COMPONENT REPORT |"
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


REPORT HVEerror (p_4gl)
  DEFINE p_4gl RECORD   system_name LIKE "nfmadmin".hvac_dynamic.system_name END RECORD
  DEFINE wid_g       CHAR(10),
         dep_g       CHAR(10),
         wid_r       CHAR(10),
         dep_r       CHAR(10)


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
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 51 , "H V A C     E R R O R",
            COLUMN 106, "Page - 1"
      PRINT COLUMN 46 , "C O M P O N E N T   R E P O R T"
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "-----------------------------------------------"

    PAGE HEADER
      PRINT COLUMN 106, "Page - ", PAGENO USING "<<<"

      BEFORE GROUP OF p_4gl.system_name
      SKIP 1 LINE
      PRINT COLUMN 1,  "SYSTEM : ",
            COLUMN 10,  p_hve.system_name CLIPPED
      SKIP 1 LINE
      PRINT COLUMN 19,  "WIDTH", 
            COLUMN 28,  "DEPTH",
            COLUMN 37,  "WIDTH", 
            COLUMN 46,  "DEPTH", 
            COLUMN 55,  "SHP" 
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1,   "CLASS",
               COLUMN 11,  "COMP",
               COLUMN 19,  "GRN", 
               COLUMN 28,  "GRN",
               COLUMN 37,  "RED", 
               COLUMN 46,  "RED", 
               COLUMN 55,  "CODE", 
               COLUMN 61,  "X (IN)",
               COLUMN 73,  "Y (IN)", 
               COLUMN 85,  "Z (IN)",
	       COLUMN 97, "DESCRIPTION"
         ELSE
         PRINT COLUMN 1,   "CLASS",
               COLUMN 11,  "COMP",
               COLUMN 19,  "GRN", 
               COLUMN 28,  "GRN",
               COLUMN 37,  "RED", 
               COLUMN 46,  "RED", 
               COLUMN 55,  "CODE", 
               COLUMN 61,  "X (MM)",
               COLUMN 73,  "Y (MM)", 
               COLUMN 85,  "Z (MM)",
	       COLUMN 97, "DESCRIPTION"
         END IF
      PRINT COLUMN 1,   "========",
            COLUMN 11,  "======",
            COLUMN 19,  "=======", 
            COLUMN 28,  "=======",
            COLUMN 37,  "=======", 
            COLUMN 46,  "=======",
            COLUMN 55,  "====", 
            COLUMN 61,  "==========",
            COLUMN 73,  "==========",
            COLUMN 85,  "==========",
	    COLUMN 97,  "==============================="


      ON EVERY ROW

      IF p_vds.prj_units_set = 1 THEN

         CALL fraction_format(p_hve.width_g, 4) RETURNING wid_g 
         CALL fraction_format(p_hve.depth_g, 4) RETURNING dep_g 
         CALL fraction_format(p_hve.width_r, 4) RETURNING wid_r 
         CALL fraction_format(p_hve.depth_r, 4) RETURNING dep_r 

         PRINT COLUMN 1,  p_hve.spec_name CLIPPED,
               COLUMN 11, p_hve.comp_code CLIPPED,
               COLUMN 19, wid_g CLIPPED, "\"",
               COLUMN 28, dep_g CLIPPED, "\"",
               COLUMN 37, wid_r CLIPPED, "\"",
               COLUMN 46, dep_r CLIPPED, "\"",
               COLUMN 55, p_hve.shape_code USING "###&",
               COLUMN 61, p_hve.loc_x USING "#######.&", 
	       COLUMN 73, p_hve.loc_y USING "#######.&",
	       COLUMN 85, p_hve.loc_z USING "#######.&", 
	       COLUMN 97, "\UNKNOWN"
      ELSE
         PRINT COLUMN 1,  p_hve.spec_name CLIPPED,
               COLUMN 11, p_hve.comp_code CLIPPED,
               COLUMN 19, p_hve.width_g USING "###&",
               COLUMN 28, p_hve.depth_g USING "###&",
               COLUMN 37, p_hve.width_r USING "###&",
               COLUMN 46, p_hve.depth_r USING "###&",
               COLUMN 55, p_hve.shape_code USING "###&",
               COLUMN 61, p_hve.loc_x USING "######&", 
	       COLUMN 73, p_hve.loc_y USING "######&",
	       COLUMN 85, p_hve.loc_z USING "######&", 
	       COLUMN 97, "\UNKNOWN"
      END IF

END REPORT
