/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "nddef.h"
/*----------------------------------------------------------------------------*/
method ACbecome_macro(	long		*action ;
			int		posInGraph ;
			struct GRmd_env	*myEnv ; ) {

/*
 * This flag (DROP_MODE_ONLY) also present in VSfecopy.I
 * (method VSfeature.NDcopy).
 */
#ifdef DROP_MODE_ONLY
	if( posInGraph & ND_BODY )	
		*action = ND_DROP_MAC ;
	else	*action = ND_SYMB_MAC | ND_CONS_MAC | ND_DROP_MAC ;
#else
	*action = ND_SYMB_MAC | ND_CONS_MAC | ND_DROP_MAC ;
#endif
	return OM_S_SUCCESS ;

} /* method ACbecome_macro */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
