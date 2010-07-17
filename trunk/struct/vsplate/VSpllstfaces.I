/*
	I/STRUCT
*/
class implementation VSplate ;

#include <stdlib.h>
#include "DImacros.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSlistPlateFaces( msg, plate, count, faceNames, faceDescs )

long		*msg ;
struct GRid	*plate ;
int		*count ;
char		***faceNames ;
long		**faceDescs ; {

	long		sts ;		/* OM return code		*/

	*count = 2 ;

	*faceNames  = VSallocList( *count, 40 ) ;
	*faceDescs  = _MALLOC( *count, long ) ;
	
	if( !( *faceNames && *faceDescs ) ) vs$mem_fail() ;


	DIstmcpy(	(*faceNames)[0],
			VS_K_plGrCmpName,
			VS_K_plBotSfName,
			NULL ) ;
	(*faceDescs)[0] = VS_gI_PlBotSurf ;



	DIstmcpy(	(*faceNames)[1],
			VS_K_plGrCmpName,
			VS_K_plTopSfName,
			NULL ) ;
	(*faceDescs)[1] = VS_gI_PlTopSurf ;

	*msg = MSSUCC ; sts = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			VSfreeList( *count, *faceNames ); *faceNames = NULL ;
			_FREE( *faceDescs )		; *faceDescs = NULL ;
			*count = 0 ;
		}
		return sts ;

} /* VSlistPlateFaces */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
