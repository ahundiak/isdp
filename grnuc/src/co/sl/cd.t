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

command_string  GRMSetDefDir,"CO_ni_cd,0,1",GRCDr
synonym         GRMCd,"CO_ni_cd,0,1",GRCDr
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
   message_key    GRC_M_SetDefDir
   prompt_key     GR_P_Cd

   filter get_event

   on EX_DATA
	do store_event_by_index ( sts, 0 )
	do push_first_event_on_queue
							  state get_dir

   on TEXT_VALUE
	do store_event_by_index( sts, 0 )
        do use_events
/*
        do update_dir_form
*/
           on RETURN_CODE = DIR_W_DIR_NOT_FOUND
       	        do status_key GR_E_DIR_NOT_FOUND
                                                          state terminate
              				                  state terminate

state get_dir
   locate_eligible   "+GRgraphics"
   locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner      "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_display    "ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT"
   filter locate

   on EX_DATA
	     do erase_hilite
	     do store_event_by_index( sts, 0 )
             do graphic_cd
	     on RETURN_CODE = DIR_W_NAME_NOT_FOUND
       	        do status_key GR_E_DIR_NOT_FOUND
                                                          state start

	     on SUCCESS
                do use_events
/*
                do update_dir_form
*/
                   on RETURN_CODE = DIR_W_DIR_NOT_FOUND
	              do copy_event_by_index( sts, 0, 6 )
                      do use_events
/*
                      do update_dir_form
*/
                         on RETURN_CODE = DIR_W_DIR_NOT_FOUND
       	                    do status_key GR_E_DIR_NOT_FOUND
                                                            state start
                                                            state start
                                                            state start
                                                            state start
