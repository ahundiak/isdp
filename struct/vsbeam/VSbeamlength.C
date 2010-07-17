/* $Id: VSbeamlength.C,v 1.1.1.1 2001/01/04 21:10:11 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSbeamlength.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbeamlength.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:11  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/02/04  23:05:02  pinnacle
 * Replaced: vsbeam/VSbeamlength.C for:  by svkadamb for struct
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.4  1996/05/07  13:20:08  pinnacle
 * Replaced: vsbeam/VSbeamlength.C for:  by s240_int for struct
 *
 * Revision 1.3  1996/01/31  06:53:16  pinnacle
 * Replaced: vsbeam/VSbeamlength.C for:  by svkadamb for struct
 *
 * Revision 1.2  1996/01/31  06:48:02  pinnacle
 * Replaced: vsbeam/VSbeamlength.C for:  by svkadamb for struct
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
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "msdef.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "bspl_cv_int.h"
#include "bsalloccv.h"
#include "bsconstprcv.h"
#include "bscveval.h"
#include "bsfreecv.h"
#include "bsprptoncv.h"
#include "bsarclen.h"
#include "bssfeval.h"
#include "bsdotp.h"
#inclued "vsvecmxproto.h"

#define ANGLE		20.	/* Angle in radians. */

extern OMuword	OPP_EMSsolid_class_id ;

/*----------------------------------------------------------------------------*/
static long VSfindExtremaPointsOntoDirection( msg, surface, direction, extPts )

