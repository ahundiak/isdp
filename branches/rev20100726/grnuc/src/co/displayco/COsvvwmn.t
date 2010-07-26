options			"si" 
product_name	"$GRNUC"
class			COviewmnpl
command_string	GRMRecalSavVw,2,GRRtSvV
start_state		ky_vw

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

at init do init_act
at delete do my_delete

state *

	on EX_RESTART 	state 	ky_vw
	on EX_BACK_UP 	state   previous_state 


state	ky_vw

	msg_key     GRC_M_RecalSavVw
	prompt_key	GR_P_KySavVwNme
        execute     status_display_button(0)
	filter		get_event

    on NULL_TEXT_VALUE  state .

	on TEXT_VALUE  	do ky_vw
						on SrchFlt state ky_vw
                    state idn_wnd

state	idn_wnd

	msg_key     GRC_M_RecalSavVw
	prompt_key	GR_P_IdWin
        execute     status_display_button(0)
	filter		get_event

	on TEXT_VALUE or EX_DATA do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
                                 on SrchFlt state idn_wnd
                                 on SUCCESS do idn_wnd
					 				on SrchFlt state idn_wnd
								 state idn_wnd
                         	 state idn_wnd
	on EX_RJT_MOVEON   state  ky_vw

