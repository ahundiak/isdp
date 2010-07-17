/*
	I/STRUCT
*/
class implementation VSpart ;

#include <stdio.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "exmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSisNameHolder( int OMmsgType ) {

	/*
	 * Here is implemented the default behavior.
	 * If 'OMmsgType' is VS_K_READ_OMmsg, then answer "yes", i.e. return
	 * OM_I_STOP_SENDING, else if 'OMmsgType' is VS_K_WRITE_OMmsg, only
	 * answer "yes" if you are in the active file otherwise say "no and
	 * don't bubble up".
	 */
	long	sts = OM_I_STOP_SENDING ;

	if( OMmsgType == VS_K_WRITE_OMmsg ) {
		OMuword actModOs ;
		ex$get_cur_mod( osnum = &actModOs ) ;
		if( actModOs != OM_Gw_current_OS ) sts = OM_E_ABORT ;
	}

	return sts ;

} /* method VSisNameHolder */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
