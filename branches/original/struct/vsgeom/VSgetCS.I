/*
	I/STRUCT
Abstract
	Given a curve and a surface this function retrieves the corresponding 
	point coordinates on the curve and computes a co-ordinate system.

		 * Reminder:	z - along tangent of trace curve
		 *		y - along normal to surface
		 *		x - cross product of the two above.
		 *		O - point on curve 

	The curve is supposed to be on the surface or on an offset of the 
	surface,
	
	This function is interfaced by macro vs$getCS_from_cv_and_sf.
*/
class implementation GRvg ;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "EMSssprops.h"
#include "EMSmsgdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "vsdpb.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "bscrossp.h"
#include "bscveval.h"
#include "bsnorvec.h"
#include "bsprptonsf.h"
#include "bssfevaln.h"
#include "vsvecmxproto.h"

from EMSsubbs	import	EMget_props ;
/*----------------------------------------------------------------------------*/
long VSgetCS_from_cv_and_sf( 	msg, surface, surfGeom, curve, curveGeom,
				pntParm,
				pntAtX, tanAtX, normAtX, xvecAtX)
long			*msg ;
struct GRobj_env	*surface,
			*curve ;
struct IGRbsp_surface	*surfGeom ;
struct IGRbsp_curve	*curveGeom ;
double			pntParm ;
IGRpoint		pntAtX ;
IGRvector		tanAtX,
			normAtX,
			xvecAtX ; {

/*
 * This function is interfaced by macro vs$getCS_from_cv_and_sf.
 */
	long		sts,		/* OM return code		*/
			bsRC ;		/* BS return code		*/
	struct IGRbsp_curve
			*cvGeom = NULL ;/* Geometry of input curve	*/
	struct IGRbsp_surface
			*sfGeom = NULL ;/* Geometry of input surface	*/
	double		uAtX,		/* U-parm. of section on curve  */
			eval[12] ;	/* Tang. & norm. of curve       */
	int		nb_nrm ;	/* Count of normals on surface  */
	IGRpoint	prjAtX ;	/* Proj. of pntAtX on surface   */
	struct GRparms  locParms,       /* For GRprojpt			*/
			uvAtX ;		/* U,v on surface at section    */
	unsigned char   props ;		/* Surface-specific properties  */

	sts = OM_W_ABORT ;

	/*
	 * Retrieve abstract geometries of curve & surface, if not given.
	 */
	if( !curveGeom ) {
		vs$get_geometry(msg	= msg,
				grobjId	= &curve->_grid,
				grobjEnv= &curve->mod_env,
				geometry= &cvGeom ) ;
		__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
		curveGeom = cvGeom ;
	}
	if( !surfGeom ) {
		/*
		 * Get surface geometry using identity matrix. Why so ? To
		 * avoid the reversal of the normal in case the matrix contains
		 * a mirror :
		 *       ^		|
		 *       |		|
		 * --------------	|      --------------
		 *                 plane of mirror    |
		 *				      v
		 * Because we want the beam to position itself on the mirrored
		 * image as it would on the original.
		 * The geometrical data obtained from the surface (essentially
		 * its normal), is transformed with the surface's matrix
		 * after they have been computed.
		 */
		struct GRmd_env	idEnv,
				*p_env ;
		if( surface->_matrix_type != MAIDMX ) {
			MAidmx( msg, idEnv._MATRIX ) ;
			idEnv._MATRIX_TYPE	= MAIDMX ;
			idEnv._MD_ID		= surface->_md_id ;
			idEnv._MD_OS		= surface->_md_os ;
			p_env			= &idEnv ;
		} else {
			p_env = &surface->mod_env ;
		}

		vs$get_geometry(msg	= msg,
				grobjId	= &surface->_grid,
				grobjEnv= p_env,
				geometry= &sfGeom ) ;
		__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
		surfGeom = sfGeom ;
	}

	/*
	 * Get point parameters on curve and surface.
	 */
	uAtX = pntParm ;

	/*
	 * Compute tangent of curve at parameter.
	 */
	BScveval(       curveGeom,
			uAtX,
			1,	      /* nb of derivatives */
			(IGRpoint *) eval,
			&bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_CurveError ; goto wrapup ; }

	/*
	 * Store and normalize tangent vector at parameter.
	 * Note: "pntAtX[0,1,2]" should be equal to "eval[0,1,2]".
	 */
	VSvccpy( pntAtX, eval ) ;
	BSnorvec( &bsRC, VSvccpy( tanAtX, eval + 3 ) ) ;
	
	/*
	 * Compute UV parameters to get normal to surface.
	 */
	if( !vs$is_surface_planar(	msg	= msg,
					surfGeom= surfGeom ) ) {
		/*
		 * Project point onto surface to get its parameters.
		 */
		sts = om$send(  msg     = message GRvg.GRprojpt(
						msg,
						&surface->_matrix_type,
						surface->_matrix,
						&locParms,
						pntAtX,
						prjAtX,
						&uvAtX ),
				senderid= surface->_objid,
				targetid= surface->_objid,
				targetos= surface->_osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRprojpt", wrapup ) ;
		
	} else {
		uvAtX.u = 0.5 ;
		uvAtX.v = 0.5 ;
	}
	
	/*
	 * Compute normal to surface.
	 */
	BSsfevaln( surfGeom,       	 /* IN  : surface geometry	*/
		   uvAtX.u,	   	 /* IN  : u of evaluation	*/
		   uvAtX.v,	   	 /* IN  : v of evaluation	*/
	           1,		   	 /* IN  : u-left/v-left normal  */
		   &nb_nrm,	   	 /* OUT : actual # of normals	*/
		   prjAtX,	 	 /* OUT : point at u, v		*/
		   (IGRvector *) normAtX,/* OUT : normal at u, v	*/
		   &bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_SurfaceError ; goto wrapup ; }

	if( surface && surface->_matrix_type != MAIDMX ) {
		VSmxprodvc( surface->_matrix, normAtX, normAtX ) ;
	}
			     
	/*
	 * Note : on the contrary of the standard for solid normals, we consider
	 * the normal pointing outside, just in case the support surface is a 
	 * face of a solid so the computed CS is outside of the solid. For
	 * surfaces the CS will be on the side of the opposite of the surface's
	 * natural normal it it hasn't been reversed.
	 */
	sts = om$send(  msg     = message EMSsubbs.EMget_props( msg, &props ),
			senderid = surface->_objid,
			targetid = surface->_objid,
			targetos = surface->_osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

	/*
	 * Note: IN and OUT arguments may be the same in "VSnegvc".
	 */
	if( ! ( props & EMSIS_NRML_REVERSED ) ) {
		VSnegvc( normAtX, normAtX ) ;
	}

	/*
	 * Compute last vector of co-ordinate system. Let's assume that it
	 * defines the x-direction.
	 */
	BSnorvec( &bsRC, normAtX ) ;
	BScrossp( &bsRC, normAtX, tanAtX, xvecAtX ) ;
	BSnorvec( &bsRC, xvecAtX ) ;
	
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup : 
		_FREE( cvGeom ) ;
		_FREE( sfGeom ) ;
		return sts ;

} /* VSgetCS_from_cv_and_sf */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;
