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

	This command provides the user interface for the following commands:
	
     1. character spacing
     2. line spacing

Notes

    COMMAND TABLE ENTRIES FOR GRSWg:
   ---------------------------------------------------------------------
    cmd_str                      cmd_t         cmd_key        cmd_class  
   ---------------------------------------------------------------------        
    cs (char space)              GRSTxChSp    36              COattr
   ---------------------------------------------------------------------
    ls (line space)              GRSTxLSp    37              COattr
   ---------------------------------------------------------------------
   
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSetACs - used for commands expecting a SCALAR

*/
command_string      GRMSetCS,"CO_charsp,0,1",GRSTxChSp
synonym             GRMSetActTxtCs,"CO_charsp,0,1",GRSTxChSp
synonym             GRMSetLS,"CO_linesp,0,1",GRSTxLSp
synonym             GRMSetActTxtLs,"CO_linesp,0,1",GRSTxLSp
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
     on CMD_TYPE=CO_charsp
                         do message_key GRC_M_SetActTxtCs   
                         do prompt_key  GR_P_EntNwTxtCs  
                                                   state get_input

     on CMD_TYPE=CO_linesp
                         do message_key GRC_M_SetActTxtLs  
                         do prompt_key  GR_P_EntNwTxtLs  
                                                   state get_input

     state get_input

on ELSE                                             state get_input

state get_input

     filter         get_event

on EX_VALUE.GRst_DEFAULT                            state terminate
on SCALAR           do COdpb.put ( sts,
                                   me->mytype,
                                   &me->event1.event.value,
                                   CO_double )

     on SUCCESS	         do COdpb.get ( sts,
                                        me->mytype,
                                        me->status,
                                        CO_message )
                         do status 0 
                         do COtools.wait (20)       state terminate

     on CO_E_INVINP 

          on CMD_TYPE=CO_charsp
                              do status_key GR_E_InvCs
                                                    state start

          on CMD_TYPE=CO_linesp
                              do status_key GR_E_InvLs        
                                                    state start
          state .

     on ERROR or WARNING or SEVERE
                         do error_box_key GR_E_ErrEncCmdTrm           state terminate
     state .

at wakeup   do COdpb.get ( sts, 
                           me->mytype,
                           me->status, 
                           CO_wakeup_message )
            do status 0

