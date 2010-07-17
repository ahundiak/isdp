/* $Id: VSdrwutil.I,v 1.5 2001/11/17 18:46:16 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwutil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwutil.I,v $
 *      Revision 1.5  2001/11/17 18:46:16  jayadev
 *      fix for TR#5811
 *
 *      Revision 1.4  2001/02/14 21:11:12  ramarao
 *      Modification related to __DBGpr_com() macro.
 *
 *      Revision 1.3  2001/02/14 21:09:46  ramarao
 *      Modification related to __DBGpr_com() macro.
 *
 *      Revision 1.2  2001/02/14 21:07:58  ramarao
 *      Modification related to __DBGpr_com() macro.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:34  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.3  1996/01/31  07:08:54  pinnacle
# Replaced: vsdrawing/VSdrwutil.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/17/01        Jayadev         TR#MP 5811
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation EMSsurface ;

#include <stdio.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "OMmacros.h"
#include "bserr.h"
#include "growner.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "emseligible.h"
#include "msdef.h"
#include "vsjoint.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsplatedef.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bspj_pt_sf1.h"
#include "vsdocvsovlap.h"
#include "vsgetchanobj.h"
#include "vsispntonsrf.h"
#include "vspratpt.h"
#include "vsvecmxproto.h"
extern void		VSsetGRids() ;
extern OMuword		OPP_GRpoint_class_id,
			OPP_EMSsolid_class_id ;

from GRlinear	import	GRgetpolyline ;
from NDnode	import	ASreturn_go ;
from NDmacro	import	ACreturn_foot ;
from VSfeature	import	VSforwardToSource,
			VSgetNormalOfComponent ;
/*----------------------------------------------------------------------------*/
#argsused
long VSdrwGetFacesOfPart( msg, partId, partEnv, fcCount, fcList )

long		*msg ;
struct GRid	*partId ;
struct GRmd_env *partEnv ;
int		*fcCount ;
struct GRid	*fcList[] ; {

	/*
	 * This function returns all the faces of a part.
	 */

	long		sts ;		/* OM completion code		*/
	struct GRid	solidObj ;	/* Id of solid owned by part	*/

	*fcCount = 0 ;
	*fcList  = NULL ;

	/*
	 * Retrieve solid of part (supposed to be the 1st owned object, which
	 * is true for beams and plates).
	 */
	sts = om$send(	msg	= message NDnode.ASreturn_go(
						 &solidObj, NULL, NULL ),
			senderid= partId->objid,
			targetid= partId->objid,
			targetos= partId->osnum ) ;
	__CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup ) ;

	VSgetLeavesOfOwnerCmpGraph( msg, &solidObj, fcCount, fcList ) ;
	if( !( ( *msg&1 ) && *fcCount ) ) vs$failure() ;

	__DBGpr_objlist( "Faces of part", *fcCount, *fcList ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSdrwGetFacesOfPart */
/*----------------------------------------------------------------------------*/
long VSdrwFindPartFacesNotOrthoToViewVect( msg, viewVector, fcCount, fcList,
					   fcEnv, count, list )

long		*msg ;
IGRvector	viewVector ;
int		fcCount ;
struct GRid	fcList[] ;
struct GRmd_env *fcEnv ;
int		*count ;
struct GRid	*list[] ; {

	/*
	 * Given a list of part faces (fcList, fcCount), this function returns
	 * a list (list, count) of faces which have their normals not orthogonal
	 * to the view vector.
	 *
	 * For a beam :
	 * ============
	 *
	 *	       0
	 *	+---------------+
	 *    11|		| 1			|
	 *	+-----+   +-----+			| view vector.
	 *	  10  |   |  2				V
	 *	    9 |   |3
	 *	   8  |   |  4
	 *	+-----+   +-----+
	 *     7|		|5
	 *	+---------------+
	 *	       6
	 *
	 * list = 0,2,4,6,8,10.
	 *
	 * For a plate :
	 * =============
	 *
	 *		  0
	 *   -------------------------------
	 *   |		 4		   |		|
	 *  7|	       -----		   |1		| view vector.
	 *   |	     5/     \3		   |		V
	 *   ---------	     ---------------
	 *	 6		    2
	 *
	 * list = 0,2,3,4,5,6.
	 *
	 * Note : '*list' is allocated by the function.
	 */

	long		sts ;		/* OM return code.		      */
	int		i ;		/* Loop-on-faces index. 	      */
	IGRvector	normal ;	/* Normal of face.		      */
        IGRint          isPlanar;       /* surface planarity flag             */

	SetProc( VSdrwFindPartFacesNotOrthoToViewVect ); Begin

	__DBGpr_vec( "View vector", viewVector ) ;

	/*
	 * Allocate memory for output list.
	 */
	*count = 0 ;
	if( !( *list = _MALLOC( fcCount, struct GRid ) ) ) vs$mem_fail() ;

	/*
	 * Find the faces which have their normals not orthogonal to the view
	 * vector.
	 */
	for( i = 0 ; i < fcCount ; i++ ) {

                isPlanar = TRUE;
		__DBGpr_obj( "Face", fcList[i] ) ;

		sts = vs$get_normal( msg    = msg,
				     sfId   = fcList + i,
				     sfEnv  = fcEnv,
				     normal = normal ) ;

		__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;
		__DBGpr_vec( "\tnormal", normal ) ;
                /*
                 * Non-planar surfaces like those of EMSproject can be
                 * made of planes and the resulting normal can be 
                 * orthogonal to the view vector; These surfaces should
                 * be considered as some of the planes may be parallel
                 * to the view - TR#MP 5811
                 */
                isPlanar = vs$is_surface_planar(
                                        msg = msg,
                                    surfId  = fcList + i,
                                    surfEnv = fcEnv );
		__DBGpr_int( "is surface planar", isPlanar ) ;

		if( !VSorthoVectors( viewVector, normal ) ||
                    (!isPlanar) ) {
			__DBGpr_com( "\t-> Keep face" ) ;
			(*list)[(*count)++] = fcList[i] ;
		} else {
			__DBGpr_com( "\t-> Reject face" ) ;
		}
	}

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *list ) ;
			*list  = NULL ;
			*count = 0 ;
		}

		End
		return sts ;

} /* VSdrwFindPartFacesNotOrthoToViewVect */
/*----------------------------------------------------------------------------*/
long VSdrwIsPtHiddenBySf( msg, sfId, sfEnv, pnt, viewVector, hidden )

