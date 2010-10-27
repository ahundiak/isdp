DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPRmain ()
  DEFINE i,last_spec_ok INTEGER
  DEFINE last_spec_name    like "nfmadmin".piping_spec.spec_name
  DEFINE str1 CHAR(80)

  DEFINE rep_crit RECORD spec_name CHAR(10),
                         comp_code CHAR(10),
                         opt_code  CHAR(10)
                 END RECORD

  DEFINE f_size float

  CALL PPRinput_opt()

  CALL ERRORLOG("Enter in  Piping Reference Data Check")
  MESSAGE "Piping Reference Data Check in progress... please wait"

  IF p_form3.spec_name = "*" THEN
     LET rep_crit.spec_name = "-ALL-"
  ELSE
     IF p_form3.spec_name = " " THEN
        LET rep_crit.spec_name = "<blank>"
     ELSE
        IF (p_form3.spec_name is null) THEN
           LET rep_crit.spec_name = "<null>"
        ELSE
           LET rep_crit.spec_name = p_form3.spec_name
        END IF
     END IF
  END IF
  IF p_form3.comp_code = "*" THEN
     LET rep_crit.comp_code = "-ALL-"
  ELSE
     IF p_form3.comp_code = " " THEN
        LET rep_crit.comp_code = "<blank>"
     ELSE
        IF (p_form3.comp_code is null) THEN
           LET rep_crit.comp_code = "<null>"
        ELSE
           LET rep_crit.comp_code = p_form3.comp_code
        END IF
     END IF
  END IF
  IF p_form3.opt_code = 0 THEN
     LET rep_crit.opt_code = "-ALL-"
  ELSE
     IF (p_form3.opt_code is null) THEN
        LET rep_crit.opt_code = "<null>"
     ELSE
        LET rep_crit.opt_code = p_form3.opt_code
     END IF
  END IF

  start REPORT PPRform to "PPRform"
    OUTPUT to REPORT PPRform (rep_crit.*)
  FINISH REPORT PPRform

  start REPORT PPRreport to pipe "PPR.sh"
  LET last_spec_ok = 0
  LET last_spec_name = ""
  LET i = 0
  IF p_form3.opt_code = 0 THEN
     declare comprcd1 cursor for
       select "nfmadmin".piping_spec.spec_name,
              "nfmadmin".piping_spec.spec_no,
              "nfmadmin".piping_spec.npd_tblno,
              "nfmadmin".piping_comps.spec_no,
              "nfmadmin".piping_comps.family_name,
              "nfmadmin".piping_comps.part_no_prfx,
              "nfmadmin".piping_comps.comp_code,
              "nfmadmin".piping_comps.opt_code,
              "nfmadmin".piping_comps.short_code,
              "nfmadmin".piping_comps.size_g_low,
              "nfmadmin".piping_comps.size_g_high,
              "nfmadmin".piping_comps.size_r_low,
              "nfmadmin".piping_comps.size_r_high,
              "nfmadmin".piping_comps.sch_thk_g,
              "nfmadmin".piping_comps.sch_thk_r

       from "nfmadmin".piping_spec, outer "nfmadmin".piping_comps

       where "nfmadmin".piping_spec.spec_name matches p_form3.spec_name
         and "nfmadmin".piping_comps.spec_no="nfmadmin".piping_spec.spec_no
         and "nfmadmin".piping_comps.comp_code matches p_form3.comp_code

       ORDER BY "nfmadmin".piping_spec.spec_name,
                "nfmadmin".piping_comps.comp_code,
                "nfmadmin".piping_comps.opt_code,
                "nfmadmin".piping_comps.size_g_low

     foreach comprcd1 into compstr.*
        IF status != 0 THEN
           exit foreach
        ELSE
           IF last_spec_ok = 0 or last_spec_name != compstr.spec_name THEN
              LET size1 = compstr.size_g_low
              LET size2 = compstr.size_g_high
              LET size3 = compstr.size_r_low
              LET size4 = compstr.size_r_high
              CALL spec_rcd() RETURNING last_spec_ok
              IF size1 is not null THEN
                 LET f_size = size1
                 CALL fraction_format(f_size,32) RETURNING size1
              END IF
              IF size2 is not null THEN
                 LET f_size = size2
                 CALL fraction_format(f_size,32) RETURNING size2
              END IF
              IF size3 is not null THEN
                 LET f_size = size3
                 CALL fraction_format(f_size,32) RETURNING size3
              END IF
              IF size4 is not null THEN
                 LET f_size = size4
                 CALL fraction_format(f_size,32) RETURNING size4
              END IF
              LET i = i + 1
              OUTPUT to REPORT PPRreport (compstr.*,size1,size2,size3,size4,
                                          msg,last_spec_ok)
           END IF
        END IF
     END foreach
  ELSE
     declare comprcd2 cursor for
       select "nfmadmin".piping_spec.spec_name,
              "nfmadmin".piping_spec.spec_no,
              "nfmadmin".piping_spec.npd_tblno,
              "nfmadmin".piping_comps.spec_no,
              "nfmadmin".piping_comps.family_name,
              "nfmadmin".piping_comps.part_no_prfx,
              "nfmadmin".piping_comps.comp_code,
              "nfmadmin".piping_comps.opt_code,
              "nfmadmin".piping_comps.short_code,
              "nfmadmin".piping_comps.size_g_low,
              "nfmadmin".piping_comps.size_g_high,
              "nfmadmin".piping_comps.size_r_low,
              "nfmadmin".piping_comps.size_r_high,
              "nfmadmin".piping_comps.sch_thk_g,
              "nfmadmin".piping_comps.sch_thk_r

       from "nfmadmin".piping_spec, outer "nfmadmin".piping_comps

       where "nfmadmin".piping_spec.spec_name  matches p_form3.spec_name
         and "nfmadmin".piping_comps.spec_no   = "nfmadmin".piping_spec.spec_no
         and "nfmadmin".piping_comps.comp_code matches p_form3.comp_code
         and "nfmadmin".piping_comps.opt_code  = p_form3.opt_code

       ORDER BY "nfmadmin".piping_spec.spec_name,
                "nfmadmin".piping_comps.comp_code,
                "nfmadmin".piping_comps.opt_code,
                "nfmadmin".piping_comps.size_g_low

     foreach comprcd2 into compstr.*
        IF status != 0 THEN
           exit foreach
        ELSE
           IF last_spec_ok = 0 or last_spec_name != compstr.spec_name THEN
              LET size1 = compstr.size_g_low
              LET size2 = compstr.size_g_high
              LET size3 = compstr.size_r_low
              LET size4 = compstr.size_r_high
              CALL spec_rcd() RETURNING last_spec_ok
              LET i = i + 1
              OUTPUT to REPORT PPRreport (compstr.*,size1,size2,size3,size4,
                                          msg,last_spec_ok)
           END IF
        END IF
     END foreach
  END IF
  IF i = 0 THEN
     LET str1 = p_form3.spec_name
     CALL check_value(str1) RETURNING str1
     LET msg = "No entry found in PIPING_SPEC for spec \"",
               str1 CLIPPED,"\"."
     MESSAGE msg
  ELSE
     MESSAGE "Piping Reference Data Check completed"
  END IF

  FINISH REPORT PPRreport

  CALL ERRORLOG("Exit from Piping Reference Data Check")

