/*

Name
  angb2el.t

Description
  State table for "Place Angular Bisector between 2 Elements" command

Notes


 */

command_string  GRMPlcAngBis2Ln,CO_ni_ang2bis,GRPAnBsBtE
synonym         GRMPlcAngBis2Ln,CO_ni_ang2bis,EMPAnBsBtE
class           COnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"

state *
on   EX_RESTART                                           state start

at init        
  do construct_class "GR3dlineseg"

at  wakeup 
  do show_assoc_mode(1)

at sleep 
  do show_assoc_mode(0)

state start
   message_key     GRC_M_PlcAngBis2Ln
   prompt_key      GR_P_Id1stEle
   accept_key      GR_P_AccPtOnEle
   relocate_key    GR_E_CouNoFndEle
   locate_class    "GRcurve"
   locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display       "SEGMENT_HILIGHT | ALL_WINDOWS"
   filter      locate
   on EX_DATA
        do store_event_by_index( sts, 0 )
        do save_first_element                         state have_first_element

state have_first_element
   prompt_key      GR_P_IdSecEle
   accept_key      GR_P_AccPtOnEle
   relocate_key    GR_E_CouNoFndEle
   locate_class    "GRcurve"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display       "LC_ERASE_LOC_ELEMENT | SEGMENT_HILIGHT | ALL_WINDOWS"
   disconnect_located 0
   filter      locate_noauto

   on EX_DATA
	do store_event_by_index( sts, 1 )
        do save_second_element                       state have_second_element

   on EX_BACK_UP
	do display_mode GRbdhe
	do display_first_located_object              state -

state have_second_element
   prompt_key      GR_P_IdEndLn
   filter          get_event
   on EX_DATA.GRst_ANGLE_TO          or
      EX_DATA.GRst_ANGLE_FROM        or
      EX_DATA.GRst_TANGENT_TO        or
      EX_DATA.GRst_TANGENT_FROM      or
      EX_DATA.GRst_PERPEND_TO        or
      EX_DATA.GRst_PERPEND_FROM
        do status_key  GR_E_InvDtTyp                   state -

   on EX_DATA
	do store_event_by_index( sts, 2 )
        do get_construct_env_from_dpb
        do locate_two_and_construct
	do erase_hilite
	do convert_to_profile
	do clear_channels                              state start

   on EX_BACK_UP
	do display_mode GRbdhe
	do display_second_located_object               state -
