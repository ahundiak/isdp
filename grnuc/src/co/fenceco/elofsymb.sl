/*\
Description
   This is the command class for the input tool which generates
   all the elements that have a specific symbology.

History
   Gray Winn    07/01/87       Creation date.
\*/

command_string  GRMEleSym,0,GRSlESy
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "msdef.h"

state *
on    EX_RESTART     do clear_weight_flag
                     do clear_color_flag
                     do clear_style_flag
                                                   state have_init

state start
on ELSE        do construct_graphics_set
               do start_transition_for_graphics_set
               do build_locate_criteria
               do clear_weight_flag
               do clear_color_flag
               do clear_style_flag
                                                   state have_init

state have_init
   message_key    GRC_M_EleSym
   prompt_key     GR_P_EntCo
   filter         get_event
on NULL_STRING or EX_RJT_MOVEON                    state have_color
on EX_STRING      do define_color_from_keyin
                     on RETURN_CODE = "MSFAIL"
                        do status_key  GR_E_InvCo
                           state .
                                                   state have_color

state have_color
   prompt_key  GR_P_EntSt
   filter      get_event
on EX_BACK_UP     do clear_color_flag              state -
on NULL_STRING or EX_RJT_MOVEON                    state have_style
on EX_STRING      do define_style_from_keyin
                     on RETURN_CODE = "MSFAIL"
                        do status_key   GR_E_InvSt
                           state .
                                                   state have_style

state have_style
   prompt_key  GR_P_EntWt
   filter      get_event
on EX_BACK_UP  do clear_style_flag                 state -
on NULL_STRING or EX_RJT_MOVEON                    state common_steps
on EX_STRING   do define_weight_from_keyin
                  on RETURN_CODE = "MSFAIL"
                     do status_key  GR_E_InvWt
                        state .
                                                   state common_steps
state common_steps
on ELSE        do status_key GR_I_PrcEleSym
               do generate_select_set_using_symbology
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_EntCoStWt
                                                   state have_init
               do end_transition_for_graphics_set
               do define_active_select_set_from_graphics_set
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_EleNotFnd
                                                   state terminate
               do put_select_set_on_queue
                                                   state terminate
