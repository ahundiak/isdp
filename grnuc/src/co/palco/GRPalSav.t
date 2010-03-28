command_string GRMSvPlTFl,PALSAV,GRSvPlTFl
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

message_key GRC_M_SvPlTFl
prompt_key  GR_P_IdPl

execute  COpal_func(CO_palette_locate_on)
filter   get_event

on GR_UNKNOWN_TYPE.PALETTE_LOCATED                state get_name
on EX_RJT_MOVEON                                  state .

state get_name 

prompt_key  GR_P_EntFil

filter 	get_event

on EX_STRING    do COtools.assign ( me->event1.event.keyin,
                                    me->name,
                                    CO_str_to_str )
                do COpal_func(CO_sav_pal)
            on SUCCESS
                do status_key GR_P_PalSaved
                                                  state start
            on WARNING or ERROR or SEVERE
                do status_key GR_E_FlCantOpn
                                                  state .
                                                  state .

at sleep  do COpal_func(CO_palette_locate_off)
at delete do COpal_func(CO_palette_locate_off)


