/*
	I/STRUCT
*/
class implementation VSupretend ;

#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "igrdp.h"		/* Structs IGR* for display	*/
#include "griodef.h"
#include "godef.h"
#include "go.h"

from VScpx import VSdescribeOutput ;
/*----------------------------------------------------------------------------*/
method DIgive_output( char *string ) {

	long		sts,
			msg ;
	GRname		name ;
	struct GRid	parent ;

	sts = om$send(	msg	= message ACpretend.ACgive_downscan( name ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	sts = om$send(	msg	= message ACpretend.ACfind_parent(
							&parent, NULL, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	sts = om$send(	msg	= message VScpx.VSdescribeOutput(
						&msg, name, string ),
			targetid= parent.objid,
			targetos= parent.osnum ) ;
	if( !( sts & 1 & msg ) ) goto wrapup ;

	wrapup :
	return OM_S_SUCCESS ;

} /*  method DIgive_output */
/*----------------------------------------------------------------------------*/

end implementation VSupretend ;
