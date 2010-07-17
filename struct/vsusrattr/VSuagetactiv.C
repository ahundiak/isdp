/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "exmacros.h"
#include "DImacros.h"
#include "msdef.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "vsdirdef.h"
/*----------------------------------------------------------------------------*/
long VSgetActiveUsrAttr( msg, baseName, activeUA )

/*
 * This function interfaced by macro vs$getActiveUsrAttr.
 */
long		*msg ;
GRname		baseName ;
struct GRid	*activeUA ; {

	long		sts ;
	GRname		UApathNm ;
	OM_S_OBJID	modId ;
	OMuword		modOs ;

	DIstmcpy(	UApathNm,
			VS_K_STRUCTdir,
			baseName,
			NULL ) ;

	if( !ex$get_cur_mod( id = &modId, osnum = &modOs ) ) {
		*msg	= MSFAIL ;
		sts	= OM_W_ABORT ;
		goto wrapup ;
	}
	sts = di$translate(	objname	= UApathNm,
				osnum	= modOs,
				p_objid	= &activeUA->objid ) ;
	switch( sts ) {
		case DIR_W_NAME_NOT_FOUND :
			activeUA->objid = NULL_OBJID ;
			*msg	= MSSUCC ;
			sts	= OM_S_SUCCESS ;
			break ;
		case DIR_S_SUCCESS :
			activeUA->osnum = modOs ;
			*msg	= MSSUCC ;
			sts	= OM_S_SUCCESS ;
			break ;
		default :
			*msg	= MSFAIL ;
			sts	= OM_W_ABORT ;
			break ;
	}
	wrapup :
		return sts ;

} /* VSgetActiveUsrAttr */
/*----------------------------------------------------------------------------*/

