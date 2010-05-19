DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVBmain ()

  CALL ERRORLOG ("Enter in  Hvac BOM report")
  MESSAGE "Hvac BOM report in progress... please wait"

  START REPORT HVBform TO "HVBform"
    OUTPUT TO REPORT HVBform ()
  FINISH REPORT HVBform

  CALL HVBquery ()
  PREPARE hvb_stmt FROM q_stmt
  DECLARE hvb_curs CURSOR FOR hvb_stmt

  START REPORT HVBmaterial TO PIPE "HVB.sh"
     FOREACH  hvb_curs INTO p_hvb.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           MESSAGE "No rows found in query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT HVBmaterial ( p_hvb.system_name, p_hvb.comp_rptcat)
        END IF
     END FOREACH

  FINISH REPORT HVBmaterial

  MESSAGE "Hvac BOM report completed"
  CALL ERRORLOG ("Exit from Hvac BOM report")
END FUNCTION



REPORT HVBform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "======================="
      PRINT COLUMN 20, "| HVAC MEMBERS REPORT |"
      PRINT COLUMN 20, "======================="
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


REPORT HVBmaterial (p_4gl)
  DEFINE p_4gl RECORD	system_name LIKE "nfmadmin".hvac_dynamic.system_name,
		      	comp_rptcat LIKE "nfmadmin".hvac_comp_type.comp_rptcat
               END RECORD
  DEFINE system_line 	INTEGER,
	 HVBdesc1	CHAR(40),
	 HVBdesc2	CHAR(37),
	 HVBdesc3	CHAR(37),
	 HVBdesc4	CHAR(37),
	 HVBdesc5	CHAR(37),
	 HVBdesc6	CHAR(37),
	 HVBsize	CHAR(30),
	 HVBquty	CHAR(13)

  OUTPUT
    LEFT MARGIN 5
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------"
      SKIP 1 LINE
      PRINT COLUMN 1  , "DATE:", 
            COLUMN 7  , today USING "mm-dd-yyyy",
            COLUMN 59 , "H V A C",
            COLUMN 108, "Page - 1"
      PRINT COLUMN 50 , "M A T E R I A L    L I S T"
      SKIP 1 LINE
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "-------------------------------------"

  BEFORE GROUP OF p_4gl.system_name
    LET system_line = 0
    SKIP 1 LINE
    PRINT COLUMN 1  , "SYSTEM:",
	  COLUMN 9  , p_hvb.system_name CLIPPED
    SKIP 1 LINE
    PRINT COLUMN 6  , "ITEM",
          COLUMN 14 , "DESCRIPTION",
          COLUMN 58 , "SIZE",
          COLUMN 80 , "QUANTITY"
    PRINT COLUMN 6  , "----",
          COLUMN 14 , "----------------------------------------",
          COLUMN 58 , "------------------",
          COLUMN 80 , "-------------"

  BEFORE GROUP OF p_4gl.comp_rptcat
    PRINT COLUMN 1  , p_hvb.category_desc CLIPPED
    CALL under (p_hvb.category_desc, length(p_hvb.category_desc), "-")
         RETURNING underline
    PRINT COLUMN 1  , underline CLIPPED

  ON EVERY ROW
    LET system_line = system_line + 1
    CALL HVBdescription () 
    RETURNING HVBdesc1, HVBdesc2, HVBdesc3, HVBdesc4, HVBdesc5, HVBdesc6,
              HVBsize, HVBquty

    PRINT COLUMN 5  , system_line USING "<<<<",
          COLUMN 14 , HVBdesc1 CLIPPED,
	  COLUMN 58 , HVBsize  CLIPPED,
	  COLUMN 80 , HVBquty  CLIPPED
    IF HVBdesc2 IS NOT NULL THEN PRINT COLUMN 17, HVBdesc2 CLIPPED
    END IF
    IF HVBdesc3 IS NOT NULL THEN PRINT COLUMN 17, HVBdesc3 CLIPPED
    END IF
    IF HVBdesc4 IS NOT NULL THEN PRINT COLUMN 17, HVBdesc4 CLIPPED
    END IF
    IF HVBdesc5 IS NOT NULL THEN PRINT COLUMN 17, HVBdesc5 CLIPPED
    END IF
    IF HVBdesc6 IS NOT NULL THEN PRINT COLUMN 17, HVBdesc6 CLIPPED
    END IF
END REPORT
