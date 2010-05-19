/*$Id: VDCmdQYsel.t,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* I/VDS
 *
 * File:        <vdpocket/com> / <VDCmdQYnpt.t>
 *
 * Description:
 *		State table for the command "VDS Query"
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdQYsel.t,v $
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
# Revision 1.12  1996/01/25  22:53:42  pinnacle
# Replaced: vdpocket/cmd/VDCmdQYsel.t for:  by yzhu for vds.240
#
# Revision 1.11  1996/01/11  20:41:50  pinnacle
# Replaced: vdpocket/cmd/VDCmdQYsel.t for:  by yzhu for vds.240
#
# Revision 1.9  1995/09/14  23:18:28  pinnacle
# Replaced: vdpocket/cmd/VDCmdQYsel.t for:  by yzhu for vds.240
#
# Revision 1.8  1995/04/16  02:56:10  pinnacle
# Replace: vdpocket/cmd/VDCmdQYsel.t by yzhu for OPE
#
# Revision 1.3  1995/02/22  21:04:08  pinnacle
# Replace: vdpocket/cmd/VDCmdQYsel.t by yzhu for OPE
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
 *	03/08/95	yzhu		Add command input.
 */

command_string	VDC_M_QrySel, 1, VDQrySel
command_table   "vds.cmd"
class           VDCmdQYnpt
product_name    "$VDS"

options         "TCis"

form		"VDquery0",0,0,"-1","-1"

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
    on EX_RESTART      	do erase_hilite 
                    	do wakeup_query( )
					                  	state start
state start
    message_key		VD_M_QrySel 

    on ELSE
        do checkEvent
	    on RETURN_CODE = VD_QRY_CHECK_EVN 		 	state getstring

	do store_query
	    on RETURN_CODE = MSFAIL				state get_query
								state keep_query

state getstring
        mask    "GRm_STRING"
	filter	get_event

	on EX_STRING
             do keyin_query_name

                  on RETURN_CODE = VD_QRY_SUCCESS   
                     do is_query_name_in_list
                       on RETURN_CODE = VD_QRY_ERROR             state terminate
                     do set_locate_eligible( sts )
                     do locelig
                       on RETURN_CODE = MSFAIL
                          do status  "Can not find eligible object "  
                                                                 state terminate
                     state get_dir

                 on RETURN_CODE = VD_QRY_ERROR                   state -
                 on RETURN_CODE = VD_QRY_START_IN_FORM 		 state start
             state start

state get_dir
/*    execute  error_box("get_dir")   */
    prompt_key		VD_P_LocFc
    accept_key		GR_P_Acc
    relocate_key	GR_E_CouNoFndEle
    locate_mask		"GRm_DATA | GRm_OBJID | GRm_RJT_MOVEON |
			 GRm_STRING | GRm_BACK_UP"
    locate_properties	"LC_LC_ONLY | LC_RW | LC_DP_ONLY | LC_REGEX_ON"
    locate_owner	"LC_FLEX_COMP | LC_RIGID_OWNER | LC_RIGID_COMP | 
		         LC_FLEX_OWNER  | LC_REF_OBJECTS" 
    locate_display	"NO_PROJ_ACCEPT_POINT |
			 ALL_WINDOWS | LC_ERASE_ALL" 
/*    locate_display	"ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
			 ALL_WINDOWS | LC_ERASE_ALL" 
*/
    filter		gs_locate 

        
    on EX_BACK_UP
/*        do error_box("get_dir:EX_BACK_UP")  */
	do store_query						state get_query

    on EX_RJT_MOVEON
	      do get_all_elt_in_file				state .

    on  DATA or EX_OBJID         
		do store_event_by_index( sts, 0 )
		do store_locate_context
		do store_event_by_index ( sts, 1 )
		do send_query
	    	  on ERROR
/*		   do status_key	VD_S_NoLocElt		state get_dir */
		   do status_key	VD_S_NoLocElt		state terminate
								state terminate
    on TEXT_VALUE
	do status_key	VD_S_TxtVal
        do store_locate_context
	    on RETURN_CODE = DIR_W_NAME_NOT_FOUND
		do status_key	VD_S_TxtVal			state get_dir
	do store_event_by_index ( sts, 1 )
	do send_query
	    on ERROR
		do status_key	VD_S_NoLocElt			state get_dir
								state terminate

state keep_query
    message_key		VD_M_QrySel 
    prompt		"Select Active Queries From Form"
    filter      	get_event

    on EX_RJT_MOVEON						
               do set_locate_eligible( sts )  
	       do locelig				
                  on RETURN_CODE = MSFAIL                       
                    do status  "Can not find eligible object "  state terminate
         							state get_dir

    on EX_BACK_UP
	do back_up_query()					state .

    on TEXT_VALUE
	do store_query
	    on RETURN_CODE = MSFAIL				state get_query
            do set_locate_eligible( sts )  
	    do locelig				
                  on RETURN_CODE = MSFAIL                       
                    do status  "Can not find eligible object "  state terminate
            do erase_form 0      				state get_dir

    on EX_FORM_FINISHED                                     	state terminate

state get_query
    message_key		VD_M_QrySel 
    prompt		"Select Active Queries From Form"
    filter      	get_event

    on EX_BACK_UP   
	do back_up_query()					state .
 
    on TEXT_VALUE   
	do store_query
	    on RETURN_CODE = MSFAIL                             state get_query
            do set_locate_eligible( sts )  
	    do locelig				
                  on RETURN_CODE = MSFAIL                       
                    do status  "Can not find eligible object "  state terminate
         							state get_dir

    on EX_FORM_FINISHED                                     	state terminate
at wakeup do wakeup_query( )

