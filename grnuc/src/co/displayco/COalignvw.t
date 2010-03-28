options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMAliVw,5,GRAlV

start_state       	get_param_win

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_param_win
	on EX_BACK_UP 	state   previous_state 


state get_param_win

    msg_key	GRC_M_AliVw
    prompt_key	GR_P_IdWinPar
    filter	get_event


    on EX_DATA or TEXT_VALUE do get_graphic_gadget(DstGGid,OneWnd,ExstGG)
			on SrchFlt state get_param_win
			on SUCCESS do wld_view 
		      		      on ERROR state get_param_win
		      		      on SUCCESS state get_align_win
				   state get_param_win
		   state get_param_win

state get_align_win

    prompt_key   GR_P_IdWinAli
    filter	get_event

    on EX_DATA or TEXT_VALUE do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
			 	on SrchFlt state get_align_win
				on SUCCESS do vw_view state get_align_win
      			     state get_align_win

    on EX_RJT_MOVEON    state get_param_win

