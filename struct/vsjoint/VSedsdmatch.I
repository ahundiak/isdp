/*
	I/STRUCT
*/
class implementation EMSedge ;

#include <stdlib.h>
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "godef.h"
#include "go.h"
#include "growner.h"
#include "vsdef.h"
#include "vs.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern struct GRid	NULL_GRID ;
extern void		VSzeroOutEdgeGeom() ;
extern void		VSfreeEdgeGeom() ;
/*----------------------------------------------------------------------------*/
long VSfindEdgeSurfaceMatch( msg, sf0, sf1, matchCount, matchList )

long			*msg ;
struct GRobj_env	*sf0,
			*sf1 ;
int			*matchCount ;
VSmatchingEdges		**matchList ; {

	/*
	 * Finds the edges of surface #0 which are nearest to surfaces #1.
	 * This function ios interfaced by macro `vs$findEdgeSurfaceMatch'
	 * defined in vsjntmacros.h
	 */
	long			sts ;		/* OM return code	*/
	struct GRid		ls0 ;		/* Loopset of sf. 0	*/
	int			i0,		/* Loop-on-edge index	*/
				edCnt0,		/* Nb. of edges of sf 0	*/
				count ;
	struct GRid		*edLst0 ;	/* Edge list of sf. 0	*/
	struct IGRbsp_surface	*sfGeom0,	/* Geometry of sf. 0	*/
				*sfGeom1 ;	/* Geometry of sf. 1	*/
	struct IGRbsp_curve     *edGeoms0 ;	/* Geoms of edges, sf 0 */
	VSoverlapInfo		ovlInfo ;	/* Overlap info		*/
	VSmatchingEdges		*head,
				**current ;
	double			tolerance = 0.01 ;

	SetProc( VSfindEdgeSurfaceMatch ) ; Begin

	head		= NULL ;
	sfGeom0		= sfGeom1	= NULL ;
	edGeoms0	= NULL ;
	edLst0		= NULL ;
	edCnt0		= 0 ;

	__DBGpr_obj( "Surface 0", sf0->_grid ) ;
	__DBGpr_obj( "Surface 1", sf1->_grid ) ;

	BSEXTRACTPAR( msg, BSTOLLENVEC, tolerance ) ;

	/*
	 * Get loop sets of surface #0.
	 */
	sts = vs$getLoopset( msg = msg, surface = sf0, loopset = &ls0 ) ;
	__CheckRC( sts, *msg, "vs$getLoopset 0", wrapup ) ;

	sts = VSgetEdgesByProps( msg, &ls0, EMED_NATURAL, &edCnt0, &edLst0 ) ;
	__CheckRC( sts, *msg, "VSgetEdgesByProps", wrapup ) ;

	/*
	 * Get geometry of surface #0: it will speed up EMget_edges.
	 * NOTE: should get boundary geometries too later.
	 */
	sts = vs$get_geometry(	msg     = msg,
				grobjId = &sf0->_grid,
				grobjEnv= &sf0->mod_env,
				geometry= &sfGeom0 ) ;
	__CheckRC( sts, *msg, "vs$get_geometry 0", wrapup ) ;

	sts = vs$get_geometry(	msg     = msg,
				grobjId = &sf1->_grid,
				grobjEnv= &sf1->mod_env,
				geometry= &sfGeom1 ) ;
	__CheckRC( sts, *msg, "vs$get_geometry 1", wrapup ) ;

	edGeoms0 = _MALLOC( edCnt0, struct IGRbsp_curve ) ;
	if( !edGeoms0 ) vs$mem_fail() ;

	for( i0 = 0 ; i0 < edCnt0 ; i0++ ) {
		VSzeroOutEdgeGeom( edGeoms0 + i0 ) ;
	}

	for( i0 = 0 ; i0 < edCnt0 ; i0++ ) {
		__DBGpr_obj( "Sf 0 edge", edLst0[i0] ) ;
		sts = om$send(	msg	= message EMSedge.EMget_bcxyz_geom(
						msg,
						&sf0->mod_env.md_env,
						&sf0->_grid,
						sfGeom0,
						0, /* from spaninx */
						OM_K_MAXINT, /* num span */
						FALSE,
						NULL,
						edGeoms0 + i0 ),
				senderid= edLst0[i0].objid,
				targetid= edLst0[i0].objid,
				targetos= edLst0[i0].osnum ) ;
		__CheckRC( sts, *msg, "EMSedge.EMget_bcxyz_geom", wrapup ) ;
	}

	count = 0 ; current = &head ;
	for( i0 = 0 ; i0 < edCnt0 ; i0++ ) {

#ifdef vsDEBUG
		printf( "TRYING ed0 %d [%d]\n", i0, edLst0[i0].objid ) ;
#endif
		sts = VSisCurveAtMinDistFromSurf(msg,
						tolerance,
						edGeoms0 + i0,
						sfGeom1,
						&ovlInfo ) ;
		__CheckRC( sts, *msg, "VSisEdgeAtMinDistFromSurf", wrapup ) ;
		switch( ovlInfo.code ) {
			case VS_K_NO_OVERLAP	:
				__DBGpr_com( "NO OVERLAP" ) ;
				break ;
			default			:
#ifdef vsDEBUG
		printf( "MATCH ed0 %d [%d]\n", i0, edLst0[i0].objid ) ;
#endif
				count++ ;
				sts = VSinitMatchEntry(	msg,
							edLst0 + i0,
							&NULL_GRID,
							edGeoms0 + i0,
							NULL,
							&ovlInfo,
							current ) ;
				__CheckRC( sts, *msg,
						 "VSinitMatchEntry", wrapup ) ;
				current = &(*current)->next ;
				
				break ;
		} /* switch */
	} /* for */

	*matchCount += count ;
	if( *matchList ) {
		/*
		 * Merge linked lists `*matchList' and `head'.
		 */
		VSmatchingEdges		*p, *q = NULL ;

		p = *matchList ;
		while( p ) {
			q = p ;
			p = p->next ;
		}
		if( q ) q->next = head ;
	} else {
		/*
		 * First call.
		 */
		*matchList = head ;
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( edCnt0 ) _FREE( edLst0 ) ;
		_FREE( sfGeom0 ) ; _FREE( sfGeom1 ) ;
		if( edGeoms0 ) {
			for( i0 = 0 ; i0 < edCnt0 ; i0++ ) {
				VSfreeEdgeGeom( edGeoms0 + i0 ) ;
			}
			_FREE( edGeoms0 ) ;
		}
		if( !( sts & 1 & *msg ) ) {
			if( head ) VSfreeMatchList( head ) ;
		}
		End
		return sts ;

} /* VSfindEdgeSurfaceMatch */
/*----------------------------------------------------------------------------*/

end implementation EMSedge ;

