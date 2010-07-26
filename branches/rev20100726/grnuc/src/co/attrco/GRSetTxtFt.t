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

History
     

Notes

    COMMAND TABLE ENTRIES FOR GRLstNms.sl:
   -----------------------------------------------------------------
    cmd_str                            cmd_key        cmd_class  
   -----------------------------------------------------------------        
    set text font                       GRSTxFn       COattr
   -----------------------------------------------------------------        
\*/
command_string      GRMSetFT,"CO_font,0,1",GRSTxFn
synonym             GRMSetActTxtFt,"CO_font,0,1",GRSTxFn
synonym             GRMSetFrcFt,"CO_frac,0,1",GRSFrFn
/* Not implmented in v1.2
synonym             GRMSetSymFt,"CO_symb,0,1",GRSymbFt
*/
synonym             GRMSetAscFt,"CO_ascii,0,1",GRSASFn
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

        on CMD_TYPE=CO_font
               do message_key GRC_M_SetActTxtFt
               do prompt_key GR_P_EntNwFtNme        state get_input
        on CMD_TYPE=CO_frac
               do message_key GRC_M_SetFrcFt         
               do prompt_key GR_P_EntNwFtNme        state get_input
        on CMD_TYPE=CO_symb
               do message_key GRC_M_SetSymFt         
               do prompt_key GR_P_EntNwFtNme        state get_input
        on CMD_TYPE=CO_ascii   
               do message_key GRC_M_SetAscFt 
               do prompt_key GR_P_EntNwFtNme        state get_input
                                                    state get_input

on ELSE                                             state get_input

state get_input

     filter         get_event

on EX_STRING.GRst_DEFAULT                           state terminate
on TEXT_VALUE       do COdpb.put ( sts,
                                   me->mytype,
                                   &me->event1.event.value,
                                   CO_string )

          on SUCCESS          do COdpb.get ( sts, 
                                             me->mytype,
                                             me->status,
                                             CO_message )
                              do status 0
                              do COtools.wait (20)  state terminate

          on CO_E_INVINP      do status_key GR_E_FtNotFnd     
                                                    state start

          on ERROR or WARNING or SEVERE
                              do error_box_key GR_E_ErrEncCmdTrm 
                                                    state terminate
          state terminate

at wakeup   do COdpb.get ( sts, 
                           me->mytype,
                           me->status, 
                           CO_wakeup_message )
            do status 0

