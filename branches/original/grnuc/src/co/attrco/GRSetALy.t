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
              forth in subdiviion  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\
Abstract	
	This command provides the user interface for the following commands:
	
     1. level    

Notes

    COMMAND TABLE ENTRIES FOR GRSCl:
   ------------------------------------------------------------------------
    cmd_str                        cmd_t          cmd_key        cmd_class  
   ------------------------------------------------------------------------        
    lv (level)                     GRSLy       4              COattr
   ------------------------------------------------------------------------

History

     Jay Wallingford     11/23/87  Deign and Implementation

\*/

/*
     
     GRSLy.sl - used for commands expecting a SCALAR or TEXT_VALUE
                   keyin. 
                   Note: These commands DO NOT leave the active attribute
                   up in the status field since their status is reflected 
                   in the active parameters form. This is done to avoid 
                   confusion between a lingering status message and the 
                   active parameters form. Text justification is one exception
                   it does leave the active attribute in the status field.

                   Note: On modification check GRSetARgBg.sl.
*/

command_string      GRMSetActLy,"CO_level,0,1",GRSLy
synonym             GRMSetLV,"CO_level,0,1",GRSLy
synonym             GRMSetLY,"CO_level,0,1",GRSLy

class		COattr
super_class     COtools
super_class     COdpb
super_class	CEO_LOCATE
spec_path       "$GRNUC/co/spec"
start_state	start
product_name	"$SOURCE"
options		"siCT"

state_table

#include <grmessage.h>
#include <dpbco.h>
#include "attrco.h"

state *

on EX_RESTART                                            state start

state start

on NO_INPUT_PENDING     do message_key GRC_M_SetActLy
                        do prompt_key GR_P_EntNwLy       state get_input  
                                                       
on ELSE                                                  state get_input

state get_input
     
     filter         get_event

on EX_VALUE.GRst_DEFAULT                                 state terminate
on SCALAR do COdpb.put ( sts,
                         CO_level,
                         &me->event1.event.value,
                         CO_double )

          on CO_E_INVINP do status_key GR_E_InvLy        state start

          on SUCCESS                                     state terminate

          on ERROR or WARNING or SEVERE
                         do error_box_key GR_E_ErrEncCmdTrm 
                                                         state terminate
                         
                         state .
on EX_STRING   do COdpb.put ( sts,
                              CO_level,
                              me->event1.event.keyin,
                              CO_string )

          on CO_E_INVINP do status_key GR_E_InvLy        state start

          on SUCCESS                                     state terminate

          on ERROR or WARNING or SEVERE
                         do error_box_key GR_E_ErrEncCmdTrm 
                                                         state terminate
                         
                         state terminate

at wakeup   do COdpb.get ( sts, 
                           CO_level, 
                           me->status, 
                           CO_wakeup_message )
            do status 0

