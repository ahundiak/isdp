/* Command definition section */

options         "si"
product_name    "$GRNUC"
spec_path       "$GRNUC/spec"
class           COdfls
super_class     CEO
command_string  GRC_M_DfLnStl,0,GRDfLnSt
form            "GRDefineLine",0,0,"-1","-1"
start_state	    strt_state


state_table

#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"


at wakeup  do form_init
at sleep  do COdfls_sleep


state   *
  on EX_RESTART   state   strt_state
  on EX_BACK_UP   state   -


state   strt_state
  msg_key       GRC_M_DfLnStl
  filter        wfi
  on EX_FORM_FINISHED   state terminate

