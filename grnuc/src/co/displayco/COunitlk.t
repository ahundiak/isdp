/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COgrid
command_string 		GRMUnitLockDef,10,GRSUnRnOf
synonym			GRMUnitLockOff,8,GRTrOfUnLc
synonym			GRMUnitLockOn,9,GRTrOnUnLc
synonym			GRMUr,10,GRSUnRnOf
start_state       	unitlk_state
		
		

/* OPP section */
/* Specification section .. code for .S file */

state_table

#include 	"grmessage.h"
#include 	"codpdef.h"

state *

	on EX_RESTART 	state 	unitlk_state
	on EX_BACK_UP 	state 	-


at  wakeup  do  wakeup_act


state	unitlk_state

	on CMD_TYPE = 8 or CMD_TYPE = 9 do set_unitlk
					   do unitlk_onoff state terminate

	on CMD_TYPE = 10  do set_unitlk state unitlk

state  unitlk

	prompt_key    	GR_P_InUnitRound
	scale_flag	GRIO_NO_SCALE
	filter 		get_event

        on DISTANCE.GRst_DEFAULT     state  .

	on DISTANCE 	do unitlk2     state terminate
  
    	on EX_RJT_MOVEON	state unitlk_state

