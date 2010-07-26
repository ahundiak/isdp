options			"si" 
product_name		"$GRNUC"
class			COmiscl
command_string		GRMLysOff,4,GRTrOfLy
synonym			GRMLysOn,5,GRTrOnLy

start_state     ly_onoff

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

#define   InvLy     6020
#define   DsplLvls  6021
#define   Chek_actvn  6022

at wakeup do wakeup_act

state *

	on EX_RESTART 	state 	ly_onoff
	on EX_BACK_UP 	state   previous_state 

state	ly_onoff
/*
	filter		none
*/

	on ELSE  	do decode_levels 
			   on ERROR state terminate
                        state get_string
state  get_string
	
	prompt_key	GR_P_KyLys
	filter		get_event


	on NULL_STRING	do err_msg
			state get_string

       on STRING	do get_string
			   on InvLy  state get_string
			   on DsplLvls  state display_levels
                           on Chek_actvn do display_levels
                                         state ly_onoff 
			state display_levels


state  display_levels
	
	prompt_key	GR_P_IdWin
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				     on SUCCESS do display_levels
				                state display_levels
				  state get_string

        on EX_RESTART or EX_BACK_UP state get_string

	on EX_RJT_MOVEON	state ly_onoff

