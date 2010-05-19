DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPRinput_opt()
  INPUT p_form3.spec_name  FROM sc_pipe.specification
  INPUT p_form3.comp_code FROM sc_pipe.component
  INPUT p_form3.opt_code FROM sc_pipe.option_code
  CLEAR SCREEN
END FUNCTION

FUNCTION spec_rcd()

  DEFINE i INTEGER
  DEFINE str1,str2,str3 CHAR(80)


  IF (compstr.s_spec_no IS NULL) THEN
     LET str1 = compstr.spec_name
     CALL check_value(str1) RETURNING str1
     LET msg = "Specification number is undefined in spec \"",
               str1 CLIPPED,"\"."
     RETURN 1
  END IF
  IF (compstr.npd_tblno IS NULL) THEN
     LET str1 = compstr.spec_name
     CALL check_value(str1) RETURNING str1
     LET msg = "Allowable NPD table is undefined in spec \"",
                str1 CLIPPED,"\"."
     RETURN 1
  END IF
  IF (compstr.c_spec_no IS NULL) THEN
     LET str1 = compstr.s_spec_no
     CALL check_value(str1) RETURNING str1
     LET str2 = p_form3.comp_code
     CALL check_value(str2) RETURNING str2
     LET str3 = p_form3.opt_code
     CALL check_value(str3) RETURNING str3
     LET msg = "No entry found in PIPING_COMPS for spec table \"",
               str1 CLIPPED,"\", component \"",
               str2 CLIPPED,"\", option \"",str3 CLIPPED,
               "\"."
     RETURN 1
  END IF

  DECLARE npd_exists CURSOR FOR
    SELECT *

    FROM "nfmadmin".piping_npd_allowed

    WHERE "nfmadmin".piping_npd_allowed.tblno = compstr.npd_tblno

  IF STATUS != 0 THEN
     LET str1 = compstr.npd_tblno
     CALL check_value(str1) RETURNING str1
     LET msg = "Table number \"",str1 CLIPPED,
               "\" not found in PIPING_NPD_ALLOWED."
     RETURN 1
  END IF

  CALL comp_rcd()

  RETURN 0

END FUNCTION

FUNCTION comp_rcd()

  DEFINE i INTEGER
  DEFINE str1 CHAR(80)

  IF (compstr.family_name IS NULL or
      compstr.family_name = " ") THEN
     LET msg = "PDM family name is undefined."
     RETURN
  END IF
  IF (compstr.part_no_prfx IS NULL or
      compstr.part_no_prfx = " ") THEN
     LET msg = "Part number prefix is undefined."
     RETURN
  END IF

  DECLARE family_exists CURSOR FOR
    SELECT *

    FROM "nfmadmin".nfmcatalogs

    WHERE "nfmadmin".nfmcatalogs.n_catalogname = compstr.family_name

  IF STATUS != 0 THEN
     LET str1 = compstr.family_name
     CALL check_value(str1) RETURNING str1
     LET msg = "PDM family \"",str1 CLIPPED,"\" does not exist."
     RETURN
  END IF

  DECLARE entry_exists CURSOR FOR
    SELECT *

    FROM "nfmadmin".piping_comp_type

    WHERE "nfmadmin".piping_comp_type.comp_code = compstr.comp_code
      AND "nfmadmin".piping_comp_type.comp_shcode = compstr.short_code

  IF STATUS != 0 THEN
     LET msg = "No entry found in PIPING_COMP_TYPE."
     RETURN
  END IF

  DECLARE get_npd_grn CURSOR FOR
    SELECT "nfmadmin".piping_npd_allowed.npd

      FROM "nfmadmin".piping_npd_allowed

      WHERE "nfmadmin".piping_npd_allowed.tblno = compstr.npd_tblno
        AND "nfmadmin".piping_npd_allowed.npd >= compstr.size_g_low
        AND "nfmadmin".piping_npd_allowed.npd <= compstr.size_g_high

      order by "nfmadmin".piping_npd_allowed.npd

  LET i = 0
  FOREACH get_npd_grn INTO npd_grn
    IF STATUS != 0 THEN
       EXIT FOREACH
    ELSE
       CALL comp_grn()
       LET i = i + 1
    END IF
  END FOREACH

  IF i = 0 THEN
     LET str1 = compstr.npd_tblno
     CALL check_value(str1) RETURNING str1
     LET msg = "No valid NPD's found in PIPING_NPD_ALLOWED for table number \"",
               str1 CLIPPED,"\"."
  END IF

