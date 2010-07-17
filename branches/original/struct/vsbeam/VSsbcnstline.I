/*
	I/STRUCT
*/
class implementation VSsrcBeam ;

#include "vsmiscmacros.h"
#include "vsbeammacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VScnst_line_rep(	long			*msg ;
			struct GRmd_env         *my_env ;
			struct GRobj_env	supports[2];
			struct GRvg_construct	*cst ;
			struct GRid  		*profile ;
			struct GRid  		*linearRep ) {

	return vs$make_linear_beam_rep(	msg		= msg,
					xSection	= profile,
					surface		= supports + 0,
					axis		= supports + 1,
					copyAxis	= TRUE,
					cst		= cst,
					linearRep	= linearRep ) ; 

} /* method VScnst_line_rep */
/*----------------------------------------------------------------------------*/

end implementation VSsrcBeam ;

