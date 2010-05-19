/*
	I/VDS	Copy.

	VD_getDefaultUnit
	----------------
Abstract
	Returns default unit with respect to UOM table.

Arguments
	OUT	long	*msg	completion code
	IN	OMuword mod_os	object space of UOM table
	IN	char	*table	UOM table
	OUT	char	**unit	pointer to unit (static buffer)

Note
	`*unit' point to static memory, hence is volatile and must used
	immediately and *NOT* freed.
*/
#include <string.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "UOMdef.h"
#include "griodef.h"
#include "griomacros.h"
#include "msdef.h"
#include "v_miscmacros.h"

extern char	*VD_Gp_UnitBuffer ;
/*----------------------------------------------------------------------------*/
int VD_getDefaultUnit( msg, mod_os, table, unit )

long	*msg	;	/* OUT : completion code		*/
OMuword mod_os	;	/* IN  : object space of UOM table	*/
char	*table	;	/* IN  : UOM table			*/
char	**unit	; {	/* OUT : pointer to unit (static buffer)*/

	char	Unit[UOM_K_MAX_LEN] ;
	short	num_defaults = 1,
		flag	     = 0 ;

	*unit = NULL ;

	co$get_default_units( msg		= msg,
			      table_name	= table,
			      osnum		= mod_os,
			      flag		= &flag,
			      num_defaults	= &num_defaults,
			      default_units	= Unit ) ;

	if( *msg & 1 ) {
		*unit = strcpy( VD_Gp_UnitBuffer, Unit ) ;
	}
	return *msg & 1 ;

} /* VD_getDefaultUnit */
/*----------------------------------------------------------------------------*/
