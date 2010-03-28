command_string GRMCrPlFrFl,PALCFL,GRCrPlFrFl
class          COpal
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_LOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
status_display "GRPalettes","-1","-1"
options        "siCT"

state_table
#include <grmessage.h>
#include <toolco.h>
#include "palco.h"

at wakeup
	do status_key GR_I_StsFrmLst
	do status_display_button(1)

at sleep
	do status_display_button(0)

state start
	message_key GRC_M_CrPlFrFl
	prompt_key GR_P_EntFil
	filter get_event
		on EX_STRING
			do COtools.assign(me->event1.event.keyin,
                                          me->name, CO_str_to_str)
			do COpal_func(CO_init_pal)
				on RETURN_CODE = MSSUCC
					do status_key GR_I_PlCr       
                		        state .
	     			on RETURN_CODE = MSFAIL
					do status_key GR_E_IlgFileTyp 
	                	        state .
                        state .
