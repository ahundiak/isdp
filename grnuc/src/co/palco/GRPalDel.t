command_string GRMDlPl,PALDEL,GRDlPl
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

message_key GRC_M_DlPl
prompt_key  GR_P_IdPl

execute  COpal_func(CO_palette_locate_on)
filter   get_event

on GR_UNKNOWN_TYPE.PALETTE_LOCATED   
        do COpal_func(CO_del_pal)
        do status_key GR_I_PlDl                   state .
on EX_RJT_MOVEON                                  state .

at sleep  do COpal_func(CO_palette_locate_off)
at delete do COpal_func(CO_palette_locate_off)


