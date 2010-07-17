/* $Id: VCSelCable.t,v 1.2 2001/01/11 20:34:06 anand Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:	vccmdutil/VCSelCable.t
 *
 * Description:
 *	
 *	This command has been written to 'Select' the Cables connected/attached
 *	to the Terminal/Guide parent objects. This command can only be invoked
 *	from within a another command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCSelCable.t,v $
 *	Revision 1.2  2001/01/11 20:34:06  anand
 *	SP merge
 *	
# Revision 1.2  2000/04/14  22:42:20  pinnacle
# Replaced: route/vccmdutil/VCSelCable.t for: Replaced ROUTE with SPXR for SP by aharihar for Service Pack
#
# Revision 1.1  2000/04/10  20:50:58  pinnacle
# Created: route/vccmdutil/VCSelCable.t by apazhani for Service Pack
#
# Revision 1.1  2000/04/07  20:06:14  pinnacle
# Added for SPX
#
# Revision 1.2  2000/03/13  16:42:10  pinnacle
# Replaced: vccmdutil/VCSelCable.t for:  by apazhani for route
#
# Revision 1.1  2000/03/10  23:08:10  pinnacle
# Added for CR179800048
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/09/2000	Alwin		Creation
 *	03/13/2000	Alwin		Changed the Product VDS-> ROUTE
 *	Apr 14 2k	Anand		Modified for SP
 * -------------------------------------------------------------------*/

command_string		VCC_M_SelectCables,0,VCSelCable 
/*command_string		"Select Cables",0,VCSelCable */
class			VCSelCable
super_class		CEO_LOCATE
/* product_name		"$SPXR" */
product_name		"$ROUTE"
command_table		"cable.cmd"
options			"isTC"
start_state		start

/*======================================*/

state_table

#include "VCmsg.h"
#include "VCCmdDef.h"

state start
	execute 	VCinit( &me->ret )
	on RETURN_CODE = VC_ERROR
		state terminate

	message_key     VC_M_SelectCables
	prompt  	"Select Guide/Point/Terminal"
	accept_key  	VC_P_AccReject
	locate_class	"+VCTerm,VCGuide,+GRpoint"
	locate_owner   	"VC_LOCATE_ALL"
	filter		locate

	on EX_DATA or EX_OBJID
	   do VCGetCables( &me->ret )	
	   on ERROR
		    do status "Wrong Object located" state terminate	
	   state terminate

/* This state is mainly written to stop the execution of the command. When there
is no other command is on the command stack. Alwin */

state _terminate
	on ELSE
			state terminate

/* This statement is required to check whether any other running or not */
at init	do VCinit( &me->ret )
