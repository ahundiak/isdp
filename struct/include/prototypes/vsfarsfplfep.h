/*
	I/STRUCT
*/

#ifndef vsfarsfplfep_include
#	define vsfarsfplfep_include

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
VSfarthestSfPoleFromLnEndPt	__((	struct IGRbsp_surface	*surface,
					struct IGRbsp_curve	*lineseg,
					int			whichEnd,
					IGRpoint		farPolePrj )) ;

#endif

