/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsfreecv.h"
/*----------------------------------------------------------------------------*/
long VSinitMatchEntry( msg, edId0, edId1, edGeom0, edGeom1, matchInfo, entry )

long			*msg ;
struct GRid		*edId0,
			*edId1 ;
struct IGRbsp_curve	*edGeom0,
			*edGeom1 ;
VSoverlapInfo		*matchInfo ;
VSmatchingEdges		**entry ; {

	long		sts ;
	VSmatchingEdges	*new ;

	SetProc( VSinitMatchEntry ) ; Begin

	*entry = NULL ;

	if( !( new = _MALLOC( 1, VSmatchingEdges ) ) ) vs$mem_fail() ;

	new->next	= NULL ;
	new->edgeGeom0 	= new->edgeGeom1 = NULL ;

	sts = VScopybc( msg, edGeom0, &new->edgeGeom0 ) ;
	__CheckRC( sts, *msg, "VScopybc", wrapup ) ;

	if( edGeom1 ) {
		sts = VScopybc( msg, edGeom1, &new->edgeGeom1 ) ;
		__CheckRC( sts, *msg, "VScopybc", wrapup ) ;
	} else {
		new->edgeGeom1 = NULL ;
	}

	__DBGpr_obj( "Edge 0", *edId0 ) ;
	__DBGpr_obj( "Edge 1", *edId1 ) ;

	new->edgeId0	= *edId0 ;
	new->edgeId1	= *edId1 ;
	new->matchInfo	= *matchInfo ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( new ) {
				_FREE( new->edgeGeom0 ) ;
				_FREE( new->edgeGeom1 ) ;
				_FREE( new ) ;
			}
		} else {
			*entry = new ;
		}
		End
		return sts ;

} /* VSinitMatchEntry */
/*----------------------------------------------------------------------------*/
void VSfreeMatchList( l ) register VSmatchingEdges *l ; {

	register VSmatchingEdges	*m ;
	long				rc ;

	while( l ) {
		m = l->next ;
		BSfreecv( &rc, l->edgeGeom0 ) ;
		if( l->edgeGeom1 ) ; BSfreecv( &rc, l->edgeGeom1 ) ;
		if( l->matchInfo.count ) _FREE( l->matchInfo.t0start ) ;
		free( l ) ;
		l = m ;
	}

} /* VSfreeMatchList */
/*----------------------------------------------------------------------------*/

