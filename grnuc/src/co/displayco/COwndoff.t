/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string		GRMWinOff,11,GRTrOfV
start_state       	wnd_off
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	wnd_off
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act


state	wnd_off

	msg_key         GRC_M_WinOff
	prompt_key	GR_P_IdWin
	filter		get_event

   on  EX_DATA or TEXT_VALUE      do get_graphic_gadget (DstGGid,MAX_WINDOW,ExstGG) 
                                   on SrchFlt state wnd_off
                                   on SUCCESS do wnd_off
 			                      on ERROR state terminate
                                              state wnd_off
                               	 state wnd_off

  on  EX_RJT_MOVEON	  state wnd_off

