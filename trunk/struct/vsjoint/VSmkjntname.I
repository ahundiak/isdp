/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
/*----------------------------------------------------------------------------*/
long VSmakeJointName( msg, parent0, parent1, directory, name )

long		*msg ;
struct GRid	*parent0,
		*parent1 ;
char		*directory,
		*name ; {

	/*
	 * Note: returns the full name, not the base name.
	 */
	long		sts ;
	GRname		name0,
			name1 ;

	*name0 = *name1 = '\0' ;
	sts = om$send(	msg	= message GRgraphics.GRgetname( msg, name0 ),
			senderid= parent0->objid,
			targetid= parent0->objid,
			targetos= parent0->osnum ) ;

	sts = om$send(	msg	= message GRgraphics.GRgetname( msg, name1 ),
			senderid= parent1->objid,
			targetid= parent1->objid,
			targetos= parent1->osnum ) ;
	if( !*name0 || !*name1 ) {
		*name = '\0' ; *msg = MSSUCC ; sts = OM_S_SUCCESS ;
	} else {
		GRname	base0,
			base1,
			junk ;

		di$split(	pathname	= name0,
				dirname		= junk,
				name		= base0 ) ;

		di$split(	pathname	= name1,
				dirname		= junk,
				name		= base1 ) ;

		sprintf( junk, "%s-%s-J", base0, base1 ) ;

		sts = VSbuildName( msg, directory, junk,  base0 ) ;
		if( sts & 1 & *msg ) {
			DIstmcpy(	name,
					directory,
					base0,
					NULL ) ;
		}
	}

	return sts ;

} /* VSmakeJointName */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
