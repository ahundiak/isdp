/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdlib.h>
#include "exmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"
/*----------------------------------------------------------------------------*/
method VSgetOperators(	long		*msg ;
			int		*opCount ;
			VSoperator	**p_opList ) {

	long			sts ;		/* OM return code	*/
	int			i ;		/* Loop index		*/
	struct GRid		*operatorIds,	/* Ids of operators	*/
				*buffer ;
	struct GRobj_env	*graphics = NULL ;
						/* List of G.O.'s	*/
	register VSoperator	*pO ;		/* Loop pointer		*/

	operatorIds = NULL ; *p_opList = NULL ;

	/*
	 * If source source part, take all parents, else take all parents but
	 * the one at index 0.
	 */
	sts = om$send(	msg	= message VSpart.VSifSourceThenSend(
							VS_K_READ_OMmsg ),
			targetid= my_id ) ;

	switch( sts ) {
		case OM_S_SUCCESS	:
		/*
		 * Source feature: get support objects.
		 */
		case OM_I_STOP_SENDING	: i = 0 ; break ;
		/*
		 * Modified feature: get operator parents (from 1 up).
		 */
		case OM_W_ABORT		: i = 1 ; break ;
		default	: i = -1 ;
		          __CheckRC( sts, 1, "VSpart.VSifSourceThenSend", wrapup ) ;
	}

	sts = om$send(	msg	= message NDnode.NDget_objects(
							 ND_ROOT | ND_IN_BUF,
							 NULL,
							 0,
							 &buffer,
							 /* from */ i,
							 /* to   */ OM_K_MAXINT,
							 opCount ),
			targetid = my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	if( i > 0 ) (*opCount)-- ;

	if( !*opCount ) {
		/*
		 * No operators.
		 */
		goto wrapup ;
	}
	graphics	= _MALLOC( *opCount, struct GRobj_env ) ;
	operatorIds	= _MALLOC( *opCount, struct GRid ) ;

	if( !( graphics && operatorIds ) ) vs$mem_fail() ;

	for( i = 0 ; i < *opCount ; i++ ) {
		operatorIds[i] = buffer[i] ;
	}

	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, *opCount, operatorIds, graphics ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	if( !( *p_opList = _MALLOC( *opCount, VSoperator ) ) ) vs$mem_fail() ;

	for( pO = *p_opList, i = 0 ; i < *opCount ; i++, pO++ ) {
		pO->id	= operatorIds[i].objid ;
		pO->os	= operatorIds[i].osnum ;
		pO->type= VSgetOperatorType(	operatorIds + i,
						&graphics[i]._grid ) ;
		pO->env	= graphics[i].mod_env ;
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( graphics	  ) ; 
		_FREE( operatorIds ) ;
		if( !( sts & 1 & *msg ) ) {
			/*
			 * Free operator list.
			 */
			_FREE( *p_opList ) ;
			*p_opList = NULL ; *opCount = 0 ;
		}
		return sts ;

} /* method VSgetOperators */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

