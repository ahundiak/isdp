/*
	I/STRUCT
*/
class implementation VSpart ;

#include <stdio.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	VSget_sub_cmp_ix(	long		*msg ;
				VScmpixtype	flag ;
				VSixPath	*rpath,
						*vpath ) {

	long	sts ;
	int	i ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;
	switch( flag ) {
		int max ;

		case VS_e_virtual_to_real :
			max = rpath->sz = vpath->sz ;
			for( i = 0 ; i < max ; i++ )
				rpath->ls[i] = vpath->ls[i] ;
			break ;
		case VS_e_real_to_virtual :
			max = vpath->sz = rpath->sz ;
			for( i = 0 ; i < max ; i++ )
				vpath->ls[i] = rpath->ls[i] ;
			break ;
		default	:
			*msg	= MSINARG ;
			sts	= OM_E_INVARG ;
	}

	return sts ;

} /* method VSget_sub_cmp_ix */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
