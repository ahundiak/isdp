command_string GRMCrPl,PALCRE,GRCrPl
class          COpal
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_LOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
options        "siCT"

state_table

#include <OMerrordef.h>
#include <grmessage.h>
#include <toolco.h>
#include "palco.h"
#include "palgo.h"

at init do COtools.assign(0, &me->num_cmds, CO_cin_to_int)

state *
	on EX_RESTART
		state start

state start
	execute COtools.assign(0, &me->num_cmds, CO_cin_to_int)
	message_key GRC_M_CrPl
	prompt_key GR_P_PalNumRows
	filter get_event
		on SCALAR
			do COtools.inrange(sts, &me->event1.event.value,
                                           1, 15, CO_dbl_to_int)
			on MSSUCC
				do status " "
	                        do COtools.assign(&me->event1.event.value,
						  &me->rows, CO_dbl_to_int)
                                state get_cols
			on MSFAIL
				do status_key GR_E_InvNm
                                state .
                        state .

		on EX_BACK_UP
			state -

state get_cols
	prompt_key GR_P_PalNumCols
	filter get_event
		on SCALAR
			do COtools.inrange(sts, &me->event1.event.value,
                                           1, 15, CO_dbl_to_int)
			on MSSUCC      
                    		do status " "
                    		do COtools.assign(&me->event1.event.value,
                                                  &me->cols, CO_dbl_to_int)
                                do COpal_func(CO_create_pal)
            			on RETURN_CODE = MSSUCC
					state get_cmd
            			on RETURN_CODE = MSFAIL
                    			do status_key GR_E_ErrEncCmdTrm
                                        state terminate
                                state get_cmd
			on MSFAIL
				do status_key GR_E_InvNm
				state .
			state .
		on EX_BACK_UP
			state start
                    
state get_cmd
	prompt_key GR_P_SelKyCmd
	filter wfi
		on EX_STRING or EX_CMD_KEY or CMD_STRING
                	do COpal_func(CO_store_cmd)
			on MSSUCC
				do COpal_func(CO_add_cmd)
				on RETURN_CODE = MSSUCC
 					state .
				on RETURN_CODE = MSFAIL
					state start
				on RETURN_CODE = PAL_E_ABORT
					do status_key GR_I_PlDl
					do COtools.wait(40)
					do status (" ")
					state start
				state .
			on MSFAIL
				do status_key GR_I_NSymFCmd
				state get_button_name
                        on MSINARG
				state do_menu_bar
			state .
		on EX_BACK_UP
			do COpal_func(CO_pop_cmd)
			state start

state get_button_name
	prompt_key GR_P_EntLbl
	filter get_event
		on EX_STRING != ""
			do COtools.assign(me->event1.event.keyin,
                                          me->symbol_file, CO_str_to_str)
                        do COtools.assign(-1, &me->symbol, CO_cin_to_int)
                        do COpal_func(CO_add_cmd)
				on RETURN_CODE = MSSUCC
					state get_cmd
				on RETURN_CODE = MSFAIL
					state start
 				on RETURN_CODE = PAL_E_ABORT
					do status_key GR_I_PlDl
					do COtools.wait(40)
					do status (" ")
                                        	state start
				state get_cmd
		on EX_STRING = ""
			do COtools.assign(me->cmd, me->symbol_file, 
					  CO_str_to_str)   
			do COtools.assign(-1, &me->symbol, CO_cin_to_int)
			do COpal_func(CO_add_cmd)
                        	on RETURN_CODE = MSSUCC
					state get_cmd
                        	on RETURN_CODE = MSFAIL
					state start
                        	on RETURN_CODE = PAL_E_ABORT
                            		do status_key GR_I_PlDl
                            		do COtools.wait(40)
                            		do status (" ")
                                        	state start
                  		state get_cmd
		on EX_RJT_MOVEON
			state get_symbol_file
		on EX_BACK_UP
			state get_cmd

state get_symbol_file
	prompt_key GR_P_EntSymFl
	filter get_event
		on EX_STRING != ""
			do COtools.assign(me->event1.event.keyin,
                                          me->symbol_file, CO_str_to_str)
			state get_symbol
		on EX_STRING = "" or EX_RJT_MOVEON
			do COtools.assign(me->cmd, me->symbol_file,
                                          CO_str_to_str)   
			do COtools.assign(-1, &me->symbol, CO_cin_to_int)
			do COpal_func(CO_add_cmd)
                        	on RETURN_CODE = MSSUCC
					state get_cmd
	                        on RETURN_CODE = MSFAIL   
					state start
	                        on RETURN_CODE = PAL_E_ABORT
		                        do status_key GR_I_PlDl
					do COtools.wait(40)
					do status (" ")
					state start
                                state get_cmd
		on EX_BACK_UP
			state -

state get_symbol
	prompt_key GR_P_EntSymNm
	filter get_event
		on SCALAR
			do COtools.assign(&me->event1.event.value,
                                          &me->symbol, CO_dbl_to_int)
			do COpal_func(CO_add_cmd)
				on RETURN_CODE = MSSUCC
					state get_cmd
				on RETURN_CODE = MSFAIL
					state start
				on RETURN_CODE = PAL_E_ABORT
					do status_key GR_I_PlDl
					do COtools.wait(40)
					do status (" ")
					state start
				state get_cmd
		on EX_RJT_MOVEON
			state .
		on EX_BACK_UP
			state -

state do_menu_bar
	 on NO_INPUT_PENDING state get_cmd
	 filter get_event
	       on ELSE state get_cmd
