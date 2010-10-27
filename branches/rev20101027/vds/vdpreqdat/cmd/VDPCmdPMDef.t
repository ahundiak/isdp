/* I/VDS
 *
 * File:        vdpdefault/cmd/VDPCmdPMDef.t
 *
 * Description:   State table for the setting default PME data.
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *       9/25/95        Mallik          Creation
 *	 9/18/96	msm		Call InitForm directly instead of
 *					CheckDM2Conn
 */

/*
 *	class specification area
 */

command_string		VDC_M_ReqPMDat, 0, VDPRqPMDat
class			VDPCmdPMDef
super_class		VDS_LOCATE
product_name		"$VDS"
command_table		"vds.cmd"
options			"siTC"

form            "VDPreqPMdat",0,0,"-1","-1"

/*
 *	state table area
 */

state_table

#include	"exdef.h"
#include	"VDmsg.h"
#include	"VDCmdDef.h"
#include	"VDSFilter.h"

state start

	message  	"Default AIM Data"
	prompt_key	VD_P_ProcFrm
	display_form	0
	filter		vds_get_event

	on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT or GR_UNKNOWN_TYPE.VD_FORM_CANCEL
	   do erase_form 0
	   state terminate

at init		do VDPInitForm

