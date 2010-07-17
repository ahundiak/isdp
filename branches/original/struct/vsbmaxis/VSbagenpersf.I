/*
	I/STRUCT

	This method generates a surface of projection perpendicular to
	the parent surface #1. The constructing surface will be moved to
	have the beam axis on middle.

	Arguments :
	-----------

	 OUT	long			*msg	   Completion code.
	 IN	struct GRvg_construct	*cst	   Construction list of surface.
	 IN	double			half_width Half width of surface.
	 OUT	struct GRobj_env	*surface   Surface of projection.
	 OUT	int			*plateSideUsed
						   If TRUE the returned object
						   is a face of the parent
						   plate.

	Notes :
	-------

	 If parent #1 of the beam axis is a curve, the resulting surface
	 is the side of plate where the axis lies, in this case `*plateSideUsed'
	 is TRUE: do not delete this object upon some clean-up process !

	 The constructing surface orientation is the same as the side
	 of plate where the axis is.
*/

class implementation VSbeamAxis ;

#include <stdio.h>
#include "OMmacros.h"
#include "maerr.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
#include "growner.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vsbmaxisdef.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "matrlmx.h"
#include "matypemx.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"

extern OMuword	OPP_EMSproject_class_id ;

from EMSproject import EMplace_surface_of_projection ;
from EMSsurface import EMrevorient ;
/*----------------------------------------------------------------------------*/
method VSgeneratePerpSfToParentSf(
				long			*msg ;
				struct GRvg_construct	*cst ;
				double			half_width ;
				struct GRobj_env	*surface ;
				int			*plateSideUsed ) {

	long			sts,
				bsRC ;
	int			rc,
				cst_type ;
	double			origin[3],
				vecProjection[3],
				transMat[16],
				pm[2],
				middlePoint[3],
				projectPoint[3],
				normalSurf[3],
				normalSide[3],
				dotp ;
	struct GRparms		prjParms ;
	short			transMat_type ;
	struct GRid		ASsup1 ;
	struct GRobj_env	GRsup1,
				side,
				axis ;

	surface->_objid = NULL_OBJID ; *plateSideUsed = FALSE ;

	/*
	 * Retrieve side of plate where beam axis is.
	 */
	sts = om$send( msg	= message VSbeamAxis.VSgetSideSupport( msg,
								       &side ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeamAxis.VSgetSideSupport", wrapup ) ;

	/*
	 * If construction type is 'Projection' ( parent #1 is a curve ),
	 * return as surface the side of plate where axis is.
	 * Otherwise ( construction type is 'Intersection', parent #1 is a
	 * surface ), generate a surface of projection perpendicular to this
	 * surface.
	 */
	sts = om$send( msg	= message VSbeamAxis.VSgetConstructionType(
							msg, &cst_type ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeamAxis.VSgetConstructionType", wrapup ) ;

	if( cst_type == VS_K_baProjection ) {
		*surface	= side ;
		*plateSideUsed	= TRUE ;
		*msg		= MSSUCC ;
		goto wrapup ;
	}

	/*
	 * Retrieve parent #1.
	 */
	sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
					&rc, VS_K_baSurfOrLine, &ASsup1 ),
			targetid= my_id ) ;
	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	sts = VSgetVirtualInfo( msg,
				&ASsup1,
				&GRsup1.mod_env,
				&GRsup1._grid ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	/*
	 * Compute vector of projection which is the vector normal of parent
	 * surface scaled by half_width.
	 */
	sts = vs$get_normal( msg	= msg,
			     sfId	= &GRsup1._grid,
			     sfEnv	= &GRsup1.mod_env,
			     normal	= vecProjection ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	VSscalvc( 2*half_width, vecProjection, vecProjection ) ;

	/*
	 * Get graphics of axis.
	 */
	sts = om$send( msg	= message NDnode.ASreturn_go(
							     &axis._grid,
							     &axis._matrix_type,
							     axis._matrix ),
		       targetid = my_id ) ;
	__CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup ) ;

	/*
	 * Construct surface of projection.
	 */
	origin[0] = origin[1] = origin[2] = 0. ;

	surface->_osnum = cst->env_info->_MD_OS ;

	sts = om$construct( classid = OPP_EMSproject_class_id,
			    osnum   = surface->_osnum,
			    p_objid = &surface->_objid ) ;
	__CheckRC( sts, 1, "om$construct", wrapup ) ;

	surface->mod_env = *cst->env_info ;

	sts = om$send( msg	=
		       message EMSproject.EMplace_surface_of_projection(
							      cst,
							      &axis._grid,
							      &axis.mod_env,
							      NULL,
							      0,
							      origin,
							      vecProjection,
							      FALSE,
							      &surface->_objid),
		       targetid = surface->_objid,
		       targetos = surface->_osnum ) ;
	msg = cst->msg ;
	__CheckRC( sts, *msg, "EMSproject.EMplace_surface_of_projection",
		   wrapup ) ;

	/*
	 * Move surface to have beam axis in the middle of the surface of
	 * projection.
	 *
	 *
	 *	-------------------------
	 *	|			| <- surface of projection.
	 *	|      beam axis	|
	 *	|-----------------------|
	 *	|			|
	 *	|			|
	 *	-------------------------
	 */
	VSscalvc( -0.5, vecProjection, vecProjection ) ;
	MAtrlmx( &bsRC, vecProjection, transMat      ) ;
	MAtypemx( &bsRC, transMat, &transMat_type    ) ;

	sts = om$send( msg	= message GRgraphics.GRxform( msg,
							      cst->env_info,
							      &transMat_type,
							      transMat,
							      &surface->_objid),
		       targetid = surface->_objid,
		       targetos = surface->_osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup ) ;

	/*
	 * If the normal of surface isn't in the same direction as the normal of
	 * side ( at the projection point of the middle point of the surface ),
	 * change orientation of the surface.
	 *
	 * Get middle point of surface generated.
	 */
	pm[0] = pm[1] = 0.5 ;
	sts = om$send( msg	= message GRvg.EMptatpr(
						   msg,
						   &cst->env_info->_MATRIX_TYPE,
						   cst->env_info->_MATRIX,
						   pm,
						   2,
						   middlePoint ),
		       targetid = surface->_objid,
		       targetos = surface->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.EMptatpr", wrapup ) ;

	/*
	 * Project found middle point onto side.
	 */
	sts = om$send( msg	= message GRvg.GRptproject( msg,
							    &side._matrix_type,
							    side._matrix,
							    middlePoint,
							    projectPoint,
							    &prjParms ),
		       targetid = side._objid,
		       targetos = side._osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRptproject", wrapup ) ;

	pm[0] = prjParms.u ;
	pm[1] = prjParms.v ;

	/*
	 * Get normal of surface at midpoint.
	 */
	sts = vs$get_normal( msg	= msg,
			     sfId	= &surface->_grid,
			     sfEnv	= cst->env_info,
			     normal	= normalSurf ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	/*
	 * Get normal of side at project point.
	 */
	sts = vs$get_normal( msg	= msg,
			     sfId	= &side._grid,
			     sfEnv	= &side.mod_env,
			     parm	= pm,
			     normal	= normalSide ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	dotp = BSdotp( msg, normalSurf, normalSide ) ;

	if( BSERROR( *msg ) ) {
		*msg = EMS_E_BSerror ;
		goto wrapup ;
	}

	if( dotp <= 0. ) {
		sts = om$send( msg	= message EMSsurface.EMrevorient( msg ),
			       targetid = surface->_objid,
			       targetos = surface->_osnum ) ;
		__CheckRC( sts, *msg, "EMSsurface.EMrevorient", wrapup ) ;

	}

	*msg = MSSUCC ;

	wrapup :
		if( !(sts & 1 & *msg) ) {
			vs$bulk_delete( count	= 1,
					grids	= &surface->_grid,
					theEnv	= cst->env_info ) ;

			surface->_objid = NULL_OBJID ;
		}

	return sts ;

} /* method VSgeneratePerpSfToParentSf */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;
