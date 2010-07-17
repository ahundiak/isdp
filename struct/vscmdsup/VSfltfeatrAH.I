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
#include "vsgrenvproto.h"

from VSfeature	import VSgetResultType ;
/*----------------------------------------------------------------------------*/
int VSfilterFeature_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	/*
	 * Accept structural elements of type `LCargs->value'.
	 */
	return VSfilterFeature( LCargs, entry, args, action,
				(unsigned long) LCargs->value, 0 ) ;

} /* VSfilterFeature_LCAH */
/*----------------------------------------------------------------------------*/
int VSfilterFeature_PFAH( object, args )

struct GRobj_env	*object ;
VSfenceArgs		*args ; {

	/*
	 * Accept structural elements of type `arg->value'.
	 */
	return VSfilterFeature_PF( object, args,
				  (unsigned long) args->value, 0 ) ;

} /* VSfilterFeature_PFAH */
/*----------------------------------------------------------------------------*/
int VSfilterFeatureNeg_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	/*
	 * Reject structural elements of type `LCargs->value'.
	 */
	return VSfilterFeature( LCargs, entry, args, action,
				~0, (unsigned long) LCargs->value ) ;

} /* VSfilterFeatureNeg_LCAH */
/*----------------------------------------------------------------------------*/
int VSfilterFeatureNeg_PFAH( object, args )

struct GRobj_env	*object ;
VSfenceArgs		*args ; {

	/*
	 * Reject structural elements of type `arg->value'.
	 */
	return VSfilterFeature_PF( object, args,
				   ~0, (unsigned long) args->value ) ;

} /* VSfilterFeatureNeg_PFAH */
/*----------------------------------------------------------------------------*/
int VSnoFrozenFeature_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	/*
	 * Accept structural elements of type `LCargs->value', but not frozen.
	 */
	return VSfilterFeature( LCargs, entry, args, action,
				(unsigned long) LCargs->value,
				VS_m_FRZ_generic ) ;

} /* VSnoFrozenFeature_LCAH */
/*----------------------------------------------------------------------------*/
int VSnoFrozenFeature_PFAH( object, args )

struct GRobj_env	*object ;
VSfenceArgs		*args ; {

	/*
	 * Accept structural elements of type `arg->value', but not frozen.
	 */
	return VSfilterFeature_PF( object, args, (unsigned long) args->value,
				   VS_m_FRZ_generic ) ;

} /* VSnoFrozenFeature_PFAH */
/*----------------------------------------------------------------------------*/
int VSfilterFeature( LCargs, entry, args, action, yesMask, noMask )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ;
unsigned long		yesMask,
			noMask ; {

	long			sts,
				msg ;
	unsigned long		type ;

	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCargs->stack, entry, args, action );
		return sts ;
	}

	/*
	 * Get type of entry object, follwing message will fail if message
	 * not recognized by target object, which is OK.
	 */
	sts = om$send( msg	= message VSfeature.VSgetResultType(
								&msg, &type ),
		       senderid = entry->located_obj.objid,
		       targetid = entry->located_obj.objid,
		       targetos = entry->located_obj.osnum ) ;
	__CheckRC( sts, msg, "VSfeature.VSgetResultType", wrapup ) ;

	if( ( type & yesMask ) && !( type & noMask ) ) {
		sts = TRUE ;
	} else {
		if( LCargs->rejectSts != MS_NO_MSG ) {
			ex$message(	msgnumb		= LCargs->rejectSts,
					field		= ERROR_FIELD,
					justification	= CENTER_JUS ) ;
			VS_Wait_timer( 40 ) ;
		}
		sts = FALSE ;
	}
	wrapup :

	sts = (sts & msg & 1) ? LCptlocact( (char *) LCargs->stack, entry,
					    args, action )
		              : LC_RELOCATE ;

	return sts ;

} /* VSfilterFeature */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSfilterFeature_PF( object, args, yesMask, noMask )

struct GRobj_env	*object ;
VSfenceArgs		*args ;
unsigned long		yesMask,
			noMask ; {

	long			sts,
				msg ;
	unsigned long		type ;
	
	/*
	 * Get type of entry object.
	 */
	sts = om$send( msg	= message VSfeature.VSgetResultType(
								&msg, &type ),
		       senderid = object->_objid,
		       targetid = object->_objid,
		       targetos = object->_osnum ) ; 
	__CheckRC( sts, msg, "VSfeature.VSgetResultType", wrapup ) ;

	if( ( type & yesMask ) && !( type & noMask ) ) {
		sts = TRUE ;
	} else {
		sts = FALSE ;
	}

	wrapup :
		return (sts & msg & 1) ? TRUE : FALSE ;

} /* VSfilterFeature_PF */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

