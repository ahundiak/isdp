/* Command definition section */

options         "si"
product_name    "$GRNUC"
spec_path       "$GRNUC/spec"
class           COedtsv
super_class     CEO
command_string  GRC_M_EdtSavVws,0,GRRvSvV
form            "GRSavedViews", 0, 0,"-1","-1"
start_state	    strt_state


state_table

#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"


at wakeup  do form_init


state   *
  on EX_RESTART   state   strt_state
  on EX_BACK_UP   state   -


state   strt_state
  msg_key       GRC_M_EdtSavVws
  filter        wfi
  on EX_FORM_FINISHED   state terminate

