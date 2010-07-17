/* $Id: VSdocvsovlap.C,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSdocvsovlap.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdocvsovlap.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/11/14  13:11:46  pinnacle
 * Replaced: vsjoint/VSdocvsovlap.C for:  by svkadamb for struct
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
#include <math.h>
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
#include "bscvcvint.h"
#include "bscvcv_int.h"
#include "vsdocvsovlap.h"
#include "vsvecmxproto.h"

#define EQPARMS( p1, p2 ) VSzeroDist( fabs( (p1) - (p2) ) )
/*----------------------------------------------------------------------------*/
long VSdoCurvesOverlap( msg, cv0, cv1, ovlInfo )

long			*msg ;
struct IGRbsp_curve	*cv0,
			*cv1 ;
VSoverlapInfo		*ovlInfo ; {

	long		sts ;		/* Completion code		*/
	int		nint;		/* Count of intersections	*/
	long		nover ;		/* Count of overlaps		*/
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

	SetProc( VSdoCurvesOverlap ) ; Begin

	xintpts = xpar0 = xpar1 = xendpts = xover0 = xover1 = NULL ; 
	ovlInfo->t0start	= ovlInfo->t0end
				= ovlInfo->t1start
				= ovlInfo->t1end   	= NULL ;
	ovlInfo->count	= 0 ;
#if 0
	BScvcvint(	cv0,
			cv1,
			FALSE // TRUE,	/* Remove duplicates		*/
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
			&xintpts,
			&xpar0,
			&xpar1,
			&xendpts,
			&xover0,
			&xover1,
			msg ) ;
#endif
	BScvcv_int(	msg,
			cv0,
			cv1,
			&nint,
			&xintpts,
			&xpar0,
			&xpar1,
			&nover,
			&xendpts,
			&xover0,
			&xover1 );
	__DBGpr_int( "Count of overlaps", nover ) ;
	__DBGpr_int( "Count of intersections", nint ) ;

	if( BSERROR( *msg ) || !nover ) {
		/*
		 * Error or no overlaps.
		 */
		ovlInfo->code	= VS_K_NO_OVERLAP ;
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
		goto wrapup ;
	}

	ovlInfo->count = nover ;

	/*
	 * CAUTION: xover0 and xover1 SEEM to be inverted ...
	 */
	tmp = xover0 ; xover0 = xover1 ; xover1 = tmp ;

	if( nover > 1 ) {
		ovlInfo->code = VS_K_COMMON_PORTION ;
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
				ovlInfo->code = VS_K_TOTAL_MATCH ;
			} else {
				__DBGpr_com( "Partial 1" ) ;
				ovlInfo->code = VS_K_0_COVERS_1 ;
			}
		} else {
			__DBGpr_com( "Partial 0" ) ;
			if( total1 ) {
				__DBGpr_com( "Total 1" ) ;
				ovlInfo->code = VS_K_1_COVERS_0 ;
			} else {
				__DBGpr_com( "Partial 1" ) ;
				ovlInfo->code = VS_K_COMMON_PORTION ;
			}
		}
	}

	if( !( tBuf = _MALLOC( 4 * nover, double ) ) ) vs$mem_fail() ;

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

} /* VSdoCurvesOverlap */
/*----------------------------------------------------------------------------*/

