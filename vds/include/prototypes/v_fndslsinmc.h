/*
	I/VDS	Copy.
*/

#ifndef v_fndslsinmc_include
#	define v_fndslsinmc_include

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
VD_findSolidsSurfacesInMacro
			__((	long			*msg,
				struct GRid		*macId,
				struct GRmd_env		*macEnv,
				struct GRobj_env	**listOfSolSfs,
				int			*countOfSolSfs )) ;

#endif
