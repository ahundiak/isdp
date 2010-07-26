command_string GRMRvRefFl,CO_revref,GRRvRfFl
class          COdetail
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_GSLOCATE
spec_path      "$grnuc/co/spec"
form           "GRRevRef",REVREF_FORM,0,"-1","-1"
start_state    start
options	       "siTC"

state_table

#include <grmessage.h>
#include "detailco.h"
#include <toolco.h>

state start

message_key GRC_M_RvRefFl        
status_key  GR_I_PrcRefFile

execute review_elements_exist ()

on MSSUCC                           state show_form
on MSFAIL   do status_key GR_E_NoRefFl
                                    state terminate

state show_form

execute display_form_by_label ( REVREF_FORM, sts )
execute review_set_gadgets ()
status ""

filter wfi

on FORM_FINISHED                    state terminate
