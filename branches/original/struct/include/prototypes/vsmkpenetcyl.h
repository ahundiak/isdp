/*
	I/STRUCT
*/

#ifndef vsmkpenetcyl_include
#	define vsmkpenetcyl_include

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
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif

extern long
VSmakePenetratingCyl		__((	long			*msg,
					struct GRid		*objId,
					struct GRmd_env		*objEnv,
					struct GRid		*cvId,
					struct GRmd_env		*cvEnv,
					struct GRvg_construct	*cst,
					struct GRid		*cylinder,
					GRrange                  solidRange )) ;

#endif
