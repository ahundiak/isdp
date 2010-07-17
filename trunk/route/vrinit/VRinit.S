/* $Id: VRinit.S,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinit/VRinit.S
 *
 * Description:
 *	ROUTE startup command
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRinit.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
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
# Revision 1.1  1995/12/06  23:25:44  pinnacle
# Created: vrinit/VRinit.S by r240_int for route240
#
 *
 * History:
 *	12/06/95	tlb 	created to replace VRinit.sl
 *				method Routeexecute renamed execute
 *
 *************************************************************************/

class specification VRinit (1:0) of CEO;
override        init,
                execute;

end specification VRinit;
