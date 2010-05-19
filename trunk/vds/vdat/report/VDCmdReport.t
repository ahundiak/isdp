/* $Id: VDCmdReport.t,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdat/report/VDReportCmd.t
 *
 * Description:
 *		State Table file to process objects.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdReport.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/31  13:47:44  pinnacle
# Moved from vdastree
#
# Revision 1.4  1997/12/05  09:21:30  pinnacle
# Replaced: vdastree/report/VDCmdReport.t for:  by ksundar for vds
#
# Revision 1.3  1997/11/21  14:38:12  pinnacle
# ah
#
# Revision 1.2  1997/11/04  18:00:10  pinnacle
# Replaced: vdastree/report/VDCmdReport.t for:  by v250_int for vds
#
# Revision 1.1  1997/11/04  17:41:50  pinnacle
# Created: vdastree/report/VDCmdReport.t by v250_int for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/23/97	adz		creation date
 *      11/21/97        ah              Minor build fixes
 *      12/30/97        ah              Moved to vdat
 ***************************************************************************/
command_string	VDC_M_GenRep,0,VDGnCmpRep
class		VDCmdReport
super_class	VDS_LOCATE
product_name	"$VDS"
options		"isTC"
command_table	"vds.cmd"
spec_path	"$VDS/spec"
start_state	start

/*-STATE TABLE----------------------------------------------------------------*/

state_table

#include "lcdef.h"
#include "VDmsg.h"
#include "v_cmddef.h"
#include "VDSFilter.h"

state start
	message		"Generate Components Report"
	execute		discard_all_input( &me->ret )
			on ELSE			state main

state main
	execute		createFileForm( &me->ret )
			on ERROR	
				do status_key VD_E_CommTerm
							state terminate
			on ELSE				state KeyInFileName

state KeyInFileName
	prompt_key	VD_S_QryFlName
	filter		get_event

	on GR_UNKNOWN_TYPE.VD_K_FILE_ACCEPTED
		do fileFormDismissed( VD_K_FILE_ACCEPTED )
							state getObjects

	on GR_UNKNOWN_TYPE.VD_K_FILE_CANCELED
		do fileFormDismissed( VD_K_FILE_CANCELED )
							state terminate

	on ELSE						state .

state getObjects
	locate_class		"+VDSroot"
	prompt			"Locate Object(s)"
	accept_key		VD_P_AccRej
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"

	/*
	 * Rigid component will be not located by a fence without the
	 * flag LC_RIGID_COMP_PRISM.
	 */
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			vds_locate

	on EX_DATA or EX_OBJID
		do process_locate( &me->ret )
		  on RETURN_CODE != "VD_K_ACT_SUCCESS"
			do status(" Invalid Locate Process")		state .

		do operation( &me->ret )
		  on RETURN_CODE != "VD_K_ACT_SUCCESS"
			do status( " Invalid Report Processing")	state .

		do discard_all_input( &me->ret )
							state main

		on EX_BACK_UP
			do discard_all_input( &me->ret )  state main

at wakeup	do fileFormOnOffOut( 1 )
at sleep	do fileFormOnOffOut( 0 ) do erase_hilite
at delete	do fileFormOnOffOut( 2 )
/*----------------------------------------------------------------------------*/
