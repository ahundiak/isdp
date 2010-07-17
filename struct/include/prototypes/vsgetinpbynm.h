/*
	I/STRUCT
*/

#ifndef vsgetinpbynm_include
#	define vsgetinpbynm_include

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
Function VSgetInputByName

Abstract
	Given an associative complex (object derived from ACcpx), finds
	the id of one of its inputs (parents) given its name.
Arguments
	OUT	long*		   msg		Completion code.
	IN	const struct GRid  *target	Object whose input is wanted.
	IN	const char	   *nameOfInput	Name of desired input.
	OUT	struct GRid	   *idOfInput	Id of input.
	OUT	struct GRmd_env	   *envOfInput 	Module env. of input
						(optional: NULL if not wanted)
Keywords
	#input#parent#complex#assoc#
Note
	The matrix in `envOfInput' is that of the input with respect
	to `target'.
-f*/
extern long
VSgetInputByName	__((	long*			msg,
				const struct GRid*	target,
				const char*		nameOfInput,
				struct GRid*		idOfInput,
				struct GRmd_env*	envOfInput )) ;

#endif
