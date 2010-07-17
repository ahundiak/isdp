/*
	I/STRUCT
*/
class implementation EMSsurface ;

#include <stdlib.h>
#include "growner.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * EF 09/30/94 Execute data reduction.
 */
extern long VDSapplyDataReduction() ;

/*----------------------------------------------------------------------------*/
long VSinfPlaneSfInt( msg, plane, surface, cst, inter )

long			*msg ;
struct GRobj_env	*plane ;
struct GRobj_env	*surface ;
struct GRvg_construct	*cst ;
struct GRid		*inter ; {

	long			sts ;		/* OM return code */
	int			emsRC ;
	struct GRlc_info	sfInfo ;
	struct IGRplane 	planeDef ;
	IGRpoint		point ;
	IGRvector		normal ;
	struct GRid		*interList = NULL ;
	int			count = 0 ;

	inter->objid = NULL_OBJID ;

	planeDef.point	= point ;
	planeDef.normal = normal ;
	sts = om$send(	msg	= message GRvg.GRdetplane(
							msg,
							&plane->_matrix_type,
							plane->_matrix,
							&planeDef ),
			senderid= NULL_OBJID,
			targetid= plane->_objid,
			targetos= plane->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;

	sfInfo.located_obj = surface->_grid ;
	sfInfo.module_info = surface->mod_env ;
	sts = om$send(	msg	= message EMSsurface.EMintplane_notrim(
							cst,
							&planeDef,
							&sfInfo,
							&count,
							&interList,
							&emsRC ),
			senderid= NULL_OBJID,
			targetid= surface->_objid,
			targetos= surface->_osnum ) ;
	*msg = emsRC ;
	__CheckRC( sts, *msg, "EMSsurface.EMintplane_notrim", wrapup ) ;

	if( !count ) {
		*msg = EMS_E_NoIntersection ; sts = OM_W_ABORT ; goto wrapup ;
	}

	/*
	 * EF ( 09/30/94 ).
	 * Execute data reduction. ( Don't check about return code because
	 * the function returns something even if it fails ).
	 */
	{
	struct GRlc_info plInfo ;

	plInfo.located_obj	= plane->obj_id ;
	plInfo.module_info	= plane->mod_env ;

	VDSapplyDataReduction( msg,
			       &sfInfo,
			       &plInfo,
			       cst,
			       count,
			       interList ) ;
	}

	*inter = interList[0] ;

	vs$bulk_delete( grids	= interList+1,
			count	= count - 1,
			theEnv	= cst->env_info ) ;

	_FREE( interList ) ; interList = NULL ;

	wrapup :
		return sts ;

} /* VSinfPlaneSfInt */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;
