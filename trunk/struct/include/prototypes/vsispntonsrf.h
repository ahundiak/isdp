/*
	I/STRUCT
*/

#ifndef vsispntonsrf_include
#	define vsispntonsrf_include

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
VSisPointOnSurface		__((	long			*msg,
					struct GRmd_env		*surfEnv,
					struct GRid		*surfId,
					int			mkNatBdry,
					IGRpoint		testPoint,
					int			*inside )) ;

#endif
