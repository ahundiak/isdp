DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION EQNquery ()

   LET w_reg =
" AND (\"nfmadmin\".piping_codelist.list_num   = 1510) ",
"AND (\"nfmadmin\".piping_codelist.code_num   = \"nfmadmin\".equip_dynamic.chg_no)"

   LET f_reg =
"\"nfmadmin\".equip_dynamic, ",
"OUTER (\"nfmadmin\".piping_codelist)"

##########################  Create EQN query ###################################
   LET s_stmt =
"\"nfmadmin\".equip_dynamic.chg_no, ",
"\"nfmadmin\".equip_dynamic.eqp_number, ",
"\"nfmadmin\".equip_dynamic.eqp_partno, ",
"\"nfmadmin\".equip_dynamic.eqp_descr, ",
"\"nfmadmin\".equip_dynamic.wet_weight, ",
"\"nfmadmin\".piping_codelist.long_txt"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "equip_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   CALL RPTquery ( 0, 0)

END FUNCTION

FUNCTION EQNdescription ()
  DEFINE EQNdesc	CHAR(20),
	 EQNwet_wgt	FLOAT
  
  IF p_eqn.eqp_number != ""
  OR p_eqn.eqp_number != " "
  OR p_eqn.eqp_number IS NOT NULL THEN LET EQNdesc = p_eqn.eqp_number
  ELSE
     IF p_eqn.eqp_partno != ""
     OR p_eqn.eqp_partno != " "
     OR p_eqn.eqp_partno IS NOT NULL THEN LET EQNdesc = p_eqn.eqp_partno
     ELSE
        IF p_eqn.eqp_descr  != ""
        OR p_eqn.eqp_descr  != " "
        OR p_eqn.eqp_descr  IS NOT NULL THEN LET EQNdesc = p_eqn.eqp_descr
        ELSE 				      LET EQNdesc = "UNKNOWN"
        END IF
     END IF
  END IF


  LET EQNwet_wgt = p_eqn.wet_weight
  IF EQNwet_wgt IS NULL OR EQNwet_wgt = "" OR EQNwet_wgt = " " THEN
     LET EQNwet_wgt = 0.0
  END IF

  RETURN EQNdesc, EQNwet_wgt
END FUNCTION
