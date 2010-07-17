/*
	I/STRUCT
*/

#ifndef vsupdreffdep_include
#	define vsupdreffdep_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif

extern long
VScheckRefFilesDependency	__((	long 	*msg,
					int	updateFlag,
					int	*nbModRef,
					OMuword	ModRefList[] )) ;

#endif
