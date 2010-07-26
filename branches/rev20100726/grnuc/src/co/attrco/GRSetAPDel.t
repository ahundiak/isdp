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
	
     1. area pattern deltas

Notes

    COMMAND TABLE ENTRIES FOR GRSArPtDl
   -----------------------------------------------------------------
    cmd_str                            cmd_key        cmd_class  
   -----------------------------------------------------------------        
    ap (area pattern deltas)           16              COattr
   -----------------------------------------------------------------        
       
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSetATxSz

*/
command_string      GRMSetAP,"CO_apdel,0,1",GRSArPtDl
synonym             GRMSetActArPatDlta,"CO_apdel,0,1",GRSArPtDl
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

on NO_INPUT_PENDING     do message_key GRC_M_SetActArPatDlta
                        do prompt_key  GR_P_EntNwArPatDlta  
                                                    state get_first_input

on ELSE                                             state get_first_input

state get_first_input     

     filter         get_event

on EX_VALUE.GRst_DEFAULT                            state terminate
on DISTANCE    do COtools.store_event ( &me->event1, 0 )
                                                    state get_second_input

state get_second_input


     filter         get_event

on EX_VALUE.GRst_DEFAULT or DISTANCE
               do COtools.store_event ( &me->event1, 1 )
                                                    state have_input


state have_input

          execute  COdpb.put ( sts, 
                               CO_apdel,
                               0,
                               CO_default )                                       

          on SUCCESS 
                    do COdpb.get ( sts,
                                   CO_apdel,
                                   me->status,
                                   CO_message )  
                    do status 0
                    do COtools.wait (20)            state terminate

          on CO_E_INVINP
                    do status_key GR_E_InvHorDlta   state start

          on ERROR or WARNING or SEVERE
                    do error_box_key GR_E_ErrEncCmdTrm  
                                                    state terminate

at wakeup   do COdpb.get ( sts, 
                           CO_apdel, 
                           me->status, 
                           CO_wakeup_message )
            do status 0
