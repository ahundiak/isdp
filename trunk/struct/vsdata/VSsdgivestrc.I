/*
	I/STRUCT
*/
class implementation VSsharedData ;

#include "ACrg_collect.h"
/*----------------------------------------------------------------------------*/
method NDgive_structure(	long			*msg ;
				struct ret_struct	*retStr ;
				struct GRmd_env		*myEnv ; ) {

	retStr->type = gen_rg_collect ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method NDgive_structure */
/*----------------------------------------------------------------------------*/

end implementation VSsharedData ;

