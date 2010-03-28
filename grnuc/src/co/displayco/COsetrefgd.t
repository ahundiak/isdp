/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COgrid
command_string		GRMSetDstBetwRefGrd,0,GRSDsMjGrD
start_state       	setrefx
		
		

/* OPP section */
/* Specification section .. code for .S file */

state_table

#include 	"grmessage.h"
#include 	"codpdef.h"

#define XUNITS 0
#define YUNITS 1
#define SET_REF 0
#define SET_GRID 1
#define DISPLAY_REF 2
#define DISPLAY_GRID 3

#define MstPosNum	666
#define MstInt		667

state *

	on EX_RESTART 	state 	setrefx
	on EX_BACK_UP 	state 	-

at  wakeup  do  wakeup_act

state   setrefx

	msg_key 	GRC_M_SetDstBetwRefGrd 
        prompt_key	GR_P_EntXDst
	scale_flag	GRIO_X_SCALE
    	filter		get_event

	on EX_RJT_MOVEON or DISTANCE  do setref(XUNITS)
				         on MstPosNum state setrefx
                                      state  setrefy

state   setrefy

	msg_key 	GRC_M_SetDstBetwRefGrd 
        prompt_key	GR_P_EntYDst
	scale_flag	GRIO_Y_SCALE
    	filter		get_event

	on EX_RJT_MOVEON or DISTANCE  do setref(YUNITS)
				         on MstPosNum state setrefy
				      state getgragad


state   getgragad

        prompt_key	GR_P_IdWin
    	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				      on SrchFlt   state getgragad
				      on SUCCESS do getgragad 
                                                 state getgragad
                                   state getgragad

	on EX_RJT_MOVEON	   state setrefx
 
