/* $Id: VSjnpreconst.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjnpreconst.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnpreconst.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1998/01/02  11:58:28  pinnacle
# Created: vsjoint/VSjnpreconst.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include <stdlib.h>
#include "nddef.h"
#include "asmacros.h"
#include "vsdata.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern struct GRid	NULL_GRID ;
from VSsharedData	import	VSgetData ;
/*----------------------------------------------------------------------------*/
method	VSpre_construct( struct GRvg_construct	*cl ;
			 struct GRid		newRoots[] ) {

	long			*msg,		/* Completion code	*/
				sts ;		/* OM return code	*/
	struct VScnst_list	*myAttr ;	/* Class attributes	*/
	char			myClass[OM_K_MAXCLASS_LEN] ;
	int			i,		/* Loop-on-parents index*/
				feCnt = 2,	/* count of features	*/
				pCount ;	/* Count of my parents	*/
	struct GRobj_env	*pList ;	/* List of my roots	*/
	VSobjDef		myDef ;		/* My class definition	*/

	msg	= cl->msg ;
	myAttr 	= (struct VScnst_list *) cl->class_attr ;
	pList	= myAttr->parent_list ;
	pCount	= myAttr->parent_count;

	/*
	 * Checks that the count of parents is OK.
	 */
	sts = om$send(	msg	= message VScpx.VSgetObjDef( msg, &myDef ),
			targetid= my_id ) ;

	if( !( pCount >= myDef.minInput && pCount <= myDef.input.count ) ) {
		*msg = MSINARG ; goto wrapup ;
	}
	__DBGpr_int("count of parent", pCount ); 
	*msg = MSFAIL ;
	
	for( i = 0 ; i < pCount ; i++ ) {
		sts = as$make_source(	go_grid	= pList[i]._grid,
					mod_env	= &pList[i].mod_env,
					as_grid	= newRoots + i ) ;
		__CheckRC( sts, 1, "as$make_source", wrapup ) ;
	}
	/*
	 * First connect the feature parents 
	 */
	sts = om$send(	msg	= message NDnode.NDconnect(	feCnt,	
								newRoots,
								NULL_GRID,
								ND_NEW ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDconnect", wrapup ) ;

	if( pCount > 2 ) {

		sts = om$send( msg = message GRvg.GRputattr(	
							msg,
							myAttr->feature_att ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;

		sts = om$send(	msg	= message NDnode.NDconnect(	
								1,
								&newRoots[2],
								NULL_GRID,
								ND_ADD ),
				targetid = my_id );
		__CheckRC( sts, 1, "NDnode.NDconnect", wrapup ) ;
	}

	/*
 	 * Create macro definition with my class name as its name.
 	 */
 	om$get_classname(	classname	= myClass,
 				objid		= my_id ) ;

	sts = om$send(	msg	= message ACcpx.ACattach( (int *) msg,
							  myClass ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "ACcpx.ACattach", wrapup ) ;

	*msg = MSSUCC ;

	wrapup:
		return sts ;

} /* method VSpre_construct */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
