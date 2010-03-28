options			"si" 
product_name		"$GRNUC"
class			COcnstrpl
command_string		GRMDfnCnsPl3Pt,0,GRPCnPl3Pn

start_state       	get_pt1

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_pt1
	on EX_BACK_UP 	state   previous_state 


state   get_pt1

        msg_key        	GRC_M_DfnCnsPl3Pt 
	prompt_key 	GR_P_EntPt1
        filter 		get_event

        on EX_DATA	do get_dt_pt(FrstPt)
                        state get_pt2
state   get_pt2

        msg_key        	GRC_M_DfnCnsPl3Pt 
	prompt_key 	GR_P_EntPt2PosXax
        filter 		get_event

        on EX_DATA	do get_dt_pt(ScndPt)
                        state get_pt3
state   get_pt3

        msg_key        	GRC_M_DfnCnsPl3Pt 
	prompt_key 	GR_P_EntPt3PosYax
        filter 		get_event

        on EX_DATA	do get_dt_pt(ThrdPt)
                        state idnt_wnd1
state	idnt_wnd1

	prompt_key	GR_P_IdWin
	filter		get_event

  on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,OneWnd,ExstGG)
                               on SrchFlt state idnt_wnd1
                               on SUCCESS do idnt_wnd1
						  on ERROR  state terminate
                                               state idnt_wnd1
                                state idnt_wnd1

  on EX_RJT_MOVEON 		state get_pt1
