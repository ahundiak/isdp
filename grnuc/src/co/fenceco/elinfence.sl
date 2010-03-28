/*\
Description
   This is the command class for the fence input tools which generate
   a select set and places it on the input queue.

   This transaction file support the following commands:

   elements inside fence,FC_INSIDE
   elements inside and overlapping fence,FC_INSIDE_OVERLAP
   elements outside fence,FC_OUTSIDE
   elements outside and overlapping fence,FC_OUTSIDE_OVERLAP
   elements overlapping fence,FC_OVERLAP

History
   Gray Winn    11/09/86    Creation date.
\*/

command_string GRMEleInFnc,FC_INSIDE,GRSlEInFn
synonym        GRMEleInOvlFnc,FC_INSIDE_OVERLAP,GRSlEInOvF
synonym        GRMEleOutFnc,FC_OUTSIDE,GRSlEOtFn
synonym        GRMEleOutOvlFnc,FC_OUTSIDE_OVERLAP,GRSlEOtOvF
synonym        GRMEleOvlFnc,FC_OVERLAP,GRSlEOvFn
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "grgsdef.h"
#include "msdef.h"

state start
on CMD_TYPE = FC_INSIDE
               do message_key  GRC_M_EleInFnc
                                                   state common_steps
on CMD_TYPE = FC_INSIDE_OVERLAP
               do message_key  GRC_M_EleInOvlFnc
                                                   state common_steps
on CMD_TYPE = FC_OUTSIDE
               do message_key  GRC_M_EleOutFnc
                                                   state common_steps
on CMD_TYPE = FC_OUTSIDE_OVERLAP
               do message_key  GRC_M_EleOutOvlFnc
                                                   state common_steps
on CMD_TYPE = FC_OVERLAP
               do message_key  GRC_M_EleOvlFnc
                                                   state common_steps

state common_steps
   status_key   GR_I_FncCntPrc
on ELSE         do construct_graphics_set
                do start_transition_for_graphics_set
                do build_locate_criteria
                do generate_right_prism_from_fence
                   on RETURN_CODE = "MSFAIL"
                        do status_key  GR_F_NoActFncDfn
                                                state terminate
                do generate_select_set_from_right_prism
                do end_transition_for_graphics_set
                do define_active_select_set_from_graphics_set_with_fence
                   on RETURN_CODE = "MSFAIL"
                        do status_key GR_E_EleNotFnd
                                                   state terminate
                do put_select_set_on_queue
                                                   state terminate

