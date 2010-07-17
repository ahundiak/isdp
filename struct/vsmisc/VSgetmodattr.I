/*
	I/STRUCT
*/
class implementation VSpart ;

#include "msdef.h"
/*----------------------------------------------------------------------------*/
long VSgetModifiableAttr( msg, classname, type, attributes )

long		*msg ;
char		*classname ;
unsigned long	*type,
		*attributes ; {

	long		sts ;
	OM_S_OBJID	part ;

	sts = om$construct(	classname	= classname,
				osnum		= OM_Gw_TransOSnum_0,
				p_objid		= &part ) ;
	*msg = MSFAIL ;
	if( sts & 1 ) {
		sts = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
							msg, type, attributes ),
				targetid= part,
				targetos= OM_Gw_TransOSnum_0,
				senderid= part ) ;
		if( sts & 1 & *msg ) {
			*msg = MSSUCC ;
		}
		om$send(	msg	= message Root.delete( 0 ),
				targetid= part,
				targetos= OM_Gw_TransOSnum_0,
				senderid= part ) ;
	}
	return *msg & 1 ;

} /* VSgetModifiableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
