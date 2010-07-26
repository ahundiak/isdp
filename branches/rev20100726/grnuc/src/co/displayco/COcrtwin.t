/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string		GRMCrtWin,3,GRCrV
start_state       	verify_window
		
state_table

#include 	"grmessage.h"
#include        "codpdef.h"
#include        "dperr.h"

state *

	on EX_RESTART 	state 	verify_window
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act

state	verify_window
        message_key	GRC_M_CrtWin
	execute 	init_kyin
	filter		get_event

	on TEXT_VALUE 
			do verify_window_name(sts,0)
                           on SrchFlt state verify_window
			   on SUCCESS state get_type_view
                        state verify_window 
	
	on EX_RJT_MOVEON/* take default orientation */
			do verify_window_name(sts,1)
                           on SrchFlt state verify_window
			   on SUCCESS state get_type_view
                        state verify_window 

state	get_type_view

        message_key	GRC_M_CrtWin
       	prompt_key	GR_P_EntVwDPWinMvOn
	filter		get_event
        
	on TEXT_VALUE /* saved view or name of standard orientation */
			do get_type_view(sts,0) 
		           on DPINVINP state get_type_view
			   on SUCCESS 
			   	do crt_window
			   	   on SUCCESS state get_wndid
			   	state verify_window
			state verify_window

	on EX_DATA /* identify window to copy for orientaion */
			do crt_window
		           on SUCCESS 
			   	do copy_window
			   	state verify_window
 			state verify_window

	on EX_RJT_MOVEON /* take default orientation */
			do get_type_view(sts,1)
		           on DPINVINP state get_type_view
			   on SUCCESS 
			   	do crt_window
			   	state get_wndid
 			state verify_window

	on ELSE         state verify_window


state get_wndid

	on ELSE  	do get_wndid
			state verify_window
