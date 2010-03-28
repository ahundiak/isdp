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
	
     1. raster background color
     2. raster foreground color

Notes

    COMMAND TABLE ENTRIES FOR GRSCl:
   ------------------------------------------------------------------------
    cmd_str                        cmd_t          cmd_key        cmd_class  
   ------------------------------------------------------------------------        
    rbg (raster background color)  RSSBcCl       2              COrattr
   ------------------------------------------------------------------------
    rfg (raster foreground color)  RSSCnFrCl       3              COrattr
   ------------------------------------------------------------------------
History

     Jay Wallingford     11/23/87  Design and Implementation
     JHW                 04/19/88  Add command to set raster background color
\*/

/*
     
     RSSBcCl.sl - used for commands expecting a SCALAR or TEXT_VALUE
                   keyin.

                   Note: On modification check GRSCl.sl.
*/
command_string  GRMSetRFG,"RGFORECOLOR,0,1",RSSCnFrCl
synonym         GRMSetRgForCo,"RGFORECOLOR,0,1",RSSCnFrCl
synonym         GRMSetRBG,"RGBACKCOLOR,0,1",RSSBcCl
synonym         GRMSetRgBacCo,"RGBACKCOLOR,0,1",RSSBcCl
class		COrattr
super_class	CEO_LOCATE
start_state	start
product_name	"$SOURCE"
options		"siTC"

state_table

#include <grmessage.h>
#include "COrattrdef.h"

state *

on EX_RESTART                                            state start

state start

on NO_INPUT_PENDING           

                         do show_attribute ()

     on CMD_TYPE=RGFORECOLOR
                         do message_key GRC_M_SetRgForCo  state get_input
     on CMD_TYPE=RGBACKCOLOR
                         do message_key GRC_M_SetRgBacCo  state get_input

     state get_input

on ELSE                                                  state get_input

state get_input
     
     prompt_key GR_P_EntNwCo
     
     filter         get_event

on EX_VALUE.GRst_DEFAULT                            state terminate
on SCALAR or EX_STRING   do set_attribute
     on COATTR_INVINP   
          on CMD_TYPE=RGFORECOLOR
                              do status_key GR_E_InvCo
                              do message_key GRC_M_SetRgForCo
                                                    state .
          on CMD_TYPE=RGBACKCOLOR
                              do status_key GR_E_InvCo
                              do message_key GRC_M_SetRgBacCo
                                                    state .
                                                    state terminate
     on SUCCESS	    do show_attribute ()            state terminate
     on ERROR       do status_key GR_E_ErrEncCmdTrm state terminate
                                                    state terminate
