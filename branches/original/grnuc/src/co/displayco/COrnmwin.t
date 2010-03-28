/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string  	GRMRenmeWin,12,GRRnV
start_state       	get_wnd_name
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_wnd_name
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act



state	get_wnd_name

        msg_key         GRC_M_RenmeWin
	prompt_key   	GR_P_KyNwNmeWin
	filter		get_event

        on NULL_TEXT_VALUE  state get_wnd_name

	on TEXT_VALUE  	do check_wnd_name
			   on SUCCESS	do  get_graphic_gadget(SrcGGid,OneWnd,NonExstGG)
			   		    on SrchFlt	state .
                           		    on SUCCESS  do get_wnd_name 
				               		state rnm_wnd
					    state  .
              		   on SrchFlt  state .

			state terminate

state	rnm_wnd

	prompt_key   	GR_P_IdWin
	filter		get_event

	on EX_DATA or TEXT_VALUE do get_graphic_gadget(DstGGid,OneWnd,ExstGG)
              		            on SrchFlt  state get_wnd_name
				    on SUCCESS do rnm_wnd
                                                  on ERROR state terminate
                                               state get_wnd_name
                       		 state get_wnd_name

	on EX_RJT_MOVEON	state get_wnd_name

