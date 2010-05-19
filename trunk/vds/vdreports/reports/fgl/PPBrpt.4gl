DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPBmain ()

  DEFINE counter INTEGER

  LET counter = 0

  CALL update_piping_off()

  CALL ERRORLOG ("Enter in  Piping BOM report")
  MESSAGE "Piping BOM report in progress... please wait"

  START REPORT PPBform TO "PPBform"
    OUTPUT TO REPORT PPBform ()
  FINISH REPORT PPBform

  CALL PPBquery ()
  PREPARE ppb_stmt FROM q_stmt
  DECLARE ppb_curs CURSOR FOR ppb_stmt

  START REPORT PPBmaterial TO PIPE "PPB.sh"
     FOREACH ppb_curs INTO p_ppb.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           MESSAGE "No rows found in query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL PPBpost_query ()
           OUTPUT TO REPORT PPBmaterial (p_ppb.seq_number, p_ppb.comp_cat)
	   LET counter = counter + 1
        END IF
     END FOREACH

  FINISH REPORT PPBmaterial

  MESSAGE "Piping BOM report completed"
  CALL ERRORLOG("Exit from Piping BOM report")
END FUNCTION



REPORT PPBform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE header
      SKIP 20 LINES
      PRINT COLUMN 20, "=========================="
      PRINT COLUMN 20, "| PIPING MATERIAL REPORT |"
      PRINT COLUMN 20, "=========================="
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


REPORT PPBmaterial (p_4gl)
  DEFINE p_4gl RECORD seq_number LIKE "nfmadmin".piping_dynamic.seq_number,
		      comp_cat   LIKE "nfmadmin".piping_comp_type.comp_cat
               END RECORD
  DEFINE system_line 	INTEGER,
	 desc1		CHAR(40),
	 desc2		CHAR(37),
	 desc3		CHAR(37),
	 desc4		CHAR(37),
	 desc5		CHAR(37),
	 desc6		CHAR(37),
	 elem_size	CHAR(30),
	 quantity	CHAR(13)

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE header
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , TODAY USING "mm-dd-yyyy",
            COLUMN 57 , "P I P I N G",
            COLUMN 108, "Page - 1"
      PRINT COLUMN 50 , "M E M B E R S  R E P O R T"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------"

  BEFORE GROUP OF p_4gl.seq_number
    LET system_line = 0
    SKIP 1 LINE
    PRINT COLUMN 1  , "SYSTEM:",
	  COLUMN 9  , p_ppb.seq_number CLIPPED
    SKIP 1 LINE
    IF p_vds.prj_units_set = 1 THEN
       PRINT COLUMN 5  , "ITEM",
             COLUMN 13 , "DESCRIPTION",
             COLUMN 57 , "SIZE",
             COLUMN 76 , "COMMODITY",
             COLUMN 96 , "QUANTITY"
    ELSE
       IF p_vds.prj_units_set = 10 THEN
          PRINT COLUMN 5  , "ITEM",
                COLUMN 13 , "DESCRIPTION",
                COLUMN 57 , "SIZE",
                COLUMN 76 , "COMMODITY",
                COLUMN 96 , "QUANTITY"
       ELSE
          PRINT COLUMN 5  , "ITEM",
                COLUMN 13 , "DESCRIPTION",
                COLUMN 57 , "SIZE",
                COLUMN 76 , "COMMODITY",
                COLUMN 96 , "QUANTITY"
       END IF
    END IF
    PRINT COLUMN 5  , "----",
          COLUMN 13 , "----------------------------------------",
          COLUMN 57 , "--------------",
          COLUMN 76 , "----------------",
          COLUMN 96 , "-------------"

  BEFORE GROUP OF p_4gl.comp_cat
    PRINT COLUMN 1  , p_ppb.category_desc CLIPPED
    CALL under (p_ppb.category_desc, LENGTH (p_ppb.category_desc), "-")
         RETURNING underline
    PRINT COLUMN 1  , underline CLIPPED

  ON EVERY ROW
    LET system_line = system_line + 1
    CALL PPBdescription ()
         RETURNING desc1, desc2, desc3, desc4, desc5, desc6, elem_size, quantity

    PRINT COLUMN 5  , system_line USING "<<<<",
          COLUMN 13 , desc1 CLIPPED,
	  COLUMN 57 , elem_size CLIPPED,
	  COLUMN 76 , p_ppb.commodity CLIPPED,
	  COLUMN 96 , quantity CLIPPED
    IF desc2  IS NOT NULL THEN PRINT COLUMN 16 , desc2  CLIPPED END IF
    IF desc3  IS NOT NULL THEN PRINT COLUMN 16 , desc3  CLIPPED END IF
    IF desc4  IS NOT NULL THEN PRINT COLUMN 16 , desc4  CLIPPED END IF
    IF desc5  IS NOT NULL THEN PRINT COLUMN 16 , desc5  CLIPPED END IF
    IF desc6  IS NOT NULL THEN PRINT COLUMN 16 , desc6  CLIPPED END IF
END REPORT
