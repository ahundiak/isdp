/*

Name
  angbs3pt.t

Description
  State table for "Place Angular Bisector by 3 Points" command

Notes


 */

command_string  GRMPlcAngBis3Pt,CO_ni_place_angle_bisector_3pt,GRPAnBs3Pn   
synonym         GRMPlcAngBis3Pt,CO_ni_place_angle_bisector_3pt,EMPAnBs3Pn   
class           COnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"




state_table
#include "coniindex.h"
#include "grmessage.h"
#include "comisc.h"


state *
on  EX_RESTART                                       state start
on  EX_BACK_UP                                       state -

at  init   
  do construct_class "GR3dlineseg"

at  wakeup 
  do clear_channels
  do show_assoc_mode(1)

at sleep 
  do show_assoc_mode(0)

state start
   message_key GRC_M_PlcAngBis3Pt
   prompt_key  GR_P_EntPt1
   filter      get_event

   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM or
      EX_DATA.GRst_PERPEND_TO   or
      EX_DATA.GRst_ANGLE_TO     or
      EX_DATA.GRst_TANGENT_TO
        do status_key GR_E_SpcConPtNoAll                state .

   on EX_DATA
	do get_construct_env_from_dpb
	do store_event_by_index( sts, 0 )               state have_first_event

   on EX_BACK_UP                                        state .



state have_first_event
   prompt_key  GR_P_EntVertex
   dynamics    DYrblinear
   filter      get_event

   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM or
      EX_DATA.GRst_PERPEND_TO   or
      EX_DATA.GRst_ANGLE_TO     or
      EX_DATA.GRst_TANGENT_TO
        do status_key GR_E_SpcConPtNoAll                state .

   on EX_DATA
	do store_event_by_index( sts, 1 )               state have_second_event


state have_second_event
   prompt_key  GR_P_EntPt3
   dynamics    DYrbangbis3pt
   filter      get_event

   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM or
      EX_DATA.GRst_PERPEND_TO   or
      EX_DATA.GRst_ANGLE_TO     or
      EX_DATA.GRst_TANGENT_TO
        do status_key GR_E_SpcConPtNoAll                state .

   on EX_DATA
	do store_event_by_index( sts, 2 )
	do construct_object
	do display_mode GRbd
        do display_constructed
	do convert_to_profile                           state start

