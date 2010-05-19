/*
	I/VDS	Copy
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "OMerrordef.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscvcvint.h"
#include "v_docvsovlap.h"
#include "v_vecmxproto.h"

#define EQPARMS( p1, p2 ) VD_zeroDist( fabs( (p1) - (p2) ) )

/*----------------------------------------------------------------------------*/
long VD_doCurvesOverlap( msg, cv0, cv1, ovlInfo )

long			*msg ;
struct IGRbsp_curve	*cv0,
			*cv1 ;
VD_overlapInfo		*ovlInfo ; {

	long		sts ;		/* Completion code		*/
	int		nint,		/* Count of intersections	*/
			nover ;		/* Count of overlaps		*/
	IGRboolean	alloc = TRUE;	/* Alloc memory for outputs	*/
	double		*xintpts,	/* Intersection points		*/
			*xpar0,		/* Parms of above on curve 0	*/
			*xpar1,		/* Parms of above on curve 1	*/
			*xendpts,	/* End points of overlaps	*/
			*xover0,	/* Parms of above on curve 0	*/
			*xover1,	/* Parms of above on curve 1	*/
			*tBuf,
			*tmp ;
	int		i,
			total0,		/* Curve 0 totally covered ?	*/
			total1 ;	/* Curve 1 totally covered ?	*/

	SetProc( VD_doCurvesOverlap ) ; Begin

	xintpts = xpar0 = xpar1 = xendpts = xover0 = xover1 = NULL ; 
	ovlInfo->t0start	= ovlInfo->t0end
				= ovlInfo->t1start
				= ovlInfo->t1end   	= NULL ;
	ovlInfo->count	= 0 ;

	BScvcvint(	cv0,
			cv1,
			TRUE,	/* Remove duplicates		*/
			0,	/* Preallocated size for int's	*/
			0,	/* Preallocated size for ovlp's	*/
			NULL,	/* Not preallocated		*/
			NULL,	/* Not preallocated		*/
			NULL,	/* Not preallocated		*/
			NULL,	/* Not preallocated		*/
			NULL,	/* Not preallocated		*/
			NULL,	/* Not preallocated		*/
			&nint,
			&nover,
			&alloc,	/* Allocate for intersections	*/
			&alloc,	/* Allocate for overlaps	*/
			(IGRpoint **) &xintpts,
			&xpar0,
			&xpar1,
			(IGRpoint **) &xendpts,
			&xover0,
			&xover1,
			msg ) ;

	if( BSERROR( *msg ) || !nover ) {
		/*
		 * Error or no overlaps.
		 */
		ovlInfo->code	= VD_K_NO_OVERLAP ;
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
		goto wrapup ;
	}
	__DBGpr_int( "Count of overlaps", nover ) ;
	__DBGpr_int( "Count of intersections", nint ) ;

	ovlInfo->count = nover ;

	/*
	 * CAUTION: xover0 and xover1 SEEM to be inverted ...
	 */
	tmp = xover0 ; xover0 = xover1 ; xover1 = tmp ;

	if( nover > 1 ) {
		ovlInfo->code = VD_K_COMMON_PORTION ;
	} else {

		total0 =        EQPARMS( xover0[0], 0. )
			     && EQPARMS( xover0[1], 1. )
			 ||     EQPARMS( xover0[0], 1. )
			     && EQPARMS( xover0[1], 0. ) ;

		total1 =        EQPARMS( xover1[0], 0. )
			     && EQPARMS( xover1[1], 1. )
			 ||     EQPARMS( xover1[0], 1. )
			     && EQPARMS( xover1[1], 0. ) ;

		if( total0 ) {
			__DBGpr_com( "Total 0" ) ;
			if( total1 ) {
				__DBGpr_com( "Total 1" ) ;
				ovlInfo->code = VD_K_TOTAL_MATCH ;
			} else {
				__DBGpr_com( "Partial 1" ) ;
				ovlInfo->code = VD_K_0_COVERS_1 ;
			}
		} else {
			__DBGpr_com( "Partial 0" ) ;
			if( total1 ) {
				__DBGpr_com( "Total 1" ) ;
				ovlInfo->code = VD_K_1_COVERS_0 ;
			} else {
				__DBGpr_com( "Partial 1" ) ;
				ovlInfo->code = VD_K_COMMON_PORTION ;
			}
		}
	}

	if( !( tBuf = _MALLOC( 4 * nover, double ) ) ) vd_$mem_fail() ;

	ovlInfo->t0start	= tBuf ;
	ovlInfo->t0end		= ovlInfo->t0start + nover ;
	ovlInfo->t1start	= ovlInfo->t0end   + nover ;
	ovlInfo->t1end		= ovlInfo->t1start + nover ;

	for( i = 0 ; i < nover ; i++ ) {
		ovlInfo->t0start[i]	= xover0[2*i+0] ;
		ovlInfo->t0end  [i]	= xover0[2*i+1] ;
		ovlInfo->t1start[i]	= xover1[2*i+0] ;
		ovlInfo->t1end  [i]	= xover1[2*i+1] ;
		__DBGpr_int( "Overlap #", i ) ;
		__DBGpr_dbl( "t0start", ovlInfo->t0start[i] ) ;
		__DBGpr_dbl( "t0end  ", ovlInfo->t0end  [i] ) ;
		__DBGpr_dbl( "t1start", ovlInfo->t1start[i] ) ;
		__DBGpr_dbl( "t1end  ", ovlInfo->t1end  [i] ) ;
	}

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		_FREE( xintpts	) ;
		_FREE( xpar0	) ;
		_FREE( xpar1	) ;
		_FREE( xendpts	) ;
		_FREE( xover0	) ;
		_FREE( xover1	) ;
		End
		return sts ;

} /* VD_doCurvesOverlap */
/*----------------------------------------------------------------------------*/

