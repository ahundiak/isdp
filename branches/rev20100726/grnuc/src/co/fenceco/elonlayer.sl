/*\
Description
   This is the command class for the input tool which generates
   all the elements that on a specific layer.

History
   Gray Winn    06/25/87       Creation date.
\*/

command_string  GRMEleLy,0,GRSlEOnLy
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "msdef.h"

state *
on   RESET                                         state start

state start
  message_key  GRC_M_EleLy
  prompt_key   GR_P_EntLys
  filter       get_event
on  EX_STRING  do status_key GR_I_PrcEleLy
               do clear_layers_flag
               do construct_graphics_set
               do start_transition_for_graphics_set
               do build_locate_criteria
               do convert_keyin_to_layer_mask
               do generate_select_set_from_all_elements
               do end_transition_for_graphics_set
               do define_active_select_set_from_graphics_set
                   on RETURN_CODE = "MSFAIL"
                        do status_key GR_E_EleNotFnd
                                                   state terminate
               do put_select_set_on_queue
                                                   state terminate
