/*
	I/VDS	Copy
*/
class implementation VDSroot ;

#include <math.h>
#include <float.h>		/* For "DBL_MAX"	*/
#include "bstypes.h"
#include "bsconic.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maptplpro.h"
#include "bsalloccv.h"
#include "bsarclength.h"
#include "bsbdlnplint.h"
#include "bscrossp.h"
#include "bscveval.h"
#include "bscvxttpt.h"
#include "bsdistptpl.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bsfreecv.h"
#include "bslenvec.h"
#include "bslngen.h"
#include "bslnxttpt.h"
#include "bsprepcirc.h"
#include "bsprptoncv.h"
#include "bspl_cv_int.h"
#include "bsrdcencrcv.h"
#include "bsmerge_cv.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bssfnormal.h"
#include "v_spcvkp1res.h"
#include "v_vecmxproto.h"
/*----------------------------------------------------------------------------*/
static void VD_farthestAndClosestPoint( testPnt, pntArray, count,
					iClosest, iFarthest )

IGRpoint	testPnt ;
double		pntArray[] ;
int		count,
		*iClosest,
		*iFarthest ; {

	long	msg ;
	int	i ;		/* Loop index			*/
	double	D2,		/* SQUARED distance		*/
		minD2,		/* Minimum SQUARED distance	*/
		maxD2 ;		/* Maximum SQUARED distance	*/

	minD2 = DBL_MAX ; maxD2 = 0. ; *iClosest = *iFarthest = 0 ;

	for( i = 0 ; i < count ; i++ ) {
		D2 = BSdistptpts( &msg, testPnt, pntArray + i * 3 ) ;
		if( D2 > maxD2 ) {
			maxD2		= D2 ;
			*iFarthest	= i ;
		}
		if( D2 < minD2 ) {
			minD2		= D2 ;
			*iClosest	= i ;
		}
	}

} /* VD_farthestAndClosestPoint */
/*----------------------------------------------------------------------------*/
static double VD_getCircleArcLength( msg, circle, frPt, toPt )

