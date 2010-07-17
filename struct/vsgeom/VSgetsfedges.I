/* $Id: VSgetsfedges.I,v 1.1.1.1 2001/01/04 21:10:38 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSgetsfedges.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSgetsfedges.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/07  22:31:24  pinnacle
# Replaced: vsgeom/VSgetsfedges.I for:  by s250_int for struct
#
 *
 * History:
 *      MM/DD/YY	AUTHOR	DESCRIPTIO
 *      04/07/98	adz	Add make_natural_boundaries to call.
 ***************************************************************************/

class implementation EMSsubbs ;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSlcdef.h"
#include "msdef.h"
#include "vsedgedef.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Include of function prototypes.
 */
#include "maidmx.h"

from EMSedge	import EMgetxyzobj ;
/*----------------------------------------------------------------------------*/
long VSgetSurfaceEdges( msg, sfId, sfEnv, edgeType, edCount, edList )

long		*msg ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
int		edgeType,
		*edCount ;
struct GRid	*edList[] ; {

	/*
	 * This function is interfaced by macro 'vs$get_surface_edges',
	 * #define'd in "vsedgemacros.h".
	 */

	long		sts ;			/* OM completion code.	      */
	struct GRid	*allEdgeList = NULL,	/* List of all edges.	      */
			*conEdgeList = NULL ;	/* List of contour edges.     */
	int		i,			/* Loop index.		      */
			j,			/* Loop index.		      */
			allEdgeCount = 0,	/* Count of all edges.	      */
			conEdgeCount = 0,	/* Count of contour edges.    */
			array_size = 0 ;	/* Size of returned list by   */
						/* EMget_edges. 	      */

	*edCount = 0 ;
	*edList  = NULL ;

	sts = vs$make_natural_boundary( msg         =  msg, 
				        surfaceEnv  =  sfEnv, 
				        surfaceId   =  sfId );
	__CheckRC( sts, *msg, "vs$make_natural_boundary", wrapup ) ;

	/*
	 * Get contour edges of the surface if we want contour edges or inside
	 * edges.
	 */
	if( edgeType == VS_K_CONTOUR_EDGES	||
	    edgeType == VS_K_INSIDE_EDGES	) {

		sts = om$send( msg	= message EMSsubbs.EMget_edges(
								msg,
								1,
								EMS_OPT_ALL,
								sfEnv,
								&conEdgeList,
								&array_size,
								&conEdgeCount ),
			       senderid = sfId->objid,
			       targetid = sfId->objid,
			       targetos = sfId->osnum ) ;
		__CheckRC( sts, *msg, "EMSsubbs.EMget_edges", wrapup ) ;
	}

	/*
	 * Get all edges of the surface if we want all edges or inside
	 * edges.
	 */
	if( edgeType == VS_K_ALL_EDGES		||
	    edgeType == VS_K_INSIDE_EDGES	) {

		array_size = 0 ;

		sts = om$send( msg	= message EMSsubbs.EMget_edges(
								msg,
								OM_K_MAXINT,
								EMS_OPT_ALL,
								sfEnv,
								&allEdgeList,
								&array_size,
								&allEdgeCount ),
			       senderid = sfId->objid,
			       targetid = sfId->objid,
			       targetos = sfId->osnum ) ;
		__CheckRC( sts, *msg, "EMSsubbs.EMget_edges", wrapup ) ;
	}

	/*
	 * Return list of edges.
	 */
	switch( edgeType ) {

		case VS_K_ALL_EDGES	:
			*edList  = allEdgeList ;
			*edCount = allEdgeCount ;
			break ;

		case VS_K_CONTOUR_EDGES :
			*edList  = conEdgeList ;
			*edCount = conEdgeCount ;
			break ;

		case VS_K_INSIDE_EDGES	:
			if( allEdgeCount > conEdgeCount ) {
				*edList = _MALLOC( allEdgeCount - conEdgeCount,
						   struct GRid ) ;

				if( !(*edList) ) vs$mem_fail() ;

				for( i=0; i<allEdgeCount; i++ ) {
					for( j=0; j<conEdgeCount; j++ )
						if( IF_EQ_GRID( allEdgeList[i],
								conEdgeList[j]))
									break ;

					if( j==conEdgeCount )
						(*edList)[(*edCount)++] =
							allEdgeList[i] ;
				}
			}

			_FREE( allEdgeList ) ;
			_FREE( conEdgeList ) ;
			break ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !(sts & 1 & *msg) ) {
			_FREE( allEdgeList ) ;
			_FREE( conEdgeList ) ;
		}

		return sts ;

} /* VSgetSurfaceEdges */
/*----------------------------------------------------------------------------*/
long VSgetGraphicEdge( msg, edId, edEnv, copy, copyEnv, grEdge )

long		*msg ;
struct GRid	*edId ;
struct GRmd_env *edEnv ;
int		copy ;
struct GRmd_env *copyEnv ;
struct GRid	*grEdge ; {

	/*
	 * This function is interfaced by macro 'vs$get_graphic_edge'.
	 */

	long			sts ;		/* OM completion code.	      */
	struct GRid		graphic ;	/* Graphic of edge.	      */
	struct GRmdenv_info	xyzinfo ;	/* Matrix and matrix type of  */
						/* graphic of edge.	      */

	if( copy && !copyEnv ) vs$inv_arg() ;

	grEdge->osnum = graphic.osnum = edId->osnum ;
	grEdge->objid = graphic.objid = NULL_OBJID ;

	/*
	 * Get graphic object of given edge.
	 *
	 * EF 08/08/94 : With the option 'EMSlcopt_noassoc', the argument
	 *		 'xyzinfo' should be the identity matrix, even if the
	 *		 edge is in a reference file. Otherwise, the returned
	 *		 graphic will not be located in the real position.
	 */
	MAidmx( msg, xyzinfo.matrix ) ;
	xyzinfo.matrix_type = MAIDMX ;

	sts = om$send( msg	= message EMSedge.EMgetxyzobj( msg,
							       EMSlcopt_noassoc,
							       &xyzinfo,
							       NULL,
							       NULL,
							       NULL,
							       NULL,
							       graphic.osnum,
							       &graphic.objid ),
		       senderid = edId->objid,
		       targetid = edId->objid,
		       targetos = edId->osnum ) ;
	__CheckRC( sts, *msg, "EMSedge.EMgetxyzobj", wrapup ) ;

	/*
	 * Get a copy of the graphic if requested.
	 */
	if( copy ) {
		sts = vs$grCopy( msg	= msg,
				 frEnv	= edEnv,
				 frObj	= &graphic,
				 toEnv	= copyEnv,
				 toObj	= grEdge ) ;
		__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;
	} else {
		*grEdge = graphic ;
	}

	wrapup :
		if( !(sts & 1 & *msg) ) grEdge->objid = NULL_OBJID ;

		/*
		 * EF 11/09/94 : The graphic edge returned by the message
		 * EMSedge.EMgetxyzobj is already a copy, so delete this
		 * graphic edge if we want a copy in a different environnement.
		 */
		if( copy )
			vs$bulk_delete( grids  = &graphic,
					theEnv = edEnv ) ;

		return sts ;

} /* VSgetGraphicEdge */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
