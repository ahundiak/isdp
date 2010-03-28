/*

Name
  msptproj.t

Description
  State table for  "Measure Distance to Projection" command.
  Command Key = GRMsPtProj


Notes


 */
command_string  GRMMsDistProj,CO_ni_measure_distance_to_projection,GRMsPtProj
class           COmeasure
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"

at sleep 
  do erase_hilite
  do SSexit()

at wakeup
  do display_mode GRhhd
  do display_first_located_object
  do SSenter()
  do SSactivate()
 
state *
on  EX_RESTART                                              state start
on  EX_BACK_UP                                              state start

state start
    message_key        GRC_M_MsDistProj
    prompt_key         GR_P_IdEle
    accept_key         GR_P_AccFrPt
    locate_mask        "GRm_TEXT_VALUE | GRm_DATA"
    relocate_key       GR_E_CouNoFndEle
    locate_eligible    "+GRvg"
    locate_properties  "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner       "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display     "NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT | ALL_WINDOWS"
    filter      locate

on  EX_DATA         
                do cvt_pt_to_act_coord_sys
                do store_event_by_index( sts, 0 )
		do save_first_element
                do display_mode GRhhd
                do display_first_located_object
                do store_locate_context
                do measure_by_object
 	           on ERROR 
		      do status_key GR_E_ErrInCalc          state start
                do display_measurement                      state have_element


state have_element
   prompt_key   GR_P_EntFrPt
   filter       get_event
on EX_DATA
                do store_event_by_index( sts, 0 )
                do measure_by_object
 	           on ERROR 
		      do status_key GR_E_ErrInCalc          state start
                do display_measurement                      state .

