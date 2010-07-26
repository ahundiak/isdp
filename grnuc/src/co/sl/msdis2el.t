/*

Name
  msdis2el.t

Description
  State table for "Measure Minimum Distance between 2 Elements" command

Notes


 */
command_string  GRMMsMinDist2Ele,CO_ni_measure_min_dis_2_ele,GRMMnDsBt2
class            COmeasure
status_display  "MeasDist","-1","-1"
form            "LinReadout",READOUT_SPEC_FORM,0,520,105
spec_path        "$PLATFORM/co/spec"
start_state      start
product_name    "$PLATFORM"
command_table   "3416.dpt"

state_table
#include "lcdef.h"
#include "coniindex.h"
#include "grmessage.h"
#include "coreadout.h"
#include "comisc.h"
 

state *

on EX_RESTART 
   do clear_fields
   do is_form_displayed
      on SUCCESS 
         do update_meas_form   
	 state start
   state start

at wakeup 
   do display_mode GRhhd
   do display_first_located_object
   do status_display_button(1)
   do update_meas_form

at sleep  
   do erase_hilite
   do status_display_button(0)

at init 
   do display_active_parms(sts,CO_ABSOLUTE|CO_APPARENT)


state start
  message_key GRC_M_MsMinDist2Ele
  prompt_key GR_P_Id1stEle
  accept_key GR_P_AccAppPt1Ele
  locate_mask "GRm_TEXT_VALUE | GRm_DATA"
  relocate_key GR_E_CouNoFndEle
  locate_eligible "!+GRlbsys,GRgrgrp,GRclrast,ACncpx"
  locate_properties  "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner "LC_RIGID_COMP    | 
                LC_FLEX_COMP     |
                LC_NO_REF_HEADER | 
                LC_REF_OBJECTS   | 
                LC_NON_GEOM_MOD"
  locate_display "ELEM_HILIGHT | ALL_WINDOWS"
  filter locate

  on EX_DATA   
     do clear_fields
     do store_event_by_index( sts, 0 )
     do store_locate_context
     do save_first_element
     do display_mode GRhhd
     do display_first_located_object
     do store_base_event       
     state have_first_elem

state have_first_elem
  prompt_key GR_P_IdSecEle
  accept_key GR_P_AccAppPt2Ele
  locate_mask "GRm_TEXT_VALUE | GRm_DATA"
  relocate_key GR_E_CouNoFndEle
  locate_eligible "!+GRlbsys,GRgrgrp,GRclrast,ACncpx"
  locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner "LC_RIGID_COMP    | 
                LC_FLEX_COMP     | 
                LC_NO_REF_HEADER |
                LC_REF_OBJECTS   | 
                LC_NON_GEOM_MOD"
  locate_display "LC_ERASE_LOC_ELEMENT | ELEM_HILIGHT | ALL_WINDOWS"
  disconnect_located 0
  filter      locate_noauto
  on EX_DATA   
     do store_current_event           
     do store_event_by_index( sts, 1 )
     do store_locate_context
     do save_second_element
     do measure_two_elements
        on ERROR 
           do clear_channels
           do status_key GR_E_ErrInCalc
	   state start
     do calc_delta_prev_current
     do display_line
     do prompt_key GR_P_Id1stEle
     do is_form_displayed
        on ERROR    
           do clear_channels
           do update_cursor_fields
	   state start
     do update_meas_form
     do clear_channels
     do erase_hilite
     state start

  on EX_BACK_UP
     do display_mode GRbdhe
     do display_first_located_object
     do clear_channels
     do clear_fields
     do is_form_displayed
        on SUCCESS
           do update_meas_form   
	   state -
     state -
