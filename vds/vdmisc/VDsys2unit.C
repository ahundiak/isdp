/*
	I/VDS	Copy

	VD_sys2unit
	----------
Abstract
	Converts a system value to a united value.

Arguments
	OUT	long	*msg	completion code
	IN	OMuword	mod_os	object space of UOM table
	IN	double	value	system value to convert
	IN	char	*table	UOM table
	OUT	char	**unit	pointer to unit (static buffer)
Note
	*unit must *NOT* be freed by the caller.
 */
#include <string.h> 
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "msdef.h"		/* For MS...		*/
#include "UOMdef.h"
#include "griodef.h"
#include "griomacros.h"
#include "v_miscmacros.h"

static char	VD_Gs_UnitBuffer[UOM_K_MAX_LEN] ;
char		*VD_Gp_UnitBuffer = VD_Gs_UnitBuffer ;
/*----------------------------------------------------------------------------*/
int VD_sys2unit( msg, mod_os, value, table, unit )

long	*msg	;	/* OUT : completion code		*/
OMuword	mod_os	;	/* IN  : object space of UOM table	*/
double	value	;	/* IN  : system value to convert	*/
char	*table	;	/* IN  : UOM table			*/
char	**unit	; {	/* OUT : pointer to unit (static buffer)*/

	char	Unit[UOM_K_MAX_LEN] ;	/* Buffer for converted value	*/
	short	num_alias	= 3 ;
	int	field_size	= UOM_K_MAX_LEN ;

	if( OM_K_NOT_AN_OS == mod_os ) ex$get_cur_mod( osnum = &mod_os ) ;

	*unit = NULL ;
	co$cvt_imp_to_alias(	msg		= msg,
				working_units	= &value,
				unit_type	= table,
				num_conversions	= 1,
				osnum		= mod_os,
				field_size	= &field_size,
				num_alias	= &num_alias,
				cvt_list	= Unit ) ;

	if( *msg & 1 ) {
		*unit = strcpy( VD_Gp_UnitBuffer, Unit ) ;
	}
	return *msg & 1 ;
	
} /* VD_sys2unit */
/*----------------------------------------------------------------------------*/

