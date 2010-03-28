/*

Name
  msang2ptax.t

Description
  State table for "Measure Angle between 2 Points and Arbitrary Axis" command

Notes


 */
command_string  GRMMsAng2PtsAx,CO_ni_measure_angle_of_2_pts_and_axis,GRMAnBt2Pn
class           COmeasure
status_display  "MeasAngle","-1","-1"
spec_path       "$PLATFORM/co/spec"
form            "AngReadout",READOUT_SPEC_FORM,0,335,105
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "coreadout.h"
#include "comisc.h"
#include "SSdef.h"

at init do display_active_parms ( sts, CO_APPARENT  )

at wakeup
  do update_meas_form
  do SSenter()
  do SSactivate()
  do status_display_button(1)

at sleep 
  do SSexit()
  do status_display_button(0)

state *
on EX_BACK_UP
                do clear_fields
                do is_form_displayed
                   on SUCCESS  do update_meas_form         state -
                state -
on EX_RESTART
                do clear_fields
                do is_form_displayed
                   on SUCCESS  do update_meas_form         state start
                state start


state start
    message_key     GRC_M_MsAng2PtsAx         
    prompt_key      GR_P_EntFirstPt
    filter      get_event
on  EX_DATA     do store_event_by_index( sts, 0 )
                do store_event_by_index( sts, 1 )
                do store_event_by_index( sts, 2 )                       state have_point_1


state have_point_1
    prompt_key      GR_P_EntSecPt
    dynamics        DYrblinear
    filter      get_event
on  EX_DATA     do store_event_by_index( sts, 3 )                      state have_point_2

state have_point_2
    prompt_key      GR_P_Ent1stAxPt
    dynamics        DYfixbuflinear
    filter      get_event
on  EX_DATA     do store_event_by_index( sts, 0 )                       state have_axis_point


state have_axis_point
    prompt_key    GR_P_Ent2ndAxPt        
    dynamics      DYrbfixlinear
    filter      get_event
on  EX_DATA     do store_event_by_index( sts, 1 )
                do measure_two_elements 
		   on ERROR 
		     do status_key  GR_E_ErrInCalc           state start
                do calc_complement_angle
                do is_form_displayed
                   on SUCCESS  do update_meas_form   state start
                   on ERROR    do display_measurement  state start
                state start
on EX_BACK_UP
                do clear_fields
		do copy_event_by_index( sts, 1, 0 )
                do is_form_displayed
                   on SUCCESS  do update_meas_form         state -
                state -
