/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COwndmnpl
command_string          GRMUpdWin,15,GRUpV
start_state       	strt_state1
		

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state *

	on EX_RESTART 	state 	strt_state1
	on EX_BACK_UP 	state 	-


at wakeup do wakeup_act


state	strt_state1

	msg_key         GRC_M_UpdWin
        prompt_key	GR_P_IdWinMoveOn
	filter		get_event

	on EX_DATA or TEXT_VALUE do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
			            on SrchFlt state strt_state1
				    on SUCCESS do idntfywnd
                                                   state strt_state1
                                        state strt_state1

	on EX_RJT_MOVEON  	
				 do get_all_graphic_gadgets
				    on SUCCESS do idntfywnd
						   state terminate
					state  terminate

