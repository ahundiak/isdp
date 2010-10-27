/*
	I/VDS	Copy
*/

#ifndef v_getchildrn_include
#	define v_getchildrn_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif

/*+f
Function VD_getChildren

Abstract
	Returns the children of an associative object: those in the same object
	space on the to-children channel and those in other object spaces (
	which are of class ACpretendin) on the notification channel.
Arguments
	OUT	long		  *msg	  Completion code.
	IN	const struct GRid *object Assoc. obj. whose children are wanted.
	OUT	int		  *count  Count of children.
	OUT	struct GRid	  **list  List of children.
Keywords
	#children#list#memory#
Note
	The list of children is dynamically allocated and must be release with:
				if( *list ) free( *list ) ;
-f*/
extern long
VD_getChildren			__((	long			*msg,
					const struct GRid	*object,
					int			*count,
					struct GRid		**list  )) ;

/*+f
Function VD_getChildrenGoThruPretends

Abstract
	Returns the children of an associative object: those in the same object
	space on the to-children channel and those in other object spaces, but
	instead of gathering the ACpretendins on the notification channel,
	these are bypassed and their children are taken instead.
Arguments
	OUT	long		  *msg	  Completion code.
	IN	const struct GRid *object Assoc. obj. whose children are wanted.
	OUT	int		  *count  Count of children.
	OUT	struct GRid	  **list  List of children.
Keywords
	#children#list#memory#pretend#
Note
	The list of children is dynamically allocated and must be release with:
				if( *list ) free( *list ) ;
-f*/
extern long
VD_getChildrenGoThruPretends	__((	long			*msg,
					const struct GRid	*object,
					int			*count,
					struct GRid		**list  )) ;
/*+f
Function VD_findChildByType

Abstract
	Given an associative object, returns the first of its child which
	has a given type.
Arguments
	IN	const struct GRid *target   Assoc. obj. whose child is wanted
	IN	OMuword		  classIt   Wanted type for child.
	OUT	struct GRid	  *child    Child found.
Keywords
	#children#type#
Note
	If no child of the given type has been found, then `child->objid' is
	set to `NULL_OBJID'.
-f*/
extern long
VD_findChildByType		__((	const struct GRid	*target,
					OMuword			classId,
					struct GRid		*child )) ;

#endif
