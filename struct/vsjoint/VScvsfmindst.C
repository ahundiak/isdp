/* $Id: VScvsfmindst.C,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsjoint/VScvsfmindst.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VScvsfmindst.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/11/14  13:06:16  pinnacle
 * Replaced: vsjoint/VScvsfmindst.C for:  by svkadamb for struct
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.3  1996/01/31  08:05:08  pinnacle
 * Replaced: vsjoint/VScvsfmindst.C for:  by svkadamb for struct
 *

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "OMerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "ma2pttobc.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsmdistcvcv.h"
#include "bsmdistptcv.h"
#include "bsnorvec.h"
#include "bspjcvnrsf.h"
#include "bsprptoncv.h"
/*----------------------------------------------------------------------------*/
long VScvTgtAtPnt( msg, cvGeom1, tpar1, cvGeom2, tpar2, resp )

long			*msg ;
struct IGRbsp_curve	*cvGeom1,
			*cvGeom2 ;
double			tpar1,
			tpar2 ;
int			*resp ; {

	double		eval1[6],
			eval2[6],
			*tg1 = eval1 + 3,
			*tg2 = eval2 + 3 ;

	SetProc( VScvTgtAtPnt ) ; Begin

	BScveval( cvGeom1, tpar1, 1, (IGRpoint *) eval1, msg ) ;
	BScveval( cvGeom2, tpar2, 1, (IGRpoint *) eval2, msg ) ;

	__DBGpr_vec( "Pnt 1", eval1 + 0 ) ;
	__DBGpr_vec( "Pnt 2", eval2 + 0 ) ;
	__DBGpr_vec( "Tan 1", tg1 ) ;
	__DBGpr_vec( "Tan 2", tg2 ) ;

	*resp = VScolinearVectors( tg1, tg2 ) ;

 	if( !*resp ) {
 		/*
 		 * If not collinear because tolerance is way too small, try a
 		 * coarser test.
 		 */
		double		zeroAngleCos,
				cosTg1Tg2 ;

		zeroAngleCos	= cos( EMS_ZEROANGLE_DEG * ( M_PI / 180.0 ) ) ;
		cosTg1Tg2	=    BSdotp( msg, tg1, tg2 )
				  / (   BSlenvec( msg, tg1 )
				      * BSlenvec( msg, tg2 ) ) ;
#ifdef vsDEBUG
		printf( "zeroAngleCos %12.11lf cosTg1Tg2 %12.11lf\n",
			zeroAngleCos, cosTg1Tg2 ) ;
#endif
		*resp = fabs( cosTg1Tg2 ) >= zeroAngleCos ;
	}

	__DBGpr_int( "Collinear ?", *resp ) ;

	End

	return BSOKAY( *msg ) ;

} /* VScvTgtAtPnt */
/*----------------------------------------------------------------------------*/
long VSchkLnStrCvDist( msg, cvGeom, numPts, pts, tolerance, t0, t1 )

long			*msg ;
struct IGRbsp_curve	*cvGeom ;
int			numPts ;
IGRpoint		*pts ;
double			tolerance,
			*t0,
			*t1 ; {

	long		sts ;
	int		i ;
	double		dist,
			*t_pars,
			*intpars ;
	short		k,
			n ;
	int		tooFar ;

	/*
	 * Given a line string which is the part of the projection group of
	 * a curve onto a surface, checks that it is close enough to the
	 * original curve and if so, attempts to find the parameters of
	 * the points on the curve corresponding to the extremities of the
	 * line string.
	 */
	SetProc( VSchkLnStrCvDist ) ; Begin
	
	__DBGpr_int( "numPts", numPts ) ;
	__DBGpr_dbl( "Tolerance", tolerance ) ;

	tooFar = FALSE ;
	for( i = 0 ; i < numPts ; i++ ) {
		t_pars = NULL ;
		intpars= NULL ;
		BSmdistptcv( cvGeom, pts[i], &k, &n, &t_pars, &dist, &intpars,
				msg ) ;
		if( BSERROR( *msg ) ) {
			/*
			 * Exit loop.
			 */
			tooFar = TRUE ; break ;
		}
		__DBGpr_dbl( "dist", dist ) ;

		if( dist > tolerance ) {
			tooFar = TRUE ; break ;
		}
		if( i == 0 ) {
			*t0 = t_pars[0] ;
		} else if( i == numPts -1 ) {
			*t1 = t_pars[0] ;
		}
		_FREE( t_pars ) ; _FREE( intpars ) ;

	}
	if( tooFar ) {
		*msg = MSFAIL ; sts = OM_W_ABORT ;
	} else {
		*msg = MSSUCC ; sts = OM_S_SUCCESS ;
		__DBGpr_dbl( "T0", *t0 ) ;
		__DBGpr_dbl( "T1", *t1 ) ;
	}

	End
	return sts ;

} /* VSchkLnStrCvDist */
/*----------------------------------------------------------------------------*/
long VSisCurveAtMinDistFromSurf( msg, tolerance, cvGeom, sfGeom, ovlInfo )


