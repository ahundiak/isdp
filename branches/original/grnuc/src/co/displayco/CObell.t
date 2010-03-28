options			"si" 
product_name		"$GRNUC"
class			COceocmds
command_string		GRMBelOnOff,0,GRBelOnOff

start_state     bell_onoff  	

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state	bell_onoff
/*
	filter		none
*/

	on ELSE		do bell_onoff
			state terminate

	on EX_RESTART 	state 	bell_onoff

	on EX_BACK_UP 	state   bell_onoff
 
	on EX_RJT_MOVEON  state bell_onoff
