/* $Id: VRDiFlCmd.t,v 1.3 2001/01/23 16:18:52 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflowco/VRDiFlCmd.t
 *
 * Description:
 *   This file contains the command object needed to display
 *		or undisplay the flow direction
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRDiFlCmd.t,v $
 *	Revision 1.3  2001/01/23 16:18:52  anand
 *	Fixed state start to allow slic to go through without any errors.
 *	
 *	Revision 1.2  2001/01/12 20:43:09  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
#
# Revision 1.1  2000/07/28  16:36:18  pinnacle
# Created: route/vrflowco/VRDiFlCmd.t by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/22  00:24:24  pinnacle
# Replaced: vrflowco/VRDiFlCmd.t for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1995/12/08  21:18:48  pinnacle
# Replaced: vrflowco/VRDiFlCmd.t for:  by r240_int for route240
#
 *
 * History:
	bruno : 	01-Jan-1993   design date
 *	12/06/95	tlb		Remove VRcmd.h
 *	07/28/2000	Alwin		Implemented selection of more than
 *					one element to display the flow 
 *					direction. CR179901347
 *
 *************************************************************************/
command_string       VRC_M_DisFlowDir,0,VRDiFlDr
class                VRflowdir
product_name         "$ROUTE"
command_table	     "route.cmd"
options         "isTC"

/**********************************************************/

state_table

#include "VRmsg.h"

#define	FIN		 2
#define	MULTISELECT	 100

state start
	message_key	VR_M_DisFlowDir
	prompt_key	VR_P_IdComp
	accept_key	VR_P_AccReject
	relocate_key	VR_S_CompNotFound
	dynamics	off
	locate_class	"VRComponent, VRConcComp"
	locate_owner	"LC_RIGID_OWNER|LC_FLEX_COMP|LC_RIGID_COMP"
	filter		locate
 
   on EX_OBJID	
			do VRGetObject ( &me->ret, 1 )
			on ERROR	state .

			on RETURN_CODE = MULTISELECT 	
				state MULTIPLE_DISPLAY

			state . /* Added by Anand to fix compile error */

   on EX_DATA
			do VRGetObject ( &me->ret, 0 )
			do VRGetNextCpt	( &me->ret, 1 )
			state Dis_Dir

/*
 * This would display the flow direction in all the corrections. If the
 * user accepts then leave it as it is and cleanup memory allocated and
 * go to the startup. If user rejects, then erase flow direction, cleanup
 * and go to the startup. CR179901347 Alwin
 */

state MULTIPLE_DISPLAY

   execute VRDisplayFlowDirection( &me->ret, 1 )

   prompt_key		VR_P_DisFlowDir
   dynamics		off
   filter		get_event

   on EX_DATA		do VRCleanUp ( &me->ret ) 	state start

   on EX_RJT_MOVEON or EX_BACK_UP
			do VRDisplayFlowDirection( &me->ret, 0 )
			do VRCleanUp ( &me->ret )	state start

state Dis_Dir

   execute VRDispCptFlowDir( &me->ret, 1, 1 )

	prompt_key	VR_P_DisFlowDir
	dynamics	off
	filter		get_event


   on EX_DATA		do VRGetNextCpt	( &me->ret, 1 )
	      			on RETURN_CODE = FIN	state start
			state .

   on EX_RJT_MOVEON	do VRDispCptFlowDir( &me->ret, 0, 1 )
			do VRGetNextCpt	( &me->ret, 1 )
	      			on RETURN_CODE = FIN	state start
			state .

   on EX_BACK_UP	state start

/******************************************************************************/
