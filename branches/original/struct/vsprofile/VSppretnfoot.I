/*
	I/STRUCT
*/
class implementation VSproffrplts ;

#include <string.h>
#include "vssectiondef.h"
/*----------------------------------------------------------------------------*/
method ACreturn_foot(	long		*rc ;
			char		*ftNm ;
			struct GRid	*ftId ;
			short		*mxType ;
			IGRmatrix	mx ) {

	/*
	 * If asked for schematic or with-fillet curve, return without-fillet
	 * curve (we do not have those feet).
	 */
	if(    !strcmp( ftNm, VS_K_WFilletCv )
	    || !strcmp( ftNm, VS_K_SchematicCv ) ) {
	    	ftNm = VS_K_WoFilletCv ;
	}
	return om$send(	msg	= message VShelper.ACreturn_foot(
						rc, ftNm, ftId, mxType, mx ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	
} /* method ACreturn_foot */
/*----------------------------------------------------------------------------*/
 
end implementation VSproffrplts ;

