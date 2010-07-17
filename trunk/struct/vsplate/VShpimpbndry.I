/*
	I/STRUCT
*/
class implementation VSholPlate ;

#include "vsmiscmacros.h"
#include "vsgeommacros.h"
/*----------------------------------------------------------------------------*/
method VSimposeBoundary(	long			*msg ;
				int			bndryCount ;
				struct GRobj_env	bndryList[],
							*surface ;
				int			sfIsPlanar ) {

	return vs$imposeBoundaries(	msg		= msg,
					surface		= surface,
					bndryCount	= bndryCount,
					bndryList	= bndryList,
					sfIsPlanar	= sfIsPlanar ) ;

} /* method VSimposeBoundary */
/*----------------------------------------------------------------------------*/

end implementation VSholPlate ;
