/*
	I/STRUCT
*/

#ifndef vsmkinfline_include
#	define vsmkinfline_include

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

/*+f
Function VSmake_infinite_line

Abstract
	Constructs an infinite line passing by two given points.
Arguments
	OUT  long		   *msg		Completion code.
	IN   const IGRpoint 	   point1	First point.
	IN   const IGRpoint 	   point2	Second point.
	IN   struct GRvg_construct *cst		Construction list.
	OUT  struct GRid	   *infLineId	Infinite line.
Keywords
	#infinite#line#
-f*/
extern int
VSmake_infinite_line		__((	long			*msg,
					const IGRpoint		point1,
					const IGRpoint		point2,
					struct GRvg_construct	*cst,
					struct GRid		*infLineId )) ;

#endif
