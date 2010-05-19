DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION NZBquery()

   LET w_reg =
""

   LET f_reg =
"\"nfmadmin\".piping_noz_dynamic"

##########################  Create NZB query ###################################
   LET s_stmt =
"\"nfmadmin\".piping_noz_dynamic.eqp_number, ",
"\"nfmadmin\".piping_noz_dynamic.tag_number, ",
"\"nfmadmin\".piping_noz_dynamic.npd_g, ",
"\"nfmadmin\".piping_noz_dynamic.rating_g, ",
"\"nfmadmin\".piping_noz_dynamic.prep_g, ",
"\"nfmadmin\".piping_noz_dynamic.seq_number, ",
"\"nfmadmin\".piping_noz_dynamic.spec_name, ",
"\"nfmadmin\".piping_noz_dynamic.insul_type, ",
"\"nfmadmin\".piping_noz_dynamic.insul_thk, ",
"\"nfmadmin\".piping_noz_dynamic.tracing_code, ",
"\"nfmadmin\".piping_noz_dynamic.paint_code, ",
"\"nfmadmin\".piping_noz_dynamic.op_temp, ",
"\"nfmadmin\".piping_noz_dynamic.op_press, ",
"\"nfmadmin\".piping_noz_dynamic.dgn_temp, ",
"\"nfmadmin\".piping_noz_dynamic.dgn_press, ",
"\"nfmadmin\".piping_noz_dynamic.spec_grav, ",
"\"nfmadmin\".piping_noz_dynamic.apprv_stat, ",
"\"nfmadmin\".piping_noz_dynamic.constr_stat"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "\"nfmadmin\".piping_noz_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".piping_noz_dynamic.eqp_number, ",
"\"nfmadmin\".piping_noz_dynamic.tag_number"

   CALL RPTquery ( 0, 1)
END FUNCTION
