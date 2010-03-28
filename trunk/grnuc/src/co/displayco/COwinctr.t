/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string 		GRMWinCen,4,GRCVCn
start_state       	get_ctrpt
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_ctrpt
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act


state	get_ctrpt

	msg_key         GRC_M_WinCen
	prompt_key      GR_P_EntCenPt 
	filter		get_event

	on EX_DATA  	do get_dt_pt(FrstPt) 
                           state get_wndctr


state	get_wndctr

	prompt_key      GR_P_IdWin 
	filter		get_event

  on EX_DATA or TEXT_VALUE     	do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
                                   on SrchFlt     state get_wndctr
                                   on SUCCESS do get_wndctr	
					      on ERROR  state terminate
                           		   state get_wndctr
                                state get_wndctr

 on EX_RJT_MOVEON		state get_ctrpt
