/*

Name
  split.t

Description
  State table for  "Split Element" command.
  Command Key = GRSpE

Notes

 */
command_string  GRMSplitEle,CO_ni_split_element,GRSpE
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "lcdef.h"


state *
on  EX_RESTART                                 state start
on  EX_BACK_UP                                 state -


at wakeup
  do SSenter()
  do SSactivate()

at sleep
  do SSexit()

state start
   message_key         GRC_M_SplitEle
   prompt_key          GR_P_IdEle
   accept_key          GR_P_AccEleSplPt
   relocate_key        GR_E_CouNoFndEle
   locate_eligible     "+GRlineseg,GRlinestr,GRconic,GRplanar,GRsubbc,GRcompcurve"
   locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY" 
   locate_owner        "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS" 
   locate_display      "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ALL_WINDOWS | LC_ERASE_ALL" 
   filter locate

   on EX_BACK_UP                                            state .

   on EX_DATA         
        do store_event_by_index( sts, 0 )
        do store_locate_context
        do display_mode GRbehe
        do display_located
        do use_one_element                                  state start

