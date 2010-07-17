/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "matypemx.h"

extern long	ACSget_abs_matrix() ;
/*----------------------------------------------------------------------------*/
method ACreturn_foot(	long		*msg ;
			char		*footName ;
			struct GRid	*footId ;
			short		*mxType ;
			IGRmatrix	mx ) {

	long	sts ;

	if( !*footName ) {

		footId->objid	= my_id ;
		footId->osnum	= OM_Gw_current_OS ;

		if( mx != NULL || mxType != NULL ) {

			short		matType ;
			IGRmatrix	mat ;

			if( !mx		) mx	= mat ;
			if( !mxType	) mxType= &matType ;

			MAidmx( msg, mx ) ;

			sts = ACSget_abs_matrix( *footId, mx ) ;
			__CheckRC( sts, 1, "ACSget_abs_matrix", wrapup ) ;

			MAtypemx( msg, mx, mxType ) ;

		}
		sts = OM_S_SUCCESS ;
		*msg= MSSUCC ;
	} else {
		sts = om$send(	msg	= message VDrelat_hdr.ACreturn_foot(
						msg, footName, footId,
						mxType, mx ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	wrapup :
		return sts ;

} /* method ACreturn_foot */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

