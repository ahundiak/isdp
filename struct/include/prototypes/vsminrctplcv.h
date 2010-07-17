/*
	I/STRUCT
*/

#ifndef vsminrctplcv_include
#	define vsminrctplcv_include

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
Function VSminRectOfPlanarCv

Abstract
	Evaluates the minimum rectangle of a closed planar curve.
Arguments
	OUT long		  *msg		Completion code.
	IN  const struct GRid	  *cvId		Id of curve.
	IN  const struct GRmd_env *cvEnv	Module environment of curve.
	OUT IGRpoint		  A		1st point of rectangle.
	OUT IGRpoint		  B		2nd point of rectangle.
	OUT IGRpoint		  C		3rd point of rectangle.
	OUT IGRpoint		  D		4th point of rectangle.
	OUT double		  *width	Width of rectangle.
	OUT height		  *height	Height of rectangle.
Keywords
	#closed#curve#minimum#planar#rectangle#
Note
	*width  = distance( A, C )
	*height = distance( B, C )
-f*/
extern long
VSminRectOfPlanarCv	__((	long			*msg,
				const struct GRid	*cvId,
				const struct GRmd_env	*cvEnv,
				IGRpoint		A,
				IGRpoint		B,
				IGRpoint		C,
				IGRpoint		D,
				double			*width,
				double			*height )) ;
#endif

