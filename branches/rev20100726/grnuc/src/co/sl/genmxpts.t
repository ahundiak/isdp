command_string  GRMGnMtxPts,0,GRGnMtPn
class           COnpt
spec_path       "$PLATFORM/co/spec"
start_state     start
status_display  "GRMtrxDpt","-1","-1"
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "grmessage.h"
#include "comisc.h"

at init   do form_init( 1 )
          do display_active_parms ( sts, CO_STATUS_FORM )

at wakeup
  do status_display_button(1)

at sleep
  do status_display_button(0)

state *
on EX_RESTART                                              state start
on EX_BACK_UP                                              state -


state start
   message_key GRC_M_GnMtxPts
   prompt_key  GR_P_EntPtsAlX
   filter      get_event

   on SCALAR.GRst_DEFAULT  or
      SCALAR = 1.0         or
      EX_RJT_MOVEON
	do set_default_event_by_index( sts,0 )
	do set_default_event_by_index( sts,1 )             state get_nbr_Y
   on SCALAR <= 0.0
        do status_key GR_E_NumMstGT0                       state .
   on SCALAR 
        do store_event_by_index( sts, 0 )                  state get_X_delta


state get_X_delta
   prompt_key  GR_P_EntDsBtwX
   filter      get_event
   on DISTANCE.GRst_DEFAULT                                state .
   on DISTANCE do store_event_by_index( sts, 1 )           state get_nbr_Y


state get_nbr_Y
   prompt_key  GR_P_EntPtsAlY
   filter      get_event
   on SCALAR.GRst_DEFAULT  or
      SCALAR = 1.0         or
      EX_RJT_MOVEON
	do set_default_event_by_index( sts,2 )
	do set_default_event_by_index( sts,3 )             state get_start_pt
   on SCALAR <= 0.0
      do status_key GR_E_NumMstGT0                         state .
   on SCALAR do store_event_by_index( sts, 2 )             state get_Y_delta


state get_Y_delta
   prompt_key  GR_P_EntDsBtwY
   filter      get_event
   on DISTANCE.GRst_DEFAULT                                state .
   on DISTANCE 
	do store_event_by_index( sts, 3 )                  state get_start_pt


state get_start_pt
   prompt_key   GR_P_EntFirstPt
   filter       get_event
   on EX_DATA   do store_event_by_index( sts, 4 )
                do gen_matrix_of_pts_by_row_col_deltas
                   on ERROR
		      do status_key GR_E_ErrInCalc         state terminate

                                                           state terminate

