DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION BMWpart ()

  CALL ERRORLOG ("Enter in  Beam Weight report")
  OPTIONS MESSAGE line 22
  MESSAGE "Overall Weight report (beam) in progress... please wait"

  CALL RPTdrawing (0)
  CALL RPTwhere_begin (0)

  CALL BMWquery ()
  PREPARE bmw_stmt FROM q_stmt
  DECLARE bmw_curs CURSOR FOR bmw_stmt

  START REPORT BMWreport TO "BEAM"
     FOREACH bmw_curs INTO p_bmw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in beam query")
           MESSAGE "No rows found in beam query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL BMWconvert ()
           OUTPUT TO REPORT BMWreport ()
        END IF
     END FOREACH
  FINISH REPORT BMWreport

  BEGIN WORK
  LOAD FROM "BEAM" INSERT INTO mftable
  COMMIT WORK
END FUNCTION


FUNCTION PLWpart ()

  CALL ERRORLOG ("Enter in  Plate Weight report")
  OPTIONS MESSAGE line 22
  MESSAGE "Overall Weight report (plate) in progress... please wait"

  CALL RPTdrawing (5)
  CALL RPTwhere_begin (5)

  CALL PLWquery ()
  PREPARE plw_stmt FROM q_stmt
  DECLARE plw_curs CURSOR FOR plw_stmt

  START REPORT PLWreport TO "PLATE"
     FOREACH plw_curs INTO p_plw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in plate query")
           MESSAGE "No rows found in plate query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL PLWconvert ()
           OUTPUT TO REPORT PLWreport ()
        END IF
     END FOREACH
  FINISH REPORT PLWreport

  BEGIN WORK
  LOAD FROM "PLATE" INSERT INTO mftable
  COMMIT WORK
END FUNCTION


FUNCTION PPWpart ()
  DEFINE p_calc RECORD sch_thk_tmp_g    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       sch_thk_tmp_r    LIKE "nfmadmin".piping_dynamic.sch_thk_ovr,
                       pdm_part_num     LIKE "nfmadmin".piping_commod_code.pdm_part_num
                END RECORD
  DEFINE p_attr RECORD arg1             CHAR(10),
                       arg2             CHAR(10),
                       arg3             CHAR(10),
                       arg4             CHAR(10),
                       arg5             CHAR(10),
                       arg6             CHAR(10)
                END RECORD
  DEFINE p_args RECORD dry_wt           FLOAT,
                       wet_wt           FLOAT,
                       surf_area        FLOAT,
                       arg1             FLOAT,
                       arg2             FLOAT,
                       arg3             FLOAT,
                       arg4             FLOAT,
                       arg5             FLOAT,
                       arg6             FLOAT
                END RECORD
  DEFINE p_star RECORD dry_wgt          CHAR(1),
                       wet_wgt          CHAR(1),
                       ins_wgt          CHAR(1),
                       tot_wgt          CHAR(1)
                END RECORD
  DEFINE query_str 	CHAR(300)

  CALL ERRORLOG ("Enter in  Piping Weight report")
  OPTIONS MESSAGE line 22
  MESSAGE "Overall Weight report (piping) in progress... please wait"

  CALL RPTdrawing (6)
  CALL RPTwhere_begin (6)

  CALL PPWquery ()
  PREPARE ppw_stmt1 FROM q_stmt
  DECLARE ppw_curs1 CURSOR FOR ppw_stmt1

  START REPORT PPWreport TO "PIPING"
     FOREACH ppw_curs1 INTO p_ppw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in piping query 1")
           MESSAGE "No rows found in piping query 1"
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL PPWpost_query ()
                RETURNING p_calc.*, p_attr.*, p_args.*, p_star.*, query_str
  
           PREPARE ppw_stmt2 FROM query_str
           DECLARE ppw_curs2 CURSOR FOR ppw_stmt2

           FOREACH ppw_curs2 INTO p_args.*
              IF STATUS < 0 THEN
                 CALL ERRORLOG ("No rows found in piping query 2")
                 MESSAGE "No rows found in piping query 2"
                 SLEEP 3
                 DISPLAY "family_name = ", p_ppw.family_name CLIPPED
                 DISPLAY "n_itemname  = ", p_calc.pdm_part_num CLIPPED
                 SLEEP 3
                 EXIT FOREACH
              ELSE
                 CALL PPWconvert ( p_calc.*, p_attr.*, p_args.*)
                      RETURNING p_args.*
              END IF
           END FOREACH

           OUTPUT TO REPORT PPWreport ( p_calc.*, p_args.*, p_star.*)
        END IF
     END FOREACH
  FINISH REPORT PPWreport

  BEGIN WORK
  LOAD FROM "PIPING" INSERT INTO mftable
  COMMIT WORK
