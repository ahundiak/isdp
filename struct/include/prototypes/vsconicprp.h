/*
	I/STRUCT
*/

#ifndef vsconicprp_include
#	define vsconicprp_include

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

extern void
VSconicprp	__((	struct IGRbsp_curve	*curve,
			int			*type,
			double			*r1_r,
			double			*r2,
			IGRpoint		center,
			IGRpoint		f1_f,
			IGRpoint		f2,
			IGRpoint		v1,
			IGRpoint		v2,
			IGRpoint		v3_t1,
			IGRpoint		v4_t2,
			BSrc			*rc )) ;

#endif
