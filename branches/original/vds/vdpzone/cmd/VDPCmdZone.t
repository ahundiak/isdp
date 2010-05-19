/* $Id: VDPCmdZone.t */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpzone/cmd/VDPCmdZone.t
 *
 * Description:
 *      State table for defining a Zone
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *      12/18/95        MSM             Creation
 *	11/11/96	MRA		Added fix for TR#179603640.
 *
 * -------------------------------------------------------------------*/

command_string		VDC_M_PMZone, 0, VDPMngZone
product_name		"$VDS"
class			VDPCmdZone
super_class		VDS_LOCATE
options			"siTC"
command_table		"vds.cmd"

form	"VDPZone1", MAIN,1,"-1","-1"
form	"VDPZone2", SUB ,0,"0","0"

/* ------------------------------------------
 *	State table area
 */

state_table

#include	"exdef.h"
#include	"VDmsg.h"
#include	"VDCmdDef.h"
#include	"VDSFilter.h"

#define		MAIN	0
#define		SUB	1

#define		VD_LOC_SOLID	1000

state start
    message_key		VD_M_MngZone
    prompt_key		VD_P_ProcFrm
    filter		vds_get_event

    on GR_UNKNOWN_TYPE.VD_FORM_CANCEL or GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
	do erase_form MAIN
	do erase_form SUB
	state terminate
    on GR_UNKNOWN_TYPE.VD_LOC_SOLID
			state locate_solid

    on EX_RJT_MOVEON or EX_RESET
	state terminate

state locate_solid
/*    prompt_key 		VD_P_LocSolBk
    relocate_key 	VD_E_SolNtFnd */
    locate_owner	"LC_RIGID_COMP | LC_RIGID_OWNER |
			LC_FLEX_COMP | LC_FLEX_OWNER"
/*    locate_eligible 	"+EMSsolid" */
    mask                "GRm_DATA | GRm_BACK_UP"


    erase_form		SUB 

    filter		vds_locate

    on EX_DATA		
	do store_solid
	    on RETURN_CODE = VD_RESTART_CMD
	    state .

	do display_form SUB 
	state start

    on EX_BACK_UP
	do display_form SUB
	state start

at init		do my_init

