command_string  GRC_M_DsplByPrio,CO_ni_display_by_priority,GRDispPrio
class           COnpt
spec_path       "$PLATFORM/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "gr.cmd"

state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"


state start
    msg_key         GRC_M_DsplByPrio
    prompt_key      GR_P_IdWinDsplIn
    filter   get_event
    on EX_DATA  or
    TEXT_VALUE
      do store_event_by_index( sts, 0 )                 
      do use_events                                      state terminate

