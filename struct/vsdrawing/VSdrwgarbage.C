/*
	I/STRUCT
*/
#include <stdlib.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdrwmacros.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
int VSdrwAddGarbage( msg, xData, temporary )

long			*msg ;
VSdrwExecData		*xData ;
const struct GRobj_env	*temporary ; {

	VSdrwGarbage	*new,
			*previous ;

	if( !( new = _MALLOC( 1, VSdrwGarbage ) ) ) {
		*msg = EMS_E_NoDynamicMemory ; return FALSE ;
	}

	new->temporary		= *temporary ;
	previous		= xData->garbageList ;
	xData->garbageList	= new ;
	new->next		= previous ;

	*msg = MSSUCC ;
	return TRUE ;

} /* VSdrwAddGarbage */
/*----------------------------------------------------------------------------*/
void VSdrwCollectGarbage( xData ) VSdrwExecData	*xData ; {

	VSdrwGarbage	*g = xData->garbageList,
			*n ;

	while( g ) {
		vs$bulk_delete(	objenvs = &g->temporary ) ;
		n = g->next ;
		free( g ) ;
		g = n ;
	}

	xData->garbageList = NULL ;

} /* VSdrwCollectGarbage */
/*----------------------------------------------------------------------------*/

