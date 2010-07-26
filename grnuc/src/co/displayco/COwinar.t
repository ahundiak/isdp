/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string  	GRMWinAr,1,GRCVAr
start_state       	get_pt1
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_pt1
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act


state	get_pt1

	msg_key         GRC_M_WinAr
	prompt_key	GR_P_EntPt1
	filter		get_event

	on EX_DATA  	do get_dt_pt(FrstPt) 
                           state get_pt2

state	get_pt2

	msg_key         GRC_M_WinAr
	prompt_key	GR_P_EntPt2
	filter		get_event

	on EX_DATA  	do get_dt_pt(ScndPt)
                           state idnt_wnd1
state   idnt_wnd1
	 
	prompt_key	GR_P_IdWin
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
                                       on SrchFlt state idnt_wnd1
                                       on SUCCESS do idnt_wnd1
                                                    on ERROR  state terminate
			               		  state idnt_wnd1
			          state idnt_wnd1

	on EX_RJT_MOVEON	  state get_pt1
