/*\
Description
   This is the transition file for the group input tool which takes
   the current select set and places it on the event queue.  This
   implements the SELECT SET command.

History
   Gray Winn    11/09/86    Creation date.
   scw          07/10/92    stripped header
\*/

command_string  GRMCurSelSet,0,GRDfSlSt
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "msdef.h"

state start
   message_key  GRC_M_CurSelSet
   status_key   GR_I_PrcCurSelSet
on ELSE         do define_graphics_set_from_active_select_set
                   on RETURN_CODE = "MSFAIL"
                        do status_key  GR_F_NoActSelSetDfn
                                                   state terminate
                do build_locate_criteria
                do second_pass_criteria_check
                do put_select_set_on_queue
                                                   state terminate
