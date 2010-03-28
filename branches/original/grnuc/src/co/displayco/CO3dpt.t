options			"si" 
product_name		"$GRNUC"
class			COaxlocks
command_string		GRM3DPt,2,GRSl3DPn

start_state       	get_pt11

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_pt11
	on EX_BACK_UP 	state   previous_state 


state	get_pt11

	msg_key         GRC_M_3DPt
/*
	filter		none
*/
	on ELSE  	do get_pt11
			   on ERROR state terminate
                        state get_pt1
state	get_pt1


	msg_key         GRC_M_3DPt
	filter		get_event

	on EX_DATA  	do get_pt1
			   on ERROR or FunFail state terminate
                         state get_pt22

	on NULL_TEXT_VALUE	state get_pt11
        on EX_RESTART           state get_pt11
        on EX_BACK_UP           state get_pt11
	on EX_RJT_MOVEON        state get_pt11

state	get_pt22

	msg_key         GRC_M_3DPt
/*
	filter		none
*/

	on ELSE  	do get_pt22
			   on ERROR or FunFail state terminate
                        state get_pt2

state	get_pt2

	msg_key         GRC_M_3DPt
	filter		get_event


	on EX_DATA  	do get_pt2
			   on ERROR or FunFail state terminate
                        state terminate

	on NULL_TEXT_VALUE	state get_pt22
        on EX_RESTART           state get_pt11
        on EX_BACK_UP           state get_pt11
	on EX_RJT_MOVEON        state get_pt22

