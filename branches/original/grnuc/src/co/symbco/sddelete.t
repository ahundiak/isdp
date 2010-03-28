/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the transition file for the following command:
      Delete Cell Definition for Cell Library

History
   Gray Winn    09/06/88      Rewrote using COB.
   SCW          07/08/92      Added arguments to actions
\*/

command_string  GRMDelCelLib,0,GRDlClDf
class           COreplace
start_state     start
product_name    "$PLATFORM"

state_table
#include "grmessage.h"
#include "msdef.h"
#include "grerr.h"

state start
  on ELSE
   do get_asl_env(sts)
      on RETURN_CODE = "MSFAIL"
         do error_box_key GR_F_NoActCelLibDfn
                                                state terminate
      on RETURN_CODE = "GR_I_SL_READ_ONLY"
         do error_box_key GR_F_FlRdOnly
                                                state terminate
                                                state get_cell_name

state get_cell_name
  message_key  GRC_M_DelCelLib
  prompt_key   GR_P_KyCelNme
  filter       get_event
on EX_BACK_UP                                   state .
on EX_RESTART                                   state .
on EX_STRING   do locate_sd_in_asl_by_name(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_CelNotFnd
                                                state .
               do delete_prompt(sts)
                                                state yes_or_no

state yes_or_no
  filter       get_event
on EX_RESTART                                   state start
on EX_BACK_UP                                   state -
on EX_STRING   do parse_y_or_n(sts)
                  on RETURN_CODE = "GR_E_INV_REQUEST"
                     do status_key  GR_E_PlsEntYN
                                                state .
                  on RETURN_CODE = "MSFAIL"
                                                state start
               do delete_symbol_definition(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key  GR_E_FailDelCel
                                                state start
                  on RETURN_CODE = "GR_I_INV_REQUEST"
                     do status_key  GR_E_CelOwnNoDel
                                                state start
               do delete_status(sts)
               do save_asl(sts)
                                                state start
