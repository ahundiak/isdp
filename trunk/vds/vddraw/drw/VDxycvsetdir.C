/*
	I/VDS	Copy
*/
#include <stdio.h>
#include <stdlib.h>
#include <values.h>
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "v_drw.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsarclength.h"
#include "bscveval.h"
#include "v_drwproto.h"
#include "v_vecmxproto.h"
extern double *VD_vccpy(double *toVector,const double *fromVector);

/*----------------------------------------------------------------------------*/
long VD_findDirOfSetOfCurvesInXYPlane( msg, cvCount, cvGeoms, setDir, noDir )

long			*msg ;		/* OUT: Completion code		*/
int			cvCount ;	/* IN : Count of input curves	*/
struct IGRbsp_curve	*cvGeoms[] ;	/* IN : Geoms of input curves	*/
IGRvector		setDir ;	/* OUT: Direction of curves	*/
int			*noDir ; {	/* OUT: TRUE(= no dir)/FALSE	*/

	/*
	 * Finds the direction of a set of curves lying in the xy-plane.
	 * The curve set is first split between "horizontal" and "vertical"
	 * curve, the the respective weight of each subset is computed
	 */
	int		i ;		/* Loop-on-geometries index	*/
	IGRvector	dir,		/* Directions of one curve	*/
			dirH,
			dirV ;
	double *sts_dbl=NULL ;
	double		length,		/* Lengths of one curve		*/
			HtotLen,	/* Tot. length of horizontal cvs*/
			VtotLen,	/* Tot. length of vertical   cvs*/
			HmaxLen,	/* Greatest horiz. curve length	*/
			VmaxLen,	/* Greatest vert. curve length	*/
			t0 = 0.,	/* Sart parameter		*/
			t1 = 1. ;	/* End parameter		*/
	VD_directionType	dType ;		/* Dir. type of one curve 	*/

	if( 1 == cvCount ) {
		return VD_findDirOfCvInXYPlane( msg, cvGeoms[0], setDir, noDir );
	}

	VD_zerovc( setDir ) ;

	HmaxLen = VmaxLen = HtotLen = VtotLen = 0 ;

	for( i = 0 ; i < cvCount ; i++ ) {

		VD_findDirOfCvInXYPlane( msg, cvGeoms[i], dir, noDir ) ;
		if( *noDir ) {
			dir[0] = 1 ; dir[1] = dir[2] = 0 ;
		}
		dType = VD_getDirType( dir ) ;

		BSarclength( msg, cvGeoms[i], &t0, &t1, &length ) ;

		switch( dType ) {
			case VD_horizontal	:
				HtotLen += length ;
				if( HmaxLen < length ) {
					HmaxLen = length ;
					sts_dbl = VD_vccpy( dirH, dir ) ;
				}
				break ;
			case VD_vertical		:
				VtotLen += length ;
				if( VmaxLen < length ) {
					VmaxLen = length ;
					sts_dbl = VD_vccpy( dirV, dir ) ;
				}
				break ;
		}
	}

	if( VD_zeroDist( HtotLen ) || VD_zeroDist( VtotLen ) ) {
		*noDir = TRUE ;
	} else {
		*noDir = FALSE ;	
		if( VtotLen > HtotLen ) {
			sts_dbl = VD_vccpy( setDir, dirV ) ;
		} else {
			sts_dbl = VD_vccpy( setDir, dirH ) ;
		}
	}

	*msg = MSSUCC ;

	return *msg & 1 ;

} /* VD_findDirOfSetOfCurvesInXYPlane */
/*----------------------------------------------------------------------------*/
long VD_findXMostCurve( msg, loc, cvCount, cvGeoms, index )

long			*msg ;		/* OUT: Completion code		*/
VD_drwTxLoc		loc ;		/* IN : Top, bottom, left, right*/
int			cvCount ;	/* IN : Count of input curves	*/
struct IGRbsp_curve	*cvGeoms[] ;	/* IN : Geoms of input curves	*/
int			*index ; {	/* OUT: Index of "X" most curve	*/

	/*
	 * Finds <X>most ( <X> = upper, lower, left, right ) curve among a set
	 * of curves all supposed to lie in the xy-plane.
	 */
	IGRpoint	pnt ;		/* Stroke point			*/
	int		i,		/* Loop-on-curves index		*/
			ixmost = 0,	/* Index of <X>most curve	*/
			j ;		/* Loop-on-points index		*/
	double		t,		/* Parameter on curve		*/
			maxCoord ;

	switch( loc ) {
		default		:
		case VD_top	:
		case VD_right	: maxCoord = - MAXDOUBLE ; break ;
		case VD_bottom	:
		case VD_left	: maxCoord =   MAXDOUBLE ; break ;
	}
	for( i = 0 ; i < cvCount ; i++ ) {
		for( j = 0 ; j <= 100 ; j++ ) {
			t = j * 0.01 ;
			BScveval( cvGeoms[i], t, 0, (IGRpoint *) pnt, msg ) ;
			switch( loc ) {
				default		:
				case VD_top	:
					if( pnt[1] > maxCoord ) {
						maxCoord = pnt[1] ;
						ixmost = i ;
					}
					break ;
				case VD_right	:
					if( pnt[0] > maxCoord ) {
						maxCoord = pnt[0] ;
						ixmost = i ;
					}
					break ;
				case VD_bottom	:
					if( pnt[1] < maxCoord ) {
						maxCoord = pnt[1] ;
						ixmost = i ;
					}
					break ;
				case VD_left	:
					if( pnt[0] < maxCoord ) {
						maxCoord = pnt[0] ;
						ixmost = i ;
					}
					break ;
			}
		}
	}

	*msg = MSSUCC ;
	*index = ixmost ;

	return *msg & 1 ;

} /* VD_findXMostCurve */
/*----------------------------------------------------------------------------*/
long VD_findCenterOfSetOfCurvesInXYPlane( msg, cvCount, cvGeoms, center )

long			*msg ;		/* OUT: Completion code		*/
int			cvCount ;	/* IN : Count of input curves	*/
struct IGRbsp_curve	*cvGeoms[] ;	/* IN : Geoms of input curves	*/
IGRpoint		center ; {	/* OUT: Center of curves	*/

	/*
	 * Finds the center of set of curves all supposed to lie in the 
	 * xy-plane.
	 */
	IGRpoint	pnt ;		/* Stroke point			*/
	int		i,		/* Loop-on-curves index		*/
			j,		/* Loop-on-points index		*/
			k,		/* Loop-on-coordinates index	*/
			n ;		/* Number of points		*/
	double		t ;		/* Parameter on curve		*/

	n = 0 ; VD_zerovc( center ) ;
	for( i = 0 ; i < cvCount ; i++ ) {
		for( j = 0 ; j <= 100 ; j++ ) {
			t = j * 0.01 ;
			BScveval( cvGeoms[i], t, 0, (IGRpoint *) pnt, msg ) ;
			for( k = 0 ; k < 3 ; k++ ) {
				center[k] += pnt[k] ;
			}
			n++ ;
		}
	}
	for( k = 0 ; k < 3 ; k++ ) {
		center[k] /= n ;
	}

	*msg = MSSUCC ;
	return *msg & 1 ;

} /* VD_findCenterOfSetOfCurvesInXYPlane */
/*----------------------------------------------------------------------------*/

