/*\
Description
   This is the command class for the input tool which generates
   all the elements that are inside or overlapping a specific view.

History
   Gray Winn    05/21/87       Creation date.
\*/

command_string  GRMEleVw,0,GRSlEInV
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
  message_key   GRC_M_EleVw
  prompt_key    GR_P_SelVw
  filter        get_event
on  EX_BACK_UP                                      state .
on  EX_DATA  or TEXT_VALUE
                do store_window_id
                   on RETURN_CODE = "MSFAIL"
                                                  state start
                do status_key GR_I_PrcEleVw
                do construct_graphics_set
                do start_transition_for_graphics_set
                do build_locate_criteria
                do generate_right_prism_from_view
                do generate_select_set_from_right_prism
                do end_transition_for_graphics_set
                do define_active_select_set_from_graphics_set
                   on RETURN_CODE = "MSFAIL"
                        do status_key GR_E_EleNotFnd
                                                   state terminate
                do put_select_set_on_queue
                                                   state terminate
