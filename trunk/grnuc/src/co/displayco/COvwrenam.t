options			"si" 
product_name		"$GRNUC"
class			COviewmnpl
command_string		GRMRenmeSavVw,3,GRRnSvV

start_state		id_vw

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

at init do init_act

state *

	on EX_RESTART 	state 	id_vw
	on EX_BACK_UP 	state   previous_state 

state	id_vw

	msg_key		GRC_M_RenmeSavVw
	prompt_key      GR_P_KySavVwCurNme
	filter		get_event

        on NULL_TEXT_VALUE  state .

	on TEXT_VALUE   do id_vw 
			   on  SrchFlt state  id_vw
                        state rnm_vw
state	rnm_vw

	prompt_key      GR_P_KyNewNmeSavVw
	filter		get_event

        on NULL_TEXT_VALUE  state .

	on TEXT_VALUE  	do rnm_vw 
			 on SrchFlt state rnm_vw
                        state id_vw

	on EX_RJT_MOVEON	state id_vw
