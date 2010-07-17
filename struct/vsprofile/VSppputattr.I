/*
	I/STRUCT
*/
class implementation VSproffrplts ;

#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	GRputattr(	long	*msg ;
			char	*attr ) {

	long		sts ;		/* OM return code		*/
	int		i,		/* Loop index			*/
			thkSize ;	/* Size of VLA of thicknesses	*/
	VSxsFrPlsAttr	*a ;		/* Specific attributes		*/

	a = (VSxsFrPlsAttr *) attr ;

	if(    a->plCount  > VS_K_MAX_XSPLATES
	    || a->cnxCount > VS_K_MAX_XSPLATES ) {
		vs$inv_arg() ;
	}

	thkSize = 0 ;
	for( i = 0 ; i < a->plCount ; i++ ) {
		if( !a->thicknesses[i] || !*a->thicknesses[i] )
			vs$inv_arg() ;
		thkSize += 1 + strlen( a->thicknesses[i] ) ;
	}

	if(    om$vla_set_dimension(	varray	= me->plateDefs,
					size	= a->plCount )
	    &  om$vla_set_dimension(	varray	= me->plateCnxs,
	    				size	= a->cnxCount )
	    &  om$vla_set_dimension(	varray	= me->plateThks,
	    				size	= thkSize )
	    & 1 ) {
	    	int	j ;

	    	OM_BLOCK_MOVE(	a->plDefs,
	    			me->plateDefs,
	    			a->plCount   * sizeof( *a->plDefs ) ) ;
	    	OM_BLOCK_MOVE(	a->plCnxs,
	    			me->plateCnxs,
	    			a->cnxCount  * sizeof( *a->plCnxs ) ) ;
	    	for( i = j = 0 ; i < a->plCount ; i++ ) {
	    		__DBGpr_str( "Thk", a->thicknesses[i] ) ;
	    		strcpy( me->plateThks + j, a->thicknesses[i] ) ;
	    		j += 1 + strlen( me->plateThks + j ) ;
	    	}
	} else {
		vs$mem_fail() ;
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		return sts ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#define GRint	IGRint
#define GRchar	IGRchar
#include "GRprims.h"

method NDdelete( struct GRmd_env *md_env) {

	long sts ;

	/*
	 * Go to protected group for name removal.
	 */
#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = VS_Ga_Group, passwd = VS_Ga_Passwd ) ;
#endif

	sts = om$send(	msg	= message ACncpx.NDdelete( md_env ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = "-" ) ;
#endif
	return sts ;

} /* method NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSproffrplts ;

