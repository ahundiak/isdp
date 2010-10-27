/* $Id: VDCmdQYcrt.t,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* I/VDS
 *
 * File:        <vdpocket/com> / <VDCmdQYcrt.t>
 *
 * Description:
 *		State table for the command "Create Query Criteria's"
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdQYcrt.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1995/12/12  15:10:44  pinnacle
# Replaced: vdpocket/cmd/VDCmdQYcrt.t for:  by yzhu for vds.240
#
# Revision 1.6  1995/04/28  17:49:44  pinnacle
# Replace: vdpocket/cmd/VDCmdQYcrt.t by yzhu for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	08/06/94	adz		Add symbology attributes
 *	08/06/94	adz		Preselect criteria within fence.
 *	08/30/94	adz		Adapt for new interface.
 */
command_string	VDC_M_QryCrt, 0, VDQryCrt
command_table   "vds.cmd"
class           VDCmdQYnpt
super_class     CEO_GSLOCATE  
product_name    "$VDS"
options         "TCis" 
form		"VDquery1",0,0,"-1","-1"

start_state     start

state_table

#include "comndef.h"
#include "coniindex.h"
#include "dedef.h"
#include "lcdef.h"
#include "grmessage.h"
#include "VDmsg.h"
#include "VDQYdef.h"


state *

	on EX_BACKUP						state -
	on EX_RESTART
                do init_query()
		do wakeup_query()				state start

state start
	message_key	VD_M_QryCrt
	prompt		"Enter Query"
	filter      	get_event

        on GR_UNKNOWN_TYPE.VD_LOCATE_STATUS
             do return_form( &me->ret )
                    on RETURN_CODE = VD_LOCATE_OBJECT   
                                          	state locate_sta
                                                        	state .
 
	on EX_FORM_FINISHED					state terminate
        

state locate_sta
	message_key	VD_M_QryCrt
	prompt	        "Locate object/Move On"
        accept          "Accept/Reject"   

    	locate_mask         "GRm_DATA | GRm_OBJID | GRm_RJT_MOVEON | 
                            GRm_STRING | GRm_BACK_UP"              
    	locate_properties   "LC_LC_ONLY | LC_RW | LC_DP_ONLY | LC_REGEX_ON"
    	locate_owner        "LC_FLEX_COMP | LC_RIGID_OWNER | LC_RIGID_COMP |
                             LC_FLEX_OWNER  | LC_REF_OBJECTS"
    	locate_display      "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                             ALL_WINDOWS | LC_ERASE_ALL"                 
	filter      	     locate        

        on EX_RJT_MOVEON
                do set_form
          	do change_label( &me->ret)
          	do return_form( &me->ret)
                   on RETURN_CODE = VD_FORM_DISPLAY
                                                        state start
                                                        state .
        on EX_DATA or EX_OBJID
                do locate_process                       state .

	on EX_FORM_FINISHED				state terminate

at init		do	init_query()
at wakeup	do	wakeup_query()

