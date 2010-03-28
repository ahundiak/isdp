/*

Name
  lnseg.t

Description
  State table for "Place Line Segment" command

Notes


 */
command_string  GRMPlcLnSeg,CO_ni_place_linear,GRPLSg
synonym         GRMPlcLnSeg,CO_ni_place_linear,EMPLSg
class           COnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "dp.h"
#include "comisc.h"
#include "SSdef.h"

state *
on EX_RJT_MOVEON                                       state start
on EX_RESTART                                          state start
on EX_BACK_UP                                          state -


at wakeup 
  do clear_channels
  do show_assoc_mode(1)
  do SSenter()
  do SSactivate()

at sleep 
  do show_assoc_mode(0)
  do SSexit()


state start
   execute SSSetNewElement (sts, SSNONE, 0)                          
   message_key   GRC_M_PlcLnSeg
   prompt_key    GR_P_EntFirstPt
   construct_class "GR3dlineseg"
   filter        get_event
   on EX_BACK_UP                                       state .

   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
         do store_event_by_index( sts, 0 )
         do get_construct_env_from_dpb                 state have_from_event

   on EX_DATA.GRst_PERPEND_TO or
      EX_DATA.GRst_ANGLE_TO   or
      EX_DATA.GRst_TANGENT_TO
         do store_event_by_index( sts, 0 )
         do get_construct_env_from_dpb                 state have_to_event
   on EX_DATA
         do store_event_by_index( sts, 0 )
         do get_construct_env_from_dpb                 state have_first_event


state have_from_event
   execute SSSetNewElement (sts, SSLINE, 0 )                         
   prompt_key    GR_P_EntNextPt
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                       state start

   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_TwoFroPtNoAll              state .

   on EX_DATA.GRst_PERPEND_TO   or
      EX_DATA.GRst_ANGLE_TO     or
      EX_DATA.GRst_TANGENT_TO
         do status_key GR_E_ToFroPtNoAll               state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do construct_object
           on ERROR                                    state .
        do display_mode  GRbd 
        do display_constructed
        do reload_last_point
	do convert_to_profile
        do disconnect_constructed
        do get_construct_env_from_dpb
        do store_event_by_index( sts, 0 )              state have_two_events


state have_to_event
   execute SSSetNewElement (sts, SSLINE, 0)                          
   prompt_key  GR_P_EntNextPt
   dynamics    DYrblinear
   filter      get_event
   on EX_BACK_UP                                       state start

   on EX_DATA.GRst_PERPEND_FROM or
      EX_DATA.GRst_ANGLE_FROM   or
      EX_DATA.GRst_TANGENT_FROM
         do status_key GR_E_ToFroPtNoAll               state .

   on EX_DATA    
        do store_event_by_index( sts, 1 )
        do construct_object
           on ERROR                                    state .
        do display_mode  GRbd 
        do display_constructed
        do reload_last_point
	do convert_to_profile
        do disconnect_constructed
        do get_construct_env_from_dpb
        do store_event_by_index( sts, 0 )              state have_two_events


state have_first_event
   execute SSSetNewElement (sts, SSLINE, 0)                          
   prompt_key       GR_P_EntNextPt
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                       state start

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do construct_object
           on ERROR                                    state .
        do display_mode  GRbd 
        do display_constructed
        do reload_last_point
	do convert_to_profile
        do disconnect_constructed
        do get_construct_env_from_dpb
        do store_event_by_index( sts, 0 )              state have_two_events


state have_two_events
   execute SSSetNewElement (sts, SSLINE, 0)                          
   prompt_key       GR_P_EntNextPt
   dynamics      DYrblinear
   filter        get_event
   on EX_BACK_UP                                       state start

   on EX_DATA.GRst_PERPEND_FROM  or
      EX_DATA.GRst_ANGLE_FROM    or
      EX_DATA.GRst_TANGENT_FROM
        do status_key GR_E_FroPtNoAllow               state .

   on EX_DATA
        do store_event_by_index( sts, 1 )
        do construct_object
            on ERROR                                    state .
        do display_mode  GRbd 
        do display_constructed
        do reload_last_point
	do convert_to_profile
        do disconnect_constructed
        do get_construct_env_from_dpb
        do store_event_by_index( sts, 0 )               state have_two_events

