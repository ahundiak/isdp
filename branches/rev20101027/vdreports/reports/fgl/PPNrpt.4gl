DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPNmain ()
  DEFINE p_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
  		       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
		       pdm_part_num	LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE p_args RECORD dry_wt		FLOAT,
		       wet_wt		FLOAT,
		       surf_area	FLOAT,
		       arg1		FLOAT,
		       arg2		FLOAT,
		       arg3		FLOAT,
		       arg4		FLOAT,
		       arg5		FLOAT,
		       arg6		FLOAT
                END RECORD
  DEFINE p_star RECORD dry_wgt		CHAR(1),
		       wet_wgt		CHAR(1),
		       ins_wgt		CHAR(1),
		       tot_wgt		CHAR(1)
                END RECORD
  DEFINE query_str CHAR(300)

  CALL update_piping_off()

  IF p_vds.prj_units_set != 1 THEN
     CALL nsts_error ()
     MESSAGE nsts_err_msg
     SLEEP 3
     CALL ERRORLOG (nsts_err_msg)
     GOTO abort
  END IF

  CALL ERRORLOG ("Enter in  Piping Nsts report")
  MESSAGE "Piping Nsts report in progress... please wait"

  START REPORT PPNform TO "PPNform" 
  OUTPUT TO REPORT PPNform ()
  FINISH REPORT PPNform

  CALL PPNquery ()
  PREPARE ppn_stmt1 FROM q_stmt
  DECLARE ppn_curs1 CURSOR FOR ppn_stmt1
  START REPORT PPNmaterial TO pipe "PPN.sh"
  FOREACH ppn_curs1 INTO p_ppn.*
    IF STATUS < 0 THEN
      CALL ERRORLOG ("No rows found in main query")
      MESSAGE "No rows found in main query"
      SLEEP 3
      EXIT FOREACH
    ELSE
      CALL PPNpost_query () RETURNING p_calc.*, p_args.*, p_star.*, query_str

      PREPARE ppn_stmt2 FROM query_str
      DECLARE ppn_curs2 CURSOR FOR ppn_stmt2
      FOREACH ppn_curs2 INTO p_args.*
        IF STATUS < 0 THEN
          CALL ERRORLOG ("No rows found in secondary query")
          MESSAGE "No rows found in secondary query"
          SLEEP 3
          DISPLAY "family_name = ", p_ppn.family_name CLIPPED
          DISPLAY "n_itemname   = ", p_calc.pdm_part_num CLIPPED
          SLEEP 3
          EXIT FOREACH
        END IF
      END FOREACH

      OUTPUT TO REPORT PPNmaterial ( p_calc.*, p_args.*, p_star.*)
    END IF
  END FOREACH

  FINISH REPORT PPNmaterial
  MESSAGE "Piping Nsts report completed"
  CALL ERRORLOG ("Exit from Piping Nsts report")

  LABEL abort:
END FUNCTION



REPORT PPNform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "================================="
      PRINT COLUMN 20, "| PIPING NSTS CONTROL WORKSHEET |"
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


REPORT PPNmaterial ( r_calc, r_args, r_star)
  DEFINE r_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
  		       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
		       pdm_part_num	LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE r_args RECORD dry_wt		FLOAT,
		       wet_wt		FLOAT,
		       surf_area	FLOAT,
		       arg1		FLOAT,
		       arg2		FLOAT,
		       arg3		FLOAT,
		       arg4		FLOAT,
		       arg5		FLOAT,
		       arg6		FLOAT
                END RECORD
  DEFINE r_star RECORD dry_wgt		CHAR(1),
		       wet_wgt		CHAR(1),
		       ins_wgt		CHAR(1),
		       tot_wgt		CHAR(1)
                END RECORD
  DEFINE PPNdesc     CHAR(30),
	 PPNdry_wgt  FLOAT,
	 PPNwet_wgt  FLOAT,
	 PPNins_wgt  FLOAT,
	 PPNtot_wgt  FLOAT,
         element_no  INTEGER,
         sce         CHAR(3),
         mod_len     CHAR(10)

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
            COLUMN 40 , "P I P I N G  N S T S  R E P O R T",
            COLUMN 120, "Page - 1"
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
      LET  element_no = element_no + 1
      CALL PPNdescription ( r_calc.*, r_args.*, r_star.*) 
           RETURNING PPNdesc,
		     PPNdry_wgt,
		     PPNwet_wgt,
		     PPNins_wgt,
		     PPNtot_wgt,
                     r_star.dry_wgt,
                     r_star.wet_wgt,
                     r_star.ins_wgt,
                     r_star.tot_wgt

      IF p_ppn.constr_stat != " "
      OR p_ppn.constr_stat != ""
      OR p_ppn.constr_stat IS NOT NULL THEN LET sce = p_ppn.constr_stat
      ELSE 				     LET sce = "U/F"
      END IF

      IF p_ppn.ship_alt = "undefined" THEN LET p_ppn.ship_alt = " "
      END IF

      IF p_ppn.short_code = "PIPE" THEN
         LET mod_len = p_ppn.pipe_length USING "<<<&.&" 
         LET PPNdesc = PPNdesc CLIPPED, " x ", mod_len CLIPPED, "\""
      END IF 


      PRINT COLUMN 1  , p_ppn.ship_alt CLIPPED,
	    COLUMN 5  , element_no USING "###&",
	    COLUMN 11 , "1",
	    COLUMN 15 , PPNdesc CLIPPED,
	    COLUMN 41 , 
	    COLUMN 42 , 
	    COLUMN 45 , 
	    COLUMN 51 , p_ppn.material CLIPPED,
	    COLUMN 61 , 
	    COLUMN 71 , p_ppn.comp_code CLIPPED,
	    COLUMN 82 , sce CLIPPED,
	    COLUMN 89 , p_ppn.spec_name CLIPPED,
	    COLUMN 94 , 
	    COLUMN 100, 
	    COLUMN 107, PPNtot_wgt USING "----&.&",r_star.tot_wgt CLIPPED,
	    COLUMN 115, " "

END REPORT
