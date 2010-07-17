/*
	I/STRUCT
*/

#ifndef vsbldrootcpx_include
#	define vsbldrootcpx_include

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
VSbuildRootComplex		__((	long		*msg,
					char		*nameOfRootCpx,
					int		countOfComponents,
					struct GRid	*idsOfComponents,
					char		**namesOfComponents,
					struct GRmd_env	*envOfRootCpx,
					OMuword		osOfOfRootCpx,
					OM_S_OBJID	*p_idOfOfRootCp )) ;

#endif
