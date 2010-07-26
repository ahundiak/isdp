/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string          GRMSetDpDep,8,GRSVDsDp
synonym                 GRMDp,8,GRSVDsDp
synonym			GRMSetVwVol,9,GRSVVl
start_state       	strt_state
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	strt_state
	on EX_BACK_UP 	state 	-


state  strt_state
/*
	filter	 	none
*/

        on CMD_TYPE = 8 do init_depths state pnt1depth
        on CMD_TYPE = 9 do init_vwvols state x1vwvol

at wakeup do wakeup_act



state	pnt1depth

	msg_key         GRC_M_SetDpDep
	prompt_key	GR_P_EntDpDep
	scale_flag	GRIO_Z_SCALE
	filter		get_event

	on EX_RJT_MOVEON or DISTANCE   	do pntdepths(FrstPt) 
                           		state pnt2depth

	on EX_DATA  	do storepnts(FrstPt) state  pnt2depth 

state	pnt2depth

	msg_key         GRC_M_SetDpDep
	prompt_key	GR_P_EntOthDpDep
	scale_flag	GRIO_Z_SCALE
	filter		get_event

	on EX_RJT_MOVEON or DISTANCE  	do pntdepths(ScndPt) 
                           		state idnt_wnd

	on EX_DATA  	do storepnts(ScndPt) state  idnt_wnd 

state	x1vwvol

	msg_key         GRC_M_SetVwVol
	prompt_key	GR_P_EntVwVol
	scale_flag	GRIO_NO_SCALE
	filter		get_event

	on DISTANCE or EX_RJT_MOVEON   	do vwvols(FrstPt) 
                           		state y1vwvol

	on EX_DATA  	 do storepnts(FrstPt) state  x2vwvol

state	y1vwvol

	msg_key         GRC_M_SetVwVol
	prompt_key	GR_P_KyVwVolYAll
	scale_flag	GRIO_NO_SCALE
	filter		get_event

	on DISTANCE or EX_RJT_MOVEON   	do vwvols(ScndPt) 
                           		state z1vwvol

state	z1vwvol

	msg_key         GRC_M_SetVwVol
	prompt_key	GR_P_KyVwVolZAll
	scale_flag	GRIO_NO_SCALE
	filter		get_event

	on DISTANCE or EX_RJT_MOVEON   	do vwvols(ThrdPt) 
                           		state x2vwvol

state	x2vwvol

	msg_key         GRC_M_SetVwVol
	prompt_key	GR_P_EntSecPt
	scale_flag	GRIO_NO_SCALE
	filter		get_event

	on DISTANCE or EX_RJT_MOVEON   	do vwvols(FrthPt) 
                           		state y2vwvol

	on EX_DATA  	 do storepnts(ScndPt) state  idnt_wnd

state	y2vwvol

	msg_key         GRC_M_SetVwVol
	prompt_key	GR_P_KyVwVolYZ
	scale_flag	GRIO_NO_SCALE
	filter		get_event

	on DISTANCE or EX_RJT_MOVEON   	do vwvols(FfthPt) 
                           		state z2vwvol
state	z2vwvol

	msg_key         GRC_M_SetVwVol
	prompt_key	GR_P_KyVwVolZ
	scale_flag	GRIO_NO_SCALE
	filter		get_event

	on DISTANCE or EX_RJT_MOVEON   	do vwvols(SxthPt) 
                           		state idnt_wnd

state   idnt_wnd

	prompt_key	GR_P_IdWin
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				     on SrchFlt  state idnt_wnd
				     on SUCCESS  do idnt_wnd
				                 state idnt_wnd
				  state idnt_wnd

     	on EX_RJT_MOVEON	  state strt_state
