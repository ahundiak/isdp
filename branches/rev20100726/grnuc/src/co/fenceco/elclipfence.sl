/*\
Description
   This is the command class for the fence input tools which generate
   a select set that clips the elements to the fence volume.

   This transaction file support the following commands:

   elements clipped inside fence,FC_INSIDE_CLIP 
   elements clipped outside fence,FC_OUTSIDE_CLIP

History
   Gray Winn    11/09/86    Creation date.
\*/

command_string  GRMEleClpInFnc,FC_INSIDE_CLIP,GRSlEClInF
synonym         GRMEleClpOutFnc,FC_OUTSIDE_CLIP,GRSlEClOtF
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "grgsdef.h"
#include "msdef.h"

state start
on CMD_TYPE = FC_INSIDE_CLIP
               do message_key GRC_M_EleClpInFnc
                                                   state common_steps
on CMD_TYPE = FC_OUTSIDE_CLIP
               do message_key GRC_M_EleClpOutFnc
                                                   state common_steps

state common_steps
   status_key   GR_I_FncCntPrc
on ELSE         do construct_fence_set
                do start_transition_for_graphics_set
                do build_locate_criteria
                do generate_right_prism_from_fence
                   on RETURN_CODE = "MSFAIL"
                        do status_key  GR_F_NoActFncDfn
                                                   state terminate
                do store_right_prism_in_fence_set
                do connect_fence_to_fence_set
                do generate_select_set_from_right_prism
                do end_transition_for_graphics_set
                do define_active_select_set_from_graphics_set_with_fence
                   on RETURN_CODE = "MSFAIL"
                        do status_key GR_E_EleNotFnd
                                                   state terminate
                do put_select_set_on_queue
                                                   state terminate
