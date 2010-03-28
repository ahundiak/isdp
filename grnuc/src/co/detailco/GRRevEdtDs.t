command_string GRMRvEdtDrwSht,CO_manageds,GRRvDrShSt
class          COdetail
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
form           "GRRvDrShSt",MAIN_FORM,1,"-1","-1"
form           "GREdDrStd",STANDARD_FORM,0,"-1","-1"
form           "GREdDrSht",SHEET_FORM,0,"-1","-1"
start_state    start
options	       "siTC"

state_table

#include <grmessage.h>
#include "detailco.h"
#include <toolco.h>

state start

message_key    GRC_M_RvEdtDrwSht

filter wfi

on FORM_FINISHED    state terminate

at init do set_defaults ()
at wakeup do set_gadgets ()

