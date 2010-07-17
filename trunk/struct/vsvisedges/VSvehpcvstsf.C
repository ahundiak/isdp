/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "growner.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"

extern long	VSveFindHiddenPartsOfCurveWithSurface() ;


/*----------------------------------------------------------------------------*/
static void VSsortPoint( point, pm, nb )

double	*point,
	*pm ;
int	nb ; {

	int		i,
			j ;
	double		tmp_pm ;
	IGRpoint	tmp_pt ;

	for( i=0; i<nb; i++ )
		for( j=i; j<nb; j++ )
			if( pm[j] < pm[i] ) {
				tmp_pm = pm[j] ;
				pm[j]  = pm[i] ;
				pm[i]  = tmp_pm ;

				VSvccpy( tmp_pt,     point +3*j ) ;
				VSvccpy( point +3*j, point +3*i ) ;
				VSvccpy( point +3*i, tmp_pt	) ;
			}

} /* VSsortPoint */
/*----------------------------------------------------------------------------*/
long VSveFindHiddenPartsOfCurveWithSetOfSf( msg, cvId, cvEnv, nbSf, sfObj,
					    viewVector, nb_part, part_pt_s,
					    part_pt_e, part_pm_s, part_pm_e )

long			*msg ;
struct GRid		*cvId ;
struct GRmd_env 	*cvEnv ;
int			nbSf ;
struct GRobj_env	*sfObj ;
double			*viewVector ;
int			*nb_part ;
double			**part_pt_s,
			**part_pt_e,
			**part_pm_s,
			**part_pm_e ; {

	/*
	 * Given a curve ( cvId, cvEnv ) and a set of surfaces ( nbSf, sfObj ),
	 * this function returns the number of parts which are hidden by the
	 * surfaces with respect to the view vector ( nb_part ), the start point
	 * ( part_pt_s ) and its corresponding parameter ( part_pm_s ), the end
	 * point ( part_pt_e ) and its corresponding parameter ( part_pm_e ) of
	 * each part.
	 *
	 *
	 *			    View vector.
	 *				|
	 *				v
	 *
	 *			 -------------- <- Surface #0.
	 *			/	     /	   -------------------
	 *		       /  --------  /	  /		    /
	 *		      /  /	/  /	 /		   /
	 *		     *	*      *  *	*		  /
	 *		    /. /.     /. /.    /.		 /
	 *		   / .-------- ./ .   ------------------- <- Surface #1.
	 *		  /  .	.      /  .	.
	 *		 --------------   .	.
	 *		     .	.      .  .	.
	 *		     .	.      .  .	.
	 *		     .	.      .  .	.
	 *		     .	.      .  .	.
	 *	   --->------*--*------*--*-----*-------* <- Curve.
	 *	      ^      A	B      C  D	E	F
	 *	      |
	 *	   Orientation
	 *	   of curve.
	 *
	 * Here, we have 3 parts ( nb_part = 3 ).
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
	 * Part #3 :
	 * =========
	 * part_pt_s[2] = E	( with part_pm_s[2] ).
	 * part_pt_e[2] = F	( with part_pm_e[2] ).
	 *
	 */

	long			sts ;	   /* Completion code.		      */
	int			i,	   /* Loop index.		      */
				j,	   /* Loop index.		      */
				k,	   /* Loop index.		      */
				nbPart ;   /* Number of hidden parts for each */
					   /* surface.	 		      */
	double			*partPtS,  /* List of start points for each   */
					   /* surface.	 		      */
				*partPtE,  /* List of end points for each     */
					   /* surface.	 		      */
				*partPmS,  /* List of parameters of start     */
					   /* points.			      */
				*partPmE ; /* List of parameters of end       */
					   /* points.			      */

	SetProc( VSveFindHiddenPartsOfCurveWithSetOfSf ); Begin

	*nb_part   = 0 ;
	*part_pt_s = *part_pt_e = *part_pm_s = *part_pm_e = NULL ;

	partPtS    = partPtE = partPmS = partPmE = NULL ;

	__DBGpr_obj( "Curve", *cvId ) ;
	__DBGpr_int( "Number of surfaces", nbSf ) ;

	/*
	 * For each surface, find hidden parts of curve and add parts to
	 * output lists.
	 */
	for( i=0; i<nbSf; i++ ) {

		__DBGpr_obj( "Find hidden parts with surface", sfObj[i]._grid );

		/*
		 * Find hidden parts.
		 */
		sts = VSveFindHiddenPartsOfCurveWithSurface( msg,
							     cvId,
							     cvEnv,
							     &sfObj[i]._grid,
							     &sfObj[i].mod_env,
							     viewVector,
							     &nbPart,
							     &partPtS,
							     &partPtE,
							     &partPmS,
							     &partPmE ) ;

		__CheckRC( sts, *msg, "VSveFindHiddenPartsOfCurveWithSurface",
			   wrapup ) ;

		__DBGpr_int( "Number of hidden parts", nbPart ) ;

		if( !nbPart ) continue ;

#ifdef vsDEBUG
		for( j=0; j<nbPart; j++ ) {
			__DBGpr_int( "number", j	     ) ;
			__DBGpr_vec( "\tstart", partPtS +3*j ) ;
			__DBGpr_dbl( "\tpm   ", partPmS[j]   ) ;
			__DBGpr_vec( "\t\tend", partPtE +3*j ) ;
			__DBGpr_dbl( "\t\tpm ", partPmE[j]   ) ;
		}
#endif
		/*
		 * Add parts to output lists.
		 */
		if( *nb_part ) {
			if( !( *part_pt_s = _REALLOC( *part_pt_s,
						      3*( *nb_part +nbPart ),
						      double ) )	      ||
			    !( *part_pt_e = _REALLOC( *part_pt_e,
						      3*( *nb_part +nbPart ),
						      double ) )	      ||
			    !( *part_pm_s = _REALLOC( *part_pm_s,
						      *nb_part +nbPart,
						      double ) )	      ||
			    !( *part_pm_e = _REALLOC( *part_pm_e,
						      *nb_part +nbPart,
						      double ) )	      )
				vs$mem_fail() ;
		} else {
			if( !( *part_pt_s = _MALLOC( 3*nbPart, double ) ) ||
			    !( *part_pt_e = _MALLOC( 3*nbPart, double ) ) ||
			    !( *part_pm_s = _MALLOC( nbPart,   double ) ) ||
			    !( *part_pm_e = _MALLOC( nbPart,   double ) ) )
				vs$mem_fail() ;
		}

		for( j=0; j<nbPart; j++ ) {
			VSvccpy( *part_pt_s +3*(*nb_part +j), partPtS +3*j ) ;
			(*part_pm_s)[*nb_part +j] = partPmS[j] ;
			VSvccpy( *part_pt_e +3*(*nb_part +j), partPtE +3*j ) ;
			(*part_pm_e)[*nb_part +j] = partPmE[j] ;
		}

		*nb_part += nbPart ;

		_FREE( partPtS ) ; partPtS = NULL ;
		_FREE( partPtE ) ; partPtE = NULL ;
		_FREE( partPmS ) ; partPmS = NULL ;
		_FREE( partPmE ) ; partPmE = NULL ;
	}

	/*
	 * Find hidden parts.
	 */
	VSsortPoint( *part_pt_s, *part_pm_s, *nb_part ) ;
	VSsortPoint( *part_pt_e, *part_pm_e, *nb_part ) ;

	for( i=0, k=0; i<*nb_part; i++, k++ ) {
		VSvccpy( *part_pt_s +3*k, *part_pt_s +3*i ) ;
		(*part_pm_s)[k] = (*part_pm_s)[i] ;

		j = i + 1 ;
		while( j != *nb_part &&
		       i != *nb_part &&
		       (*part_pm_s)[j] <= (*part_pm_e)[i] ) {
			i++ ;
			j++ ;
		}

		VSvccpy( *part_pt_e +3*k, *part_pt_e +3*(j-1) ) ;
		(*part_pm_e)[k] = (*part_pm_e)[j-1] ;
	}

	*nb_part = k ;

#ifdef vsDEBUG
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

		_FREE( partPtS ) ;
		_FREE( partPtE ) ;
		_FREE( partPmS ) ;
		_FREE( partPmE ) ;

		End
		return sts ;

} /* VSveFindHiddenPartsOfCurveWithSetOfSf */
/*----------------------------------------------------------------------------*/
