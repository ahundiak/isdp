options			"si" 
product_name		"$GRNUC"
class			COaxlocks
command_string		GRMDbAxLk1,1,GRSlPnOnWr
synonym			GRMDbAxLk,1,GRSlPnOnWr

start_state     db_lock1  	

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	db_lock1
	on EX_BACK_UP 	state   previous_state 

state	db_lock1

	msg_key  	GRC_M_DbAxLk
	prompt_key    	GR_P_EntOrgAx
	filter	  	get_event
	
	on EX_DATA		do  dspl_buffrs	 state  db_lock2

state  db_lock2

	filter	      get_event
	
	
	on EX_DATA  		do project_point state terminate
	on EX_RJT_MOVEON	state db_lock1


