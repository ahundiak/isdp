command_string  GRMRvAngRd,0,GRRvAnRdUn
class            COmeasure
form            "AngReadout",READOUT_SPEC_FORM,1,"-1","-1"
spec_path        "$PLATFORM/co/spec"
start_state      start
product_name    "$PLATFORM"
command_table   "3416.dpt"

state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "coreadout.h"

at init        do save_current_readout_spec
at wakeup      do update_readout_form
 
state start
  message_key    GR_P_RvAngRd  
  filter  get_event
  on DATA        do update_readout_form                   state .
