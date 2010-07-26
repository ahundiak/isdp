/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the transition file for the following command:
      Replace All Occurrences of All Symbols

History
   Gray Winn    04/07/88      Creation date.
\*/

command_string  GRMRepAllSym,0,GRRpAlSyGl
class           COreplace
start_state     start
product_name    "$PLATFORM"

state_table
#include "grmessage.h"
#include "msdef.h"
#include "grerr.h"

state start
  message_key  GRC_M_RepAllSym
  prompt_key   GR_P_RepAllSym
  filter       get_event
on EX_BACK_UP                                   state .
on EX_RESTART                                   state .
on EX_STRING   do parse_y_or_n(sts)
                  on RETURN_CODE = "MSFAIL"        
                                                state terminate
                  on RETURN_CODE = "GR_E_INV_REQUEST"
                     do status_key  GR_E_PlsEntYN  
                                                state .
               do get_asl_env(sts)
               do get_all_sd_in_asl(sts)
               do get_all_sd_in_lsl(sts)
               do erase_sd(sts)
               do replace_sd(sts)
               do draw_sd(sts)
               do empty_channel(sts)            state terminate
