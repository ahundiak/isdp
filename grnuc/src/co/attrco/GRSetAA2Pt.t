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
	
     1. angle by 2 points

Notes

    COMMAND TABLE ENTRIES FOR GRSAn3Pn:
   -----------------------------------------------------------------
    cmd_str                       cmd_t      cmd_key        cmd_class  
   --------------------------------------------------------------------        
    set active angle by 2 points  GRSAn2Pn 6              COattr
   ---------------------------------------------------------------------        
   
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSAn2Pn.sl

*/
command_string      GRMSetActAng2Pt,"CO_ang2pts",GRSAn2Pn
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

     message_key    GRC_M_SetActAng2Pt
     prompt_key     GR_P_EntPt1
     status 0

     filter         get_event

on EX_BACK_UP or EX_RJT_MOVEON                      state .
on EX_DATA          do COtools.store_event ( &me->event1, 0 )
                                                    state get_second_dp

state get_second_dp
     
     prompt_key     GR_P_EntPt2
     status 0

     filter         get_event

on EX_BACK_UP                                       state -
on EX_RJT_MOVEON                                    state .
on EX_DATA          do COtools.store_event ( &me->event1, 1 )
                    do COdpb.put ( sts,
                                   CO_ang2pts,
                                   0,
                                   CO_default )

          on SUCCESS          
                    do COdpb.get ( sts, 
                                   CO_angle,
                                   me->status,
                                   CO_message )
                    do status 0                     
                    do COtools.wait (20)            state terminate

          on CO_E_INVINP
                    do status_key  GR_E_CantDfnAng  state start

          on ERROR or WARNING or SEVERE
                              do error_box_key GR_E_ErrEncCmdTrm 
                                                    state terminate
          state .

at wakeup   do COdpb.get ( sts,
                           CO_angle,
                           me->status,
                           CO_message )

