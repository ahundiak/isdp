/*
	I/STRUCT
*/

#ifndef vsedgeproto_include
#	define vsedgeproto_include

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
#ifndef igr_include
#	include "igr.h"
#endif



extern long
VSgetBevelCurves		__((	struct GRid	edgeId,
					struct GRmd_env	edgeEnv,
					struct GRid	*baseGraphicId,
					struct GRid	*offsetGraphicId )) ;


#endif /* vsedgeproto_include */

