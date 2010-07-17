/* $Id: VSfndplpljns.C,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsjoint/VSfndplpljns.
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfndplpljns.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/11/18  08:13:14  pinnacle
 * Replaced: vsjoint/VSfndplpljns.C for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/14  13:17:54  pinnacle
 * Replaced: vsjoint/VSfndplpljns.C for:  by svkadamb for struct
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/
/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsjoint.h"
#include "vsAPImac.h"
#include "vswelddef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bssfeval.h"
#include "bssfevaln.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSfindPlateToPlateJoints( msg, bot0, top0, bot1, top1, cst, plateObj,
							weldSide, jnGroup )

long			*msg ;
struct GRobj_env	*bot0,		/* Bottom surface of plate #0	*/
			*top0,		/* Top    surface of plate #0	*/
			*bot1,		/* Bottom surface of plate #1	*/
			*top1 ;		/* Top    surface of plate #1	*/
struct GRvg_construct	*cst ;		/* construction list		*/
struct GRobj_env	plateObj ;	/* plate used for intersection 	*/
int			weldSide ;	/* weld side Left/Right/Both	*/
struct GRid		*jnGroup ; {

	long			sts ;		/* OM return code	*/
	struct IGRbsp_surface	*botGeom0,	/* geometry of bot0	*/
				*botGeom1,	/* geometry of bot1	*/
				*topGeom1 ;	/* geometry of top0	*/
	IGRvector		botNorm0,	/* normal of bot0	*/
				botNorm1 ;	/* normal of bot1	*/
	IGRpoint		ptOnBot0,	/* point on bot0	*/
				ptOnBot1,	/* point on bot1	*/
				ptOnTop1 ;	/* point on top1	*/
	int			nbNorms,	/* num of normals of srf*/
#define TRY_EDG_EDG	0
#define TRY_EDG_BOT	1
#define TRY_EDG_TOP	2
				actions[2],	/* used for quick algo	*/
				i,		/* loop index		*/
				isPlanar0,	/* is surf0 planar	*/
				isPlanar1 ;	/* is surf1 planar	*/
	int			matchCount = 0; /* match count for joint*/
	VSmatchingEdges		*matchList ;	/* list for joint group */
	struct GRobj_env	plSol ;		/* solid from plateObj 	*/

#define	COS45DEG		( 0.5 * M_SQRT2 )

	SetProc( VSfindPlateToPlateJoints ) ; Begin

