/*

Name
  lnsegt2.t

Description
  State table for "Place Line Segment Tangent to 2 Elements" command

Notes


 */

command_string  GRMPlcLnSegTan2Ele,CO_ni_place_linear,GRPLSgTnT2
synonym         GRMPlcLnSegTan2Ele,CO_ni_place_linear,EMPLSgTnT2
class           COnpt
super_class     CEO_LOCATE
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "lcdef.h"
#include "comisc.h"


state *
on  EX_RESTART                                       state start
on  EX_BACK_UP  do display_mode GRbdhe
                do display_first_located_object      state -



at wakeup
  do display_mode GRhhd
  do display_first_located_object
  do show_assoc_mode(1)

at sleep
  do display_mode GRbdhe
  do display_first_located_object
  do show_assoc_mode(0)


state start
    message_key      GRC_M_PlcLnSegTan2Ele
    prompt_key       GR_P_Id1stEle
    accept_key       GR_P_AccAppPt1Ele
    relocate_key     GR_E_CouNoFnd1Ele
    locate_eligible  "+GRsubbc,GRconic"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display       "PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
    filter               locate
    construct_class      "GR3dlineseg"
on  EX_BACK_UP                                       state .
on  EX_DATA
                do save_first_element
                do make_data_event_tangent_to
                do store_event_by_index( sts, 0 )
                do display_mode GRhhd
                do display_first_located_object      state have_first_element

state have_first_element
    prompt_key       GR_P_IdSecEle
    accept_key       GR_P_AccAppPt2Ele
    relocate_key     GR_E_CouNoFnd2Ele
    locate_eligible  "+GRsubbc,GRconic"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display       "LC_ERASE_LOC_ELEMENT | PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
    disconnect_located 0
    filter      locate_noauto
on  EX_RESTART
        do display_mode GRbdhe
        do display_first_located_object
        do clear_channels                            state start
on  EX_DATA
        do save_second_element
        do make_data_event_tangent_to
	do store_event_by_index( sts, 1 )
        do display_mode GRbdhe
        do display_first_located_object
        do display_second_located_object
        do clear_channels
        do get_construct_env_from_dpb
        do construct_object
           on ERROR                                  state start
	do display_constructed
	do convert_to_profile                        state start