long		*msg ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
IGRpoint	pnt ;
IGRvector	viewVector ;
int		*hidden ; {

	/*
	 * This function tests if a point is hidden by a surface.
	 *
	 *		->		<- view vector.
	 *
	 *		|
	 *		|		<- surface.
	 *	.(p1)	|	.(p2)
	 *		|
	 *		|
	 *		|
	 *
	 *	- p1 is HIDDEN.
	 *	- p2 is VISIBLE.
	 */

	long			sts,		 /* OM return code.	      */
				rc ;		 /* BS return code.	      */
	struct IGRbsp_surface	*sfGeom = NULL ; /* Geometry of surface.      */
	long			num_pts = 0 ;	 /* Arguments for ...	      */
	double			*proj_pts = NULL,/*			      */
				*u = NULL,	 /*			      */
				*v = NULL;	 /* ... BSpj_pt_sf1	      */

	SetProc( VSdrwIsPtHiddenBySf ); Begin

	*hidden = FALSE ;

	__DBGpr_obj( "Surface", *sfId ) ;
	__DBGpr_vec( "Point  ", pnt   ) ;

	/*
	 * Get geometry of surface.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= sfId,
			       grobjEnv = sfEnv,
			       geometry = &sfGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Project the input point ( along the direction of the view vector )
	 * onto surface. If a projected point is found and is on surface the
	 * point is 'hidden', otherwise the point is visible.
	 */
	BSpj_pt_sf1( sfGeom,
		     pnt,
		     viewVector,
		     &num_pts,
		     &proj_pts,
		     &u,
		     &v,
		     &rc ) ;

	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	if( num_pts ) {
		/*
		 * See if point is on surface.
		 */
		sts = VSisPointOnSurface( msg,
					  sfEnv,
					  sfId,
					  TRUE,
					  proj_pts,
					  hidden ) ;

		__CheckRC( sts, *msg, "VSisPointOnSurface", wrapup ) ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( *hidden ) { __DBGpr_com( "Point is HIDDEN"  ) ; }
		else	      { __DBGpr_com( "Point is VISIBLE" ) ; }

		_FREE( sfGeom	) ;
		_FREE( proj_pts ) ;
		_FREE( u	) ;
		_FREE( v	) ;

		End
		return sts ;

} /* VSdrwIsPtHiddenBySf */
/*----------------------------------------------------------------------------*/
long VSdrwSfToWireFrame( msg, sfId, sfEnv, cst, wfCount, wfList )

long			*msg ;
struct GRid		*sfId ;
struct GRmd_env 	*sfEnv ;
struct GRvg_construct	*cst ;
int			*wfCount ;
struct GRid		*wfList[] ; {

	/*
	 * This functions returns the wireframes of a surface.
	 */

	long			sts ;		/* OM return code.	      */
	long			buf_size ;	/* For EMmake_wire_frame.     */
	struct GRvg_construct	locCst ;	/* Construction list (local). */
	struct EMScurveinfo	cvInfo ;	/* I/O of EMmake_wire_frame.  */
	unsigned short		options ;	/* Options of		      */
						/* EMmake_wire_frame.	      */

	SetProc( VSdrwSfToWireFrame ); Begin

	__DBGpr_obj( "Surface", *sfId ) ;

	*wfList = NULL ; *wfCount = 0 ;

	/*
	 * Construct local construction list.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= cst->env_info,
			   Display	= cst->display,
			   Level	= cst->level,
			   Cnst_list	= locCst ) ;

	/*
	 * Initialize data for EMmake_wire_frame.
	 */
	buf_size			= 0 ;
	cvInfo.messg_linestr		= NULL ;
	cvInfo.messg_gencrv		= NULL ;
	cvInfo.construct_list		= &locCst ;
	cvInfo.linestr.objid		= NULL_OBJID ;
	cvInfo.gencrv.objid		= NULL_OBJID ;
	cvInfo.linestr_counter		= 0 ;
	cvInfo.gencrv_counter		= 0 ;
	cvInfo.curves			= wfList ;
	cvInfo.buf_size 		= &buf_size ;
	cvInfo.num_curves		= (long *) wfCount ;

	options = EMSeligible_WholeEdge ;

	/*
	 * Make wireframe of input surface.
	 */
	sts = om$send( msg	= message EMSsurface.EMmake_wire_frame(
								      msg,
								      sfEnv,
								      &cvInfo,
								      options ),
		       senderid = sfId->objid,
		       targetid = sfId->objid,
		       targetos = sfId->osnum ) ;

	__CheckRC( sts, *msg, "EMSsurface.EMmake_wire_frame", wrapup ) ;

	__DBGpr_objlist( "Wireframes", *wfCount, *wfList ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *wfList ) ;
			*wfList  = NULL ;
			*wfCount = 0 ;
		}

		End
		return sts ;

} /* VSdrwSfToWireFrame */
/*----------------------------------------------------------------------------*/
long VSdrwIsEdgeHiddenByFaces( msg, edId, edEnv, fcEdge, viewVector, fcEnv,
				fcCount, fcList, hidden )

