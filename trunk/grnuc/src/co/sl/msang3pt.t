/*

Name
  msang3pt.t

Description
  State table for "Measure Angle by 3 Points" command

Notes


 */
command_string  GRMMsAng3Pts,CO_ni_measure_angle_by_3_pts,GRMAn3Pn 
class           COmeasure
spec_path       "$PLATFORM/co/spec"
status_display  "MeasAngle","-1","-1"
form            "AngReadout",READOUT_SPEC_FORM,0,335,105
start_state     start
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "coreadout.h"
#include "comisc.h"
#include "SSdef.h"


at init 
  do display_active_parms ( sts, CO_APPARENT  )

at wakeup
  do update_meas_form
  do SSenter()
  do SSactivate()
  do status_display_button(1)

at sleep
  do SSexit()
  do status_display_button(0)

state *
on   EX_RESTART 
                do clear_fields
                do is_form_displayed
                   on SUCCESS  do update_meas_form   state start
                state start

on   EX_BACK_UP
                do clear_fields
                do is_form_displayed
                   on SUCCESS  do update_meas_form   state start
                state start


state start
  message_key   GRC_M_MsAng3Pts
  prompt_key    GR_P_EntFirstPt
  filter        get_event
on  EX_DATA.GRst_ANGLE_TO      or
    EX_DATA.GRst_ANGLE_FROM    or
    EX_DATA.GRst_TANGENT_FROM  or
    EX_DATA.GRst_PERPEND_TO    or
    EX_DATA.GRst_PERPEND_FROM  
       do status_key  GR_E_InvDtTyp                     state .

on  EX_DATA    
       do store_event_by_index( sts, 0 )                             state have_first_event

state have_first_event
  prompt_key    GR_P_EntVertPt 
  dynamics      DYrblinear
  filter        get_event
on  EX_DATA.GRst_ANGLE_TO      or
    EX_DATA.GRst_ANGLE_FROM    or
    EX_DATA.GRst_TANGENT_FROM  or
    EX_DATA.GRst_PERPEND_TO    or
    EX_DATA.GRst_PERPEND_FROM  
       do status_key  GR_E_InvDtTyp                     state .

on  EX_DATA
       do store_event_by_index( sts, 1 )                            state have_second_event


state have_second_event
  prompt_key    GR_P_EntAxisPt 
  dynamics      DYrbmsang3pt
  filter        get_event
on  EX_DATA.GRst_ANGLE_TO      or
    EX_DATA.GRst_ANGLE_FROM    or
    EX_DATA.GRst_TANGENT_FROM  or
    EX_DATA.GRst_PERPEND_TO    or
    EX_DATA.GRst_PERPEND_FROM  
       do status_key  GR_E_InvDtTyp                      state .

on  EX_DATA     
       do store_event_by_index( sts, 2 )
       do measure            
	  on ERROR 
	     do status_key  GR_E_ErrInCalc               state start
       do calc_complement_angle
       do is_form_displayed
          on SUCCESS  do update_meas_form   state start
          on ERROR    do display_measurement  state start

                                                         state start

on  EX_BACK_UP                                           state -

