command_string  GRMGnPolPts,0,GRGnPlArPn
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
status_display  "GRPolarDpt","-1","-1"
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "grmessage.h"
#include "comisc.h"

at init   do form_init( 2 )
          do display_active_parms ( sts, CO_STATUS_FORM )

at wakeup
  do status_display_button(1)

at sleep
  do status_display_button(0)


state *
on EX_RESTART                                             state start
on EX_BACK_UP                                              state -

state start
   message_key GRC_M_GnPolPts
   prompt_key  GR_P_EntNPtsSwp
   filter     get_event

   on SCALAR < 1.0
        do status_key GR_E_NumPtsLT1                       state .
   on SCALAR 
	do store_event_by_index( sts, 0 )                  state get_columns


state get_columns
   prompt_key  GR_P_EntNSwp
   filter     get_event
   on SCALAR.GRst_DEFAULT  or
      SCALAR = 1.0         or
      EX_RJT_MOVEON
	do set_default_event_by_index( sts,1 )
	do set_default_event_by_index( sts,2 )             state get_center_pt
   on SCALAR < 1.0
        do status_key GR_E_NumSwpLT1                       state .
   on SCALAR 
	do store_event_by_index( sts, 1 )                  state get_dist



state get_dist
   prompt_key  GR_P_EntDsSwp
   filter  get_event
   on DISTANCE  <= 0.0
        do status_key  GR_E_DsLT1                          state .
   on DISTANCE
        do store_event_by_index( sts, 2 )                  state get_center_pt

state get_center_pt
   prompt_key GR_P_EntCenPt
   filter     get_event
   on EX_DATA 
	do store_event_by_index( sts, 3 )                  state get_sweep_pt


state get_sweep_pt
   prompt_key  GR_P_EntPtOnSwp
   execute    DYlinear( sts, 3 )
   filter     get_event
   on EX_DATA 
	do store_event_by_index( sts, 4 )
        do gen_polar_pts
           on ERROR   
		do status_key  GR_E_ErrInCalc              state terminate
		                                           state terminate

