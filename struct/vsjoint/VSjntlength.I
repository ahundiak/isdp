/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "EMSutlmacros.h"
#include "vsmiscmacros.h"
#include "vsjntmacros.h"
#include "vsiomacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchanobj.h"

from GRcurve	import GRtotlength ;
/*----------------------------------------------------------------------------*/
long VSjointLength( msg, jnId, jnEnv, jnLength )

long		*msg ;
struct GRid	*jnId ;
struct GRmd_env	*jnEnv ;
double		*jnLength ; {

	long		sts ;	/* OM return code	*/
	struct GRid	group,	/* Of graphics		*/
			*cmps ;	/* Components of group	*/
	int		count,	/* Of components	*/
			i ;	/* Loop index		*/
	double		cmpLen;	/* Length of a component*/

	*jnLength = 0 ; cmps = NULL ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, VS_K_jnGrCmpName,
						&group, NULL, NULL ),
			senderid= jnId->objid,
			targetid= jnId->objid,
			targetos= jnId->osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	{
	  OM_S_CHANSELECT toComps ;
	  ems$make_chanselect( chan_label = GRcmpowner_to_components,
			       chan_selector = &toComps ) ;
	  sts = VS_GetChanObjWithMalloc( &group, &toComps, &count, &cmps ) ;
	  if( !( sts & 1 ) ) goto wrapup ;
	}

	for( i = 0 ; i < count ; i++ ) {
		sts = om$send(	msg	= message GRcurve.GRtotlength(
							msg,
							&jnEnv->_MATRIX_TYPE,
							jnEnv->_MATRIX,
							&cmpLen ),
				senderid= jnId->objid,
				targetid= cmps[i].objid,
				targetos= cmps[i].osnum ) ;
		if( sts & 1 & *msg ) *jnLength += cmpLen ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( cmps ) ;
		return sts ;

} /* VSjointLength */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

