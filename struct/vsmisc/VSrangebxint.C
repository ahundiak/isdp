/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "bstypes.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */
#include "bsrgbxint.h"
/*----------------------------------------------------------------------------*/
long VSfindRngBoxInters( msg, card1, set1, card2, set2, wantStatus, mapping )

long		*msg ;
int		card1,
		card2,
		wantStatus ;
char		*mapping ;
struct GRobj_env*set1,
		*set2 ; {

	long		sts,
			BSrc ;		/* BS completion code		*/
	int		i1,		/* Loop index on set 1		*/
			i2 ;		/* Loop index on set 2		*/
	GRrange		interrng ;	/* Range of intersection box	*/
	IGRboolean	intersect ;	/* Do boxes intersect ?		*/
	char		buf[40] ;	/* ex$message buffer		*/
	GRrange		*RANGE1,	/* Ranges of set 1		*/
			*RANGE2,	/* Ranges of set 2		*/
			*alloc ;	/* Pointer to allocated buffer	*/

#define MAPPING( u, v ) (mapping[(v) * card1 + (u)])

	if( wantStatus ) {
		ex$message( msgnumb = VS_gI_Processing ) ;
	}
	if( !( alloc = _MALLOC( card1 + card2, GRrange ) ) ) {
		vs$mem_fail() ;
	}

	RANGE1 = alloc ;
	RANGE2 = alloc + card1 ;

	i2 = card1 * card2 ;
	for( i1 = 0 ; i1 < i2 ; i1++ ) mapping[i1] = FALSE ;

	for( i1 = 0 ; i1 < card1 ; i1++ ) {
		sts = vs$getRangeOfComposite(
				msg		= msg,
				composite	= set1 + i1,
				range		= (double *) (RANGE1 + i1) );
		if( !( sts & *msg & 1 ) ) {
			goto wrapup ;
		}
	}
	for( i2 = 0 ; i2 < card2 ; i2++ ) {
		sts = vs$getRangeOfComposite(
				msg		= msg,
				composite	= set2 + i2,
				range		= (double *) (RANGE2 + i2) );
		if( !( sts & *msg & 1 ) ) {
			goto wrapup ;
		}
	}

	for( i1 = 0 ; i1 < card1 ; i1++ ) {
		for( i2 = 0 ; i2 < card2 ; i2++ ) {
			if( wantStatus ) {
				sprintf( buf, "%d/%d", i1, i2 ) ;
				ex$message(	field		= ERROR_FIELD,
						justification	= CENTER_JUS,
						in_buff		= buf ) ;
			}
			BSrgbxint(	&RANGE1[i1][0],
					&RANGE1[i1][3],
					&RANGE2[i2][0],
					&RANGE2[i2][3],
					&intersect,
					interrng + 0,
					interrng + 3,
					&BSrc ) ;
			if( intersect ) {
				MAPPING( i1, i2 ) = TRUE ;
			}

		}
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		_FREE( alloc ) ;
		if( wantStatus ) {
			ex$message( msgnumb = VS_gI_EmptyMessage ) ;
		}
		return sts ;

#undef MAPPING

} /* VSfindRngBoxInters */
/*----------------------------------------------------------------------------*/

