/*
	I/STRUCT
*/
class implementation VSrflPlate ;

#include <string.h>
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VStopBottomMapping( long *msg ; int count, index[2] ; GRname name[2] ) {

	SetProc( VSrflPlate_VStopBottomMapping ) ; Begin ; __DBGpr_me() ;

#define	BOT	0
#define TOP	1

	strcpy( name[BOT], VS_K_plBotSfName ) ;
	strcpy( name[TOP], VS_K_plTopSfName ) ;
	index[0] = me->map[0] ;
	index[1] = me->map[1] ;

	__DBGpr_int( "map 0", index[0] ) ;
	__DBGpr_int( "map 1", index[1] ) ;
	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VStopBottomMapping */
/*----------------------------------------------------------------------------*/

end implementation VSrflPlate ;

