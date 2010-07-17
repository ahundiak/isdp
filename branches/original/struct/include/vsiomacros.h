/*
 * I/STRUCT
 * Macros to convert units to system values and conversely, output messages,
 * etc.
 */
#ifndef vsiomacros_include
#	define vsiomacros_include

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
Macro vs$system_to_unit

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

	vs$system_to_unit(	msg	= &msg,
				value	= 1.3451,
				type	= GRIO_ANGLE,
				osnum	= md_env.md_id.osnum,
				p_unit	= &unit ) ;

	...

-M*/
extern int
VSsys2unit		__((	long			*msg,
				OMuword			mod_os,
				double			value,
				char			*table,
				char			**unit )) ;

#omdef vs$system_to_unit(	msg,
				value,
				type	= GRIO_DISTANCE,
				osnum	= OM_K_NOT_AN_OS,
				p_unit )
	VSsys2unit( (msg), (osnum), (value), (type), (p_unit) )
#endomdef

/*+M
Macro vs$SPECIALsystem_to_unit

Abstract
	Converts an internal value to a united value for units which are
	those of the moment of inertia, volumetric mass, etc.
Arguments
	OUT	long	*msg		Completion code.
	IN	double	value		Internal value to convert.
	IN	char	type		Type of unit as defined in vemeasdef.h.
	IN	OMuword osnum		Module object space in which conversion
					is desired (optional).
	OUT	char	**p_unit	Pointer to string containing unit.
Note
	`*unit' points to static memory, hence is volatile and must be used
	immediately.
-M*/
extern int
VSspecialSys2unit	__((	long			*msg,
				OMuword			mod_os,
				double			value,
				char			*table,
				char			**unit )) ;

#omdef vs$SPECIALsystem_to_unit(	msg,
					value,
					type,
					osnum	= OM_K_NOT_AN_OS,
					p_unit )
	VSspecialSys2unit( (msg), (osnum), (value), (type), (p_unit) )
#endomdef

/*+M
Macro vs$unit_to_system

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

	vs$unit_to_system(	msg	= &msg,
				unit	= "12 ft",
				type	= GRIO_DISTANCE,
				p_value = &result ) ;

	...


-M*/
extern int
VSunit2sys		__((	long			*msg,
				char			*table,
				char			*unit,
				double			*p_value )) ;

#omdef vs$unit_to_system(	msg,
				unit,
				type	= GRIO_DISTANCE,
				p_value )
	VSunit2sys( (msg), (unit), (type), (p_value) )
#endomdef

/*+M
Macro vs$dotsInStsFld

Abstract
	Puts "Processing ..." to the status field or clears it, depending on
	the value of argument `dots':
		dots = clear	: clears status field.
		dots = increment: takes the previous count of dots and increment
				  it.
		dots = n >= 0	: prints "Processing" with n dots.
Arguments
	IN	int	dots
	IN	long	msgnum	The number of the message to be displayed
	                        (optional).
-M*/
extern long
VSdotsInStatusField		__(( int	dots,
				     long	msg )) ;

#omdef vs$dotsInStsFld( dots = increment, msgnum = MS_NO_MSG )
#	if	om$equal( dots, clear )
		VSdotsInStatusField( -1, (msgnum) )
#	elif	om$equal( dots, increment )
		VSdotsInStatusField( -2, (msgnum) )
#	elif	dots >= -2
		VSdotsInStatusField( (dots), (msgnum) )
#	else
#	omerror "vs$dotsInStsFld: `dots' must be `clear', `increment', or >= 0."
#endif
#endomdef

/*+M
Macro vs$get_default_unit

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

	vs$get_default_unit(	msg	= &msg,
				type	= GRIO_ANGLE,
				osnum	= md_env.md_id.osnum,
				p_unit	= &unit ) ;

	...

-M*/
extern int
VSgetDefaultUnit	__((	long			*msg,
				OMuword 		mod_os,
				char			*table,
				char			**unit )) ;

#omdef	vs$get_default_unit(	msg,
				type	= GRIO_DISTANCE,
				osnum,
				p_unit )
	VSgetDefaultUnit( (msg), (osnum), (type), (p_unit) )
#endomdef

#endif /* vsiomacros_include */
