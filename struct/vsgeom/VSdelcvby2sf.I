/* $Id: VSdelcvby2sf.I,v 1.1.1.1 2001/01/04 21:10:38 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSdelcvby2sf.I
 *
 * Description: Interfaced by macro "vs$delimit_curve_by_two_surfaces".
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdelcvby2sf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:38  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/11/12  20:06:32  pinnacle
# tr179900753
#
# Revision 1.2  1999/04/20  18:34:16  pinnacle
# TR179900495
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/02/20  16:18:38  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/98  ah      CR179800676 - Delimit curve can now extend curve as well
 * 04/20/99  ylong   TR179900495
 * 08/18/99  Jayadev TR179900753 - For Planar Freeform Surfaces
 ***************************************************************************/

class implementation GRvg ;

#include <stdio.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "gr.h"
#include "igr.h"
#include "growner.h"
#include "bserr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "vssplitdef.h"
#include "EMSdef.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpl.h"
#include "bsmdstptssf.h"
#include "vsintcvsf.h"
#include "vspratpt.h"
#include "vsvecmxproto.h"

from GRcurve	import	GRsplit,
			GRendpts,
			GRrevparm,
			GRptalong,
                        GRdisextend;

from EMSplane	import	EMplaneDef;

extern OMuword          OPP_EMSgenbs_class_id; // for TR179900753
/*----------------------------------------------------------------------------*/
long VSfindCvEndPtNearestToSf( msg, curve, surf, surfFlag, infIfPlanar, endPt, endPm )

long			*msg  ;
struct GRobj_env	*curve,
			*surf ;