long			*msg ;
double			tolerance ;
struct IGRbsp_curve	*cvGeom ;
struct IGRbsp_surface	*sfGeom ;
VSoverlapInfo		*ovlInfo ; {

	/*
	 * WARNING ! The possible inner boundaries of the input surface are
	 * not taken into account.
	 */
	long			sts ;
	int			numMins = 0 ;
	double			dist,
				*t_par1	= NULL,
				*t_par2	= NULL ;
	IGRpoint		*pt1	= NULL,
				*pt2	= NULL ;
	int			numGrps	= 0,
				*numInGrps	= NULL ;
	BSpair			**uvpars ;
	IGRpoint		**pts ;
	IGRboolean		allOnCv ;
	double			segPoles[12],
				segKnots[4] ;
	struct IGRbsp_curve	segGeom ;
	int			i ;

	SetProc( VSisCurveAtMinDistFromSurf ) ; Begin ;

	ovlInfo->count	= 0 ;
	ovlInfo->code	= VS_K_NO_OVERLAP ;

	__DBGpr_vec( "cvGeom pole 0", cvGeom->poles + 0 ) ;
	__DBGpr_vec( "cvGeom pole 1", cvGeom->poles + 3 ) ;
	__DBGpr_int( "cvGeom #poles", cvGeom->num_poles ) ;


	segGeom.poles	= segPoles ;
	segGeom.knots	= segKnots ;

	BSpjcvnrsf(	cvGeom,
			sfGeom,
			0.01,
			&numGrps,
			&numInGrps,
			&uvpars,
			&pts,
			&allOnCv,
			msg ) ;
	__DBGpr_int( "Num grp", numGrps ) ;
	__DBGpr_int( "BSpjcvnrsf rc", *msg ) ;
	__DBGpr_int( "All on cv", allOnCv ) ;

	if( BSERROR( *msg ) || !numGrps ) {
		__DBGpr_com( "No solution" ) ;
		vs$error( stsval = OM_S_SUCCESS, msgval = EMS_I_NoSolution ) ;
	}

	/*
	 * There will at most be as many overlaps as there are projection
	 * groups. NOTE: we only malloc for t0start and t0end since, t1start
	 * and t1end are unused here.
	 */
	if( !( ovlInfo->t0start = _MALLOC( 2 * numGrps, double ) ) ) {
		vs$mem_fail() ;
	}
	ovlInfo->t0end = ovlInfo->t0start + numGrps ;

	for( i = 0 ; i < numGrps ; i++ ) {
		__DBGpr_int( "Group index", numInGrps[i] ) ;

		if( numInGrps[i] == 2 ) {
			/*
			 * Projection is a line segment, check that it is
			 * within distance of curve.
			 */
			MA2pttobc( msg, pts[i][0], pts[i][1], &segGeom ) ;

			__DBGpr_vec( "Line seg pt 0", pts[i][0] ) ;
			__DBGpr_vec( "Line seg pt 0", pts[i][1] ) ;
			__DBGpr_dbl( "U 0", uvpars[i][0][0] ) ;
			__DBGpr_dbl( "V 0", uvpars[i][0][1] ) ;
			__DBGpr_dbl( "U 1", uvpars[i][1][0] ) ;
			__DBGpr_dbl( "V 1", uvpars[i][1][1] ) ;
			__DBGpr_vec( "cvGeom pole 0", cvGeom->poles + 0 ) ;
			__DBGpr_vec( "cvGeom pole 1", cvGeom->poles + 3 ) ;
			
			BSmdistcvcv(	cvGeom,
					&segGeom,
					&numMins,
					&t_par1,
					&t_par2,
					&pt1,
					&pt2,
					&dist,
					msg ) ;
			__DBGpr_int( "Num mins", numMins ) ;
			__DBGpr_dbl( "Min dist", dist ) ;
			__DBGpr_int( "BSmdistcvcv rc", *msg ) ;

			if( numMins ) {
				int resp ;

				VScvTgtAtPnt( msg, cvGeom, *t_par1,
						  &segGeom, *t_par2,
						  &resp ) ;
				if( !resp ) dist = 100 * tolerance ;

				numMins = 0 ;
				_FREE( t_par1 ) ; _FREE( pt1 ) ;
				_FREE( t_par2 ) ; _FREE( pt2 ) ;
				t_par1	= t_par2	= NULL ;
				pt1	= pt2		= NULL ;
			}
			if( dist <= tolerance ) {
				IGRboolean	onCurve ;
				double		t0, t1, tmp ;

				__DBGpr_com( "MATCH !" ) ;
				BSprptoncv( msg, cvGeom, pts[i][0],
							&t0, &onCurve ) ;

				__DBGpr_dbl( "T0", t0 ) ;
				__DBGpr_int( "On cv 0", onCurve ) ;

				BSprptoncv( msg, cvGeom, pts[i][1],
							&t1, &onCurve ) ;
				__DBGpr_dbl( "T1", t1 ) ;
				__DBGpr_int( "On cv 1", onCurve ) ;
				if( t1 < t0 ) {
					tmp = t0 ; t0 = t1 ; t1 = tmp ;
				}
				__DBGpr_int( "Count", ovlInfo->count ) ;
				ovlInfo->t0start[ovlInfo->count] = t0 ;
				ovlInfo->t0end  [ovlInfo->count] = t1 ;
				
				ovlInfo->count++ ;
			}
		} else if( numInGrps[i] != 1 ) { 
			/*
			 * Projection is a line string.
			 */
			double	t0, t1, tmp ;
			sts = VSchkLnStrCvDist(	msg,
						cvGeom,
						numInGrps[i],
						pts[i],
						tolerance,
						&t0,
						&t1 ) ;
			if( sts & 1 & *msg ) {
				/*
				 * Line string is within tolerance distance
				 * of curve.
				 */
				__DBGpr_com( "MATCH !" ) ;
				if( t1 < t0 ) {
					tmp = t0 ; t0 = t1 ; t1 = tmp ;
				}
				ovlInfo->t0start[ovlInfo->count] = t0 ;
				ovlInfo->t0end  [ovlInfo->count] = t1 ;
					
				ovlInfo->count++ ;
			}
		}
	}

	if(    ovlInfo->count == 1
	    && ovlInfo->t0start[0] == 0.
	    && ovlInfo->t0start[1] == 1. ) {
	    	ovlInfo->code = VS_K_TOTAL_MATCH ;
		*msg	= MSSUCC ;
	} else if( !ovlInfo->count ) {
		ovlInfo->code = VS_K_NO_OVERLAP ;
		*msg	= EMS_I_NoSolution ;
	} else {
		ovlInfo->code = VS_K_COMMON_PORTION ;
		*msg	= MSSUCC ;
	}
	sts	= OM_S_SUCCESS ;

	wrapup :
		/*
		 * Free memory allocated by BSpjcvnrsf.
		 */
		if( numGrps ) {
			for( i = 0 ; i < numGrps ; i++ ) {
					_FREE( uvpars[i] ) ;
					_FREE( pts[i] ) ;
			}
			_FREE( uvpars ) ; _FREE( pts ) ; _FREE( numInGrps ) ;
		}
		End
		return sts ;
	
} /* VSisCurveAtMinDistFromSurf */
/*----------------------------------------------------------------------------*/


