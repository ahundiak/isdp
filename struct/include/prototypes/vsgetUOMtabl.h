/*
	I/STRUCT
*/

#ifndef vsgetUOMtabl_include
#	define vsgetUOMtabl_include

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
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif
#ifndef griodef_include
#	include "griodef.h"
#endif
#ifndef grio_include
#	include "grio.h"
#endif
#ifndef UOMdef_include
#	include "UOMdef.h"
#endif
#ifndef UOM_include
#	include "UOM.h"
#endif

extern long
VSgetUOMtable			__((	OMuword		osnum,
					const char	*UOMtableName,
					UOM_TYPE	**UOMtable )) ;

#endif
