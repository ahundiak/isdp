/*
	I/STRUCT
*/
class implementation VSvirtcmp ;

#include <string.h>
/*----------------------------------------------------------------------------*/
method VSgetVirtualOwner( long *msg ; struct GRid *p_vo ; GRname path ) {

	/*
	 * We make this check just in case `owner' forgot to delete us
	 * when it got deleted.
	 */
	if( om$is_objid_valid(	osnum	= me->virtualOwner.osnum,
				objid	= me->virtualOwner.objid ) & 1 ) {
		*p_vo = me->virtualOwner ;
		strcpy( path, me->path ) ;
	} else {
		me->virtualOwner.objid = NULL_OBJID ;
	}

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* VSgetVirtualOwner */
/*----------------------------------------------------------------------------*/

end implementation VSvirtcmp ;

