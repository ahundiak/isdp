/*
 * I/VDS	Copy.
 *
 * Macros to convert units to system values and conversely, output messages,
 * etc.
 */
#ifndef v_iomacros_include
#	define v_iomacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif
#ifndef griodef_include
#	include "griodef.h"
#endif
#ifndef msdef_include
#	include "msdef.h"
#endif

/*+M
Macro vd_$system_to_unit

Abstract
	Converts an internal value to a united value.
Arguments
	OUT	long	*msg		Completion code.
	IN	double	value		Internal value to convert.
	IN	char	type		Type of unit [GRIO_ANGLE, GRIO_DISTANCE,
					etc. defined in griodef.h].
	IN	OMuword osnum		Module object space in which conversion
					is desired (optional).
	OUT	char	**p_unit	Pointer to string containing unit.
Note
	`*unit' points to static memory, hence is volatile and must used
	immediately.

Sample usage
	char	*unit ;
	long	msg ;

	vd_$system_to_unit(	msg	= &msg,
				value	= 1.3451,
				type	= GRIO_ANGLE,
				osnum	= md_env.md_id.osnum,
				p_unit	= &unit ) ;

	...

-M*/
extern int
VD_sys2unit		__((	long			*msg,
				OMuword			mod_os,
				double			value,
				char			*table,
				char			**unit )) ;

#omdef vd_$system_to_unit(	msg,
				value,
				type	= GRIO_DISTANCE,
				osnum	= OM_K_NOT_AN_OS,
				p_unit )
	VD_sys2unit( (msg), (osnum), (value), (type), (p_unit) )
#endomdef

/*+M
Macro vd_$unit_to_system

Abstract
	Converts a united value to an internal value.
Arguments
	OUT	long	*msg		Completion code
	IN	char	type		Type of unit [GRIO_ANGLE, GRIO_DISTANCE,
					etc. defined in griodef.h].
	IN	char	*unit		String containing unit to convert.
	OUT	double	*p_value	Internal value,

Sample usage
	double	*result ;
	long	msg ;

	vd_$unit_to_system(	msg	= &msg,
				unit	= "12 ft",
				type	= GRIO_DISTANCE,
				p_value = &result ) ;

	...


-M*/
extern int
VD_unit2sys		__((	long			*msg,
				char			*table,
				char			*unit,
				double			*p_value )) ;

#omdef vd_$unit_to_system(	msg,
				unit,
				type	= GRIO_DISTANCE,
				p_value )
	VD_unit2sys( (msg), (unit), (type), (p_value) )
#endomdef

/*+M
Macro vd_$get_default_unit

Abstract
	Returns the default unit with respect to UOM table.

Arguments
	OUT	long	*msg		Completion code.
	IN	char	type		Type of unit [GRIO_ANGLE, GRIO_DISTANCE,
					etc. defined in griodef.h].
	IN	OMuword osnum		Module object space in which unit
					is desired.
	OUT	char	**p_unit	Pointer to string containing unit.

Note
	`*p_unit' points to static memory, hence is volatile and must used
	immediately.

Sample usage
	char	*unit ;
	long	msg ;

	vd_$get_default_unit(	msg	= &msg,
				type	= GRIO_ANGLE,
				osnum	= md_env.md_id.osnum,
				p_unit	= &unit ) ;

	...

-M*/
extern int
VD_getDefaultUnit	__((	long			*msg,
				OMuword 		mod_os,
				char			*table,
				char			**unit )) ;

#omdef	vd_$get_default_unit(	msg,
				type	= GRIO_DISTANCE,
				osnum,
				p_unit )
	VD_getDefaultUnit( (msg), (osnum), (type), (p_unit) )
#endomdef

#endif /* v_iomacros_include */