long			*msg ;
struct IGRbsp_curve	*circle ;
IGRpoint		frPt,
			toPt ; {

	IGRboolean	onCurve ;
	double		t1,
			t2,
			tfr,
			tto,
			length ;

	BSprptoncv( msg, circle, frPt, &t1, &onCurve ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	BSprptoncv( msg, circle, toPt, &t2, &onCurve ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	/*
	 * Order parameters for BSarclength.
	 */
	if( t1 < t2 )	{ tfr = t1 ; tto = t2 ; }
	else		{ tfr = t2 ; tto = t1 ;	}

	BSarclength( msg, circle, &tfr, &tto, &length ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	*msg = MSSUCC ;

	wrapup :
		return length ;
	
} /* VD_getCircleArcLength */
/*----------------------------------------------------------------------------*/
static long VD_findLongestArc( msg, center, normal, pnt1, pnt2, planeGeom,
				moreLength, extPnt )

long			*msg ;
IGRpoint		center,
			pnt1,
			pnt2 ;
IGRvector		normal ;
struct IGRbsp_surface	*planeGeom ;
double			moreLength ;
IGRpoint		extPnt ; {

	/*
	 * Given two circles with the same center and normal defined by
	 * - center, normal, pnt1
	 * - center, normal, pnt2
	 * and given a plane, finds the circle which has the longest arc
	 * from the input point (pnt1 or pnt2) to its first intersection to
	 * the input plane.
	 */

	long			sts ;
	double			rad1,	/* Radius of first circle	*/
				rad2,	/* Radius of second circle	*/
				L1,	/* Length of first arc		*/
				L2 ;	/* Length of second arc		*/
	struct IGRbsp_curve     C1,	/* Geometry of first circle	*/
				C2 ;	/* Geometry of second circle	*/
	/*
	 * Memory for poles, weights and knots of the first and second
	 * circles.
	 */
	double		P1[BSCIRCLE_NUM_POLES_MAX*3],
			P2[BSCIRCLE_NUM_POLES_MAX*3],
			W1[BSCIRCLE_NUM_POLES_MAX],
			W2[BSCIRCLE_NUM_POLES_MAX],
			K1[BSCIRCLE_NUM_KNOTS_MAX*3],
			K2[BSCIRCLE_NUM_KNOTS_MAX*3] ;
	int		type,
			iClosest1,	/* Closest intersec. pnt for C1	*/
			iClosest2 ;	/* Closest intersec. pnt for C2	*/
	IGRvector	unormal,	/* Unitary normal to circle	*/
			plNormal ;	/* Normal to input plane	*/
	IGRpoint	plPoint ;	/* Pont on input plane		*/
	/*
	 * Intersection args.
	 */
	double			a[BSCIRCLE_NUM_POLES_MAX],
				b[BSCIRCLE_NUM_POLES_MAX],
				u[BSCIRCLE_NUM_POLES_MAX],
				int1[BSCIRCLE_NUM_POLES_MAX*3],
				int2[BSCIRCLE_NUM_POLES_MAX*3] ;
	int			nint1,
				nint2,
				nseg,
				whichCirc ;

	sts = OM_W_ABORT ;

	C1.num_poles	= BSCIRCLE_NUM_POLES_MAX ;
	C1.poles	= P1 ;
	C1.weights	= W1 ;
	C1.knots	= K1 ;

	C2.num_poles	= BSCIRCLE_NUM_POLES_MAX ;
	C2.poles	= P2 ;
	C2.weights	= W2 ;
	C2.knots	= K2 ;

	rad1 = BSdistptpt( msg, center, pnt1 ) ;
	rad2 = BSdistptpt( msg, center, pnt2 ) ;

	BSprepcirc( msg, center, &rad1, normal, &C1, unormal, &type ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	BSprepcirc( msg, center, &rad2, normal, &C2, unormal, &type ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	/*
	 * Get normal to plane.
	 */
	BSsfnormal( planeGeom, plNormal, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	VD_vccpy( plPoint, planeGeom->poles ) ;

	/*
	 * Now intersect circles with plane.
	 */
	BSpl_cv_int( msg, &C1, plPoint, plNormal,
		     &nint1, int1, u, &nseg, a, b ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_Intersect ; goto wrapup ; }

	BSpl_cv_int( msg, &C2, plPoint, plNormal,
		     &nint2, int2, u, &nseg, a, b ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_Intersect ; goto wrapup ; }

	if( nint1 < 1 || nint2 < 1 ) {
		*msg = EMS_E_NoIntersection ; goto wrapup ;
	}

	/*
	 * Find closest intersection point for both circles, that with the
	 * smaller arc length.
	 */
	L1 = VD_getCircleArcLength( msg, &C1, pnt1, int1 + 0 ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	iClosest1 = 0 ;

	if( nint1 == 2 ) {
		int	l ;

		l = VD_getCircleArcLength( msg, &C1, pnt1, int1 + 3 ) ;
		if( !( *msg & 1 ) ) goto wrapup ;

		if( L1 > l ) { L1 = l ; iClosest1 = 1 ; }
	}
		
	L2 = VD_getCircleArcLength( msg, &C2, pnt2, int2 + 0 ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	iClosest2 = 0 ;

	if( nint2 == 2 ) {
		int	l ;

		l = VD_getCircleArcLength( msg, &C2, pnt2, int2 + 3 ) ;
		if( !( *msg & 1 ) ) goto wrapup ;

		if( L2 > l ) { L2 = l ; iClosest2 = 1 ; }
	}

	/*
	 * Now keep point giving arc of largest length.
	 */
	if( L1 > L2 ) {
		VD_vccpy( extPnt, int1 + iClosest1 * 3 ) ;
		whichCirc = 1 ;
	} else {
		VD_vccpy( extPnt, int2 + iClosest2 * 3 ) ;
		whichCirc = 2 ;
	}

	if( moreLength > 0. ) {
		/*
		 * An extra length is desired to make sure that the beam
		 * constructed on the extension will penetrate the plane.
		 */
		IGRvector	U, V, W ;
		double		length, rad, *pt, alpha, Cos, Sin ;
		int		i ;

		if( whichCirc == 1 ) {
			length	= L1 ;
			rad	= rad1 ;
			pt	= pnt1 ;
		} else {
			length	= L2 ;
			rad	= rad2 ;
			pt	= pnt2 ;
		}
		BSmkvec( msg, U, center, pt	  ) ;
		BSmkvec( msg, V, center, extPnt ) ;
		BScrossp( msg, U, V, W ) ;
		BScrossp( msg, W, U, V ) ;
		BSnorvec( msg, U ) ;
		BSnorvec( msg, V ) ;

		alpha = length * ( 1 + moreLength ) / rad ;

		Cos = cos( alpha ) ;
		Sin = sin( alpha ) ;
		for( i = 0 ; i < 3 ; i++ ) {
			extPnt[i] = center[i] + rad * ( Cos * U[i] + Sin * V[i] ) ;
		}
	}
	  
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VD_findLongestArc */
/*----------------------------------------------------------------------------*/
static long VD_circExtOfCurve( msg, curveGeom, endPoint, whichEnd, extPoint,
				portionOnly, p_extGeom )

long			*msg ;
IGRpoint		endPoint,	/* End pnt where to extend	*/
			extPoint ;	/* Extension point		*/
int			whichEnd,	/* Which end (0 or 1)		*/
			portionOnly ;	/* Only return ext'd portion ?	*/
struct IGRbsp_curve	*curveGeom,
			**p_extGeom ; {

	long			sts = OM_W_ABORT,
				rc ;
	struct IGRbsp_curve	*newCurve,
				*extGeom ;
	int			order,
				nPoles ;

	*p_extGeom = extGeom = newCurve = NULL ;

	/*
	 * See the header of `BScvxttpt' for the following memory allocation.
	 */
	if( curveGeom->order < 3 ) {
		order	= 3 ;
		nPoles	=  7
			 + curveGeom->num_poles
			 + (   ( curveGeom->num_poles - curveGeom->order + 2 )
			     * ( 3 - curveGeom->order ) ) ;
	} else if( curveGeom->order > 3 ) {
		order	= curveGeom->order ;
		nPoles	=   curveGeom->num_poles
			  + 7
			  + ( 6 * ( curveGeom->order - 3 ) ) ;
	} else /* curveGeom->order = 3 */ {
		order	= curveGeom->order ;
		nPoles	= curveGeom->num_poles + 7 - 1 ;
	}

	BSalloccv(	order,
			nPoles,
			TRUE,		/* Result will be rational	*/
			0,
			&newCurve,
			msg ) ;
	if( BSERROR( *msg ) ) {
		*msg = EMS_E_NoDynamicMemory ; sts = OM_E_NODYNMEM ;
		goto wrapup ;
	}
	newCurve->num_poles	= nPoles ;
	newCurve->order		= order ;
	newCurve->num_knots	= nPoles + order ;
	newCurve->rational	= TRUE ;

	BScvxttpt( msg, curveGeom, endPoint, extPoint, newCurve ) ;
	if( BSERROR( *msg ) ) {
		*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
	}

	if( portionOnly ) {
		/*
		 * Now split at `endPoint' to only keep extension portion.
		 */
		sts = VD_splitCvKeepOneResult(	msg,
						newCurve,
						endPoint,
						whichEnd,
						&extGeom ) ;
		__CheckRC( sts, *msg, "VD_splitCvKeepOneResult", wrapup ) ;
	} else {
		extGeom = newCurve ;
	}

	*p_extGeom = extGeom ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		if( newCurve && portionOnly ) BSfreecv( &rc, newCurve ) ;

		return sts ;

} /* VD_circExtOfCurve */
/*----------------------------------------------------------------------------*/
long VD_allocForBSmerge_cv( msg, cv1, cv2, mcv )

long			*msg ;
struct IGRbsp_curve	*cv1,
			*cv2,
			**mcv ; {

	long	sts ;
	int	o1	= cv1->order,
		o2	= cv2->order,
		om,
		np1	= cv1->num_poles,
		np2	= cv2->num_poles,
		npm ;

	if( o1 == o2 ) {
		om	= o1 ;
		npm	= np1 + np2 - 1 ;
	} else if( o1 > o2 ) {
		om	= o1 ;
		npm	= np1 + np2 + ( ( np2 - o2 + 2 ) * ( o1 - o2 ) ) ;
	} else /* o1 < o2 */ {
		om	= o2 ;
		npm	= np2 + np1 + ( ( np1 - o1 + 2 ) * ( o2 - o1 ) ) ;
	}

	BSalloccv(	om,
			npm,
			TRUE,		/* Result will be rational	*/
			0,
			mcv,
			msg ) ;

	if( BSERROR( *msg ) ) {
		*mcv = NULL ;
		*msg = EMS_E_NoDynamicMemory ; sts = OM_E_NODYNMEM ;
	} else {
		*msg = MSSUCC ; sts = OM_S_SUCCESS ;
	}

	return sts ;

} /* VD_allocForBSmerge_cv */
/*----------------------------------------------------------------------------*/
int VD_pjptoninfln( P1, P2, Q, Qprime )

IGRpoint	P1,
		P2,
		Q,
		Qprime ; {

	long	rc   ;
	int	i ;
	double	dP1P2,
		P1QdotP1P2,
		scale ;
	/*
	 * The projection Q' of point Q on line defined by P1 and P2 is :
	 * --->   -->   -> ->        ->  --->      --->
	 * P1Q' = P1Q . u  u , where u = P1P2 / || P1P2 ||
	 *                 -->   ---> --->      --->   --->
	 * Hence Q' = P1 + P1Q . P1P2 P1P2 // ( P1P2 . P1P2 )
	 */
	dP1P2 = BSdistptpt( &rc, P1, P2 ) ;

	if( VD_zeroDist( dP1P2 ) ) return FALSE ;

	P1QdotP1P2 = 0 ;
	for( i = 0 ; i < 3 ; i++ ) {
		P1QdotP1P2 += ( Q[i] - P1[i] ) * ( P2[i] - P1[i] ) ;
	}
	scale = P1QdotP1P2 / ( dP1P2 * dP1P2 ) ;
	for( i = 0 ; i < 3 ; i++ ) {
		Qprime[i] = P1[i] + ( P2[i] - P1[i] ) * scale ;
	}
	return TRUE ;

} /* VD_pjptoninfln */
/*----------------------------------------------------------------------------*/
static void VD_merge_ls( rc, ls1, ls2, newls )

long			*rc ;
struct IGRbsp_curve	*ls1,
			*ls2,
			*newls ; {
	double	*newp0,
		*newp1,
		*p1_0	= ls1->poles + 0,
		*p1_1	= ls1->poles + 3,
		*p2_0	= ls2->poles + 0,
		*p2_1	= ls2->poles + 3 ;
	int	i ;

	       if( VD_eqPoints( p1_0, p2_0 ) ) {
		newp0 = p1_1 ; newp1 = p2_1 ;
	} else if( VD_eqPoints( p1_0, p2_1 ) ) {
		newp0 = p1_1 ; newp1 = p2_0 ;
	} else if( VD_eqPoints( p1_1, p2_0 ) ) {
		newp0 = p1_0 ; newp1 = p2_1 ;
	} else if( VD_eqPoints( p1_1, p2_1 ) ) {
		newp0 = p1_0 ; newp1 = p2_0 ;
	} else {
		*rc = BSINARG ; goto wrapup ;
	}
	BSlngen( rc, newp0, newp1, newls, &i ) ;

	wrapup : ;
	
} /* VD_merge_ls */
/*----------------------------------------------------------------------------*/
static long VD_lineExtOfCurve( msg, curveGeom, planeGeom, whichEnd, moreLength,
				portionOnly,
				extension )

long			*msg ;
struct IGRbsp_curve	*curveGeom,
			**extension ;
double			whichEnd,	/* Which end (0. or 1.)		*/
			moreLength ;
int			portionOnly ;	/* Only return ext'd portion ?	*/
struct IGRbsp_surface	*planeGeom ; {

	long		sts = OM_W_ABORT ;
	double		eval[6],	/* For BScveval()		*/
			*tangent,	/* Tangent to curve at end pnt	*/
			*endPnt,	/* End point of curve		*/
			dist ;		/* Dist. from end pnt to ...	*/
	IGRpoint	plPoint,	/* Point on plane		*/
			line[2],	/* End points of line segment	*/
			intPts[2],	/* Inters. pnts segment/plane	*/
			extPnt ;	/* Extension point		*/
	IGRvector	plNormal ;	/* Normal to plane		*/
	int		i,		/* Loop index			*/
			nint ; 		/* Count of intersections	*/

	*extension = NULL ;

        BScveval( curveGeom, whichEnd, 1, (IGRpoint *) eval, msg ) ;
        if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	endPnt	= eval + 0 ;
	tangent = eval + 3 ;

	BSnorvec( msg, tangent ) ;

	if( whichEnd == 0. ) VD_negvc( tangent, tangent ) ;

	if( vd_$is_curve_linear( msg = msg, curveGeom = curveGeom ) ) {
		double		*P1 = curveGeom->poles + 0,
				*P2 = curveGeom->poles + 3,
				*Q  = planeGeom->poles,
				maxDist ;
		IGRpoint	proj ;
		IGRvector	endPt2Prj ;
		int		n ;

		n	= planeGeom->u_num_poles * planeGeom->v_num_poles ;
		maxDist = 0 ;

		for( i = 0 ; i < n ; i++ ) {
	 		if( !VD_pjptoninfln( P1, P2, Q, proj ) ) {
				*msg = EMS_E_NoSolution ;
				goto wrapup ;
			}

	 		BSmkvec( msg, endPt2Prj, endPnt, proj ) ;

	 		dist = BSlenvec( msg, endPt2Prj ) ;
	 		if(    dist > maxDist
	 		    && BSdotp( msg, endPt2Prj, tangent ) > 0 ) {
	 			maxDist = dist ;
	 			VD_vccpy( intPts[0], proj ) ;
	 		}
	 		Q += 3 ;
	 	}
	 	goto MORELENGTH ;
 	}

	/*
	 * Get normal to plane and a point on the plane.
	 */
	BSsfnormal( planeGeom, plNormal, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	VD_vccpy( plPoint, planeGeom->poles ) ;

	/*
	 * Compute distance from curve's end point to plane.
	 */
	BSdistptpl( msg, endPnt, plPoint, plNormal, &dist ) ;

	if( VD_zeroDist( dist ) ) {
		IGRpoint	farthest ;

		VD_farthestSfPoleFromPt( endPnt, planeGeom, farthest ) ;

		dist = BSdistptpt( msg, endPnt, farthest ) ;

		for( i = 0 ; i < 3 ; i++ ) {
			intPts[0][i] = endPnt[i] + dist * tangent[i] ;
		}
	} else {
		/*
		 * Build line segment from point along tangent with length
		 * 2 * dist to give it a chance to intersect plane.
		 * Possible bug here ? tangent goes outwards only for end 1.
		 */

		dist *= 2 ;
		for( i = 0 ; i < 3 ; i++ ) {
			line[0][i] = endPnt[i] ;
			line[1][i] = endPnt[i] + dist * tangent[i] ;
		}

		/*
		 * Intersect line segment and plane.
		 */
		BSbdlnplint( line, plPoint, plNormal, &nint, intPts, msg ) ;
	        if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

		if( nint != 1 ) { *msg = EMS_E_NoIntersection ; goto wrapup ; }
	}

MORELENGTH :
	if( moreLength > 0. ) {
		/*
		 * An extra length is desired to make sure that the beam
		 * constructed on the extension will penetrate the plane.
		 */
		dist = ( 1 + moreLength ) * BSdistptpt( msg, endPnt, intPts[0] ) ;

		for( i = 0 ; i < 3 ; i++ ) {
			extPnt[i] = endPnt[i] + dist * tangent[i] ;
		}
	} else {
		VD_vccpy( extPnt, intPts[0] ) ;
	}

	if( portionOnly ) {

		BSalloccv(	2,
				3,
				FALSE,
				0,
				extension,
				msg ) ;
		if( BSERROR( *msg ) ) {
			*msg = EMS_E_NoDynamicMemory ; sts = OM_E_NODYNMEM ;
			goto wrapup ;
		}
		BSlngen( msg, endPnt, extPnt, *extension, &i ) ;

	        if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }
	} else {
		struct IGRbsp_curve	lineSeg ;
		double			lsPoles[12],
					lsKnots[6] ;

		lineSeg.poles	= lsPoles ;
		lineSeg.knots	= lsKnots ;

		BSlngen( msg, endPnt, extPnt, &lineSeg, &i ) ;

        	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

		sts = VD_allocForBSmerge_cv( msg, curveGeom, &lineSeg, extension ) ;
		__CheckRC( sts, *msg, "VD_allocForBSmerge_cv", wrapup ) ;

		VD_merge_ls( msg, curveGeom, &lineSeg, *extension ) ;

		if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			long rc ;
			BSfreecv( &rc, *extension ) ; *extension = NULL ;
		}
		return sts ;

} /* VD_lineExtOfCurve */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
