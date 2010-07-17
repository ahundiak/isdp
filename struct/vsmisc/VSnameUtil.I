/*
	I/STRUCT
*/
class implementation GRoups ;

#include "OMerrordef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSisDirUsable( dirName, isHere, inActMod, isWritable )

char	*dirName ;
int	*isHere,
	*inActMod,
	*isWritable ; {

/*
 * This function is interfaced by macro vs$isDirUsable.
 */
	long		sts ;
	DIgrid		dirId ;
	OMuword		curModOs ;
	int		inA,
			isW,
			isH ;

	if( !inActMod	) inActMod	= &inA ;
	if( !isWritable ) isWritable	= &isW ;
	if( !isHere	) isHere	= &isH ;

	*inActMod = *isWritable = *isHere = FALSE ;

	sts = di$translate(	objname	= dirName,
				p_osnum	= &dirId.osnum,
				p_objid	= &dirId.objid ) ;
	if( !( sts & 1 ) ) { sts = OM_S_SUCCESS ; goto wrapup ; }

	*isHere = TRUE  ;
	ex$get_cur_mod( osnum = &curModOs ) ;

	if( dirId.osnum == curModOs ) {
		int	rc ;

		*inActMod = TRUE ;

		rc = om$send(	msg	= message GRoups.validate(
							&rc, DIR_R_WRITE ),
				senderid= dirId.objid,
				targetid= dirId.objid,
				targetos= dirId.osnum ) ;

		if( sts & 1 & rc ) *isWritable = TRUE ;

		sts = OM_S_SUCCESS ;
	}

	wrapup :
		return sts ;

} /* VSisDirUsable */
/*----------------------------------------------------------------------------*/

end implementation GRoups ;