END FUNCTION

FUNCTION comp_grn()

   DEFINE i INTEGER
  DEFINE str1 CHAR(80)

   IF compstr.size_r_low = 0 THEN		#PROCESS 1-SIZED COMPONENT
      LET npd_red = 0.
      CALL component()
      RETURN
   ELSE						#PROCESS 2-SIZED COMPONENT
      DECLARE get_npd_red CURSOR FOR		#GET ALLOWED NPD'S IN THE RANGE
        SELECT "nfmadmin".piping_npd_allowed.npd		#THAT ARE SMALLER THAN THE
						#CURRENT GREEN SIZE
        FROM "nfmadmin".piping_npd_allowed

        WHERE "nfmadmin".piping_npd_allowed.npd >= compstr.size_r_low
          AND "nfmadmin".piping_npd_allowed.npd <= compstr.size_r_high
          AND npd_grn > "nfmadmin".piping_npd_allowed.npd

        order by "nfmadmin".piping_npd_allowed.npd

      LET i = 0
      FOREACH get_npd_red INTO npd_red		#PROCESS AT MOST 2 RED NPD'S
         IF STATUS != 0 or i >= 2 THEN
            EXIT FOREACH
         ELSE
            CALL component()
            LET i = i + 1
         END IF
      END FOREACH

      IF i = 0 THEN
         LET size1 = npd_grn
         LET size2 = ""
         LET size3 = compstr.size_r_low
         LET size4 = compstr.size_r_high
         LET str1 = compstr.npd_tblno
         CALL check_value(str1) RETURNING str1
         LET msg =
  "No valid NPD's found in PIPING_NPD_ALLOWED for red END for table number \"",
  str1 CLIPPED,"\"."
      END IF
   END IF
END FUNCTION

