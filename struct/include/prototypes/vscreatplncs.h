/*
	I/STRUCT
*/

#ifndef vscreatplncs_include
#	define vscreatplncs_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef igr_include
#	include "igr.h"
#endif

/*+f
Function VScreatePlaneCS

Abstract
	Given a plane, evaluates a coordinate system such that the normal
	to the plane is the z-axis and returns the transformation matrices
	from the world CS to this plane CS and its inverse.
Arguments
	IN	struct IGRplane	*plane		Input plane.
	OUT	IGRmatrix	l2w		Matrix local plane -> world.
	OUT	IGRmatrix	w2l		Matrix world -> local plane.
Keywords
	#coordinate system#matrix#plane#
-f*/
extern void
VScreatePlaneCS		__((	struct IGRplane		*plane,
				IGRmatrix		l2w,
				IGRmatrix		w2l )) ;

#endif
