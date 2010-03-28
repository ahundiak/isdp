
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
*/ 
command_string  GRMDPT,"CO_ni_delta_world,0,1",GRDltVwPt
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "dperr.h"

state *
on  EX_RESTART                                          state start
on  EX_BACK_UP                                          state -
on  EX_RJT_MOVEON                                       state .


state start
   message_key    GRC_M_DPT
   prompt_key     GR_P_EntXDeltaVal
   filter         get_event

   on DISTANCE
	do store_event_by_index( sts, 1 )                           state have_first_delta


state have_first_delta
   prompt_key     GR_P_EntYDeltaVal
   filter         get_event

   on DISTANCE 
	do store_event_by_index( sts, 2 )                            state have_second_delta


state have_second_delta
   prompt_key     GR_P_EntZDelValVw
   filter         get_event

   on DISTANCE
	do store_event_by_index( sts, 3 )                          state have_third_delta


state have_third_delta

   on VSD_EMPTY
	do store_event_by_index( sts, 4 )   
        do use_events
           on RETURN_CODE = DPNOOBJECTS
                do status_key GR_E_WinNotFnd           state start

           on ERROR
                do status_key GR_E_NoWinByName         state start

        do push_first_event_on_queue    state terminate

   filter  get_event

   on TEXT_VALUE 
	do store_event_by_index( sts, 4 )
        do use_events
           on RETURN_CODE = DPNOOBJECTS
                do status_key GR_E_WinNotFnd           state start
           on RETURN_CODE = DPAMBIGUOUS 
                do status_key GR_E_NamMatMnyWin        state start

           on ERROR
                do status_key GR_E_NoWinByName         state start

        do push_first_event_on_queue                   state terminate

