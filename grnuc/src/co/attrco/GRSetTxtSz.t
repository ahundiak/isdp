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

/*\
Abstract	
	This class implements commands to change any of the following 
	attributes:
	
     1. text size    
     2. text width     
     3. text height 

Notes

    COMMAND TABLE ENTRIES FOR GRSTSz:
   -----------------------------------------------------------------
    cmd_str                            cmd_key        cmd_class  
   -----------------------------------------------------------------        
    tx (text size)                     33              COattr
   -----------------------------------------------------------------
    tw (text width)                    34              COattr
   -----------------------------------------------------------------
    th (text height)                   35              COattr
   -----------------------------------------------------------------
       
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSTxSz

*/
command_string      GRMSetTX,"CO_size,0,1",GRSTxSz
synonym             GRMSetTS,"CO_size,0,1",GRSTxSz
synonym             GRMSetActTxtSz,"CO_size,0,1",GRSTxSz                   
synonym             GRMSetTW,"CO_width,0,1",GRSTxWd
synonym             GRMSetActTxtWd,"CO_width,0,1",GRSTxWd
synonym             GRMSetTH,"CO_height,0,1",GRSTxHg
synonym             GRMSetActTxtHt,"CO_height,0,1",GRSTxHg
class               COattr
super_class         COtools
super_class         COdpb
super_class         CEO_LOCATE
spec_path           "$GRNUC/co/spec"
start_state         start
product_name        "$SOURCE"
options             "siCT"

state_table

#include <grmessage.h>
#include <dpbco.h>
#include "attrco.h"

state *

on EX_RESTART                                       state start

state start

on NO_INPUT_PENDING

     on CMD_TYPE=CO_size  do message_key GRC_M_SetActTxtSz
                          do prompt_key  GR_P_EntNwTxtSz  
                                                    state get_input  

     on CMD_TYPE=CO_width do message_key GRC_M_SetActTxtWd
                          do prompt_key  GR_P_EntNwTxtWd  
                                                    state get_input

     on CMD_TYPE=CO_height do message_key GRC_M_SetActTxtHt  
                           do prompt_key  GR_P_EntNwTxtHt  
                                                    state get_input

     state get_input

on ELSE                                             state get_input

state get_input     

     filter         get_event

on EX_VALUE.GRst_DEFAULT                            state terminate
on DISTANCE         do COdpb.put ( sts,
                                   me->mytype,
                                   &me->event1.event.value,
                                   CO_double )

          on SUCCESS          do COdpb.get ( sts,
                                             me->mytype,
                                             me->status,
                                             CO_message )
                              do status 0
                              do COtools.wait (20)  state terminate

          on CO_E_INVINP

               on CMD_TYPE=CO_size   
                              do status_key GR_E_InvTxtSz     state start

               on CMD_TYPE=CO_width      
                              do status_key GR_E_InvTxtWd     state start

               on CMD_TYPE=CO_height 
                              do status_key GR_E_InvTxtHt     state start

               state terminate

          on ERROR or WARNING or SEVERE
                              do error_box_key GR_E_ErrEncCmdTrm  
                                                               state terminate
          state .

at wakeup   do COdpb.get ( sts, 
                           me->mytype,
                           me->status, 
                           CO_wakeup_message )
            do status 0

