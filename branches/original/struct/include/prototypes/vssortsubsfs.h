/*
	I/STRUCT
*/

#ifndef vssortsubsfs_include
#	define vssortsubsfs_include

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
#ifndef growner_include
#	include "growner.h"
#endif

extern long
VSsort_sub_surfaces		__((	long			*msg,
					struct GRid		*surf1,
					struct GRid		*surf2,
					struct GRmd_env		*envOfSurfs,
					struct GRobj_env	*curve,
					struct GRid		*firstSurf,
					struct GRid		*secondSurf )) ;

#endif
