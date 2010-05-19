/*
	I/VDS	Copy
*/

#ifndef v_objgarbage_include
#	define v_objgarbage_include

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

extern void
VD_recordTmpObj			__((	struct GRid	*id,
					struct GRmd_env	*env )) ;

extern void
VD_discardTmpObjs		__((	void )) ;

#endif
