/*
	I/STRUCT
*/ 
class implementation VScpx ;

#include "acmacros.h"

extern struct GRid 	AC_construct_id ;
/*----------------------------------------------------------------------------*/
method	ACattach( int *succ ; char *macDefName ) {

	long			msg,		/* Completion code	*/
				sts ;		/* OM return code	*/
	OM_S_OBJID		macDefId ;	/* Id of mac. definition*/

	sts = ac$find_macro_defn(	action		= ACfind_load,
					macro_name	= macDefName,
					p_macro_defn_id	= &me->mac_def ) ;

	if( !( sts & 1 ) ) {
		/*
		 * No macro definition exists for this class yet: create one.
		 */
		me->mac_def.osnum = AC_construct_id.osnum ;
		sts = om$send(	msg	= message VScpx.VScreate_def(
							&msg,
							macDefName,
							me->mac_def.osnum,
							&macDefId ),
				targetid= my_id ) ;
		if( sts & 1 & msg ) {
			me->mac_def.objid = macDefId ;
			*succ = TRUE ;
		} else {
			me->mac_def.objid = NULL_OBJID ;
			*succ = FALSE ;
		}
	} else *succ = TRUE ;

	return sts ;

} /* method ACattach */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
