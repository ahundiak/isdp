DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION NZBmain ()

  CALL update_piping_off()

  CALL ERRORLOG ("Enter in  Piping Nozzle report")
  MESSAGE "Piping Nozzle report in progress... please wait"

  START REPORT NZBform to "NZBform"
    OUTPUT to REPORT NZBform ()
  FINISH REPORT NZBform

  CALL NZBquery ()
  PREPARE nzb_stmt FROM q_stmt
  DECLARE nzb_curs CURSOR FOR nzb_stmt

  START REPORT NZBlist to pipe "NZB.sh"
  FOREACH nzb_curs into p_nzn.*
    IF STATUS < 0 then
       CALL ERRORLOG ("No rows found in query")
       SLEEP 3
       EXIT FOREACH
    ELSE
       OUTPUT to REPORT NZBlist ()
     END IF
  END FOREACH
  
  FINISH REPORT NZBlist

  MESSAGE "Piping Nozzle report achieved"
  CALL ERRORLOG ("Exit from Piping Nozzle report")
END FUNCTION



REPORT NZBform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "============================="
      PRINT COLUMN 20, "| EQUIPMENT NOZZLE SUMMARY  |"
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
            COLUMN 21, "[", COLUMN 23, p_nz.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_nz.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_nz.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_nz.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_nz.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_nz.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_nz.constr_stat CLIPPED, COLUMN 32, "]"
END REPORT


