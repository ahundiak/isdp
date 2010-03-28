/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string		GRMSetActDep,0,GRSZDp
synonym			GRMAz,0,GRSZDp
start_state       	get_act_dep
		
		

/* OPP section */
/* Specification section .. code for .S file */


state_table

#include 	"grmessage.h"
#include	"griodef.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_act_dep
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act

state	get_act_dep

	msg_key         GRC_M_SetActDep
	prompt_key	GR_P_EntActDep

	scale_flag 	GRIO_Z_SCALE
	filter		get_event

	on DISTANCE or EX_DATA  	do get_act_dep
                           	        state get_wnd

state	get_wnd

	msg_key         GRC_M_SetActDep
	prompt_key	GR_P_IdWin
	filter		get_event

  on TEXT_VALUE or EX_DATA   do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
			       on SrchFlt state get_wnd
			       on SUCCESS do get_wnd
                                                  on ERROR state terminate
                           		       state get_wnd
                    	     state get_wnd

 on EX_RJT_MOVEON    	     state get_act_dep

