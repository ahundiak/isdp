options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMRotVwDfnAx,8,GRRtVAbAx

start_state       	get_ax_pt1

state_table

#define     dyn_in_vwrotn  4

#include 	"grmessage.h"
#include        "codpdef.h"

at init do init_act
at wakeup do dspl_bufrs 
at sleep  do erase_bufrs
at delete do erase_bufrs

state *

	on EX_RESTART 	state 	get_ax_pt1
	on EX_BACK_UP 	state   previous_state 

state	get_ax_pt1

        msg_key         GRC_M_RotVwDfnAx
	prompt_key  	GR_P_Ent1stAxPtOrgRot
	filter		get_event

	on EX_DATA  	do get_dt_pt(FrstPt)
                           on SUCCESS do get_ax_pt1 state get_ax_pt2
                        state terminate

state	get_ax_pt2

	prompt_key  	GR_P_Ent2ndAxPt
	dynamics        dyn_in_vwrotn 
	filter          get_event
	

        on EX_DATA	do get_dt_pt(ScndPt)
                           on SUCCESS do get_ax_pt2  
			               state get_angle
		        state terminate

state  get_angle

	prompt_key	GR_P_KyAngRot
	filter 		get_event

        on ANGLE.GRst_DEFAULT   state .

	on ANGLE       do get_angle 
                       state get_id_view

	on EX_RESTART  do erase_bufrs
                          do reset_flag
                       state get_ax_pt1

        on EX_BACK_UP  do erase_bufrs
                          do reset_flag
                       state  -

state  get_id_view

	prompt_key	GR_P_IdWin
	filter		get_event

 on EX_DATA or TEXT_VALUE   do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
			      on SrchFlt  state get_id_view
                              on SUCCESS do get_id_view
				           on ERROR or FunFail state get_ax_pt1
				         state get_id_view	
			    state get_id_view	

 on EX_RESTART or EX_RJT_MOVEON   	do erase_bufrs
                			state get_ax_pt1



