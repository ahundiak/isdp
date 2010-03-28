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

     1. units of angular measurement
     2. units of distance measurement 	

Notes

    COMMAND TABLE ENTRIES FOR GRSetAUniA:
   -----------------------------------------------------------------
    cmd_str              cmd_t          cmd_key        cmd_class  
   -----------------------------------------------------------------        
    ma (angular units)   GRSAnMsUn     13              COattr
   -----------------------------------------------------------------        
    md (distance units)  GRSDsMsUn     14              COattr
   -----------------------------------------------------------------        
    mar(area units)      GRSArMsUn     15              COattr
   -----------------------------------------------------------------        
   
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSetAUniA.sl

*/
command_string      GRMSetMA,"CO_angunit,0,1",GRSAnMsUn
synonym             GRMSetActUnAngMs,"CO_angunit,0,1",GRSAnMsUn
synonym             GRMSetMD,"CO_disunit,0,1",GRSDsMsUn
synonym             GRMSetActUnDisMs,"CO_disunit,0,1",GRSDsMsUn
synonym             GRMSetMAR,"CO_areaunit,0,1",GRSArMsUn
synonym             GRMSetActArMs,"CO_areaunit,0,1",GRSArMsUn
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

on EX_RESTART                                      state start

state start

on NO_INPUT_PENDING   

     on CMD_TYPE=CO_angunit 
                         do message_key GRC_M_SetActUnAngMs
                         do prompt_key  GR_P_EntNwUnAngMs  
                                                   state get_first_input

     on CMD_TYPE=CO_disunit 
                         do message_key GRC_M_SetActUnDisMs
                         do prompt_key  GR_P_EntNwUnDisMs  
                                                   state get_first_input
     on CMD_TYPE=CO_areaunit 
                         do message_key GRC_M_SetActArMs
                         do prompt_key  GR_P_EntNwUnArMs
                                                   state get_first_input

     state get_first_input

on ELSE                                             state get_first_input

state get_first_input

     filter         get_event

on NULL_TEXT_VALUE                                  state terminate
on TEXT_VALUE       do COtools.store_event ( &me->event1, 0 )
                                                    state get_second_input
 
state get_second_input

on NO_INPUT_PENDING do COtools.store_event ( &me->event1, 1 )
                                                    state get_third_input

     filter         get_event

on TEXT_VALUE       do COtools.store_event ( &me->event1, 1 )
                                                    state get_third_input

state get_third_input

on NO_INPUT_PENDING do COtools.store_event ( &me->event1, 2 )
                                                    state have_input

     filter         get_event

on TEXT_VALUE       do COtools.store_event ( &me->event1, 2 )
                                                    state have_input

state have_input

     execute COdpb.put ( sts,
                         me->mytype,
                         0,
                         CO_default )

on SUCCESS          do COdpb.get ( sts, 
                                   me->mytype,
                                   me->status,
                                   CO_message )
                    do status 0
                    do COtools.wait (20)            state terminate

on CO_E_INVINP

     on CMD_TYPE=CO_angunit 
                    do status_key  GR_E_InvUnAngMs   
                                                    state start
     on CMD_TYPE=CO_disunit 
                    do status_key  GR_E_InvUnDisMs
                                                    state start
     on CMD_TYPE=CO_areaunit
                    do status_key  GR_E_InvUnArMs
                                                    state start
     state start

on ERROR or WARNING or SEVERE
                    do error_box_key GR_E_ErrEncCmdTrm 
                                                    state terminate

at wakeup   do COdpb.get ( sts, 
                           me->mytype,
                           me->status, 
                           CO_wakeup_message )
            do status 0

