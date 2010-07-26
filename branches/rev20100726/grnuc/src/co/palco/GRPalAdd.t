command_string GRMAdCmTPl,PALADD,GRAdCmTPl
class          COpal
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_LOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
options        "siCT"

state_table

#include <grmessage.h>
#include <toolco.h>
#include "palco.h"

state *

on EX_RESTART                                     state start


state start

message_key GRC_M_AdCmTPl   
prompt_key  GR_P_SelKyCmd

filter    wfi

on EX_STRING or EX_CMD_KEY or CMD_STRING
                    do COpal_func(CO_store_cmd)
     on RETURN_CODE = MSSUCC                      state get_btn_pos
     on RETURN_CODE = MSFAIL      do status_key GR_I_NSymFCmd
                                                  state get_button_name
     on RETURN_CODE = MSINARG	
				state do_menu_bar

                                                  state .
state get_button_name

prompt_key  GR_P_EntLbl

filter    get_event

on EX_STRING != ""  do COtools.assign ( me->event1.event.keyin,
                                        me->symbol_file,
                                        CO_str_to_str )
                    do COtools.assign ( -1,
                                        &me->symbol,
                                        CO_cin_to_int )
                                                 state get_btn_pos
on EX_STRING = ""   do COtools.assign ( me->cmd,
                                        me->symbol_file,
                                        CO_str_to_str )
                    do COtools.assign ( -1,
                                        &me->symbol,
                                        CO_cin_to_int )
                                                  state get_btn_pos
on EX_RJT_MOVEON                                  state get_symbol_file
on EX_BACK_UP                                     state -

state get_symbol_file

prompt_key  GR_P_EntSymFl

filter    get_event

on EX_STRING != ""  do COtools.assign ( me->event1.event.keyin,
                                        me->symbol_file,
                                        CO_str_to_str )
                                                  state get_symbol
on EX_STRING = "" or EX_RJT_MOVEON
                    do COtools.assign ( me->cmd,
                                        me->symbol_file,
                                        CO_str_to_str )
                    do COtools.assign ( -1,
                                        &me->symbol,
                                        CO_cin_to_int )
                                                  state get_btn_pos
on EX_BACK_UP                                     state -

state get_symbol

prompt_key  GR_P_EntSymNm

filter    get_event

on SCALAR      do COtools.assign ( &me->event1.event.value,
                                   &me->symbol,
                                   CO_dbl_to_int )
                                                  state get_btn_pos
on EX_RJT_MOVEON                                  state .

on EX_BACK_UP                                     state -

state get_btn_pos

prompt_key  GR_P_IdPos

execute  COpal_func(CO_palette_locate_on)
filter   get_event

on GR_UNKNOWN_TYPE.PALETTE_LOCATED
                do COpal_func(CO_add_cmd)
                    on RETURN_CODE = MSSUCC  do status_key GR_I_CmdAd
                                                  state start
                    on RETURN_CODE = MSFAIL  do status_key GR_E_SymNFd
                                                  state start
                                                  state .
on EX_BACK_UP   do COpal_func(CO_palette_locate_off)
                                                  state get_button_name

on EX_RJT_MOVEON                                  state .

state do_menu_bar
	 on NO_INPUT_PENDING state start
	 filter get_event
	       on ELSE state start

at sleep  do COpal_func(CO_palette_locate_off)
at delete do COpal_func(CO_palette_locate_off)


