/*
	I/STRUCT
*/

#ifndef vsexpvalue_include
#	define vsexpvalue_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif

extern long
VSexpValue			__((	OM_S_OBJID	exp_id,
					OMuword		exp_os,
					double		*p_value )) ;


extern long
VStxtExpValue			__((	OM_S_OBJID	exp_id,
					OMuword		exp_os,
					char		*p_value )) ;

extern long
VScreateExp			__((	char		*name,
					double		value,
					OMuword		osnum,
					OM_S_OBJID	*p_objid )) ;

extern long
VScreateTextExp			__((	char		*name,
					char		*value,
					OMuword		osnum,
					OM_S_OBJID	*p_objid )) ;

#endif
