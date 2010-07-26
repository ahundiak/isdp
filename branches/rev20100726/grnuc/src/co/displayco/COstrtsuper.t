options			"si" 
product_name		"$GRNUC"
class			COceocmds
command_string	GRMDrftFst,7,GRDrftFst	

start_state     super_state

state_table

state super_state

	on ELSE		do action1
                        state terminate




