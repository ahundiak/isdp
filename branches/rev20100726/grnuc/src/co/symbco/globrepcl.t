/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the transition file the following command:
      Replace All Occurrences of All Cells

History
   Gray Winn    04/07/88      Creation date.
\*/

command_string  GRMRepAllCel,0,GRRpAlClGl
class           COreplace
start_state     start
product_name    "$PLATFORM"

state_table
#include "grmessage.h"
#include "msdef.h"
#include "grerr.h"

state start
  message_key  GRC_M_RepAllCel
  prompt_key   GR_P_RepAllCel
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
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_CelNotFnd
                                                state .
               do get_all_cells_in_module(sts)
               do get_cell_names(sts)
                  on RETURN_CODE = "MSFAIL"
                     do empty_channel(sts)
                     do status_key GR_E_CelNotFnd
                                                state .
               do erase_objects(sts)
               do replace_cells(sts)
               do draw_objects(sts)             
               do empty_channel(sts)            state terminate
