/*
	I/STRUCT
*/
class implementation VSdpb ;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMversion.h"
#include "exdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "vsdbgmacros.h"

extern struct GRid	VS_GS_DpbId ;
/*----------------------------------------------------------------------------*/
method sleep( int type ) {

	VS_GS_DpbId.objid = NULL_OBJID ;

	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/

end implementation VSdpb ;

