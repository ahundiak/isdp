/* $Id: VSjnfindcoll.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjnfindcoll.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnfindcoll.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/01/07  14:44:58  pinnacle
# Method spelt wrong
#
# Revision 1.2  1998/01/07  08:32:42  pinnacle
# Replaced: vsjoint/VSjnfindcoll.I for:  by svkadamb for struct
#
# Revision 1.1  1998/01/02  11:40:26  pinnacle
# Created: vsjoint/VSjnfindcoll.I by svkadamb for struct
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *            suresh  creation 
 *  01/07/98  suresh  call modified from VSforwardToSource to
 *		      VSfwdToSource which gets the proper RC.
 *  01/07/98  ah      Changed VSVSfwdToSource to VSfwdToSource
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "vsdatamacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSfindCollection( long *msg ; char *name ; struct GRid *coll ) {

	long		sts ;
	int		ACrc ;
	unsigned long	type ;

#define FTO	message VSjoint.VSgetCollectionId( msg, name, coll )

	SetProc( VSjoint_VSfindCollection ) ; Begin 
	coll->objid = NULL_OBJID ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
			targetid= my_id ) ;

	if( type & VS_m_SRC_generic ) {

		sts = om$send( msg = FTO, targetid = my_id ) ;

		if( ( sts & *msg & 1 ) )  { *msg = MSSUCC ; goto wrapup ; }
	}

	/*
	 * Input collection cannot be found: 1) it may be because I am an output
	 * of a macro occurrence: if so use VSforwardToSource which will rebind
	 * me to the graph of the macro definition and the input collection
	 * may be found there. This is acceptable only because the collection
	 * is static (not a user-defined input of the macro) hence is always
	 * the same (it is the copy of the collection of the object which was
	 * in the original graph used to create the macro definition).
	 * 2) It may also be because I am not a source feature.
	 */

	sts = om$send(	msg	= message VSfeature.VSfwdToSource(
						msg, OM_e_wrt_object, FTO ),
			targetid = my_id ) ;
	if( !( sts & *msg & 1 ) ) vs$failure() ;

	wrapup :
		End 
		return sts ;

} /* method VSfindCollection */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

