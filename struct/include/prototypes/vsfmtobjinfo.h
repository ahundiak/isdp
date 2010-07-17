/*
	I/STRUCT
*/

#ifndef vsfmtobjinfo_include
#	define vsfmtobjinfo_include

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
VSformatObjInfo			__((	long			*msg,
					OMuword			osnum,
					OM_S_OBJID		objid,
					long			objtype,
					struct GRobj_info 	*info  )) ;

extern long
VSformatCpxInfo			__((	long			*msg,
					OMuword			osnum,
					OM_S_OBJID		objid,
					long			objtype,
					struct GRobj_info 	*info  )) ;

#endif
