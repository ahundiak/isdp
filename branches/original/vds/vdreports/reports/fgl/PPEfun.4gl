DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION PPEquery()

  LET w_reg = 
" AND \"nfmadmin\".piping_dynamic.err_cmp_flg  = 'Y'"

  LET f_reg =
"\"nfmadmin\".piping_dynamic"

##########################  Create PPE query ###################################
  LET s_stmt =
" \"nfmadmin\".piping_dynamic.spec_name, ",
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_dynamic.comp_code, ",
"\"nfmadmin\".piping_dynamic.npd_g, ",
"\"nfmadmin\".piping_dynamic.npd_r, ",
"\"nfmadmin\".piping_dynamic.opt_code, ",
"\"nfmadmin\".piping_dynamic.loc_x, ",
"\"nfmadmin\".piping_dynamic.loc_y, ",
"\"nfmadmin\".piping_dynamic.loc_z, ",
"\"nfmadmin\".piping_dynamic.err_cmp_flg"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "\"nfmadmin\".piping_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".piping_dynamic.seq_number, ",
"\"nfmadmin\".piping_dynamic.comp_code"

   CALL RPTquery ( 0, 1)
END FUNCTION
