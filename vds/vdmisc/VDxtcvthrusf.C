/*
	I/VDS	Copy
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "ma2pttobc.h"
#include "maaddvc.h"
#include "bsalloccv.h"
#include "bscv_sf_int.h"
#include "bscveval.h"
#include "bscvxttsf.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bsfreecv.h"
#include "bslngen.h"
#include "bslnxttsf.h"
#include "bsmdstptarr.h"
#include "bsmdistptsf.h"
#include "bspj_pt_sf.h"
#include "bspolyxtdst.h"
#include "bsprptonsf.h"
#include "bssfevaln.h"
#include "GRbclnextend.h"
#include "v_vecmxproto.h"

/*----------------------------------------------------------------------------*/
double VD_farthestSfPoleFromPt( point, surface, farthest )

IGRpoint		point,
			farthest ;
struct IGRbsp_surface	*surface ; {

	long		rc ;
	int		maxPoles,
			i ;
	double		dSq,
			maxdSq ;
	int		farIndex ;
	IGRpoint	*poles ;

	SetProc( VD_farthestSfPoleFromPt ); Begin

	farIndex	= -1 ;
	maxdSq		= 0 ;
	poles		= (IGRpoint *) surface->poles ;
	maxPoles	= surface->u_num_poles + surface->v_num_poles ;


	for( i = 0 ; i < maxPoles ; i++ ) {
		if( ( dSq = BSdistptpts( &rc, point, poles[i] ) ) > maxdSq ) {
			maxdSq 		= dSq ;
			farIndex	= i ; 
		}
	}
	if( farIndex != -1 ) {
		VD_vccpy( farthest, poles[farIndex] ) ;
	}

	End
	return farIndex != -1 ? sqrt( maxdSq ) : -1. ;

} /* VD_farthestSfPoleFromPt */
/*----------------------------------------------------------------------------*/
static int VD_findApproxPoint( msg, curve, surface, whichEnd, approxPnt )

