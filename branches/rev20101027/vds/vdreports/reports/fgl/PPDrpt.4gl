DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPDmain ()
  DEFINE	pa_cnt	INTEGER,
		i	INTEGER

  CALL update_piping_off()

  CALL ERRORLOG("Enter in  Piping Design Data report")
  MESSAGE "Piping Design Data report in progress... please wait"

  START REPORT PPDform TO "PPDform"
    OUTPUT TO REPORT PPDform ()
  FINISH REPORT PPDform

  START REPORT PPDheader TO "PPDheader"
    OUTPUT TO REPORT PPDheader ()
  FINISH REPORT PPDheader

  LET pa_cnt = 1
  CALL PPDquery1 ()
  PREPARE ppd_stmt1 FROM q_stmt
  DECLARE ppd_curs1 CURSOR FOR ppd_stmt1
  FOREACH ppd_curs1 INTO p_ppd1[pa_cnt].*
    IF status < 0 THEN
      CALL ERRORLOG("No rows found in group query")
      MESSAGE "No rows found in group query"
      SLEEP 3
      EXIT FOREACH
    ELSE
      IF pa_cnt > 5000 THEN
        CALL ERRORLOG("Piping design data report truncated to 5000 groups")
        MESSAGE "Piping design data report truncated to 5000 groups"
        SLEEP 3
        EXIT FOREACH
      ELSE
        LET pa_cnt = pa_cnt + 1
      END IF
    END IF
  END FOREACH

  LET pa_cnt = pa_cnt - 1

  FOR i = 1 TO pa_cnt
    CALL PPDdisplay_null (i)
#    CALL PPDclarify (i)

    CALL PPDquery2 (i)
    PREPARE ppd_stmt2 FROM q_stmt
    DECLARE ppd_curs2 CURSOR FOR ppd_stmt2

    START REPORT PPDmaterial TO pipe "PPD.sh"
    FOREACH ppd_curs2 INTO p_ppd2.*
      IF status < 0 THEN
        CALL ERRORLOG("No rows found in element query")
        MESSAGE "No rows element in element query"
        SLEEP 3
        EXIT FOREACH
      ELSE
        CALL PPDconvert ()
        OUTPUT TO REPORT PPDmaterial (p_ppd2.seq_number)
      END IF
    END FOREACH
    FINISH REPORT PPDmaterial
  END FOR

  MESSAGE "Piping Design Data report completed"
  CALL ERRORLOG("Exit from Piping Design Data report")
END FUNCTION


REPORT PPDform ()

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 3
    BOTTOM MARGIN 5
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 51, "============================="
      PRINT COLUMN 51, "| PIPING DESIGN DATA REPORT |"
      PRINT COLUMN 51, "============================="
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


REPORT PPDheader ()

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 6

  FORMAT
    FIRST PAGE HEADER
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "--------------------------------------------"
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 60 , "P I P I N G",
            COLUMN 115, "Page - 1"
      PRINT COLUMN 53 , "D E S I G N     D A T A"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "--------------------------------------------"
END REPORT


