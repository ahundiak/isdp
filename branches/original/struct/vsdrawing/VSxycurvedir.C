/* $Id: VSxycurvedir.C,v 1.1.1.1 2001/01/04 21:10:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSxycurvedir.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxycurvedir.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.6  1996/05/08  15:00:30  pinnacle
 * Replaced: vsdrawing/VSxycurvedir.C for:  by svkadamb for struct
 *
 * Revision 1.5  1996/05/07  19:54:48  pinnacle
 * Replaced: vsdrawing/VSxycurvedir.C for:  by svkadamb for struct
 *
 * Revision 1.4  1996/05/07  18:52:14  pinnacle
 * Replaced: vsdrawing/VSxycurvedir.C for:  by svkadamb for struct
 *
 * Revision 1.3  1996/01/31  07:13:36  pinnacle
 * Replaced: vsdrawing/VSxycurvedir.C for:  by svkadamb for struct
 *

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
#include <string.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "igrdp.h"		/* Structs IGR* for display	*/
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "vsdpb.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsarclength.h"
#include "bscveval.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsunwght_p.h"
#include "vsconicprp.h"
#include "vsstrngproto.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
static void VSrmRedundantPntsInPolygon( count, pts, newcount, newpts )

int		count,		/* IN : Number of polygon vertices	*/
		*newcount ;	/* OUT: New number of polygon vertices	*/
IGRpoint	pts[],		/* IN : Polygon vertices		*/
		**newpts ; {	/* OUT: Polygon vertices w/o redundancy	*/

	/*
	 * Remove redundant non-vertices points in a polygon, such as
	 *       A
	 *   ----x-----
	 *   |        |
	 * B x   ------
	 *   |   |
	 *   -----
	 */

	int		i,
			next_i,
			next_next_i,
			rm0 ;
	IGRvector	v,
			w ;
	BSrc		rc ;

	/*
	 * Input points are supposed to be the vertices of a polygon, hence
	 * point #0 is the same as point #count-1.
	 * We copy vertices #1 and #2 at the end so we may loop entirely on
	 * the polygon.
	 */
	*newpts = (IGRpoint *) VSmemdup( pts,
					( count + 2 ) * sizeof( IGRpoint ) ) ;
	VSvccpy( (*newpts)[count+0], pts[1] ) ;
	VSvccpy( (*newpts)[count+1], pts[2] ) ;

	pts = *newpts ;

	*newcount = 0 ; rm0 = FALSE ;

	for( i = 0, next_i = 1, next_next_i = 2 ; i < count ; ) {

		BSmkvec( &rc, v, pts[i     ], pts[next_i     ] ) ;
		BSmkvec( &rc, w, pts[next_i], pts[next_next_i] ) ;

		if( VScolinearVectors( v, w ) ) {
			/*
			 * Skip next_i, next_i becomes next_next_i
			 */
			if( next_i == count - 1 ) rm0 = TRUE ;

			next_i 		= next_next_i ;
			next_next_i	= next_i + 1 ;
		} else {
			VSvccpy( (*newpts)[(*newcount)++], pts[i] ) ;
			i		= next_i ;
			next_i		= i + 1 ;
			next_next_i	= next_i + 1 ;
		}
	}

	if( rm0 ) {
		/*
		 * Since vertex #count-1 was redundant, so is vertex #0.
		 */
		(*newcount)-- ;
		memcpy(	(char *) &pts[0][0],
			(char *) &pts[1][0],
			 *newcount * sizeof( IGRpoint ) ) ;
	}

} /* VSrmRedundantPntsInPolygon */
/*----------------------------------------------------------------------------*/
static int VSisPolygonRegular( nvertices, vertices )

int	 nvertices ;		/* IN : Number of polygon vertices	*/
IGRpoint vertices[] ; {		/* IN : Polygon vertices		*/

	BSrc		rc ;
	int		i,
			k,
			isRegular	= FALSE ;
	IGRpoint	center ;
	IGRvector	v,
			sum ;
	double		rad,
			len ;

	center[0] = center[1] = center[2] = 0. ;

	for( i = 0 ; i < nvertices ; i++ ) {
		for( k = 0 ; k < 3 ; k++ ) {
			center[k] += vertices[i][k] / nvertices ;
		}
	}
	sum[0] = sum[1] = sum[2] = 0. ;

	rad = BSdistptpt( &rc, center, vertices[0] ) ;

	for( i = 0 ; i < nvertices ; i++ ) {
		BSmkvec( &rc, v, center, vertices[i] ) ;
		len = BSlenvec( &rc, v ) ;
		if( !VSzeroDist( fabs( len - rad ) ) ) {
			goto wrapup ;
		}
		BSnorvec( &rc, v ) ;
		for( k = 0 ; k < 3 ; k++ ) {
			sum[k] += v[k] ;
		}
	}

	/*
	 * `sum' is null if regular polygon.
	 */
	isRegular = VSzeroDist( BSlenvec( &rc, sum ) ) ;

	wrapup :
		return isRegular ;

} /* VSisPolygonRegular */
/*----------------------------------------------------------------------------*/
long VSfindDirOfCvInXYPlane( msg, cvGeom, direction, noDir )

