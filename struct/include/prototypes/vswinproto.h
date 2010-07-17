/*
	I/STRUCT
*/
#ifndef vswinproto_include
#	define vswinproto_include

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

extern long
VScstSomeObjcVw		__((	long		*msg,
				char		*windowName,
				struct GRid	*someObjcWin,
				struct GRid	*someObjcGad )) ;

extern int
VSwnMakeName		__((	struct GRid	*modId,
				char		*seed,
				char		*wname )) ;

#endif

