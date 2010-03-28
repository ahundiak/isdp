/*

Name
  msang2pt.t

Description
  State table for "Measure Angle by 2 Points" command

Notes


 */
command_string  GRMMsAng2Pts,CO_ni_measure_angle_by_2_pts,GRMAn2Pn
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

at init do display_active_parms ( sts, CO_STATUS_FORM  )

at wakeup       
  do update_meas_form
  do status_display_button(1)
  do SSenter()
  do SSactivate()

at sleep 
  do status_display_button(0)
  do SSexit()

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
  execute SSSetNewElement (sts, SSNONE, 0)                          
  message_key   GRC_M_MsAng2Pts
  prompt_key    GR_P_EntFirstPt
  filter        get_event
on  EX_DATA.GRst_ANGLE_TO     or
    EX_DATA.GRst_ANGLE_FROM   or
    EX_DATA.GRst_TANGENT_FROM or
    EX_DATA.GRst_PERPEND_TO   or
    EX_DATA.GRst_PERPEND_FROM  
        do status_key    GR_E_InvDtTyp                    state .

on  EX_DATA                  do store_event_by_index( sts, 0 )       
                                                          state have_first_event

state have_first_event
  prompt_key    GR_P_Ent2ndPt
  execute SSSetNewElement (sts, SSLINE, 0)                          
  dynamics      DYrblinear
  filter        get_event
on  EX_DATA.GRst_ANGLE_TO     or
    EX_DATA.GRst_ANGLE_FROM   or
    EX_DATA.GRst_TANGENT_FROM or
    EX_DATA.GRst_PERPEND_TO   or
    EX_DATA.GRst_PERPEND_FROM  
        do status_key    GR_E_InvDtTyp                          state .

on  EX_DATA                 do store_event_by_index( sts, 1 )    
                            do measure            
			       on ERROR 
				  do status_key  GR_E_ErrInCalc  state start
                            do calc_complement_angle
                            do is_form_displayed
                             on SUCCESS  do update_meas_form     state .
                             on ERROR    do display_measurement  state .
                            state .
