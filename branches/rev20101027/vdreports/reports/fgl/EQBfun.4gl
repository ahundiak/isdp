DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION EQBquery()

   LET w_reg =
""

   LET f_reg =
"\"nfmadmin\".equip_dynamic"

##########################  Create EQB query ###################################
   LET s_stmt =
"\"nfmadmin\".equip_dynamic.eqp_type, ",
"\"nfmadmin\".equip_dynamic.eqp_number, ",
"\"nfmadmin\".equip_dynamic.eqp_descr, ",
"\"nfmadmin\".equip_dynamic.eqp_partno"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "equip_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".equip_dynamic.eqp_number"

   CALL RPTquery ( 0, 1)
END FUNCTION
