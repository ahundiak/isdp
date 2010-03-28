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
	
     1. angle by 3 points    
     2. scale by 3 points    

Notes

    COMMAND TABLE ENTRIES FOR GRSAn3Pn:
   -----------------------------------------------------------------
    cmd_str                       cmd_t      cmd_key        cmd_class  
   --------------------------------------------------------------------        
    set active angle by 3 points  GRSAn3Pn 7              COattr
   --------------------------------------------------------------------        
    set active scale by 3 points  GRSSc3Pn 9              COattr
   --------------------------------------------------------------------        
   
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSAn3Pn.sl

*/
command_string      GRMSetActAng3Pt,"CO_ang3pts",GRSAn3Pn
synonym             GRMSetActSc3Pt,"CO_scale3pts",GRSSc3Pn
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

on CMD_TYPE=CO_ang3pts 
                    do message_key  GRC_M_SetActAng3Pt
                                                    state get_first_dp
on CMD_TYPE=CO_scale3pts
                    do message_key  GRC_M_SetActSc3Pt
                                                    state get_first_dp

state get_first_dp

     prompt_key     GR_P_EntPt1
     status 0

     filter         get_event

on EX_BACK_UP or EX_RJT_MOVEON                      state .
on EX_DATA          do COtools.store_event ( &me->event1, 0)
                                                    state get_second_dp

state get_second_dp

     prompt_key     GR_P_EntPt2
     status 0     

     filter         get_event

on EX_BACK_UP                                       state -
on EX_RJT_MOVEON                                    state .
on EX_DATA          do COtools.store_event ( &me->event1, 1 )
                                                    state get_third_dp

state get_third_dp

     prompt_key     GR_P_EntPt3
     status 0     

     filter         get_event

on EX_BACK_UP                                       state -
on EX_RJT_MOVEON                                    state .
on EX_DATA          do COtools.store_event ( &me->event1, 2 )            
                    do COdpb.put ( sts,
                                   me->mytype,
                                   0,
                                   CO_default )   
          on SUCCESS          
               on CMD_TYPE=CO_ang3pts
                              do COdpb.get ( sts,
                                             CO_angle,
                                             me->status,
                                             CO_message )
                              do status 0
                              do COtools.wait (20)            state terminate

               on CMD_TYPE=CO_scale3pts
                              do COdpb.get ( sts,
                                             CO_scale,
                                             me->status,
                                             CO_message )
                              do status 0 
                              do COtools.wait (20)            state terminate

               state terminate

          on CO_E_INVINP
               on CMD_TYPE=CO_scale3pts
                              do status_key  GR_E_CantDfnSc   state start
     
               on CMD_TYPE=CO_ang3pts
                              do status_key  GR_E_CantDfnAng  state start

               state terminate

          on ERROR or WARNING or SEVERE
                              do error_box_key GR_E_ErrEncCmdTrm 
                                                              state terminate
          state .


at wakeup   do COdpb.get ( sts,
                           me->mytype,
                           me->status,
                           CO_message )

