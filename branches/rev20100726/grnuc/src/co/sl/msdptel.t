/*

Name
  msdptel.t

Description
  State table for "Measure Distance between Point and Element" command.
  Command Key = GRMDsBtPnE

Notes


 */
command_string  GRMMsDistPtEle,CO_ni_measure_min_dist_point_to_element,GRMDsBtPnE 
class            COmeasure
status_display  "MeasDist","-1","-1"
form            "LinReadout",READOUT_SPEC_FORM,0,520,105
spec_path       "$PLATFORM/co/spec"
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
 do display_active_parms ( sts, CO_STATUS_FORM  )

at wakeup
  do update_meas_form
  do status_display_button(1)
  do SSenter()

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
   execute SSactivate( )
   message_key    GRC_M_MsDistPtEle
   prompt_key     GR_P_EntBasePt
   filter         get_event

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
        do is_form_displayed
           on SUCCESS  
	        do update_meas_form                 state have_base_event
                                                    state have_base_event

state have_base_event
   execute SSdeactivate( )
   prompt_key      GR_P_IdEle
   accept_key      GR_P_AccMvOn
   locate_mask     "GRm_TEXT_VALUE | GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
   relocate_key    GR_E_CouNoFndEle
   locate_eligible "+GRgraphics"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NON_GEOM_MOD | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display       "ELEM_HILIGHT | PROJ_ACCEPT_POINT | ALL_WINDOWS"
   filter locate 

on  TEXT_VALUE = "" or
    EX_DATA   
        do store_current_event                   
        do erase_hilite
        do measure_by_object
 	   on ERROR 
	      do status_key GR_E_ErrInCalc                    state start
        do calc_delta_prev_current 
        do display_line 
        do clear_channels
        do prompt_key GR_P_EntBasePt 
        do is_form_displayed 
           on ERROR    
              do update_cursor_fields                         state start 
        do update_meas_form                                   state start 
