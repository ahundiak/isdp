/* $Id: VSdrwplvwint.I,v 1.1.1.1 2001/01/04 21:10:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwplvwint.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwplvwint.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:33  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1996/01/31  07:06:34  pinnacle
# Replaced: vsdrawing/VSdrwplvwint.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation VSplate ;

#include <stdio.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsplatedef.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "bsdistptpl.h"
#include "vsdrwproto.h"

#define DISTANCE_TOLERANCE	5.	/* 5% of minimum distance edges to    */
					/* view plane.			      */

extern void		VSsetGRids() ;
extern long		EFproject_any_curve_on_planen() ;
/*----------------------------------------------------------------------------*/
long VSdrwCstPlateVwIntersection( msg, inp, xData, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
VSdrwGraphicGroup	*outp ; {

	/*
	 * This function extracts the intersection between the bottom side
	 * of a plate and the view plane. If no intersection was found, this
	 * function extracts the graphic contour edges of the bottom side which
	 * are parallel to the view plane and are at a minimum distance from it,
	 * if the bottom side has more than one edge. Otherwise, this function
	 * projects the only edge.
	 */

	long			sts ;	       /* OM completion code.	      */
	BSrc			rc ;	       /* BS return code.	      */
	struct GRid		botSd,	       /* Bottom side of plate.       */
				*wfList,       /* List of wireframes to       */
					       /* project.		      */
				*pjList,       /* List of projected	      */
					       /* wireframes.		      */
				*edList,       /* List of bottom side edges.  */
				*grList ;      /* List of graphic contour     */
					       /* edges which are parallel to */
					       /* view plane.		      */
	int			i,	       /* Loop index.		      */
				wfCount,       /* Count of wireframes.	      */
				plateInter,    /* Flag to indicate if the     */
					       /* plate intersects the view   */
					       /* plane.		      */
				edCount,       /* Count of bottom side edges. */
				grCount,       /* Count of graphic contour    */
					       /* edges which are parallel to */
					       /* view plane.		      */
				grParallel ;   /* Is graphic contour edge     */
					       /* parallel to view plane ?    */
	double			*dstList,      /* List of distance view plane */
					       /* to graphic contour edge.    */
				minDst,        /* Minimum distance of the     */
					       /* above list.		      */
				pm ;	       /* Parameter to get point.     */
	IGRpoint		midPnt ;       /* Middle point of graphic     */
					       /* contour edge. 	      */
	struct GRobj_env	cpyBotSd ;     /* Copy of bottom side of      */
					       /* plate.		      */
	struct GRvg_construct	cst ;	       /* Construction list for       */
					       /* wireframe elements.	      */
	OMuword 		pjClassid ;    /* Class of the projected      */
					       /* wireframe.		      */

	SetProc( VSdrwCstPlateVwIntersection ); Begin

	__DBGpr_obj( "Plate to draw", *(inp->elmId) ) ;

	/*
	 * Initialize data.
	 */
	plateInter = FALSE ;

	outp->list  = wfList  = pjList	= edList  = grList = NULL ;
	outp->count = wfCount = edCount = grCount = 0 ;

	VSsetGRids( inp->drwInfo.drwEnv->_MD_OS, 1, &cpyBotSd._grid ) ;

	dstList = NULL ;
	minDst	= MAXDOUBLE ;
	pm	= 0.5 ;

	/*
	 * Get bottom side of plate.
	 */
	sts = om$send( msg	= message NDmacro.ACreturn_foot(
							       msg,
							       VS_K_plBotSfPath,
							       &botSd,
							       NULL,
							       NULL ),
		       senderid = inp->elmId->objid,
		       targetid = inp->elmId->objid,
		       targetos = inp->elmId->osnum ) ;

	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	__DBGpr_obj( "Bottom side of plate", botSd ) ;

	/*
	 * Construction list for wireframe elements.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	/*
	 * Copy bottom side of plate, because the message EMSsurface.EMintplane
	 * doesn't take the inside boundaries of the surface when the surface
	 * comes from a drawing view.
	 */
	cpyBotSd.mod_env = *(cst.env_info) ;

	sts = vs$grCopy( msg	= msg,
			 frEnv	= inp->elmEnv,
			 frObj	= &botSd,
			 toEnv	= &cpyBotSd.mod_env,
			 toObj	= &cpyBotSd._grid ) ;

	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	__DBGpr_obj( "Copy of bottom side", cpyBotSd._grid ) ;

	/*
	 * Intersect the bottom side of plate and view plane.
	 */
	sts = vs$plane_surface_intersection( msg       = msg,
					     planeGeom = inp->drwInfo.viewPlane,
					     surface   = &cpyBotSd,
					     cst       = &cst,
					     nb_result = &wfCount,
					     resultList= &wfList ) ;

	if( *msg != EMS_W_NoSolution )
		__CheckRC( sts, *msg, "vs$plane_surface_intersection", wrapup );

	__DBGpr_int( "Count of intersections", wfCount ) ;

	/*
	 * If an intersection was found, project the intersection to drawing
	 * plane. Otherwise, if the bottom side has more than one edge, project
	 * all graphic contour edges of the bottom side which are parallel to
	 * the view plane and are at a minimum distance from it, else project
	 * the only edge.
	 */
	if( !wfCount ) {
		__DBGpr_com( "No intersections -> Find edges to project" ) ;

		/*
		 * Get all contour edges of copied bottom side.
		 */
		sts = vs$get_surface_edges( msg 	= msg,
					    sfId	= &cpyBotSd._grid,
					    sfEnv	= &cpyBotSd.mod_env,
					    edgeType	= VS_K_CONTOUR_EDGES,
					    edCount	= &edCount,
					    edList	= &edList ) ;

		__CheckRC( sts, *msg, "vs$get_surface_edges", wrapup ) ;

		__DBGpr_int( "Count of contour edges", edCount ) ;

		/*
		 * Get all graphic contour edges parallel to view plane and
		 * distances from it.
		 */
		if( !( grList  = _MALLOC( edCount, struct GRid ) ) &
		    !( dstList = _MALLOC( edCount, double      ) ) )
			vs$mem_fail() ;

		VSsetGRids( cpyBotSd.mod_env._MD_OS, edCount, grList ) ;

		for( i=0; i<edCount; i++ ) {
			__DBGpr_obj( "Edge", edList[i] ) ;

			sts = vs$get_graphic_edge( msg	  = msg,
						   edId   = edList +i,
						   edEnv  = &cpyBotSd.mod_env,
						   grEdge = grList + grCount ) ;

			__CheckRC( sts, *msg, "vs$get_graphic_edge", wrapup ) ;

			__DBGpr_obj( "Graphic", grList[grCount] ) ;

			__DBGpr_com( "Is parallel to view plane ?" ) ;

			sts = VSdrwIsCurveParallelToVwPlane(
							 msg,
							 grList + grCount,
							 &cpyBotSd.mod_env,
							 inp->drwInfo.viewPlane,
							 &grParallel ) ;

			__CheckRC( sts, *msg, "VSdrwIsCurveParallelToVwPlane",
				   wrapup ) ;

			if( grParallel ) {
				__DBGpr_com( "\t-> Yes, keep it" ) ;

				/*
				 * Find distance from graphic contour edge to
				 * view plane.
				 */
				sts = om$send( msg	= message GRvg.EMptatpr(
							 msg,
							 &cpyBotSd._matrix_type,
							 cpyBotSd._matrix,
							 &pm,
							 1,
							 midPnt ),
					       senderid = grList[grCount].objid,
					       targetid = grList[grCount].objid,
					       targetos = grList[grCount].osnum ) ;

				__CheckRC( sts, *msg, "GRvg.EMptatpr", wrapup );

				__DBGpr_vec( "Middle point", midPnt ) ;

				BSdistptpl( &rc,
					    midPnt,
					    inp->drwInfo.viewPlane->point,
					    inp->drwInfo.viewPlane->normal,
					    &dstList[grCount] ) ;

				if( BSERROR( rc ) )
					vs$error( msgval = EMS_E_BSerror ) ;

				__DBGpr_dbl( "Distance from view plane",
					     dstList[grCount] ) ;

				if( minDst > dstList[grCount] )
					minDst = dstList[grCount] ;

				grCount++ ;
			} else {
				__DBGpr_com( "\t-> No" ) ;
			}
		}

		if( !grCount ) {
			if( edCount == 1 ) {
				__DBGpr_com( "Bottom side is composed of one edge" ) ;
				__DBGpr_com( "-> Project it" ) ;
				dstList[grCount++] = 0. ;
			} else {
				__DBGpr_com( "No edges to project" ) ;
				*msg = MSSUCC ;
				sts  = OM_S_SUCCESS ;
				goto wrapup ;
			}
		}

		/*
		 * Project all graphic contour edges which have their distance
		 * less than a distance tolerance. This distance tolerance is
		 * minimum distance + ( minimum distance / DISTANCE_TOLERANCE )
		 * if the minimum distance is not null, ortherwise it's the BS
		 * length vector tolerance.
		 */
		if( minDst ) minDst += minDst / DISTANCE_TOLERANCE ;
		else	     BSEXTRACTPAR( msg, BSTOLLENVEC, minDst ) ;

		__DBGpr_dbl( "Minimum distance", minDst ) ;

		if( !( wfList = _MALLOC( grCount, struct GRid ) ) )
			vs$mem_fail() ;

		for( i=0; i<grCount; i++ )
			if( dstList[i] <= minDst )
				wfList[wfCount++] = grList[i] ;

	} else {
		__DBGpr_com( "Project intersections" ) ;
		plateInter = TRUE ;
	}

	/*
	 * Project wireframes to drawing plane.
	 */
	if( !( pjList = _MALLOC( wfCount, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( cst.env_info->_MD_OS, wfCount, pjList ) ;

	for( i=0; i<wfCount; i++ ) {
		__DBGpr_obj( "Wireframe to project", wfList[i] ) ;

		sts = EFproject_any_curve_on_planen( msg,
						     &cst,
						     wfList + i,
						     cst.env_info,
						     inp->drwInfo.drwPlane,
						     inp->drwInfo.viewVector,
						     pjList + i,
						     &pjClassid ) ;

		__CheckRC( sts, *msg, "EFproject_any_curve_on_planen", wrapup );

		__DBGpr_obj( "Projected wireframe", pjList[i] ) ;
	}

	/*
	 * Remove projected curved which are covered by other projected curves.
	 */
	sts = VSdrwRmCoveredCurves( msg,
				    cst.display->style,
				    cst.display->style,
				    wfCount,
				    pjList,
				    cst.env_info,
				    &outp->count,
				    &outp->list ) ;

	__CheckRC( sts, *msg, "VSdrwRmCoveredCurves", wrapup ) ;

	__DBGpr_objlist( "Drawing of plate", outp->count, outp->list ) ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( pjList && wfCount )
				vs$bulk_delete( count  = wfCount,
						grids  = pjList,
						theEnv = cst.env_info ) ;

			_FREE( outp->list ) ;
			outp->list  = NULL ;
			outp->count = 0 ;
		}

		vs$bulk_delete( grids	= &cpyBotSd._grid,
				theEnv	= &cpyBotSd.mod_env ) ;

		if( plateInter )
			vs$bulk_delete( count	= wfCount,
					grids	= wfList,
					theEnv	= cst.env_info ) ;

		_FREE( wfList  ) ;
		_FREE( pjList  ) ;
		_FREE( edList  ) ;
		if( grList ) {
			vs$bulk_delete( grids = grList,
					count = edCount,
					theEnv= &cpyBotSd.mod_env ) ;
			_FREE( grList  ) ;
		}
		_FREE( dstList ) ;

		End
		return sts ;

} /* VSdrwCstPlateVwIntersection */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
