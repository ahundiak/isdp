/*
	I/STRUCT
*/
class implementation GRcompcurve ;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern OMuword	OPP_GRcompcurve_class_id ;
/*----------------------------------------------------------------------------*/
long VSmakeCompCurve( msg, cvList, cvCount, cvEnv, compEnv, compCv )

long		*msg ;
struct GRid	cvList[] ;
int		cvCount ;
struct GRmd_env *cvEnv ;
struct GRmd_env *compEnv ;
struct GRid	*compCv ; {

	/*
	 * This function is interfaced by macro 'vs$makeCompCurve'.
	 */

	long			sts ;
	int			i ;
	struct GRlc_info	*entries = NULL ;
	long			badCv ;

	compCv->osnum = compEnv->_MD_OS ;
	compCv->objid = NULL_OBJID ;

	/*
	 * Create entry for EMmakecomp.
	 */
	if( !( entries = _MALLOC( cvCount, struct GRlc_info ) ) ) vs$mem_fail();
	for( i=0; i<cvCount; i++ ) {
		entries[i].located_obj = cvList[i] ;
		entries[i].module_info = *cvEnv ;
	}

	/*
	 * Construct composite curve.
	 */
	sts = om$construct( osnum   = compCv->osnum,
			    p_objid = &compCv->objid,
			    classid = OPP_GRcompcurve_class_id ) ;
	__CheckRC( sts, 1, "om$construct", wrapup ) ;

	sts = om$send( msg	= message GRcompcurve.EMmakecomp( msg,
								  compEnv,
								  cvCount,
								  entries,
								  &badCv ),
		       senderid = compCv->objid,
		       targetid = compCv->objid,
		       targetos = compCv->osnum ) ;
	__CheckRC( sts, *msg, "GRcompcurve.EMmakecomp", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !(sts & 1 & *msg) )
			if( !IF_NULL_OBJID( compCv->objid ) )
				vs$bulk_delete( count	= 1,
						grids	= compCv,
						theEnv	= compEnv ) ;

		_FREE( entries ) ;

		return sts ;

} /* VSmakeCompCurve */
/*----------------------------------------------------------------------------*/

end implementation GRcompcurve ;
