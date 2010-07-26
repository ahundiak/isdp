/*

Name
  lnmindis.t

Description
  State table for "Place Line at Minimum Distance between 2 Elements" command

Notes


 */

command_string  GRMPlcLnMinDis2Ele,CO_ni_line_at_minimum_distance,GRPLMnDsBt   
synonym         GRMPlcLnMinDis2Ele,CO_ni_line_at_minimum_distance,EMPLMnDsBt   
class           COnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"

state *
on  EX_RESTART                                       state start
on  EX_BACK_UP                                       state -

at init 
  do display_active_parms ( sts, CO_APPARENT | CO_ABSOLUTE )

at wakeup
  do display_mode GRhhd
  do display_first_located_object
  do show_assoc_mode(1)
                              
at sleep
  do display_mode GRbdhe
  do display_first_located_object
  do show_assoc_mode(0)

state start
   message_key           GRC_M_PlcLnMinDis2Ele
   construct_class       "GR3dlineseg"
   prompt_key            GR_P_Id1stEle
   accept_key            GR_P_AccAppPt1Ele
   relocate_key          GR_E_CouNoFnd1Ele
   locate_eligible    "!+GRlbsys,GRclrast,EMScompsurf"
   locate_properties  "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner       "LC_RIGID_COMP | LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display     "NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT | ALL_WINDOWS"
   filter   locate

on  EX_DATA
        do display_mode GRhhd                        
        do save_first_element
        do store_event_by_index( sts, 0 )
        do display_first_located_object 
                                                    state have_element
on  EX_BACK_UP                                      state .

state have_element
   prompt_key              GR_P_IdSecEle
   accept_key              GR_P_AccAppPt2Ele
   relocate_key            GR_E_CouNoFnd2Ele
   locate_eligible      "!+GRlbsys,GRclrast,EMScompsurf"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP | LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display       "LC_ERASE_LOC_ELEMENT | NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT | ALL_WINDOWS"

   disconnect_located 0 
   filter      locate_noauto 

on  EX_DATA
        do display_mode GRbdhe
        do save_second_element
        do store_event_by_index( sts, 1 )
        do display_first_located_object
        do display_second_located_object
        do get_construct_env_from_dpb
        do locate_two_and_construct
	do convert_to_profile
        do clear_channels
                                                         state start
on  EX_BACK_UP
        do display_mode GRbdhe
        do display_first_located_object
        do clear_channels 
                                                         state start
