/*
	I/STRUCT
*/
class implementation VSbooBeam ;

#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsrangebxint.h"
/*----------------------------------------------------------------------------*/
long VSfilterNotches( msg, beamBody, notchCnt, notchList, possCnt, possList )

long			*msg ;
int			notchCnt,
			*possCnt ;
struct GRobj_env	*beamBody,
			notchList[],
			possList[] ; {
 
	long		sts ;
	char		mapping[VS_K_bbMAX_NOTCHES] ;
					/* Beams/notches mapping array	*/
	int		i ;

	SetProc( VSfilterNotches ); Begin

	*possCnt = 0 ;

	if( notchCnt > VS_K_bbMAX_NOTCHES ) notchCnt = VS_K_bbMAX_NOTCHES ;

	sts = VSfindRngBoxInters(	msg,
					1,
					beamBody,
					notchCnt,
					notchList,
					TRUE,
					mapping ) ;
	__CheckRC( sts, *msg, "VSfindRngBoxInters", wrapup ) ;

#define MAPPING( u, v )	(mapping[ (v) * 1 + (u)])

	for( i = 0 ; i < notchCnt ; i++ ) {
		if( MAPPING( 0, i ) ) {
			possList[(*possCnt)++] = notchList[i] ;
		}
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		End
		return sts ;

} /* VSfilterNotches */
/*----------------------------------------------------------------------------*/

end implementation VSbooBeam ;

