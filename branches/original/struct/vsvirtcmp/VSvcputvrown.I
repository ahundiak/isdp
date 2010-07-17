/*
	I/STRUCT
*/
class implementation VSvirtcmp ;

#include <string.h>
/*----------------------------------------------------------------------------*/
method VSputVirtualOwner( long *msg ; struct GRid *vo ; char *path ) {

	me->virtualOwner = *vo ;
	strcpy( me->path, path ) ;

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* VSputVirtualOwner */
/*----------------------------------------------------------------------------*/

end implementation VSvirtcmp ;

