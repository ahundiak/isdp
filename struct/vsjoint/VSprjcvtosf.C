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
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bsdtardupts.h"
#include "bsfreecv.h"
#include "bslngen.h"
#include "bspjcvnrsf.h"
/*----------------------------------------------------------------------------*/
long VSprojectCvToSf( msg, cvGeom, sfGeom, pjCount, pjGeoms )

long			*msg ;
struct IGRbsp_curve	*cvGeom,
			***pjGeoms ;
struct IGRbsp_surface	*sfGeom ;
int			*pjCount ; {

	long			sts ;
	int			i,
				numGrps	= 0,
				*numInGrps	= NULL ;
	BSpair			**uvpars ;
	IGRpoint		**pts ;
	IGRboolean		allOnCv ;
	struct IGRbsp_curve	*tmpCv ;

	SetProc( VSprojectCvToSf ) ; Begin

	*pjCount = 0 ;
	*pjGeoms = NULL ;

	BSpjcvnrsf(	cvGeom,
			sfGeom,
			0.01,
			&numGrps,
			&numInGrps,
			&uvpars,
			&pts,
			&allOnCv,
			msg ) ;

	__DBGpr_int( "Num grp", numGrps ) ;
	__DBGpr_int( "BSpjcvnrsf rc", *msg ) ;
	__DBGpr_int( "All on cv", allOnCv ) ;

	if( BSERROR( *msg ) || !numGrps ) {
		__DBGpr_com( "No solution" ) ;
		vs$error( stsval = OM_S_SUCCESS, msgval = EMS_I_NoSolution ) ;
	}

	if( !( *pjGeoms = _CALLOC( numGrps, struct IGRbsp_curve * ) ) ) {
		vs$mem_fail() ;
	}

	/*
	 * Now least-square-fit results.
	 */
	for( i = 0 ; i < numGrps ; i++ ) {
		__DBGpr_int( "Group index", numInGrps[i] ) ;
		if( numInGrps[i] == 2 ) {
			int	type ;
			BSalloccv(	2,
					2,
					FALSE,
					0,
					&tmpCv,
					msg ) ;
			if( BSERROR( *msg ) ) vs$mem_fail() ;
			BSlngen( msg, pts[i][0], pts[i][1], tmpCv, &type ) ;
			if( BSERROR( *msg ) ) vs$failure() ;
		} else {
			BSdtardupts(
				numInGrps[i],
				(double *) pts[i],
				4,		/* Order wanted		*/
				1,		/* Dummy, says BS	*/
				0,		/* No beginning tangent	*/
				0,		/* No ending tangent	*/
				NULL,		/* No beginning tangent	*/
				NULL,		/* No ending tangent	*/
				FALSE,		/* Don't want error info*/
				NULL,		/* Maximum error	*/
				NULL,		/* Average error	*/
				NULL,		/* Maximum indicator	*/
				NULL,		/* Maximum segment	*/
				&tmpCv,		/* Output curve		*/
				msg ) ;
			__DBGpr_int( "BSdtardupts rc", *msg ) ;

			if( BSERROR( *msg ) ) {
				__DBGpr_com( "No solution for fit" ) ;
				vs$error( stsval = OM_S_SUCCESS,
					  msgval = EMS_I_NoSolution ) ;
			}
		}

		(*pjGeoms)[i] = tmpCv ;
	}

	sts = OM_S_SUCCESS ;
	*msg= MSSUCC ;

	wrapup :
		/*
		 * Free memory allocated by BSpjcvnrsf.
		 */
		if( numGrps ) {
			for( i = 0 ; i < numGrps ; i++ ) {
					_FREE( uvpars[i] ) ;
					_FREE( pts[i] ) ;
			}
			_FREE( uvpars ) ; _FREE( pts ) ; _FREE( numInGrps ) ;
		}
		if( ( !( sts & 1 & *msg ) || *msg == EMS_I_NoSolution ) ) {
			if( *pjGeoms && numGrps ) {
				/*
				 * Clean up ...
				 */
				long	rc ;

				__DBGpr_com( "Cleaning up" ) ;
				for( i = 0 ; i < numGrps ; i++ ) {
					if( (*pjGeoms)[i] )
						BSfreecv( &rc, (*pjGeoms)[i]);
				}
				_FREE( *pjGeoms ) ;
				*pjGeoms = NULL ;
			}
		} else {
			*pjCount = numGrps ;
		}
		End
		return sts ;

} /* VSprojectCvToSf */
/*----------------------------------------------------------------------------*/
