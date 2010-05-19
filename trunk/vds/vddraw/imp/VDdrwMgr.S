/* $Id: VDdrwMgr.S,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrwMgr.S
 *
 * Description:
 *      This class controls 
 *		- the drawing-views, containing existing 2d-visualization
 *		  objects. When new objects need to be added an drawing
 *		  assembly, the manager will find the context group, from
 *		  where the original object came from.
 *		  When this is established the resulting 2d visualization
 *		  object will be connected to the VDdrw2dVw assembly object. 
 *		  Objects attached to the VDdrw2dVw defines the set of active
 *		  objects (visible, hidden and transparent).
 *
 *		- modeling-views, containing extsing 3d-visualization objects.
 *		  (See above).
 *
 * Dependencies:
 *	All interact with this object we be done through macros, defined in
 *	the file vddwrmgrmac.h.
 *
 * Revision History:
 *	$Log: VDdrwMgr.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/06/27  18:24:22  pinnacle
# Created: vddraw/imp/VDdrwMgr.S by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

class specification VDdrwMgr(1:0) of GRcmpowner;

instance VDdrwMgr
{
	/*
	 * None.
	 */
};

end specification VDdrwMgr;