long			*msg ;		/* OUT: Completion code		*/
struct IGRbsp_curve	*cvGeom ;	/* IN : Geometry of curve	*/
IGRvector		direction ;	/* OUT: Direction of curve	*/
int			*noDir ; {	/* OUT: TRUE(= no dir)/FALSE	*/

	/*
	 * Given a curve in the xy-plane, this functions finds the global
	 * direction of the curve.
	 * - for curves with n degrees of symmetry with respect to rotation
	 *   (curves, regular polygons), no direction is returned.
	 * - for line segments, it is that of the line.
	 * - for non-regular polygons, it is that of the longest side.
	 * - for other curves, it is guessed using their conic properties.
	 * The direction, if any, is returned as a normalized vector always
	 * pointing toward the "top" (with it y-coordinate positive).
	 */

	*noDir = FALSE ;
	direction[0] = direction[1] = direction[2] = 0 ;

	if( vs$is_curve_linear( msg = msg, curveGeom = cvGeom ) ) {
		double	*p1 = cvGeom->poles + 0,
			*p2 = cvGeom->poles + 3 ;

		if( VSeqPoints( p1, p2 ) ) {
			/*
			 * It's a point.
			 */
			*noDir = TRUE ;
		} else {
			BSmkvec( msg, direction, p1, p2 ) ;
		}

	} else if( 2 == cvGeom->order && cvGeom->phy_closed ) {

		/*
		 * Closed line string: polygon. We take as direction of the
		 * curve that of the longest edge.
		 */
		int		i ;
		IGRpoint	*poles		= (IGRpoint *) cvGeom->poles ;
		int		npoles		= cvGeom->num_poles,
				nvertices ;

		/*
		 * Check if its a regular polygon: the sum of the vectors from
		 * its center to the vertices must be null.
		 * CAUTION! in the polygon the 1st pole and the last are the
		 * same.
		 */
		nvertices = npoles - 1 ;

		*noDir = VSisPolygonRegular( nvertices, poles ) ;

		if( !*noDir ) {
			int		npts,
					j,
					i1		= 0,
					i2		= 0 ;
			IGRpoint	*pts ;
			double		maxDistSq	= 0.,
					distSq ;

			VSrmRedundantPntsInPolygon( npoles, poles, &npts, &pts);

			for( i = 0 ; i < npts ; i++ ) {
				j = i == npts - 1 ? 0 : i + 1 ;
				distSq = BSdistptpts( msg, pts[i], pts[j] ) ;
				if( distSq > maxDistSq ) {
					maxDistSq = distSq ; i1 = i ; i2 = j ;
				}
			}
			BSmkvec( msg, direction, pts[i1], pts[i2] ) ;

			_FREE( pts ) ;
		}

	} else {
		double			r1_r,
					r2,
					tmp,
					t1,
					t2 ;
		IGRpoint		f1_f,
					f2,
					v1,
					v2,
					v3_t1,
					v4_t2,
					center ;
		int			cntype ;

		/*
		 * Check if curve is rotation symmetric.
		 */
		if( cvGeom->phy_closed ) {
			IGRpoint	*pts ;

			if( cvGeom->rational ) {
				pts = _MALLOC( cvGeom->num_poles, IGRpoint ) ;
				BSunwght_p( msg, cvGeom->poles, cvGeom->weights,
						&cvGeom->num_poles,
						(double *) pts ) ;
			} else {
				pts = (IGRpoint *) cvGeom->poles ;
			}

			*noDir = VSisPolygonRegular(
					(int) cvGeom->num_poles - 1,
					pts ) ;

			if( pts && pts != (IGRpoint *) cvGeom->poles ) {
				_FREE( pts ) ;
			}

			if( *noDir ) goto wrapup ;
		}

		VSconicprp(	cvGeom,
				&cntype,
				center,
				&r1_r,
				&r2,
				f1_f,
				f2,
				v1,
				v2,
				v3_t1,
				v4_t2,
				msg ) ;
		if( BSERROR( *msg ) ) {
			*noDir = TRUE ; goto wrapup ;
		}

		switch( cntype ) {
			case BSCELLIPSE		:
				BSmkvec( msg, direction, f2, f1_f ) ;
				break ;

			case BSCPARABOLA	:
				BSmkvec( msg, direction, v1, f1_f ) ;
				 	tmp		=   direction[0] ;
				 	direction[0]	= - direction[1] ;
				 	direction[1]	= tmp ;
				break ;

			case BSCCIRCLE		:
				t1 = 0 ; t2 = 1 ;
				BScveval( cvGeom, t1, 0, (IGRpoint *) v1, msg );
				BScveval( cvGeom, t2, 0, (IGRpoint *) v2, msg );
				if( VSeqPoints( v1, v2 ) ) {
					*noDir = TRUE ;
				} else {
					double	angle,
						len ;

					BSarclength( msg, cvGeom, &t1, &t2, &len ) ;
					angle = len / r1_r ;
					BSmkvec( msg, direction, v1, v2 ) ;
					if( angle > M_PI ) {
						tmp	     =   direction[0] ;
						direction[0] = - direction[1] ;
						direction[1] = tmp ;	
					}
				}
				break ;

			case BSCHYPERBOLA	:
				BSmkvec( msg, direction, v1, f1_f ) ;
				break ;

			default			: *noDir = TRUE ;
		}
	}

	wrapup :
		if( !*noDir ) {
			if( direction[1] < 0 ) VSnegvc( direction, direction ) ;
			BSnorvec( msg, direction ) ;
		}
		*msg = MSSUCC ;

		return 1 ;		

} /* VSfindDirOfCvInXYPlane */
/*----------------------------------------------------------------------------*/
