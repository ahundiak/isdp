command_string  GRMMsAngLn,CO_ni_measure_line_angle,GRMAnL 
class           COmeasure
status_display  "MeasAngle","-1","-1"
form            "AngReadout",READOUT_SPEC_FORM,0,335,105
spec_path       "$PLATFORM/co/spec"
start_state     start
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

at sleep
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
    message_key          GRC_M_MsAngLn
    prompt_key           GR_P_IdEle
    accept_key           GR_P_AccMvOn
    locate_mask       "GRm_TEXT_VALUE | GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
    relocate_key         GR_E_CouNoFndEle
    locate_eligible      "+GRinfline,GRlineseg,GRlinestr,GRplanar"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | 
                          LC_REF_OBJECTS"
    locate_display       "ELEM_HILIGHT | ALL_WINDOWS"
    filter              locate

on  EX_DATA             do store_event_by_index( sts, 0 )
                        do store_locate_context
                        do erase_hilite        
                        do measure_by_object    
			       on ERROR 
				  do status_key  GR_E_ErrInCalc  state start
                        do calc_complement_angle
                        do is_form_displayed
                               on SUCCESS do update_meas_form   state start
                               on ERROR   do display_measurement  state start
                        state start