	botGeom0 = botGeom1 = topGeom1 = NULL ;
	matchList = NULL ;

#ifdef vsDEBUG
	printf( "Bot 0:" ) ; ShowObj( &bot0->_grid ) ;
	printf( "Top 0:" ) ; ShowObj( &top0->_grid ) ;
	printf( "Bot 1:" ) ; ShowObj( &bot1->_grid ) ;
	printf( "Top 1:" ) ; ShowObj( &top1->_grid ) ;
#endif
	/*
	 * get the geomerty of the bbot0 surface
	 */
	sts = vs$get_geometry(	msg	= msg,
				grobjId	= &bot0->_grid,
				grobjEnv= &bot0->mod_env,
				geometry= &botGeom0 ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	sts = vs$get_geometry(	msg	= msg,
				grobjId	= &bot1->_grid,
				grobjEnv= &bot1->mod_env,
				geometry= &botGeom1 ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * get the point and normal of the bot0 surface at the center
	 */
	BSsfevaln( botGeom0, 0.5, 0.5, 1, &nbNorms, ptOnBot0,
		   (IGRvector *) botNorm0, msg ) ;
	if( BSERROR( *msg ) ) vs$error( msgval = EMS_E_SurfaceError ) ;

	/*
	 * get the point and normal of the bot1 surface at the center
	 */
	BSsfevaln( botGeom1, 0.5, 0.5, 1, &nbNorms, ptOnBot1,
		   (IGRvector *) botNorm1, msg ) ;
	if( BSERROR( *msg ) ) vs$error( msgval = EMS_E_SurfaceError ) ;

	__DBGpr_vec( "Normal of bot 0", botNorm0 ) ;
	__DBGpr_vec( "Normal of bot 1", botNorm1 ) ;

	__DBGpr_dbl( "Angle between bottoms",
			 BSdotp( msg, botNorm0, botNorm1 ) ) ;

	isPlanar0 = vs$is_surface_planar( msg = msg, surfGeom = botGeom0 ) ;
	isPlanar1 = vs$is_surface_planar( msg = msg, surfGeom = botGeom1 ) ;

	/*
	 * Try to find where joint will be, ordering the attempts by likeliness,
	 * since this process is time-consuming.
	 * Planar plate with their normals' angle < 44 degree are likely
	 * to be joined by their edges, so try this first.
	 * Otherwise first try to match an edge for the first plate with
	 * either the to or bottom surface of the other plate.
	 */
	if(    fabs( BSdotp( msg, botNorm0, botNorm1 ) ) > COS45DEG
	    || ( !isPlanar0 && !isPlanar1 ) ) {

		__DBGpr_com( "Try edge/edge first" ) ;
		actions[0] = TRY_EDG_EDG ;
		actions[1] = TRY_EDG_BOT ;
	} else {
		actions[0] = TRY_EDG_BOT ;
	    	actions[1] = TRY_EDG_EDG ;
	}

	if( weldSide == VS_K_wldLeftSide) {
	    /*
	     * Intersect the base_surf of plate0 with
	     * either top or bottom of plate 1
	     */
	    __DBGpr_com(" Weld Side is Left Side " );
	    for( i = 0, *msg = EMS_I_NoSolution ;
             		i < 2 && *msg == EMS_I_NoSolution ; i++ ) {
	    __DBGpr_int(" Loop count ", i );
		switch( actions[i] ) {
			case TRY_EDG_BOT :
				__DBGpr_com( "TRY_EDG_BOT" ) ;
				sts = VSfindSfToSfJoints( msg, 
							VS_K_TRY_EDGE_SF,
							bot0, bot1, cst, 
							jnGroup ) ;
				break ;
			case TRY_EDG_EDG :
				__DBGpr_com( "TRY_EDG_EDG" ) ;
				sts = VSfindSfToSfJoints( msg,
							VS_K_TRY_EDGE_SF,
							bot0, bot1, cst, 
							jnGroup ) ;
				break ;
		}
	    }

	    if( *msg == EMS_I_NoSolution ) {
	    __DBGpr_com(" Weld Side is LEft Side " );
		for( i = 0, *msg = EMS_I_NoSolution ;
             		i < 2 && *msg == EMS_I_NoSolution ; i++ ) {
			switch( actions[i] ) {
				case TRY_EDG_BOT :
					__DBGpr_com(" Trying reverse TRY_EDG_BOT");
					sts = VSfindSfToSfJoints( msg, 
						 	VS_K_TRY_EDGE_SF,
						 	bot0, top1, cst, 
						 	jnGroup ) ;
					break ;
				case TRY_EDG_EDG :
					__DBGpr_com(" Trying reverse TRY_EDG_EDG");
					sts = VSfindSfToSfJoints( msg,
						    	VS_K_TRY_EDGE_EDGE,
						    	bot0, top1, cst,
						    	jnGroup ) ;
					break ;
			}
		}
	    }
	    if( *msg == EMS_I_NoSolution ) {
		/*
	 	 * do an intersection of the bottom surface with the plate
		 * solid 
		 */
		plSol.mod_env	= plateObj.mod_env ;

		sts = vs$return_gr_copy( msg             = msg,
					 strEnv          = &plateObj.mod_env,
					 strElement      = plateObj._grid,
					 solidRep        = &plSol._grid);
		__CheckRC( sts, *msg, "vs$return_gr_copy",  wrapup ) ;

		VSgetJntFromInter( msg, bot0, &plSol, cst, 
					&matchCount, &matchList ) ;
		/*
		 * delete the solid that was generated 
		 */
		vs$bulk_delete(	grids	= &plSol._grid ,
				theEnv	= &plSol.mod_env ) ;
		if( matchCount ) {
			/*
			 * process the intersection information to get the 
	 		 * the joint group
			 */
			sts = VSprocessJntMatches( msg, matchCount, matchList, 
							cst, jnGroup ) ;
			__CheckRC( sts, *msg, "VSprocessJntMatches", wrapup ) ;
		}
	    }

	} else if( weldSide == VS_K_wldRightSide ) {
	    __DBGpr_com(" Weld Side is Right Side " );
		/*
		 * Intersect the offset surface of plate0 with
		 * either top or bottom of plate 1
		 */
	    for( i = 0, *msg = EMS_I_NoSolution ;
             		i < 2 && *msg == EMS_I_NoSolution ; i++ ) {

		switch( actions[i] ) {
			case TRY_EDG_BOT :
				__DBGpr_com( "TRY_EDG_BOT" ) ;
				 sts = VSfindSfToSfJoints( msg, 
							VS_K_TRY_EDGE_SF,
							top0, bot1, cst, 
							jnGroup );
				break ;
			case TRY_EDG_EDG :
				__DBGpr_com( " TRY_EDG_EDGE " );
				 sts = VSfindSfToSfJoints( msg, 
							VS_K_TRY_EDGE_EDGE,
							top0, bot1, cst, 
							jnGroup );
				break ;
		}
	    }
	    if( *msg == EMS_I_NoSolution ) {
		for( i = 0, *msg = EMS_I_NoSolution ;
             		i < 2 && *msg == EMS_I_NoSolution ; i++ ) {
			switch( actions[i] ) {
				case TRY_EDG_BOT :
					__DBGpr_com(" Trying reverse TRY_EDG_BOT");
					sts = VSfindSfToSfJoints( msg, 
							VS_K_TRY_EDGE_SF,
							top0, top1, cst, 
							jnGroup );
					break ;

				case TRY_EDG_EDG :
					__DBGpr_com(" Trying reverse TRY_EDG_EDG");
					sts = VSfindSfToSfJoints( msg, 
							VS_K_TRY_EDGE_EDGE,
							top0, top1, cst, 
							jnGroup );
					break ;
			}
		}
	    }
	    if( *msg == EMS_I_NoSolution ) {
		plSol.mod_env	= plateObj.mod_env ;
		/*
		 * do an intersection of the offset surface with the plate
		 * solid
		 */
		sts = vs$return_gr_copy( msg             = msg,
					 strEnv          = &plateObj.mod_env,
					 strElement      = plateObj._grid,
					 solidRep        = &plSol._grid);
		__CheckRC( sts, *msg, "vs$return_gr_copy",  wrapup ) ;

		VSgetJntFromInter( msg, top0, &plSol, cst, 
					&matchCount, &matchList ) ;
		/*
		 * delete the solid that was generated 
		 */
		vs$bulk_delete(	grids	= &plSol._grid ,
				theEnv	= &plSol.mod_env ) ;
		if( matchCount ) {
			/*
			 * process the intersection information to get the 
	 		 * the joint group
			 */
			sts = VSprocessJntMatches( msg, matchCount, matchList, 
							cst, jnGroup ) ;
			__CheckRC( sts, *msg, "VSprocessJntMatches", wrapup ) ;
		}
	   }
	} else if( weldSide == VS_K_wldBothSides ){
		/*
		 * Take the bottom Surface and intersect with the plate solid
		 * Next take the top surface and do the intesection with the 
		 * plate solid
		 */

		plSol.mod_env	= plateObj.mod_env ;

		sts = vs$return_gr_copy( msg             = msg,
					 strEnv          = &plateObj.mod_env,
					 strElement      = plateObj._grid,
					 solidRep        = &plSol._grid);
		__CheckRC( sts, *msg, "vs$return_gr_copy",  wrapup ) ;

		VSgetJntFromInter( msg, bot0, &plSol, cst, 
					&matchCount, &matchList ) ;

		VSgetJntFromInter( msg, top0, &plSol, cst, 
					&matchCount, &matchList ) ;

		/*
		 * delete the plate solid copied
		 */
		vs$bulk_delete(	grids	= &plSol._grid ,
				theEnv	= &plSol.mod_env ) ;
		
		if( matchCount ) {
			sts = VSprocessJntMatches( msg, matchCount, matchList, 
							cst, jnGroup ) ;
			__CheckRC( sts, *msg, "VSprocessJntMatches", wrapup ) ;

		} else vs$failure() ;
	}

	wrapup :
		if( matchList ) VSfreeMatchList( matchList );
		_FREE( botGeom0 ) ; _FREE( botGeom1 ) ; _FREE( topGeom1 ) ;

		End
		return sts ;

} /* VSfindPlateToPlateJoints */
/*----------------------------------------------------------------------------*/


