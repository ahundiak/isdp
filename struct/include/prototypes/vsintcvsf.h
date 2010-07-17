/*
	I/STRUCT
*/

#ifndef vsintcvsf_include
#	define vsintcvsf_include

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

/*+f
Function VSintersectCurveAndSurface

Abstract
	Intersects a curve and a surface in search on an intersection point.
Arguments
	OUT	long		*msg	    Completion code.
	IN	struct GRid	*curveId    Input curve.
	IN	struct GRmd_env	*curveEnv   Mod. env. of curve.
	IN	struct GRid	*surfId	    Input surface.
	IN	struct GRmd_env	*surfEnv    Mod. env. of surface.
	IN	int		infIfPlanar Consider surface as infinite
					    if it is planar.
	OUT	IGRpoint	pntInt	    First intersection point.
	OUT	double		*pmInt	    Param. of int. point on curve.
Keywords
	#curve#intersection#point#surface#
Note
	`pntInt' is the first intersection point with respect to the 
	curve orientation and `pmInt' the paramater value of this point on 
	the curve.
	If no intersection point is found, `*msg' is set to `EMS_W_NoSolution'.
-f*/

extern long
VSintersectCurveAndSurface	__((	long		*msg,
					struct GRid	*curveId,
					struct GRmd_env	*curveEnv,
					struct GRid	*surfId,
					struct GRmd_env	*surfEnv,
					int		infIfPlanar,
					IGRpoint	pntInt,
					double		*pmInt )) ;

#endif
