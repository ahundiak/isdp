/*\
Description
   This is the command class for the file fence command.

History
   Gray Winn    06/30/88      Creation date.
\*/

command_string GRMFlFnc,FC_OUTSIDE_OVERLAP,GRCpFnE
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "grgsdef.h"
#include "msdef.h"
#include "execmsg.h"
#include "grerr.h"

state start
   message_key    GRC_M_FlFnc
on ELSE           do check_for_fence
                     on RETURN_CODE = "MSFAIL"
                        do status_key  GR_F_NoActFncDfn
                                                state terminate
                                                state checked_fence

state checked_fence
   prompt_key        GR_P_EntFlNme
   locate_class      "GRgraphics"
   locate_owner      "LC_GEOM_MOD | LC_REF_HEADER | LC_NO_REF_OBJECTS | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED | LC_HANDLES"
   locate_properties "IGN_LC_BIT | LC_WRITE_ONLY | IGN_DP_BIT"
   filter            get_event
on EX_STRING      do check_file_fence_name
                     on RETURN_CODE = "MSFAIL"
                                                state y_or_n
                                                state file_ok

state y_or_n
   prompt_key  GR_P_FlExOv
  filter       get_event
on EX_BACK_UP                                   state -
on EX_RESTART                                   state start
on EX_STRING   do parse_y_or_n
                  on RETURN_CODE = "MSFAIL"     
                                                state start
                  on RETURN_CODE = "GR_E_INV_REQUEST"
                     do status_key  GR_E_PlsEntYN
                                                state .
                                                state file_ok
                                                
state file_ok
on ELSE           do save_current_file_as_file_fence
                     on RETURN_CODE = "MSFAIL"
                        do status_key  GR_E_ErrFlCrt  state terminate

                  do status_key   GR_I_FncCntPrc
                  do construct_graphics_set
                  do start_transition_for_graphics_set
                  do generate_right_prism_from_fence
                  do set_locate_criteria_off
                  do set_all_layers
                  do generate_select_set_from_right_prism
                  do end_transition_for_graphics_set
                  do delete_graphics
                  do set_locate_criteria_on
                                                state deleted_outside

state deleted_outside
   locate_class      "GRgraphics"
   locate_owner      "LC_GEOM_MOD | LC_REF_HEADER | LC_NO_REF_OBJECTS | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED"
   locate_properties "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
on ELSE           do set_layers_off_in_fence_view
                  do set_locate_criteria_off
                  do construct_graphics_set
                  do start_transition_for_graphics_set
                  do generate_select_set_for_delete
                  do set_locate_criteria_on
                                                state deleted_graphics

/* deleting non-locatable cells */

state deleted_graphics
   locate_class      "GRclhdr"
   locate_owner      "LC_GEOM_MOD | LC_REF_HEADER | LC_NO_REF_OBJECTS"
   locate_properties "LC_WRITE_ONLY | LC_DP_ONLY"
on ELSE           do generate_select_set_for_delete
                  do end_transition_for_graphics_set
                  do delete_graphics
                  do close_file_fence
                  do status ""
                                                state terminate

