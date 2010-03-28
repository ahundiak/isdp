/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COgrid
command_string		GRMGrdOnOff,5,GRTgGrDs
start_state       	grd_onoff
		
		

/* OPP section */
/* Specification section .. code for .S file */

state_table

#include 	"grmessage.h"
#include 	"codpdef.h"


state *

	on EX_RESTART 	state 	grd_onoff
	on EX_BACK_UP 	state 	-


at  wakeup  do  wakeup_act


state	grd_onoff

	msg_key         GRC_M_GrdOnOff
	prompt_key	GR_P_IdWin
	filter		get_event

  on EX_DATA or TEXT_VALUE  	do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				   on SrchFlt   state grd_onoff
				   on SUCCESS do grd_onoff
						 on ERROR state terminate
                                                 state grd_onoff
                                state grd_onoff


  on EX_RJT_MOVEON		state grd_onoff
