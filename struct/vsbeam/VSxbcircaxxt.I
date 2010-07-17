/* $Id: VSxbcircaxxt.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbeam/VSxbcircaxxt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxbcircaxxt.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/01/21  19:35:18  pinnacle
# TR179702512
#
# Revision 1.4  1998/01/21  17:01:20  pinnacle
# TR179702512
#
# Revision 1.3  1998/01/02  12:23:02  pinnacle
# Replaced: vsbeam/VSxbcircaxxt.I for:  by svkadamb for struct
#
# Revision 1.2  1997/09/29  14:50:22  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 ***************************************************************************/

class implementation VSbeam ;

#include <math.h>
#include <float.h>		/* For "DBL_MAX"	*/
#include "bstypes.h"
#include "bsconic.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vsdpb.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

#include "vsbeamproto.h"

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
#include "vsspcvkp1res.h"
#include "vsvecmxproto.h"
#include "vsfarsfplfpt.h"

extern long VSbeamGetState(struct GRid *beamId, int *state);

/*----------------------------------------------------------------------------*/
static void VSfarthestAndClosestPoint( testPnt, pntArray, count,
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

} /* VSfarthestAndClosestPoint */
/*----------------------------------------------------------------------------*/
static double VSgetCircleArcLength( msg, circle, frPt, toPt )

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
	
} /* VSgetCircleArcLength */
/*----------------------------------------------------------------------------*/
static long VSfindLongestArc( msg, center, normal, pnt1, pnt2, planeGeom,
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

	VSvccpy( plPoint, planeGeom->poles ) ;

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
	L1 = VSgetCircleArcLength( msg, &C1, pnt1, int1 + 0 ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	iClosest1 = 0 ;

	if( nint1 == 2 ) {
		int	l ;

		l = VSgetCircleArcLength( msg, &C1, pnt1, int1 + 3 ) ;
		if( !( *msg & 1 ) ) goto wrapup ;

		if( L1 > l ) { L1 = l ; iClosest1 = 1 ; }
	}
		
	L2 = VSgetCircleArcLength( msg, &C2, pnt2, int2 + 0 ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	iClosest2 = 0 ;

	if( nint2 == 2 ) {
		int	l ;

		l = VSgetCircleArcLength( msg, &C2, pnt2, int2 + 3 ) ;
		if( !( *msg & 1 ) ) goto wrapup ;

		if( L2 > l ) { L2 = l ; iClosest2 = 1 ; }
	}

	/*
	 * Now keep point giving arc of largest length.
	 */
	if( L1 > L2 ) {
		VSvccpy( extPnt, int1 + iClosest1 * 3 ) ;
		whichCirc = 1 ;
	} else {
		VSvccpy( extPnt, int2 + iClosest2 * 3 ) ;
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

} /* VSfindLongestArc */
/*----------------------------------------------------------------------------*/
static long VScircExtOfCurve( msg, curveGeom, endPoint, whichEnd, extPoint,
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
		sts = VSsplitCvKeepOneResult(	msg,
						newCurve,
						endPoint,
						whichEnd,
						&extGeom ) ;
		__CheckRC( sts, *msg, "VSsplitCvKeepOneResult", wrapup ) ;
	} else {
		extGeom = newCurve ;
	}

	*p_extGeom = extGeom ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		if( newCurve && portionOnly ) BSfreecv( &rc, newCurve ) ;

		return sts ;

} /* VScircExtOfCurve */
/*----------------------------------------------------------------------------*/
long VSallocForBSmerge_cv( msg, cv1, cv2, mcv )

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

} /* VSallocForBSmerge_cv */
/*----------------------------------------------------------------------------*/
int VSpjptoninfln( P1, P2, Q, Qprime )

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

	if( VSzeroDist( dP1P2 ) ) return FALSE ;

	P1QdotP1P2 = 0 ;
	for( i = 0 ; i < 3 ; i++ ) {
		P1QdotP1P2 += ( Q[i] - P1[i] ) * ( P2[i] - P1[i] ) ;
	}
	scale = P1QdotP1P2 / ( dP1P2 * dP1P2 ) ;
	for( i = 0 ; i < 3 ; i++ ) {
		Qprime[i] = P1[i] + ( P2[i] - P1[i] ) * scale ;
	}
	return TRUE ;

} /* VSpjptoninfln */
/*----------------------------------------------------------------------------*/
static void VSmerge_ls( rc, ls1, ls2, newls )

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

	       if( VSeqPoints( p1_0, p2_0 ) ) {
		newp0 = p1_1 ; newp1 = p2_1 ;
	} else if( VSeqPoints( p1_0, p2_1 ) ) {
		newp0 = p1_1 ; newp1 = p2_0 ;
	} else if( VSeqPoints( p1_1, p2_0 ) ) {
		newp0 = p1_0 ; newp1 = p2_1 ;
	} else if( VSeqPoints( p1_1, p2_1 ) ) {
		newp0 = p1_0 ; newp1 = p2_0 ;
	} else {
		*rc = BSINARG ; goto wrapup ;
	}
	BSlngen( rc, newp0, newp1, newls, &i ) ;

	wrapup : ;
	
} /* VSmerge_ls */
/*----------------------------------------------------------------------------*/
static long VSlineExtOfCurve( msg, curveGeom, planeGeom, whichEnd, moreLength,
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

	if( whichEnd == 0. ) VSnegvc( tangent, tangent ) ;
/*
	if( vs$is_curve_linear( msg = msg, curveGeom = curveGeom ) ) {
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
	 		if( !VSpjptoninfln( P1, P2, Q, proj ) ) {
				*msg = EMS_E_NoSolution ;
				goto wrapup ;
			}

	 		BSmkvec( msg, endPt2Prj, endPnt, proj ) ;

	 		dist = BSlenvec( msg, endPt2Prj ) ;
	 		if(    dist > maxDist
	 		    && BSdotp( msg, endPt2Prj, tangent ) > 0 ) {
	 			maxDist = dist ;
	 			VSvccpy( intPts[0], proj ) ;
	 		}
	 		Q += 3 ;
	 	}
	 	goto MORELENGTH ;
 	}
*/

	/*
	 * Get normal to plane and a point on the plane.
	 */
	BSsfnormal( planeGeom, plNormal, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	VSvccpy( plPoint, planeGeom->poles ) ;

	/*
	 * Compute distance from curve's end point to plane.
	 */
	// BSdistptpl( msg, endPnt, plPoint, plNormal, &dist ) ;

	/* 
	 * Evaluation of ditance from end point of curve and the plane may 
	 * not givecorrect results escpecially when the angle between the 
	 * beam and the surface is small and also if the cardinal point 
	 * of beam is not the lower one. Hence initialise the distance to zero. 	 * The farthest point will be calculated automatically
	 */
	dist = 0. ;

	if( VSzeroDist( dist ) ) {
		IGRpoint	farthest ;

		VSfarthestSfPoleFromPt( endPnt, planeGeom, farthest ) ;

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

// MORELENGTH :
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
		VSvccpy( extPnt, intPts[0] ) ;
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

		sts = VSallocForBSmerge_cv( msg, curveGeom, &lineSeg, extension ) ;
		__CheckRC( sts, *msg, "VSallocForBSmerge_cv", wrapup ) ;

		VSmerge_ls( msg, curveGeom, &lineSeg, *extension ) ;

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

} /* VSlineExtOfCurve */
/*----------------------------------------------------------------------------*/
long VSext_axis_for_trimming_plane( msg, beamId, beamEnv, supports,
				axisGeom, planeGeom, whichEnd, moreLength,
				portionOnly,
				extension )

long			*msg ;		/* Completion code		*/
struct GRid		*beamId ;	/* Id of beam			*/
struct GRmd_env		*beamEnv ;	/* Module of beam		*/
struct GRobj_env	*supports ;	/* Supports of beam		*/
struct IGRbsp_curve	*axisGeom ;	/* Geometry of beam axis	*/
struct IGRbsp_surface	*planeGeom ;	/* Geometry of plane		*/
double			whichEnd,	/* End of axis			*/
			moreLength ;	/* %-age of length to add	*/
int			portionOnly ;	/* Return ext'd portion only ?	*/
struct IGRbsp_curve	**extension ; {	/* Geometry of extension	*/


	long		sts ;		/* OM return code		*/
	IGRmatrix	xCS ;		/* Profile CS			*/
	struct GRid	xDef ;		/* Profile definition		*/
	IGRvector	nrmToCirc ;	/* Normal to circles		*/
	IGRpoint	rectPt[5],	/* Rectangle points		*/
			cenOfCrvt,	/* Center of crvatr at axis end	*/
			closest,	/* Prj. of closest point	*/
			farthest,	/* Prj. of farthest point	*/
			extPnt ;	/* Point to extend axis with	*/
	double		radOfCrvt ;	/* Radius of crvatr at axis end	*/
	int		i,		/* Loop index			*/
			iClosest,	/* Rect pt closest to cenOfCrv	*/
			iFarthest ;	/* Rect pt farthest fr cenOfCrv	*/
	struct IGRplane	planeDef;

	/*
	 * Compute coordinate system of profile at beam axis parameter
	 * `whichEnd'.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
						msg,
						beamEnv,
						supports + 0,
						supports + 1,
						whichEnd,
						&xDef,
						xCS ),
			senderid= beamId->objid,
			targetid= beamId->objid,
			targetos= beamId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

	/*
	 * Evaluate co-ordinates of the four points of the rectangle surrounding
	 * the profile :
	 *	rectPt[0]		rectPt[3]
	 *		+---------------+
	 *		|		|
	 *		+-----+   +-----+
	 *		      |   |
	 *		      |   |
	 *		      |   |
	 *		+-----+   +-----+
	 *		|		|
	 *		+---------------+
	 *	rectPt[1]		rectPt[2]
	 *
	 * They are first evaluate at the location of the cached profile
	 * definition (at the origin in the xy-plane z=0), then mapped to
	 * the site.
	 */

/* TR179701294 */
// TR179700969
/* TR179702512 */
  {	
    IGRboolean  cardOpt = FALSE ;
    int         state ;

    VSbeamGetState(beamId,&state);
    if( state & VS_m_NdState ) cardOpt = TRUE ;

    sts = VScardpt_to_point( beamEnv, xDef, &cardOpt, VS_e_BOT_LEFT, rectPt[0] ) ;
    sts = VScardpt_to_point( beamEnv, xDef, &cardOpt, VS_e_BOT_RGHT, rectPt[1] ) ;
    sts = VScardpt_to_point( beamEnv, xDef, &cardOpt, VS_e_UPP_LEFT, rectPt[2] ) ;
    sts = VScardpt_to_point( beamEnv, xDef, &cardOpt, VS_e_UPP_RGHT, rectPt[3] ) ;
  }

	/*
	 * Map points to the end of the beam axis.
	 */
	for( i = 0 ; i < 4 ; i++ ) {
	        VSmxprodpt( xCS, rectPt[i], rectPt[i] ) ;
        }

	/*
	 * Add beam axis end as last point (axis end may be OFF beam, hence
	 * axis end may not lie within above rectangle). The axis end is the
	 * origin in the profile CS. Fill normal-to-circle as well which is the
	 * y-axis of the CS.
	 */
        BScveval( axisGeom, whichEnd, 0, (IGRpoint *) rectPt[4], msg ) ;
	for( i = 0 ; i < 3 ; i++ ) {
		nrmToCirc[i]	= xCS[1 + 4*i] ;
	}

	if( vs$is_curve_linear(	msg		= msg,
				curveGeom	= axisGeom ) ) {
		sts = VSlineExtOfCurve(	msg,
					axisGeom,
					planeGeom,
					whichEnd,
					moreLength,
					portionOnly,
					extension ) ;
		__CheckRC( sts, *msg, "VSlineExtOfCurve", wrapup ) ;
		goto wrapup ;
	}

	/*
	 * Evaluate center and radius of curvature of axis at end point.
	 * Right and left radii of curvature and curvatures are the same here.
	 */
	{ double	kr, kl, rr ;
	  IGRpoint	cr ;
	  IGRboolean	boundary ;

		BSrdcencrcv(	msg, axisGeom, &whichEnd,
			    	&boundary, &kr, &kl, &radOfCrvt, &rr,
				cenOfCrvt, cr ) ;

		if( BSERROR( *msg ) ) {
			*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
		}
	}

	/*
	 * Find closest and farthest rectangle point from center of curvature.
	 */
	VSfarthestAndClosestPoint( cenOfCrvt, (double *) &rectPt[0][0], 5,
				   &iClosest, &iFarthest ) ;

	/*
	 * Now build 2 circles, one passing through the closest point, one
	 * through the farthest point ( the two circles will be in the plane
	 * tangent to the axis at the end of the axis ), and return the longest
	 * arc from the end of the axis to the plane. Taking the longest one
	 * whill ensure that the portion of beam later generated on this arc
	 * will go through the trimming plane.
	 * First project closest and farthest points onto the plane of the
	 * circles.
	 */
	planeDef.point	= cenOfCrvt ;
	planeDef.normal = nrmToCirc ;

	MAptplproj( msg, (IGRpoint *) rectPt[iClosest] , &planeDef, closest  ) ;
	MAptplproj( msg, (IGRpoint *) rectPt[iFarthest], &planeDef, farthest ) ;

	sts = VSfindLongestArc(	msg,
				cenOfCrvt,
				nrmToCirc,
				closest,
				farthest,
				planeGeom,
				moreLength,
				extPnt ) ;

	if( !( sts & 1 & *msg ) ) {
		if( *msg == EMS_E_NoIntersection ) {
			/*
			 * Cannot extend with an arc, try a linear extension.
			 */
			sts = VSlineExtOfCurve(	msg,
						axisGeom,
						planeGeom,
						whichEnd,
						moreLength,
						portionOnly,
						extension ) ;
			__CheckRC( sts, *msg, "VSlineExtOfCurve", wrapup ) ;
		} else {
			__CheckRC( sts, *msg, "VSfindLongestArc", wrapup ) ;
		}
	} else {
		/*
		 * Creation portion of curve extending axis up to extension point
		 * `extPnt', with an extension algorithm using the radius of curva-
		 * ture at the end point (which is here `rectPt[4]').
		 */
		sts = VScircExtOfCurve(	msg,
					axisGeom,
					rectPt[4],
					(int) whichEnd,
					extPnt,
					portionOnly,
					extension ) ;
		__CheckRC( sts, *msg, "VScircExtOfCurve", wrapup ) ;
	}

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		return sts ;

} /* VSext_axis_for_trimming_plane */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
