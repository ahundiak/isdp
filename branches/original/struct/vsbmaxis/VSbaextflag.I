/* $Id: VSbaextflag.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbaextflag.I
 *
 * Description: get/put extend flag
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbaextflag.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/02/20  18:24:18  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 *                     Just renamed VS_K_baExtendAxis to make sure I caught everything
 *
 ***************************************************************************/

class implementation VSbeamAxis ;

#include <stdio.h>
#include "vsbmaxisdef.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSputExtendFlag( long	*msg ;
			int	extend ) {

	if( extend ) {
		me->flagAttr |= VS_K_baExtendAxisAH ;
	} else {
		me->flagAttr &= ~VS_K_baExtendAxisAH ;
	}

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSputExtendFlag */
/*----------------------------------------------------------------------------*/
method VSgetExtendFlag( long	*msg ;
			 int	*extend ) {

	if( me->flagAttr & VS_K_baExtendAxisAH ) {
		*extend = TRUE ;
	} else {
		*extend = FALSE ;
	}

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSgetExtendFlag */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;



