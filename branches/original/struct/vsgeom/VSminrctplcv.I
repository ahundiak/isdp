/* $Id: VSminrctplcv.I,v 1.1.1.1 2001/01/04 21:10:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsgeom/VSminrctplcv.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSminrctplcv.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/06  09:16:14  pinnacle
# Replaced: vsgeom/VSminrctplcv.I for:  by svkadamb for struct
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.5  1996/05/07  19:21:40  pinnacle
# Replaced: vsgeom/VSminrctplcv.I for:  by svkadamb for struct
#
# Revision 1.4  1996/05/07  16:16:52  pinnacle
# Replaced: vsgeom/VSminrctplcv.I for:  by svkadamb for struct
#
# Revision 1.3  1996/01/31  08:02:28  pinnacle
# Replaced: vsgeom/VSminrctplcv.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation GRvg ;

#define _INGR_EXTENSIONS
#include <math.h> 
#include <values.h>
#include <stdlib.h>
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "matypemx.h"
#include "bsdistptpt.h"
#include "bslngen.h"
#include "bsmdistcvcv.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "vscreatplncs.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
static double VSminDistLnCv( p1, p2, cv )

const IGRpoint			p1, p2 ;
const struct IGRbsp_curve	*cv ; {

	int			num ;
	double			*par1,
				*par2 ;
	IGRpoint		*pt1,
				*pt2 ;
	long			msg ;
	double			dist ;
	struct IGRbsp_curve	line ;
	double			lnPoles[12],
				lnKnots[6] ;
	int			type ;

	line.poles = lnPoles ;
	line.knots = lnKnots ;

	BSlngen( &msg, (double*) p1, (double*) p2, &line, &type ) ;

	par1	= NULL ;
	par2	= NULL ;
	pt1	= NULL ;
	pt2	= NULL ;
	BSmdistcvcv(	&line,
			(struct IGRbsp_curve*) cv,
			&num,
			&par1,
			&par2,
			&pt1,
			&pt2,
			&dist,
			&msg ) ;
	free( par1 ) ; free( pt1 ) ;
	free( par2 ) ; free( pt2 ) ;

	return dist ;

} /* VSminDistLnCv */
/*----------------------------------------------------------------------------*/
static void VSrefinePlanarCvBox( cv, p0, p1, p2, p3 )

const struct IGRbsp_curve*	cv ;
IGRpoint			p0, p1, p2, p3 ; {

	/*
	 *        + p3
	 *   ->  /  .
	 *   v  /     . 
	 *     /        + p2
	 *    /        /
	 *p0 +  ->    /
	 *     .u    /
	 *       .  /
	 *         + p1
	 */
	IGRvector u ;
	IGRvector v ;
	double	  d ; 
	int	  i ;
	long	  msg ;

	BSmkvec( &msg, u, p0, p1 ) ; BSnorvec( &msg, u ) ;
	BSmkvec( &msg, v, p0, p3 ) ; BSnorvec( &msg, v ) ;

	d = VSminDistLnCv( p0, p1, cv ) ;
	for( i = 0 ; i < 3 ; i = i + 1 ) {
		p0[i] = p0[i] + d * v[i] ;
		p1[i] = p1[i] + d * v[i] ;
	}
	d = VSminDistLnCv( p1, p2, cv ) ;
	for( i = 0 ; i < 3 ; i = i + 1 ) {
		p1[i] = p1[i] - d * u[i] ;
		p2[i] = p2[i] - d * u[i] ;
	}
	d = VSminDistLnCv( p2, p3, cv ) ;
	for( i = 0 ; i < 3 ; i = i + 1 ) {
		p2[i] = p2[i] - d * v[i] ;
		p3[i] = p3[i] - d * v[i] ;
	}
	d = VSminDistLnCv( p3, p0, cv ) ;
	for( i = 0 ; i < 3 ; i = i + 1 ) {
		p3[i] = p3[i] + d * u[i] ;
		p0[i] = p0[i] + d * u[i] ;
	}
	
} /* VSrefinePlanarCvBox */
/*----------------------------------------------------------------------------*/
long VSminRectOfPlanarCv( msg, cvId, cvEnv, A, B, C, D, width, height )

