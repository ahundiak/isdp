/*
	I/STRUCT
*/
class implementation VSsrcBeam ;

#include "ms.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VScnst_solid_rep( 	long			*msg ;
				struct GRmd_env         *my_env ;
				struct GRvg_construct 	*cst ;
				struct GRobj_env	*surface,
							*axis ;
				struct GRid  		*profile,
					  		*solidRep ) {

	struct GRobj_env	prflIdEnv ;	/* Id+env. of profile	*/

	prflIdEnv._grid 	= *profile ;
	prflIdEnv.mod_env	= *cst->env_info ;

	return vs$make_beam_segment(	msg	= msg,
					xSection= &prflIdEnv,
					surface	= surface,
					axis	= axis,
					cst	= cst,
					segment	= solidRep ) ;

} /* method VScnst_solid_rep */
/*----------------------------------------------------------------------------*/

end implementation VSsrcBeam ;
