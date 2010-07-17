/*
	I/STRUCT
*/
#include <stdio.h>
#include <math.h>
#include "bstypes.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
#include "AS_status.h"
/*
 * Includes of function prototypes.
 */
#include "ma2pttobc.h"
#include "maptbcpro.h"
#include "maptlnpro.h"
#include "bsalloccv.h"
#include "bscveval.h"
#include "bscvsplit.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bsfreecv.h"
#include "bsmkvec.h"
#include "bsrev_cv.h"
#include "vssortsubsfs.h"
#include "vsspcvkp1res.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
int VSsplitCvKeepOneResult( msg, cvToSplit, splitPnt, whichToKeep, result )

long			*msg ;
struct IGRbsp_curve	*cvToSplit,
			**result ;
IGRpoint		splitPnt ;	/* Point where splitting occurs	*/
int			whichToKeep ; {

	/*
	 * whichToKeep = 0 : keep portion at left  of split point.
	 * whichToKeep = 1 : keep portion at right of split point.
	 */

	long		bsRC ;
	struct IGRbsp_curve
			*splitCrvR,	/* Result of split (right)	*/
			*splitCrvL ;	/* Result of split (left )	*/
	IGRpoint	projPnt ;	/* Proj. of split pnt on cv.	*/
	double		projTol,	/* Tolerance for projection	*/
			Usplit ;	/* Parameter of split point	*/
	IGRboolean	testPlanar ;	/* Test planarity of results ?	*/

	*result = splitCrvR = splitCrvL = NULL ;

	/*
	 * I didn't invent "1.e-10": GRNUC uses it in GRptproject !
	 */
	projTol = 1.e-10 ;
	MAptbcproj( msg, splitPnt, cvToSplit, &projTol, projPnt, &Usplit ) ;
	if( !( *msg & 1 ) ) { *msg = EMS_E_MAerror ; goto wrapup ; }

	/*
	 * Get memory for results of split.
	 */
	BSalloccv(	cvToSplit->order,
			cvToSplit->num_poles,
			cvToSplit->rational,
			cvToSplit->num_boundaries,
			&splitCrvR,
			&bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	BSalloccv(	cvToSplit->order,
			cvToSplit->num_poles,
			cvToSplit->rational,
			cvToSplit->num_boundaries,
			&splitCrvL,
			&bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	testPlanar = TRUE ;
	BScvsplit( &bsRC, cvToSplit, &Usplit, splitCrvL, splitCrvR,
			&testPlanar ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	if( whichToKeep == 0 ) {
		/*
		 * If we keep portion near end 0 of input curve, we want
		 * end 0 of portion of curve to coincide with end 0 of input
		 * curve. (if we keep portion near end 1 of input curve then
		 * end 0 of portion already coincides with end 1 of input
		 * curve ) ;
		 */

                /* for split point at 0, TR179800632 */
                if( Usplit == 0 ) {
                  UI_status("Bad left curve in VSsplitCvKeepOneResult");
                  //printf("Bad left curve in VSsplitCvKeepOneResult\n");
		  *msg = EMS_E_BSerror ; goto wrapup ; 
		}
	    	BSrev_cv( &bsRC, splitCrvL ) ;
	    	if( BSERROR( bsRC )){*msg = EMS_E_BSerror ; goto wrapup ; }
	}
        else {
           /* for split point at 0, TR179800632 */
           if( Usplit == 1.0 ) {
                  UI_status("Bad right curve in VSsplitCvKeepOneResult");
                  //printf("Bad right curve in VSsplitCvKeepOneResult\n");
                  *msg = EMS_E_BSerror ; goto wrapup ;
           }
        }

	*msg = MSSUCC ;

	wrapup :
		if( !( *msg & 1 ) ) {
			if( splitCrvR	 ) BSfreecv( &bsRC, splitCrvR	 ) ;
			if( splitCrvL	 ) BSfreecv( &bsRC, splitCrvL	 ) ;
		} else {
			if( whichToKeep == 1 ) {
				  *result = splitCrvR ;
				  if( splitCrvL	 ) BSfreecv( &bsRC, splitCrvL );
			} else {/* whichToKeep == 0 */ 
				  *result = splitCrvL ;
				  if( splitCrvR	 ) BSfreecv( &bsRC, splitCrvR );
			}
		}

		return *msg & 1 ;

} /* VSsplitCvKeepOneResult */
/*----------------------------------------------------------------------------*/
double VSfarthestSfPoleFromLnEndPt( surface, lineseg, whichEnd, farPolePrj )

struct IGRbsp_surface	*surface ;
struct IGRbsp_curve	*lineseg ;
int			whichEnd ;
IGRpoint		farPolePrj ; {

	long		rc ;
	int		maxPoles,
			i,
			farIndex ;
	double		*endPt,
			dSq,
			maxdSq,
			Uparm ;
	IGRpoint	*poles,
			prjPnt ;
	IGRvector	lineVc,
			ptToPrj ;
	struct IGRline	line ;

	farIndex	= -1 ;
	maxdSq		= 0 ;
	poles		= (IGRpoint *) surface->poles ;
	maxPoles	= surface->u_num_poles + surface->v_num_poles ;
	line.point1	= lineseg->poles + 0 ;
	line.point2	= lineseg->poles + 3 ;
	endPt		= lineseg->poles + whichEnd * 3 ;

	BSmkvec( &rc, lineVc, line.point1, line.point2 ) ;

	for( i = 0 ; i < maxPoles ; i++ ) {
		/*
		 * Project pole onto line. Retain farthest pole from point
		 * in the same direction as that of line.
		 */
		MAptlnproj( &rc, poles[i], &line, prjPnt, &Uparm ) ;

		if( ( dSq = BSdistptpts( &rc, endPt, prjPnt ) ) > maxdSq ) {
			double dotp ;

			BSmkvec( &rc, ptToPrj, endPt, prjPnt ) ;
			dotp = BSdotp( &rc, lineVc, ptToPrj ) ;

			switch( whichEnd ) {
				case 0 : if( dotp <= 0 ) {
						maxdSq 		= dSq ;
						farIndex	= i ; 
					 }
					 break ;

				case 1 : if( dotp >= 0 ) {
						maxdSq 		= dSq ;
						farIndex	= i ; 
					 }
					 break ;
			} /* switch */
		} /* if */
	} /* for */

	if( farIndex != -1 ) {
		MAptlnproj( &rc, poles[farIndex], &line, farPolePrj, &Uparm ) ;
	}

	return farIndex != -1 ? sqrt( maxdSq ) : -1. ;

} /* VSfarthestSfPoleFromLnEndPt */
/*----------------------------------------------------------------------------*/
static int VSmk_portion_of_ln_through_sf( msg, lineseg, surface, whichEnd,
					  p_throughPortion )
long			*msg ;
struct IGRbsp_curve	*lineseg,
			**p_throughPortion ;
int			whichEnd ;
struct IGRbsp_surface	*surface ; {

	IGRpoint	farthest ;
	double		extDist ;

	*p_throughPortion = NULL ;

	switch( whichEnd ) {
		case 0 :
		case 1 : break ;
		default: *msg = MSINARG ; goto wrapup ;
	}

	extDist = VSfarthestSfPoleFromLnEndPt(	surface,
						lineseg,
						whichEnd,
						farthest ) ;

	if( extDist == -1. ) {
		*msg = MSINARG ; goto wrapup ;
	}

	BSalloccv(	lineseg->order,
			lineseg->num_poles,
			lineseg->rational,
			lineseg->num_boundaries,
			p_throughPortion,
			msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	MA2pttobc(	msg,
			lineseg->poles + whichEnd * 3,
			farthest,
			*p_throughPortion ) ;

	wrapup :
		if( !( *msg & 1 ) ) {
			long bsRC ;
			if( *p_throughPortion )
				BSfreecv( &bsRC, *p_throughPortion ) ;
		}
		return *msg & 1 ;

} /* VSmk_portion_of_ln_through_sf */
/*----------------------------------------------------------------------------*/
static int VSmk_portion_of_bc_through_sf( msg, curve, surface, whichEnd,
					  p_throughPortion )
long			*msg ;
struct IGRbsp_curve	*curve,
			**p_throughPortion ;
int			whichEnd ;
struct IGRbsp_surface	*surface ; {

	long		bsRC ;		/* BS return code		*/
	struct IGRbsp_curve
			*throughCurve ;	/* Extended through-curve	*/
	IGRpoint	splitPnt ;	/* Point where splitting occurs	*/

	*p_throughPortion = NULL ;

	vs$extend_curve_through_surface(msg		= msg,
					curveGeom	= curve,
					surfaceGeom	= surface,
					whichEnd	= whichEnd,
					p_curveGeom	= &throughCurve ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	/*
	 * We want to split at the end point of the original curve: get end
	 * point then its parameter on through-curve.
	 */
	BScveval( curve, (double) whichEnd, 0, (IGRpoint *) splitPnt, &bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	VSsplitCvKeepOneResult( msg,
				throughCurve,
				splitPnt,
				whichEnd,
				p_throughPortion ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	*msg = MSSUCC ;

	wrapup :
		if( throughCurve ) BSfreecv( &bsRC, throughCurve ) ;

		return *msg & 1 ;

} /* VSmk_portion_of_bc_through_sf */
/*----------------------------------------------------------------------------*/
int VSmk_portion_of_cv_through_sf( msg, curve, surface, whichEnd,
					p_throughPortion )

/*
Abstract :
	Given a curve and a surface, creates a portion of curve from one of
	the curve's end point, extending the curve and going through the
	surface.
	This function interfaced by macro vs$mk_portion_of_cv_through_sf
*/

long			*msg ;
struct IGRbsp_curve	*curve,
			**p_throughPortion ;
int			whichEnd ;
struct IGRbsp_surface	*surface ; {

	if( vs$is_curve_linear( msg = msg, curveGeom = curve ) ) {
		VSmk_portion_of_ln_through_sf(	msg,
						curve,
						surface,
						whichEnd,
						p_throughPortion ) ;
	} else {
		VSmk_portion_of_bc_through_sf(	msg,
						curve,
						surface,
						whichEnd,
						p_throughPortion ) ;
	}
	return *msg & 1 ;

} /* VSmk_portion_of_cv_through_sf */
/*----------------------------------------------------------------------------*/