END FUNCTION


FUNCTION HVWpart ()
  DEFINE p_calc RECORD comp_wt_star     CHAR(1),
                       insul_star       CHAR(1)
                END RECORD

  CALL ERRORLOG ("Enter in  Hvac Weight report")
  OPTIONS MESSAGE line 22
  MESSAGE "Over Weight report (hvac) in progress... please wait"

  CALL RPTdrawing (2)
  CALL RPTwhere_begin (2)

  CALL HVWquery ()
  PREPARE hvw_stmt FROM q_stmt
  DECLARE hvw_curs CURSOR FOR hvw_stmt

  START REPORT HVWreport TO "HVAC"
     FOREACH hvw_curs INTO p_hvw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in hvac query")
           MESSAGE "No rows found in hvac query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           CALL HVWstar (p_calc.*)
                RETURNING p_calc.comp_wt_star, p_calc.insul_star
           OUTPUT TO REPORT HVWreport ()
        END IF
     END FOREACH
  FINISH REPORT HVWreport

  BEGIN WORK
  LOAD FROM "HVAC" INSERT INTO mftable
  COMMIT WORK
END FUNCTION


FUNCTION EQWpart ()

  CALL ERRORLOG ("Enter in  Equipment Weight report")
  OPTIONS MESSAGE line 22
  MESSAGE "Over Weight report (equipment) in progress... please wait"

  CALL RPTdrawing (1)
  CALL RPTwhere_begin (1)

  CALL EQWquery ()
  PREPARE eqw_stmt FROM q_stmt
  DECLARE eqw_curs CURSOR FOR eqw_stmt

  START REPORT EQWreport TO "EQUP"
     FOREACH eqw_curs INTO p_eqw.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in equipment query")
           MESSAGE "No rows found in equipment query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT EQWreport ()
        END IF
     END FOREACH
  FINISH REPORT EQWreport

  BEGIN WORK
  LOAD FROM "EQUP" INSERT INTO mftable
  COMMIT WORK
END FUNCTION


FUNCTION RWWpart ()

  CALL ERRORLOG ("Enter in  Raceway Weight report")
  OPTIONS MESSAGE line 22
  MESSAGE "Over Weight report (raceway) in progress... please wait"

  CALL RPTdrawing (7)
  CALL RPTwhere_begin (7)

  CALL RWWquery ()
  PREPARE rww_stmt FROM q_stmt
  DECLARE rww_curs CURSOR FOR rww_stmt

  START REPORT RWWreport TO "RWAY"
     FOREACH rww_curs INTO p_rww.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in raceway query")
           MESSAGE "No rows found in raceway query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT RWWreport ()
        END IF
     END FOREACH
  FINISH REPORT RWWreport

  BEGIN WORK
  LOAD FROM "RWAY" INSERT INTO mftable
  COMMIT WORK
END FUNCTION


FUNCTION OVWpart ()

  DECLARE ov_curs CURSOR FOR
    SELECT prj_no, 
           comp_seqno, 
           weight_grp, 
           ship_alt, 
           discipline, 
           description, 
           total_wgt,
           vcg, 
           lcg, 
           tcg, 
           vmom, 
           lmom, 
           tmom
    FROM "nfmadmin".mftable
    ORDER BY weight_grp,
             ship_alt,
	     discipline

  CALL ERRORLOG ("Enter in Overall Weight report")
  OPTIONS MESSAGE line 22
  MESSAGE "Overall Weight report in progress... please wait"

  START REPORT OVWform TO "OVWform"
    OUTPUT TO REPORT OVWform ()
  FINISH REPORT OVWform

  START REPORT OVWreport TO pipe "OVW.sh"
     FOREACH ov_curs INTO p_over.*
        IF STATUS < 0 THEN
           CALL ERRORLOG ("No rows found in overall query")
           MESSAGE "No rows found in overall query"
           SLEEP 3
           EXIT FOREACH
        ELSE
           OUTPUT TO REPORT OVWreport (p_over.weight_grp)
        END IF
     END FOREACH
  FINISH REPORT OVWreport
END FUNCTION