FUNCTION component()

  DEFINE str1,str2,str3,str4,str5 CHAR(80)

   DEFINE sch_grn     LIKE "nfmadmin".piping_comps.sch_thk_g,
          sch_red     LIKE "nfmadmin".piping_comps.sch_thk_r,
          pdm_part_num LIKE "nfmadmin".piping_commod_code.pdm_part_num
   DEFINE i INTEGER
   DEFINE query_str CHAR(300)

   LET sch_grn = compstr.sch_thk_g

   IF compstr.sch_thk_g = "MATCH" THEN		#CONVERT MATCH TO A SCHEDULE
      CALL cvrtsch_g (compstr.s_spec_no,npd_grn) RETURNING STATUS,sch_grn
      IF STATUS != 0 THEN
         LET size1 = npd_grn
         LET size2 = ""
         LET size3 = ""
         LET size4 = ""
         LET str1 = compstr.s_spec_no
         CALL check_value(str1) RETURNING str1
         LET msg = "Unable to convert \"MATCH\" schedule in spec number \"",
                   str1 CLIPPED,"\" for green end."
         RETURN
      END IF
   END IF

   IF sch_grn = "NREQD" THEN			#NULL OUT SCHEDULES THAT ARE NREQD
      LET sch_grn = " "
   END IF

   LET sch_red = compstr.sch_thk_r

   IF sch_red IS NOT NULL AND sch_red != " " THEN
      IF compstr.sch_thk_r = "MATCH" THEN	#FOR 2-SIZED COMPONENTS CONVERT MATCH SCHEDULE
         CALL cvrtsch_r (compstr.s_spec_no,npd_red) RETURNING STATUS,sch_red
         IF STATUS != 0 THEN
            LET size1 = npd_grn
            LET size2 = npd_red
            LET size3 = ""
            LET size4 = ""
            LET str1 = compstr.s_spec_no
            CALL check_value(str1) RETURNING str1
            LET msg = "Unable to convert \"MATCH\" schedule in spec number \"",
                       str1 CLIPPED,"\" for red end."
            RETURN
         END IF
      END IF
   END IF

   IF sch_red = "NREQD" THEN			#NULL OUT SCHEDULES THAT ARE NREQD
      LET sch_red = " "
   END IF


   LET i = 0

   DECLARE get_part_num CURSOR FOR		#TRY TO GET PDM PART NUMBER
     SELECT "nfmadmin".piping_commod_code.pdm_part_num

     FROM "nfmadmin".piping_commod_code

     WHERE "nfmadmin".piping_commod_code.si_comm_code = compstr.part_no_prfx
       AND "nfmadmin".piping_commod_code.size_g = npd_grn
       AND "nfmadmin".piping_commod_code.size_r = npd_red
       AND "nfmadmin".piping_commod_code.sch_thk_g = sch_grn
       AND "nfmadmin".piping_commod_code.sch_thk_r = sch_red

   FOREACH get_part_num INTO pdm_part_num
      IF STATUS != 0 THEN
         EXIT FOREACH
      ELSE
        LET query_str = "SELECT * FROM \"nfmadmin\".",compstr.family_name CLIPPED,
          " WHERE n_itemname = \"",pdm_part_num CLIPPED, "\""

        prepare args FROM query_str
        DECLARE part_num_exists CURSOR FOR args
        IF STATUS != 0 THEN
           LET size1 = npd_grn
           LET size2 = ""
           LET size3 = ""
           LET size4 = ""
           LET str1 = compstr.family_name
           CALL check_value(str1) RETURNING str1
           LET str2 = pdm_part_num
           CALL check_value(str2) RETURNING str2
           LET msg = "No PDM part found in family \"",str1 CLIPPED,
                      "\" with part number \"",str2 CLIPPED,"\"."
           RETURN
        ELSE
           LET msg = "Ok."
        END IF
        LET i = i + 1
      END IF
   END FOREACH
   IF i = 0 THEN
      LET size1 = npd_grn
      LET size2 = ""
      LET size3 = ""
      LET size4 = ""
      LET str1 = compstr.part_no_prfx
      CALL check_value(str1) RETURNING str1
      LET str2 = npd_grn
      CALL check_value(str2) RETURNING str2
      LET str3 = npd_red
      CALL check_value(str3) RETURNING str3
      LET str4 = sch_grn
      CALL check_value(str4) RETURNING str4
      LET str5 = sch_red
      CALL check_value(str5) RETURNING str5
      LET msg = "No entry found in PIPING_COMMOD_CODE for part code \"",
                str1 CLIPPED,"\",size 1 \"",str2 CLIPPED,
                "\", size 2 \"",str3 CLIPPED,"\", schedule 1 \"",
                str4 CLIPPED,"\", schedule 2 \"",str5 CLIPPED,"\"."
   END IF
END FUNCTION

FUNCTION cvrtsch_g (in_spec_no,in_npd)

   DEFINE in_spec_no LIKE "nfmadmin".piping_comps.spec_no
   DEFINE in_npd     LIKE "nfmadmin".piping_npd_allowed.npd
   DEFINE out_sch     LIKE "nfmadmin".piping_comps.sch_thk_g
   DEFINE i INTEGER

   DECLARE get_sch_g CURSOR FOR	
     SELECT "nfmadmin".piping_comps.sch_thk_g

     FROM "nfmadmin".piping_comps

     WHERE "nfmadmin".piping_comps.spec_no = in_spec_no
       AND "nfmadmin".piping_comps.comp_code = "PIPING"
       AND in_npd >= "nfmadmin".piping_comps.size_g_low
       AND in_npd <= "nfmadmin".piping_comps.size_g_high
       AND "nfmadmin".piping_comps.opt_code = 1


   LET i = 0
   FOREACH get_sch_g INTO out_sch
      IF STATUS = 0 THEN
         LET i = i + 1
      END IF
      EXIT FOREACH
   END FOREACH
    IF i = 0 THEN
       LET STATUS = 1
    END IF

    RETURN STATUS,out_sch
END FUNCTION

