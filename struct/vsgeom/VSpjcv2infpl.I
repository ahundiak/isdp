/*
	I/STRUCT
*/
class implementation GRcurve ;

#include <stdlib.h>
#include "bserr.h"
#include "bstypes.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsprj_cv_pl.h"

extern OMuword		OPP_GRbcsubbc_class_id ;
/*----------------------------------------------------------------------------*/
long VSprjCvOntoInfPlane( msg, cvId, cvEnv, infPlane, vector, cst, prjCv )

long			*msg ;
struct GRid		*cvId ;
struct GRmd_env		*cvEnv ;
struct IGRplane		*infPlane ;
IGRvector		vector ;
struct GRvg_construct	*cst ;
struct GRid		*prjCv ; {

	long			sts ;		/* OM return code	*/
	struct IGRbsp_curve	*cvGeom,	/* Geom of input curve	*/
				*pjGeom ;	/* Geom of prj'd curve	*/
	struct GRvg_construct	locCst ;

	sts = OM_S_SUCCESS ;

	cvGeom = pjGeom = NULL ; prjCv->objid = NULL_OBJID ;

	vs$get_geometry(	msg		= msg,
				grobjId		= cvId,
				grobjEnv	= cvEnv,
				geometry	= &cvGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

        BSalloccv(	cvGeom->order,
			cvGeom->num_poles,
			cvGeom->rational,
			cvGeom->num_boundaries,
			&pjGeom,
			msg ) ;
	if( !BSOKAY( *msg ) ) vs$mem_fail() ;

	if( !vector ) vector = infPlane->normal ;

	BSprj_cv_pl(	msg,
			cvGeom,
			infPlane->point,
			infPlane->normal,
			vector,
			pjGeom ) ;
	if( !BSOKAY( *msg ) ) vs$error( stsval = EMS_E_BSerror ) ;

	vs$fill_cnst_list(	Cnst_list	= locCst,
				Msg		= cst->msg,
				Env_info	= cst->env_info,
				Newflag		= cst->newflag,
				Level		= cst->level,
				Display		= cst->display,
				Geometry	= (char *) pjGeom,
				Properties	= cst->properties ) ;

	prjCv->osnum = locCst.env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_GRbcsubbc_class_id,
				osnum	= prjCv->osnum,
				p_objid	= &prjCv->objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	sts = om$send(	msg	= message GRgraphics.GRconstruct( &locCst ),
			senderid= prjCv->objid,
			targetid= prjCv->objid,
			targetos= prjCv->osnum ) ;
	*msg = *locCst.msg ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= prjCv,
					theEnv	= locCst.env_info ) ;
		}
		if( pjGeom ) { long rc ; BSfreecv( &rc, pjGeom ) ; }
		_FREE( cvGeom ) ;

		return sts ;

} /* VSprjCvOntoInfPlane */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;

