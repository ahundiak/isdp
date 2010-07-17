/*
	I/STRUCT
*/
class implementation VSvirtcmp ;

#include "OMmacros.h"

from ACcpx	import	ACconnect_pretend,
			ACconnect_pretendin ;
/*----------------------------------------------------------------------------*/
method NDmake_source(	long		*msg ;
			struct GRid	*locObj,
					*context ;
			char		*path ;
			OMuword		osnum ;
			struct GRid	*pretender ; ) {

	long		sts ;
	int		rc ;
	struct GRid	virtOwner ;
	GRname		Path ;

	sts = om$send(	msg	= message VSvirtcmp.VSgetVirtualOwner(
							msg, &virtOwner, Path ),
			targetid= my_id ) ;

	if( IF_NULL_OBJID( context->objid ) ) {
		sts = om$send(	msg	= message ACcpx.ACconnect_pretend(
							&rc, Path, pretender ),
				targetid= virtOwner.objid,
				targetos= virtOwner.osnum ) ;
	} else {
		sts = om$send(	msg	= message ACcpx.ACconnect_pretendin(
						&rc, Path, pretender, context ),
				targetid= virtOwner.objid,
				targetos= virtOwner.osnum ) ;
	}
	*msg = rc ? MSSUCC : MSFAIL ;
		
	return sts ;

} /* method NDmake_source */
/*----------------------------------------------------------------------------*/

end implementation VSvirtcmp ;
