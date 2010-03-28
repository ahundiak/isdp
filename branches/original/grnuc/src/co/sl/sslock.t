command_string  GRC_M_ToggleSSLock,0,GRTgSmSk
class           CEO_LOCATE
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"

state_table

#include "grmsg.h"

state start
   execute SSSmartSketchLock ( sts, 2 ) /* 2 is the toggle lock directive */
   execute SSSmartSketchLock ( sts, 3 ) /* 3 is the query  lock directive */
     on RETURN_CODE = 0
        do status_key GR_S_SSLockOff 
        state terminate
     on RETURN_CODE = 1
        do status_key GR_S_SSLockOn
        state terminate
     on ELSE
        do status_key GR_E_ErrEncCmdTrm
        state terminate

