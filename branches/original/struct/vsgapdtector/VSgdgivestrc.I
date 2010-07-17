/*
	I/STRUCT
*/
class implementation VSgapDtector ;

#include <string.h>
#include "OMmacros.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

/*----------------------------------------------------------------------------*/
method	ACgive_structure(	int			*ok,
							*notUsed ;
				char			*attribute ;
				struct ret_struct	*value ;
				struct GRmd_env		*myEnv ) {

	long		sts	= OM_S_SUCCESS ;

	*ok = TRUE ;
	
	if( !strcmp( attribute, VS_K_gdVirtOutMaxAdmGap ) ) {

		value->type			= double_type ;
		value->var.root_pm_st.value	= me->maxAdmissibleGap ;

	} else if( !strcmp( attribute, VS_K_gdVirtOutExcessGap ) ) {

		value->type			= double_type ;
		value->var.root_pm_st.value	= me->excessGap ;

	} else {
		sts = om$send(	msg	= message VShelper.ACgive_structure(
					ok, notUsed, attribute, value, myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	return sts ;

} /* method ACgive_structure */
/*----------------------------------------------------------------------------*/

end implementation VSgapDtector ;
