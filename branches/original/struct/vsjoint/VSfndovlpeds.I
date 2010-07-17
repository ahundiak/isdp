/*
	I/STRUCT
*/
class implementation EMSedge ;

#include <stdlib.h>
#include "msdef.h"
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
/*
 * Includes of function prototypes.
 */
#include "EMSutlmacros.h"

extern void	VSfreeMatchList() ;
/*----------------------------------------------------------------------------*/
void VSzeroOutEdgeGeom( edgeGeom ) struct IGRbsp_curve *edgeGeom ; {

	edgeGeom->poles = edgeGeom->knots = edgeGeom->weights = NULL ;

} /* VSzeroOutEdgeGeom */
/*----------------------------------------------------------------------------*/
void VSfreeEdgeGeom( edgeGeom ) struct IGRbsp_curve *edgeGeom ; {

	_FREE( edgeGeom->poles   ) ;
	_FREE( edgeGeom->knots   ) ;
	_FREE( edgeGeom->weights ) ;
	VSzeroOutEdgeGeom( edgeGeom ) ;

} /* VSfreeEdgeGeom */
/*----------------------------------------------------------------------------*/
long VSgetLoopset( msg, sf, loopset )

long			*msg ;
struct GRobj_env	*sf ;
struct GRid		*loopset ; {

	/*
	 * This function is interfaced by macro `vs$getLoopset' defined in
	 * vsjntmacros.h
	 */
	long			sts ;		/* OM return code	*/
	OM_S_CHANSELECT		toLoopset ;	/* To-loopset channel	*/
	OM_S_OBJECT_LINKAGE	ls ;		/* Loopset of surface	*/
	int			count ;

	/*
	 * Put some topology onto surface.
	 */
	sts = vs$make_natural_boundary(	msg		= msg,
					surfaceEnv	= &sf->mod_env,
					surfaceId	= &sf->_grid ) ;
	__CheckRC( sts, *msg, "vs$make_natural_boundary", wrapup ) ;

	 ems$make_chanselect( chan_label    = EMSsubbs_to_loopset,
			      chan_selector = &toLoopset ) ;

	/*
	 * Get loopset of surface 0.
	 */
	sts = om$get_channel_objects(	objid		= sf->_objid,
					osnum		= sf->_osnum,
					p_chanselect	= &toLoopset,
					size		= 1,
					list		= &ls,
					count		= (OMuint *) &count ) ;
	__CheckRC( sts, 1, "om$get_channel_objects", wrapup ) ;
	if( !count ) {
		sts = OM_W_ABORT ; *msg = EMS_E_ChanCountWrong ; goto wrapup ;
	}
	loopset->objid	= ls.S_objid ;
	loopset->osnum	= ls.osnum ;

	__DBGpr_obj( "Loop set", *loopset ) ;

	wrapup :
		return sts ;

} /* VSgetLoopset */
/*----------------------------------------------------------------------------*/
long VSfindOverlappingEdges( msg, sf0, sf1, ovCount, ovList )

long			*msg ;
struct GRobj_env	*sf0,
			*sf1 ;
