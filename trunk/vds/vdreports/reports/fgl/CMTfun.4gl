DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

##########################  Create CMT query1 #################################

FUNCTION CMTquery1()

   LET w_reg =
""

   LET f_reg =
"\"nfmadmin\".compart_dynamic"

   LET s_stmt =
"\"nfmadmin\".compart_dynamic.partno, ",
"\"nfmadmin\".compart_dynamic.partrev, ",
"COUNT(*)"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "compart_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_reg CLIPPED

   LET o_stmt =""

   LET g_stmt ="\"nfmadmin\".compart_dynamic.partno,\"nfmadmin\".compart_dynamic.partrev"

#   CALL RPTquery ( 1, 0)
#   Cannot use the standard query, as there is no where clause.

   LET q_stmt = "SELECT ", s_stmt CLIPPED,
		" \nFROM ", f_stmt CLIPPED,
		" \nGROUP BY ",g_stmt CLIPPED
END FUNCTION


##########################  Create CMT query2 #################################

FUNCTION CMTquery2(num)
   DEFINE    num   INTEGER

   LET s_stmt =
"\"nfmadmin\".compart_dynamic.assembly_cat, ",
"\"nfmadmin\".compart_dynamic.assembly_nam, ",
"\"nfmadmin\".compart_dynamic.assembly_ver, ",
"\"nfmadmin\".compart_dynamic.name, ",
"\"nfmadmin\".compart_dynamic.descript, ",
"\"nfmadmin\".compart_dynamic.partno, ",
"\"nfmadmin\".compart_dynamic.partrev"


   LET f_stmt =
"\"nfmadmin\".compart_dynamic"

   LET w_stmt =
"    (\"nfmadmin\".compart_dynamic.partno LIKE '", p_cmt1[num].partno CLIPPED , "'",
"AND \"nfmadmin\".compart_dynamic.partrev LIKE '", p_cmt1[num].partrev CLIPPED ,"')"

   CALL RPTquery ( 0, 0)
END FUNCTION

