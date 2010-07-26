command_string  GRMRvLinRd,0,GRRvLnRdUn
class            COmeasure
form            "LinReadout",READOUT_SPEC_FORM,1,"-1","-1"
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
  message_key    GR_P_RvLinRd  
  filter         get_event
  on DATA        do update_readout_form                   state .



