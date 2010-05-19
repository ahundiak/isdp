/* $Id: VDPCmdRvPmr.t */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdprevpmr/cmd / VDPCmdRvPmr.t
 *
 * Description:
 *      State table for the displaying PME enabled objects
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *      10/23/95        MSM 		Creation
 *
 * -------------------------------------------------------------------*/

command_string		VDC_M_RvPmrWP,0,VDPRvPmrWP
product_name		"$VDS"
class			VDPCmdRvPmr
super_class		VDS_LOCATE
options			"siTC"
command_table		"vds.cmd"
form			"VDPRvPmr",0,0,"-1","-1"

/*------------------------------------
 *	State table area
 */

state_table

#include	"exdef.h"
#include	"VDmsg.h"
#include	"VDCmdDef.h"
#include	"VDSFilter.h"

state start
    message_key			VD_M_RvPmrWP
    prompt_key			VD_P_ProcFrm
    display_form		0

    filter			vds_locate

    on GR_UNKNOWN_TYPE.VD_FORM_CANCEL
	state terminate

    on EX_RJT_MOVEON or EX_RESET			
	state terminate

at init		do my_init

