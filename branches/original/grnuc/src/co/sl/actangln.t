/*

Name
  actangln.t

Description
  State table for "Place Line at Active Angle" command

Notes


 */

command_string  GRMPlcLnActAng,CO_ni_place_line_at_active_angle,GRPL
synonym         GRMPlcLnActAng,CO_ni_place_line_at_active_angle,EMPL
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
on  EX_RJT_MOVEON                                    state .

at init   
  do display_active_parms(sts,CO_ACTIVE_ANGLE)

at  wakeup
  do clear_channels
  do show_assoc_mode(1)

at sleep 
  do show_assoc_mode(0)


state start
    message_key GRC_M_PlcLnActAng
    prompt_key  GR_P_EntPt1
    filter      get_event
    construct_class "GR3dlineseg"

on  EX_DATA.GRst_PERPEND_FROM or
    EX_DATA.GRst_ANGLE_FROM   or
    EX_DATA.GRst_TANGENT_FROM
		do status_key GR_E_FroPtNoAllow      state .

on  EX_DATA.GRst_PERPEND_TO   or
    EX_DATA.GRst_ANGLE_TO     or
    EX_DATA.GRst_TANGENT_TO
                do store_event_by_index( sts, 0 )
                do get_construct_env_from_dpb        state have_to_point

on  EX_DATA     do store_event_by_index( sts, 0 ) 
                do get_construct_env_from_dpb        state have_first_event


state have_first_event
 prompt_key    GR_P_EntPt2
 dynamics      DYrb_line_active_angle
 filter        get_event

on  EX_DATA.GRst_PERPEND_FROM or
    EX_DATA.GRst_ANGLE_FROM   or
    EX_DATA.GRst_TANGENT_FROM
		do status_key GR_E_FroPtNoAllow      state .

on  EX_DATA     do store_event_by_index( sts, 1 )
                do construct_object
		do display_mode GRbd
                do display_constructed
		do convert_to_profile                    state start


state have_to_point
 prompt_key    GR_P_EntPt2
 dynamics      DYrb_line_active_angle
 filter        get_event

on  EX_DATA.GRst_PERPEND_FROM  or
    EX_DATA.GRst_ANGLE_FROM    or
    EX_DATA.GRst_TANGENT_FROM  or
    EX_DATA.GRst_PERPEND_TO    or
    EX_DATA.GRst_ANGLE_TO      or
    EX_DATA.GRst_TANGENT_TO    
		do status_key GR_E_IllCmbSpPts       state .

on  EX_DATA     do store_event_by_index( sts, 1 )
                do construct_object
		do display_mode GRbd
                do display_constructed
		do convert_to_profile                    state start

