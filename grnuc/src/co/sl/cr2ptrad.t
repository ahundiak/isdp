/*

Name
  cr2ptrad.t

Description
  State table for "Place Circle by 2 Points and Diameter" command

Notes


 */
command_string  GRMPCr2PnDm,CO_ni_place_circle_by_2pts_radius,GRPCr2PnDm
synonym         GRMPCr2PnDm,CO_ni_place_circle_by_2pts_radius,EMPCr2PnDm

class           COnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "comisc.h"
#include "SSdef.h"


state *
on   EX_RESTART                                   state start
on   EX_BACK_UP                                   state -
on   RETURN_CODE = GRw_no_value                   state .

at init   
  do construct_class "GR3dcircle"

at wakeup 
  do clear_channels
  do show_assoc_mode(1)
  do SSenter()

at sleep 
  do show_assoc_mode(0)
  do SSexit()


state start
  execute SSactivate ()
  message_key     GRC_M_PCr2PnDm
  prompt_key      GR_P_EnDmVl
  filter          get_event

  on DISTANCE <= 0
     do status_key GR_E_CEnNPsDv               state .

  on DISTANCE
     do store_event_by_index( sts, 2 )
     do diameter_to_radius( sts, 2 )           state have_first_event


state have_first_event
  execute SSactivate ()
  prompt_key       GR_P_Ent1stEdgPt
  filter        get_event
  on EX_DATA.GRst_PERPEND_FROM or
     EX_DATA.GRst_ANGLE_FROM   or
     EX_DATA.GRst_TANGENT_FROM or
     EX_DATA.GRst_PERPEND_TO   or
     EX_DATA.GRst_ANGLE_TO
     do status_key  GR_E_InvDtTyp              state .

  on EX_DATA.GRst_TANGENT_TO
     do store_event_by_index( sts, 0 )
     do get_construct_env_from_dpb             state have_tan_second_event

  on EX_DATA
     do store_event_by_index( sts, 0 )
     do get_construct_env_from_dpb             state have_second_event

  on  EX_BACK_UP                                 state start

  on DISTANCE <= 0
     do status_key GR_E_CEnNPsDv               state .

  on DISTANCE
     do store_event_by_index( sts, 2 )
     do diameter_to_radius( sts, 2 )           state have_first_event



state have_second_event
  execute SSactivate ()
  prompt_key       GR_P_Ent2ndEdgPt
  dynamics      DYrbconstruct_line
  filter        get_event
  on EX_DATA.GRst_PERPEND_FROM or
     EX_DATA.GRst_ANGLE_FROM   or
     EX_DATA.GRst_TANGENT_FROM or
     EX_DATA.GRst_PERPEND_TO   or
     EX_DATA.GRst_ANGLE_TO
     do status_key  GR_E_InvDtTyp              state .

  on EX_DATA.GRst_TANGENT_TO
     do store_event_by_index( sts, 1 )
     do copy_event_by_index( sts, 3, 1 )
     do construct_object
     do display_mode GRbd
     do display_constructed
     do convert_to_profile                     state have_first_event

  on EX_DATA
     do store_event_by_index( sts, 1 )         state have_third_event

  on DISTANCE <= 0
     do status_key GR_E_CEnNPsDv               state .

  on DISTANCE
     do store_event_by_index( sts, 2 )
     do diameter_to_radius( sts, 2 )           state have_first_event



state have_tan_second_event
  execute SSactivate ()
  prompt_key       GR_P_Ent2ndEdgPt
  dynamics      DYrbconstruct_line
  filter        get_event
  on EX_DATA.GRst_PERPEND_FROM or
     EX_DATA.GRst_ANGLE_FROM   or
     EX_DATA.GRst_TANGENT_FROM or
     EX_DATA.GRst_PERPEND_TO   or
     EX_DATA.GRst_ANGLE_TO
     do status_key  GR_E_InvDtTyp              state .

  on EX_DATA
     do store_event_by_index( sts, 1 )
     do copy_event_by_index( sts, 3, 1 )
     do construct_object
     do display_mode GRbd
     do display_constructed
     do convert_to_profile                     state have_first_event

  on DISTANCE <= 0
     do status_key GR_E_CEnNPsDv               state .

  on DISTANCE
     do store_event_by_index( sts, 2 )
     do diameter_to_radius( sts, 2 )           state have_first_event


state have_third_event
  execute SSactivate ()
  prompt_key       GR_P_EntAppCentPt
  dynamics      DYrbcircle_by_2pts_radius
  filter        get_event
  on EX_DATA.GRst_PERPEND_FROM or
     EX_DATA.GRst_ANGLE_FROM   or
     EX_DATA.GRst_TANGENT_FROM or
     EX_DATA.GRst_PERPEND_TO   or
     EX_DATA.GRst_ANGLE_TO
     do status_key  GR_E_InvDtTyp              state .

  on EX_DATA
     do store_event_by_index( sts, 3 )
     do construct_object
     do display_mode GRbd
     do display_constructed
     do convert_to_profile                     state have_first_event

  on DISTANCE <= 0
     do status_key GR_E_CEnNPsDv               state .

  on DISTANCE
     do store_event_by_index( sts, 2 )
     do diameter_to_radius( sts, 2 )           state have_first_event

