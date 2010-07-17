/*
	I/STRUCT
*/
class implementation VSsplBeam ;

#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vschgsymb.h"
#include "vsvecmxproto.h"

from GRlinear	import	GRgetpolyline ;
from GRcurve	import	GRsplit ;

extern OMuword OPP_GRcompcurve_class_id ;
/*----------------------------------------------------------------------------*/
static long VSsplit( msg, env, cv, pm, pt, cnt, cvs )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
double		pm ;
IGRpoint	pt ;
int		*cnt ;
OM_S_OBJID	*cvs ; {

	/*
	 * I got tired of writing the whole message send.
	 */
	long			sts ;
	struct GRparms		splitPm ;
	short			count ;
	struct GRid		Cv ;

	splitPm.u		= pm ;
	splitPm.leaf_id.objid	= NULL_OBJID ;
	splitPm.leaf_id.objid	= 0 ;

	Cv.objid = cv ;
	Cv.osnum = env->_MD_OS ;
	if( vs$is_ancestry_valid(object		= &Cv,
				 classid	= OPP_GRcompcurve_class_id ) ) {
				 	
		/* For composite curves we need the lead id */

		IGRpoint	prj ;
		sts = om$send( msg	= message GRgraphics.GRptproject(
							msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							pt,
							prj,
							&splitPm ),
				senderid= cv,
				targetid= cv,
				targetos= env->_MD_OS ) ;
							
	}
	sts = om$send(	msg	= message GRcurve.GRsplit(	msg,
								env,
								pt,
								&splitPm,
								cvs + 0,
								cvs + 1,
								&count ),
			senderid= cv,
			targetid= cv,
			targetos= env->_MD_OS ) ;
	*cnt = count ;

	return sts ;

} /* VSsplit */
/*----------------------------------------------------------------------------*/
long VSptatpr( msg, env, cv, pm, pt )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
double		pm ;
IGRpoint	pt ; {

	long	sts ;

	sts = om$send(	msg	= message GRvg.EMptatpr(msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							&pm,
							1,
							pt ),
			senderid= cv,
			targetid= cv,
			targetos= env->_MD_OS ) ;
	return sts ;

} /* VSptatpr */
/*----------------------------------------------------------------------------*/
long VSpratpt( msg, env, cv, pt, pm )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
IGRpoint	pt ;
double		*pm ; {

	long	sts ;
	int	count ;
	double	t[2] ;

	sts = om$send(	msg	= message GRvg.EMpratpt(msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							pt,
							t,
							&count ),
			senderid= cv,
			targetid= cv,
			targetos= env->_MD_OS ) ;
			
	if( !count ) {
		sts  = OM_E_ABORT ;
		*msg = EMS_W_NoSolution ;
	} else 	*pm = t[0] ;

	return sts ;

} /* VSpratpt */
/*----------------------------------------------------------------------------*/
static long VSsplitAtXYZ( msg, env, cv, pt, cnt, cvs )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
IGRpoint	pt ;
int		*cnt ;
OM_S_OBJID	*cvs ; {

	long	sts ;
	double	pm ;

	sts = VSpratpt( msg, env, cv, pt, &pm ) ;
	if( sts & 1 & *msg ) {
		sts = VSsplit( msg, env, cv, pm, pt, cnt, cvs ) ;
	}
	return sts ;

} /* VSsplitAtXYZ */
/*----------------------------------------------------------------------------*/
long VSsplitCurveWithOneOrTwoPoints( msg, curveEnv, curveId,
					  count, pntEnv, pntIds, points,
					  cst,
					  subCurve1, subCurve2 )
long		*msg ;
struct GRmd_env	*curveEnv,
		*pntEnv ;
struct GRvg_construct
		*cst ;
