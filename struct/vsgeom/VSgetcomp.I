/*
	I/STRUCT
*/
class implementation GRowner ;

#include <stdio.h>
#include <stdlib.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSgetComponents( msg, grobjId, grobjEnv, number, components )

long			*msg ;
const struct GRid	*grobjId ;
const struct GRmd_env	*grobjEnv ;
int			*number ;
struct GRid		**components ; {

	/*
	 * Given an object ( grobjId, grobjEnv ), this function returns
	 * the number ( number ) and all components ( components ) on
	 * the "to_components" channel.
	 *
	 * Notes :
	 * -------
	 *	`*components' is allocated and hence must be freed by the caller
	 *	with `free( *components )'.
	 *
	 *	This function is interfaced by macro `vs$get_components'.
	 */

	long		sts ;		/* OM completion code.		      */
	int		count ; 	/* Count of components on the channel.*/

	*number     = 0 ;
	*components = NULL ;

	/*
	 * Get number of components on the channel.
	 */
	sts = om$send( msg	= message GRowner.GRget_number_components(
								       msg,
								       &count ),
		       senderid = grobjId->objid,
		       targetid = grobjId->objid,
		       targetos = grobjId->osnum ) ;
	__CheckRC( sts, *msg, "GRowner.GRget_number_components", wrapup ) ;

	/*
	 * Allocate memory for output list.
	 */
	if( !( *components = _MALLOC( count, struct GRid ) ) ) vs$mem_fail() ;

	/*
	 * Get all components on the channel.
	 */
	sts = om$send( msg	= message GRowner.GRget_components(
					msg, (struct GRmd_env*) grobjEnv,
					*components, count, number, 0, count ),
		       senderid = grobjId->objid,
		       targetid = grobjId->objid,
		       targetos = grobjId->osnum ) ;
	__CheckRC( sts, *msg, "GRowner.GRget_components", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *components ) ;
			*components = NULL ;
			*number     = 0 ;
		}

		return sts ;

} /* VSgetComponents */
/*----------------------------------------------------------------------------*/

end implementation GRowner ;
