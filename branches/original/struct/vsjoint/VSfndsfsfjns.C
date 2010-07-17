/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMerrordef.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern void	VSfreeMatchList() ;
/*----------------------------------------------------------------------------*/
long VSprocessJntMatches( msg, ovCount, ovList, cst, jnGroup )

long			*msg ;
int			ovCount ;
VSmatchingEdges		*ovList ;
struct GRvg_construct	*cst ;
struct GRid		*jnGroup ; {

	long		sts = OM_S_SUCCESS ;
	VSmatchingEdges	*head ;
#define MAX	100
	struct GRid	grList[MAX] ;
	int		grCount ;

	SetProc( VSprocessJntMatches ) ; Begin

	*msg = MSSUCC ;

	if( !ovCount ) {
		vs$error( stsval = OM_S_SUCCESS, msgval = EMS_I_NoSolution ) ;
	}
	grCount = 0 ;
	for( head = ovList ; head ; head = head->next ) {

		if( grCount >= MAX ) goto wrapup ;
#ifdef vsDEBUG
		printf( "ed0 [%d] - ed1 [%d], code ",
			head->edgeId0.objid, head->edgeId1.objid ) ;
			VSshowOvlapCode( head->matchInfo.code ) ;
#endif

		switch( head->matchInfo.code ) {

		default			: /* Should not get here */
					  vs$inv_arg() ;
		case VS_K_1_COVERS_0	:
		case VS_K_TOTAL_MATCH	:
			sts = VScstGraphicsFromEdge(	msg,
							&head->edgeId0,
							head->edgeGeom0,
							cst,
							grList + grCount ) ;
			__CheckRC( sts, *msg, "VScstGraphicsFromEdge", wrapup ) ;
			grCount++ ;
			break ;

		case VS_K_0_COVERS_1	:
			sts = VScstGraphicsFromEdge(	msg,
							&head->edgeId1,
							head->edgeGeom1,
							cst,
							grList + grCount ) ;
			__CheckRC( sts, *msg, "VScstGraphicsFromEdge", wrapup ) ;
			grCount++ ;
			break ;

		case VS_K_COMMON_PORTION:
			if( grCount + head->matchInfo.count >= MAX ) {
				goto wrapup ;
			}
			sts = VScstGraphicsFromEdgePortions(
						msg,
						head->edgeGeom0,
						head->matchInfo.count,
						head->matchInfo.t0start,
						head->matchInfo.t0end,
						cst,
						grList + grCount ) ;
			__CheckRC( sts, *msg, "VScstGraphicsFromEdgePortions", wrapup ) ;

			grCount += head->matchInfo.count ;
			break ;
		}
	}

	sts = VSconstructGroup(	msg,
				cst,
				grCount,
				grList,
				jnGroup ) ;
	__CheckRC( sts, *msg, "VSconstructGroup", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		End
		return sts ;

} /* VSprocessJntMatches */
/*----------------------------------------------------------------------------*/
long VSfindSfToSfJoints( msg, trialType, sf0, sf1, cst, jnGroup )

long			*msg ;
int			trialType ;
struct GRobj_env	*sf0,
			*sf1 ;
struct GRvg_construct	*cst ;
struct GRid		*jnGroup ; {

	long		sts ;
	int		ovCount ;
	VSmatchingEdges	*ovList ;

	SetProc( VSfindSfToSfJoints ) ; Begin

	__DBGpr_obj( "Surface 0", sf0->_grid ) ;
	__DBGpr_obj( "Surface 1", sf1->_grid ) ;

	jnGroup->objid = NULL_OBJID ; ovList = NULL ;

	/*
	 * The following two must be initialized before calling
	 * `vs$findOverlappingEdges' or `vs$findEdgeSurfaceMatch'.
	 */
	ovCount = 0 ; ovList = NULL ;

	switch( trialType ) {
		case VS_K_TRY_EDGE_EDGE	:
			__DBGpr_com( "VS_K_TRY_EDGE_EDGE" ) ;
			sts = vs$findOverlappingEdges(	msg	   = msg,
							surface1   = sf0,
							surface2   = sf1,
							matchCount = &ovCount,
							matchList  = &ovList ) ;
			__DBGpr_int( "Count of overlaps", ovCount ) ;
			__CheckRC( sts, *msg, "vs$findOverlappingEdges", wrapup ) ;
			break ;

		case VS_K_TRY_EDGE_SF	:
			__DBGpr_com( "VS_K_TRY_EDGE_SF" ) ;
			sts = vs$findEdgeSurfaceMatch(	msg	   = msg,
							sfForEdges = sf0,
							surface	   = sf1,
							matchCount = &ovCount,
							matchList  = &ovList ) ;
			__DBGpr_int( "Count of matches", ovCount ) ;
			__CheckRC( sts, *msg, "vs$findEdgeSurfaceMatch", wrapup ) ;
			break ;

		default			:
			vs$inv_arg() ;
	}

	if( ovCount ) {
		sts = VSprocessJntMatches( msg, ovCount, ovList, cst, jnGroup ) ;
		__CheckRC( sts, *msg, "VSprocessJntMatches", wrapup ) ;
		*msg	= MSSUCC ;
	} else {
		*msg	= EMS_I_NoSolution ;
	}

	sts	= OM_S_SUCCESS ;

	wrapup :
		if( ovList ) VSfreeMatchList( ovList ) ;
		End
		return sts ;

} /* VSfindSfToSfJoints */
/*----------------------------------------------------------------------------*/
VSshowOvlapCode( code ) int code ; {

switch( code ) {
	case VS_K_NO_OVERLAP		: printf( "VS_K_NO_OVERLAP\n" ) ; break ;
	case VS_K_0_COVERS_1		: printf( "VS_K_0_COVERS_1\n" ) ; break ;
	case VS_K_1_COVERS_0		: printf( "VS_K_1_COVERS_0\n" ) ; break ;
	case VS_K_COMMON_PORTION	: printf( "VS_K_COMMON_PORTION\n" ) ; break ;
	case VS_K_TOTAL_MATCH		: printf( "VS_K_TOTAL_MATCH\n" ) ; break ;
	default				: printf( "** UNKNOWN **\n" ) ; break ;
}

}
/*----------------------------------------------------------------------------*/


