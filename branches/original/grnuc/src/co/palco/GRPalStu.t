command_string "palette startup","PALSTU,512,1",GRPalStu
class          COpal
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_LOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
options        "siCT"

state_table

#include <toolco.h>
#include "palco.h"

state *

on EX_RESTART                                     state start


state start

    execute COpal_startup

    on ELSE                                       state terminate
