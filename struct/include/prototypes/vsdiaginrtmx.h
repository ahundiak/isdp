/*
	I/STRUCT
*/

#ifndef vsdiaginrtmx_include
#	define vsdiaginrtmx_include

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

extern long
VSdiagInertiaMx			__((	long		*msg,
					double		inertiaMatrix_3x3[6],
					double		Jxyz[3],
					IGRvector	principalAxes[3] )) ;

#endif
