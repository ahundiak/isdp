command_string GRMRvRefFl,CO_revref,GRRRvRfFl
class          COdetail
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_GSLOCATE
spec_path      "$grnuc/co/spec"
form           "GRRevRef",REVREF_FORM,1,"-1","-1"
start_state    start
options	       "siTC"

state_table

#include <grmessage.h>
#include "detailco.h"
#include <toolco.h>

state start

message_key GRC_M_RvRefFl        

filter wfi

on FORM_FINISHED    state terminate
