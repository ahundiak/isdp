/*
	I/STRUCT
*/
class implementation GRvg ;

#include <stdio.h>
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "growner.h"
#include "vsdef.h"
#include "vscmd.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "LCptlocact.h"
#include "vsacthrproto.h"
/*----------------------------------------------------------------------------*/
int VSrejectSubClass_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	long	sts ;
	char	*subClass ;
	OMuword	entryClassid ;

	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCargs->stack, entry, args, action );
		return sts ;
	}

	subClass = (char *) LCargs->value ;

	sts = om$get_classid(	objid		= entry->located_obj.objid,
				osnum		= entry->located_obj.osnum,
				p_classid	= &entryClassid ) ;
	if( !( sts & 1 ) ) { sts = FALSE ; goto wrapup ; }

	sts = om$is_ancestry_valid(	superclassname	= subClass,
					subclassid	= entryClassid ) ;
	sts = sts == OM_S_SUCCESS ? FALSE : TRUE ;

	wrapup :
		sts = sts ? LCptlocact( (char *) LCargs->stack, entry, args,
			    action )
		          : LC_RELOCATE ;
		return sts ;

} /* VSrejectSubClass_LCAH */
/*----------------------------------------------------------------------------*/
int VSrejectSubClass_PFAH( object, args )

struct GRobj_env	*object ;
VSfenceArgs		*args ; {

	long	sts ;
	char	*subClass ;
	OMuword	entryClassid ;

	subClass = (char *) args->value ;

	sts = om$get_classid(	objid		= object->_objid,
				osnum		= object->_osnum,
				p_classid	= &entryClassid ) ;
	if( !( sts & 1 ) ) { sts = FALSE ; goto wrapup ; }

	sts = om$is_ancestry_valid(	superclassname	= subClass,
					subclassid	= entryClassid ) ;
	sts = sts == OM_S_SUCCESS ? FALSE : TRUE ;

	wrapup :
		return sts ;

} /* VSrejectSubClass_PFAH */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