int		count ;
IGRpoint	points[2] ;
struct GRid	*curveId,
		pntIds[2],
		*subCurve1,
		*subCurve2 ; {

	long			sts ;		/* OM return code	*/
	IGRpoint		pnts[2] ;
	struct IGRpolyline	point ;
	int			action = 1,
				i,
				cnt ;
	double			Tpm[2] ;
	OM_S_OBJID		cv[2],		/* Results of split	*/
				cvCopy ;
	struct GRprops		props ;
	struct GRmd_env		*cstEnv ;

	cstEnv			= cst->env_info ;
	subCurve1->objid	= subCurve2->objid = cvCopy = NULL_OBJID ;
	point.num_points	= 1 ;

	if( points ) {
		for( i = 0 ; i < count ; i++ ) {
			VSvccpy( pnts[0], points[0] ) ;
			VSvccpy( pnts[1], points[1] ) ;
		}
	} else for( i = 0 ; i < count ; i++ ) {
		point.points = pnts[i] ;
		sts = om$send(	msg	= message GRlinear.GRgetpolyline(
							msg,
							&pntEnv->_MATRIX_TYPE,
							pntEnv->_MATRIX,
							&action,
							&point ),
				senderid= pntIds[i].objid,
				targetid= pntIds[i].objid,
				targetos= pntIds[i].osnum ) ;
		__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;
	}

	for( i = 0 ; i < count ; i++ ) {
		sts = VSpratpt( msg, curveEnv, curveId->objid, pnts[i], Tpm + i ) ;
		__CheckRC( sts, *msg, "GRvg.EMpratpt", wrapup ) ;
	}

	if( count == 1 ) {
		/*
		 * One point to split curve with, possible cases.
		 *
		 *	1) --------x------
		 *	2) x--------------
		 *	3) --------------x
		 */
		if( Tpm[0] == 0. || Tpm[0] == 1. ) {
			/*
			 * Case 2)/3) : degenerate case, copy input curve to
			 * sub-curve 1.
			 */
			sts = om$send(	msg	= message GRgraphics.GRcopy(
							msg,
							curveEnv,
							cstEnv,
							&cvCopy ),
				senderid= curveId->objid,
				targetid= curveId->objid,
				targetos= curveId->osnum ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

			if( Tpm[0] == 0. ) {
				subCurve1->objid = cvCopy ;
				subCurve1->osnum = cstEnv->_MD_OS ;
				subCurve2->objid = NULL_OBJID ;
			} else {
				subCurve2->objid = cvCopy ;
				subCurve2->osnum = cstEnv->_MD_OS ;
				subCurve1->objid = NULL_OBJID ;
			}
			cvCopy = NULL_OBJID ;
		} else {
			/*
			 * Non-degenerate case.
			 * Since GRsplit deletes the original, we have to copy
			 * it first.
			 */
			sts = om$send(	msg	= message GRgraphics.GRcopy(
								msg,
								curveEnv,
								cstEnv,
								&cvCopy ),
					senderid= curveId->objid,
					targetid= curveId->objid,
					targetos= curveId->osnum ) ;

			sts = VSsplit(	msg, cstEnv, cvCopy, Tpm[0],
					pnts[0], &cnt, cv );
			__CheckRC( sts, *msg, "VSsplit", wrapup ) ;

			subCurve1->objid = cv[0] ;
			subCurve2->objid = cv[1] ;
			subCurve1->osnum = subCurve2->osnum = cstEnv->_MD_OS ;

			cvCopy = NULL_OBJID ;
		}
		/*
		 * End of case when one split point.
		 */
		goto wrapup ;
	}

	/*
	 * Herafter we have TWO split points.
	 */
	/*
	 * Order points along curve.
	 */
	if( Tpm[0] > Tpm[1] ) {
		double	 tmp ;

		tmp = Tpm[0] ; Tpm[0] = Tpm[1] ; Tpm[1] = tmp ;

		for( i = 0 ; i < 3 ; i++ ) {
			tmp		= pnts[0][i] ;
			pnts[0][i]	= pnts[1][i] ;
			pnts[1][i]	= tmp ;
		}
	}
	/*
	 * CLOSED CURVE: Result of split is one open curve.
	 *
	 *  +---a----x-b-x-----------+
	 *  |                        |
	 *  +------------------------+
	 *
	 *  Split curve at point 1
	 *	     1
	 *  +---a----x---------------+		keep a
	 *  |                        |
	 *  +------------------------+
	 *
	 *  Split a at point 1
	 *	         2
	 *  +---a---- -b-x-----------+		delete b
	 *  |                        |
	 *  +------------------------+
	 *
	 * OPEN CURVE: Beware of split points being end points!
	 * We have 3 cases :
	 *
	 * 1) -----a------x-b-x----c----
	 * 2) --------------a------x-b-x
	 * 3) x-b-x---------c-----------
	 *
	 * 1) Split curve at point 1
	 *                1
	 *    -----a------x-----B-------	keep a
	 *    Split B at point 2
	 *                   2
	 *                -b-x-----c-------	keep c, delete b
	 * 2) Split curve at point 1, keep a
	 * 3) Split curve at point 2, keep c
	 *
	 */
	sts = om$send(	msg	= message GRvg.GRgeomprops(
							msg,
							&curveEnv->_MATRIX_TYPE,
							curveEnv->_MATRIX,
							&props ),
			senderid= curveId->objid,
			targetid= curveId->objid,
			targetos= curveId->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;
	
	/*
	 * Since GRsplit deletes the original, we have to copy it first.
	 */
	sts = om$send(	msg	= message GRgraphics.GRcopy(	msg,
								curveEnv,
								cstEnv,
								&cvCopy ),
			senderid= curveId->objid,
			targetid= curveId->objid,
			targetos= curveId->osnum ) ;

	if( props.phy_closed ) {

		sts = VSsplit( msg, cstEnv, cvCopy, Tpm[0], pnts[0], &cnt, cv );
		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

		cvCopy = cv[0] ;

		sts = VSsplitAtXYZ( msg, cstEnv, cvCopy, pnts[1], &cnt, cv ) ;
		__CheckRC( sts, *msg, "VSsplitAtXYZ", wrapup ) ;

		cvCopy = NULL_OBJID ;
		subCurve1->objid = cv[1] ;

		vs$bulk_delete(	objids = cv + 0, theEnv = cstEnv ) ;

	} else if( Tpm[0] != 0. ) {
		/*
		 * Case 1) or 3).
		 */
		sts = VSsplit( msg, cstEnv, cvCopy, Tpm[0], pnts[0], &cnt, cv );
		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

		cvCopy = NULL_OBJID ;
		subCurve1->objid = cv[0] ;
		subCurve1->osnum = cstEnv->_MD_OS ;

		if( Tpm[1] != 1. ) {
			/*
			 * Case 1) : Resplit cv[1] at pnts[1].
			 */
			cvCopy = cv[1] ;
			sts = VSsplitAtXYZ(	msg, cstEnv, cvCopy, pnts[1],
						&cnt, cv ) ;
			__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

			subCurve2->objid = cv[1] ;
			subCurve2->osnum = cstEnv->_MD_OS ;

			cvCopy = NULL_OBJID ;
			vs$bulk_delete(	objids = cv + 0, theEnv = cstEnv ) ;
		} else {
			/*
			 * Case 2) : Get rid of cv[1].
			 */
			vs$bulk_delete(	objids = cv + 1, theEnv = cstEnv ) ;
		}
	} else if( Tpm[1] != 1. ) {
		/*
		 * Case 3).
		 */
		sts = VSsplit( msg, cstEnv, cvCopy, Tpm[1], pnts[1], &cnt, cv );
		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

		cvCopy = NULL_OBJID ;

		subCurve2->objid = cv[1] ;
		subCurve2->osnum = cstEnv->_MD_OS ;

		vs$bulk_delete(	objids = cv + 0, theEnv = cstEnv ) ;
	} else {
		*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	if( !IF_NULL_OBJID( subCurve1->objid  ) ) {
		VSchgSymbAndProps( msg, subCurve1, cst->level, cst->display,
					cst->properties ) ;
	}
	if( !IF_NULL_OBJID( subCurve2->objid ) ) {
		VSchgSymbAndProps( msg, subCurve2, cst->level, cst->display,
					cst->properties ) ;
	}

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	objids = &cvCopy  , theEnv = cstEnv ) ;
			vs$bulk_delete(	grids  = subCurve1, theEnv = cstEnv ) ;
			vs$bulk_delete(	grids  = subCurve2, theEnv = cstEnv ) ;
		}
		return sts ;

} /* VSsplitCurveWithTwoPoints */
/*----------------------------------------------------------------------------*/

end implementation VSsplBeam ;
