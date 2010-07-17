/* $Id: VRPCComp.S,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRPCComp.S
 *
 * Description:
 *
 * Dependencies:
 *		SUBCLASS OF:    VRConcComp, VRPiping
 *
 * Revision History:
 *	$Log: VRPCComp.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
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
# Revision 1.4  1995/12/17  18:07:00  pinnacle
# Replaced: ./vrprdcmp/VRPCComp.S for:  by azuurhou for route240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/22/90			creation date
 *
 ***************************************************************************/

class specification VRPCComp (0:1) of VRConcComp, VRPiping;

/*--------------------------------------------------------------------------*/
override GRvg;		/* reject GRvg instances */

override ACgive_structure;

override VDgetObjDef;
override VRGetDefName;
override VRGetCatBehavior;

end specification VRPCComp;
