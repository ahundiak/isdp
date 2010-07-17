/*
	I/STRUCT
*/

#ifndef vsplencompbx_include
#	define vsplencompbx_include

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
VSmakePlaneEncompassingBox	__((	long			*msg,
					struct GRobj_env 	*inPlane,
					struct GRvg_construct	*cst,
					GRrange			box,
					struct GRid		*outPlane )) ;

#endif
