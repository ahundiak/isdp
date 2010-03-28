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
	
     1. raster memory

Notes

    COMMAND TABLE ENTRIES FOR GRSWg:
   ---------------------------------------------------------------------
    cmd_str                      cmd_t         cmd_key        cmd_class  
   ---------------------------------------------------------------------        
    set raster reference memory  GRSetRMem      1              COrattr
   ---------------------------------------------------------------------
   
History

     Jay Wallingford     11/23/87  Design and Implementation

\*/

/* 
     
     GRSetRMem - used for commands expecting a SCALAR

*/
command_string      GRMSetRgMem,"RGREFMEMLIM,0,1",GRSetRMem
synonym             GRMSetRCM,"RGREFMEMLIM,0,1",GRSetRMem
class               COrattr
super_class         CEO_LOCATE
start_state         start
product_name        "$SOURCE"
options             "siTC"

state_table

#include <grmessage.h>
#include "COrattrdef.h"

state *

on EX_RESTART                                       state start

state start

on NO_INPUT_PENDING do message_key GRC_M_SetRgMem
                    do prompt_key  GR_P_EntRgMem    
                    do show_attribute ()            state get_input
on ELSE                                             state get_input

state get_input

     filter         get_event

on EX_VALUE.GRst_DEFAULT                            state terminate
on SCALAR                do set_attribute        
     on COATTR_INVINP 
                         do status_key GR_E_InvRgMem     
                         do message_key GRC_M_SetRgMem
                         do prompt_key  GR_P_EntRgMem            state get_input
     on SUCCESS	         do show_attribute ()                    state terminate
     on ERROR            do status_key GR_E_ErrEncCmdTrm         state terminate
     state terminate
