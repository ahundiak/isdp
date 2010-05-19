/* $Id: VDPCmdEnab.t */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpenable/cmd / VDPCmdEnab.t
 *
 * Description:
 *      State table for the PME enabling an object
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *      10/12/95        MSM 		Creation
 *      Jan 09 1998	SSR		TR # 179702659
 * 
 * -------------------------------------------------------------------*/

command_string		VDC_M_PMEnableItem,0,VDPEnabItm
product_name		"$VDS"
class			VDPCmdEnab
super_class		VDS_LOCATE
options			"siTC"
command_table		"vds.cmd"

/*------------------------------------
 *	State table area
 */

state_table

#include	"exdef.h"
#include	"VDmsg.h"
#include	"VDCmdDef.h"
#include	"VDSFilter.h"

state start
    message			    "AIM Enable Items"
    prompt_key			VD_P_IdComp
    accept_key			VD_P_AccRej
    locate_properties		"LC_DP_ONLY | LC_LC_ONLY"
    locate_class		"+VDSroot,~SMcomp"
    locate_owner		"LC_RIGID_OWNER | LC_FLEX_COMP |
				 LC_RIGID_COMP | LC_FLEX_OWNER"

    filter			vds_locate

    on EX_OBJID
	do VDPLocateObjects
	    on RETURN_CODE = VD_RESTART_CMD	state .
	    on RETURN_CODE = VD_ERROR		state terminate

	do prompt ""
	do status "Processing .."

	do VDPEnableItems			

	do status ""
	state .
    
    on EX_DATA
       do VDPLocate1Obj
           on RETURN_CODE = VD_ERROR           state terminate
       do prompt " "
       do status " Processing..."

       do VDPEnableItems
       do status ""
       state .

    on EX_RJT_MOVEON or EX_RESET		state terminate

at init		do my_init

