/* $Id: VSbpcnst3Drp.I,v 1.3 2001/03/14 00:36:48 jayadev Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsplate/VSbpcnst3Drp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSbpcnst3Drp.I,v $
 *  Revision 1.3  2001/03/14 00:36:48  jayadev
 *  vs$make_boolean_difference args changed
 *
 *  Revision 1.2  2001/01/16 23:59:52  ramarao
 *  *** empty log message ***
 *
# Revision 1.2  2000/12/09  16:49:06  pinnacle
# Replaced: struct/vsplate/VSbpcnst3Drp.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/12/03  18:55:26  pinnacle
# Created: struct/vsplate/VSbpcnst3Drp.I by jpulapar for Service Pack
#
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 *      12/03/00    Jayadev     args change in vs$make_boolean_difference 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSbooPlate ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

extern IGRboolean		ASbroadcast_in_progress ;
/*----------------------------------------------------------------------------*/
method VSconstruct_3D_rep(	long			*msg ;
				int			optrCount ;
				struct GRobj_env	optrList[],
							*operand ;
				struct GRvg_construct	*resCst ;
				struct GRid		*result ) {

	long		sts ;		/* OM return code		*/
	IGRboolean	saveBroadcast ;	/* Save-broadcast flag		*/

	/*
	 * `vs$make_boolean_difference' copies the operators, so save as
	 * broadcast to prevent graph copy.
	 */
	saveBroadcast		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

	sts = vs$make_boolean_difference(	msg		= msg,
						optrCount	= optrCount,
						optrList	= optrList,
						operand		= operand,
						resCst		= resCst,
						compress	= TRUE,
						oneAtATime	= TRUE,
						result		= result,
						refList         = NULL,
						refCount        = 0, 
						range           = NULL) ;
	ASbroadcast_in_progress = saveBroadcast ;

	return sts ;

} /* method VSconstruct_3D_rep */
/*----------------------------------------------------------------------------*/

end implementation VSbooPlate ;

