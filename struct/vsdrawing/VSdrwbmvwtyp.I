/* $Id: VSdrwbmvwtyp.I,v 1.3 2001/06/13 21:58:05 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwbmvwtyp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwbmvwtyp.I,v $
 *      Revision 1.3  2001/06/13 21:58:05  ramarao
 *      Fixed TR# 5322.
 *
 *      Revision 1.2  2001/05/29 15:18:14  ramarao
 *      Fixed ETL# 8300.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.4  1996/01/31  06:48:36  pinnacle
# Replaced: vsdrawing/VSdrwbmvwtyp.I for:  by svkadamb for struct
#
# Revision 1.3  1996/01/31  06:41:58  pinnacle
# Replaced: vsdrawing/VSdrwbmvwtyp.I for:  by svkadamb for struct
#
#
*
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include <malloc.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "madef.h"
#include "bstypes.h"
#include "bserr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "EMSmsgdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpl.h"
#include "bsdotp.h"
#include "vsvecmxproto.h"

from GRcurve	import GRendpts ;
/*----------------------------------------------------------------------------*/
long VSdrwFindPointOfViewPlaneOnAxis( msg, axisId, axisEnv, viewPlane, pt, pm )

long			*msg ;
const struct GRid	*axisId ;
const struct GRmd_env 	*axisEnv ;
const struct IGRplane 	*viewPlane ;
IGRpoint		pt ;
double			*pm ; {

	/*
	 * Given an axis and the view plane, this function returns the
	 * intersection point (pt) between the view plane and the axis, and
	 * the correponding parameter (pm) of this point onto the axis if an
	 * intersection between the axis and the view plane is found.
	 * Otherwise the function returns the nearest end point of the axis of
	 * the view plane.
	 *
	 * 1) Plane 'orthogonal' to axis :
	 * ===============================
	 *
	 *	|	0	 |	      1 	|
	 *	|	.--------|------------. 	|
	 *	|		 |	^		|
	 *				|
	 *			       axis
	 *	^		 ^			^
	 *	|		 |			|
	 *  view plane #0    view plane #1	    view plane #2
	 *
	 *  Points returned :
	 *  -----------------
	 *
	 *   view plane :
	 *
	 *	#0) Start point of axis.
	 *	#1) Intersection point between view plane #1 and the axis.
	 *	#2) End point of axis.
	 *
	 * 2) Plane 'parallel' to axis :
	 * =============================
	 *
	 *		0		      1
	 *		.---------------------.
	 *
	 *	    --------	-------    -------
	 *		^	   ^	      ^
	 *		|	   |	      |
	 *	view plane #0  view plane #1  view plane #2
	 *
	 * The point returned in those 3 case is the start point of axis.
	 *
	 * 3) Plane no 'orthogonal' and no 'parallel' :
	 * ============================================
	 *
	 *		\    0	       \	    1	\
	 *		 \   .----------\-----------.	 \
	 *		  \		 \		  \
	 *		   \		  \		   \
	 *		   ^		  ^		    ^
	 *		   |		  |		    |
	 *	       view plane #0  view plane #1	view plane #2
	 *
	 *  Points returned :
	 *  -----------------
	 *
	 *   view plane :
	 *
	 *	#0) Start point of axis.
	 *	#1) Intersection point between view plane #1 and the axis.
	 *	#2) End point of axis.
	 */

	long			sts ;		     /* OM completion code.   */
	BSrc			rc ;		     /* BS return code.       */
	struct IGRbsp_curve	*axGeom = NULL ;     /* Geometry of axis.     */
	IGRpoint		startPt,	     /* Start point of axis.  */
				endPt ; 	     /* End point of axis.    */
	double			distWthStart,	     /* Distance between the  */
						     /* start point and       */
						     /* view plane.	      */
				distWthEnd ;	     /* Distance between the  */
						     /* end point and view    */
						     /* plane.		      */
	int			inter ; 	     /* TRUE/FALSE	      */

	SetProc( VSdrwFindPointOfViewPlaneOnAxis ); Begin

	__DBGpr_obj( "Axis", *axisId ) ;
	__DBGpr_vec( "Point  of view plane", viewPlane->point ) ;
	__DBGpr_vec( "Normal of view plane", viewPlane->normal ) ;

	/*
	 * Get geometry of axis.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= axisId,
			       grobjEnv = axisEnv,
			       geometry = &axGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Intersect the view plane and the axis.
	 */
	inter = vs$isPlaneClippingCurve(	cvGeom		= axGeom,
						plane		= viewPlane,
						firstIntPoint	= pt,
						firstIntPm	= pm ) ;

	__DBGpr_int( "Intersection ?", inter ) ;

	if( !inter ) {
		/*
		 * No solution found. Find end point of axis.
		 */
		__DBGpr_com( "No Intersection found" ) ;

		sts = om$send( msg	= message GRcurve.GRendpts(
						msg,
						(short*) &axisEnv->_MATRIX_TYPE,
						 axisEnv->_MATRIX,
						 startPt,
						 endPt ),
			       senderid = axisId->objid,
			       targetid = axisId->objid,
			       targetos = axisId->osnum ) ;

	       __CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

		__DBGpr_vec( "Start point of axis", startPt ) ;
		__DBGpr_vec( "End   point of axis", endPt   ) ;

		/*
		 * Find distance between start point and view plane.
		 */
		BSdistptpl( &rc,
			    startPt,
			    (double*) viewPlane->point,
			    (double*) viewPlane->normal,
			    &distWthStart ) ;

		if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

		__DBGpr_dbl( "Distance with start point", distWthStart ) ;

		/*
		 * Find distance between end point and view plane.
		 */
		BSdistptpl( &rc,
			    endPt,
			    (double*) viewPlane->point,
			    (double*) viewPlane->normal,
			    &distWthEnd ) ;

		if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

		__DBGpr_dbl( "Distance with end point  ", distWthEnd   ) ;

		/*
		 * Find the nearest end point of axis to view plane.
		 */
		if( distWthStart > distWthEnd ) {
			VSvccpy( pt, endPt   ) ;
			*pm = 1. ;
		} else {
			VSvccpy( pt, startPt ) ;
			*pm = 0. ;
		}

	}

	__DBGpr_vec( "Point on axis  ", pt  ) ;
	__DBGpr_dbl( "Parameter value", *pm ) ;

	wrapup :
		_FREE( axGeom ) ;
		End
		return sts ;

} /* VSdrwFindPointOfViewPlaneOnAxis */
/*----------------------------------------------------------------------------*/
long VSdrwGetViewTypeFromBeam( msg, inp, xData )

