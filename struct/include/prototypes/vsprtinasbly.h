/*
	I/STRUCT
*/

#ifndef vsprtinasbly_include
#	define vsprtinasbly_include

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
VSisPartInAssembly		__((	long		*msg,
					struct GRid	*part )) ;

#endif
