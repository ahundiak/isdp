/*
	I/VDS	Copy
*/

#ifndef v_expvalue_include
#	define v_expvalue_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif

extern long
VD_expValue			__((	OM_S_OBJID	exp_id,
					OMuword		exp_os,
					double		*p_value )) ;

extern long
VD_createExp			__((	char		*name,
					double		value,
					OMuword		osnum,
					OM_S_OBJID	*p_objid )) ;

extern long
VD_createTextExp		__((	char		*name,
					char		*value,
					OMuword		osnum,
					OM_S_OBJID	*p_objid )) ;

#endif
