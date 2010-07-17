/*
	I/STRUCT
*/
class implementation VSsharedData ;

#include "msdef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsshdatproto.h"
/*----------------------------------------------------------------------------*/
method VSgetData(	long		*msg ;
			int		count;
			VSdataDesc	list[] ) {

	long		sts ;			/* OM return code	*/
	int		i,			/* Loop-on-data index	*/
			maxindex ;
	VSdataPtr	val ;

	/*
	 * Check indices.
	 */
	maxindex = om$dimension_of( varray = me->loc ) ;

	for( sts = TRUE, i = 0 ; i < count ; i++ ) {
		if( list[i].index >= maxindex ) sts = FALSE ;
		if( list[i].type == VSstring ) {
			list[i].value.s = NULL ;
		}
	}
	if( !sts ) vs$inv_arg() ;

	for( i = 0 ; i < count ; i++ ) {
		if( me->loc[list[i].index].addr == VS_K_MAX_ADDR ) {
			list[i].type = VSnullType ;
			continue ;
		}
		/*
		 * Get data at specified index.
		 */
		val.s = me->data + me->loc[list[i].index].addr ;

		switch( list[i].type = (VSdataType) me->loc[list[i].index].type ) {
			case VSdouble	: list[i].value.d = *val.d ;
					  break ;
			case VSint	: list[i].value.i = *val.i ;
					  break ;
			case VSstring	:
				if( !( list[i].value.s = VSstrdup( val.s ) ) )
					vs$mem_fail() ;
				break ;
			default		: vs$inv_arg() ;
		}
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			VSfreeData( count, list ) ;
		}
		return sts ;

} /* method VSgetData */
/*----------------------------------------------------------------------------*/

end implementation VSsharedData ;
