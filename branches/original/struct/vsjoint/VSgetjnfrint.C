/* $Id: VSgetjnfrint.C,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSgetjnfrint.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSgetjnfrint.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/11/14  13:20:26  pinnacle
 * Created: vsjoint/VSgetjnfrint.C by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/
#include "OMmacros.h"
#include "OMprimitives.h"
#include "EMSmsgdef.h"
#include "ex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "grio.h"
#include "vsjoint.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

extern struct GRid      NULL_GRID ;
extern long	VSgetLeavesOfOwnerCmpGraph() ;

/*----------------------------------------------------------------------------*/
long VSgetJntFromInter( msg, sf0, sf1, cst, matchCount, matchList )
long                    *msg ;
struct GRobj_env        *sf0,
                        *sf1 ;
struct GRvg_construct	*cst ;
int			*matchCount ;
VSmatchingEdges		**matchList ; {

	long			sts ;
	int			i0, i,
				grCount,
				nbObj,
				status ;
	struct GRlc_info	firstSol,
				secondSol ;
	IGRboolean		approximation,
				trimRequired = TRUE ;
	VSmatchingEdges         *head = NULL,
				**current ;
	VSoverlapInfo		ovlInfo ;
	struct IGRbsp_surface	*edGeoms = NULL ;
#define MAX	100
	struct GRid 		grList[MAX] ;
	struct GRid		*comp ;

	nbObj 	= grCount	= 0 ;
	current = &head ;
	comp	= NULL ;

	firstSol.located_obj    = sf0->_grid ;
	firstSol.module_info    = sf0->mod_env ;

	secondSol.located_obj   = sf1->_grid ;
	secondSol.module_info   = sf1->mod_env ;

	approximation	= FALSE ;

	vs$dotsInStsFld() ;

	status = IntTwoSrf(	trimRequired,
				approximation,
				&firstSol,
				&secondSol,
				cst,
				&grCount,
				grList,
				msg ) ;
	vs$dotsInStsFld() ;

	if( *msg == MSFAIL ) *msg = EMS_E_NoSolution ;
	__DBGpr_int(" Intersection count ", grCount );

	ovlInfo.code = VS_K_TOTAL_MATCH ;
	ovlInfo.t0start = NULL ;

	for( i0 = 0; i0 < grCount ; i0++ ) {
	
		sts = VSgetLeavesOfOwnerCmpGraph(msg,
						&grList[i0],
						&nbObj,
						&comp ) ;
		__CheckRC( sts, *msg, "VSgetLeavesOfOwnerCmpGraph", wrapup ) ;
		
		/*
		vs$get_components(	msg	 = msg,
					grobjId  = &grList[i0],
					grobjEnv = cst->env_info,
					number	 = &nbObj,
					components= &comp );
		__CheckRC( sts, *msg, "vs$get_components", wrapup ) ;
			*/

		__DBGpr_int(" Leaves  count ", nbObj );


		for( i = 0 ; i < nbObj ; i++ ) {

			sts = vs$get_geometry( 	msg	= msg,
					 	grobjId	= &comp[i],
					 	grobjEnv= cst->env_info,
					 	geometry= &edGeoms ) ;
			__CheckRC( sts, *msg, "vs$get_geometry", wrapup );

			sts = VSinitMatchEntry( msg,
						&NULL_GRID,	// &comp[i],
						&NULL_GRID,
						edGeoms,
						NULL,
						&ovlInfo,
						current ) ;
			__CheckRC( sts, *msg, "VSinitMatchEntry", wrapup );
			 current = &(*current)->next ;
	
			_FREE( edGeoms ) ;
		}
		*matchCount += nbObj ;
	}


	if( *matchList ) {
		/*
		 * Merge linked lists `*matchList' and `head'.
		 */
		VSmatchingEdges         *p, *q = NULL ;
	 
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
wrapup :
	if( !( sts & *msg & 1 ) ) {


	}
		vs$bulk_delete(	count	= grCount,
				grids	= grList,
				theEnv	=cst->env_info );
	_FREE( comp );
	return sts  ;

}/* long VSgetJntFromInter */
/*----------------------------------------------------------------------------*/
