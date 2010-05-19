DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION RWBmain ()

  CALL ERRORLOG ("Enter in  Rway BOM report")
  MESSAGE "Rway BOM report in progress... please wait"

  START REPORT RWBform TO "RWBform"
    OUTPUT TO REPORT RWBform ()
  FINISH REPORT RWBform

  CALL RWBquery ()
  PREPARE rwb_stmt FROM q_stmt
  DECLARE rwb_curs CURSOR FOR rwb_stmt
  START REPORT RWBmaterial TO PIPE "RWB.sh"
     FOREACH rwb_curs into p_rwb.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in query")
           MESSAGE "No rows found in query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT RWBmaterial ( p_rwb.system_name, p_rwb.comp_rptcat)
        END IF
     END FOREACH

  FINISH REPORT RWBmaterial

  MESSAGE "Rway BOM report completed"
  CALL ERRORLOG ("Exit from Rway BOM report")
END FUNCTION



REPORT RWBform ()

  OUTPUT
    LEFT MARGIN 35
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  FORMAT
    FIRST PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "=========================="
      PRINT COLUMN 20, "| RACEWAY MEMBERS REPORT |"
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
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_cat CLIPPED, COLUMN 44, "]"
      PRINT COLUMN 1 , "ASSEMBLY NAME",
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_nam CLIPPED, COLUMN 54, "]"
      PRINT COLUMN 1 , "ASSEMBLY VERSION",
            COLUMN 21, "[", COLUMN 23, p_rw.assembly_ver CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "SYSTEM NAME",
            COLUMN 21, "[", COLUMN 23, p_rw.system_name CLIPPED, COLUMN 36, "]"
      PRINT COLUMN 1 , "ZONE NUMBER",
            COLUMN 21, "[", COLUMN 23, p_rw.zone_number CLIPPED, COLUMN 28, "]"
      PRINT COLUMN 1 , "APPROVAL STATUS",
            COLUMN 21, "[", COLUMN 23, p_rw.apprv_stat CLIPPED, COLUMN 32, "]"
      PRINT COLUMN 1 , "CONSTRUCTION STATUS",
            COLUMN 21, "[", COLUMN 23, p_rw.constr_stat CLIPPED, COLUMN 32, "]"
END REPORT


REPORT RWBmaterial ( p_4gl)
  DEFINE p_4gl RECORD system_name LIKE "nfmadmin".rway_dynamic.system_name,
                      comp_rptcat LIKE "nfmadmin".rway_comp_type.comp_rptcat
               END RECORD
  DEFINE system_line 	INTEGER,
	 RWBdesc1	CHAR(40),
	 RWBdesc2	CHAR(37),
	 RWBdesc3	CHAR(37),
	 RWBdesc4	CHAR(37),
	 RWBdesc5	CHAR(37),
	 RWBdesc6	CHAR(37),
	 RWBsize	CHAR(18),
	 RWBquty	CHAR(13),
         sub		CHAR(1)

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
            COLUMN 7  , today using "mm-dd-yyyy",
            COLUMN 56 , "R A C E W A Y",
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
	  COLUMN 9  , p_rwb.system_name CLIPPED
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
    PRINT COLUMN 1  , p_rwb.category CLIPPED
    CALL under (p_rwb.category, LENGTH(p_rwb.category), "-") 
         RETURNING underline
    PRINT COLUMN 1  , underline CLIPPED

  ON EVERY ROW
    LET system_line = system_line + 1
    CALL RWBdescription () 
    RETURNING RWBdesc1, RWBdesc2, RWBdesc3, RWBdesc4, RWBdesc5, RWBdesc6,
              RWBsize, RWBquty

    PRINT COLUMN 5  , system_line using "<<<<",
          COLUMN 14 , RWBdesc1 CLIPPED,
	  COLUMN 58 , RWBsize  CLIPPED,
	  COLUMN 80 , RWBquty  CLIPPED

    IF RWBdesc2 IS NOT NULL THEN PRINT COLUMN 17, RWBdesc2 CLIPPED
    END IF
    IF RWBdesc3 IS NOT NULL THEN PRINT COLUMN 17, RWBdesc3 CLIPPED
    END IF
    IF RWBdesc4 IS NOT NULL THEN PRINT COLUMN 17, RWBdesc4 CLIPPED
    END IF
    IF RWBdesc5 IS NOT NULL THEN PRINT COLUMN 17, RWBdesc5 CLIPPED
    END IF
    IF RWBdesc6 IS NOT NULL THEN PRINT COLUMN 17, RWBdesc6 CLIPPED
    END IF
END REPORT
