/*
 * I/STRUCT
 * Macros to retrieve the default construction parameters (level, display,
 * representation, directory, etc.), manupulate form fields with units, etc.
 */

#ifndef vscmdmacros_include
#	define vscmdmacros_include

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
#ifndef igr_include
#	include "igr.h"
#endif
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef griodef_include
#	include "griodef.h"
#endif

/*+M
Macro vs$cnstDefaults

Abstract
	Returns the default construction parameters ( level, display,
	representation, directory, etc. ).
Arguments
	OUT	long			*msg		MSSUCC, MSFAIL
	IN	struct GRid		symb_id		The entry for osnum will
							define the object space
							for the symbology.
	IN	char			*matchKey	Key used to deduce
							symbology and directory
							to put element in.
	IN	struct GRid		*matchId	Id used to deduce
							symbology and directory
							to put element in.
	OUT	char			*path		Pathname for new
							element.
	OUT	struct VDSsymb		*symb		active VDS symbology.
	OUT	short  			*level		Level for new element.
	OUT     struct IGRdisplay	*display	Display for new element.
-M*/
extern long
VScnstDefaults			__((	long			*msg,
					struct GRid		symb_id,
					char			*matchKey,
					struct GRid		*matchId,
					char			*path,
					struct VDSsymb		*symb,
					short  			*level,
					struct IGRdisplay	*display )) ;

#omdef	vs$cnstDefaults(	   msg, 
				   symb_id,
				   matchKey	= NULL,
				   matchId	= NULL,
				   path		= NULL,
				   symb, 
				   level, 
				   display ) 
	VScnstDefaults		( (msg), 
				  (symb_id),
				  (matchKey),
				  (matchId),
				  (path), 
				  (symb), 
				  (level), 
				  (display) ) 
#endomdef

extern long
VSgetBmOrPlCstDefaults		__((	long			*msg,
					struct GRid		symb_id,
					int			memberClass,
					char			*matchKey,
					struct GRid		*matchId,
					char			*path,
					struct VDSsymb		*symb,
					short  			*level,
					struct IGRdisplay	*display )) ;
					
#omdef	vs$getBmOrPlCstDefaults(   msg, 
				   symb_id,
				   memberClass,
				   matchKey	= NULL,
				   matchId	= NULL,
				   path		= NULL,
				   symb, 
				   level, 
				   display ) 
	VSgetBmOrPlCstDefaults	( (msg), 
				  (symb_id),
				  (memberClass),
				  (matchKey),
				  (matchId),
				  (path), 
				  (symb), 
				  (level), 
				  (display) ) 

#endomdef

/*+M
Macro vs$processUnitField

Abstract
	Reads an ASCII form field supposed to contain a value with a unit,
	( eg. "12 inches" ), then converts it to system units, if the input
	value is not valid, resets the field to its previous value.
Arguments
	OUT	long	*msg		Completion code (is even if input value
					was invalid and old value has been set
					back).
	IN	char	*form		Form pointer.
	IN	int	field		Gadget label of field.
	IN	int	row		Field row.
	IN	int	column		Field column.
	IN	OMuword	osnum		Object Space number for unit table.
	IN	char	*type		Type of unit table.
	IN	int	(*verify)()	Verify function.
	IN	char	*args		Arguments to verify function.
	IN	double	oldValue	Previous value of field (system units).
	OUT	double	*newValue	New value of field (system units).
Note
	If `osnum' is not specified the active design file Object Space number
	will be used.
	If `verify' is not NULL, it must be declared as :

			int verify( d, args )
			double	d ;
			char	*args ;

	and will be invoked as

			verify( *newValue, args )

	It must return TRUE if the value is acceptable else FALSE, in this
	latter case, the field will be set back to its previous value.

	If `oldValue' is not specified it will be taken as "0.".
-M*/
extern long
VSprocessUnitField	__((	long	*msg,
				char	*form,
				int	field,
				int	row,
				int	col,
				OMuword	osnum,
				char	*type,
				int	(*verify)__(( double d, char *args )),
				char	*args,
				double	oldValue,
				double	*newValue )) ;

#omdef vs$processUnitField(	msg,
				form,
				field,
				row		= 0,
				column		= 0,
				osnum		= OM_K_NOT_AN_OS,
				type		= GRIO_DISTANCE,
				verify		= NULL,
				args		= NULL,
				oldValue	= 0.,
				newValue )

	VSprocessUnitField(	(msg),
				(form),
				(field),
				(row),
				(column),
				(osnum),
				(type),
				(verify),
				(char *) (args),
				(oldValue),
				(newValue) )
#endomdef

/*+M
Macro vs$fillUnitField

Abstract
	Fills an ASCII field with a unit value.
Arguments
	OUT	long	*msg		Completion code.
	IN	char	*form		Form pointer.
	IN	int	field		Gadget label of field.
	IN	int	row		Field row.
	IN	int	column		Field column.
	IN	OMuword	osnum		Object Space number for unit table.
	IN	char	*type		Type of unit table.
	IN	double	value		Value of field (system units).
-M*/
extern long
VSfillUnitField			__((	long	*msg,
					char	*form,
					int	field,
					int	row,
					int	col,
					OMuword	osnum,
					char	*type,
					double	value )) ;

#omdef	vs$fillUnitField(	msg,
				form,
				field,
				row	= 0,
				column	= 0,
				osnum	= OM_K_NOT_AN_OS,
				type	= GRIO_DISTANCE,
				value	= 0. )

	VSfillUnitField( (msg), (form), (field), (row), (column),
			 (osnum), (type), (value) )
#endomdef

#endif /* vscmdmacros_include */

