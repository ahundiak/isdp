/* $Id: VSdrwcvhid.I,v 1.1.1.1 2001/01/04 21:10:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwcvhid.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwcvhid.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:33  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1996/01/31  06:55:14  pinnacle
# Replaced: vsdrawing/VSdrwcvhid.I for:  by svkadamb for struct
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

#include <stdio.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bsdotp.h"
#include "bspj_pt_cv.h"
#include "vsvecmxproto.h"

extern void	VSsetGRids() ;
extern long	EFproject_any_curve_on_planen() ;

from GRcurve import	GRsplit,
			GRrevparm ;
/*----------------------------------------------------------------------------*/
static long VSgetCurveTangentAt05( msg, cvId, cvEnv, tangent )

long		*msg ;
struct GRid	*cvId ;
struct GRmd_env *cvEnv ;
IGRvector	tangent ; {

	/*
	 * This function returns the tangent ( tangent ) of input curve
	 * ( cvId, cvEnv ) at parameter u=0.5.
	 */

	long			sts,	 /* OM completion code. 	      */
				bsRC ;	 /* BS return code.		      */
	double			eval[6] ;/* Evaluation of input curve.	      */
	struct IGRbsp_curve	*cvGeom ;/* Geometry of input curve.	      */

	cvGeom = NULL ;

	/*
	 * Get geometry of input curve.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Get tangent at u=0.5.
	 */
	BScveval( cvGeom,
		  0.5,
		  1,
		  (IGRpoint *) eval,
		  &bsRC ) ;

	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	VSvccpy( tangent, eval + 3 ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( cvGeom ) ;

		return sts ;

} /* VSgetCurveTangentAt05 */
/*----------------------------------------------------------------------------*/
static long VSpj_pt_cv( msg, cvGeom, vector, pnt, pjPnt, pjPm )

long			*msg ;
struct IGRbsp_curve	*cvGeom ;
IGRvector		vector ;
IGRpoint		pnt ;
IGRpoint		pjPnt ;
double			*pjPm ; {

	/*
	 * Given a curve ( cvGeom ), a point ( pnt ) and a vector ( vector ),
	 * this function returns the first projection point ( pjPnt ) and
	 * corresponding parameter of the point on the curve ( pjPm ).
	 */

	long			sts ;	  /* OM completion code.	      */
	BSrc			bsRC ;	  /* BS return code.		      */
	long			num_pts ; /* Number of projection points.     */
	double			*proj_pts,/* Projection points. 	      */
				*upars ;  /* Parameters of projection points. */

	num_pts  = 0 ;
	proj_pts = upars = NULL ;

	/*
	 * Project point onto curve.
	 */
	BSpj_pt_cv( cvGeom,
		    pnt,
		    vector,
		    &num_pts,
		    (IGRpoint **) &proj_pts,
		    &upars,
		    &bsRC ) ;

	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	if( !num_pts ) vs$failure() ;

	VSvccpy( pjPnt, proj_pts ) ;
	*pjPm = upars[0] ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( proj_pts ) ;
		_FREE( upars	) ;

		return sts ;

} /* VSpj_pt_cv */
/*----------------------------------------------------------------------------*/
static long VSfindSplitPoints( msg, pjId, pjEnv, nb_part, part_pt_s, part_pt_e,
			       viewVector, nbPoints, points, leftHidden )

long		*msg ;
struct GRid	*pjId ;
struct GRmd_env *pjEnv ;
int		nb_part ;
double		*part_pt_s,
		*part_pt_e ;
IGRvector	viewVector ;
int		*nbPoints ;
double		**points ;
int		*leftHidden ; {

	/*
	 * Given the projected curve ( pjId, pjEnv ), this function returns
	 * an ordered list of split points ( nbPoints, points ) calculated with
	 * respect to given hidden parts ( nb_part, part_pt_s, part_pt_e )
	 * and view vector ( viewVector ). It returns also a flag ( leftHidden )
	 * which indicate if the left result of first split should be hidden.
	 *
	 * Note :
	 * ======
	 *	'*points' is allocated and must be freed by the caller with
	 *	'free( *points )'.
	 */

	long			sts ;	    /* OM return code.		      */
	int			i,	    /* Loop index.		      */
				j,	    /* Loop index.		      */
				nbPjPt ;    /* Number of projected points.    */
	double			*pm,	    /* Parameters of split points.    */
				tmp_pm ;    /* Local parameter. 	      */
	IGRpoint		tmp_pt ;    /* Local point.		      */
	struct IGRbsp_curve	*pjGeom ;   /* Geometry of projected curve.   */

	SetProc( VSfindSplitPoints ); Begin

	__DBGpr_obj( "Projected curve", *pjId ) ;

	*nbPoints   = 0 ;
	*points     = NULL ;
	*leftHidden = FALSE ;

	nbPjPt	    = 0 ;

	pm	    = NULL ;
	pjGeom	    = NULL ;

	/*
	 * Allocate memory for output split points.
	 */
	if( !( *points = _MALLOC( 3*(2*nb_part), double ) ) ) vs$mem_fail() ;

	/*
	 * Allocate memory for parameters of split points.
	 */
	if( !( pm = _MALLOC( 2*nb_part, double ) ) ) vs$mem_fail() ;

	/*
	 * Get geometry of projected curve.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= pjId,
			       grobjEnv = pjEnv,
			       geometry = &pjGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Project start and end points onto projected curve along view vector.
	 */
	for( i=0; i<nb_part; i++ ) {
		sts = VSpj_pt_cv( msg,
				  pjGeom,
				  viewVector,
				  part_pt_s +3*i,
				  (*points) +3*nbPjPt,
				  pm +nbPjPt ) ;

		__CheckRC( sts, *msg, "VSpj_pt_cv", wrapup ) ;

		if( pm[nbPjPt] == 0. ) *leftHidden = TRUE ;

		/*
		 * If start point is equal to last end point, don't keep split
		 * point.
		 */
		if( !VSeqPoints( part_pt_s +3*i, part_pt_e +3*(nb_part-1) ) )
			nbPjPt++ ;

		/*
		 * If end point is equal to first start point, don't project it.
		 */
		if( !VSeqPoints( part_pt_e +3*i, part_pt_s ) ) {
			sts = VSpj_pt_cv( msg,
					  pjGeom,
					  viewVector,
					  part_pt_e +3*i,
					  (*points) +3*nbPjPt,
					  pm +nbPjPt ) ;

			__CheckRC( sts, *msg, "VSpj_pt_cv", wrapup ) ;

			nbPjPt++ ;
		}
	}

	/*
	 * Sort split points and remove equal points.
	 */
	for( i=0; i<nbPjPt; i++ ) {
		for( j=i; j<nbPjPt; j++ )
			if( pm[j] < pm[*nbPoints] ) {
				tmp_pm	       = pm[j] ;
				pm[j]	       = pm[*nbPoints] ;
				pm[*nbPoints]  = tmp_pm ;

				VSvccpy( tmp_pt,
					 (*points) +3*j 	  ) ;
				VSvccpy( (*points) +3*j,
					 (*points) +3*(*nbPoints) ) ;
				VSvccpy( (*points) +3*(*nbPoints),
					 tmp_pt 		  ) ;
			}

		if( !(*nbPoints) || pm[*nbPoints] != pm[(*nbPoints)-1] )
			(*nbPoints)++ ;
		else	pm[*nbPoints] = MAXDOUBLE ;
	}

#ifdef vsDEBUG
	__DBGpr_int( "Number of hidden parts", nb_part ) ;
	__DBGpr_com( "List of hidden parts" ) ;
	__DBGpr_com( "--------------------" ) ;
	for( i=0; i<nb_part; i++ ) {
		__DBGpr_int( "number", i	       ) ;
		__DBGpr_vec( "\tstart", part_pt_s +3*i ) ;
		__DBGpr_vec( "\t\tend", part_pt_e +3*i ) ;
	}
	__DBGpr_int( "Number of split points", *nbPoints ) ;
	__DBGpr_com( "List of split points" ) ;
	__DBGpr_com( "--------------------" ) ;
	for( i=0; i<*nbPoints; i++ ) {
		__DBGpr_int( "number", i	       ) ;
		__DBGpr_vec( "\tpoint", *points +3*i   ) ;
		__DBGpr_dbl( "\tpm   ", pm[i]	       ) ;
	}
	__DBGpr_int( "Is first left result hidden ?", *leftHidden ) ;
#endif

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *points ) ;
			*points   = NULL ;
			*nbPoints = 0 ;
		}

		_FREE( pm     ) ;
		_FREE( pjGeom ) ;

		End
		return sts ;

} /* VSfindSplitPoints */
/*----------------------------------------------------------------------------*/
long VSdrwProjectCurveWithHiddenParts( msg, cvId, cvEnv, nb_part, part_pt_s,
				       part_pt_e, part_pm_s, part_pm_e, cst,
				       dspVis, dspHid, drwPlane, viewVector,
				       cvHid, cvClassid )

