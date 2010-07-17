/* $Id: VRPutQueue.t,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRPutQueue.t
 *
 * Description:
 *	Put in event queue an aabbcc code to a menu event.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPutQueue.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1995/12/08  21:18:36  pinnacle
# Replaced: vrco/VRPutQueue.t for:  by r240_int for route240
#
 *
 * History:
 *	Creation : ADZ (isdc Paris)		25-07-1991
 *	12/06/95	tlb		Remove VRcmd.h
 *
 *************************************************************************/
command_string		VRC_M_PutOnEventQueue,0,VRPutQ
class			CEO_LOCATE
product_name		"$ROUTE"
command_table		"route.cmd"
options         "isTC"


start_state		start
/* ======================================================================== */
state_table


state start

	on ELSE						 state terminate

/* ==== end of file ======================================================= */
