/*
	I/STRUCT
*/
#ifndef vsvcmpmacros_include
#	define vsvcmpmacros_include

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

/*+M
Macro vs$makeVirtualComponent

Abstract
	Given an associative complex and a graphic object, creates a virtual
	component of the associative complex representing the graphic object.
	This will allow the graphic object, without being linked to the
	associative complex to behave associativity-wise as if it were a
	real component of its associative complex owner.
Arguments
	OUT	long		*msg	Completion code.
	IN	struct GRmd_env	*modEnv	Module environment of graphic object.
	IN	struct GRid	*owner	Owner of virtual component.
	IN	struct GRid	*grObj	Graphic object.
	IN	char		*path	Path associated in complex with
					virtual component.
	OUT	struct GRid	*virtCmp
					Virtual component.
-M*/
extern long
VSmakeVirtualComponent		__((	long		*msg,
					struct GRmd_env	*modEnv,
					struct GRid	*owner,
					struct GRid	*grObj,
					char		*path,
					struct GRid	*virtCmp )) ;

#omdef	vs$makeVirtualComponent( msg, modEnv, owner, grObj, path, virtCmp )
	VSmakeVirtualComponent(	(msg),
				(modEnv),
				(owner),
				(grObj),
				(path),
				(virtCmp) )
#endomdef

#endif
