options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMZmIn,6,GRZmInV
synonym			GRMZmOut,7,GRZmOtV
start_state       	strt_state

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

at init do init_act

state *

	on EX_RESTART 	state 	strt_state
	on EX_BACK_UP 	state   previous_state 


state   strt_state
   
	on CMD_TYPE  = 6     state   zoom_in
	on  CMD_TYPE = 7     state   zoom_out

state   zoom_in

	msg_key		GRC_M_ZmIn 
        prompt_key	GR_P_IdWinKyZmFc
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)  
				     on SrchFlt  state zoom_in
                                     on SUCCESS do zoom_inout
                                                on ERROR  state terminate
				             state zoom_in	
			          state zoom_in
	on SCALAR		 do zoom_factor state zoom_in

	on EX_RJT_MOVEON	 state zoom_in

state   zoom_out

	msg_key		GRC_M_ZmOut
        prompt_key	GR_P_IdWinKyZmFc
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)  
				     on SrchFlt  state zoom_out
                                     on SUCCESS do zoom_inout
                                                on ERROR  state terminate
				             state zoom_out	
			          state zoom_out

	on SCALAR		 do zoom_factor state zoom_out

	on EX_RJT_MOVEON	 state zoom_out
