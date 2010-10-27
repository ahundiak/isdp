/*
	I/VDS	Copy.
*/
#include <stdlib.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "v_drwmacros.h"
#include "v_miscmacros.h"
/*----------------------------------------------------------------------------*/
int VD_drwAddGarbage( msg, xData, temporary )

long			*msg ;
VD_drwExecData		*xData ;
const struct GRobj_env	*temporary ; {

	VD_drwGarbage	*new	   = NULL ,
			*previous  = NULL ;

	if( !( new = _MALLOC( 1, VD_drwGarbage ) ) ) {
		*msg = EMS_E_NoDynamicMemory ; return FALSE ;
	}

	new->temporary		= *temporary ;
	previous		= xData->garbageList ;
	xData->garbageList	= new ;
	new->next		= previous ;

	*msg = MSSUCC ;
	return TRUE ;

} /* VD_drwAddGarbage */
/*----------------------------------------------------------------------------*/
void VD_drwCollectGarbage( xData ) VD_drwExecData	*xData ; {

	VD_drwGarbage	*g = NULL, *n = NULL ;

	g = xData->garbageList ;

	while( g ) {
		vd_$bulk_delete(	objenvs = &g->temporary ) ;
		n = g->next ;
		_FREE( g ) ;
		g = n ;
	}

	xData->garbageList = NULL ;

} /* VD_drwCollectGarbage */
/*----------------------------------------------------------------------------*/

