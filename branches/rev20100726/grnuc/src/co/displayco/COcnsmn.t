options			"si" 
product_name		"$GRNUC"
class			COcnstrpl
command_string		GRMCnsPlOnOff,1,GRTgCnPl
synonym 		GRMCnsPlLkOnOff,1,GRTgCnPl
synonym 		GRMRotCnsPl,4,GRRtCnPl

start_state       	strt_state

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	strt_state
	on EX_BACK_UP 	state   previous_state 


state   strt_state

        on CMD_TYPE = 1      state      pln_onoff
        on CMD_TYPE = 4      state      rot_cnspl


state	pln_onoff

	msg_key        	GRC_M_CnsPlOnOff 
	prompt_key	GR_P_IdWin
	filter		get_event

 on EX_DATA or TEXT_VALUE 	do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
                                   on SrchFlt state pln_onoff
                                   on SUCCESS do pln_onoff
                                                 on ERROR state terminate
				              state pln_onoff
			        state pln_onoff

 on EX_RJT_MOVEON	state pln_onoff

state	rot_cnspl

	msg_key         GRC_M_RotCnsPl
	prompt_key	GR_P_IdWin
	filter		get_event

 on EX_DATA or EX_STRING  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG) 
                             on SrchFlt state rot_cnspl
			     on SUCCESS do rot_cnspl
				           on ERROR or FunFail state terminate
                                        state rot_cnspl
                          state rot_cnspl

on EX_RJT_MOVEON	  state rot_cnspl
