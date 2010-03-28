/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the transition file for the following command:
      Replace Single Occurrence of Symbol or Cell

History
   Gray Winn    04/07/88      Creation date.
   SCW          07/08/92      Added arguments to actions
\*/

command_string  GRMRepSngOccSym,0,GRRpSyIn
class           COreplace
start_state     start
product_name    "$PLATFORM"

state_table
#include "grmessage.h"
#include "msdef.h"
#include "grerr.h"
#include "lcdef.h"

state start
  message_key  GRC_M_RepSngOccSym
  prompt_key   GR_P_KyCelRep
  filter       get_event
on EX_BACK_UP                                   state .
on EX_RESTART                                   state .
on EX_STRING   do locate_sd_in_asl_by_name(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_CelNotFnd  
                                                state .
                                                state get_element

state get_element
   prompt_key           GR_P_IdSymRep
   accept_key           GR_P_AccSymCel
   relocate_key         GR_E_EleNotFnd
   locate_class         "GRclhdr, GRsmhdr"
   locate_owner         "LC_GEOM_MOD"
   locate_properties    "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
   locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
   gslocate_num_inputs        1
   gslocate_spec_prompt1_key  GR_P_AccSymCel
   gslocate_spec_mask1        "GRm_RESTART | GRm_DATA"
   filter                     gs_locate
on EX_RESTART                                   state start
on EX_BACK_UP                                   state -
on EX_DATA or EX_OBJID
               do erase_highlight(sts)
               do get_cell_names(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_CelNotFnd
                     do empty_channel(sts)
                                                state .
               do erase_objects(sts)
               do replace_cells(sts)
               do draw_objects(sts)
               do empty_channel(sts)
               do put_event_on_queue(sts)
                                                state get_element
