/*

Name
  nspymdpt.t

Description
  State table for "Place N-sided Polygon by Midpoint of Side" command

Notes


 */
command_string  GRMPlcNSPolyMpSide,CO_ni_place_npoly_by_vertex,GRPNsPlMdS
synonym         GRMPlcNSPolyMpSide,CO_ni_place_npoly_by_vertex,EMPNsPlMdS
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table    "3416.dpt"



state_table
#include "coniindex.h"
#include "grmessage.h"
#include "SSdef.h"


state *
on  EX_RESTART                                   state start
on  RETURN_CODE = GRw_no_value                   state .  

at  init   
  do construct_class "GRcompcurve"

at  wakeup       
  do clear_channels
  do show_assoc_mode(1)
  do SSenter()

at sleep
  do show_assoc_mode(0)
  do SSexit()


state start
  execute SSdeactivate ()
  execute SSSetNewElement( sts, SSNONE, 1 )
  message_key GRC_M_PlcNSPolyMpSide
  prompt_key  GR_P_EntNumSides
  filter      get_event
  on EX_BACK_UP                                  state .

  on SCALAR < 3  or
     SCALAR > 100
     do status_key   GR_E_NumSid3To100           state .

  on SCALAR 
     do store_event_by_index( sts, 0 )            
     do set_default_event_by_index( sts, 3)      state have_number_of_sides
        

state have_number_of_sides
  execute SSactivate ()
  prompt_key     GR_P_EntCenPt
  filter         get_event

  on SCALAR < 3  or
     SCALAR > 100
     do status_key GR_E_NumSid3To100             state .
  on SCALAR 
     do store_event_by_index( sts, 0 )             
     do set_default_event_by_index( sts, 3)      state .


  on EX_DATA.GRst_PERPEND_FROM   or  
     EX_DATA.GRst_TANGENT_TO     or
     EX_DATA.GRst_TANGENT_FROM   or
     EX_DATA.GRst_PERPEND_TO     or
     EX_DATA.GRst_ANGLE_FROM     or 
     EX_DATA.GRst_ANGLE_TO
     do status_key   GR_E_InvDtTyp               state .

  on EX_DATA
     do store_event_by_index( sts, 1 )
     do get_construct_env_from_dpb               state have_center_event

  on EX_BACK_UP                                  state start



state have_center_event
  execute SSactivate ()
  execute SSSetNewElement( sts, SSLINE, 1 )
  prompt_key     GR_P_EntSegMp
  dynamics    DYrbnpolygon
  filter      get_event

  on SCALAR < 3  or
     SCALAR > 100
     do status_key GR_E_NumSid3To100             state .
  on SCALAR 
     do store_event_by_index( sts, 0 )              
     do set_default_event_by_index( sts, 3)      state .


  on EX_DATA.GRst_PERPEND_FROM   or  
     EX_DATA.GRst_TANGENT_TO     or
     EX_DATA.GRst_TANGENT_FROM   or
     EX_DATA.GRst_PERPEND_TO     or
     EX_DATA.GRst_ANGLE_FROM     or 
     EX_DATA.GRst_ANGLE_TO
     do status_key   GR_E_InvDtTyp               state .

  on EX_DATA
     do store_event_by_index( sts, 2 )
     do construct_polygon
     do display_mode GRbd
     do display_constructed                      state have_number_of_sides

  on EX_BACK_UP                                  state have_number_of_sides


