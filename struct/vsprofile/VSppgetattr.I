/*
	I/STRUCT
*/
class implementation VSproffrplts ;

#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	GRgetattr(	long	*msg ;
			char	*attr ) {

	long		sts ;		/* OM return code		*/
	int		i,		/* Loop index			*/
			next ;		/* Index where next thk starts	*/
	VSxsFrPlsAttr	*a ;		/* Specific attributes		*/

	a = (VSxsFrPlsAttr *) attr ;

	a->plCount = om$dimension_of( varray = me->plateDefs	) ;
	a->cnxCount= om$dimension_of( varray = me->plateCnxs	) ;

	if( a->plCount && a->plDefs ) {
	    	OM_BLOCK_MOVE(	/* From */ me->plateDefs,
	    			/* To   */ a->plDefs,
	    			/* Size */ a->plCount * sizeof( *a->plDefs ) ) ;
	}
	if( a->cnxCount && a->plCnxs ) {
	    	OM_BLOCK_MOVE(	/* From */ me->plateCnxs,
	    			/* To   */ a->plCnxs,
	    			/* Size */ a->cnxCount * sizeof( *a->plCnxs ) );
	}

	next = 0 ;
	for( i = 0 ; i < a->plCount ; i++ ) {
		if( !a->thicknesses[i] ) break ;
		strcpy( a->thicknesses[i], me->plateThks + next ) ;
		next += 1 + strlen( a->thicknesses[i] ) ;
	}

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSproffrplts ;

