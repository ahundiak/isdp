/*
	I/STRUCT
*/

#ifndef vsgetaxofstf_include
#	define vsgetaxofstf_include

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
Function VSgetBeamAxisOfStiffener

Abstract
	Returns the beam axis of a stiffener (of class VSbeamAxis).
Arguments
	OUT	long			*msg		Completion code.
	IN	const struct GRid	*stiffener	Target stiffener.
	OUT	struct GRid		*beamAxis	Axis of stiffener.
Keywords
	#axis#beam#stiffener#
-f*/
extern long
VSgetBeamAxisOfStiffener	__((	long			*msg,
					const struct GRid	*stiffener,
					struct GRid		*beamAxis )) ;

#endif
