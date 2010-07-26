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


command_string  GRMDI,"CO_ni_dist_dir_view,0,1",GRSlPnDsDr

/* 
 *  this synonym allows "di" to be found in the command table 
 */
synonym         GRMDistDir,"CO_ni_dist_dir_view,0,1",GRSlPnDsDr  

class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "coniindex.h"
#include "grmessage.h"
#include "dperr.h"
#include "comisc.h"

at init do display_active_parms ( sts, CO_ACTIVE_ANGLE )

state *
on  EX_RESTART                                              state get_distance
on  EX_BACK_UP                                              state -
on  EX_RJT_MOVEON                                           state .

/*
 * misc_flag  settings:  0 means NO input was pending on entry
 *                       1 means input WAS pending on entry
 */

state start
   message_key   GRC_M_DI
   on NO_INPUT_PENDING     do set_misc_flag(sts,0)       state get_distance
   on ELSE                 do set_misc_flag(sts,1)       state get_distance

state get_distance
   prompt_key    GR_P_EntDist
   filter        get_event
   on DISTANCE
      do store_event_by_index( sts, 1 )                  state have_distance


state have_distance
   on VSD_EMPTY
      do get_misc_flag
         on RETURN_CODE = 1
	    /* then use default for angle */
	    do set_default_event_by_index( sts, 2 )      state have_angle
         on RETURN_CODE = 0  /* prompt for arg */        state prompt_for_angle
                                                         state terminate
   on ELSE                                               state prompt_for_angle

state prompt_for_angle
   prompt_key    GR_P_EntAng
   filter        get_event
   on ANGLE
      do store_event_by_index( sts, 2 )                state have_angle


state have_angle
   on VSD_EMPTY
        do store_event_by_index( sts, 3 )   /* default rep factor */
        do store_event_by_index( sts, 4 )   /* default view       */
        do use_events
           on RETURN_CODE = DPNOOBJECTS
                do status_key GR_E_WinNotFnd             state terminate
           on ERROR
                do status_key GR_E_NoWinByName           state terminate
                                                         state terminate


   filter  get_event
   on TEXT_VALUE
	do set_default_event_by_index( sts, 3 ) /*  default rep factor */
	do store_event_by_index( sts, 4 )
        do use_events
           on RETURN_CODE = DPNOOBJECTS
                do status_key GR_E_WinNotFnd              state terminate
           on RETURN_CODE = DPAMBIGUOUS 
                do status_key GR_E_NamMatMnyWin           state terminate
           on ERROR
                do status_key GR_E_NoWinByName            state terminate

                                                          state terminate


   on SCALAR >= 1.0 or
      SCALAR.GRst_DEFAULT
	do set_default_event_by_index( sts, 4 ) /*  default window    */
	do store_event_by_index( sts, 3 )
                                                          state get_view

   on SCALAR
	do status_key GR_E_NumMstGT0                      state terminate


state get_view

   on VSD_EMPTY
        do store_event_by_index( sts, 4 )         /* default rep factor */
        do use_events
           on RETURN_CODE = DPNOOBJECTS
                do status_key GR_E_WinNotFnd              state terminate
           on RETURN_CODE = DPAMBIGUOUS 
                do status_key GR_E_NamMatMnyWin           state terminate
           on ERROR
                do status_key GR_E_NoWinByName            state terminate

                                                          state terminate
   filter  get_event
   on TEXT_VALUE
	do store_event_by_index( sts, 4 )  /* store view name */
        do use_events
           on RETURN_CODE = DPNOOBJECTS
                do status_key GR_E_WinNotFnd              state terminate
           on RETURN_CODE = DPAMBIGUOUS 
                do status_key GR_E_NamMatMnyWin           state terminate
           on ERROR
                do status_key GR_E_NoWinByName            state terminate

                                                          state terminate