END FUNCTION


REPORT PPRform (rep_crit)

  DEFINE rep_crit RECORD spec_name CHAR(10),
                         comp_code CHAR(10),
                         opt_code  CHAR(10)
                 END RECORD

  OUTPUT
    left MARGIN 35
    top MARGIN 3
    bottom MARGIN 3
    PAGE LENGTH 66

  format
    first PAGE HEADER
      SKIP 20 LINES
      PRINT COLUMN 20, "============================"
      PRINT COLUMN 20, "|                          |"
      PRINT COLUMN 20, "| Piping Data Check Report |"
      PRINT COLUMN 20, "|                          |"
      PRINT COLUMN 20, "|    Date:",
            COLUMN 32, today using "mmm-dd-yyyy",
            COLUMN 47, "|"
      PRINT COLUMN 20, "|                          |"
      PRINT COLUMN 20, "============================"
      SKIP 4 LINES
      PRINT COLUMN 20 , "    Reporting Criteria"
      PRINT COLUMN 20, "============================"
      SKIP 1 LINE
      PRINT COLUMN 20, " Specification :",
            COLUMN 37, rep_crit.spec_name
      SKIP 1 LINE
      PRINT COLUMN 20, "     Component :",
            COLUMN 37, rep_crit.comp_code
      SKIP 1 LINE
      PRINT COLUMN 20, "   Option Code :",
            COLUMN 37, rep_crit.opt_code
