/*
	I/STRUCT
*/

#ifndef vsconstrctcs_include
#	define vsconstrctcs_include

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
Function VSconstructCS

Abstract
	Given a matrix and a construction list, constructs the coordinate system
	described by the matrix.
Arguments
	OUT	long			*msg	Completion code.
	IN	IGRmatrix		matrix	Matrix of the coord. sys.
	IN	struct GRvg_construct	cst	Construction list.
	OUT	struct GRid		*CSid	Id of the constructed c. s.
Keywords
	#coordinate system#construct#
-f*/
extern long
VSconstructCS			__((	long			*msg,
					IGRmatrix		matrix,
					struct GRvg_construct	*cst,
					struct GRid		*CSid )) ;

#endif