long			*msg ;
struct IGRbsp_curve	*curve ;
struct IGRbsp_surface	*surface ;
int			whichEnd ;
IGRpoint		approxPnt ; {

	/*
	 * Find the approximate point needed by BS[ln|cv]xttsf.
	 * Create line from wanted end of curve with tangent vector,
	 * intersect if with surface, retain intersection closest to end.
	 */
	IGRpoint		lnPoles[4],
				otherEnd,
				*intPoints	= NULL ;
	double			*tParms		= NULL,
				*uParms		= NULL,
				*vParms		= NULL,
				lnKnots[6],
				dist,
				eval[6] ;
	int			nbInt		= 0,
				type,
				i1,
				i2 ;
	struct IGRbsp_curve	line ;

	SetProc( VD_findApproxPoint ); Begin 

	BScveval( curve, (double) whichEnd, 1, (IGRpoint *) eval, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	line.poles = &lnPoles[0][0] ;
	line.knots = lnKnots ;

	if( whichEnd == 0 ) VD_negvc( eval + 3, eval + 3 ) ;
	MAaddvc( msg, eval + 0, eval + 3, otherEnd ) ;

	BSlngen( msg, eval + 0, otherEnd, &line, &type ) ;

	GRbclnextend( msg, &line, &line ) ;

	BScv_sf_int(	msg,
			&line,
			surface,
			&nbInt,
			(double **) &intPoints,
			&tParms,
			&uParms,
			&vParms ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	BSmdstptarr(	1,
			(IGRpoint *) eval + 0,
			nbInt,
			intPoints,
			&i1,
			&i2,
			&dist,	/* Unused	*/
			msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	BSsfevaln(	surface,
			uParms[i2],
			vParms[i2],
			1,
			&i1,			/* Unused	*/
			approxPnt,
			(IGRvector *) eval,	/* Unused	*/
			msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	*msg = MSSUCC ;

	wrapup :
		_FREE( intPoints ) ;
		_FREE( uParms ) ;
		_FREE( vParms ) ;
		_FREE( tParms ) ;

	End
	return *msg & 1 ;

} /* VD_findApproxPoint */
/*----------------------------------------------------------------------------*/
static int VD_cvxttsf( msg, curve, isLinear, endPoint, endIndex, surface,
		      p_extCurve )

long			*msg ;
struct IGRbsp_curve	*curve,
			**p_extCurve ;
int			endIndex ;
int			isLinear ;
IGRpoint		endPoint ;
struct IGRbsp_surface	*surface ; {

	/*
	 * Extends a curve to a surface.
	 */
	long			bsRC ;
	IGRpoint		approxPt ;
	struct IGRbsp_curve	*extCurve ;
	int			numPoles,
				extOrder,
				extRatnl ;

	SetProc( VD_cvxttsf ) ; Begin

	extCurve = *p_extCurve = NULL ;

	VD_findApproxPoint( msg, curve, surface, endIndex, approxPt ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	if( VD_eqPoints( endPoint, approxPt ) ) {
		VD_copybc( msg, curve, &extCurve ) ;
		goto wrapup ;
	}

	/*
	 * Allocate memory for extCurve, for the following setting of number of
	 * poles, order, etc. see the headers of functions `BSlnxttsf' and
	 * `BScvxttsf'.
	 */
	if( isLinear ) {
		if( curve->order > 2 ) {
			numPoles = 2 * ( curve->order - 2 ) + curve->num_poles ;
			extOrder = curve->order ;
		} else /* curve->order == 2 */ {
			extOrder = 2 ;
			numPoles = curve->num_poles + 1 ;
		}
		extRatnl = curve->rational ;
	} else {
		if( curve->order > 3 ) {
			numPoles = curve->num_poles + 7
					+ 6 * ( curve->order - 3 ) ;
		} else /* curve->order == 3 */ {
			numPoles = curve->num_poles + 7 - 1 ;
		}
		extOrder = curve->order ;
		extRatnl = TRUE ;
	}
	
	BSalloccv(	extOrder,
			numPoles,
			extRatnl,
			curve->num_boundaries,
			&extCurve,
			&bsRC ) ;

	if( bsRC == BSNOMEMORY ) {
		extCurve = NULL ; *msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}
	extCurve->order 	= extOrder ;
	extCurve->rational	= extRatnl ;

	if( isLinear ) {
		BSlnxttsf( curve, endPoint, surface, approxPt, extCurve, &bsRC);
	} else {
		BScvxttsf( curve, endPoint, surface, approxPt, extCurve, &bsRC);
	}
	switch( bsRC ) {
		case BSSUCC	  : *msg = MSSUCC		; break ;
		case BSPHYCLOSED  : *msg = EMS_E_Closed		; goto wrapup ;
		case BSNOINTERS	  : *msg = EMS_E_NoIntersection ; goto wrapup ;
		case BSPTNOTFOUND : *msg = EMS_E_NoSolution	; goto wrapup ;
		case BSINVEXTDIR  : *msg = EMS_E_NoSolution	; goto wrapup ; 
		case BSNOMEMORY	  : *msg = EMS_E_NoDynamicMemory; goto wrapup ; 
		default		  : *msg = EMS_E_BSerror	; goto wrapup ;
	}

	wrapup :
		if( !( *msg & 1 ) ) {
			if( extCurve ) BSfreecv( &bsRC, extCurve ) ;
		} else {
			*p_extCurve = extCurve ;
		}

		End
		return *msg & 1 ;

} /* VD_cvxttsf */
/*----------------------------------------------------------------------------*/
int VD_extend_curve_to_surface( msg, curve, surface, whichEnd, p_extCurve )

long			*msg ;
struct IGRbsp_curve	*curve,
			**p_extCurve ;
int			whichEnd ;
struct IGRbsp_surface	*surface ; {

	long		bsRC ;		/* BS return code		*/
	struct IGRbsp_curve
			*extCurve ;	/* Extension to surface		*/
	IGRpoint	endPoint ;	/* Curve point where to extend	*/
	double		U ;
	int		isLinear ;	/* Is curve linear ?		*/

	SetProc( VD_extend_curve_to_surface ); Begin
	extCurve = NULL ;
	/*
	 * Get end point of extension.
	 */
	switch( whichEnd ) {
		case	0 : U = 0. ; goto CVEVAL ;
		case	1 : U = 1. ;
		CVEVAL	  : BScveval( curve, U, 0, (IGRpoint *) endPoint, &bsRC ) ;
			    if( BSOKAY( bsRC ) ) break ;
		default	  : *msg = EMS_I_InvalidArg ; goto wrapup ;
	}

	isLinear = vd_$is_curve_linear( msg = msg, curveGeom = curve ) ;

	VD_cvxttsf( msg, curve, isLinear, endPoint, whichEnd, surface, &extCurve ) ;
	if( !( *msg & 1 ) ) {
		if( !isLinear ) {
			/*
			 * Non-linear extension failed: try linear extension
			 * of non-linear curve.
			 */
			 VD_cvxttsf( msg, curve, TRUE, endPoint, whichEnd,
			 		surface, &extCurve ) ;
		}
	}
	if( !( *msg & 1 ) ) goto wrapup ;

	/*
	 * If input curve was a line segment, we also want a line segment
	 * as output.
	 */
	if( isLinear ) {
		IGRpoint	end0,
				end1 ;

		BScveval( extCurve, 0., 0, (IGRpoint *) end0, &bsRC ) ;
		BScveval( extCurve, 1., 0, (IGRpoint *) end1, &bsRC ) ;
		BSfreecv( &bsRC, extCurve ) ;

		BSalloccv(	curve->order,
				curve->num_poles,
				curve->rational,
				curve->num_boundaries,
				&extCurve,
				&bsRC ) ;
		if( BSERROR( bsRC ) ) {
			extCurve = NULL ;
			*msg = EMS_E_NoDynamicMemory ;
			goto wrapup ;
		}
		MA2pttobc( msg, end0, end1, extCurve ) ;
	}

	*msg = MSSUCC ;
	wrapup :
		if( !( *msg & 1 ) ) {
			if( extCurve ) BSfreecv( &bsRC, extCurve ) ;
		} else {
			*p_extCurve = extCurve ;
		}

		End
		return *msg & 1 ;

} /* VD_extend_curve_to_surface */
/*----------------------------------------------------------------------------*/
int VD_extend_bc_through_surface( msg, curve, surface, whichEnd,
					p_throughCurve )

/*
Abstract :
	Given a curve and a surface, extends the curve so that it goes through
	the surface.
	This function interfaced by macro vd_$extend_curve_through_surface.
*/

long			*msg ;
struct IGRbsp_curve	*curve,
			**p_throughCurve ;
int			whichEnd ;
struct IGRbsp_surface	*surface ; {

	long		bsRC ;		/* BS return code		*/
	struct IGRbsp_curve
			*extCurve ;	/* Extension to surface		*/
	IGRpoint	endPoint,	/* Curve point where to extend	*/
			farthest ;
	double		extDist,
			U ;

	SetProc( VD_extend_bc_through_surface ); Begin

	extCurve = *p_throughCurve = NULL ;

	VD_extend_curve_to_surface( msg, curve, surface, whichEnd, &extCurve ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	/*
	 * To make sure that curve will go through surface re-extend it by
	 * the distance from (new) end point of curve to the farthest pole
	 * of surface, but do not bother if surface is planar.
	 */
	if(    surface->u_order == 2
	    && surface->v_order == 2
	    && surface->planar
	    && !surface->rational ) {
	    	*p_throughCurve = extCurve ;
	    	goto wrapup ;
	}

	U = (double) whichEnd ;
	BScveval( extCurve, U, 0, (IGRpoint *) endPoint, &bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	extDist = VD_farthestSfPoleFromPt( endPoint, surface, farthest ) ;
	if( extDist == -1 ) {
		*msg = MSINARG ; goto wrapup ;
	}

	/*
	 * Extend curve by computed distance.
	 */
	BSalloccv(	extCurve->order,
			extCurve->num_poles + extCurve->order - 1,
			extCurve->rational,
			extCurve->num_boundaries,
			p_throughCurve,
			&bsRC ) ;
	if( bsRC == BSNOMEMORY ) {
		*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}
	(*p_throughCurve)->num_poles = extCurve->num_poles + extCurve->order - 1 ;
	(*p_throughCurve)->order     = extCurve->order ;
	(*p_throughCurve)->rational  = extCurve->rational ;
	/*
	 * Note that the following call will fail for certain B-splines if
	 * the distance to extend with is too large.
	 */
	BSpolyxtdst( extCurve, endPoint, extDist, *p_throughCurve, &bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	*msg = MSSUCC ;

	wrapup :
		if(    extCurve
		    /*
		     * Do not free if surface to extend to was planar and no
		     * further extension was performed.
		     */
		    && extCurve != *p_throughCurve ) {
		    	BSfreecv( &bsRC, extCurve ) ;
		}
		if( !( *msg & 1 ) ) {
			if( *p_throughCurve ) BSfreecv( &bsRC, *p_throughCurve);
		}

		End
		return *msg & 1 ;

} /* VD_extend_bc_through_surface */
/*----------------------------------------------------------------------------*/
int VD_extend_ln_through_surface( msg, lineseg, surface, whichEnd,
					p_throughCurve )

long			*msg ;
struct IGRbsp_curve	*lineseg,
			**p_throughCurve ;
int			whichEnd ;
struct IGRbsp_surface	*surface ; {

	IGRpoint	farthest ;
	double		extDist ;
	int		start ;

	SetProc( VD_extend_ln_through_surface ); Begin

	*p_throughCurve = NULL ;

	switch( whichEnd ) {
		case 0 : start = 1 ; break ;
		case 1 : start = 0 ; break ;
		default: *msg = MSINARG ; goto wrapup ;
	}

	extDist = VD_farthestSfPoleFromLnEndPt(	surface,
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
			p_throughCurve,
			msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	MA2pttobc(	msg,
			lineseg->poles + start * 3,
			farthest,
			*p_throughCurve ) ;

	wrapup :
		if( !( *msg & 1 ) ) {
			long bsRC ;
			if( *p_throughCurve )
				BSfreecv( &bsRC, *p_throughCurve ) ;
		}

	End
	return *msg & 1 ;

} /* VD_extend_ln_through_surface */
/*----------------------------------------------------------------------------*/
int VD_extend_curve_through_surface( msg, curve, surface, whichEnd,
					p_throughCurve )

/*
Abstract :
	Given a curve and a surface, extends the curve so that it goes through
	the surface.
	This function interfaced by macro vd_$extend_curve_through_surface.
*/

long			*msg ;
struct IGRbsp_curve	*curve,
			**p_throughCurve ;
int			whichEnd ;
struct IGRbsp_surface	*surface ; {

	SetProc( VD_extend_curve_through_surface ); Begin

	if( vd_$is_curve_linear( msg = msg, curveGeom = curve ) ) {
		VD_extend_ln_through_surface(	msg,
						curve,
						surface,
						whichEnd,
						p_throughCurve ) ;
	} else {
		VD_extend_bc_through_surface(	msg,
						curve,
						surface,
						whichEnd,
						p_throughCurve ) ;
	}

	End
	return *msg & 1 ;

} /* VD_extend_curve_through_surface */
/*----------------------------------------------------------------------------*/
