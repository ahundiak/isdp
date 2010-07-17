/*
	I/STRUCT
*/

#ifndef vsgdplcgpdtc_include
#	define vsgdplcgpdtc_include

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

extern int
VSplaceGapDetector	__((	const struct GRid		*bmId,
				const struct GRmd_env		*bmEnv,
				double				maxAdmGap,
				struct GRvg_construct		*cst,
				struct GRid			*gdId )) ;


#endif
