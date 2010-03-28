/*

Name
  crt3pts.t

Description
  State table for "Place Circle Tangent to 3 Elements" command

Notes


 */

command_string  GRMPlcCirTan3Els,CO_ni_place_circle_by_3pts,GRPCrTnT3E
synonym         GRMPlcCirTan3Els,CO_ni_place_circle_by_3pts,EMPCrTnT3E
class           COnpt
super_class     CEO_LOCATE
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"



state *
on  EX_RESTART  do erase_hilite
                do clear_channels                    state start
on  EX_BACK_UP  do erase_hilite                      state -


at wakeup
  do display_mode GRhhd
  do display_first_located_object
  do display_second_located_object
  do show_assoc_mode(1)
 

at sleep
  do display_mode GRbdhe
  do display_first_located_object
  do display_second_located_object
  do display_constructed
  do show_assoc_mode(0)



state start
  message_key    GRC_M_PlcCirTan3Els
  prompt_key     GR_P_Id1stEle
  accept_key     GR_P_AccAppPt1Ele
  relocate_key   GR_E_CouNoFnd1Ele
  locate_eligible      "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"


  locate_display       "PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
  filter               locate
  construct_class      "GR3dcircle"
  on EX_DATA
     do save_first_element
     do make_data_event_tangent_to
     do store_event_by_index( sts, 0 )
     do display_mode GRhhd
     do display_first_located_object
                                                  state have_first_element

state have_first_element
  prompt_key     GR_P_IdSecEle
  accept_key     GR_P_AccAppPt2Ele
  relocate_key   GR_E_CouNoFnd2Ele
  locate_eligible      "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display       "LC_ERASE_LOC_ELEMENT | PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
  disconnect_located 0
  filter      locate_noauto

  on EX_DATA
     do make_data_event_tangent_to
     do store_event_by_index( sts, 1 )
     do save_second_element
     do display_mode GRhhd
     do display_second_located_object
                                                     state have_second_element

state have_second_element
  prompt_key     GR_P_Id3rdEle
  accept_key     GR_P_AccAppPt3Ele
  relocate_key   GR_E_CouNoFnd3Ele
  locate_eligible      "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display       "LC_ERASE_LOC_ELEMENT | PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
  disconnect_located 0
  filter      locate

  on EX_DATA
     do make_data_event_tangent_to
     do store_event_by_index( sts, 2 )
     do display_mode GRbdhe
     do display_first_located_object
     do display_second_located_object
     do store_locate_context
     do display_located
     do clear_channels
     do get_construct_env_from_dpb
     do construct_object
     do display_mode GRbd
     do display_constructed
     do clear_channels    
     do convert_to_profile                        state start

  on EX_BACK_UP  do erase_hilite
     do display_mode GRhhd
     do display_first_located_object
                                                  state -
