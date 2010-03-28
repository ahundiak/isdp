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
	
     1. scale   
     2. xscale    
     3. yscale          
     4. zscale          

Notes

    COMMAND TABLE ENTRIES FOR GRSWg:
   ---------------------------------------------------------------------
    cmd_str                      cmd_t         cmd_key        cmd_class  
   ---------------------------------------------------------------------        
    sc (scale)                   GRSSc        8              COattr
   ---------------------------------------------------------------------        
    xs (x-scale)                 GRSXSc      10              COattr
   ---------------------------------------------------------------------        
    ys (y-scale)                 GRSYSc      11              COattr
   ---------------------------------------------------------------------        
    zs (z-scale)                 GRSZSc      12              COattr
   ---------------------------------------------------------------------        
   
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSSc - used for commands expecting a SCALAR

*/
command_string      GRMSetSC,"CO_scale,0,1",GRSSc
synonym             GRMSetActSc,"CO_scale,0,1",GRSSc
synonym             GRMSetAS,"CO_scale,0,1",GRSSc
synonym             GRMSetXS,"CO_xscale,0,1",GRSXSc
synonym             GRMSetActXsc,"CO_xscale,0,1",GRSXSc
synonym             GRMSetYS,"CO_yscale,0,1",GRSYSc
synonym             GRMSetActYsc,"CO_yscale,0,1",GRSYSc
synonym             GRMSetZS,"CO_zscale,0,1",GRSZSc
synonym             GRMSetActZsc,"CO_zscale,0,1",GRSZSc
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

     on CMD_TYPE=CO_scale   do message_key GRC_M_SetActSc
                            do prompt_key  GR_P_EntNwScFac  
                                                   state get_input

     on CMD_TYPE=CO_xscale  do message_key GRC_M_SetActXsc  
                            do prompt_key  GR_P_EntNwScFac  
                                                   state get_input

     on CMD_TYPE=CO_yscale  do message_key GRC_M_SetActYsc  
                            do prompt_key  GR_P_EntNwScFac  
                                                   state get_input

     on CMD_TYPE=CO_zscale  do message_key GRC_M_SetActZsc  
                            do prompt_key  GR_P_EntNwScFac  
                                                   state get_input

     state get_input

on ELSE                                            state get_input

state get_input

     filter         get_event

on EX_VALUE.GRst_DEFAULT                           state terminate
on SCALAR           do COdpb.put ( sts,
                                   me->mytype,
                                   &me->event1.event.value,
                                   CO_double )

     on SUCCESS	         do COdpb.get ( sts, 
                                        me->mytype,
                                        me->status,
                                        CO_message )
                         do status 0
                         do COtools.wait (20)      state terminate

     on CO_E_INVINP 

          on CMD_TYPE=CO_scale
                              do status_key GR_E_InvScFac     
                                                   state start

          on CMD_TYPE=CO_xscale  
                              do status_key GR_E_InvScFac     
                                                   state start

          on CMD_TYPE=CO_yscale  
                              do status_key GR_E_InvScFac     
                                                   state start

          on CMD_TYPE=CO_zscale  
                              do status_key GR_E_InvScFac     
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

