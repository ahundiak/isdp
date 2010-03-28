/*

Name
  ptalong.t

Description

  State table for  "Point at Distance along Element" command.
  Command Key = GRSlPnDsAl

Notes


 */
command_string  GRMPtAlongEle,CO_ni_pt_along_element,GRSlPnDsAl
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
on EX_RESTART                                     state start
on EX_BACK_UP                                     state -
 
at wakeup
  do SSenter()

at sleep 
  do disconnect_channel( sts, &me->located_chansel )
  do SSexit()

state start
   message_key GRC_M_PtAlongEle  /* Point at distance along element */
   prompt_key  GR_P_EntDist
   filter  get_event

   on DISTANCE > 0 
	do store_event_by_index( sts, 1 )         state locate_element
   on DISTANCE <= 0                               state start


state locate_element
   execute SSactivate()
   prompt_key         GR_P_IdEle
   accept_key         GR_P_AccFrPt
   relocate_key       GR_E_CouNoFndEle
   locate_class       "GRcurve"
   locate_properties  "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner       "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display     "NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT | ALL_WINDOWS"
   filter   locate

   on EX_DATA
        do SSdeactivate()
	do display_mode GRhhd
	do store_event_by_index( sts, 2 )           state have_element


state have_element

   prompt_key     GR_P_EntDirPt
   filter         get_event

   on EX_DATA
	do store_event_by_index( sts, 3 )
        do erase_hilite
        do use_events
	do push_first_event_on_queue             state terminate


