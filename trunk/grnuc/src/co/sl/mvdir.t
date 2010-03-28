
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


command_string  GRMMoveDir,0,GRMvdir
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"

state_table
#include "coniindex.h"
#include "DIdef.h"
#include "grmessage.h"

state *
on  EX_RESTART
               do erase_hilite                          state start
on  EX_BACK_UP
               do erase_hilite                          state -



state start
on NO_INPUT_PENDING
     do message_key GRC_M_MoveDir                        state get_from_name
on ELSE                                                 state get_from_name


state get_from_name
   prompt_key GR_P_OLD_NAME
   filter        get_event 
   on TEXT_VALUE or EX_DATA
        do store_event_by_index( sts, 0 )
        do get_first_name
           on RETURN_CODE = 2 
                do push_first_event_on_queue            state locate_from_name
                                                        state get_to_name

state locate_from_name
   filter locate
   on EX_DATA
        do get_first_name
        do erase_hilite
        do clear_channels                               state get_to_name


state get_to_name
   prompt_key GR_P_NEW_NAME
   filter  get_event 
   on TEXT_VALUE
        do store_event_by_index( sts, 1 )                           
        do erase_hilite
        do mvdir
           on RETURN_CODE = DIR_E_DIR_DUP
                do status_key GR_E_DIR_DUP              state terminate

           on RETURN_CODE = DIR_E_INVARG
                do status_key GR_E_INV                  state terminate

           on RETURN_CODE = DIR_E_NAME_DUP
                do status_key GR_E_NAME_DUP             state terminate

           on RETURN_CODE = DIR_E_DIR_DUP
                do status_key GR_E_NAME_DUP             state terminate

           on RETURN_CODE = DIR_W_NAME_NOT_FOUND
                do status_key GR_E_NAME_NOT_FND         state terminate

           on RETURN_CODE = DIR_E_ILL_LINK
                do status_key GR_E_SPACE                state terminate

           on RETURN_CODE = DIR_E_PERMISSION
                do status_key GR_E_PERM                 state terminate

           on RETURN_CODE = DIR_S_SUCCESS
                do status_key GR_S_MVDIR                state terminate

                                                        state terminate

   on EX_BACK_UP
        do erase_hilite                                 state get_from_name

