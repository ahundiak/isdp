options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMSetVwRot,4,GRSVRt
synonym			GRMVi,4,GRSVRt
start_state       	get_type_view

state_table

#include 	"grmessage.h"
#include 	"dperr.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	get_type_view
	on EX_BACK_UP 	state   previous_state 

state	get_type_view

        msg_key		GRC_M_SetVwRot 
	prompt_key	GR_P_KyVwTyp
	filter		get_event
        
	on TEXT_VALUE  	do get_type_view(sts,0) 
		           on DPINVINP state get_type_view
                        state get_wndid
	on EX_RJT_MOVEON /* take default orientation */
			do get_type_view(sts,1)
		           on DPINVINP state get_type_view
 			state get_wndid

state	get_wndid

	prompt_key	GR_P_IdWin
	filter		get_event

  on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
			       on SrchFlt state get_wndid
			       on SUCCESS do get_wndid
			           on DPINVINP state get_type_view
		   		   on ERROR state terminate
                        	state get_wndid
			    state get_wndid

  on  EX_RJT_MOVEON	    state  get_type_view


