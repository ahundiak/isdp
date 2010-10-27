/* $Id: VDgeomi.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp / VDgeomi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgeomi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation VDgeom;

/*
 * HISTORY:
 *
 * ADZ		Sep 6  1994	- Creation Date
 */


#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= VD_I_ObjGeomDrawing ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VDgeom;