FUNCTION cvrtsch_r (in_spec_no,in_npd)

   DEFINE in_spec_no LIKE "nfmadmin".piping_comps.spec_no
   DEFINE in_npd     LIKE "nfmadmin".piping_npd_allowed.npd
   DEFINE out_sch     LIKE "nfmadmin".piping_comps.sch_thk_r
   DEFINE i INTEGER

   DECLARE get_sch_r CURSOR FOR	
     SELECT "nfmadmin".piping_comps.sch_thk_r

     FROM "nfmadmin".piping_comps

     WHERE "nfmadmin".piping_comps.spec_no = in_spec_no
       AND "nfmadmin".piping_comps.comp_code = "PIPING"
       AND in_npd >= "nfmadmin".piping_comps.size_r_low
       AND in_npd <= "nfmadmin".piping_comps.size_r_high
       AND "nfmadmin".piping_comps.opt_code = 1


   LET i = 0
   FOREACH get_sch_r INTO out_sch
      IF STATUS = 0 THEN
         LET i = i + 1
      END IF
      EXIT FOREACH
   END FOREACH
    IF i = 0 THEN
       LET STATUS = 1
    END IF

    RETURN STATUS,out_sch
END FUNCTION

FUNCTION check_value(invalue)
  DEFINE invalue CHAR(80)
  DEFINE outchar CHAR(80)
  IF ( invalue IS NULL ) THEN
     LET outchar = "<null>"
  ELSE
     IF invalue = " " THEN
        LET outchar = "<blank>"
     ELSE
        LET outchar = invalue
     END IF
  END IF
  RETURN outchar
END FUNCTION

FUNCTION split_string(msg)
  DEFINE msg,buffer CHAR(300)
  DEFINE msg1,msg2,msg3,msg4,msg5 CHAR(70)
  DEFINE i,pos INTEGER

  LET msg1 = ""
  LET msg2 = ""
  LET msg3 = ""
  LET msg4 = ""
  LET msg5 = ""

  LET pos = 1
  LET buffer = msg
  IF length(buffer) <= 70 THEN
     LET msg1 = buffer
     GOTO slut
  END IF

  LET i = 70
  WHILE i > 0
     IF buffer[i] = " " or buffer[i] = "," THEN
        LET msg1 = buffer[1,i]
        EXIT WHILE
     END IF
     LET i = i - 1
  END WHILE

  IF i = 0 THEN		# No space found; copy full string
     LET i = 70
     LET msg1 = buffer[1,i]
  END IF

  LET pos = pos + i
  LET buffer = msg[pos,300]
  IF length(buffer) <= 70 THEN
     LET msg2 = buffer
     GOTO slut
  END IF

  LET i = 70
  WHILE i > 0
     IF buffer[i] = " " or buffer[i] = "," THEN
        LET msg2 = buffer[1,i]
        EXIT WHILE
     END IF
     LET i = i - 1
  END WHILE

  IF i = 0 THEN		# No space found; copy full string
     LET i = 70
     LET msg2 = buffer[1,i]
  END IF

  LET pos = pos + i
  LET buffer = msg[pos,300]
  IF length(buffer) <= 70 THEN
     LET msg3 = buffer
     GOTO slut
  END IF

  LET i = 70
  WHILE i > 0
     IF buffer[i] = " " or buffer[i] = "," THEN
        LET msg3 = buffer[1,i]
        EXIT WHILE
     END IF
     LET i = i - 1
  END WHILE

  IF i = 0 THEN		# No space found; copy full string
     LET i = 70
     LET msg3 = buffer[1,i]
  END IF

  LET pos = pos + i
  LET buffer = msg[pos,300]
  IF length(buffer) <= 70 THEN
     LET msg4 = buffer
     GOTO slut
  END IF

  LET i = 70
  WHILE i > 0
     IF buffer[i] = " " or buffer[i] = "," THEN
        LET msg4 = buffer[1,i]
        EXIT WHILE
     END IF
     LET i = i - 1
  END WHILE

  IF i = 0 THEN		# No space found; copy full string
     LET i = 70
     LET msg4 = buffer[1,i]
  END IF

  LET pos = pos + i
  LET buffer = msg[pos,300]
  IF length(buffer) <= 70 THEN
     LET msg5 = buffer
     GOTO slut
  END IF

  LET i = 70
  WHILE i > 0
     IF buffer[i] = " " or buffer[i] = "," THEN
        LET msg5 = buffer[1,i]
        EXIT WHILE
     END IF
     LET i = i - 1
  END WHILE

  IF i = 0 THEN		# No space found; copy full string
     LET i = 70
     LET msg5 = buffer[1,i]
  END IF
     
LABEL slut:
  RETURN msg1,msg2,msg3,msg4,msg5
END FUNCTION
