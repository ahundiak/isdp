/*
	I/STRUCT
*/

#ifndef vspjcvinfpln_include
#	define vspjcvinfpln_include

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
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif

extern long
VSprjCvOntoInfPlane		__((	long			*msg,
					struct GRid		*cvId,
					struct GRmd_env		*cvEnv,
					struct IGRplane		*infPlane,
					IGRvector		vector,
					struct GRvg_construct	*cst,
					struct GRid		*prjCv )) ;

#endif
