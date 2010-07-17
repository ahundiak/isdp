/*
	I/STRUCT
*/

#ifndef vsrangebxint_include
#	define vsrangebxint_include

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
VSfindRngBoxInters		__((	long			*msg,
					int			card1,
					struct GRobj_env	*set1,
					int			card2,
					struct GRobj_env	*set2,
					int			wantStatus,
					char			*mapping )) ;

#endif
