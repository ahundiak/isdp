/*
	I/STRUCT
*/ 
class implementation VScpx ;

#include <stdlib.h>
#include "nddef.h"
#include "asmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern struct GRid	NULL_GRID ;
/*----------------------------------------------------------------------------*/
method	VSpre_construct( struct GRvg_construct	*cl ;
			 struct GRid		newRoots[] ) {

	long			*msg,		/* Completion code	*/
				sts ;		/* OM return code	*/
	struct VScnst_list	*myAttr ;	/* Class attributes	*/
	char			myClass[OM_K_MAXCLASS_LEN] ;
	int			i,		/* Loop-on-parents index*/
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
 
	*msg = MSFAIL ;
	
	for( i = 0 ; i < pCount ; i++ ) {

		sts = as$make_source(	go_grid	= pList[i]._grid,
					mod_env	= &pList[i].mod_env,
					as_grid	= newRoots + i ) ;
		__CheckRC( sts, 1, "as$make_source", wrapup ) ;
	}

	sts = om$send(	msg	= message NDnode.NDconnect(	pCount,
								newRoots,
								NULL_GRID,
								ND_NEW ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDconnect", wrapup ) ;

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

end implementation VScpx ;
