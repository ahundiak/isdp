/* $Id: VDxycurvedir.C,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDxycurvedir.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDxycurvedir.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1995/11/22  23:48:26  pinnacle
 * Replaced: ./vddraw/drw/VDxycurvedir.C for:  by azuurhou for vds.240
 *
 * Revision 1.2  1995/08/23  20:10:00  pinnacle
 * Replaced: vddraw/drw/VDxycurvedir.C for:  by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *					creation date
 ***************************************************************************/

#include <string.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
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
#include "growner.h"
#include "EMSmsgdef.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
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
#include "v_conicprp.h"
#include "v_strngproto.h"
#include "v_vecmxproto.h"
/*----------------------------------------------------------------------------*/
static void VD_rmRedundantPntsInPolygon( count, pts, newcount, newpts )

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
	*newpts = (IGRpoint *) VD_memdup( pts,
					( count + 2 ) * sizeof( IGRpoint ) ) ;
	VD_vccpy( (*newpts)[count+0], pts[1] ) ;
	VD_vccpy( (*newpts)[count+1], pts[2] ) ;

	pts = *newpts ;

	*newcount = 0 ; rm0 = FALSE ;

	for( i = 0, next_i = 1, next_next_i = 2 ; i < count ; ) {

		BSmkvec( &rc, v, pts[i     ], pts[next_i     ] ) ;
		BSmkvec( &rc, w, pts[next_i], pts[next_next_i] ) ;

		if( VD_colinearVectors( v, w ) ) {
			/*
			 * Skip next_i, next_i becomes next_next_i
			 */
			if( next_i == count - 1 ) rm0 = TRUE ;

			next_i 		= next_next_i ;
			next_next_i	= next_i + 1 ;
		} else {
			VD_vccpy( (*newpts)[(*newcount)++], pts[i] ) ;
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

} /* VD_rmRedundantPntsInPolygon */
/*----------------------------------------------------------------------------*/
static int VD_isPolygonRegular( nvertices, vertices )

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
		if( !VD_zeroDist( fabs( len - rad ) ) ) {
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
	isRegular = VD_zeroDist( BSlenvec( &rc, sum ) ) ;

	wrapup :
		return isRegular ;

} /* VD_isPolygonRegular */
/*----------------------------------------------------------------------------*/
long VD_findDirOfCvInXYPlane( msg, cvGeom, direction, noDir )

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

	if( vd_$is_curve_linear( msg = msg, curveGeom = cvGeom ) ) {
		double	*p1 = cvGeom->poles + 0,
			*p2 = cvGeom->poles + 3 ;

		if( VD_eqPoints( p1, p2 ) ) {
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

		*noDir = VD_isPolygonRegular( nvertices, poles ) ;

		if( !*noDir ) {
			int		npts		= 0 ,
					j,
					i1		= 0 ,
					i2		= 0 ;
			IGRpoint	*pts 		= NULL ;
			double		maxDistSq	= 0.,
					distSq ;

			VD_rmRedundantPntsInPolygon( npoles, poles, &npts, &pts);

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
			IGRpoint	*pts = NULL ;

			if( cvGeom->rational ) {
				pts = _MALLOC( cvGeom->num_poles, IGRpoint ) ;
				BSunwght_p( msg, cvGeom->poles, cvGeom->weights,
						&cvGeom->num_poles,
						(double *) pts ) ;
			} else {
				pts = (IGRpoint *) cvGeom->poles ;
			}

			*noDir = VD_isPolygonRegular(
					(int) cvGeom->num_poles - 1,
					pts ) ;

			if( pts && pts != (IGRpoint *) cvGeom->poles ) {
				_FREE( pts ) ;
			}

			if( *noDir ) goto wrapup ;
		}

		VD_conicprp(	cvGeom,
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
				if( VD_eqPoints( v1, v2 ) ) {
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
			if( direction[1] < 0 ) VD_negvc( direction, direction ) ;
			BSnorvec( msg, direction ) ;
		}
		*msg = MSSUCC ;

		return 1 ;		

} /* VD_findDirOfCvInXYPlane */
/*----------------------------------------------------------------------------*/