long		*msg ;		/* OUT : completion code	*/
VSdrwInputData	*inp ;		/* I/O : input data		*/
VSdrwExecData	*xData ; {	/* IN  : execution data		*/

	/*
	 * This function returns the view type of a beam :
	 *
	 * TOP / BOTTOM :
	 * ==============
	 *
	 *	    ^
	 *	    |		<- view vector. ( view type is TOP )
	 *
	 *	---------
	 *	|	|
	 *	---   ---
	 *	   | |
	 *	   | |		<- beam.
	 *	   | |
	 *	---   ---
	 *	|	|
	 *	---------
	 *	  ----		<- support surface.
	 *
	 *	    |		<- view vector. ( view type is BOTTOM )
	 *	    v
	 *
	 * END-ON / SIDE :
	 * ===============
	 *
	 *	---------
	 *	|	|
	 *	---   ---
	 *	   | |
	 *	   | |		<- beam.
	 *	   | |
	 *	---   ---
	 *	|	|  ->	<- view vector. ( view type is SIDE )
	 *	---------
	 *
	 *	   /		<- view vector. ( view type is END-ON )
	 *	  v
	 */

	long			sts,		/* OM completion code.	*/
				rc ;		/* BS return code.	*/
	struct GRid		*bmId ;		/* Id of beam		*/
	struct GRmd_env 	*bmEnv ;	/* Mod. env. of beam	*/
	struct IGRplane 	*viewPlane ;	/* View plane		*/
	double			*viewVector,	/* View vector		*/
				angle ;		/* Half of vw cone angle*/
	int			suppCount ;	/* # of beam supports.  */
	VSsuppList		bmSupps ;	/* Beam supports.	*/
	IGRpoint		ptOnAxis ;	/* Point of view plane	*/
						/*  onto beam axis.	*/
	double			pm ;		/* Parameter of the	*/
						/*  point above.	*/
	IGRmatrix		CS ;		/* Coordinates sys. of	*/
						/*  beeam cross-section.*/
	IGRvector		zCS,		/* Z axis of the above.	*/
				yCS ;		/* Y axis of the above.	*/
	struct GRid		xDef ;		/* Id of cross- section.*/
	struct GRmd_env 	axisEnv ;	/* Real env. of axis.	*/

	SetProc( VSdrwGetViewTypeFromBeam ); Begin

	bmId		= inp->elmId ;
	bmEnv		= inp->elmEnv ;
	viewVector	= inp->drwInfo.viewVector ;
	viewPlane	= inp->drwInfo.viewPlane ;
	inp->viewType	= VSunknownViewType ;
	angle		= 0.5 * xData->overrides.viewConeAngle ;

	/*
	 * `xData->overrides.viewConeAngle' is in degrees, convert `angle' to
	 * radians.
	 */
	angle		= angle * M_PI / 180. ;

	__DBGpr_obj( "Beam", *bmId ) ;
	__DBGpr_obj( "Beam's module", bmEnv->md_id ) ;
	__DBGpr_vec( "View vector", viewVector ) ;

	/*
	 * Get supports of beam.
	 */
	sts = om$send( msg	= message VSpart.VSgetSupports( msg,
								bmEnv,
								&suppCount,
								bmSupps ),
		     senderid = bmId->objid,
		     targetid = bmId->objid,
		     targetos = bmId->osnum ) ;

	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	__DBGpr_obj( "Surface of beam", bmSupps[0]._grid ) ;
	__DBGpr_obj( "Axis    of beam", bmSupps[1]._grid ) ;

	/*
	 * Find point of view plane on axis.
	 */
	axisEnv.md_id = bmSupps[1].mod_env.md_id ;
	VSmulmx( bmSupps[1]._matrix, bmEnv->_MATRIX, axisEnv._MATRIX,
		 &axisEnv._MATRIX_TYPE ) ;

	sts = VSdrwFindPointOfViewPlaneOnAxis( msg,
					       &bmSupps[1]._grid,
					       &axisEnv,
					       viewPlane,
					       ptOnAxis,
					       &pm ) ;

	__CheckRC( sts, *msg, "VSdrwFindPointOfViewPlaneOnAxis", wrapup ) ;

	__DBGpr_dbl( "Parameter of view point onto axis", pm ) ;

	/*
	 * Get the coordinate of the cross section of the beam at parameter
	 * found.
	 */
	sts = om$send( msg	= message VSbeam.VSgetCrossSectionCS( msg,
								      bmEnv,
								      bmSupps,
								      bmSupps+1,
								      pm,
								      &xDef,
								      CS ),
		       senderid = bmId->objid,
		       targetid = bmId->objid,
		       targetos = bmId->osnum ) ;

	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

	yCS[0] = CS[1] ; yCS[1] = CS[5] ; yCS[2] = CS[9]  ;
	zCS[0] = CS[2] ; zCS[1] = CS[6] ; zCS[2] = CS[10] ;

	__DBGpr_vec( "Y axis of coord. of cross section of beam", yCS ) ;
	__DBGpr_vec( "Z axis of coord. of cross section of beam", zCS ) ;

	/*
	 * See if the Y axis is colinear to the view vector. In this case the
	 * view type is 'Top' if the dot product between the view vector and the
	 * Y axis is >0, otherwise the view type is 'Bottom'.
	 *							view type :
	 *							-----------
	 *	      ^
	 *	      | 	   <- view vector.		   TOP
	 *
	 *	 Y ^ |
	 *	   | |		   <- beam + Y axis.
	 *	     .----
	 *	--------------	   <- surface of beam.
	 *
	 *	      | 	   <- view vector.		  BOTTOM
	 *	      v
	 */
	if( VSareaColinearVectors( yCS, viewVector, angle ) ) {
		if( BSdotp( &rc, yCS, viewVector ) >0 ) {
			__DBGpr_com( "View type is TOP" ) ;
			inp->viewType = VSfromTop ;
		} else {
			__DBGpr_com( "View type is BOTTOM" ) ;
			inp->viewType = VSfromBottom ;
		}

		goto wrapup ;
	}

	/*
	 * Here Y axis isn't colinear to view vector. If it's orthogonal to
	 * view vector and the Z axis is also orthogonal to the view vector,
	 * the view type is 'Side'. Otherwise if only the Z axis is colinear
	 * to the view vector, the view type is 'End-On'.
	 *
	 *							view type :
	 *							-----------
	 *			    ^
	 *			   /	<- view vector. 	  End-On
	 *
	 *		 ----------------
	 *		/	/	/
	 *	       /       /       /
	 *	      / Y ^ | /^ Z    / <- beam + Z axis.
	 *	     /	  | |//      /
	 *	    /	    .---    /
	 *	   -----------------
	 *			->	<- view vector. 	   Side
	 *
	 */

#define FIVE_DEGREES ( 5. / 180. * M_PI )
        if( VSareaOrthoVectors( viewVector, yCS, FIVE_DEGREES ) &&
            VSareaOrthoVectors( viewVector, zCS, FIVE_DEGREES ) ) {
		__DBGpr_com( "View type is SIDE" ) ;
		inp->viewType = VSfromSide ;
	} else {
		if( VSareaColinearVectors( zCS, viewVector, angle ) ) {
			__DBGpr_com( "View type is END-ON" ) ;
			inp->viewType = VSendOn ;
		} else vs$inv_arg() ;
	}

	wrapup :
		if( *msg == EMS_E_InvalidArg ) {
			__DBGpr_com( "Invalid case !!!" ) ;
		}

		End
		return sts ;

} /* VSdrwGetViewTypeFromBeam */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
