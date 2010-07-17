/*
	I/STRUCT
*/
class implementation GRvg ;

#include <stdio.h>
#include "growner.h"
#include "vscmd.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "LCptlocact.h"
#include "vsacthrproto.h"

from VSpart	import VSgetUserEditableAttr ;
/*----------------------------------------------------------------------------*/
int VSisAnEditableFeature_PFAH( object, args ) 

struct GRobj_env	*object ;
VSfenceArgs		*args ; {
	
	/*
	 * This function tests if object is an editable feature.
	 */
	long			sts,	/* OM return code		*/
				msg ;	/* Completion code		*/
	unsigned long		type,	/* Intrinsic type of element	*/
				attr ;	/* Mask of editable attributes	*/

	/*
	 * Get object's intrinsic type and attributes.
	 */
	sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							&msg, &type, &attr ),
		       senderid = object->_objid,
		       targetid = object->_objid,
		       targetos = object->_osnum ) ;
	__CheckRC( sts, msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	sts = type == args->value && attr ;

	wrapup :
	
	sts = ( sts & msg & 1 ) ? TRUE : FALSE ;
	
	return sts ;

} /* VSisAnEditableFeature_PFAH */
/*----------------------------------------------------------------------------*/
int VSisAnEditableFeature_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	/*
	 * Remove non-editable feature from the locate stack.
	 */
	long			sts ;	  /* OM return code		*/
	struct GRobj_env	feature ; /* Feature from locate stack.	*/
	VSfenceArgs		fargs ;

	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCargs->stack, entry, args, action );
		goto wrapup ;
	}

	feature._grid 	= entry->located_obj ;
	feature.mod_env	= entry->module_info ;

	fargs.value = LCargs->value ;
	sts = VSisAnEditableFeature_PFAH( &feature, &fargs ) ;

	sts = sts ? LCptlocact( (char *) LCargs->stack, entry, args, action )
		  : LC_RELOCATE ;

	wrapup :
		return sts ;
			
} /* VSisAnEditableFeature_LCAH */
/*----------------------------------------------------------------------------*/
	 	
end implementation GRvg ;
