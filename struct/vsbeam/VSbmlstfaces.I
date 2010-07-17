/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdlib.h>
#include "DImacros.h"
#include "growner.h"
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

extern long	VSgetCmpNameAndDescr() ;

from VScompcurve import VSgetMapping ;
/*----------------------------------------------------------------------------*/
long VSlistBeamFaces( msg, beam, count, faceNames, faceDescs )

long		*msg ;
struct GRid	*beam ;
int		*count ;
char		***faceNames ;
long		**faceDescs ; {

	long		sts ;		/* OM return code		*/
	struct GRid	profileDef ;	/* Id of prof. macro occurrence	*/
	struct GRobj_env
			profileCv ;	/* Id of profile curve		*/
	int		mapSize,	/* Size of mapping array	*/
			*mapArray,	/* Mapping array		*/
			i ;		/* Loop index			*/
	char		*name ;

	mapArray = NULL ; *faceNames = NULL ; *faceDescs = NULL ;

	sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
							msg, &profileDef ),
			senderid= beam->objid,
			targetid= beam->objid,
			targetos= beam->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	sts = vs$get_graphic_section(	msg		= msg,
					sectDef		= &profileDef,
					representation	= AC_3D_REP,
					section		= &profileCv ) ;
	__CheckRC( sts, *msg, "vs$get_graphic_section", wrapup ) ;

	sts = om$send(	msg	= message VScompcurve.VSgetMapping(
						msg, &mapSize, &mapArray ),
			senderid= beam->objid,
			targetid= profileCv._objid,
			targetos= profileCv._osnum ) ;
	__CheckRC( sts, *msg, "VScompcurve.VSgetMapping", wrapup ) ;

	*count = mapSize + 2 ;

	*faceNames  = VSallocList( *count, 40 ) ;
	*faceDescs  = _MALLOC( *count, long ) ;
	
	if( !( *faceNames && *faceDescs ) ) vs$mem_fail() ;

	for( i = 0 ; i < mapSize ; i++ ) {

		sts = VSgetCmpNameAndDescr(	msg,
						mapArray[i],
						&name,
						*faceDescs + i ) ;
		__CheckRC( sts, *msg, "VSgetCmpNameAndDescr", wrapup ) ;

		DIstmcpy(	(*faceNames)[i],
				VS_K_bmGrCmpName,
				VS_K_bmBody,
				name,
				NULL ) ;

	}

	DIstmcpy(	(*faceNames)[mapSize+0],
			VS_K_bmGrCmpName,
			VS_K_bmBeginCap,
			NULL ) ;
	(*faceDescs)[mapSize+0] = VS_gI_BmBegCap ;

	DIstmcpy(	(*faceNames)[mapSize+1],
			VS_K_bmGrCmpName,
			VS_K_bmEndCap,
			NULL ) ;
	(*faceDescs)[mapSize+1] = VS_gI_BmEndCap ;

	*msg = MSSUCC ; sts = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			VSfreeList( *count, *faceNames ); *faceNames = NULL ;
			_FREE( *faceDescs )		; *faceDescs = NULL ;
			*count = 0 ;
			*msg = EMS_I_Fail ;
			sts  = OM_S_SUCCESS ;
		}
		_FREE( mapArray ) ;
		return sts ;

} /* VSlistBeamFaces */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