END REPORT

REPORT PPRreport (compstr,size1,size2,size3,size4,msg,spec_ok)
  DEFINE compstr RECORD spec_name    LIKE "nfmadmin".piping_spec.spec_name,
                        s_spec_no    LIKE "nfmadmin".piping_spec.spec_no,
                        npd_tblno    LIKE "nfmadmin".piping_spec.npd_tblno,
                        c_spec_no    LIKE "nfmadmin".piping_comps.spec_no,
                        family_name  LIKE "nfmadmin".piping_comps.family_name,
                        part_no_prfx LIKE "nfmadmin".piping_comps.part_no_prfx,
                        comp_code    LIKE "nfmadmin".piping_comps.comp_code,
                        opt_code     LIKE "nfmadmin".piping_comps.opt_code,
                        short_code   LIKE "nfmadmin".piping_comps.short_code,
                        size_g_low   LIKE "nfmadmin".piping_comps.size_g_low,
                        size_g_high  LIKE "nfmadmin".piping_comps.size_g_high,
                        size_r_low   LIKE "nfmadmin".piping_comps.size_r_low,
                        size_r_high  LIKE "nfmadmin".piping_comps.size_r_high,
                        sch_thk_g    LIKE "nfmadmin".piping_comps.sch_thk_g,
                        sch_thk_r    LIKE "nfmadmin".piping_comps.sch_thk_r
                 END RECORD
  DEFINE size1,size2,size3,size4 CHAR(20)
  DEFINE msg CHAR(300)
  DEFINE spec_ok INTEGER

  DEFINE msg1,msg2,msg3,msg4,msg5 CHAR(70)

  OUTPUT
    LEFT MARGIN 0
    TOP MARGIN 3
    BOTTOM MARGIN 3
    PAGE LENGTH 66

  ORDER BY compstr.spec_name,compstr.comp_code
  FORMAT
    PAGE HEADER
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      PRINT COLUMN 1  , TODAY USING "mmm-dd-yyyy",
            COLUMN 47 , "  Piping Data Check Report",
            COLUMN 123, "Page - ", PAGENO using "<<<"
      PRINT COLUMN 1  , "----------------------------------------",
            COLUMN 41 , "----------------------------------------",
            COLUMN 81 , "----------------------------------------------------"
      SKIP 2 LINES

    BEFORE GROUP OF compstr.spec_name
      PRINT COLUMN 1  , "Specification :",
            COLUMN 17 , compstr.spec_name
      SKIP 1 LINE

    AFTER GROUP OF compstr.comp_code
      SKIP 1 LINE
    ON EVERY ROW
      IF spec_ok = 0 THEN
         CALL split_string(msg) RETURNING msg1,msg2,msg3,msg4,msg5
         PRINT COLUMN 3,   "<",
               COLUMN 4,   compstr.comp_code CLIPPED,
               COLUMN 12,  size1 CLIPPED,
               COLUMN 19,  size2 CLIPPED,
               COLUMN 27,  size3 CLIPPED,
               COLUMN 34,  size4 CLIPPED,
               COLUMN 41,  compstr.opt_code CLIPPED,
               COLUMN 46,  ">  (",
               COLUMN 50,  compstr.short_code CLIPPED,
               COLUMN 56,  ") :",
               COLUMN 60,  msg1 CLIPPED
         IF LENGTH(msg2) > 0 THEN
            PRINT COLUMN 60, msg2 CLIPPED
         END IF
         IF LENGTH(msg3) > 0 THEN
            PRINT COLUMN 60, msg3 CLIPPED
         END IF
         IF LENGTH(msg4) > 0 THEN
            PRINT COLUMN 60, msg4 CLIPPED
         END IF
         IF LENGTH(msg5) > 0 THEN
            PRINT COLUMN 60, msg5 CLIPPED
         END IF
      ELSE
         PRINT COLUMN 3,   msg CLIPPED
      END IF
END REPORT
