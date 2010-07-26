/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string		GRMDpActDep,5,GRShZ
synonym			GRMDpDpDep,6,GRShDp
synonym			GRMDpVwVol,7,GRShVVl
start_state       	window
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state  window
	on EX_BACK_UP 	state 	-

at wakeup do wakeup_act


state	window

	prompt_key	GR_P_IdWin
	filter		get_event

  on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,OneWnd,ExstGG) 
	  			on SrchFlt  state window
   			        on SUCCESS do dspl
                                              on ERROR state terminate
					      state window
                                state window

  on  EX_RJT_MOVEON		state window


