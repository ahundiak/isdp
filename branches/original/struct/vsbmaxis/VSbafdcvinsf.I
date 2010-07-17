/*
	I/STRUCT
*/
class implementation EMSsubbs ;

#include <stdio.h>
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "vssplitdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsintcvsf.h"
#include "bsdistptpt.h"
/*----------------------------------------------------------------------------*/
long VSfindCurveIntersectingSurfaces( msg, surface1, surface2, nb_curves,
				      curves, env_curves, index )

long			*msg ;
struct GRobj_env	*surface1,
			*surface2 ;
int			nb_curves ;
struct GRid		*curves ;
struct GRmd_env 	*env_curves ;
int			*index ; {

	long	sts,
		bsRC ;
	int	i,
		int_with_s1   = -1,
		int_with_s2   = -1,
		int_with_s1s2 = -1 ;
	double	param,
		point[3],
		ptCv0[3],
		ptCv1[3],
		ptSf1[3],
		ptSf2[3],
		pm[2],
		dstSf1Cv0,
		dstSf1Cv1,
		dstSf2Cv0,
		dstSf2Cv1 ;

	*index = 0 ;

	/*
	 * Find first curve which intersects surface1, first curve which
	 * intersects surface2 and first curve which intersects
	 * surface1 and surface2.
	 */
	for( i=0; i<nb_curves; i++ ) {

		/*
		 * See if curve intersects with surface1.
		 */
		sts = VSintersectCurveAndSurface( msg,
						  &curves[i],
						  env_curves,
						  &surface1->obj_id,
						  &surface1->mod_env,
						  VS_K_CONSASANINFPLANE,
						  point,
						  &param ) ;

		if( *msg != EMS_W_NoSolution ) {
			__CheckRC( sts, *msg, "VSintersectCurveAndSurface",
				   wrapup ) ;
			if( int_with_s1 == -1 ) int_with_s1 = i ;
			int_with_s1s2 = i ;
		}

		/*
		 * See if curve intersects with surface2.
		 */
		sts = VSintersectCurveAndSurface( msg,
						  &curves[i],
						  env_curves,
						  &surface2->obj_id,
						  &surface2->mod_env,
						  VS_K_CONSASANINFPLANE,
						  point,
						  &param ) ;

		if( *msg != EMS_W_NoSolution ) {
			__CheckRC( sts, *msg, "VSintersectCurveAndSurface",
				   wrapup ) ;
			if( int_with_s2 == -1 ) int_with_s2 = i ;
			if( int_with_s1s2 != i ) int_with_s1s2 = -1 ;
		} else int_with_s1s2 = -1 ;

		if( int_with_s1s2 != -1 ) break ;
	}

	/*
	 * Return found curve.
	 */
	if( int_with_s1s2 != -1 ) {
		*index = int_with_s1s2 ;
	} else if( int_with_s1 != -1 ) {
		*index = int_with_s1 ;
	} else if( int_with_s2 != -1 ) {
		*index = int_with_s2 ;
	} else {
		/*
		 * No curves intersect with surface 1 and surface 2. So, find
		 * the curve which is between the two surfaces.
		 */
		pm[0] = pm[1] = 0.5 ;

		sts = om$send( msg	= message EMSsubbs.EMptatpr(
							msg,
							&surface1->_matrix_type,
							surface1->_matrix,
							pm,
							2,
							ptSf1 ),
			       senderid = surface1->_objid,
			       targetid = surface1->_objid,
			       targetos = surface1->_osnum ) ;
		__CheckRC( sts, *msg, "EMSsubbs.EMptatpr", wrapup ) ;

		sts = om$send( msg	= message EMSsubbs.EMptatpr(
							msg,
							&surface2->_matrix_type,
							surface2->_matrix,
							pm,
							2,
							ptSf2 ),
			       senderid = surface2->_objid,
			       targetid = surface2->_objid,
			       targetos = surface2->_osnum ) ;
		__CheckRC( sts, *msg, "EMSsubbs.EMptatpr", wrapup ) ;

		pm[0] = 0. ;
		pm[1] = 1. ;

		for( i=0; i<nb_curves; i++ ) {

			sts = om$send( msg	= message EMSsubbs.EMptatpr(
						      msg,
						      &env_curves->_MATRIX_TYPE,
						      env_curves->_MATRIX,
						      pm,
						      1,
						      ptCv0 ),
				       senderid = curves[i].objid,
				       targetid = curves[i].objid,
				       targetos = curves[i].osnum ) ;
			__CheckRC( sts, *msg, "EMSsubbs.EMptatpr", wrapup ) ;

			sts = om$send( msg	= message EMSsubbs.EMptatpr(
						      msg,
						      &env_curves->_MATRIX_TYPE,
						      env_curves->_MATRIX,
						      pm +1,
						      1,
						      ptCv1 ),
				       senderid = curves[i].objid,
				       targetid = curves[i].objid,
				       targetos = curves[i].osnum ) ;
			__CheckRC( sts, *msg, "EMSsubbs.EMptatpr", wrapup ) ;

			dstSf1Cv0 = BSdistptpt( &bsRC, ptSf1, ptCv0 ) ;
			dstSf1Cv1 = BSdistptpt( &bsRC, ptSf1, ptCv1 ) ;
			dstSf2Cv0 = BSdistptpt( &bsRC, ptSf2, ptCv0 ) ;
			dstSf2Cv1 = BSdistptpt( &bsRC, ptSf2, ptCv1 ) ;

			if( ( dstSf1Cv0 < dstSf1Cv1   &&
			      dstSf2Cv0 > dstSf2Cv1 ) ||
			    ( dstSf1Cv1 < dstSf1Cv0   &&
			      dstSf2Cv1 > dstSf2Cv0 ) ) {

				*index = i ;
				break ;
			}
		}
	}

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSfindCurveIntersectingSurfaces */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