REPORT PPDmaterial (p_4gl)
  DEFINE p_4gl RECORD seq_number LIKE "nfmadmin".piping_dynamic.seq_number END RECORD
  DEFINE PPDsize CHAR(30),
         PPDsyst CHAR(23)

  OUTPUT
    LEFT MARGIN 4
    TOP MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH 16

  FORMAT
    BEFORE GROUP OF p_4gl.seq_number
      LET PPDsyst = "SYSTEM: ", p_ppd2.seq_number CLIPPED
      CALL under (PPDsyst, LENGTH(PPDsyst), "=")
           RETURNING underline
      SKIP 2 LINES
      PRINT COLUMN 1  , underline CLIPPED
      PRINT COLUMN 1  , PPDsyst CLIPPED
      PRINT COLUMN 1  , underline CLIPPED

      SKIP 1 LINE
      PRINT COLUMN 1  , "PIPING SPEC",
            COLUMN 19 , ":",
            COLUMN 21 , p_ppd2.spec_name CLIPPED,
            COLUMN 36 , "OPERATING CONDITIONS"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "OPERATING FLUID",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.fluid_code CLIPPED,
               COLUMN 39 , "TEMPERATURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.op_temp USING "##&",
               COLUMN 57 , ". DEG F"
      ELSE
         PRINT COLUMN 1  , "OPERATING FLUID",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.fluid_code CLIPPED,
               COLUMN 39 , "TEMPERATURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.op_temp USING "##&",
               COLUMN 57 , ". DEG C"
      END IF
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "INSULATION",
               COLUMN 39 , "PRESSURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.op_press USING "##&",
               COLUMN 57 , ". PSIG"
      ELSE
         PRINT COLUMN 1  , "INSULATION",
               COLUMN 39 , "PRESSURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.op_press USING "##&",
               COLUMN 57 , ". BARS"
      END IF
      PRINT COLUMN 6  , "TYPE",
            COLUMN 19 , ":",
            COLUMN 21 , p_ppd2.insul_type CLIPPED,
            COLUMN 39 , "SPEC GRAVITY",
            COLUMN 52 , ":",
            COLUMN 54 , p_ppd2.spec_grav USING "&.&&&"
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 6  , "THICKNESS",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.insul_thk USING "&.&",
               COLUMN 24 , "\"",
               COLUMN 36 , "DESIGN CONDITIONS"
      ELSE
         PRINT COLUMN 6  , "THICKNESS",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.insul_thk USING "##&",
               COLUMN 24 , " MM",
               COLUMN 36 , "DESIGN CONDITIONS"
      END IF
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "HEAT TRACING",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.tracing_code CLIPPED,
               COLUMN 39 , "TEMPERATURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.dgn_temp USING "##&",
               COLUMN 57 , ". DEG F"
      ELSE
         PRINT COLUMN 1  , "HEAT TRACING",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.tracing_code CLIPPED,
               COLUMN 39 , "TEMPERATURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.dgn_temp USING "##&",
               COLUMN 57 , ". DEG C"
      END IF
      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , "PAINT CODE",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.paint_code CLIPPED,
               COLUMN 39 , "PRESSURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.dgn_press USING "##&",
               COLUMN 57 , ". PSIG"
      ELSE
         PRINT COLUMN 1  , "PAINT CODE",
               COLUMN 19 , ":",
               COLUMN 21 , p_ppd2.paint_code CLIPPED,
               COLUMN 39 , "PRESSURE",
               COLUMN 52 , ":",
               COLUMN 54 , p_ppd2.dgn_press USING "##&",
               COLUMN 57 , ". BARS"
      END IF
      SKIP 1 LINE
      PRINT COLUMN 1  , "COMP",
            COLUMN 11 , "SIZE",
            COLUMN 23 , "OPT",
            COLUMN 27 , "DESCRIPTION",
            COLUMN 48 , "TAG NUMBER",
            COLUMN 61 , "SCH OVRD",
            COLUMN 70 , "COMPONENT NOTE",
            COLUMN 101, "X",
            COLUMN 110, "Y",
            COLUMN 118, "Z"
      PRINT COLUMN 1  , "------",
            COLUMN 11 , "------------",
            COLUMN 23 , "---",
            COLUMN 27 , "--------------------",
            COLUMN 48 , "------------",
            COLUMN 61 , "--------",
            COLUMN 70 , "---------------------------",
            COLUMN 98 , "-------",
            COLUMN 106, "-------",
            COLUMN 114, "-------"

    ON EVERY ROW
      CALL size_of_element ( p_ppd2.npd_g, p_ppd2.npd_r) RETURNING PPDsize

      IF p_vds.prj_units_set = 1 THEN
         PRINT COLUMN 1  , p_ppd2.comp_code CLIPPED,
               COLUMN 11 , PPDsize CLIPPED,
               COLUMN 23 , p_ppd2.opt_code USING "<<&",
               COLUMN 27 , p_ppd2.comp_descr CLIPPED,
               COLUMN 48 , p_ppd2.tag_number CLIPPED,
               COLUMN 61 , p_ppd2.sch_thk_ovr CLIPPED,
               COLUMN 70 , p_ppd2.comp_note CLIPPED,
               COLUMN 98 , p_ppd2.loc_x USING "----&.&",
               COLUMN 106, p_ppd2.loc_y USING "----&.&",
               COLUMN 114, p_ppd2.loc_z USING "----&.&"
      ELSE
         PRINT COLUMN 1  , p_ppd2.comp_code CLIPPED,
               COLUMN 11 , PPDsize CLIPPED,
               COLUMN 23 , p_ppd2.opt_code USING "<<&",
               COLUMN 27 , p_ppd2.comp_descr CLIPPED,
               COLUMN 48 , p_ppd2.tag_number CLIPPED,
               COLUMN 61 , p_ppd2.sch_thk_ovr CLIPPED,
               COLUMN 70 , p_ppd2.comp_note CLIPPED,
               COLUMN 98 , p_ppd2.loc_x USING "------&.",
               COLUMN 106, p_ppd2.loc_y USING "------&.",
               COLUMN 114, p_ppd2.loc_z USING "------&."
      END IF
END REPORT
