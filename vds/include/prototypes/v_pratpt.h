/*
	I/VDS	Copy
*/

#ifndef v_pratpt_include
#	define v_pratpt_include

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
VD_ptatpr		__((	long		*msg,
				struct GRmd_env	*env,
				OM_S_OBJID	cv,
				double		pm,
				IGRpoint	pt )) ;

extern long
VD_pratpt		__((	long		*msg,
				struct GRmd_env	*env,
				OM_S_OBJID	cv,
				IGRpoint	pt,
				double		*pm )) ;

#endif
