/* $Id: VSfndbmbmjns.C,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSfndbmbmjns.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfndbmbmjns.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/11/14  12:59:48  pinnacle
 * Replaced: vsjoint/VSfndbmbmjns.C for:  by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "vsjoint.h"
#include "vswelddef.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsocgrleaves.h"

extern void	VSfreeMatchList() ;
extern	long	VSgetFaceFromSolid() ;
extern 		VSgetJntFromInter();
/*----------------------------------------------------------------------------*/
long VSfindBeamToBeamJoints( msg, bmSol0, bmSol1, cst, weldSide, jnGroup )

long			*msg ;
struct GRobj_env	*bmSol0,	/* Solid of beam #0 	*/
			*bmSol1 ;	/* Solid of beam #1 	*/
struct GRvg_construct	*cst ;
int			weldSide ;
struct GRid		*jnGroup ; {

	long			sts ;		/* OM return code	*/
	struct IGRbsp_surface	*bmSfGeom0,	/* Geom of solid 0's sf.*/
				*bmSfGeom1 ;	/* Geom of solid 1's sf.*/
	struct GRid		*bmSfs0,	/* Surfaces of solid 0	*/
				*bmSfs1 ;	/* Surfaces of solid 1	*/
	struct GRobj_env	bmSf0,
				bmSurf,
				bmSf1 ;
	int			isSfOnSf,	/* Is surf. on surf. ?	*/
				nbBmSfs0,	/* Count of solid0's sfs*/
				nbBmSfs1,	/* Count of solid1's sfs*/
				i0,		/* Loop-on-surfs index	*/
				i1,		/* Loop-on-surfs index	*/
				ovCount ;	/* Count of matches	*/
	VSmatchingEdges		*ovList ;	/* List of matches	*/
	GRname			name ;

	SetProc( VSfindBeamToBeamJoints ) ; Begin 

	bmSfs1 = bmSfs0 = NULL ; bmSfGeom0 = bmSfGeom1 = NULL ;
	/*
	 * The following two must be set before calling
	 * `vs$findEdgeSurfaceMatch'.
	 */
	ovList = NULL ; ovCount = 0 ;

	/*
	 * Find all surfaces making solid of beam #0.
	 */
	sts = VSgetLeavesOfOwnerCmpGraph(	msg,
						&bmSol0->_grid,
						&nbBmSfs0,
						&bmSfs0 ) ;
	__CheckRC( sts, *msg, "VSgetLeavesOfOwnerCmpGraph", wrapup ) ;

	/*
	 * Find all surfaces making solid of beam #.
	 */
	sts = VSgetLeavesOfOwnerCmpGraph(	msg,
						&bmSol1->_grid,
						&nbBmSfs1,
						&bmSfs1 ) ;
	__CheckRC( sts, *msg, "VSgetLeavesOfOwnerCmpGraph", wrapup ) ;

	bmSf0.mod_env = bmSol0->mod_env ;
	bmSf1.mod_env = bmSol1->mod_env ;
	bmSurf.mod_env  = bmSol0->mod_env ;
#if 0
	for( i0 = 0 ; i0 < nbBmSfs0 ; i0++ ) {
		sts = vs$get_geometry(	msg	= msg,
					grobjId	= bmSfs0 + i0,
					grobjEnv= &bmSol0->mod_env,
					geometry= &bmSfGeom0 ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		bmSf0._grid	= bmSfs0[i0] ;

		for( i1 = 0 ; i1 < nbBmSfs1 ; i1++ ) {
			__DBGpr_obj( "Trying beam sf 0", bmSfs0[i0] ) ;
			__DBGpr_obj( "... with beam sf 1", bmSfs1[i1] ) ;
			sts = vs$get_geometry(	msg	= msg,
						grobjId	= bmSfs1 + i1,
						grobjEnv= &bmSol1->mod_env,
						geometry= &bmSfGeom1 ) ;
			__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

			VSisSfOnSf( msg, bmSfGeom0, bmSfGeom1, &isSfOnSf ) ;

			_FREE( bmSfGeom1 ) ; bmSfGeom1 = NULL ;

			if( isSfOnSf ) {
				/*
				 * Try to find the edges of the beam surface
				 * which are on the other beam surface.
				 */
				__DBGpr_obj( "Beam sf 0", bmSfs0[i0] ) ;
				__DBGpr_obj( "... is on beam sf 1", bmSfs1[i1] ) ;

				bmSf1._grid	= bmSfs1[i1] ;
				sts = vs$findEdgeSurfaceMatch(
						msg		= msg,
						sfForEdges	= &bmSf0,
						surface		= &bmSf1,
						matchCount	= &ovCount,
						matchList	= &ovList ) ;
				__CheckRC( sts, *msg, "vs$findEdgeSurfaceMatch", wrapup ) ;
				__DBGpr_int( "Count of matches", ovCount ) ;
			}
		} /* End loop on 1 */

		_FREE( bmSfGeom0 ) ; bmSfGeom0 = NULL ;

	} /* End loop on 0 */
	*/
#endif
	switch ( weldSide ) {
		case VS_K_wldLeftSide  :
			__DBGpr_com(" Weld Left Side" );
			DIstmcpy( name, VS_K_bmGrCmpName, VS_K_bmBody, 
						VS_K_nmWebL, NULL ) ;
			sts = VSgetFaceFromSolid( msg, bmSol0, name, 
							&bmSurf._grid );
			break ;

		case VS_K_wldRightSide  :
			__DBGpr_com(" Weld Right Side" );
			DIstmcpy( name, VS_K_bmGrCmpName, VS_K_bmBody, 
						VS_K_nmWebR, NULL ) ;
			sts = VSgetFaceFromSolid( msg, bmSol0, name,
							&bmSurf._grid );
			break ;

		case VS_K_wldBothSides  :
			__DBGpr_com(" Weld Both Sides" );
			bmSurf._grid = bmSol0->_grid ;
			break ;
	}

	VSgetJntFromInter( msg, &bmSurf, bmSol1, cst, &ovCount, &ovList );
	__DBGpr_int(" Count of matches1111", ovCount );

	if( ovCount ) {
		sts = VSprocessJntMatches( msg, ovCount, ovList, cst, jnGroup );
		__CheckRC( sts, *msg, "VSprocessJntMatches", wrapup ) ;

		__DBGpr_obj( "Joint Group", *jnGroup ) ;

	} else vs$failure() ;

	wrapup :
		_FREE( bmSfs0 ) ; _FREE( bmSfs1 ) ;
		/*
		 * Just in case we got out of a loop prematurely without the
		 * geometries being freed, do it again if need be.
		 */
		_FREE( bmSfGeom1 ) ; _FREE( bmSfGeom0 ) ;

		if( ovList ) VSfreeMatchList( ovList ) ;

		End
		return sts ;

} /* VSfindBeamToBeamJoints */
/*----------------------------------------------------------------------------*/

