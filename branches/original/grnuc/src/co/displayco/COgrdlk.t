/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COgrid
command_string 		GRMGrdLk,4,GRTgGrLc
start_state       	grd_lk
		
		

/* OPP section */
/* Specification section .. code for .S file */

state_table

#include 	"grmessage.h"
#include 	"codpdef.h"


state *

	on EX_RESTART 	state 	grd_lk
	on EX_BACK_UP 	state 	-

at  wakeup  do  wakeup_act

 
state	grd_lk

	msg_key         GRC_M_GrdLk
	prompt_key	GR_P_IdWin
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				     on SrchFlt state grd_lk
				     on SUCCESS do grd_lk
					        state grd_lk
                                  state grd_lk

	on  EX_RJT_MOVEON	  state grd_lk
