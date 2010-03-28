/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   This is the transition file for the following command:
      DROP SYMBOL SYMBOLOGY

History
   Gray Winn    09/27/88      Creation date.
   SCW          07/08/92      Added arguments to the actions
\*/

command_string  GRMDrpSymSymb,0,GRDrSySy
class           COreplace
start_state     start
product_name    "$PLATFORM"

state_table
#include "grmessage.h"
#include "msdef.h"
#include "grerr.h"
#include "lcdef.h"

state start
   message_key          GRC_M_DrpSymSymb
   prompt_key           GR_P_IdSym
   accept_key           GR_P_AccSym
   relocate_key         GR_E_EleNotFnd
   locate_eligible      "GRsmhdr"
   locate_owner         "LC_NON_GEOM_MOD"
   locate_properties    "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
   locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
   filter               gs_locate
on EX_RESTART                                   state start
on EX_DATA or EX_OBJID
               do erase_highlight(sts)
               do erase_objects(sts)
               do clear_symbol_symbology_properties(sts)
               do draw_objects(sts)
               do empty_channel(sts)
               do put_event_on_queue(sts)
                                                state start