long			*msg ;
struct IGRbsp_surface	*surface ;
double			*direction,
			extPts[2] ; {

	long		sts,
			bsRC ;
	IGRpoint	ptOnSf ;
	double		ptOnDi ;

	extPts[0] = MAXDOUBLE ;
	extPts[1] = -MAXDOUBLE ;

	/*
	 * U=0, V=0.
	 */
	BSsfeval( surface, 0., 0., 0, (IGRpoint *) ptOnSf, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	ptOnDi = BSdotp( &bsRC, ptOnSf, direction ) ;

	if( ptOnDi < extPts[0] ) extPts[0] = ptOnDi ;
	if( ptOnDi > extPts[1] ) extPts[1] = ptOnDi ;

	/*
	 * U=0, V=1.
	 */
	BSsfeval( surface, 0., 1., 0, (IGRpoint *) ptOnSf, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	ptOnDi = BSdotp( &bsRC, ptOnSf, direction ) ;

	if( ptOnDi < extPts[0] ) extPts[0] = ptOnDi ;
	if( ptOnDi > extPts[1] ) extPts[1] = ptOnDi ;

	/*
	 * U=1, V=1.
	 */
	BSsfeval( surface, 1., 1., 0, (IGRpoint *) ptOnSf, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	ptOnDi = BSdotp( &bsRC, ptOnSf, direction ) ;

	if( ptOnDi < extPts[0] ) extPts[0] = ptOnDi ;
	if( ptOnDi > extPts[1] ) extPts[1] = ptOnDi ;

	/*
	 * U=1, V=0.
	 */
	BSsfeval( surface, 1., 0., 0, (IGRpoint *) ptOnSf, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	ptOnDi = BSdotp( &bsRC, ptOnSf, direction ) ;

	if( ptOnDi < extPts[0] ) extPts[0] = ptOnDi ;
	if( ptOnDi > extPts[1] ) extPts[1] = ptOnDi ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSfindExtremaPointsOntoDirection */
/*----------------------------------------------------------------------------*/
static int VSpl_cv_int( curve, point, normal, pm )

struct IGRbsp_curve	*curve ;
double			*point,
			*normal,
			*pm ; {

	/*
	 * This function intersects the curve ( curve ) and the plane ( point,
	 * normal ). It returns TRUE and the parameter ( pm ) of the
	 * intersection point if the curve and the plane intersect, otherwise
	 * it returns FALSE.
	 */

	long		bsRC ;
	int		n_int,
			n_seg,
			intersect   = FALSE ;
	double		*int_points = NULL,
			*u	    = NULL,
			*a	    = NULL,
			*b	    = NULL ;

	if( ! curve->num_poles )
		goto wrapup ;

	if( !( int_points = _MALLOC( 3*curve->num_poles, double )))
		goto wrapup ;

	if( !( u	  = _MALLOC( curve->num_poles,	 double )))
		goto wrapup ;

	if( !( a	  = _MALLOC( curve->num_poles,	 double )))
		goto wrapup ;

	if( !( b	  = _MALLOC( curve->num_poles,	 double )))
		goto wrapup ;

	BSpl_cv_int( &bsRC,
		     curve,
		     point,
		     normal,
		     &n_int,
		     int_points,
		     u,
		     &n_seg,
		     a,
		     b ) ;

	if( BSOKAY( bsRC ) && n_int ) {
		*pm	  = u[0] ;
		intersect = TRUE ;
	}

	wrapup :
		_FREE( int_points ) ;
		_FREE( u	  ) ;
		_FREE( a	  ) ;
		_FREE( b	  ) ;

		return intersect ;

} /* VSpl_cv_int */
/*----------------------------------------------------------------------------*/
static int VShavePtInList( pt, list, nb )

double	*pt,
	*list ;
int	nb ; {

	int	i ;

	for( i=0; i<nb; i++ ) if( VSeqPoints( pt, list +3*i ) ) break ;

	if( i < nb ) return TRUE ;
	else return FALSE ;

} /* VShavePtInList */
/*----------------------------------------------------------------------------*/
long VSgetVerticesOfSurface( msg, sfId, sfEnv, nbVertices, vertices )

long		*msg ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
int		*nbVertices ;
double		**vertices ; {

	long			sts,
				bsRC ;
	int			i,
				edCount = 0 ;
	struct GRid		*edList = NULL,
				grEdge ;
	struct IGRbsp_curve	*edGeom = NULL ;
	double			endPt[3] ;

	*nbVertices = 0 ;
	*vertices   = NULL ;
	
	grEdge.objid = NULL_OBJID ;

	/*
	 * Get contour edges of surface.
	 */
	sts = vs$get_surface_edges( msg 	= msg,
				    sfId	= sfId,
				    sfEnv	= sfEnv,
				    edgeType	= VS_K_CONTOUR_EDGES,
				    edCount	= &edCount,
				    edList	= &edList ) ;

	__CheckRC( sts, *msg, "vs$get_surface_edges", wrapup ) ;

	/*
	 * Allocate memory for vertices.
	 */
	if( !( *vertices = _MALLOC( 2*3*edCount, double ) ) ) vs$mem_fail() ;

	/*
	 * For each edges, find end points.
	 */
	for( i=0; i<edCount; i++ ) {

		sts = vs$get_graphic_edge( msg		= msg,
					   edId 	= edList +i,
					   edEnv	= sfEnv,
					   grEdge	= &grEdge ) ;
//		__CheckRC( sts, *msg, "vs$get_graphic_edge", wrapup ) ;
		/*
		 * Do not  exit on failure to get the graphic edge continue
		 * the process and check for other edges.
		 */
		if( !( sts & *msg & 1 ) )  continue;

		sts = vs$get_geometry( msg	= msg,
				       grobjId	= &grEdge,
				       grobjEnv = sfEnv,
				       geometry = &edGeom ) ;

		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		vs$bulk_delete( grids = &grEdge, theEnv = sfEnv ) ;

		BScveval( edGeom, 0., 0, (IGRpoint *) endPt, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		if( !VShavePtInList( endPt, *vertices, *nbVertices ) ) {
			VSvccpy( *vertices +3*(*nbVertices), endPt ) ;
			(*nbVertices)++ ;
		}

		BScveval( edGeom, 1., 0, (IGRpoint *) endPt, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		if( !VShavePtInList( endPt, *vertices, *nbVertices ) ) {
			VSvccpy( *vertices +3*(*nbVertices), endPt ) ;
			(*nbVertices)++ ;
		}

		_FREE( edGeom ) ;
		edGeom = NULL ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *vertices ) ;
			*vertices   = NULL ;
			*nbVertices = 0 ;
		}

		vs$bulk_delete( grids = &grEdge, theEnv = sfEnv ) ;

		_FREE( edList ) ;
		_FREE( edGeom ) ;

		return sts ;

} /* VSgetVerticesOfSurface */
/*----------------------------------------------------------------------------*/
long VSgetSurfaceLengthAlongDirection( msg, sfId, sfEnv, direction, length )

long		*msg ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
double		*direction,
		*length ; {

	/*
	 * Given a surface ( sfId, sfEnv ), this function returns the arclength
	 * of the surface ( length ) along a direction vector ( direction ).
	 *
	 *	 ----------------- <- Surface.
	 *	/		/.
	 *     /	       / .	 ===>
	 *    / 	      /  .	  ^
	 *   -----------------	 .	  |
	 *   .			 .    Direction.
	 *   .<----------------->.
	 *	    length
	 */

	long			sts,
				bsRC ;
	int			i,
				j,
				k,
				nbValidEdges = 0,
				nbVertices   = 0 ;
	double			uv,
				tanAt05[6],
				*vertices    = NULL,
				pm,
				pntAndNor[6],
				dir,
				arclength ;
	short			tst_plan     = FALSE,
				opt,
				verticeOnNatEdge,
				status ;
#define NB_NAT_EDGES	4
	struct IGRbsp_curve	*natEdge[NB_NAT_EDGES] = { NULL,
							   NULL,
							   NULL,
							   NULL } ;
	double			carPm[NB_NAT_EDGES][2] = { -1., -1.,
							   -1., -1.,
							   -1., -1.,
							   -1., -1. },
					/*				      */
					/* Caracteristic parameters onto      */
					/* natural edges :		      */
					/* 0 : Parameter of start point.      */
					/* 1 : Parameter of end point.	      */
					/*				      */
				lenPm[NB_NAT_EDGES][2] = { -1., -1.,
							   -1., -1.,
							   -1., -1.,
							   -1., -1. } ;
					/*				      */
					/* Parameters to compute arclength of */
					/* natural edges :		      */
					/* 0 : Parameter of start point.      */
					/* 1 : Parameter of end point.	      */
					/*				      */
	struct IGRbsp_surface	*sfGeom = NULL ;

	*length = 0. ;

	/*
	 * Get geometry of surface.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= sfId,
			       grobjEnv = sfEnv,
			       geometry = &sfGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Find natural edges of surface 'parallel' to direction vector.
	 */
	for( i=0; i<NB_NAT_EDGES; i++ ) {

		opt = i < 2 ? 1  : 2  ;
		uv  = i & 1 ? 1. : 0. ;

		BSalloccv( opt == 1 ? sfGeom->v_order : sfGeom->u_order,
			   opt == 1 ? sfGeom->v_num_poles : sfGeom->u_num_poles,
			   sfGeom->rational,
			   sfGeom->num_boundaries,
			   natEdge +nbValidEdges,
			   &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		BSconstprcv( &bsRC,
			     sfGeom,
			     &opt,
			     &uv,
			     &tst_plan,
			     natEdge[nbValidEdges] ) ;

		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		BScveval( natEdge[nbValidEdges],
			  0.5,
			  1,
			  (IGRpoint *) tanAt05,
			  &bsRC ) ;

		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		if( VSareaColinearVectors( direction,
					   tanAt05 +3,
					   ANGLE * M_PI/180. ) ) {
			nbValidEdges++ ;
		} else {
			BSfreecv( &bsRC, natEdge[nbValidEdges] ) ;
			natEdge[nbValidEdges] = NULL ;
		}
	}

	if( !nbValidEdges ) {
		*length = 0. ;
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
		goto wrapup ;
	}

	/*
	 * Find vertices of surface.
	 */
	sts = VSgetVerticesOfSurface( msg,
				      sfId,
				      sfEnv,
				      &nbVertices,
				      &vertices ) ;
	__CheckRC( sts, *msg, "VSgetVerticesOfSurface", wrapup ) ;


	/*
	 * Find caracteristic points on natural edges.
	 */
	for( i=0; i<nbValidEdges; i++ ) {

		for( j=0; j<nbVertices; j++ ) {

			BSprptoncv( &bsRC,
				    natEdge[i],
				    vertices +3*j,
				    &pm,
				    &verticeOnNatEdge ) ;

			if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror);

			if( !verticeOnNatEdge ) continue ;

			if( carPm[i][0] == -1. && carPm[i][1] == -1. ) {
				carPm[i][0] = pm ;
				carPm[i][1] = pm ;
				continue ;
			}

			if( pm < carPm[i][0] ) carPm[i][0] = pm ;

			if( pm > carPm[i][1] ) carPm[i][1] = pm ;
		}
	}

	/*
	 * Find parameters to compute arclength of natural edges and
	 * get arclength between this two parameters.
	 */
	for( i=0; i<nbValidEdges; i++ ) {

		lenPm[i][0] = carPm[i][0] ;
		lenPm[i][1] = carPm[i][1] ;

		for( j=0; j<nbValidEdges; j++ ) {
			if( i == j ) continue ;

			for( k=0; k<2; k++ ) {
				BScveval( natEdge[j],
					  carPm[j][k],
					  1,
					  (IGRpoint *) pntAndNor,
					  &bsRC ) ;
				if( BSERROR( bsRC ) ) continue ;

				if( !VSpl_cv_int( natEdge[i],
						  pntAndNor,
						  pntAndNor +3,
						  &pm ) ) continue ;

				if( pm < lenPm[i][0] ) lenPm[i][0] = pm ;
				if( pm > lenPm[i][1] ) lenPm[i][1] = pm ;
			}
		}

		dir = ( lenPm[i][0] + lenPm[i][1] ) / 2 ;

		BSarclen( &bsRC,
			  &status,
			  natEdge[i],
			  lenPm[i],
			  lenPm[i] +1,
			  &dir,
			  &arclength ) ;
		if( BSERROR( bsRC ) ) continue ;

		if( arclength > *length ) *length = arclength ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		for( i=0; i<NB_NAT_EDGES; i++ ) BSfreecv( &bsRC, natEdge[i] ) ;
		_FREE( sfGeom	) ;
		_FREE( vertices ) ;

		return sts ;

} /* VSgetSurfaceLengthAlongDirection */
/*----------------------------------------------------------------------------*/
long VSgetSolidBeamLength( msg, solidId, solidEnv, direction, length )

long		*msg ;
struct GRid	*solidId ;
struct GRmd_env *solidEnv ;
double		*direction,
		*length ; {

	/*
	 * Given the solid of a beam, this function returns the length of
	 * the beam.
	 *
	 * Note :
	 * ======
	 *	'direction' is the tangent of the beam's axis at parameter
	 *	u=0.5
	 */

	long			sts ;
	int			i,
				j,
				surfCount ;
	struct GRid		*surfaces = NULL ;
	double			*extPts   = NULL,
				deltaMax,
				ptMin,
				ptMax,
				middle,
				surfLength,
				subLength ;
	struct IGRbsp_surface	*sfGeom   = NULL ;

	*length = 0. ;

	/*
	 * See if we have really a solid.
	 */
	if( !vs$is_ancestry_valid( object  = solidId,
				   classid = OPP_EMSsolid_class_id ) )
		vs$inv_arg() ;

	/*
	 * Get components surfaces.
	 */
	sts = vs$get_components( msg		= msg,
				 grobjId	= solidId,
				 grobjEnv	= solidEnv,
				 number 	= &surfCount,
				 components	= &surfaces ) ;

	__CheckRC( sts, *msg, "vs$get_components", wrapup ) ;

	/*
	 * Find extrema points of each component surface onto direction
	 * vector.
	 */
	if( !( extPts = _MALLOC( 2*surfCount, double ) ) ) vs$mem_fail() ;

	for( i=0; i<surfCount; i++ ) {

		sts = vs$get_geometry( msg	= msg,
				       grobjId	= surfaces +i,
				       grobjEnv = solidEnv,
				       geometry = &sfGeom ) ;

		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		sts = VSfindExtremaPointsOntoDirection( msg,
							sfGeom,
							direction,
							extPts +2*i ) ;

		__CheckRC( sts, *msg, "VSfindExtremaPointsOntoDirection",
			   wrapup ) ;

		_FREE( sfGeom ) ;
		sfGeom = NULL ;
	}

	/*
	 * Take maximum length of surfaces which have their middle point of
	 * their extrema points onto bigger delta extrema points. In fact,
	 * take maximum length of surfaces which is a part of boolean solid.
	 *
	 *	   ------------------------- <- boolean solid.
	 *	  /	  /	  /	  /|
	 *	 /	 /	 /	 / |
	 *	-------------------------  /
	 *	| S0	| S1	| S2	| /
	 *	|	|	|	|/
	 *	-------------------------
	 *
	 *		---> direction.
	 *
	 *	S0, S1, S2 : Solids of boolean solid.
	 *
	 *	Length of this solid is :
	 *		maximum length of surfaces which compose solid S0 +
	 *		maximum length of surfaces which compose solid S1 +
	 *		maximum length of surfaces which compose solid S2.
	 */
	for( i=0; i<surfCount; i++ ) {

		if( extPts[2*i]   == -MAXDOUBLE &&
		    extPts[2*i+1] == MAXDOUBLE	) continue ;

		deltaMax = 0. ;
		ptMin	 = MAXDOUBLE ;
		ptMax	 = -MAXDOUBLE ;

		/*
		 * Find the bigger delta extrema points.
		 */
		for( j=0; j<surfCount; j++ ) {

			if( extPts[2*j]   == -MAXDOUBLE &&
			    extPts[2*j+1] == MAXDOUBLE	) continue ;

			if( ( extPts[2*j+1] - extPts[2*j] ) > deltaMax ) {
				deltaMax = extPts[2*j+1] - extPts[2*j] ;
				ptMin	 = extPts[2*j] ;
				ptMax	 = extPts[2*j+1] ;
			}
		}

		/*
		 * Find maximum length of surfaces which have their middle
		 * point of their extrema points onto delta extrema points.
		 */
		subLength = 0. ;

		for( j=0; j<surfCount; j++ ) {

			if( extPts[2*j]   == -MAXDOUBLE &&
			    extPts[2*j+1] == MAXDOUBLE	) continue ;

			middle = ( extPts[2*j] + extPts[2*j+1] ) * 0.5 ;

			if( middle > ptMin && middle < ptMax ) {

				extPts[2*j]   = -MAXDOUBLE ;
				extPts[2*j+1] = MAXDOUBLE ;

				sts = VSgetSurfaceLengthAlongDirection(
								 msg,
								 surfaces +j,
								 solidEnv,
								 direction,
								 &surfLength ) ;

				if( !( sts & 1 & *msg ) ) continue ;

				if( surfLength > subLength )
					subLength = surfLength ;
			}
		}

		*length += subLength ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) *length = 0. ;

		_FREE( surfaces ) ;
		_FREE( extPts	) ;
		_FREE( sfGeom	) ;

		return sts ;

} /* VSgetSolidBeamLength */
/*----------------------------------------------------------------------------*/
