/* Command definition section */

options         "si"
product_name    "$GRNUC"
spec_path       "$GRNUC/spec"
class           COactly
super_class     COlayer
command_string  GRC_M_SetActLayNmLayers,0,GRSALy
form            "GRLayers", GRLAYERS_FORM, 0,"-1","-1"
start_state	    strt_state


state_table

#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"
#include "lydef.h"

at wakeup  do form_init


state   *
  on EX_RESTART   state   strt_state
  on EX_BACK_UP   state   -


state   strt_state
  msg_key       GRC_M_SetActLayNmLayers
  filter        wfi
  on EX_FORM_FINISHED   state terminate

