/* $Id: VSsxsfbdries.I,v 1.2 2001/08/17 21:59:15 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSsxsfbdries.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsxsfbdries.I,v $
 *      Revision 1.2  2001/08/17 21:59:15  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:00  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/01  14:58:34  pinnacle
# TR179701791
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTIO
 * 09/26/97  ah      added header
 * 09/30/97  ah      TR179701791 Don't allocate 0 bytes
 * 03/01/98  ah      TR179701791 Final Checkin
 ***************************************************************************/

class implementation EMSsubbs ;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "msdef.h"
#include "ms.h"
#include "growner.h"
#include "gocmacros.h"
#include "dpmacros.h"
#include "emsdattyp.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>
/*
 * Includes of function prototypes.
 */
#include "bscv_copy.h"
#include "bsfreecv.h"
#include "EMSutlmacros.h"

extern IGRboolean	EFmerge_curves() ;

from EMSedge	import EMget_bcxyz_geom ;
/*----------------------------------------------------------------------------*/
long VSmergeEdges( msg, surface, sfGeom, edCount, edList, mergedGeom )

long			*msg ;
struct GRobj_env	*surface ;
struct IGRbsp_surface	*sfGeom ;
int			edCount ;
struct GRid		edList[] ;
struct IGRbsp_curve	**mergedGeom ;
{
	long			sts ;
	int			i ;
	char			*chGeom ;
	struct IGRbsp_curve	*edGeoms,
				*mc ;

        __enterFunction ( name = "VSmergeEdges" //, argfmt = "", args = ``
        );

	*msg	= MSFAIL ;
	sts	= OM_S_SUCCESS ;

	*mergedGeom = edGeoms = mc = NULL ;
	if( ! edCount )	goto wrapup ;

	if( !( edGeoms = _MALLOC( edCount, struct IGRbsp_curve ) ) )
		vs$mem_fail() ;

	for( i = 0 ; i < edCount ; i++ ) {
		VSzeroOutEdgeGeom( &edGeoms[i] ) ;
	}

	for( i = 0 ; i < edCount ; i++ ) {
		sts = om$send(	msg	= message EMSedge.EMget_bcxyz_geom(
						msg,
						&surface->mod_env.md_env,
						&surface->_grid,
						sfGeom,
						0, /* from spaninx */
						OM_K_MAXINT, /* num span */
						FALSE,
						NULL,
						&edGeoms[i] ),
				senderid= NULL_OBJID,
				targetid= edList[i].objid,
				targetos= edList[i].osnum ) ;
		__CheckRC( sts, *msg, "EMSedge.EMget_bcxyz_geom", wrapup ) ;
	}

	sts = EFmerge_curves(	edCount,
				NULL,
				edGeoms,
				NULL_OBJID,
				&mc,
				FALSE, /* Do not fill gaps */
				msg ) ;

	// Dare to be stupid
	sts = sts ? OM_S_SUCCESS : OM_W_ABORT ;
	__CheckRC( sts, *msg, "EFmerge_curves", wrapup ) ;

	mc->num_boundaries = 0 ;

	// Really a c macro, i gets size
	GRbc_size(	mc->order,
			mc->num_poles,
			mc->rational,
			mc->num_boundaries,
			i ) ;

	if (i == 0) {
		BSfreecv( msg, mc ) ;
		vs$mem_fail() ;
	}

	if( chGeom = _MALLOC( i, char )) {

		*mergedGeom	= (struct IGRbsp_curve *) chGeom ;
		chGeom		= NULL ;

		GRbc_partition(	(*mergedGeom),
				mc->order,
				mc->num_poles,
				mc->rational,
				mc->num_boundaries ) ;
		BScv_copy( msg, mc, *mergedGeom ) ;
		BSfreecv( msg, mc ) ;
	} else {
		BSfreecv( msg, mc ) ;
		vs$mem_fail() ;
	}

	sts = OM_S_SUCCESS ; *msg = MSSUCC ;

