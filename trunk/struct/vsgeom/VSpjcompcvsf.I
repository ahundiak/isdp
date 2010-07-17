/*
	I/STRUCT
*/
class implementation GRcurve ;

#include <stdio.h>
#include <stdlib.h>
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "grmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bsdotp.h"

from EMSsubbs	import EMproject_curve_onto_surface ;

/*----------------------------------------------------------------------------*/
static long VSreverseProjectionIfNeedBe( msg, cvId, cvEnv, pjId, pjEnv )

long		*msg ;
struct GRid	*cvId ;
struct GRmd_env *cvEnv ;
struct GRid	*pjId ;
struct GRmd_env *pjEnv ; {

	long			sts ;	  /* OM completion code.	      */
	BSrc			bsRC ;	  /* BS return code.		      */
	struct IGRbsp_curve	*cvGeom,  /* Geometry of curve. 	      */
				*pjGeom ; /* Geometry of projection.	      */
	double			cvTan[6], /* Tangent of curve at pm = 0.5.    */
				pjTan[6] ;/* Tangent of projection at	      */
					  /* pm = 0.5.			      */

	cvGeom = pjGeom = NULL ;

	/*
	 * Get geometry of curve and its projection.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	sts = vs$get_geometry( msg	= msg,
			       grobjId	= pjId,
			       grobjEnv = pjEnv,
			       geometry = &pjGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Get tangent of curve and its projection at pm = 0.5.
	 */
	BScveval( cvGeom, 0.5, 1, (IGRpoint *) cvTan, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	BScveval( pjGeom, 0.5, 1, (IGRpoint *) pjTan, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	if( BSdotp( &bsRC, cvTan +3, pjTan +3 ) < 0. ) {
		sts = om$send( msg	= message GRcurve.GRrevparm( msg,
								     pjEnv ),
			       senderid = pjId->objid,
			       targetid = pjId->objid,
			       targetos = pjId->osnum ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( cvGeom ) ;
		_FREE( pjGeom ) ;

		return sts ;

} /* VSreverseProjectionIfNeedBe */
/*----------------------------------------------------------------------------*/
long VSprojectCompCurveOntoSurface( msg, compId, compEnv, vector, surfaceId,
				    surfaceEnv, cst, projectId )

long			*msg ;
struct GRid		*compId ;
struct GRmd_env 	*compEnv ;
IGRvector		vector ;
struct GRid		*surfaceId ;
struct GRmd_env 	*surfaceEnv ;
struct GRvg_construct	*cst ;
struct GRid		*projectId ; {

	/*
	 * This function is interfaced by macro 'vs$projectCompCurveOntoSurface'
	 */

	long		 sts,		/* OM completion code.		      */
			 count ;	/* Count of projection of a component */
					/* curve.			      */
	int		 i,		/* Loop index.			      */
			 j,		/* Loop index.			      */
			 cmpCount,	/* Count of component curves of input */
					/* composite curve.		      */
			 pjCount ;	/* Count of projected curves.	      */
	struct GRid	 *cmpList,	/* List of component curves of input  */
					/* composite curve.		      */
			 *pjList ;	/* List of projected curves.	      */
	OM_S_OBJID	 *pjCvs ;	/* Projection of a component curve.   */
	struct GRlc_info cvInfo,	/* Info of curve to project.	      */
			 sfInfo ;	/* Info of surface to project onto.   */
	struct GRprops	 properties ;	/* Geometry properties of input       */
					/* composite curve.		      */

	projectId->objid = NULL_OBJID ;

	cmpCount = pjCount = 0 ;
	cmpList  = pjList  = NULL ;
	count	 = 0 ;
	pjCvs	 = NULL ;

	/*
	 * See if input curve is a composite curve.
	 */
	sts = om$send( msg	= message GRcurve.GRgeomprops(
							 msg,
							 &compEnv->_MATRIX_TYPE,
							 compEnv->_MATRIX,
							 &properties ),
		       senderid = compId->objid,
		       targetid = compId->objid,
		       targetos = compId->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRgeomprops", wrapup ) ;

	if( properties.type != GRCURVE	||
	    properties.subtype != GRCC	) {
		/* Not a composite curve */
		vs$inv_arg() ;
	}

	/*
	 * Get component curves of input composite curve.
	 */
	sts = vs$get_components( msg	    = msg,
				 grobjId    = compId,
				 grobjEnv   = compEnv,
				 number     = &cmpCount,
				 components = &cmpList ) ;
	__CheckRC( sts, *msg, "vs$get_components", wrapup ) ;

	/*
	 * For each component curves, project it onto surface along given
	 * vector. The orientation of a composite curve is the same as the
	 * orientation of its first component. Thus, having the projection
	 * of the composite curve oriented as the original composite curve,
	 * set orientation of first projection like its original component
	 * curve.
	 */
	sfInfo.located_obj = *surfaceId ;
	sfInfo.module_info = *surfaceEnv ;

	cvInfo.module_info = *compEnv ;

	for( i=0; i<cmpCount; i++ ) {
		cvInfo.located_obj = cmpList[i] ;
		sts = om$send( msg	=
				  message EMSsubbs.EMproject_curve_onto_surface(
									&cvInfo,
									&sfInfo,
									cst,
									vector,
									TRUE,
									TRUE,
									&count,
									&pjCvs,
									msg ),
			       senderid = surfaceId->objid,
			       targetid = surfaceId->objid,
			       targetos = surfaceId->osnum ) ;
		__CheckRC( sts, *msg, "EMSsubbs.EMproject_curve_onto_surface",
			   wrapup ) ;

		if( !count ) continue ;

		if( !pjCount ) {
			if( !( pjList = _MALLOC( count, struct GRid ) ) )
				vs$mem_fail() ;
		} else {
			if( !( pjList = _REALLOC( pjList, pjCount + count,
						  struct GRid ) ) )
				vs$mem_fail() ;
		}

		for( j=0; j<count; j++ ) {
			pjList[pjCount+j].objid = pjCvs[j] ;
			pjList[pjCount+j].osnum = cst->env_info->_MD_OS ;
		}

		/*
		 * Set orientation of first projection like its original curve.
		 */
		if( !pjCount ) VSreverseProjectionIfNeedBe( msg,
							    cmpList +i,
							    compEnv,
							    pjList,
							    cst->env_info ) ;
	
		pjCount += count ;

		count = 0 ;
		_FREE( pjCvs ) ; pjCvs = NULL ;
	}

	/*
	 * Make output composite curve.
	 */
	if( pjCount ) {
		sts = vs$makeCompCurve2( msg		= msg,
					 cst		= cst,
					 cvList		= pjList,
					 cvCount	= pjCount,
					 cvEnv		= cst->env_info,
					 compEnv	= cst->env_info,
					 compCv		= projectId ) ;
		__CheckRC( sts, *msg, "VSmakeCompCurveFromProfile", wrapup ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( count	= pjCount,
					grids	= pjList,
					theEnv	= cst->env_info ) ; 
		} 
	

		_FREE( cmpList ) ;
		_FREE( pjList  ) ;
		_FREE( pjCvs   ) ;

		return sts ;

} /* VSprojectCompCurveOntoSurface */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;
