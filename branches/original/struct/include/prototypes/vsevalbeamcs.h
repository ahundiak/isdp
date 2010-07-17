/*
	I/STRUCT
*/

#ifndef vsevalbeamcs_include
#	define vsevalbeamcs_include

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
#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

extern long
VSevalBeamCS			__((	long			*msg,
					struct GRobj_env	*beam,
					int			endno,
					enum VScardinal_point	cardPt,
					IGRmatrix		CS )) ;

#endif