	wrapup	:
		if( edGeoms ) {
			for( i = 0 ; i < edCount ; i++ ) {
				VSfreeEdgeGeom( &edGeoms[i] ) ;
			}
			_FREE( edGeoms ) ;
		}
		if( mc ) BSfreecv( msg, mc ) ;

        __exitFunction ( name = "VSmergeEdges", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		return sts ;

} /* VSmergeEdges */
/*----------------------------------------------------------------------------*/
long VSgetInnerBoundaries( msg, surface, sfGeom, ibGeoms, ibCount )

long			*msg ;
struct GRobj_env	*surface ;
struct IGRbsp_surface	*sfGeom ;
struct IGRbsp_curve	***ibGeoms ;
int			*ibCount ;
{
	long			sts ;
	struct GRid		*edList,	/* Inner edges		*/
				*grList ;	/* Graphics of the above*/
	int			edCount,	/* Count of inner edges	*/
				i,		/* Loop index		*/
				gCount,		/* # of edge groups	*/
				cvsInGroup,	/* # of cvs in one group*/
				*index,		/* Indices of groups	*/
				nbIb ;		/* # of inner boundaries*/
	OMuint			lpCount ;	/* Count of loops	*/
	OM_S_OBJECT_LINKAGE	loop ;		/* Id of a loop		*/
	OM_S_CHANSELECT		edgeToOwner ;	/* Channel edge->loop	*/
	OM_S_OBJID		prevLoop ;
	struct IGRbsp_curve	**cvGeoms ;

        __enterFunction ( name = "VSgetInnerBoundaries" //, argfmt = "", args = ``
        );

	*ibGeoms	= NULL ;
	*ibCount	= 0 ;
	edCount		= 0 ;
	edList		= NULL ;
	grList		= NULL ;
	index		= NULL ;
	cvGeoms		= NULL ;
	nbIb		= 0 ;

	/*
	 * Get inside edges of surface.
	 */
	sts = vs$get_surface_edges( msg 	= msg,
				    sfId	= &surface->_grid,
				    sfEnv	= &surface->mod_env,
				    edgeType	= VS_K_INSIDE_EDGES,
				    edCount	= &edCount,
				    edList	= &edList ) ;
	__CheckRC( sts, *msg, "vs$get_surface_edges", wrapup ) ;

	if( !edCount ) { *msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ; }

	/*
	 * Group together the edges belonging to the same loop.
	 */
	if( !( index = _MALLOC( edCount + 1, int ) ) ) vs$mem_fail() ;

	ems$make_chanselect( chan_label    = EMSedge_to_owner,
			     chan_selector = &edgeToOwner ) ;

	prevLoop = NULL_OBJID ;

	for( i = gCount = 0 ; i < edCount ; i++ ) {

		sts = om$get_channel_objects(
					objid		= edList[i].objid,
					osnum		= edList[i].osnum,
					p_chanselect	= &edgeToOwner,
					size		= 1,
					list		= &loop,
					count		= &lpCount ) ;
		__CheckRC( sts, *msg, "om$get_channel_objects", wrapup ) ;

		if( !lpCount ) vs$failure() ;

		if( !IF_EQ_OBJID( prevLoop, loop.S_objid ) ) {
			index[gCount++] = i ;
			 prevLoop  = loop.S_objid ;
		}
	}
	index[gCount] = edCount ;

	if( !( grList = _MALLOC( edCount + 1, struct GRid ) ) ) vs$mem_fail() ;

	for( i = 0 ; i < edCount ; i++ ) {

		/*
		 * Get graphics of inner edge.
		 */
		sts = vs$get_graphic_edge( msg	   = msg,
					   edId    = edList + i,
					   edEnv   = &surface->mod_env,
					   grEdge  = grList + i ) ;

		__CheckRC( sts, *msg, "vs$get_graphic_edge", wrapup ) ;

	}

	if( !( cvGeoms = _CALLOC( edCount, struct IGRbsp_curve * ) ) )
		vs$mem_fail() ;

	nbIb = 0 ;
	for( i = 0 ; i < gCount ; i++ ) {

		cvsInGroup = index[i+1] - index[i] ;

		if( cvsInGroup == 1 ) {
			sts = vs$get_geometry(	msg	= msg,
						grobjId	= grList + index[i],
						grobjEnv= &surface->mod_env,
						geometry= cvGeoms + nbIb ) ;
			__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
		} else {

			sts = VSmergeEdges(	msg,
						surface,
						sfGeom,
						cvsInGroup,
						edList + index[i],
						&cvGeoms[nbIb] ) ;
			__CheckRC( sts, *msg, "VSmergeEdges", wrapup ) ;
		}

		nbIb ++ ;
	}

	*ibCount	= nbIb ;
	*ibGeoms	= cvGeoms ;

	sts = OM_S_SUCCESS ; *msg = MSSUCC ;

	wrapup :
		_FREE( edList ) ;
		if( grList ) {
			vs$bulk_delete( grids = grList,
					count = edCount,
					theEnv= &surface->mod_env ) ;
			_FREE( grList ) ;
		}
		_FREE( index ) ;
		if( !( sts & 1 & *msg ) ) {
			for( i = 0 ; i < nbIb ; i++ ) {
				_FREE( cvGeoms[i] ) ;
			}
			_FREE( cvGeoms ) ;
		}

        __exitFunction ( name = "VSgetInnerBoundaries", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		return sts ;

} /* VSgetInnerBoundaries */
/*----------------------------------------------------------------------------*/
long VSgetSfBoundaries( msg, surface, sfGeom, sfBndries, nbSfBndries )

long			*msg ;
struct GRobj_env	*surface ;
struct IGRbsp_surface	*sfGeom ;
struct IGRbsp_curve	***sfBndries ;
int			*nbSfBndries ;
{
	long			sts ;
	int			ibCount = 0 ;
	struct IGRbsp_curve	*ctGeom	= NULL,
				**ibGeoms = NULL ;
	struct GRid		compId ;

        __enterFunction ( name = "VSgetSfBoundaries" //, argfmt = "", args = ``
        );

	*sfBndries	= NULL ;
	*nbSfBndries	= 0 ;
	compId.objid	= NULL_OBJID ;

	sts = VSgetInnerBoundaries( msg, surface, sfGeom, &ibGeoms, &ibCount ) ;
	__CheckRC( sts, *msg, "VSgetInnerBoundaries" , wrapup ) ;

	sts = VSdrwMakeSfContourCompCurve( msg, &surface->_grid,
					   &surface->mod_env,
					   &surface->mod_env, &compId ) ;
	__CheckRC( sts, *msg, "VSdrwMakeSfContourCompCurve" , wrapup ) ;

	sts = vs$get_geometry(	msg	= msg,
				grobjId	= &compId,
				grobjEnv= &surface->mod_env,
				geometry= &ctGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry" , wrapup ) ;

	ibGeoms	= _REALLOC(	ibGeoms,
				ibCount+1,
				struct IGRbsp_curve * );
	if( !ibGeoms ) vs$mem_fail() ;

	ibGeoms[ibCount++]	= ibGeoms[0] ;
	ibGeoms[0]		= ctGeom ;

	ctGeom		= NULL ;

	*sfBndries	= ibGeoms ;
	*nbSfBndries	= ibCount ;

	wrapup :
		vs$bulk_delete( grids = &compId, theEnv = &surface->mod_env ) ;
		if( !( sts & 1 & *msg ) ) {
			if( ibGeoms ) {
				int	i ;
				for( i = 0 ; i < ibCount ; i++ ) {
					_FREE( ibGeoms[i] ) ;
				}
				_FREE( ibGeoms ) ;
			}
		}
		_FREE( ctGeom );

        __exitFunction ( name = "VSgetSfBoundaries", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		return sts ;

} /* VSgetSfBoundaries */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
