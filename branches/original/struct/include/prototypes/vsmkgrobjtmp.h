/*
	I/STRUCT
*/

#ifndef vsmkgrobjtmp_include
#	define vssmkgrobjtmp_include

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
VSmakeGraphicObjectTemporary	__((	long		*msg,
					struct GRid	*graphicObject,
					int		invisible )) ;

#endif
