/*

Name
  msdptpt.t

Description
  COB state transition file for the "Measure Distance between Points" command.

Notes

 */
command_string  GRMMsDistBtPts,CO_ni_measure_distance_btwn_2pts,GRMDsBtPn 
synonym         GRMMsDistBtPts,CO_ni_measure_distance_btwn_2pts,GRMDsBtPn2 
class            COmeasure
status_display  "MeasDist","-1","-1"
form            "LinReadout",READOUT_SPEC_FORM,0,520,105
spec_path        "$PLATFORM/co/spec"
start_state      start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "coreadout.h"
#include "comisc.h"

at init
  do display_active_parms(sts,CO_APPARENT)

at wakeup            
  do update_meas_form
  do SSenter()
  do SSactivate( )
  do status_display_button(1)

at sleep            
  do SSexit()
  do status_display_button(0)

state *
on EX_RESTART
     do clear_fields
     do is_form_displayed
        on SUCCESS  
	     do update_meas_form     
             do prompt_key    GR_P_EntBasePt  state start
                                     state start

on EX_BACK_UP
     do clear_fields
     do is_form_displayed
        on SUCCESS  
	     do update_meas_form   
             do prompt_key    GR_P_EntBasePt  state start
                                     state start


state start
   message_key   GRC_M_MsDistBtPts
   prompt_key    GR_P_EntBasePt
   filter        get_event
   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp               state .

   on EX_DATA
        do clear_fields
        do store_base_event       
        do display_point(sts,0)
	do prompt_key  GR_P_EntNextPt
        do update_cursor_fields
        do is_form_displayed
           on SUCCESS  do update_meas_form          
                                                    state have_base_event
                                                    state have_base_event


state have_base_event
   prompt_key    GR_P_EntNextPt
   filter        get_event

   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp               state .

   on EX_DATA   
        do store_current_event           
        do display_point(sts,1)
        do calc_delta_prev_current
        do measure
	do display_measurement(sts) 
        do display_line
	do prompt_key  GR_P_EntNextPt
        do is_form_displayed
           on SUCCESS  do update_meas_form     
                       do update_cursor_fields
                                                  state have_previous_point
           on ERROR    do prompt_key   GR_P_EntNextPt
                       do update_cursor_fields
                                                    state have_previous_point
                                                    state have_previous_point


state have_previous_point
   prompt_key    GR_P_EntNextPt
   filter        get_event

   on EX_DATA.GRst_PERPEND_FROM   or  
      EX_DATA.GRst_TANGENT_TO     or
      EX_DATA.GRst_TANGENT_FROM   or
      EX_DATA.GRst_PERPEND_TO     or
      EX_DATA.GRst_ANGLE_FROM     or 
      EX_DATA.GRst_ANGLE_TO
        do status_key   GR_E_InvDtTyp               state .

   on EX_DATA   
        do copy_event_by_index( sts, 0, 1 )
        do store_current_event           
        do display_point(sts,1)
        do calc_delta_base_current
        do calc_delta_prev_current
        do store_dis_base_current
        do measure
	do display_measurement(sts) 
        do display_line
	do prompt_key  GR_P_EntNextPt
        do is_form_displayed
           on SUCCESS
		do update_meas_form          
                do update_cursor_fields        
                                                     state .
           on ERROR
		do prompt_key  GR_P_EntNextPt
                do update_cursor_fields
                                                       state .
                                                       state .
   on EX_RJT_MOVEON                                       
        do clear_fields
        do is_form_displayed
           on SUCCESS
		do update_meas_form                    
                do prompt_key    GR_P_EntBasePt
                                                       state start
                                                       state start