long			*msg ;
struct GRid		*cvId ;
struct GRmd_env 	*cvEnv ;
int			nb_part ;
double			*part_pt_s,
			*part_pt_e,
			*part_pm_s,
			*part_pm_e ;
struct GRvg_construct	*cst ;
struct IGRdisplay	*dspVis,
			*dspHid ;
struct IGRplane 	*drwPlane ;
IGRvector		viewVector ;
struct GRid		*cvHid ;
OMuword 		*cvClassid ; {

	/*
	 * Given a curve ( cvId, cvEnv ) and its hidden parts ( nb_part,
	 * part_pt_s, part_pt_e, part_pm_s, part_pm_e ), this function
	 * returns a composite curve ( cvHid ) and its class id ( cvClassid )
	 * which is the projection of the input curve onto drawing plane
	 * ( drwPlane ) with hidden ( dspHid ) and visible ( dspVis ) parts.
	 *
	 * Note :
	 * ------
	 *	If the input curve is total hidden or visible, the output
	 *	curve is not a composite curve.
	 */

	long			sts ;	    /* OM completion code.	      */
	BSrc			bsRC ;	    /* BS return code.		      */
	int			i,	    /* Loop index.		      */
				cvCount,    /* Count of component curves of   */
					    /* output composite curve.	      */
				nbSplit,    /* Number of split points.	      */
				leftHidden ;/* Is left result of first split  */
					    /* hidden ( TRUE / FALSE ) ?      */
	short			num ;	    /* Number of curves split.	      */
	IGRvector		cvTan,      /* Tangent of input curve.	      */
				pjTan ;     /* Tangent of projected curve.    */
	IGRpoint		projPt ;    /* Project point ( not used ).    */
	double			*splitPt ;  /* List of split points.	      */
	struct GRid		*cvList,    /* List of component curves of    */
					    /* output composite curve.	      */
				rCv ;	    /* Right result of split.	      */
	struct GRparms		parm ;	    /* Parameter for split curve.     */

	SetProc( VSdrwProjectCurveWithHiddenParts ); Begin

	__DBGpr_obj( "Curve to project", *cvId ) ;

	cvHid->objid = rCv.objid = NULL_OBJID ;

	*cvClassid   = OM_K_NOTUSING_CLASSID ;

	cvCount      = 0 ;
	cvList	     = NULL ;

	nbSplit      = 0 ;
	splitPt      = NULL ;

	/*
	 * Project input curve onto drawing plane.
	 */
	cst->display = nb_part && part_pm_s[0] == 0. ? dspHid : dspVis ;

	sts = EFproject_any_curve_on_planen( msg,
					     cst,
					     cvId,
					     cvEnv,
					     drwPlane,
					     viewVector,
					     &rCv,
					     cvClassid ) ;

	__CheckRC( sts, *msg, "EFproject_any_curve_on_planen", wrapup ) ;

	__DBGpr_obj( "Projection of curve", rCv ) ;

	/*
	 * Set orientation of projected curve like input curve.
	 */
	sts = VSgetCurveTangentAt05( msg, cvId, cvEnv, cvTan ) ;

	__CheckRC( sts, *msg, "VSgetCurveTangentAt05", wrapup ) ;

	sts = VSgetCurveTangentAt05( msg, &rCv, cst->env_info, pjTan ) ;

	__CheckRC( sts, *msg, "VSgetCurveTangentAt05", wrapup ) ;

	if( BSdotp( &bsRC, cvTan, pjTan ) < 0. ) {
		__DBGpr_com( "Reversing order of projection" ) ;

		sts = om$send( msg	= message GRcurve.GRrevparm(
								msg,
								cst->env_info ),
			       senderid = rCv.objid,
			       targetid = rCv.objid,
			       targetos = rCv.osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRrevparm", wrapup ) ;
	}

	/*
	 * If the input curve is total hidden or visible, return the above
	 * projected curve.
	 */
	if( (nb_part	  == 1		&&
	     part_pm_s[0] == 0. 	&&
	     part_pm_e[0] == 1.)	||
	     nb_part	  == 0		) {
		__DBGpr_com( "Curve is total hidden or visible" ) ;
		*cvHid = rCv ;

		sts  = OM_S_SUCCESS ;
		*msg = MSSUCC ;
		goto wrapup ;
	}

	/*
	 * Find split points.
	 */
	sts = VSfindSplitPoints( msg,
				 &rCv,
				 cst->env_info,
				 nb_part,
				 part_pt_s,
				 part_pt_e,
				 viewVector,
				 &nbSplit,
				 &splitPt,
				 &leftHidden ) ;

	__CheckRC( sts, *msg, "VSfindSplitPoints", wrapup ) ;

	/*
	 * Allocate memory for component curves of output composite curve.
	 */
	if( !( cvList = _MALLOC( nbSplit +1, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( cst->env_info->_MD_OS, nbSplit +1, cvList ) ;

	/*
	 * Split curve with found split points.
	 */
	for( i=0; i<nbSplit; i++ ) {
		/*
		 * Find parameters structure for spliting curve.
		 */
		sts = om$send( msg	= message GRcurve.GRptproject(
						   msg,
						   &cst->env_info->_MATRIX_TYPE,
						   cst->env_info->_MATRIX,
						   splitPt +3*i,
						   projPt,
						   &parm ),
			       senderid = rCv.objid,
			       targetid = rCv.objid,
			       targetos = rCv.osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRptproject", wrapup ) ;

		if( parm.u == 0. ||
		    parm.u == 1. ) continue ;

		__DBGpr_obj( "Split curve", rCv 	 ) ;
		__DBGpr_vec( "with point ", splitPt +3*i ) ;
		__DBGpr_dbl( "parameter  ", parm.u	 ) ;

		sts = om$send( msg	= message GRcurve.GRsplit(
							 msg,
							 cst->env_info,
							 splitPt +3*i,
							 &parm,
							 &cvList[cvCount].objid,
							 &rCv.objid,
							 &num ),
			       senderid = rCv.objid,
			       targetid = rCv.objid,
			       targetos = rCv.osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

		__DBGpr_obj( "Left result", cvList[cvCount] ) ;

		sts = om$send( msg	= message GRvg.GRchgdp(
						 msg,
						 leftHidden ? dspHid : dspVis ),
			       senderid = cvList[cvCount].objid,
			       targetid = cvList[cvCount].objid,
			       targetos = cvList[cvCount].osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRchgdp", wrapup ) ;

		leftHidden = !leftHidden ;
		cvCount++ ;
	}

	cvList[cvCount] = rCv ;

	sts = om$send( msg	= message GRvg.GRchgdp(
						 msg,
						 leftHidden ? dspHid : dspVis ),
		       senderid = cvList[cvCount].objid,
		       targetid = cvList[cvCount].objid,
		       targetos = cvList[cvCount].osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRchgdp", wrapup ) ;

	cvCount++ ;

	__DBGpr_int( "Count of component curves", cvCount ) ;
	__DBGpr_objlist( "Component", cvCount, cvList ) ;

	/*
	 * Make composite curve.
	 */
	sts = vs$makeCompCurve( msg	= msg,
				cvList	= cvList,
				cvCount = cvCount,
				cvEnv	= cst->env_info,
				compEnv = cst->env_info,
				compCv	= cvHid ) ;

	__CheckRC( sts, *msg, "vs$makeCompCurve", wrapup ) ;

	__DBGpr_obj( "Output curve", *cvHid ) ;

	/*
	 * Get classid of output curve.
	 */
	sts = om$get_classid( osnum	= cvHid->osnum,
			      objid	= cvHid->objid,
			      p_classid = cvClassid ) ;

	__CheckRC( sts, 1, "om$get_classid", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids  = cvHid,
					theEnv = cst->env_info ) ;
			*cvClassid = OM_K_NOTUSING_CLASSID ;

			vs$bulk_delete( grids  = &rCv,
					theEnv = cst->env_info ) ;

			vs$bulk_delete( count  = cvCount,
					grids  = cvList,
					theEnv = cst->env_info ) ;
		}

		_FREE( splitPt ) ;
		_FREE( cvList  ) ;

		End
		return sts ;

} /* VSdrwProjectCurveWithHiddenParts */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;
