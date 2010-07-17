/*
	I/STRUCT
*/

#ifndef vsnameproto_include
#	define vsnameproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif

extern void
VSgenCmpName			__((	int	cmpIndex,
					char	*name )) ;

extern int
VSreadGenericName		__((	char	*name,
					int	*p_index )) ;

extern int
VSreadGenericNameAcceptNegative	__((	char	*name,
					int	*p_index )) ;

extern long
VSbuildName			__((	long	*msg,
					char	*directory,
					char	*pattern,
					char	*name )) ;

extern void
VSbuildNameInSameDirIfPossible	__((	OMuword	actModOs,
					OMuword	templateOS,
					char	*templateName,
					char	*cwd,
					char	*newName )) ;

#endif
