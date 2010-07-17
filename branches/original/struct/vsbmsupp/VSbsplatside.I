/* $Id: VSbsplatside.I,v 1.1.1.1 2001/01/04 21:10:21 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmsupp/VSbsplatside.I
 *
 * Description: Gets top or bottom of plate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbsplatside.I,v $
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
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 *                     See note in construct feet
 ***************************************************************************/

class implementation VSbeamSupp ;

#include <stdio.h>
//#include "vsbmaxisdef.h"
#include "vsbmsuppdef.h"   // CR179800676
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSputPlateSide( long	*msg ;
		       int	whichSide ) {

	SetProc( VSbeamSupp_VSputPlateSide ) ; Begin ; __DBGpr_me() ;

	me->flagAttr |= whichSide ;

	/*
	 * Remove the opposite flag.
	 */
	switch( whichSide ) {
		case VS_K_bsOnTopOfPlate :
			me->flagAttr &= ~VS_K_bsOnBotOfPlate ;
			break ;

		case VS_K_bsOnBotOfPlate :
			me->flagAttr &= ~VS_K_bsOnTopOfPlate ;
			break ;
	}

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSputPlateSide */
/*----------------------------------------------------------------------------*/

end implementation VSbeamSupp ;
