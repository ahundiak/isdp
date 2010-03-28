/*\
Description
   This is the command class for the file fence command.

History
   WBC          03/30/89      Creation date.
\*/

command_string  GRMSvEl,0,GRSvEl
class           COsaveelem
spec_path       "$grnuc/co/spec"
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"
options         "siTC"

state_table
#include "grmessage.h"
#include "grgsdef.h"
#include "msdef.h"
#include "execmsg.h"
#include "grerr.h"

at wakeup do status_display_button(1)

state start
   message_key         GRC_M_SvEl
   prompt_key          GR_P_IdEle
   accept_key          GR_P_Acc
   gslocate_spec_prompt1_key GR_P_Acc
   relocate_key        GR_E_EleNotFnd
   gslocate_num_inputs 1
   locate_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
   accept_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
   gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
   locate_eligible     "+GRgraphics"
   locate_owner        "LC_GEOM_MOD | LC_REF_HEADER | LC_NO_REF_OBJECTS | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED | LC_HANDLES"
   locate_properties   "IGN_LC_BIT | IGN_RW_BIT | IGN_DP_BIT"
   filter              gs_locate

on EX_DATA or EX_OBJID or EX_STRING    do clear_highlight
                                       do store_event ()
                                                state get_filename

state get_filename
   prompt_key        GR_P_EntFlNme
   filter            get_event

on EX_STRING      do check_file_fence_name
                     on RETURN_CODE = "MSFAIL"
                                                state y_or_n
                                                state file_ok

on EX_BACK_UP or EX_RESTART                     state start

state y_or_n
   prompt_key   GR_P_FlExOv
   filter       get_event

on EX_BACK_UP                                   state -

on EX_RESTART                                   state start

on EX_STRING   do parse_y_or_n
                  on RETURN_CODE = "MSFAIL"     
                                                state -
                  on RETURN_CODE = "GR_E_INV_REQUEST"
                     do status_key  GR_E_PlsEntYN  
                                                state .
                                                state file_ok
                                                
state file_ok

on ELSE           do delete_graphics_set_flag (0)
                  do save_current_file_as_file_fence
                    on RETURN_CODE = "MSFAIL"
                      do delete_graphics_set_flag (1)
                      do status_key GR_E_ErrFlCrt       state start
                                                        state saved_file

state saved_file

on ELSE           do delete_graphics_set_flag (1)
                  do get_select_set ()
                  do set_locate_criteria_off
                  do set_all_layers
                  do construct_graphics_set
                  do start_transition_for_graphics_set
                  do build_locate_criteria
                  do generate_select_set_from_all_elements
                  do end_transition_for_graphics_set
                  do define_active_select_set_from_graphics_set
                      on RETURN_CODE = "MSFAIL"
                           do status_key GR_E_EleNotFnd  state terminate

                  do put_select_set_on_queue             state elements_in_file

state elements_in_file
   filter         get_event

on EX_OBJID           do delete_no_connect ()
                      do set_locate_criteria_on
                      do clear_layers_flag
                      do close_file_fence
                      do status ""
                      do put_queue ()                       state start

on ELSE               do status_key GR_F_NoActSelSetDfn     state .
