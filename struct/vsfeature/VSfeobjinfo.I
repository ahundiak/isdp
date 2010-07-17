/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsdbgmacros.h"
/*
 * Include of function prototypes.
 */
#include "vsfmtobjinfo.h"
/*----------------------------------------------------------------------------*/
method GRgetobjinfo(	long			*msg ;
			struct GRobj_info	*info ) {

	long		sts,
			VSrc ;
	VSobjDef	objDef ;

	sts = om$send(	msg 	= message VSfeature.VSforwardToOriginal(
						&VSrc,
						OM_e_wrt_object,
						message VScpx.VSgetObjDef(
								msg, &objDef )),
			targetid= my_id ) ;

	if( sts & VSrc & *msg & 1 ) { 
		sts = VSformatObjInfo(	msg,
					OM_Gw_current_OS,
					my_id,
					objDef.info,
					info ) ;
		if( !( sts & 1 & *msg ) ) info->type[0] = '\0' ;
	} else {
		info->type[0] = '\0' ;
	}

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method GRgetobjinfo */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
