/*
	I/STRUCT
*/

#ifndef vsdelbndries_include
#	define vsdelbndries_include

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
Function VSdelete_boundaries_if_any

Abstract
	Given a surface, if its has boundaries, copies it and return the copy
	with its boundaries removed; it it has no boundaries, does nothing
	and returns the input surface as the copy.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*sfEnv		Environment of input surface.
	IN	struct GRid	*sfId		Id of input surface.
	IN	struct GRmd_env	*cpyEnv		Environment for copy.
	OUT	struct GRid	*cpyId		Copy without boundaries.
	OUT	int		*hadBdry	TRUE if the input surface had
						boundaries else FALSE.
Keywords
	#boundary#delete#surface#
Note
	We have "*hadBdry == FALSE  <=> *sfId == *cpyId".
-f*/
extern long
VSdelete_boundaries_if_any	__((	long		*msg,
					struct GRmd_env *sfEnv,
					struct GRid	*sfId,
					struct GRmd_env	*cpyEnv,
					struct GRid	*cpyId,
					int		*hadBdry )) ;

/*+f
Function VSdelete_inside_bdrs_if_any

Abstract
	Given a surface, if its has *inside* boundaries, copies it and return
	the copy with its *inside* boundaries removed; it it has no *inside*
	boundaries, does nothing and returns the input surface as the copy.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*sfEnv		Environment of input surface.
	IN	struct GRid	*sfId		Id of input surface.
	IN	struct GRmd_env	*cpyEnv		Environment for copy.
	OUT	struct GRid	*cpyId		Copy without inside boundaries.
	OUT	int		*hadBdry	TRUE if the input surface had
						*inside* boundaries else FALSE.
Keywords
	#boundary#delete#surface#
Note
	We have "*hadBdry == FALSE  <=> *sfId == *cpyId".
-f*/
extern long
VSdelete_inside_bdrs_if_any	__((	long		*msg,
					struct GRmd_env *sfEnv,
					struct GRid	*sfId,
					struct GRmd_env	*cpyEnv,
					struct GRid	*cpyId,
					int		*hadBdry )) ;

#endif
