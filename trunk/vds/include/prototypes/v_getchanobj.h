/*
	I/VDS	Copy
*/

#ifndef v_getchanobj_include
#	define v_getchanobj_include

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
Function VD_GetChanObjWithMalloc

Abstract
	Given an object and a channel selector, returns a dynamically
	allocated list of the objects on the channel.
Arguments
	IN	const struct GRid	*target	Object with channel.
	IN	const OM_p_CHANSELECT	*chan	Channel selector.
	OUT	int			*count	Count of objects on channel.
	OUT	struct GRid		**list	List of objects on channel.
Returns
	TRUE (success) or FALSE (error).
Keywords
	#channel#list#memory#
Note
	The memory allocated by this function must be release with:

		if( *list ) free( *list ) ;
-f*/
extern int
VD_GetChanObjWithMalloc		__((	const struct GRid	*target,
					const OM_p_CHANSELECT	chan,
					int			*count,
					struct GRid		**objects )) ;

#endif
