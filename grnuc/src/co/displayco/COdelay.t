options			"si" 
product_name		"$GRNUC"
class			COmiscl
command_string		GRMDlyOnOff,1,GRTgDl

start_state     delay_onoff

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state	delay_onoff

        msg_key	 	GRC_M_DlyOnOff
        prompt_key	GR_P_IdWin
	filter		get_event

  on EX_DATA or TEXT_VALUE   do  get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
			         on SrchFlt state delay_onoff
                                 on SUCCESS do delay_onoff
						    on ERROR state terminate
					         state delay_onoff
                            state delay_onoff

  on EX_RESTART 	state 	delay_onoff

  on EX_BACK_UP 	state   delay_onoff

  on EX_RJT_MOVEON 	state   delay_onoff
