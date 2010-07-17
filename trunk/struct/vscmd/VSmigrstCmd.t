/* $Id: VSmigrstCmd.t,v 1.1.1.1 2001/01/04 21:10:25 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSmigrstCmd.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmigrstCmd.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/10/06  11:16:28  pinnacle
# Created: vscmd/VSmigrstCmd.t by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          creation
 ***************************************************************************/
/*
	I/STRUCT
	"Migrate Stiffeners" command.
*/
command_string	VSC_M_VSMgSt,0,VSMgSt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSmigrstCmd
product_name	"$STRUCT"
form		"VSmigstfnrs.fm",0,0,"-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"

state start
	message_key		VS_M_VSMgSt
	prompt_key 		VS_P_KyInStfNms
	filter			get_event

		on EX_FORM_FINISHED				state terminate

		on GR_UNKNOWN_TYPE.VS_K_GADGET_LOCATED		state locatePart


state locatePart
	prompt_key 		VS_P_IdStfForMig
	accept_key		VS_P_AccRej
	locate_class		"VSstfBeam"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP | GRm_FORM_FINISHED"
	filter			locate

		on EX_BACK_UP					state start

		on EX_FORM_FINISHED				state terminate

		on EX_DATA	do store_stiffener( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
								state start

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
								state .
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
								state start


state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do rmLastLocObjs( 0 )
		do setFormSettings()				state start


at init 	do init_cmd()
		do setFormSettings()
at wakeup	do display_form 0
at sleep	do erase_form	0
at delete	do rmLastLocObjs( 0 )
		do saveFormSettings()
/*----------------------------------------------------------------------------*/
