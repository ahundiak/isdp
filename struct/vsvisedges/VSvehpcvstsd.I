/*
	I/STRUCT
*/
class implementation GRgraphics ;

#include <stdio.h>
#include <stdlib.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "growner.h"
#include "vsvedef.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvisedproto.h"

extern long	VSdrwIsSolidOrSurface() ;
extern long	VSveFindHiddenPartsOfCurveWithSetOfSf() ;


/*----------------------------------------------------------------------------*/
long VSveFindHiddenPartsOfCurveWithSolSurfs( msg, cvId, cvEnv, nbSolSurf,
					     solSurfObj, viewVector, nb_part,
					     part_pt_s, part_pt_e, part_pm_s,
					     part_pm_e )

long			*msg ;
const struct GRid	*cvId ;
const struct GRmd_env 	*cvEnv ;
int			nbSolSurf ;
const struct GRobj_env	*solSurfObj ;
const IGRvector		viewVector ;
int			*nb_part ;
double			**part_pt_s,
			**part_pt_e,
			**part_pm_s,
			**part_pm_e ; {

	/*
	 * Given a curve ( cvId, cvEnv ) and a set of solids / surfaces
	 * ( nbSolSurf, solSurfObj ), this function returns the number of
	 * parts which are hidden by the solids / surfaces with respect to a
	 * view vector ( nb_part ), the start point ( part_pt_s ) and
	 * corresponding parameter ( part_pm_s ), the end point ( part_pt_e )
	 * and corresponding parameter ( part_pm_e ) of each parts.
	 *
	 *
	 *			    View vector.
	 *				|
	 *				v
	 *
	 *		    ----------- <- Solid #0.
	 *		   /	      /|	   ------------- <- Surface #1.
	 *		  /	     / |	  /	       /
	 *		 /	    /  |	 *	      /
	 *		------------   |	/.	     /
	 *		|	   |   /       --------------
	 *		|	   |  / 	 .
	 *		| *	   | *		 .
	 *		| .	   |/.		 .
	 *		------------ .		 .
	 *		  .	     .		 .
	 *		  .	     .		 .
	 *		  .	     .		 .
	 *		  .	     .		 .
	 *	   --->---*----------*-----------*-------* <- Curve.
	 *	      ^   A	     B		 C	 D
	 *	      |
	 *	   Orientation
	 *	   of curve.
	 *
	 * Here, we have 2 parts ( nb_part = 2 ).
	 *
	 * Part #1 :
	 * =========
	 * part_pt_s[0] = A	( with part_pm_s[0] ).
	 * part_pt_e[0] = B	( with part_pm_e[0] ).
	 *
	 * Part #2 :
	 * =========
	 * part_pt_s[1] = C	( with part_pm_s[1] ).
	 * part_pt_e[1] = D	( with part_pm_e[1] ).
	 *
	 */

	long			sts ;	     /* Completion code.	      */
	int			i,	     /* Loop index.		      */
				j,	     /* Loop index.		      */
				relShip,     /* Relationship between two      */
					     /* ranges. 		      */
				nbSurfSol,   /* Number of surfaces of a solid.*/
				nbSurf,      /* Number of surfaces which hide */
					     /* input curve.		      */
				sol1_surf0 ; /* Is a solid or surface ?       */
	struct GRid		*surfSol ;   /* List of surfaces of a solid.  */
	struct GRobj_env	*surfaces ;  /* List of surfaces which hide   */
					     /* the input curve.	      */
	IGRboolean		world ;      /* Compute range in world	      */
					     /* coordinate.		      */
	GRrange 		cvRange,     /* Range of input curve.	      */
				ssRange ;    /* Range of a solid / surface.   */

	SetProc( VSveFindHiddenPartsOfCurveWithSolSurfs ); Begin

	*nb_part   = 0 ;
	*part_pt_s = *part_pt_e = *part_pm_s = *part_pm_e = NULL ;

	nbSurfSol  = nbSurf = 0 ;
	surfSol    = NULL ;
	surfaces   = NULL ;

	__DBGpr_obj( "Curve", *cvId ) ;

	/*
	 * Get range of curve.
	 */
	world = TRUE ;

#define CVENV		((struct GRmd_env*) cvEnv)
#define SOLSURFOBJ	((struct GRobj_env*) solSurfObj)
	sts = om$send( msg	= message GRgraphics.GRgetrang(
							   msg,
							   &CVENV->_MATRIX_TYPE,
							   CVENV->_MATRIX,
							   &world,
							   cvRange ),
		       senderid = cvId->objid,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Min range of curve", cvRange     ) ;
	__DBGpr_vec( "Max range of curve", cvRange + 3 ) ;

	/*
	 * For each solid/surface which hides the curve ( we test only on
	 * ranges ), add surface(s) ( component surfaces for solid ) to list
	 * of surfaces which hide the input curve.
	 */
	for( i=0; i<nbSolSurf; i++ ) {
		__DBGpr_obj( "Solid / Surface", solSurfObj[i]._grid ) ;

		/*
		 * See if it's really a solid or a surface.
		 */
		sts = VSdrwIsSolidOrSurface( msg,
					     &solSurfObj[i]._grid,
					     &solSurfObj[i].mod_env,
					     &sol1_surf0 ) ;

		if( *msg == EMS_E_InvalidArg ) {
			__DBGpr_com( "Is not a solid or a surface" ) ;
			continue ;
		}

		/*
		 * Get range of solid / surface.
		 */
		sts = om$send( msg	= message GRgraphics.GRgetrang(
						    msg,
						    &SOLSURFOBJ[i]._matrix_type,
						    SOLSURFOBJ[i]._matrix,
						    &world,
						    ssRange ),
			       senderid = solSurfObj[i]._objid,
			       targetid = solSurfObj[i]._objid,
			       targetos = solSurfObj[i]._osnum ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

		__DBGpr_vec( "Min range of solid / surface", ssRange	) ;
		__DBGpr_vec( "Max range of solid / surface", ssRange +3 ) ;

		/*
		 * See if range of solid / surface hides range of curve.
		 */
		sts = VSveRangeRangeRelationShip( msg,
						  ssRange,	/* Range #0 */
						  cvRange,	/* Range #1 */
						  viewVector,
						  &relShip ) ;

		__CheckRC( sts, *msg, "VSveRangeRangeRelationShip", wrapup ) ;

		if( relShip == VS_K_0_IN_FRONT_OF_1 ||
		    relShip == VS_K_0_AT_THE_BACK_OF_1  ) {
			__DBGpr_com( "Curve is NOT HIDDEN by solid / surface" );
			continue ;
		}

		/*
		 * Find surfaces to add to list of surfaces which hide the input
		 * curve.
		 */
		if( sol1_surf0 ) {
			__DBGpr_com( "It's a SOLID" ) ;

			sts = vs$get_components(
					    msg        = msg,
					    grobjId    = &solSurfObj[i]._grid,
					    grobjEnv   = &solSurfObj[i].mod_env,
					    number     = &nbSurfSol,
					    components = &surfSol ) ;

			__CheckRC( sts, *msg, "vs$get_components", wrapup ) ;

			__DBGpr_int( "Number of surfaces of solid", nbSurfSol );
			__DBGpr_objlist( "Surfaces", nbSurfSol, surfSol       );

		} else {
			__DBGpr_com( "It's a SURFACE" ) ;
			nbSurfSol = 1 ;
		}

		/*
		 * Add surfaces to list of surfaces which hide input curve.
		 */
		if( nbSurf ) {
			if( !( surfaces = _REALLOC( surfaces,
						    nbSurf + nbSurfSol,
						    struct GRobj_env ) ) )
				vs$mem_fail() ;
		} else {
			if( !( surfaces = _MALLOC( nbSurfSol,
						   struct GRobj_env ) ) )
				vs$mem_fail() ;
		}

		if( sol1_surf0 )
			for( j=0; j<nbSurfSol; j++ ) {
			    surfaces[nbSurf+j]._grid   = surfSol[j] ;
			    surfaces[nbSurf+j].mod_env = solSurfObj[i].mod_env ;
			}
		else surfaces[nbSurf] = solSurfObj[i] ;

		nbSurf += nbSurfSol ;

		_FREE( surfSol ) ;
		surfSol   = NULL ;
		nbSurfSol = 0 ;
	}

	/*
	 * Find hidden parts of input curve with list of surfaces which hide
	 * it.
	 */
	sts = VSveFindHiddenPartsOfCurveWithSetOfSf( msg,
						     cvId,
						     cvEnv,
						     nbSurf,
						     surfaces,
						     viewVector,
						     nb_part,
						     part_pt_s,
						     part_pt_e,
						     part_pm_s,
						     part_pm_e ) ;

	__CheckRC( sts, *msg, "VSveFindHiddenPartsOfCurveWithSetOfSf", wrapup );

#ifdef vsDEBUG
	__DBGpr_int( "Number of hidden parts", *nb_part ) ;
	__DBGpr_com( "List of hidden parts" ) ;
	__DBGpr_com( "--------------------" ) ;
	for( i=0; i<*nb_part; i++ ) {
		__DBGpr_int( "number", i		) ;
		__DBGpr_vec( "\tstart", *part_pt_s +3*i ) ;
		__DBGpr_dbl( "\tpm   ", (*part_pm_s)[i] ) ;
		__DBGpr_vec( "\t\tend", *part_pt_e +3*i ) ;
		__DBGpr_dbl( "\t\tpm ", (*part_pm_e)[i] ) ;
	}
	__DBGpr_com( "--------------------" ) ;
#endif

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *part_pt_s ) ; *part_pt_s = NULL ;
			_FREE( *part_pt_e ) ; *part_pt_e = NULL ;
			_FREE( *part_pm_s ) ; *part_pm_s = NULL ;
			_FREE( *part_pm_e ) ; *part_pm_e = NULL ;
			*nb_part = 0 ;
		}

		_FREE( surfSol	) ;
		_FREE( surfaces ) ;

		End
		return sts ;

} /* VSveFindHiddenPartsOfCurveWithSolSurfs */
/*----------------------------------------------------------------------------*/

end implementation GRgraphics ;
