/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string	        GRMWinOn,10,GRTrOnV
start_state       	wnd_on
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	wnd_on
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act



state	wnd_on

	msg_key         GRC_M_WinOn
	prompt_key	GR_P_KyWinNme
	filter		get_event

   on  TEXT_VALUE  	      do get_graphic_gadget (DstGGid,MAX_WINDOW,ExstGG) 
                                   on SrchFlt state wnd_on
                                   on SUCCESS do wnd_on
 			                      on ERROR  state terminate
                                              state wnd_on
                                state wnd_on

  on  EX_RJT_MOVEON		state wnd_on
