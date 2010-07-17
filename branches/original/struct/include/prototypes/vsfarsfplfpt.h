/*
	I/STRUCT
*/

#ifndef vsfarsfplfpt_include
#	define vsfarsfplfpt_include

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
#ifndef igr_include
#	include "igr.h"
#endif

extern double
VSfarthestSfPoleFromPt		__((	IGRpoint		point,
					struct IGRbsp_surface	*surface,
					IGRpoint		farthest )) ;

#endif

