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

command_string  GRMCreateDir,CO_ni_mkdir,GRCrDr
synonym         GRMMkdir,CO_ni_mkdir,GRCrDr
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"

state_table
#include "coniindex.h"
#include "DIdef.h"
#include "grmessage.h"

state start
   message_key   GRC_M_CreateDir
   prompt_key    GR_P_Mkdir
   filter        get_event 
   on TEXT_VALUE
	do store_event_by_index( sts, 0 )
        do use_events
/*
        do update_dir_form
*/
           on NO_INPUT_PENDING
           on RETURN_CODE = DIR_E_DIR_DUP
	        do status_key GR_E_DIR_DUP                      state terminate
           on RETURN_CODE = DIR_W_NAME_NOT_FOUND
	        do status_key GR_E_INVARG                       state terminate
           on RETURN_CODE = DIR_E_PERMISSION
	        do status_key GR_E_PERM                         state terminate
	                                                        state terminate

                                                                state start
