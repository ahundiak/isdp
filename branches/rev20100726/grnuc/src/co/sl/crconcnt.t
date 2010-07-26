/*

Name
  crconcnt.t

Description
  State table for "Place Concentric Circles by Center and Diameter" command

Notes


 */

command_string  GRMPlcCcirCentRad,CO_ni_place_circle_by_center,GRPCnCrCnR
synonym         GRMPlcCcirCentRad,CO_ni_place_circle_by_center,EMPCnCrCnR
class           COnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "comisc.h"



state *
on   EX_RESTART                                   state start
on   EX_BACK_UP                                   state -
on   RETURN_CODE = GRw_no_value                   state .

at init
  do construct_class  "GR3dcircle"

at wakeup 
  do clear_channels
  do show_assoc_mode(1)

at sleep 
  do show_assoc_mode(0)


state start
   message_key      GRC_M_PlcCcirCentRad
   prompt_key       GR_P_EntCenPt
   filter           get_event

   on EX_BACK_UP                                  state .

   on DISTANCE <= 0.0
        do status_key  GR_E_CEnNPsDv              state .

   on DISTANCE
        do store_event_by_index( sts, 1 )         
	do diameter_to_radius( sts, 1 )           state first_event_is_value

   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_TO       or
      EX_DATA.GRst_TANGENT_TO
        do status_key   GR_E_InvDtTyp             state .

   on EX_DATA
        do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb             state have_first_event


state have_first_event
   prompt_key   GR_P_EntRadPtKyin
   dynamics     DYrbcircnt
   filter       get_event

   on DISTANCE <= 0
        do status_key  GR_E_CEnNPsDv              state .

   on DISTANCE
        do store_event_by_index( sts, 1 )
	do diameter_to_radius( sts, 1 )
        do construct_object
        do display_mode GRbd
        do display_constructed
	do convert_to_profile                    state have_first_event

   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp             state .


   on EX_DATA
        do store_event_by_index( sts, 1 )
        do construct_object
        do display_mode GRbd
        do display_constructed
	do convert_to_profile                   state have_first_event

   on EX_BACK_UP                                 state start



state first_event_is_value
   prompt_key    GR_P_EntCenPt
   filter        get_event


   on DISTANCE <= 0.0
        do status_key  GR_E_CEnNPsDv             state .

   on DISTANCE
        do store_event_by_index( sts, 1 )
	do diameter_to_radius( sts, 1 )          state .

   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_TO       or
      EX_DATA.GRst_TANGENT_TO
        do status_key   GR_E_InvDtTyp            state .

   on EX_DATA
        do store_event_by_index( sts, 0 )
        do get_construct_env_from_dpb     
        do construct_object
        do display_mode GRbd
        do display_constructed
	do convert_to_profile                    state have_first_event
