/* $Id: VRDelPlane.t,v 1.1.1.1 2001/01/04 21:13:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:	vrutil/VRDelPlane.t
 *
 * Description:
 *	
 *	This command has been written to highlight the elements which are going
 *	to be deleted, while deleting a VRplane object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRDelPlane.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  2000/03/15  19:03:48  pinnacle
# added for CR179900493
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/14/2000	Alwin		Creation
 * -------------------------------------------------------------------*/

command_string		"Delete Plane",0,VRDelPlane
class				VRDelPlane
super_class			CEO_LOCATE
product_name		"$ROUTE"
command_table		"route.cmd"
options				"isTC"
start_state			start

/*======================================*/

state_table

#include    "VRmsg.h"
#include 	"VRco.h"
#define	NODYNMEM  1000

state start
	execute 		VRinit( &me->ret )

	message     	"Delete Plane"
	prompt  		"Select Plane to Deleted/Move on to quit"
	accept_key  	VR_P_AccReject
	locate_class	"VRplane"
 	filter			locate

	on EX_DATA or EX_OBJID
	   do VRGetAffectedObjectsList( &me->ret )	
	   on RETURN_CODE = NODYNMEM
		    do status "No Dynamic Memory available" state CleanUp	
	   state ConfirmDelete

	on EX_RJT_MOVEON			state terminate

state ConfirmDelete

	prompt 			"Accept Delete/Reject"
	filter			wfi

	on EX_DATA 
	   do VRDeletePlane( &me->ret )			state CleanUp

/*	on EX_RJT_MOVEON			state CleanUp */

	on ELSE 
		do VRResetDisplay( &me->ret )
		do VRReleaseMemory(&me->ret )
		state -

state CleanUp
	on ELSE
		do VRResetDisplay ( &me->ret )
		do VRReleaseMemory( &me->ret )
		/*state terminate*/
		state start
