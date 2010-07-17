/* $Id: VSrtdescfoot.I,v 1.1.1.1 2001/01/04 21:10:31 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vscpx/VDcxdescfoot.I
 *
 * Description:
 *	This method is used to let VDS call the VSdreibeOutput Routine.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSrtdescfoot.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/10/23  21:47:56  pinnacle
# Created: vscpx/VSrtdescfoot.I by s250_int for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/23/97	adz		creation date
 *
 ***************************************************************************/
class implementation VScpx ;

#include <string.h>
/*----------------------------------------------------------------------------*/
method VDdescribeOutput( long *msg ; char *nameOfOutput, *description ) {

	IGRint		sts	= OM_S_SUCCESS ;

	sts =
	om$send( msg     = message VScpx.VSdescribeOutput(
                                     msg, nameOfOutput, description ),
		 targetid = my_id ) ;

	return sts;

} /* method VDdescribeOutput */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
