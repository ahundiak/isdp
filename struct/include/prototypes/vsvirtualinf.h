/*
	I/STRUCT
*/

#ifndef vsvirtualinf_include
#	define vsvirtualinf_include

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
VSgetVirtualInfo	__((	long			*msg,
				const struct GRid	*object,
				struct GRmd_env		*p_md_env,
				struct GRid		*p_virtual )) ;

#endif
