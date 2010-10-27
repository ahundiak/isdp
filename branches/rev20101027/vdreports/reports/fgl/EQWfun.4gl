DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION EQWquery ()

   LET w_reg =
" AND (\"nfmadmin\".piping_codelist.list_num   = 1510) ",
"AND (\"nfmadmin\".piping_codelist.code_num   = \"nfmadmin\".equip_dynamic.chg_no)"

   LET f_reg =
"\"nfmadmin\".equip_dynamic, ",
"OUTER (\"nfmadmin\".piping_codelist)"

##########################  Create EQW query ###################################
   LET s_stmt =
"\"nfmadmin\".equip_dynamic.chg_no, ",
"\"nfmadmin\".equip_dynamic.weight_grp, ",
"\"nfmadmin\".equip_dynamic.comp_seqno, ",
"\"nfmadmin\".equip_dynamic.eqp_number, ",
"\"nfmadmin\".equip_dynamic.eqp_partno, ",
"\"nfmadmin\".equip_dynamic.eqp_descr, ",
"\"nfmadmin\".equip_dynamic.dry_weight, ",
"\"nfmadmin\".equip_dynamic.wet_weight, ",
"\"nfmadmin\".equip_dynamic.cog_x, ",
"\"nfmadmin\".equip_dynamic.cog_y, ",
"\"nfmadmin\".equip_dynamic.cog_z, ",
"\"nfmadmin\".piping_codelist.long_txt"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "equip_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".equip_dynamic.chg_no, ",
"\"nfmadmin\".equip_dynamic.weight_grp"

   CALL RPTquery ( 0, 1)
END FUNCTION

FUNCTION EQWdescription ()
  DEFINE EQWdesc	CHAR(20),
	 EQWdry_wgt	FLOAT,
	 EQWwet_wgt	FLOAT,
	 EQWvcg		FLOAT,
	 EQWlcg		FLOAT,
	 EQWtcg		FLOAT,
	 EQWvmom	FLOAT,
	 EQWlmom	FLOAT,
	 EQWtmom	FLOAT
  
  IF p_eqw.eqp_number != ""
  OR p_eqw.eqp_number != " "
  OR p_eqw.eqp_number IS NOT NULL THEN LET EQWdesc = p_eqw.eqp_number
  ELSE
     IF p_eqw.eqp_partno != ""
     OR p_eqw.eqp_partno != " "
     OR p_eqw.eqp_partno IS NOT NULL THEN LET EQWdesc = p_eqw.eqp_partno
     ELSE
        IF p_eqw.eqp_descr  != ""
        OR p_eqw.eqp_descr  != " "
        OR p_eqw.eqp_descr  IS NOT NULL THEN LET EQWdesc = p_eqw.eqp_descr
        ELSE 				     LET EQWdesc = "UNKNOWN"
        END IF
     END IF
  END IF

  LET EQWdry_wgt = p_eqw.dry_weight
  IF EQWdry_wgt IS NULL OR EQWdry_wgt = "" OR EQWdry_wgt = " " THEN
     LET EQWdry_wgt = 0.0
  END IF

  LET EQWwet_wgt = p_eqw.wet_weight
  IF EQWwet_wgt IS NULL OR EQWwet_wgt = "" OR EQWwet_wgt = " " THEN
     LET EQWwet_wgt = 0.0
  END IF

  LET EQWvcg     = (p_eqw.cog_z - def_vcog) / 12.0
  IF EQWvcg IS NULL OR EQWvcg = "" OR EQWvcg = " " THEN LET EQWvcg = 0.0
  END IF

  LET EQWlcg     = (p_eqw.cog_x - def_lcog) / 12.0
  IF EQWlcg IS NULL OR EQWlcg = "" OR EQWlcg = " " THEN LET EQWlcg = 0.0
  END IF

  LET EQWtcg     = (p_eqw.cog_y - def_tcog) / 12.0
  IF EQWtcg IS NULL OR EQWtcg = "" OR EQWtcg = " " THEN LET EQWtcg = 0.0
  END IF

  LET EQWvmom    = EQWwet_wgt * EQWvcg
  IF EQWvmom IS NULL OR EQWvmom = "" OR EQWvmom = " " THEN LET EQWvmom = 0.0
  END IF

  LET EQWlmom    = EQWwet_wgt * EQWlcg
  IF EQWlmom IS NULL OR EQWlmom = "" OR EQWlmom = " " THEN LET EQWlmom = 0.0
  END IF

  LET EQWtmom    = EQWwet_wgt * EQWtcg
  IF EQWtmom IS NULL OR EQWtmom = "" OR EQWtmom = " " THEN LET EQWtmom = 0.0
  END IF

  RETURN EQWdesc, EQWdry_wgt, EQWwet_wgt,
         EQWvcg, EQWlcg, EQWtcg,
         EQWvmom, EQWlmom, EQWtmom
END FUNCTION
