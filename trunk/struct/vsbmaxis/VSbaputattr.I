/* $Id: VSbaputattr.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbaputattr.I
 *
 * Description: get/put attribute byte
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbaputattr.I,v $
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
 *                     Just though I would add a get
 ***************************************************************************/
 
class implementation VSbeamAxis ;

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

/*----------------------------------------------------------------------------*/
/* We can put but can't get, makes alot of sense.
 */
method	VSgetAttr(	long	*msg ;
			int	*attr ) {

	/*
	 * Get instance data.
	 */
	*attr = me->flagAttr; 
	*msg  = MSSUCC ;
	
	return OM_S_SUCCESS ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;

