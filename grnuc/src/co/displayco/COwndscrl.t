/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string 		GRMWinScr,13,GRMvVCn
start_state       	get_pt11
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_pt11
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act



state	get_pt11

	msg_key         GRC_M_WinScr
	prompt_key	GR_P_EntPt1
	filter		get_event

	on EX_DATA  	do get_dt_pt(FrstPt) 
			   do get_pt11
                           state get_pt22

state	get_pt22

	msg_key         GRC_M_WinScr
	prompt_key	GR_P_EntPt2
	filter		get_event

	on EX_DATA  	do get_dt_pt(ScndPt) 
			   on SUCCESS do get_pt22
					   state get_pt22
                        state get_pt22

        on EX_RJT_MOVEON	state get_pt11
