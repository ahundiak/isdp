/*
	I/STRUCT
*/
#ifndef vsaddmodattr_include
#	define vsaddmodattr_include

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
VSaddOrModAttr	__((	long			*msg,
			const struct GRid	*coll,
			const char		*name,
			int			type,
			const void		*value )) ;
#endif
