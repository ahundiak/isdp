/*

Name
  arcchd.t

Description
  State table for "Place Arc Tangent to Element by Chord Definition" command

Notes


 */

command_string  GRMPlcArcTnTECD,CO_ni_place_arc_tan_chord,GRPATnTECD
synonym         GRMPlcArcTnTECD,CO_ni_place_arc_tan_chord,EMPATnTECD
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
on  EX_RESTART                                            state start
on  EX_BACK_UP                                            state -

at init
  do display_active_parms( sts, CO_ACTIVE_ANGLE | CO_CLOCKWISE )

at wakeup 
  do verify_active_angle( sts, 0 )
  do show_assoc_mode(1)

at sleep 
  do show_assoc_mode(0)

state start
    message_key    GRC_M_PlcArcTnTECD 
    prompt_key     GR_P_IdEle
    accept_key     GR_P_AccTPMvon
    relocate_key   GR_E_CouNoFndEle
    locate_eligible      "+GRlineseg,GRinfline,GRlinestr,GRplanar,GRconic,GRsubbc,GRcompcurve"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display       "PROJ_ACCEPT_POINT | SEGMENT_HILIGHT | ALL_WINDOWS"
    filter               locate
    construct_class      "GR3dcirarc"
on  EX_BACK_UP  do erase_hilite                    state .


on EX_DATA.GRst_PERPEND_FROM    or         
   EX_DATA.GRst_PERPEND_TO      or      
   EX_DATA.GRst_TANGENT_FROM    or       
   EX_DATA.GRst_TANGENT_TO      or       
   EX_DATA.GRst_ANGLE_FROM      or        
   EX_DATA.GRst_ANGLE_TO
       do status_key   GR_E_InvDtTyp               state .

on  EX_DATA
                do verify_active_angle( sts, 0 )
                   on ERROR                        state . 
                do store_event_by_index( sts, 1 )
                do save_first_element
                                                   state have_first_event
on  EX_RESTART  do erase_hilite                    state .


state have_first_event
   prompt_key    GR_P_EntLorECd
   dynamics      DYrbcirchd      
   filter        get_event

   on DISTANCE <= 0
        do status_key  GR_E_InvChdLn               state .

   on DISTANCE
        do verify_active_angle( sts, 0 )
           on ERROR                                 state . 
        do store_event_by_index( sts, 0 )        state have_second_event
 

   on EX_DATA.GRst_PERPEND_FROM    or         
      EX_DATA.GRst_PERPEND_TO      or      
      EX_DATA.GRst_TANGENT_FROM    or       
      EX_DATA.GRst_TANGENT_TO      or       
      EX_DATA.GRst_ANGLE_FROM      or        
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp               state .

   on EX_DATA
        do verify_active_angle( sts, 0 )
           on ERROR                                 state . 
        do store_event_by_index( sts, 0 )        state have_second_event




state have_second_event
   prompt_key    GR_P_EntAEorMvon
   dynamics      DYrbarcchd
   filter        get_event


   on EX_RJT_MOVEON
      do verify_active_angle( sts, 0 )
         on ERROR                                 state . 
      do store_event_by_index( sts, 2 )
      do set_default_event_by_index( sts, 2 )
      do display_mode GRbdhe
      do display_first_located_object
      do clear_channels
      do get_construct_env_from_dpb    
      do construct_object       
      do display_mode GRbd
      do display_constructed
      do convert_to_profile                      state start


   on EX_DATA.GRst_PERPEND_FROM    or         
      EX_DATA.GRst_PERPEND_TO      or      
      EX_DATA.GRst_TANGENT_FROM    or       
      EX_DATA.GRst_TANGENT_TO      or       
      EX_DATA.GRst_ANGLE_FROM      or        
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp               state .

   on EX_DATA
        do verify_active_angle( sts, 0 )
           on ERROR                                 state . 
        do store_event_by_index( sts, 2 )
        do display_mode GRbdhe
        do display_first_located_object
        do clear_channels
        do get_construct_env_from_dpb    
        do construct_object       
        do display_mode GRbd
        do display_constructed
	do convert_to_profile                       state start
