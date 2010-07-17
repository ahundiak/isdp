/* $Id: VSgetsrfdims.I,v 1.1.1.1 2001/01/04 21:10:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsgeom/VSgetsrfdims.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSgetsrfdims.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1996/01/31  08:01:40  pinnacle
# Replaced: vsgeom/VSgetsrfdims.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation EMSsurface ;

#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "msdef.h"
#include "madef.h"
#include "bstypes.h"
#include "growner.h"
#include "emssfdef.h"
#include "EMSmsgdef.h"
#include "EMSsfparms.h"
#include "vspart.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsarclength.h"
#include "bsdistptpt.h"
#include "bslenvec.h"
#include "vsminrctplcv.h"

from EMSsubbs		import EMget_edges ;
from EMSedge		import EMget_bcxyz_geom ;
/*----------------------------------------------------------------------------*/
long VSgetSfDimensions( msg, surfEnv, surfId, width, length )

long			*msg ;
struct GRmd_env		*surfEnv ;
struct GRid		*surfId ;
double			*width,
			*length ; {

/*
 * We try to find out two numbers representing the dimensions of a surface,
 * something analogous to the length and width of a rectangle.
 * This is mainly intended to get the dimensions of a plate.
 * Exotic cases of surfaces are treated (that is for a plate to lie on ... ),
 * but pretty much everything is covered.
 * The two output dimensions are such that *width <= *length.
 * This function is interfaced by macro vs$getSfDimensions.
 */
	long			sts,		/* OM return code	*/
				bsRC ;		/* BS return code	*/
	int			i ;		/* Loop index		*/
	struct EMsurface_params	sfInfo ;	/* Description of surf.	*/
/*
 * Short cuts.
 */
#define PJCT sfInfo.params.project
#define PCYL sfInfo.params.pcyl
#define CYLR sfInfo.params.cyl
#define ECYL sfInfo.params.elpcyl
#define CONE sfInfo.params.cone
#define PCON sfInfo.params.pcone
#define ELCN sfInfo.params.elpcone
#define ELID sfInfo.params.elpsd
#define SPHR sfInfo.params.sphere
#define TRUS sfInfo.params.torus
#define RVLV sfInfo.params.revolve

	double			length1 = 0,
				length2 = 0,
				t0 = 0,
				t1 = 1,
				d[3],
				min ;
	int			imin ;
	unsigned short		sfType ;

	*width = *length = 0 ;

	/*
	 * If the surface is planar, go for the miminum rectangle!
	 */
	if( vs$is_surface_planar(	msg	= msg,
					surfId	= surfId, 
					surfEnv	= surfEnv ) ) {
		struct GRid		compId ;

		compId.objid = NULL_OBJID ;
		sts = VSdrwMakeSfContourCompCurve( msg, surfId, surfEnv,
						   surfEnv, &compId ) ;
		if( sts & 1 & *msg ) {
			IGRpoint A, B, C, D ;
			sts = VSminRectOfPlanarCv( msg, &compId, surfEnv,
						   A, B, C, D,
						   &length1, &length2 ) ;
			vs$bulk_delete( grids = &compId, theEnv = surfEnv ) ;
			if( sts & 1 & *msg ) goto ORDER ;
		}
	}

	/*
	 * This message will succeed with simple surfaces (not composite) and
	 * surfaces with no state tree, eg. a surface with imposed boundaries
	 * constructed with the no-state-tree option or which has been
	 * compressed. If not the method is rejected by those surfaces.
	 */
	sts = om$send(	msg	= message EMSsurface.EMget_params(
						msg,
						NULL,
						surfEnv,
						&sfType,
						&sfInfo ),
			senderid= surfId->objid,
			targetid= surfId->objid,
			targetos= surfId->osnum ) ;
	if( sts == OM_W_REJECTED_METHOD ) {
		sts	= OM_W_ABORT ;
		*msg	= EMS_E_InvalidArg ;
	}
	__CheckRC( sts, *msg, "EMSsurface.EMget_params", wrapup ) ;

	switch( sfType ) {

	/*
	 * Surface of projection
	 * - length1 : length of projection vector
	 * - length2 : length of projected curve.
	 */
	case EMproject	:
		length1 = BSdistptpt(	&bsRC,
					PJCT.axis_point0,
					PJCT.axis_point1 ) ;

		if( vs$is_curve_linear(
				msg		= msg,
				curveGeom	= &PJCT.curve ) ) {
			length2 = BSdistptpt(	&bsRC,
						PJCT.curve.poles + 0,
						PJCT.curve.poles + 3 ) ;
		} else {
			BSarclength( &bsRC, &PJCT.curve, &t0, &t1, &length2 ) ;
		}
		_FREE( PJCT.curve.knots		) ;
		_FREE( PJCT.curve.poles		) ;
		_FREE( PJCT.curve.weights	) ;
		break ;

	/*
	 * Partial cylinder
	 * - length1 : height of cylinder
	 * - length2 : length of basis arc.
	 */
	case EMpcylinder :
		length1 = BSlenvec( &bsRC, PCYL.height ) ;
		length2 = PCYL.radius * PCYL.sweep_angle ;
		break ;

	/*
	 * Cylinder.
	 * - length1 : height of cylinder
	 * - length2 : length of basis circle.
	 */
	case EMcylinder :
		length1 = BSlenvec( &bsRC, CYLR.height ) ;
		length2 = 2 * PI * CYLR.radius ;
		break ;

	/*
	 * Elliptical cylinder.
	 * - length1 : height of cylinder
	 * - length2 : length of basis ellipse.
	 */
	case EMelliptical_cylinder :
		length1 = BSlenvec( &bsRC, ECYL.height ) ;
		length2 = PI * BSlenvec( &bsRC, ECYL.semi_major_axis )
			     * BSlenvec( &bsRC, ECYL.semi_minor_axis ) ;
		break ;

	/*
	 * Cone.
	 * - length1 : slant height height of cone
	 * - length2 : length of biggest basis circle.
	 */
	case EMcone :
		length1 = CONE.slant_height ;
		if( CONE.base_radius < CONE.top_radius )
			length2 = CONE.top_radius ;
		else	length2 = CONE.base_radius;
		length2 *= 2 * PI ;
		break ;

	/*
	 * Partial cone.
	 * - length1 : slant height height of cone
	 * - length2 : length of biggest basis arc.
	 */
	case EMpcone :
		length1 = PCON.slant_height ;
		if( PCON.base_radius < PCON.top_radius )
			length2 = PCON.top_radius ;
		else	length2 = PCON.base_radius;
		length2 *= PCON.sweep_angle ;
		break ;

	/*
	 * Elliptical cone.
	 * - length1 : height height of cone
	 * - length2 : length of biggest basis ellipse.
	 */
	case EMelliptical_cone :
		length1 =  BSlenvec( &bsRC, ELCN.height ) ;
		length2 =   PI
		          * BSlenvec( &bsRC, ELCN.semi_major_axis )
		          * BSlenvec( &bsRC, ELCN.semi_minor_axis )
		          * ELCN.scale ;
		break ;

	/*
	 * Ellipsoid.
	 * - length1 : length of major axis
	 * - length2 : length of max. section circle
	 */
	case EMellipsoid :
		length1 = 2 * BSlenvec( &bsRC, ELID.semi_major_axis ) ;
		length2 = 2 * PI * ELID.radius ;
		break ;
	
	/*
	 * Sphere.
	 * - length1 : radius
	 * - length2 : length of section circle
	 */
	case EMsphere :
		length1 = SPHR.radius ;
		length2 = 2 * PI * SPHR.radius ;
		break ;

	/*
	 * Torus.
	 * - length1 : minor radius
	 * - length2 : length of circle of major radius
	 */
	case EMtorus :
		length1 = TRUS.minor_radius ;
		length2 = 2 * PI * TRUS.major_radius ;
		break ;

	/*
	 * Surface of revolution
	 * - length1 : DONT KNOW (not enough info in structure)
	 * - length2 : length of revolved curve
	 * NOTE: IT SEEMS THAT NO EMS SURFACE, EVEN A surface of revolution
	 * CLAIMS TO BE OF TYPE "EMrevol" ! A SURFACE OF REVOLUTION RETURNS THE
	 * TYPE "EMfreeform_surface".
	 */
	case EMrevol :
		length1 = 0 ;
		BSarclength( &bsRC, &RVLV.curve, &t0, &t1, &length2 ) ;
		_FREE( RVLV.curve.knots		) ;
		_FREE( RVLV.curve.poles		) ;
		_FREE( RVLV.curve.weights	) ;
		break ;

	/*
	 * All the others ...
	 * Take range box and keep the two larges sides of the box !
	 */
	case EMfreeform_surface :

		sts = vs$getSurfaceRange(	msg	= msg,
						surface	= surfId,
						range	= sfInfo.range ) ;
		__CheckRC( sts, *msg, "vs$getSurfaceRange", wrapup ) ;
		
		min = MAXDOUBLE ; imin = 0 ;
		for( i = 0 ; i < 3 ; i++ ) {
			d[i] = fabs( sfInfo.range[i] - sfInfo.range[i+3] ) ;
			if( d[i] < min ) {
				min = d[i] ; imin = i ;
			}
		}

		switch( imin ) {
			case 0 : length1 = d[1] ; length2 = d[2] ; break ;
			case 1 : length1 = d[0] ; length2 = d[2] ; break ;
			case 2 : length1 = d[0] ; length2 = d[1] ; break ;
		}
			
		break ;

	default :
		*msg	= EMS_E_InvalidArg ;
		sts	= OM_W_ABORT ;
		break ;
	}

	/*
	 * Now order lengths.
	 */
	ORDER:
	if( length1 > length2 ) {
		min = length2 ; length2 = length1 ; length1 = min ;
	}

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;
	*width	= length1 ;
	*length	= length2 ;

	wrapup :
		return sts ;

} /* VSgetSfDimensions */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;
