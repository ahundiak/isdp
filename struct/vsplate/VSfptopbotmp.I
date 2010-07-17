/*
	I/STRUCT
*/
class implementation VSfrzPlate ;

#include <string.h>
#include "EMSmsgdef.h"
/*----------------------------------------------------------------------------*/
method VStopBottomMapping( long *msg ; int count, index[2] ; GRname name[2] ) {

#define	BOT	0
#define TOP	1

	strcpy( name[BOT], VS_K_plBotSfName ) ;
	strcpy( name[TOP], VS_K_plTopSfName ) ;
	index[0] = me->map[0] ;
	index[1] = me->map[1] ;

	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VStopBottomMapping */
/*----------------------------------------------------------------------------*/

end implementation VSfrzPlate ;

