/*
	I/STRUCT
*/

#ifndef vschgsymb_include
#	define vschgsymb_include

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

extern long
VSchangeSymbology	__((	long			*msg,
				struct GRid		*graphic,
				short			newLevel,
				struct IGRdisplay	*newDisplay )) ;

extern long
VSchgSymbAndProps	__((	long			*msg,
				struct GRid		*graphic,
				short			newLevel,
				struct IGRdisplay	*newDisplay,
				short			newProps )) ;

#endif
