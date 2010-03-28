/* Command definition section */

options			"si"
product_name		"$GRNUC"
class			COgrid
command_string          GRMFstFit,7,GRFsFtV
synonym                 GRMFit,6,GRFtV
start_state       	fit
		
		

/* OPP section */
/* Specification section .. code for .S file */

state_table

#include 	"grmessage.h"
#include 	"codpdef.h"
#include 	"dpdef.h"


state *

	on EX_RESTART     state fit
	on EX_BACKUP      state -

at  wakeup  do  wakeup_act


state	fit

        prompt_key	GR_P_IdWinMoveOn
	filter		get_event

	on EX_DATA or TEXT_VALUE  do get_sel_gragad(DstGGid,MAX_WINDOW,ExstGG,ALL_GG_CLASSES | GG_WIN_ON )
				     on SrchFlt state fit
                                     on SUCCESS do fit state fit 
				  state fit

	on EX_RJT_MOVEON	 do get_sel_all_gragad(ALL_GG_CLASSES | GG_WIN_ON )
				     on SUCCESS do fit state terminate
				 state fit
