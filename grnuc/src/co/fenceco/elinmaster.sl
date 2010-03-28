/*\
Description
   This is the command class for the input tool which generates
   all the elements in the master file.

History
   Gray Winn    07/01/87       Creation date.
\*/

command_string  GRMEleCurFl,0,GRSlAlE
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "msdef.h"

state start
   message_key  GRC_M_EleCurFl
   status_key   GR_I_PrcEleCurFl
on ELSE        do clear_layers_flag
               do construct_graphics_set
               do start_transition_for_graphics_set
               do build_locate_criteria
               do generate_select_set_from_all_elements
               do end_transition_for_graphics_set
               do define_active_select_set_from_graphics_set
                   on RETURN_CODE = "MSFAIL"
                        do status_key GR_E_EleNotFnd
                                                   state terminate
               do put_select_set_on_queue
                                                   state terminate
