/*
	I/STRUCT
*/
class implementation VSbmawszCmd ;

#include <stdio.h>
#include "dpbco.h"
#include "gr.h"
#include "vsdef.h"
#include "vs.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vscmddef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
/*----------------------------------------------------------------------------*/
method putToDpb(	long		*msg ;
			double		value ; ) {

	if( value > 0 ) {
		vs$put_beam_arrow_size(	msg	= msg,
					p_size	= &value ) ;
		me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
	} else {
		me->ret = CO_E_INVINP ;
	}
	return OM_S_SUCCESS ;

} /* method putToDpb */
/*----------------------------------------------------------------------------*/
method displayValue( long *msg ) {

	double	value ;

	vs$get_beam_arrow_size(	msg = msg, p_size = &value ) ;
	if( *msg & 1 ) {
		char	*unit ;

		vs$system_to_unit(	msg	= msg,
					value	= value,
					type	= GRIO_DISTANCE,
					osnum	= me->ModuleInfo._MD_OS,
					p_unit	= &unit ) ;

		ex$message(	msgnumb		= VS_gI_ArwSz,
				type		= "%s",
				var		= `unit`,
				justification	= CENTER_JUS,
				field		= ERROR_FIELD ) ;

		me->ret = VS_K_ACT_SUCCESS ;
	} else {
		me->ret = VS_K_ABORT_CMD ;
	}

	return OM_S_SUCCESS ;

} /* method displayValue */
/*----------------------------------------------------------------------------*/

end implementation VSbmawszCmd ;
