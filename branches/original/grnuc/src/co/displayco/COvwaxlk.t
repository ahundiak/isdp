options			"si" 
product_name		"$GRNUC"
class			COaxlocks
command_string  GRMVwAxLk1,0,GRSlPnOnVC
synonym		GRMVwAxLk,0,GRSlPnOnVC

start_state       	vw_lock1

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	vw_lock1
	on EX_BACK_UP 	state   previous_state 
 
state	vw_lock1

	msg_key  	GRC_M_VwAxLk
	prompt_key   	GR_P_EntOrgAx
	filter	  	get_event

	on EX_DATA	do  dspl_buffrs1 
			    on FunFail state terminate
		 	state  vw_lock2

state  vw_lock2

	filter	      get_event
	
	on EX_DATA  		do project_point1 state terminate

	on EX_RJT_MOVEON	state vw_lock1


