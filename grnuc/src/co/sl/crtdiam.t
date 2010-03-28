/*

Name
  crtdiam.t

Description
  State table for "Place Circle Tangent to 1 Element by Diameter" command

Notes


 */

command_string  GRMPlcCirTanEleDia,CO_ni_place_circle_by_diameter,GRPCTnT1ED
synonym         GRMPlcCirTanEleDia,CO_ni_place_circle_by_diameter,EMPCTnT1ED
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
on  EX_RESTART                                state start
on  EX_BACK_UP                                state -


at wakeup 
  do show_assoc_mode(1)

at sleep 
  do show_assoc_mode(0)


state start
   message_key    GRC_M_PlcCirTanEleDia
   prompt_key     GR_P_IdEle
   accept_key     GR_P_AccAppPtEle
   relocate_key   GR_E_CouNoFndEle
   locate_eligible      "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
   locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner      "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display       "PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
   filter               locate
   construct_class      "GR3dcircle"

   on  EX_BACK_UP         
       do erase_hilite                                       state .

   on  EX_DATA
       do save_first_element
       do make_data_event_tangent_to
       do store_event_by_index( sts, 0 )                     state have_element

   on  EX_RESTART  do erase_hilite                              state .


state have_element
    prompt_key       GR_P_Ent2ndDiamPt
    dynamics      DYrbcirdiam
    filter        get_event
on  EX_DATA
	do store_event_by_index( sts, 1 )
        do display_mode GRbdhe
        do display_first_located_object
        do clear_channels
        do get_construct_env_from_dpb
        do construct_object
        do display_mode GRbd
        do display_constructed
	do convert_to_profile                                   state start
