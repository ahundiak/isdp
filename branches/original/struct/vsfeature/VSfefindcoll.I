/*
	I/STRUCT
*/ 
class implementation VSfeature ;

#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSfindCollection( long *msg ; char *name ; struct GRid *coll ) {

	long		sts ;
	int		ACrc ;
	unsigned long	type ;

#define FTO message ACcpx.ACfind_temp_obj( &ACrc, name, coll )

	coll->objid = NULL_OBJID ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
			targetid= my_id ) ;

	if( type & VS_m_SRC_generic ) {
		sts = om$send( msg = FTO, targetid = my_id ) ;

		if( ( sts & 1 ) && ACrc )  { *msg = MSSUCC ; goto wrapup ; }
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

	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
						msg, OM_e_wrt_object, FTO ),
			targetid = my_id ) ;
	if( !( sts & 1 ) || !ACrc ) vs$failure() ;

	wrapup :
		return sts ;

} /* method VSfindCollection */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

