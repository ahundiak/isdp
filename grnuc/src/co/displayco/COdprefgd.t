/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COgrid
command_string 		GRMDpDstBetwRefGrd,2,GRShDsMjGr
start_state       	getgragad
		
		

/* OPP section */
/* Specification section .. code for .S file */

state_table

#include 	"grmessage.h"
#include 	"codpdef.h"


state *

	on EX_RESTART 	state 	getgragad
	on EX_BACK_UP 	state 	-

at  wakeup  do  wakeup_act


state   getgragad

        prompt_key	GR_P_IdWin
    	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				      on SrchFlt   state getgragad
				      on SUCCESS do getgragad 
                                                 state getgragad
                                   state getgragad
 
	on EX_RJT_MOVEON	 state getgragad
