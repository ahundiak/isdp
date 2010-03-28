/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the transition file for following command:
      Replace All Occurrences of a Cell

History
   Gray Winn  04/07/88   Creation date.
   SCW        07/08/92   Added argument lists
\*/

command_string  GRMRepOccCel,0,GRRpClGl
class           COreplace
start_state     start
product_name    "$PLATFORM"

state_table
#include "grmessage.h"
#include "msdef.h"
#include "grerr.h"

state start
  message_key  GRC_M_RepOccCel
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
  prompt_key   GR_P_KyCelRpd
  filter       get_event
on EX_BACK_UP                                   state -
on EX_RESTART                                   state start
on EX_STRING   do locate_cells_by_name(sts)
               do get_cell_names(sts)
                  on RETURN_CODE = "MSFAIL"
                     do status_key GR_E_CelNotFnd
                     do empty_channel(sts)
                                                state .
               do erase_objects(sts)
               do replace_cells(sts)
               do draw_objects(sts)
               do empty_channel(sts)            state start
