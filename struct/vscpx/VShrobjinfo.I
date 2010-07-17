/*
	I/STRUCT
*/
class implementation VShelper ;

/*
 * Includes of function portotypes.
 */
#Include "vsfmtobjinfo.h"
/*----------------------------------------------------------------------------*/
method GRgetobjinfo(	long			*msg ;
			struct GRobj_info	*info ) {

	long		sts ;
	VSobjDef	objDef ;

	sts = om$send(	msg 	= message VScpx.VSgetObjDef( msg, &objDef ),
			targetid= my_id ) ;
	if( sts & 1 & *msg ) {
		/*
		 * Add some info besides your type.
		 */
		VSformatCpxInfo( msg, OM_Gw_current_OS, my_id,
				 objDef.info, info ) ;
	} else {
		/*
		 * Something failed ..., do it the hard way.
		 */
		om$send(msg 	= message ACncpx.GRgetobjinfo( msg, info ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	}	
	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method GRgetobjinfo */
/*----------------------------------------------------------------------------*/

end implementation VShelper ;
