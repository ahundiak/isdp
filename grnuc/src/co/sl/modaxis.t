/*

Name
  modaxis.t

Description
  State table for "Change Axis of Conic Element" command

Notes

 */
command_string  GRMModAxOfConEle,CO_ni_modify_axis,GRCAxCn
class           COnpt
super_class     CEO_LOCATE
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "lcdef.h"

at wakeup
  do SSenter()
  do SSactivate()

at sleep
  do SSexit()

state *
on  EX_RESTART                                        state start
on  EX_BACK_UP                                        state -



state start
   message_key    GRC_M_ModAxOfConEle
   prompt_key     GR_P_IdEle
   accept_key     GR_P_AccEleAxPt
   relocate_key   GR_E_CouNoFndEle
   locate_eligible "+GRconic"
   locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY" 
   locate_owner   "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS" 
   locate_display   "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ALL_WINDOWS | LC_ERASE_ALL" 
   filter locate
   on EX_DATA         
        do store_event_by_index( sts, 0 )
        do store_locate_context                         state have_element


state have_element
   prompt_key  GR_P_EntNewAxPt
   dynamics    DYrbbadmodify
   filter      get_event
   on EX_DATA
        do store_event_by_index( sts, 1 )
	do erase_hilite
        do use_one_element
           on ERROR 
		do display_mode GRbd
                do display_located
                do status_key GR_E_ErrInCalc            state start
           on SUCCESS
		do display_mode GRhhd
                do display_located
                                                        state get_axis
                                                        state get_axis

   on EX_RJT_MOVEON                                     state start 



state get_axis
   prompt_key GR_P_IdAxisMod
   filter get_event

   on EX_DATA
	do store_event_by_index( sts, 0 )               state have_element

   on EX_RJT_MOVEON                                     state start