long		*msg ;
struct GRid	*edId ;
struct GRmd_env *edEnv ;
int		fcEdge ;
IGRvector	viewVector ;
struct GRmd_env *fcEnv ;
int		fcCount ;
struct GRid	*fcList ;
int		*hidden ; {

	/*
	 * This function tests if an edge of a face ( edId, edEnv ) is hidden
	 * by another face ( in `fcList' ).
	 *
	 * Note : 'fcEdge' is the face index in the list 'fcList' where the edge
	 * 'edId' is.
	 */

	long		sts ;			/* OM completion code.	      */
	int		i ;			/* Loop on face.	      */
	IGRpoint	midPnt ;		/* Middle point of edge.      */

	SetProc( VSdrwIsEdgeHiddenByFaces ); Begin

	__DBGpr_obj( "Edge", *edId ) ;
	__DBGpr_obj( "Face of edge", fcList[fcEdge] ) ;

	*hidden = FALSE ;

	/*
	 * Get middle point of edge.
	 */
	sts = VSptatpr( msg, edEnv, edId->objid, 0.5, midPnt ) ;

	__CheckRC( sts, *msg, "VSptatpr", wrapup ) ;

	__DBGpr_vec( "Middle point of edge", midPnt ) ;

	/*
	 * See if the edge is hidden by a face.
	 */
	for( i=0; i<fcCount; i++ ) {
		if( i==fcEdge ) continue ;

		sts = VSdrwIsPtHiddenBySf( msg,
					   fcList + i,
					   fcEnv,
					   midPnt,
					   viewVector,
					   hidden ) ;

		__CheckRC( sts, *msg, "VSdrwIsPtHiddenBySf", wrapup ) ;

		if( *hidden ) break ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( *hidden ) { __DBGpr_obj( "Edge is HIDDEN by", fcList[i] ); }
		else	      { __DBGpr_com( "Edge is VISIBLE" ) ; }

		End
		return sts ;

} /* VSdrwIsEdgeHiddenByFaces */
/*----------------------------------------------------------------------------*/
long VSdrwRmCoveredCurves( msg, styleHid, styleVis, inCvCount, inCvList,
			   cvEnv, outCvCount, outCvList )

long		*msg ;
char unsigned	styleHid,	/* Style for hidden curve.  */
		styleVis ;	/* Style for visible curve. */
int		inCvCount ;
struct GRid	inCvList[] ;
struct GRmd_env *cvEnv ;	/* Env for all curves.	    */
int		*outCvCount ;
struct GRid	*outCvList[] ; {

	/*
	 * Given a set of curves ALL LYING IN THE SAME PLANE, removes those in
	 * the set which are covered by other curves in the set.
	 * Note : Returns the list of remaining curves in `*outCvList'
	 * allocated by the function.
	 */

	long			sts ;		/* OM completion code.	      */
	int			i,		/* Loop index.		      */
				j,		/* Loop index.		      */
				rm ;		/* Index of entry to remove.  */
	struct IGRbsp_curve	**geoms = NULL ;/* Geometries of input curves.*/
	VSoverlapInfo		ovlInfo ;	/* Overlapping info.	      */
	struct GRsymbology	symb ;		/* Symbology of one element.  */
	char unsigned		style ; 	/* Style of element.	      */

#define GET_LINE_STYLE( index, style ) {\
	om$send( msg	  = message GRvg.GRgetsymb( msg, &symb ),\
		 senderid = inCvList[(index)].objid,\
		 targetid = inCvList[(index)].objid,\
		 targetos = inCvList[(index)].osnum ) ;\
	(style) = symb.display_attr.style ;\
	}

	SetProc( VSdrwRmCoveredCurves ); Begin

#ifdef vsDEBUG
	if( styleHid == styleVis )
		__DBGpr_com( "Same style for hidden and visible curves" ) ;
	else
		__DBGpr_com( "Different style for hidden and visible curves" ) ;
#endif

	/*
	 * Allocate memory for output list.
	 */
	*outCvCount = 0 ;
	if( !( *outCvList = _MALLOC( inCvCount, struct GRid ) ) )
		vs$mem_fail() ;

	/*
	 * Get geometries of input curves.
	 */
	if( !( geoms = _CALLOC( inCvCount, struct IGRbsp_curve * ) ) )
		vs$mem_fail() ;

	for( i=0; i<inCvCount; i++ ) {
		sts = vs$get_geometry( msg	= msg,
				       grobjId	= inCvList + i,
				       grobjEnv = cvEnv,
				       geometry = geoms + i ) ;

		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
	}

	/*
	 * For each input curve, test the overlapping and remove it if needed.
	 */
	for( i=0; i<inCvCount; i++ ) {

	  if( IF_NULL_OBJID( inCvList[i].objid ) ) continue ;

	  __DBGpr_obj( "Curve #0", inCvList[i] ) ;

	  for( j=i+1; j<inCvCount; j++ ) {

	    if( IF_NULL_OBJID( inCvList[i].objid ) ) break ;
	    if( IF_NULL_OBJID( inCvList[j].objid ) ) continue ;

	    __DBGpr_obj( "Curve #1", inCvList[j] ) ;

	    /*
	     * Test curve overlapping.
	     */
	    sts = VSdoCurvesOverlap( msg, geoms[i], geoms[j], &ovlInfo ) ;
	    __CheckRC( sts, *msg, "VSdoCurvesOverlap", wrapup ) ;

	    rm = -1 ;

	    /*
	     * If we have the same style for hidden and visible
	     * curve, remove the smaller curve.
	     */
	    if( styleHid == styleVis ) {

		 switch( ovlInfo.code ) {

		   case VS_K_TOTAL_MATCH	:
			__DBGpr_com( "-> Total match" ) ;
			/*
			 * -------- i
			 * -------- j
			 *
			 * Remove #i line.
			 */
			 rm = i ;
			 break ;

		   case VS_K_0_COVERS_1 :
			__DBGpr_com( "-> 0 covers 1" ) ;
			/*
			 * ------------------- i (0)
			 *	 ---- j (1)
			 *
			 * Remove #j line.
			 */
			 rm = j ;
			 break ;

		   case VS_K_1_COVERS_0 :
			__DBGpr_com( "-> 1 covers 0" ) ;
			/*
			 *	 ---- i (0)
			 * ------------------- j (1)
			 *
			 * Remove #i line.
			 */
			 rm = i ;
			 break ;
			}
	    } else {

		 switch( ovlInfo.code ) {

		   case VS_K_TOTAL_MATCH	:
			__DBGpr_com( "-> Total match" ) ;
			GET_LINE_STYLE( i, style ) ;
			if( style == styleHid ) {
				/*
				 * - - - - - - - - - - - - - i
				 * ------------------------- j
				 *
				 * Remove #i line.
				 */
				rm = i ;
			} else	{
				/*
				 * ------------------------- i
				 * - - - - - - - - - - - - - j
				 *
				 * Remove #j line.
				 */
				rm = j ;
			}
			break ;

		   case VS_K_0_COVERS_1 :
			__DBGpr_com( "-> 0 covers 1" ) ;
			GET_LINE_STYLE( j, style ) ;
			if( style == styleHid ) {
				/*
				 * - - - - - - - - - - - - i (0)
				 *	   - - - j (1)
				 *
				 * ----------------------- i
				 *	   - - - j
				 *
				 * Remove #j line.
				 */
				rm = j ;
			} else {
				GET_LINE_STYLE( i, style ) ;
				if( style == styleHid ) {
					/*
					 *  - - - - - - - - - i
					 *	 ----- j
					 *
					 * Remove #i line.
					 */
					rm = i ;
				} else {
					/*
					 *  ----------------- i
					 *	 ----- j
					 *
					 * Remove #j line.
					 */
					rm = j ;
				}
			}
			break ;

		   case VS_K_1_COVERS_0 :
			__DBGpr_com( "-> 1 covers 0" ) ;
			GET_LINE_STYLE( i, style ) ;
			if( style == styleHid ) {
				/*
				 *	   - - - i (0)
				 * - - - - - - - - - - - - j (1)
				 *
				 *	   - - - i
				 * ----------------------- j
				 *
				 * Remove #i line.
				 */
				rm = i ;
			} else {
				GET_LINE_STYLE( j, style ) ;
				if( style == styleHid ) {
					/*
					 *	 ----- i
					 *  - - - - - - - - - j
					 *
					 * Remove #j line.
					 */
					rm = j ;
				} else {
					/*
					 *	 ----- i
					 *  ----------------- j
					 *
					 * Remove #i line.
					 */
					rm = i ;
				}
			}
			break ;
		}
	    }
	    if( ovlInfo.count ) {
		_FREE( ovlInfo.t0start ) ; ovlInfo.t0start = NULL ;
	    }
	    if( rm != -1 ) {
			__DBGpr_obj( "Remove", inCvList[rm] ) ;

			vs$bulk_delete( grids  = inCvList + rm,
					theEnv = cvEnv ) ;

			inCvList[rm].objid = NULL_OBJID ;
	    }
	  } /* for j */
	} /* for i */

	/*
	 * Compress list.
	 */
	for( i=0; i<inCvCount; i++ ) {
		if( !IF_NULL_OBJID( inCvList[i].objid ) ) {
			(*outCvList)[(*outCvCount)++] = inCvList[i] ;
		}
	}

	__DBGpr_objlist( "Kept curves", *outCvCount, *outCvList ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup	:
		if( geoms ) _LOOPFREE( geoms, inCvCount ) ;

		if( !(sts & 1 & *msg) ) {
			_FREE( *outCvList ) ;
			*outCvList  = NULL ;
			*outCvCount = 0 ;
		}

		End
		return sts ;

#undef GET_LINE_STYLE

} /* VSdrwRmCoveredCurves */
/*----------------------------------------------------------------------------*/
long VSdrwMakeSfContourCompCurve( msg, sfId, sfEnv, compEnv, compId )

long		*msg ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
struct GRmd_env *compEnv ;
struct GRid	*compId ; {

	/*
	 * This function returns in 'compId' the composite curve of the
	 * surface contour.
	 */

	long		sts ;		/* OM completion code.		      */
	int		i ;		/* Loop index.			      */
	struct GRid	*edList = NULL, /* List of contour edges of surface.  */
			*grList = NULL ;/* List of copy of graphic contour    */
					/* edges.			      */
	int		edCount ;	/* Count of contour edges.	      */

	SetProc( VSdrwMakeSfContourCompCurve ); Begin

	__DBGpr_obj( "Surface", *sfId ) ;

	compId->osnum = compEnv->_MD_OS ;
	compId->objid = NULL_OBJID ;

	/*
	 * Get contour edges of surface.
	 */
	sts = vs$get_surface_edges( msg 	= msg,
				    sfId	= sfId,
				    sfEnv	= sfEnv,
				    edgeType	= VS_K_CONTOUR_EDGES,
				    edCount	= &edCount,
				    edList	= &edList ) ;

	__CheckRC( sts, *msg, "vs$get_surface_edges", wrapup )

	__DBGpr_int( "Count of contour edge", edCount ) ;

	/*
	 * Construct a list of copy of graphic contour edges.
	 */
	if( !( grList = _MALLOC( edCount, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( compEnv->_MD_OS, edCount, grList ) ;

	for( i=0; i<edCount; i++ ) {

		__DBGpr_obj( "Contour edge of surface", edList[i] ) ;

		/*
		 * Get the copy of graphic of contour's edge.
		 */
		sts = vs$get_graphic_edge( msg	   = msg,
					   edId    = edList + i,
					   edEnv   = sfEnv,
					   copy    = TRUE,
					   copyEnv = compEnv,
					   grEdge  = grList + i ) ;

		__CheckRC( sts, *msg, "vs$get_graphic_edge", wrapup ) ;

		__DBGpr_obj( "Copy of graphic edge", grList[i] ) ;
	}

	/*
	 * Create a composite curve of contour if we have more than one copy
	 * of graphic contour's edge. Otherwise, return the copy of graphic
	 * contour edge.
	 */
	if( edCount > 1 ) {
		sts = vs$makeCompCurve( msg	= msg,
					cvList	= grList,
					cvCount = edCount,
					cvEnv	= compEnv,
					compEnv = compEnv,
					compCv	= compId ) ;

		__CheckRC( sts, *msg, "vs$makeCompCurve", wrapup ) ;

		__DBGpr_obj( "Composite curve of contour", *compId ) ;

	} else {
		*compId = grList[0] ;

		__DBGpr_obj( "Contour of surface", *compId ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !(sts & 1 & *msg) ) {
			if( grList )
				vs$bulk_delete( count	= edCount,
						grids	= grList,
						theEnv	= compEnv ) ;

			compId->osnum = compEnv->_MD_OS ;
			compId->objid = NULL_OBJID ;
		}

		_FREE( edList ) ;
		_FREE( grList ) ;

		End
		return sts ;

} /* VSdrwMakeSfContourCompCurve */
/*----------------------------------------------------------------------------*/
long VSdrwIsPlateOrthogonalToPlate( msg, plId0, plEnv0, plId1, plEnv1,
				    orthogonal )

long		*msg ;
struct GRid	*plId0 ;
struct GRmd_env *plEnv0 ;
struct GRid	*plId1 ;
struct GRmd_env *plEnv1 ;
int		*orthogonal ; {

	/*
	 * This function returns TRUE in '*orthogonal' if plate #0 (plId0,
	 * plEnv0) is orthogonal to plate #1 (plId1, plEnv1). Otherwise
	 * '*orthogonal' is FALSE.
	 */

	long		sts ;		/* OM completion code.		*/
	long		rc ;		/* Additional return code	*/
	IGRvector	normal0,	/* Normal of bot sd of plate #0 */
			normal1 ;	/* Normal of bot sd of plate #1 */

	SetProc( VSdrwIsPlateOrthogonalToPlate ); Begin

	__DBGpr_obj( "Plate #0", *plId0 ) ;
	__DBGpr_obj( "Plate #1", *plId1 ) ;

	*orthogonal = FALSE ;

	/*
	 * Get normal of bottom side of source of plate #0.
	 */
	sts = om$send(	msg	 = message VSfeature.VSforwardToSource(
				&rc,
				OM_e_wrt_object,
				message VSfeature.VSgetNormalOfComponent(
					msg, plEnv0, VS_K_plBotSfPath,
					0.5, 0.5, normal0 ) ),
			senderid= plId0->objid,
			targetid= plId0->objid,
			targetos= plId0->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToSource", wrapup ) ;
	__DBGpr_vec( "Normal of bottom side #0", normal0 ) ;

	/*
	 * Get normal of bottom side of source of plate #1.
	 */
	sts = om$send(	msg	 = message VSfeature.VSforwardToSource(
				msg,
				OM_e_wrt_object,
				message VSfeature.VSgetNormalOfComponent(
					msg, plEnv1, VS_K_plBotSfPath,
					0.5, 0.5, normal1 ) ),
			senderid= plId1->objid,
			targetid= plId1->objid,
			targetos= plId1->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToSource", wrapup ) ;
	__DBGpr_vec( "Normal of bottom side #1", normal1 ) ;

	/*
	 * See if the two normals are orthogonal. Thus, in this case, the
	 * two plates are orthogonal.
	 */
#define TWO_DEGREES ( 2. / 180. * M_PI )
	if( VSareaOrthoVectors( normal0, normal1, TWO_DEGREES ) ) {
		__DBGpr_com( "Plate #0 is ORTHOGONAL to plate #1" ) ;
		*orthogonal = TRUE ;
	} else {
		__DBGpr_com( "Plate #0 is NOT ORTHOGONAL to plate #1" ) ;
		*orthogonal = FALSE ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSdrwIsPlateOrthogonalToPlate */
/*----------------------------------------------------------------------------*/
long VSdrwIsPlateHiddenByPlate( msg, plId0, plEnv0, plId1, plEnv1, viewVector,
				hidden )

long		*msg ;
struct GRid	*plId0 ;
struct GRmd_env *plEnv0 ;
struct GRid	*plId1 ;
struct GRmd_env *plEnv1 ;
IGRvector	viewVector ;
int		*hidden ; {

	/*
	 * This function tests if plate #0 (plId0, plEnv0) is hidden
	 * (*hidden = TRUE) or not (*hidden = FALSE) by plate #1 (plId1,
	 * plEnv1).
	 *
	 *	   ^
	 *	   |	    <- View vector ( Plate #0 is HIDDEN ).
	 *
	 *	---------
	 *	|	|   <- Plate #1.
	 *	---------
	 *	  |  |
	 *	  |  |	    <- Plate #0.
	 *	  |  |
	 *	  ----
	 *
	 *	   |	    <- View vector ( Plate #0 is NOT HIDDEN ).
	 *	   v
	 */

	long		sts ;		/* OM completion code.		      */
	struct GRid	botSd1 ;	/* Bottom side of plate #1.	      */
	GRrange 	range0 ;	/* Range of plate #0.		      */
	short		world = TRUE ;	/* Compute range in world coordinate. */
	IGRpoint	midPnt0 ;	/* Middle point of plate #0.	      */

	SetProc( VSdrwIsPlateHiddenByPlate ); Begin

	__DBGpr_obj( "Plate #0", *plId0 ) ;
	__DBGpr_obj( "Plate #1", *plId1 ) ;
	__DBGpr_mat( "Mx #0", plEnv0->_MATRIX ) ;
	__DBGpr_mat( "Mx #1", plEnv1->_MATRIX ) ;

	*hidden = FALSE ;

	/*
	 * Get middle point of plate #0.
	 */
	sts = om$send( msg	= message GRgraphics.GRgetrang(
							  msg,
							  &plEnv0->_MATRIX_TYPE,
							  plEnv0->_MATRIX,
							  &world,
							  range0 ),
		       senderid = plId0->objid,
		       targetid = plId0->objid,
		       targetos = plId0->osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Range pt 0", range0 + 0 ) ;
	__DBGpr_vec( "Range pt 1", range0 + 3 ) ;

	midPnt0[0] = ( range0[0] + range0[3] ) * 0.5 ;
	midPnt0[1] = ( range0[1] + range0[4] ) * 0.5 ;
	midPnt0[2] = ( range0[2] + range0[5] ) * 0.5 ;

	__DBGpr_vec( "Middle point of plate #0", midPnt0 ) ;

	/*
	 * Get bottom side of source of plate #1.
	 */

	sts = om$send( msg	 = message VSfeature.VSforwardToSource(
						 msg,
						 OM_e_wrt_object,
						 message NDmacro.ACreturn_foot(
							       msg,
							       VS_K_plBotSfPath,
							       &botSd1,
							       NULL,
							       NULL )),
			senderid = plId1->objid,
			targetid = plId1->objid,
			targetos = plId1->osnum ) ;

	__CheckRC( sts, *msg, "VSfeature.VSforwardToSource", wrapup ) ;

	__DBGpr_obj( "Bottom side of source of plate #1", botSd1 ) ;

	/*
	 * See if middle point of plate #0 is hidden by bottom side of plate #1.
	 * Thus, in this case, plate #0 is hidden by plate #1, otherwise
	 * plate #0 is not hidden by plate #1.
	 */
	sts = VSdrwIsPtHiddenBySf( msg,
				   &botSd1,
				   plEnv1,
				   midPnt0,
				   viewVector,
				   hidden ) ;

	__CheckRC( sts, *msg, "VSdrwIsPtHiddenBySf", wrapup ) ;

	if( *hidden ) { __DBGpr_com( "Plate #0 is HIDDEN by plate #1"	) ; }
	else	      { __DBGpr_com( "Plate #0 is NOT HIDDEN by plate #1" ) ; }

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSdrwIsPlateHiddenByPlate */
/*----------------------------------------------------------------------------*/
long VSdrwRmEqualPoints( msg, inElmCount, inElmList, elmEnv, outElmCount,
			 outElmList )

long		*msg ;
int		inElmCount ;
struct GRid	inElmList[] ;
struct GRmd_env *elmEnv ;		/* Env of all elements. */
int		*outElmCount ;
struct GRid	*outElmList[] ; {

	/*
	 * Given a list of elements (inElmCount, inElmList), this function
	 * removes points in the list which are equal to other points in the
	 * list.
	 * Note : Returns the list of remaining elements in `*outElmList',
	 * allocated by the function.
	 */

	long			sts ;	  /* OM completion code.	      */
	int			i,	  /* Loop index.		      */
				j ;	  /* Loop index.		      */
	struct IGRpolyline	pol0,	  /* Polyline geometry of element     */
					  /* point #0.			      */
				pol1 ;	  /* Polyline geometry of element     */
					  /* point #1.			      */
	int			action ;  /* Point is wanted.		      */
	IGRpoint		point0,   /* Coordinates of element point #0. */
				point1 ;  /* Coordinates of element point #1. */
	int			hav2Pnt ; /* Have two points in the input     */
					  /* list ?			      */

#define IS_A_POINT( p_object )\
	vs$is_ancestry_valid( object  = (p_object),\
			      classid = OPP_GRpoint_class_id )

	SetProc( VSdrwRmEqualPoints ); Begin

	*outElmCount = 0 ;
	*outElmList  = NULL ;

	pol0.points = point0 ;
	pol1.points = point1 ;

	action = 1 ;

	/*
	 * Remove equal points.
	 */
	__DBGpr_int( "Count of input elements", inElmCount ) ;

	for( i=0; i<inElmCount; i++ ) {

		__DBGpr_obj( "Element #0", inElmList[i] ) ;

		/*
		 * See if element #0 is a point.
		 */
		__DBGpr_com( "Is a point ?" ) ;

		if( !IS_A_POINT( inElmList + i ) ) {
			__DBGpr_com( "\t-> No" ) ;
			continue ;
		}

		/*
		 * Get coordinates of point #0.
		 */
		sts = om$send( msg	= message GRlinear.GRgetpolyline(
							  msg,
							  &elmEnv->_MATRIX_TYPE,
							  elmEnv->_MATRIX,
							  &action,
							  &pol0 ),
			       senderid = inElmList[i].objid,
			       targetid = inElmList[i].objid,
			       targetos = inElmList[i].osnum ) ;

		__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;

		__DBGpr_vec( "\t-> Yes", point0 ) ;

		hav2Pnt = FALSE ;

		for( j=i+1; j<inElmCount; j++ ) {

			__DBGpr_obj( "Element #1", inElmList[j] ) ;

			/*
			 * See if element #1 is a point.
			 */
			__DBGpr_com( "Is a point ?" ) ;

			if( !IS_A_POINT( inElmList + j ) ) {
				__DBGpr_com( "\t-> No" ) ;
				continue ;
			}

			hav2Pnt = TRUE ;

			/*
			 * Get coordinates of point #1.
			 */
			sts = om$send( msg	= message GRlinear.GRgetpolyline(
							  msg,
							  &elmEnv->_MATRIX_TYPE,
							  elmEnv->_MATRIX,
							  &action,
							  &pol1 ),
				       senderid = inElmList[j].objid,
				       targetid = inElmList[j].objid,
				       targetos = inElmList[j].osnum ) ;

			__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup );

			__DBGpr_vec( "\t-> Yes", point1 ) ;

			/*
			 * If point #0 is equal to point #1, remove point #0.
			 */
			__DBGpr_com( "Is same point ?" ) ;

			if( !VSeqPoints( point0, point1 ) ) {
				__DBGpr_com( "\t-> No" ) ;
				continue ;
			}

			__DBGpr_com( "\t-> Yes, Remove point #0" ) ;

			vs$bulk_delete( count  = 1,
					grids  = inElmList + i,
					theEnv = elmEnv ) ;

			break ;
		}

		if( !hav2Pnt ) break ;
	}

	/*
	 * Compress output list.
	 */
	if( !( *outElmList = _MALLOC( inElmCount, struct GRid ) ) )
		vs$mem_fail() ;

	for( i=0; i<inElmCount; i++ ) {
		if( !IF_NULL_OBJID( inElmList[i].objid ) ) {
			(*outElmList)[(*outElmCount)++] = inElmList[i] ;
		}
	}

	__DBGpr_objlist( "Kept elements", *outElmCount, *outElmList ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

#undef IS_A_POINT

} /* VSdrwRmEqualPoints */
/*----------------------------------------------------------------------------*/
long VSdrwIsCurveParallelToVwPlane( msg, cvId, cvEnv, viewPlane, parallel )

long		*msg ;
struct GRid	*cvId ;
struct GRmd_env *cvEnv ;
struct IGRplane *viewPlane ;
int		*parallel ; {

	/*
	 * This function returns '*parallel = TRUE' if the given curve is
	 * parallel to the view plane, otherwise, returns '*parallel = FALSE'.
	 */

	long			sts,	  /* OM completion code.	      */
				rc ;	  /* BS return code.		      */
	int			isLinear ;/* Is input curve linear ?	      */
	double			pntTng[6];/* Point and tangent at middle of   */
					  /* input curve.		      */
	struct IGRbsp_curve	*cvGeom ; /* Geometry of input curve.	      */
	struct IGRplane 	plane ;   /* Plane from no linear input curve.*/
	IGRvector		normal ;  /* Normal of the above.	      */
	IGRpoint		point ;   /* Point of the above.	      */

	SetProc( VSdrwIsCurveParallelToVwPlane ); Begin

	__DBGpr_obj( "Curve", *cvId ) ;
	__DBGpr_vec( "Normal of view plane", viewPlane->normal ) ;

	*parallel = FALSE ;
	cvGeom	  = NULL ;

	/*
	 * Get geometry of curve.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * See if the input curve is linear.
	 */
	isLinear = vs$is_curve_linear( msg	 = msg,
				       curveGeom = cvGeom ) ;

	if( isLinear ) {
		__DBGpr_com( "Curve is linear" ) ;

		/*
		 * Get tangent at middle of curve.
		 */
		BScveval( cvGeom, 0.5, 1, (IGRpoint *) pntTng, &rc ) ;

		if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

		__DBGpr_vec( "Tangent of curve", pntTng +3 ) ;

		/*
		 * If tangent of curve is orthogonal to normal of view plane,
		 * the curve is parallel to view plane.
		 */
		if( VSorthoVectors( pntTng +3, viewPlane->normal ) )
			*parallel = TRUE ;

	} else {
		__DBGpr_com( "Curve isn't linear" ) ;

		/*
		 * Get plane from input curve.
		 */
		plane.normal = normal ;
		plane.point  = point ;

		sts = om$send( msg	= message GRvg.GRdetplane(
							   msg,
							   &cvEnv->_MATRIX_TYPE,
							   cvEnv->_MATRIX,
							   &plane ),
			       senderid = cvId->objid,
			       targetid = cvId->objid,
			       targetos = cvId->osnum ) ;

		if( *msg == MSSUCC ) {
			__DBGpr_vec( "Normal of plane", normal ) ;
			__DBGpr_vec( "Point  of plane", point  ) ;

			/*
			 * If the normal of the plane is colinear to normal
			 * of view plane, the curve is parallel to view plane.
			 */
			if( VScolinearVectors( normal, viewPlane->normal ) )
				*parallel = TRUE ;

		} else if( *msg == MSFAIL )
			 __CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;
	}

	__DBGpr_int( "Is curve parallel to view plane ?", *parallel ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( cvGeom ) ;

		End
		return sts ;

} /* VSdrwIsCurveParallelToVwPlane */
/*----------------------------------------------------------------------------*/
long VSdrwIsSolidOrSurface( msg, elmId, elmEnv, sol1_surf0 )

long		*msg ;
struct GRid	*elmId ;
struct GRmd_env *elmEnv ;
int		*sol1_surf0 ; {

	/*
	 * Given an element ( elmId, elmEnv ), this function returns TRUE in
	 * argument '*sol1_surf0' if element is a solid, ortherwise if element
	 * is a surface returns FALSE.
	 *
	 * Note :
	 * ------
	 *	If element isn't a solid or a surface 'msg' is equal to
	 *	EMS_E_InvalidArg.
	 */

	long		sts ;	     /* OM completion code.		      */
	struct GRprops	properties ; /* Geometric properties of element.      */

	SetProc( VSdrwIsSolidOrSurface ); Begin

	__DBGpr_obj( "Element", *elmId ) ;

	/*
	 * Get geometric properties of element.
	 */
	sts = om$send( msg	= message GRvg.GRgeomprops(
							  msg,
							  &elmEnv->_MATRIX_TYPE,
							  elmEnv->_MATRIX,
							  &properties ),
		       senderid = elmId->objid,
		       targetid = elmId->objid,
		       targetos = elmId->osnum ) ;
	if( !( sts & 1 & *msg ) ) {
		__DBGpr_com( "Not a solid or surface" ) ;
		vs$inv_arg() ;
	}

	/*
	 * Even if element is a solid, the properties type is set to GRSURFACE.
	 * So, to see if element is a solid, we have to check its classid.
	 */
	if( properties.type != GRSURFACE ) {
		__DBGpr_com( "Not a solid or surface" ) ;
		vs$inv_arg() ;
	} else	*sol1_surf0 = FALSE ;

	if( vs$is_ancestry_valid( object  = elmId,
				  classid = OPP_EMSsolid_class_id ) )
		*sol1_surf0 = TRUE ;

	__DBGpr_int( "Is a solid ?", *sol1_surf0 ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSdrwIsSolidOrSurface */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;