int                      surfFlag;   // CR179800676, is set then extend curve
int			infIfPlanar ;
double			*endPt ;
double			*endPm ; {

	/*
	 * Given a curve and a surface, this function finds an end point
	 * on the curve near the surface.
	 */

	int				sts,
					is_planar = FALSE ;
	IGRboolean			all_on_surf ;
	BSrc				rc ;
	double				startPnt[3],
					endPnt[3],
					uvs[2][2],
					sf_pts[6],
					dist[2],
					normalPlane[3],
					pointPlane[3] ;
	struct IGRbsp_surface		*surfGeom = NULL ;
	struct IGRplane 		planeDef ;
	OMuword                         classID; // for TR179900753

	/*
	 * Retrieve start and end points of curve.
	 */
	sts = om$send( msg	= message GRcurve.GRendpts(
							msg,
							&curve->_matrix_type,
							curve->_matrix,
							startPnt,
							endPnt ),
			senderid = curve->_objid,
			targetid = curve->_objid,
			targetos = curve->_osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

	/*
	 * Check if surface is planar.
	 */
	if( infIfPlanar ) {
		is_planar = vs$is_surface_planar(
						msg	= msg,
						surfId	= &surf->obj_id,
						surfEnv = &surf->mod_env ) ;
		__CheckRC( 1, *msg, "vs$is_surface_planar", wrapup ) ;
	}

	/*
	 * If surface planar, it will be considered as an infinite plane.
	 */
	 om$get_classid( objid = surf->_objid,
			 osnum = surf->_osnum,
			 p_classid  = &classID);

	if( is_planar && (classID != OPP_EMSgenbs_class_id)) {//for TR179900753
		/*
		 * Retrieve normal and one point of planar surface.
		 */
		planeDef.normal = normalPlane ;
		planeDef.point	= pointPlane ;

		sts = om$send( msg = message EMSplane.EMplaneDef(
							 msg,
							 &surf->_matrix_type,
							 surf->_matrix,
							 &planeDef ) ,
			       senderid = surf->_objid,
			       targetid = surf->_objid,
			       targetos = surf->_osnum ) ;
		__CheckRC( sts, *msg, "EMSplane.EMplaneDef", wrapup ) ;

		/*
		 * Find distance between start point and infinite plane.
		 */
		BSdistptpl(	&rc,
				startPnt,
				pointPlane,
				normalPlane,
				&dist[0] ) ;
		if( BSERROR( rc ) ) {
			*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
		}

		/*
		 * Find distance between end point and infinite plane.
		 */
		BSdistptpl(	&rc,
				endPnt,
				pointPlane,
				normalPlane,
				&dist[1] ) ;
		if( BSERROR( rc ) ) {
			*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
		}
	} else {
		double	Points[6] ;
		/*
		 * Surface is not planar.
		 * Get geometry of surface.
		 */
		sts = vs$get_geometry( msg	= msg,
				       grobjId	= &surf->obj_id,
				       grobjEnv = &surf->mod_env,
				       geometry = &surfGeom ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		/*
		 * Find minimum distances between these points and the surface.
		 */
		VSvccpy( Points,   startPnt ) ;
		VSvccpy( Points+3, endPnt   ) ;

		BSmdstptssf(	2,
				(IGRpoint *) Points,
				surfGeom,
				uvs,
				(IGRpoint *) sf_pts,
				dist,
				&all_on_surf,
				&rc ) ;

		if( BSERROR( rc ) ) {
			*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
		}
	}

	/*
	 * The result is the point with the minimum distance.
	 */
	if( dist[1] > dist[0] ) {
	  
	  if (surfFlag == 0) VSvccpy( endPt, startPnt );
	  else {
	    
	    sts = om$send(
			  msg = message GRcurve.GRdisextend(msg,&curve->mod_env,startPnt,&dist[0],endPt),
			  senderid = NULL_OBJID,
			  targetid = curve->obj_id.objid,
			  targetos = curve->obj_id.osnum
			  );
	    
	  }
	  
	  *endPm = 0. ;

	} else {

	  if (surfFlag == 0) VSvccpy( endPt, endPnt );

	  /* CR179800676
	   * Note that we are actually cheating here by only extending the curve
	   * by the already calculated min distance, this should be ok since then intent
	   * is only to extend stiffeners a small amount.  If we need the extended curve
	   * to actually intersect the surface then we should use some sort of extend to surface
	   * macro function
	   */
	  else {  
	    
	    sts = om$send(
			  msg = message GRcurve.GRdisextend(msg,&curve->mod_env,endPnt,&dist[1],endPt),
			  senderid = NULL_OBJID,
			  targetid = curve->obj_id.objid,
			  targetos = curve->obj_id.osnum
			  );
	  }
	 
	  *endPm = 1. ;
	}

	wrapup :
		_FREE( surfGeom ) ;

		return sts ;

} /* VSfindCvEndPtNearestToSf */
/*----------------------------------------------------------------------------*/
long VSdelimitCurveByTwoSurfaces( msg, curve, surf, surfFlags, options, offset, resultSymb,
				  result )

long			*msg ;
struct GRobj_env	*curve,
			surf[2] ;

int                     surfFlags[2];  // CR179800676 New optional argument

int			options ;
double			offset[2] ;
struct GRsymbology	*resultSymb ;
struct GRid		*result ; {

	short				count ;
	int				sts,
					tmpBool,
					intFoundWthFirstSf = TRUE,
					intFoundWthSecondSf = TRUE,
					reverseCvOrient = FALSE ;
	double				firstPoint[3],
					secondPoint[3],
					startPoint[3],
					endPoint[3],
					tmpPoint[3],
					firstParm,
					secondParm,
					tmpParm ;
	OM_S_OBJID			subCurveL,
					subCurveR ;
	struct GRparms			splitParms,
					parms1,
					parms2 ;

	int flags[2];
	
	if (surfFlags != NULL) {
	  flags[0] = surfFlags[0];
	  flags[1] = surfFlags[1];
	}
	else {
	  flags[0] = 0;
	  flags[1] = 0;
	}
	
	result->objid = NULL_OBJID ;

	/*
	 * Find the intersection point between the curve and the first surface.
	 */
	sts = VSintersectCurveAndSurface( msg,
					  &curve->obj_id,
					  &curve->mod_env,
					  &surf[0].obj_id,
					  &surf[0].mod_env,
					  options & VS_K_CONSASANINFPLANE,
					  firstPoint,
					  &firstParm ) ;

	if( !( sts & *msg & 1 ) ) {
		if( *msg == EMS_W_NoSolution ) {
			/*
			 * No intersection point. Find good end point.
			 */
			__DBGpr_com( "No intersection with first surface" ) ;

			sts = VSfindCvEndPtNearestToSf( msg,
						curve,
					       &surf[0],flags[0],
						options & VS_K_CONSASANINFPLANE,
						firstPoint,
						&firstParm ) ;
			__CheckRC( sts, *msg, "VSfindCvEndPtNearestToSf", wrapup ) ;

			intFoundWthFirstSf = FALSE ;
		} else {
			/*
			 * Error encountered.
			 */
			 __DBGpr_com( "VSintersectCurveAndSurface FAILED" ) ;
			 goto wrapup ;
		}
	}

	__DBGpr_vec( "first intersection point", firstPoint ) ;
	__DBGpr_dbl( "parameter value", firstParm ) ;

	/*
	 * See if the intersection point found isn't an endpoint of the
	 * curve. In this case don't split the curve.
	 */
	if( firstParm == 0. || firstParm == 1. ) {
		__DBGpr_com( "Intersection point is an endpoint" ) ;

		intFoundWthFirstSf = FALSE ;
	}

	/*
	 * Find the intersection point between the curve and the second surface.
	 */
	sts = VSintersectCurveAndSurface( msg,
					  &curve->obj_id,
					  &curve->mod_env,
					  &surf[1].obj_id,
					  &surf[1].mod_env,
					  options & VS_K_CONSASANINFPLANE,
					  secondPoint,
					  &secondParm ) ;

	if( !( sts & *msg & 1 ) ) {
		if( *msg == EMS_W_NoSolution ) {
			/*
			 * No intersection point. Find good end point.
			 */
			 __DBGpr_com( "No intersection with second surface" ) ;

			sts = VSfindCvEndPtNearestToSf( msg,
					        curve,
					       &surf[1],flags[1],
					        options & VS_K_CONSASANINFPLANE,
					        secondPoint,
					        &secondParm ) ;
			__CheckRC( sts, *msg, "VSfindCvEndPtNearestToSf", wrapup ) ;

	// TR179900495 by ylong
	VSpratpt( msg, &curve->mod_env, curve->_objid, firstPoint, &firstParm ) ;

			intFoundWthSecondSf = FALSE ;
		} else {
			/*
			 * Error encountered.
			 */
			 __DBGpr_com( "VSintersectCurveAndSurface FAILED\n" ) ;
			 goto wrapup ;
		}
	}

	__DBGpr_vec( "second intersection point", secondPoint ) ;
	__DBGpr_dbl( "parameter value", secondParm ) ;

	/*
	 * See if the intersection point found isn't an endpoint of the
	 * curve. In this case don't split the curve.
	 */
	if( secondParm == 0. || secondParm == 1. ) {
		__DBGpr_com( "Intersection point is an endpoint" ) ;

		intFoundWthSecondSf = FALSE ;
	}

	/*
	 * Order points along curve.
	 */
	if( firstParm > secondParm ) {
		__DBGpr_com( "Reversing order of split points" ) ;

		tmpParm 	= firstParm ;
		firstParm	= secondParm ;
		secondParm	= tmpParm ;

		tmpBool 	    = intFoundWthFirstSf ;
		intFoundWthFirstSf  = intFoundWthSecondSf ;
		intFoundWthSecondSf = tmpBool ;

		VSvccpy( tmpPoint,	firstPoint	) ;
		VSvccpy( firstPoint,	secondPoint	) ;
		VSvccpy( secondPoint,	tmpPoint	) ;

		if( options & VS_K_SETCURVORIENT )
			reverseCvOrient = TRUE ;

		if( offset ) {
			double	tmpOffset ;

			tmpOffset	= offset[0] ;
			offset[0]	= offset[1] ;
			offset[1]	= tmpOffset ;
		}
	}

	/*
	 * If we want to keep/remove an offset length at the begining and at 
	 * the end of the result curve, find good spliting points. These points
	 * are :
	 *
	 * - First point : Point at the given offset[0] distance from the
	 *		   intersection point with the first surface to the
	 *		   start point of the curve.
	 *
	 *		Curve orientation.
	 *			 |
	 *			 v   <----- Offset #0.
	 *			->---*----*----------- <- Original curve.
	 *			     ^	  ^
	 *			    /	   \ Intersection point with first
	 *	       Spliting point	     surface.
	 *
	 * - Second point : Point at the given offset[1] distance from the
	 *		    intersection point with the second surface to the
	 *		    end point of the curve.
	 *
	 *		Curve orientation.
	 *			 |
	 *			 v	  -----> Offset #1.
	 *			->--------*----*------ <- Original curve.
	 *				  ^    ^
	 *				 /	\
	 * Intersection point with second	 Spliting point.
	 * surface.
	 *
	 */
	if( offset ) {

		if( intFoundWthFirstSf && offset[0] ) {

			__DBGpr_dbl( "Offset from first surface", offset[0] ) ;

			VSptatpr( msg, &curve->mod_env, curve->_objid, 0.,
				  startPoint ) ;

			parms1.u = firstParm ;
			parms2.u = 0. ;

			sts = om$send( msg	= message GRcurve.GRptalong(
							   msg,
							   &curve->_matrix_type,
							   curve->_matrix,
							   firstPoint,
							   startPoint,
							   &parms1,
							   &parms2,
							   offset,
							   tmpPoint ),
					senderid = curve->_objid,
					targetid = curve->_objid,
					targetos = curve->_osnum ) ;

			if( !(sts & 1 & *msg) ) {
				/*
				 * Point is not on curve.
				 */
				__DBGpr_com( "New first point not found" ) ;
				intFoundWthFirstSf = FALSE ;
			} else {
				sts = VSpratpt( msg,
						&curve->mod_env,
						curve->_objid,
						tmpPoint,
						&tmpParm ) ;

				if( !(sts & 1 & *msg) || tmpParm <= 0. ) {
					/*
					 * The point was found but is not
					 * on curve.
					 */
					__DBGpr_com( "New first point not found" ) ;
					intFoundWthFirstSf = FALSE ;
				} else {
					__DBGpr_com( "New first point found" ) ;
					firstParm = tmpParm ;
					VSvccpy( firstPoint, tmpPoint ) ;
				}
			}
		}

		if( intFoundWthSecondSf && offset[1] ) {

			__DBGpr_dbl( "Offset from second surface", offset[1] ) ;

			VSptatpr( msg, &curve->mod_env, curve->_objid, 1.,
				  endPoint ) ;

			parms1.u = secondParm ;
			parms2.u = 1. ;

			sts = om$send( msg	= message GRcurve.GRptalong(
							   msg,
							   &curve->_matrix_type,
							   curve->_matrix,
							   secondPoint,
							   endPoint,
							   &parms1,
							   &parms2,
							   offset+1,
							   tmpPoint ),
					senderid = curve->_objid,
					targetid = curve->_objid,
					targetos = curve->_osnum ) ;

			if( !(sts & 1 & *msg) ) {
				/*
				 * Point is not on curve.
				 */
				__DBGpr_com( "New second point not found" ) ;
				intFoundWthSecondSf = FALSE ;
			} else {
				sts = VSpratpt( msg,
						&curve->mod_env,
						curve->_objid,
						tmpPoint,
						&tmpParm ) ;

				if( !(sts & 1 & *msg) || tmpParm >= 1.) {
					/*
					 * The point was found but is not
					 * on curve.
					 */
					__DBGpr_com( "New second point not found" ) ;
					intFoundWthSecondSf = FALSE ;
				} else {
					__DBGpr_com( "New second point found" );
					secondParm = tmpParm ;
					VSvccpy( secondPoint, tmpPoint ) ;
				}
			}
		}
	}

	/*
	 * Split curve with first point.
	 */
	if( intFoundWthFirstSf ) {
		__DBGpr_dbl( "Split curve with first surface at", firstParm ) ;
		__DBGpr_vec( "... and point", firstPoint ) ;

		splitParms.u = firstParm ;

		sts = om$send( msg	= message GRcurve.GRsplit(
								msg,
								&curve->mod_env,
								firstPoint,
								&splitParms,
								&subCurveL,
								&subCurveR,
								&count ),
			       senderid = curve->_objid,
			       targetid = curve->_objid,
			       targetos = curve->_osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

		__DBGpr_int( "1 sub curve L", subCurveL ) ;
		__DBGpr_int( "2 sub curve R", subCurveR ) ;

		/*
		 * Delete Left result.
		 */
		 vs$bulk_delete( count	= 1,
				 objids = &subCurveL,
				 theEnv = &curve->mod_env ) ;

	} else {
		__DBGpr_com( "No split curve with first surface" ) ;

		subCurveR = curve->_objid ;
	}

	/*
	 * Split the right result with second point.
	 */
	if( intFoundWthSecondSf ) {
		/*
		 * SeconParm is the parameter of secondPoint on the original
		 * curve before the split, let's compute secondPoint's
		 * parameter on the sub-curve.
		 */
		VSpratpt( msg, &curve->mod_env, subCurveR, secondPoint,
			  &tmpParm ) ;
		__DBGpr_dbl( "New param", tmpParm ) ;

		splitParms.u = secondParm = tmpParm ;

		__DBGpr_dbl( "Split curve with second surface at", secondParm );
		__DBGpr_vec( "... and point", secondPoint ) ;

		sts = om$send( msg	= message GRcurve.GRsplit(
								msg,
								&curve->mod_env,
								secondPoint,
								&splitParms,
								&result->objid,
								&subCurveR,
								&count ),
			       senderid = subCurveR,
			       targetid = subCurveR,
			       targetos = curve->_osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

		__DBGpr_int( "2 sub curve L", result->objid ) ;
		__DBGpr_int( "2 sub curve R", subCurveR     ) ;

		/*
		 * Delete Right result.
		 */
		vs$bulk_delete( count  = 1,
				objids = &subCurveR,
				theEnv = &curve->mod_env ) ;

	} else {
		__DBGpr_com( "No split curve with second surface" ) ;

		result->objid = subCurveR ;
	}

	/*
	 * Change curve orientation if requested.
	 */
	if( reverseCvOrient ) {
		__DBGpr_com( "Change curve orientation of result curve" ) ;

		sts = om$send( msg	= message GRcurve.GRrevparm(
							      msg,
							      &curve->mod_env ),
			       senderid = result->objid,
			       targetid = result->objid,
			       targetos = curve->_osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRrevparm", wrapup ) ;
	}

	/*
	 * Put symbology.
	 */
	sts = om$send( msg	= message GRvg.GRputsymb( msg, resultSymb ),
		       senderid = result->objid,
		       targetid = result->objid,
		       targetos = curve->_osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRputsymb", wrapup ) ;

	wrapup :
		result->osnum = curve->_osnum ;

		return sts ;

} /* VSdelimitCurveByTwoSurfaces */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;
