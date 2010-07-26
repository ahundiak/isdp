/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COgrid
command_string 		GRMSetNumGrdPerRefGrd,1,GRSMnGrDvM
start_state             setgrdx
		
		

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

	on EX_RESTART 	state 	setgrdx
	on EX_BACK_UP 	state 	-


at  wakeup  do  wakeup_act


state   setgrdx

	msg_key 	GRC_M_SetNumGrdPerRefGrd 
        prompt_key	GR_P_EntNumXGrd
    	filter		get_event

	on EX_RJT_MOVEON or SCALAR do setgrd(XUNITS)
				         on MstInt    state setgrdx
				         on MstPosNum state setgrdx
				      state setgrdy

state   setgrdy

	msg_key 	GRC_M_SetNumGrdPerRefGrd 
        prompt_key	GR_P_EntNumYGrd
    	filter		get_event

        on EX_RJT_MOVEON or SCALAR do setgrd(YUNITS)
				         on MstInt    state setgrdy
				         on MstPosNum state setgrdy
				      state getgragad

state   getgragad

        prompt_key	GR_P_IdWin
    	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
				      on SrchFlt   state getgragad
				      on SUCCESS do getgragad 
                                                 state getgragad
                                   state getgragad
 
       on EX_RJT_MOVEON	   state setgrdx
