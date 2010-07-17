/*
	I/STRUCT
*/
class implementation ASsource ;

#include "madef.h"
#include "exmacros.h"
#include "godef.h"
#include "nddef.h"
#include "asmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsobjgarbage.h"

extern struct GRid	NULL_GRID ;

from GRgraphics	import GRchgprops ;
/*----------------------------------------------------------------------------*/
long VSmakeGraphicObjectTemporary( msg, graphicObject, invisible )

long			*msg ;
struct GRid		*graphicObject ;
int			invisible ; {

	long			sts ;
	struct GRid		source ;
	struct GRmd_env		env ;

	*msg = MSSUCC ;

	if( invisible ) {
		short		action	= 0,
				props	= GRIS_LOCATABLE | GRIS_DISPLAYABLE ;

		sts = om$send(	msg	= message GRgraphics.GRchgprops(
								msg,
								&action,
								&props ),
				senderid= graphicObject->objid,
				targetid= graphicObject->objid,
				targetos= graphicObject->osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;
	}
	sts = as$make_source(	go_grid	= *graphicObject,
				as_os	= graphicObject->osnum,
				as_grid	= &source ) ;
	__CheckRC( sts, 1, "as$make_source", wrapup ) ;

	sts = om$send(	msg	= message NDnode.NDchg_state(
					ND_DEL_NO_CH | ND_WAIT_DEL,
					ND_DEL_NO_CH | ND_WAIT_DEL ),
			senderid= NULL_OBJID,
			targetid= source.objid,
			targetos= source.osnum ) ;

	MAidmx( msg, env._MATRIX ) ; env._MATRIX_TYPE = MAIDMX ;
	env._MD_OS = graphicObject->osnum ;
	ex$get_modid( mod_osnum = env._MD_OS, mod_id = &env._MD_ID ) ;

	VSrecordTmpObj( &source, &env ) ;

	wrapup :
		return sts ;

} /* VSmakeGraphicObjectTemporary */
/*----------------------------------------------------------------------------*/

end implementation ASsource ;

