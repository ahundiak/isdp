options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMRotVwDfn3Pt,10,GRRtV3Pn

start_state       	get_origin

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_origin
	on EX_BACK_UP 	state   previous_state 

state	get_origin

        msg_key		GRC_M_RotVwDfn3Pt
	prompt_key	GR_P_EntPt1OrgRot
	filter		get_event

	on EX_DATA  	do get_dt_pt(FrstPt)
                        state get_x_pt

state	get_x_pt

 	prompt_key	GR_P_EntPt2PosXax
	filter		get_event

	on EX_DATA  	do get_dt_pt(ScndPt)
			state get_y_pt

state	get_y_pt

 	prompt_key	GR_P_EntPt3PosYax
	filter		get_event

	on EX_DATA  	do get_dt_pt(ThrdPt)
                        state get_id_view1
state	get_id_view1

	prompt_key	GR_P_IdWin
	filter 		get_event

 on EX_DATA or TEXT_VALUE  do get_graphic_gadget (DstGGid,MAX_WINDOW,ExstGG)
                              on SrchFlt state get_id_view1
                              on SUCCESS do get_id_view1
                                                 on FunFail state terminate
			        	 state get_id_view1
			   state get_id_view1

 on EX_RJT_MOVEON	state get_origin
