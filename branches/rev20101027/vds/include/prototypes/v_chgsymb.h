/*
	I/VDS	Copy
*/

#ifndef v_chgsymb_include
#	define v_chgsymb_include

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
VD_changeSymbology	__((	long			*msg,
				struct GRid		*graphic,
				short			newLevel,
				struct IGRdisplay	*newDisplay )) ;

extern long
VD_chgSymbAndProps	__((	long			*msg,
				struct GRid		*graphic,
				short			newLevel,
				struct IGRdisplay	*newDisplay,
				short			newProps )) ;

#endif
