/*
	I/STRUCT
*/

#ifndef vsgetmacinfo_include
#	define vsgetmacinfo_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef _UNISTD_H
#	include <unistd.h>
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
#ifndef MACRODEF
#	include "macro.h"
#endif

#ifdef X11
#include "standards.h"
#define NAME_MAX 14
#endif

/*+f
Function VSgetMacroInformation

Abstract
	Gathers information about a macro definition given its name or id.
Arguments
	OUT long	      *msg		  Completion code.
	IN  const char        *mcDfNm		  Name of macro definition.
	IN  const struct GRid *mcDefId		  Id of macro definition.
	OUT char              mcLibNm[1+NAME_MAX] Library of definition.
	OUT int		      *nbInputs		  Number of inputs of macro.
	OUT struct stemp      **InputInfo	  Info about the inputs.
	OUT int		      *nbOutputs	  Number of outputs of macro.
	OUT struct myfeet     **OutputInfo	  Info about the outputs.
	OUT struct GRid	      *optObj		  Collection of macro options.
Keywords
	#macro#definition#
Notes
	Either `mcDfNm' or `mcDefId' can be specified.
	`mcLibNm' may be NULL if not needed.
	Either `nbInputs' or `InputInfo' may be NULL if not needed.
	Either `nbOutputs' or `OutputInfo' may be NULL if not needed.
	`optObj' may be NULL if not needed.
-f*/
extern long
VSgetMacroInformation		__((	long		  *msg,
					const char	  *mcDfNm,
					const struct GRid *mcDefId,
					char		  mcLibNm[1+NAME_MAX],
					int		  *nbInputs,
					struct stemp	  **InputInfo,
					int		  *nbOutputs,
					struct myfeet	  **OutputInfo,
					struct GRid	  *optObj )) ;

#endif
