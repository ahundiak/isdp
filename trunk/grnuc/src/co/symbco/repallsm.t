/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the transition file for the following command:
      Replace All Occurrences of a Symbol

History
   Gray Winn    04/07/88      Creation date.
   SCW          07/08/92      Added arguments to actions
\*/

command_string  GRMRepOccSym,0,GRRpSyGl
class           COreplace
start_state     start
product_name    "$PLATFORM"
options		"si"

state_table
#include "grmessage.h"
#include "msdef.h"
#include "grerr.h"

state start
  message_key  GRC_M_RepOccSym
  prompt_key   GR_P_KyCelRep
  filter       get_event
on EX_BACK_UP                                   state .
on EX_RESTART                                   state .
on EX_STRING   do locate_sd_in_asl_by_name(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_CelNotFnd  
                     state .
               state get_name

state get_name
  prompt_key   GR_P_KySymRep
  filter       get_event
on EX_BACK_UP                                   state -
on EX_RESTART                                   state start
on EX_STRING   do locate_sd_in_lsl_by_name(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_CelNotFnd
                     state .
               do highlight_sd(sts)
               do replace_prompt(sts)
               state replace

state replace
  prompt_key   GR_P_RepVer
  filter       get_event
on EX_RESTART                                   state start
on EX_STRING   do parse_y_or_n(sts)
                  on RETURN_CODE = "GR_E_INV_REQUEST"
                     do status_key  GR_E_PlsEntYN
                     state .
                  on RETURN_CODE = "MSFAIL"
                     do erase_highlight(sts)
                     do increment_inuse(sts)
                        on RETURN_CODE = "MSFAIL"
                           do status_key GR_I_Clear
                           state start
                     do highlight_sd(sts)
                     do replace_prompt(sts)
                     state .
               do erase_highlight(sts)
               do erase_sd(sts)
               do replace_sd(sts)
               do draw_sd(sts)
               do increment_inuse(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_I_Clear
                     state start
               do highlight_sd(sts)
               do replace_prompt(sts)
               state .