int			*ovCount ;
VSmatchingEdges		**ovList ; {

	/*
	 * This function is interfaced by macro `vs$findOverlappingEdges'
	 * defined in vsjntmacros.h.
	 */
	long			sts ;		/* OM return code	*/
	struct GRid		ls0,		/* Loopset of sf. 0	*/
				ls1 ;		/* Loopset of sf. 1	*/
	int			i0,		/* Loop-on-edge index	*/
				i1,		/* Loop-on-edge index	*/
				count,
				edCnt0,		/* Nb. of edges of sf 0	*/
				edCnt1 ;	/* Nb. of edges of sf 1	*/
	struct GRid		*edLst0,	/* Edge list of sf. 0	*/
				*edLst1 ;	/* Edge list of sf. 1	*/
	struct IGRbsp_surface	*sfGeom0,	/* Geometry of sf. 0	*/
				*sfGeom1 ;	/* Geometry of sf. 1	*/
	struct IGRbsp_curve     *edGeoms0,	/* Geoms of edges, sf 0 */
                                *edGeoms1 ;	/* Geoms of edges, sf 1 */
	VSoverlapInfo		ovlInfo ;	/* Overlap info		*/
	VSmatchingEdges		*head,
				**current ;
	int			rmEdFrList ;

	SetProc( VSfindOverlappingEdges ) ; Begin

	head		= NULL ;
	sfGeom0		= sfGeom1	= NULL ;
	edGeoms0	= edGeoms1	= NULL ;
	edLst0		= edLst1	= NULL ;
	edCnt0		= edCnt1	= 0 ;

	/*
	 * Get loop sets.
	 */
	sts = vs$getLoopset( msg = msg, surface = sf0, loopset = &ls0 ) ;
	__CheckRC( sts, *msg, "vs$getLoopset 0", wrapup ) ;

	sts = vs$getLoopset( msg = msg, surface = sf1, loopset = &ls1 ) ;
	__CheckRC( sts, *msg, "vs$getLoopset 1", wrapup ) ;	

	sts = VSgetEdgesByProps( msg, &ls0, EMED_NATURAL, &edCnt0, &edLst0 ) ;
	__CheckRC( sts, *msg, "VSgetEdgesByProps", wrapup ) ;

	sts = VSgetEdgesByProps( msg, &ls1, EMED_NATURAL, &edCnt1, &edLst1 ) ;
	__CheckRC( sts, *msg, "VSgetEdgesByProps", wrapup ) ;
	__DBGpr_objlist( "Edges of surface 0", edCnt0, edLst0 ) ;
	__DBGpr_objlist( "Edges of surface 1", edCnt1, edLst1 ) ;

	__DBGpr_int( "Count of edges 0", edCnt0 ) ;
	__DBGpr_int( "Count of edges 1", edCnt1 ) ;

	/*
	 * Get geometry of both surfaces: it will speed up EMget_edges.
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

	edGeoms1 = _MALLOC( edCnt1, struct IGRbsp_curve ) ;
	if( !edGeoms1 ) vs$mem_fail() ;

	for( i1 = 0 ; i1 < edCnt1 ; i1++ ) {
		VSzeroOutEdgeGeom( edGeoms1 + i1 ) ;
	}

	for( i0 = 0 ; i0 < edCnt0 ; i0++ ) {
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

	for( i1 = 0 ; i1 < edCnt1 ; i1++ ) {
		sts = om$send(	msg	= message EMSedge.EMget_bcxyz_geom(
						msg,
						&sf1->mod_env.md_env,
						&sf1->_grid,
						sfGeom1,
						0, /* from spaninx */
						OM_K_MAXINT, /* num span */
						FALSE,
						NULL,
						edGeoms1 + i1 ),
				senderid= edLst1[i1].objid,
				targetid= edLst1[i1].objid,
				targetos= edLst1[i1].osnum ) ;
		__CheckRC( sts, *msg, "EMSedge.EMget_bcxyz_geom", wrapup ) ;
	}

	count = 0 ; current = &head ;
	for( i0 = 0 ; i0 < edCnt0 ; i0++ ) {

		for( i1 = 0 ; i1 < edCnt1 ; i1++ ) {
			rmEdFrList = FALSE ;
			if( OM_K_NOT_AN_OS == edLst1[i1].osnum ) continue ;

			sts = VSdoCurvesOverlap(	msg,
							edGeoms0 + i0,
							edGeoms1 + i1,
							&ovlInfo ) ;
			__CheckRC( sts, *msg, "VSdoCurvesOverlap", wrapup ) ;
#ifdef vsDEBUG
			printf( "ed0 %d [%d] - ed1 %d [%d]\n",
				i0, edLst0[i0].objid, i1, edLst1[i1].objid ) ;
#endif
			switch( ovlInfo.code ) {
				case VS_K_NO_OVERLAP	:
					__DBGpr_com( "NO OVERLAP" ) ;
					break ;
				case VS_K_TOTAL_MATCH	: 
				/*
				 * Remove edLst1[i1] from edge list: no use
				 * trying to make it match another edge from
				 * edLst0 since we have a total match.
				 */
				 	rmEdFrList = TRUE ;
				/*
				 * Fall through next case.
				 */
				default			:
					count++ ;
					sts = VSinitMatchEntry(	msg,
								edLst0 + i0,
								edLst1 + i1,
								edGeoms0 + i0,
								edGeoms1 + i1,
								&ovlInfo,
								current ) ;
					__CheckRC( sts, *msg,
						 "VSinitMatchEntry", wrapup ) ;
					current = &(*current)->next ;
					
				break ;
			}
			if( rmEdFrList ) {
				edLst1[i1].osnum = OM_K_NOT_AN_OS ;
				break ;
			}
		}
	}

	*ovCount += count ;
	if( *ovList ) {
		/*
		 * Merge linked lists `*ovList' and `head'.
		 */
		VSmatchingEdges		*p, *q = NULL ;

		p = *ovList ;
		while( p ) {
			q = p ;
			p = p->next ;
		}
		if( q ) q->next = head ;
	} else {
		/*
		 * First call.
		 */
		*ovList = head ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( edCnt0 ) _FREE( edLst0 ) ;
		if( edCnt1 ) _FREE( edLst1 ) ;
		_FREE( sfGeom0 ) ; _FREE( sfGeom1 ) ;
		if( edGeoms0 ) {
			for( i0 = 0 ; i0 < edCnt0 ; i0++ ) {
				VSfreeEdgeGeom( edGeoms0 + i0 ) ;
			}
			_FREE( edGeoms0 ) ;
		}
		if( edGeoms1 ) {
			for( i1 = 0 ; i1 < edCnt1 ; i1++ ) {
				VSfreeEdgeGeom( edGeoms1 + i1 ) ;
			}
			_FREE( edGeoms1 ) ;
		}
		if( !( sts & 1 & *msg ) ) {
			if( head ) VSfreeMatchList( head ) ;
		}
		End
		return sts ;

} /* VSfindOverlappingEdges */
/*----------------------------------------------------------------------------*/
int VSdumpEdges( ls ) struct GRid *ls ; {

	long		msg,
			sts ;
	int		size	= 0,
			count 	= 0,
			i ;
	struct GRid	*list 	= NULL ;
	unsigned short	props ;
	
	sts = om$send(	msg	= message EMSboundary.EMget_edges(
					&msg,
					OM_K_MAXINT, /* tree depth */
					EMS_OPT_ALL,
					&list,
					&size,
					&count ),
			senderid= ls->objid,
			targetid= ls->objid,
			targetos= ls->osnum ) ;
	__CheckRC( sts, msg, "EMSboundary.EMget_edges", wrapup ) ;
	printf( "*-* Dump of edges for looset [%d,%d]\n", ls->objid,
		ls->osnum ) ;

	for( i = 0 ; i < count ; i++ ) {
		sts = om$send(	msg	= message EMSedge.EMget_props(
								&msg, &props ),
				senderid= NULL_OBJID,
				targetid= list[i].objid,
				targetos= list[i].osnum ) ;
		ShowObj( list + i ) ;
		if( props & EMED_NATURAL ) printf( "NATURAL " ) ;
		if( props & EMED_SEAM    ) printf( "SEAM " ) ;
		if( !(props & EMED_DEGENERATE ) ) printf( "CONNECTABLE " ) ;
		if( props & EMED_DEGENERATE ) printf( "DEGENERATE " ) ;
		printf( "\n" ) ;
	}
	printf( "*-* End of dump\n" ) ;

	wrapup :
	_FREE( list ) ;
	return 1 ;
}
/*----------------------------------------------------------------------------*/

end implementation EMSedge ;
