/*

Name
  arcrpt.t

Description
  State table for "Place Arc by Radius Point and Tangent Point" command

Notes


 */
command_string  GRMPlcArcRaTanPT,CO_ni_place_arc_rad,GRPArRPnTn
synonym         GRMPlcArcRaTanPT,CO_ni_place_arc_rad,EMPArRPnTn
class           COnpt
spec_path       "$PLATFORM/spec"
start_state     start
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"
#include "SSdef.h"

state *
on EX_RESTART                                      state start
on EX_BACK_UP                                      state .
on RETURN_CODE = GRw_no_value                      state .

at init 
  do construct_class "GR3dcirarc"
  do display_active_parms ( sts, CO_CLOCKWISE )

at wakeup 
  do clear_channels
  do show_assoc_mode(1)
  do SSenter()
  do SSactivate ()

at sleep 
  do show_assoc_mode(0)
  do SSexit()

state start
  message_key     GRC_M_PlcArcRaTanPT  
  prompt_key      GR_P_EntRadiusKyin
  filter          get_event

  on DISTANCE <= 0
     do status_key GR_E_RadValBePos               state .

  on DISTANCE
     do store_event_by_index( sts, 0 )            state have_first_event

  on  EX_BACK_UP                                    state .

state have_first_event
  prompt_key      GR_P_EntEndPtArc 
  filter          get_event
  on EX_DATA.GRst_ANGLE_TO        or
     EX_DATA.GRst_ANGLE_FROM      or
     EX_DATA.GRst_TANGENT_FROM    or
     EX_DATA.GRst_PERPEND_TO      or
     EX_DATA.GRst_PERPEND_FROM
     do status_key  GR_E_InvDtTyp                 state .

  on EX_DATA
     do store_event_by_index( sts, 1 )
     do store_event_by_index( sts, 2 )
                                                  state have_second_event 
  on EX_BACK_UP                                   state start

state have_second_event  
  prompt_key GR_P_IdEleTanArc
  accept_key GR_P_EntAppCentPt 
  relocate_key GR_E_CouNoFndEle
  locate_eligible "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
  locate_display "PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
  filter locate
  on EX_DATA
     do save_first_element
     do make_data_event_tangent_to
     do store_event_by_index( sts, 3 )
     do clear_channels
     do get_construct_env_from_dpb                         
     do construct_object
     do display_mode GRbd
     do display_constructed
     do erase_hilite
     do convert_to_profile                        state have_first_event

  on EX_RESTART           
     do erase_hilite                              state have_first_event

  on EX_BACK_UP
     do erase_hilite                              state -

