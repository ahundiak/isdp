/* $Id: VSbsputattr.I,v 1.1.1.1 2001/01/04 21:10:21 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmsupp/VSbsgetobjdf.I
 *
 * Description: Gets top or bottom of plate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbsputattr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:21  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/02/20  20:26:00  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 02/20/98  ah        Added header
 ***************************************************************************/

class implementation VSbeamSupp ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	GRputattr(	long	*msg ;
			char	*attr ) {

	/*
	 * Set instance data.
	 */
	me->flagAttr 	= *attr ; 
	*msg		= MSSUCC ;
	
	return OM_S_SUCCESS ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/

end implementation VSbeamSupp;

