/*
	I/STRUCT
*/

#ifndef vselmsonsupp_include
#	define vselmsonsupp_include

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
VSgetElementsOnSupport		__((	long		*msg,
					struct GRid	*support,
					unsigned long	STRUCTtype,
					int		wantVisibleOnes,
					int		*count,
					struct GRid	**list )) ;

#endif
