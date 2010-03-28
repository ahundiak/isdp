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


command_string  GRMXY,"ABSOLUTE,0,1",GRSlPnKyn

class           COcoord
start_state     start
spec_path       "$PLATFORM/co/spec"

product_name    "$PLATFORM"
command_table   "3416.dpt"


state_table
#include "grmessage.h"
#include "msdef.h"
#include "dpdef.h"
#include "DIdef.h"
#include "cocobpriv.h"
#include "comisc.h"

at init do display_active_parms ( sts, CO_COORD_TYPE | CO_COORD_NAME )

state *
on  EX_RESTART    do reset_input_count                          state .

/*
 * We start off assuming that the CSname and CStype are NOT specified 
 * on the command line; thus, we get the default query info, and CS 
 * environment incase the first input is a coordinate.  That way if
 * input is pending, then we can set the filter mask for the default 
 * CS type in case the input is a VALUE ( coordinate ).
 *
 * misc_flag  settings:  0 means NO input was pending on entry
 *                       1 means input WAS pending on entry
 */
state start

   message_key  GRC_M_AbsCoord
   execute  get_cs_manager
   execute  load_default_query_info
   execute  load_cs_environment
   execute  reset_input_count

   on NO_INPUT_PENDING     do set_misc_flag(sts,0)             state get_coord

   execute set_misc_flag(sts,1)
   execute  set_cs_prompt_and_mask
   scale_flag  GRIO_NO_SCALE
   filter get_event

   on TEXT_VALUE
        do load_specified_query_info
           on RETURN_CODE = MSINARG
        do status_key  GR_E_NotValCSTyp                        state terminate
           on RETURN_CODE = DIR_W_NAME_NOT_FOUND
                do status_key GR_E_CorSysNotFnd                state terminate

        do load_cs_environment                                 state get_coord
 

   on EX_VALUE or
      EX_DATA
	do store_coordinate
        do increment_input_count                               state get_coord


state get_coord
   on NO_INPUT_PENDING
      do get_misc_flag
         on RETURN_CODE = 1  /* then use defaults for remainder of args */
	    do set_default_event_by_index( sts, -1 )
            do store_coordinate
            do increment_input_count
               on RETURN_CODE = CO_I_INDEX_MAX                 state get_window
                                                               state .
         on RETURN_CODE = 0  /* prompt for arg */              state call_filter
                                                               state .
   on ELSE /* input pending - call filter */                   state call_filter

state call_filter   
   execute  set_cs_prompt_and_mask
   scale_flag  GRIO_NO_SCALE   /* scaling done by CS object automatically */
   filter get_event

   on EX_VALUE or
      EX_DATA
        do store_coordinate 
        do increment_input_count
           on RETURN_CODE = CO_I_INDEX_MAX                     state get_window
                                                               state get_coord

   on EX_BACK_UP
        do decrement_input_count
           on RETURN_CODE = CO_I_INDEX_ZERO                    state get_coord
                                                               state get_coord


state get_window
  /*
   *  the world data point generated is put in first_event, then pushed onto
   *  the software queue
   */
  on VSD_EMPTY
       do generate_world_data_point
          on RETURN_CODE = DPNOOBJECTS
               do status_key GR_E_WinNotFnd                  state terminate
          on ERROR
               do status_key GR_E_NoWinByName                state terminate

       do push_first_event_on_queue                          state terminate

  filter get_event

  on TEXT_VALUE
       do generate_world_data_point
          on RETURN_CODE = DPAMBIGUOUS 
               do status_key GR_E_NamMatMnyWin               state terminate
          on RETURN_CODE = DPNOOBJECTS
               do status_key GR_E_WinNotFnd                  state terminate
          on ERROR
               do status_key GR_E_NoWinByName                state terminate

       do push_first_event_on_queue                          state terminate

