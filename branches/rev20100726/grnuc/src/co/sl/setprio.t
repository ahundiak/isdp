command_string  GRC_M_SetDsplPrio,0,GRSetPrio
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "gr.cmd"

state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"

state *
on EX_RESTART                                          state start
on EX_BACK_UP                                          state -

at init    do create_directory ( sts, "display_list" )


state start
   msg_key         GRC_M_SetDsplPrio
   prompt_key      GR_P_IdEleTop
   accept_key      GR_P_AccNxtMvOn
   relocate_key    GR_E_CouNoFndEle
   locate_class    "+GRvg, GRrg"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
   locate_owner         "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display       "ELEM_HILIGHT | ALL_WINDOWS"
   filter          locate
   on EX_DATA  or
      EX_STRING          
        do add_object_to_directory( sts, &me->located_chansel )
        do push_accept_event_on_queue
        do display_located                                  state .
   on  EX_BACK_UP                                           state .