REPORT NZBlist ()

  DEFINE	frac	CHAR(30)

  OUTPUT
    LEFT MARGIN 2
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "--------------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 56 , "E Q U I P M E N T",
            COLUMN 114, "Page - 1"
      PRINT COLUMN 51 , "N O Z Z L E  S U M M A R Y"
      SKIP 1 LINE
      PRINT COLUMN 1,  "----------------------------------------",
            COLUMN 41, "----------------------------------------",
            COLUMN 81, "--------------------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 15,  "NOZZLE DESCRIPTION",
            COLUMN 73,  "PIPING SYSTEM PARAMETERS"
      PRINT COLUMN 10,  "------------------------------",
            COLUMN 44,  "--------------------------------------------------",
            COLUMN 52,  "-------------------------------------"
      PRINT COLUMN 27,  "PRESS",
            COLUMN 63,  "INSUL",
            COLUMN 69,  "INSUL",
            COLUMN 75,  "HEAT",
            COLUMN 80,  "PNT",
            COLUMN 85,  "OPER",
            COLUMN 92,  "OPER",
            COLUMN 99,  "DGN",
            COLUMN 106, "DGN",
            COLUMN 113, "SPEC",
            COLUMN 120, "APPVL",
            COLUMN 126, "CONST"
      PRINT COLUMN 1,   "EQUIP ID",
            COLUMN 10,  "TAG NO",
            COLUMN 19,  "SIZE", 
            COLUMN 27,  "RATING",
            COLUMN 34,  "FACING",
            COLUMN 44,  "SYSTEM NAME",
            COLUMN 56,  "SPEC",
            COLUMN 63,  "TYPE",
            COLUMN 69,  "THK",
            COLUMN 75,  "TRAC",
            COLUMN 80,  "CODE",
            COLUMN 85,  "TEMP",
            COLUMN 92,  "PRESS",
            COLUMN 99,  "TEMP",
            COLUMN 106, "PRESS",
            COLUMN 113, "GRAV",
            COLUMN 120, "STAT",
            COLUMN 126, "STAT"
      PRINT COLUMN 1,   "========",
            COLUMN 10,  "========",
            COLUMN 19,  "=======", 
            COLUMN 27,  "======",
            COLUMN 34,  "======",
            COLUMN 44,  "===========",
            COLUMN 56,  "======",
            COLUMN 63,  "=====",
            COLUMN 69,  "=====",
            COLUMN 75,  "====",
            COLUMN 80,  "====",
            COLUMN 85,  "======",
            COLUMN 92,  "======",
            COLUMN 99,  "======",
            COLUMN 106, "======",
            COLUMN 113, "======",
            COLUMN 120, "=====",
            COLUMN 126, "====="

    PAGE HEADER
      PRINT COLUMN 114, "Page - ", PAGENO USING "<<<"
      SKIP 1 LINE
      PRINT COLUMN 15,  "NOZZLE DESCRIPTION",
            COLUMN 73,  "PIPING SYSTEM PARAMETERS"
      PRINT COLUMN 10,  "------------------------------",
            COLUMN 44,  "--------------------------------------------------",
            COLUMN 52,  "-------------------------------------"
      PRINT COLUMN 27,  "PRESS",
            COLUMN 63,  "INSUL",
            COLUMN 69,  "INSUL",
            COLUMN 75,  "HEAT",
            COLUMN 80,  "PNT",
            COLUMN 85,  "OPER",
            COLUMN 92,  "OPER",
            COLUMN 99,  "DGN",
            COLUMN 106, "DGN",
            COLUMN 113, "SPEC",
            COLUMN 120, "APPVL",
            COLUMN 126, "CONST"
      PRINT COLUMN 1,   "EQUIP ID",
            COLUMN 10,  "TAG NO",
            COLUMN 19,  "SIZE", 
            COLUMN 27,  "RATING",
            COLUMN 34,  "FACING",
            COLUMN 44,  "SYSTEM NAME",
            COLUMN 56,  "SPEC",
            COLUMN 63,  "TYPE",
            COLUMN 69,  "THK",
            COLUMN 75,  "TRAC",
            COLUMN 80,  "CODE",
            COLUMN 85,  "TEMP",
            COLUMN 92,  "PRESS",
            COLUMN 99,  "TEMP",
            COLUMN 106, "PRESS",
            COLUMN 113, "GRAV",
            COLUMN 120, "STAT",
            COLUMN 126, "STAT"
      PRINT COLUMN 1,   "========",
            COLUMN 10,  "========",
            COLUMN 19,  "=======", 
            COLUMN 27,  "======",
            COLUMN 34,  "======",
            COLUMN 44,  "===========",
            COLUMN 56,  "======",
            COLUMN 63,  "=====",
            COLUMN 69,  "=====",
            COLUMN 75,  "====",
            COLUMN 80,  "====",
            COLUMN 85,  "======",
            COLUMN 92,  "======",
            COLUMN 99,  "======",
            COLUMN 106, "======",
            COLUMN 113, "======",
            COLUMN 120, "=====",
            COLUMN 126, "====="


      ON EVERY ROW
         CALL size_of_element ( p_nzn.npd_g, 0) RETURNING frac

         CASE p_vds.prj_units_set
            WHEN 1 OR 10
               PRINT COLUMN 1,   p_nzn.eqp_number CLIPPED, 
                     COLUMN 10,  p_nzn.tag_number CLIPPED,
                     COLUMN 19,  frac CLIPPED,
                     COLUMN 27,  p_nzn.rating_g CLIPPED, 
                     COLUMN 34,  p_nzn.prep_g CLIPPED,
                     COLUMN 44,  p_nzn.seq_number CLIPPED, 
                     COLUMN 56,  p_nzn.spec_name CLIPPED, 
                     COLUMN 63,  p_nzn.insul_type CLIPPED, 
                     COLUMN 69,  p_nzn.insul_thk USING "##.&", "\"",
                     COLUMN 75,  p_nzn.tracing_code CLIPPED, 
                     COLUMN 80,  p_nzn.paint_code CLIPPED,
                     COLUMN 85,  p_nzn.op_temp USING "####&", "\.",
                     COLUMN 92,  p_nzn.op_press USING "####&", "\.", 
                     COLUMN 99,  p_nzn.dgn_temp USING "####&", "\.", 
                     COLUMN 106, p_nzn.dgn_press USING "####&", "\.",
                     COLUMN 113, p_nzn.spec_grav USING "#.###&", 
                     COLUMN 120, p_nzn.apprv_stat CLIPPED,
                     COLUMN 126, p_nzn.constr_stat CLIPPED
            WHEN 20
               PRINT COLUMN 1,   p_nzn.eqp_number CLIPPED, 
                     COLUMN 10,  p_nzn.tag_number CLIPPED,
                     COLUMN 19,  frac CLIPPED,
                     COLUMN 27,  p_nzn.rating_g CLIPPED, 
                     COLUMN 34,  p_nzn.prep_g CLIPPED,
                     COLUMN 44,  p_nzn.seq_number CLIPPED, 
                     COLUMN 56,  p_nzn.spec_name CLIPPED, 
                     COLUMN 63,  p_nzn.insul_type CLIPPED, 
                     COLUMN 69,  p_nzn.insul_thk USING "##&.",
                     COLUMN 75,  p_nzn.tracing_code CLIPPED, 
                     COLUMN 80,  p_nzn.paint_code CLIPPED,
                     COLUMN 85,  p_nzn.op_temp USING "####&", "\.",
                     COLUMN 92,  p_nzn.op_press USING "####&", "\.", 
                     COLUMN 99,  p_nzn.dgn_temp USING "####&", "\.", 
                     COLUMN 106, p_nzn.dgn_press USING "####&", "\.",
                     COLUMN 113, p_nzn.spec_grav USING "#.###&", 
                     COLUMN 120, p_nzn.apprv_stat CLIPPED,
                     COLUMN 126, p_nzn.constr_stat CLIPPED
         END CASE

END REPORT
