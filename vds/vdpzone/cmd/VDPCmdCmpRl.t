/* $Id: VDPCmdCmpRl.t */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpzone/cmd/VDPCmdCmpRl.t
 *
 * Description:
 *      State table for creating a compartment relation
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *      10/12/95        MSM 		Creation
 *	10/03/96	MSM		Added LC_REF_OBJECTS to locate filter.
 *					TR # 179603235
 *
 * -------------------------------------------------------------------*/

command_string		VDC_M_PsCmpReln,0,VDPPsCmRln
product_name		"$VDS"
class			VDPCmdCmpRl
super_class		VDS_LOCATE
options			"siTC"
command_table		"vds.cmd"

/*------------------------------------
 *	State table area
 */

state_table

#include	"exdef.h"
#include	"VDmsg.h"
#include	"SMmsg.h"
#include	"VDCmdDef.h"
#include	"VDSFilter.h"

state start
    message_key			VD_M_PsCmpReln
    prompt_key			SM_P_LocComp
    accept_key			SM_P_PlAccRej
    locate_class		"SMcomp"
    locate_owner		"LC_RIGID_OWNER | LC_FLEX_COMP |
				 LC_RIGID_COMP | LC_FLEX_OWNER |
				 LC_REF_OBJECTS"

    filter			vds_locate

    on EX_DATA or EX_OBJID
	do locate_comp
	    on RETURN_CODE = VD_RESTART_CMD	state .
	    on RETURN_CODE = VD_ERROR		state terminate

	do prompt ""
	do status "Processing .."

	do post_comp_reln			

	do status ""
	state .

    on EX_RJT_MOVEON or EX_RESET		state terminate

at init		do my_init

