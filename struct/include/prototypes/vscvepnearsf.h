/*
	I/STRUCT
*/

#ifndef vscvepnearsf_include
#	define vscvepnearsf_include

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

/*+f
Function VSfindCvEndPtNearestToSf

Abstract
	Given a curve and a surface, finds the end point of the curve closest
	to the surface.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRobj_env *curve		Input curve.
	IN	struct GRobj_env *surface	Input surface.
	IN	int		 infIfPlanar	Specifies that if surface is
						planar it must be considered as
						infinite (TRUE/FALSE).
	OUT	IGRpoint	 endPoint	Nearest end point.
	OUT	double		 *endPm		Parameter of end point.
Keywords
	#curve#end point#near#surface#
-f*/

extern long
VSfindCvEndPtNearestToSf	__((	long			*msg,
					struct GRobj_env	*curve,
					struct GRobj_env	*surface,
					int			infIfPlanar,
					IGRpoint		endPoint,
					double			*endPm )) ;

#endif
