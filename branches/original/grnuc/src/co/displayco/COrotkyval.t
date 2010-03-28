options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMRotVwPtKyVal,9,GRRtVAbPnK
synonym			GRMRv,9,GRRtVAbPnK

start_state       	get_angle1

state_table

#define     ANGLE1	0
#define     ANGLE2	1
#define	    ANGLE3	2
#define	    ID_VIEW     3

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_angle1
	on EX_BACK_UP 	state   previous_state 

state	get_angle1

        msg_key		GRC_M_RotVwPtKyVal
	prompt_key 	GR_P_Ky3AngIdWin
	filter		get_event

	on ANGLE 	do get_angles (ANGLE1) 
                        state get_angle2

state	get_angle2

	prompt_key	GR_P_Ky2AngIdWin
	filter		get_event

	on ANGLE 	do get_angles (ANGLE2) 
                        state get_angle3
state	get_angle3

	prompt_key      GR_P_KyAngIdWin
	filter		get_event

	on ANGLE 	do get_angles (ANGLE3)
                        state get_view

state  get_view

	prompt_key	GR_P_IdWin
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
                                     on SrchFlt  state get_view
                                     on SUCCESS do get_view
                                                   on FunFail  state terminate
					        state get_view
		                  state get_view

	on EX_RJT_MOVEON         state get_angle1

