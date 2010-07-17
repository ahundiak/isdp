/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include <string.h>
/*----------------------------------------------------------------------------*/
method DIgive_output( char *output ) {

	long			sts,
				msg ;
	struct GRobj_info	info ;

	sts = om$send(	msg 	= message GRgraphics.GRgetobjinfo( &msg, &info),
			targetid= my_id ) ;

	if( sts & 1 & msg ) {
		strcat( output, "[" ) ;
		strcat( output, info.type ) ;
		strcat( output, "]" ) ;
	} else {
		strcat( output, "[]" ) ;
	}
	return OM_S_SUCCESS ;

} /* method DIgive_output */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

