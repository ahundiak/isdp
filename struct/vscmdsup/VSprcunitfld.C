/*
	I/STRUCT
*/
#include <stdio.h>
#include <standards.h>
#include <FI.h>
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "vsdpb.h"
#include "vscmd.h"
#include "VDSsymb_def.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vscmdmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
#include "VX_FIproto.h"
#include "vsformproto.h"
#include "vsioproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSisDblPositive( d, args ) double d ; char *args ; {

	return d >= 0. ;

} /* VSisDblPositive */
/*----------------------------------------------------------------------------*/
int VSisDblGreaterThan( d, toBeGreaterThan )

double	d ;
char	*toBeGreaterThan ; {	/* Actually a double *	*/

	return d > * ( (double *) toBeGreaterThan ) ;

} /* VSisDblGreaterThan */
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) short: here
   osnum causes it to choke...
 */
long VSprocessUnitField(	long	*msg,
				char	*form,
				int	field,
				int	row,
				int	col,
				OMuword	osnum,
				char	*type,
				int	(*verify)__(( double d, char *args )),
				char	*args,
				double	oldValue,
				double	*newValue )
#else
long VSprocessUnitField( msg, form, field, osnum, type, verify, args, oldValue,
			 newValue )

long	*msg ;
char	*form ;
int	field ;
OMuword	osnum ;
char	*type ;
int	(*verify)__(( double d, char *args )) ;
char	*args ;
double	oldValue,
	*newValue ;
#endif

{

	/*
	 * This function interfaced by macro vs$processUnitField defined in
	 * vscmdmacros.h
	 */

	long	rc ;
	char	*text,
		*unit ;

	text = VSmcf_get_text( form, field, row, col ) ;

	if( OM_K_NOT_AN_OS == osnum ) {
		ex$get_cur_mod( osnum = &osnum ) ;
	}

	if( !type ) type = GRIO_DISTANCE ;

	vs$unit_to_system(	msg	= msg,
				unit	= text,
				type	= type,
				p_value	= newValue ) ;

	_FREE( text ) ;

	if( !( *msg & 1 ) ) {
		/*
		 * Invalid value: redisplay previous one.
		 */
		*newValue = oldValue ;
	} else if( verify ) {
		if( !verify( *newValue, args ) ) {
			*newValue = oldValue ;
			*msg = MSINARG ;
		}
	}

	vs$system_to_unit(	msg	= &rc,
				type	= type,
				osnum	= osnum,
				value	= *newValue,
				p_unit	= &unit ) ;

	FIfld_set_text( form, field, row, col, unit, FALSE ) ;

	return *msg & 1 ;

} /* VSprocessUnitField */
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) short: here
   osnum causes it to choke...
 */
long VSfillUnitField(	long	*msg,
			char	*form,
			int	field,
			int	row,
			int	col,
			OMuword	osnum,
			char	*type,
			double	value )

#else
long VSfillUnitField( msg, form, field, osnum, type, value )

long	*msg ;
char	*form ;
int	field ;
OMuword	osnum ;
char	*type ;
double	value ;
#endif

{

	char	*unit ;

	if( OM_K_NOT_AN_OS == osnum ) {
		ex$get_cur_mod( osnum = &osnum ) ;
	}

	vs$system_to_unit(	msg	= msg,
				value	= value,
				type 	= type,
				osnum 	= osnum,
				p_unit	= &unit ) ;

	FIfld_set_text(	form, field, row, col, unit, FALSE ) ;

	return TRUE ;

} /* VSfillUnitField */
/*----------------------------------------------------------------------------*/
int VSget_form_pos( form, pos ) char *form ;  struct VSdpb_form_pos *pos ; {

	int	screen,
		x,
		y,
		width,
		height,
		rc ;

	rc = VSf_get_layout( form, &screen, &x, &y, &width, &height ) ;

	pos->screen	= screen ;
	pos->x		= x ;
	pos->y		= y ;
	pos->width	= width ;
	pos->height	= height ;

	return rc ;

} /* VSget_form_pos */
/*----------------------------------------------------------------------------*/