long			*msg ;
const struct GRid	*cvId ;
const struct GRmd_env	*cvEnv ;
IGRpoint		A, B, C, D ;
double			*width, *height ; {
	/*
	 * NOTE: the input curve is supposed to be planar.
	 */
	long		sts ;
	GRrange		cvRange ;	/* Range of curve		*/
	struct IGRplane	cvPlane ;	/* Plane of curve		*/
	IGRvector	plNormal ;	/* Normal to plane of curve	*/
	IGRpoint	plPoint ;	/* Point on plane of curve	*/
	IGRmatrix	w2l,		/* Matrix world -> plane CS	*/
			l2w,		/* Matrix plane CS -> world	*/
			rot ;
	short		mxType ;
	int		i ;		/* Loop index			*/
	BSrc		rc ;		/* Return Code for BS functionalaty */

	cvPlane.normal	= plNormal ;
	cvPlane.point	= plPoint ;

	sts = om$send(	msg	= message GRvg.GRdetplane(
						msg,
						(short *)&cvEnv->_MATRIX_TYPE,
						(double *)cvEnv->_MATRIX,
						&cvPlane ),
			senderid= cvId->objid,
			targetid= cvId->objid,
			targetos= cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;

	/*
         * Create system of axes x, y and z = plNormal, local to the curve's
	 * plane: l2w = local-to-world, w2l = world-to-local.
	 */
	VScreatePlaneCS( &cvPlane, l2w, w2l ) ;

	{
	  IGRmatrix	xform ;
	  double	t ;
	  double	t0 ;
	  double	t1 ;
	  double	bestT = 0 ;
	  int		bestI = 0 ;
	  double	delta ;
	  double	minArea ;
	  double	area ;
	  IGRboolean	world = TRUE ;	/* For GRgetrang		*/
	  double	a0, a1 ;
#define MAX 99
	  double	a[99] ;
	  double	areaTol ;

	  MAidmx( msg, rot ) ;

	  /*
	   * Hunt for good angle to start at...
	   */
	  t	  = 0 ;
	  delta	  = (M_PI/2.0) / ( MAX + 1. ) ;
	  minArea = MAXDOUBLE ;

	  for( i = 0 ; i < MAX ; i++ ) {
	  	rot[0] = cos( t ) ; rot[4] = sin( t ) ;
	  	rot[1] = -rot[4]  ; rot[5] = rot[0] ;

	  	VSmulmx( rot, w2l, xform, &mxType ) ;

		sts = om$send( msg = message GRvg.GRgetrang(
						msg, &mxType, xform, &world,
						cvRange ),
				senderid= NULL_OBJID,
				targetid= cvId->objid,
				targetos= cvId->osnum ) ;
		area = (cvRange[3] - cvRange[0]) * (cvRange[4] - cvRange[1]) ;
		a[i] = area ;
		if( area < minArea ) {
			minArea	= area ; bestT = t ; bestI = i ;
		}
		t += delta ;
	  }


	  /*
	   * Now refine process...
	   */
	  t0 = bestT - delta ;
	  t1 = bestT + delta ;
	  a0 = bestI > 0     ? a[bestI-1] : a[MAX-1] ;
	  a1 = bestI < MAX-1 ? a[bestI+1] : a[0    ] ;
	  BSEXTRACTPAR( &rc, BSTOLLENVEC, areaTol ) ;

	  while( TRUE ) {
	  	t = 0.5 * ( t0 + t1 ) ;

	  	/*
	  	 * Create a rotation of t around the origin, in the plane.
	  	 */
	  	rot[0] = cos( t ) ; rot[4] = sin( t ) ;
	  	rot[1] = -rot[4]  ; rot[5] = rot[0] ;

	  	/*
	  	 * Rotate curve around z in its plane, then compute its
	  	 * range in this plane.
	  	 */
	  	VSmulmx( rot, w2l, xform, &mxType ) ;

		sts = om$send( msg = message GRvg.GRgetrang(
						msg, &mxType, xform, &world,
						cvRange ),
				senderid= NULL_OBJID,
				targetid= cvId->objid,
				targetos= cvId->osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetrang", wrapup ) ;

		area = (cvRange[3] - cvRange[0]) * (cvRange[4] - cvRange[1]) ; 

		     if( area < a0 )	{ a0 = area ; t0 = t ; }
		else if( area < a1 )	{ a1 = area ; t1 = t ; }
		else if( a0   > a1 )	{ a0 = area ; t0 = t ; }
		else			{ a1 = area ; t1 = t ; }

		if( fabs( a0 - a1 ) < BSTOLSQLENVEC ) break ;
	  }
	} /* while */

	__DBGpr_dbl( "1st a",(cvRange[3] - cvRange[0])*(cvRange[4] - cvRange[1]));

	/*
	 * Inverse the rotation matrix (just need to touch 2 elements).
	 */
	rot[4] = -rot[4] ;
	rot[1] = -rot[1] ;

	/*
	 * Rotate range box by -t to make it coincide with the
	 * original curve. Note that all z's are 0 in this plane.
	 */
	{ IGRpoint p0, p1, p2, p3 ; /* Corner of range box of rotated cv */
	  IGRpoint P0, P1, P2, P3 ; /* Corner of rotated-back range box  */

	  struct IGRbsp_curve *cvGeom = NULL ;
 
	  for( i = 0 ; i < 2 ; i++ ) {
		p0[i] = cvRange[0+i] ;
		p2[i] = cvRange[3+i] ;
	  }

	  p1[0] = p2[0] ; p1[1] = p0[1] ;
	  p3[0] = p0[0] ; p3[1] = p2[1] ;

	  P0[0] = rot[0] * p0[0] + rot[1] * p0[1] ;
	  P0[1] = rot[4] * p0[0] + rot[5] * p0[1] ;
	  P0[2] = 0 ;
		
	  P1[0] = rot[0] * p1[0] + rot[1] * p1[1] ;
	  P1[1] = rot[4] * p1[0] + rot[5] * p1[1] ;
	  P1[2] = 0 ;

	  P2[0] = rot[0] * p2[0] + rot[1] * p2[1] ;
	  P2[1] = rot[4] * p2[0] + rot[5] * p2[1] ;
	  P2[2] = 0 ;

	  P3[0] = rot[0] * p3[0] + rot[1] * p3[1] ;
	  P3[1] = rot[4] * p3[0] + rot[5] * p3[1] ;
	  P3[2] = 0 ;

	  /*
	   * Range boxes usually do not touch the curve, so move the edges
	   * until they do.
	   */
	  sts = vs$get_geometry(	msg	= msg,
					grobjId = cvId,
					grobjEnv= cvEnv,
					geometry= &cvGeom ) ;
	  __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	  MAtypemx( msg, w2l, &mxType ) ;
	  vs$xform_curve(	msg		= msg,
	  			mxType		= mxType,
	  			transMx		= w2l,
	  			curveGeom	= cvGeom ) ;
	  VSrefinePlanarCvBox( cvGeom, P0, P1, P2, P3 ) ;
	  _FREE( cvGeom ) ;

	  /*
	   * Back to world coordinates.
	   */
	  VSmxprodpt( l2w, P0, A ) ;
	  VSmxprodpt( l2w, P1, B ) ;
	  VSmxprodpt( l2w, P2, C ) ;
	  VSmxprodpt( l2w, P3, D ) ;

	  *width  = BSdistptpt( &rc, P0, P1 ) ;

	  *height = BSdistptpt( &rc, P1, P2 ) ;

	  __DBGpr_dbl( "Area", *height * *width ) ;

	}

	wrapup :
		return sts ;

} /* VSminRectOfPlanarCv */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

