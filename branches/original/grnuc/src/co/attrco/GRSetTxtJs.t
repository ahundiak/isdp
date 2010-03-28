/*
Abstract	
	This command provides the user interface for the following commands:
	
     1. text justification

Notes

    COMMAND TABLE ENTRIES FOR GRSCl:
   ------------------------------------------------------------------------
    cmd_str                        cmd_t          cmd_key        cmd_class  
   ------------------------------------------------------------------------        
    tj (text just)                 GRSTxJs          32              COattr
   ------------------------------------------------------------------------

History

     Jay Wallingford     11/23/87  Deign and Implementation
     Mark Ferguson	 03/30/90  Added Status Form Available status display

*/

/*
     
     GRSTJs.sl - used for commands expecting a SCALAR or TEXT_VALUE
                   keyin. 

                   Note: These commands DO NOT leave the active attribute
                   up in the status field since their status is reflected 
                   in the active parameters form. This is done to avoid 
                   confusion between a lingering status message and the 
                   active parameters form. Text justification is one exception
                   it does leave the active attribute in the status field.

                   Note: On modification check GRSetARgBg.sl.

*/

command_string  GRMSetTJ,"CO_just,0,1",GRSTxJs
synonym         GRMSetActTxtJust,"CO_just,0,1",GRSTxJs
class		COattr
super_class     COtools
super_class     COdpb
super_class	CEO_LOCATE
spec_path       "$GRNUC/co/spec"
start_state	start
product_name	"$SOURCE"
status_display  "GRTextJust","-1","-1"
options		"siCT"

state_table

#include <grmessage.h>
#include <FI.h>
#include <dpbco.h>
#include "attrco.h"

state *

on EX_RESTART                                            state start

state start

on NO_INPUT_PENDING      do message_key GRC_M_SetActTxtJust 
                         do prompt_key GR_P_EntNwJust    
            						 state get_input
on ELSE                                                  state get_input

state get_input
     
     filter         get_event

on EX_VALUE.GRst_DEFAULT                                 state terminate

on SCALAR      do COdpb.put ( sts,
                              CO_just,
                              &me->event1.event.value,
                              CO_double )

          on CO_E_INVINP    
                    do status_key GR_E_InvJust          state start

          on SUCCESS
                    do COdpb.get ( sts,
                                   CO_just,
                                   me->status,
                                   CO_message )  
                    do status 0
                    do COtools.wait (20)                 state terminate

          on ERROR or WARNING or SEVERE
                    do error_box_key GR_E_ErrEncCmdTrm   state terminate
          state .

on EX_STRING        do COdpb.put ( sts,
                                   CO_just,
                                   me->event1.event.keyin,
                                   CO_string )

          on SUCCESS
                    do COdpb.get ( sts,
                                   CO_just,
                                   me->status,
                                   CO_message )
		    do status 0				 state terminate

          on CO_E_INVINP    
                    do status_key GR_E_InvJust           state start

          on ERROR or WARNING or SEVERE
                    do error_box_key GR_E_ErrEncCmdTrm   state terminate
          state .

at wakeup   do set_gadgets()
            do message_key GRC_M_SetActTxtJust 
            do prompt_key GR_P_EntNwJust    
	    do status_key GR_I_StFmAvail
	    do status_display_button(1)
	    do COtools.wait (20)
            do COdpb.get ( sts, 
                           CO_just,
                           me->status, 
                           CO_wakeup_message )
            do status 0

at sleep
	    do status_display_button(0)

