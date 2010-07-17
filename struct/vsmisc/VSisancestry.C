/*
	I/STRUCT

Abstract
	Checks if input object is of given class or of one of its subclasses.

Arguments
IN	const struct GRid	*object		object to test
IN	OMuword			classid		class id

Returns
	TRUE if `object' of (sub)class `classid' else FALSE.
*/
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "gr.h"			/* Structs GR* for graphic info	*/
/*----------------------------------------------------------------------------*/
int VSis_ancestry_valid( object, classid )

const struct GRid	*object ;
OMuword			classid ; {

	OMuword subclassid ;

	return
	 	( 1 & om$get_classid(	objid		= object->objid,
					osnum		= object->osnum,
					p_classid	= &subclassid ) )
	&&	om$is_ancestry_valid(
				superclassid	= classid,
				subclassid	= subclassid ) == OM_S_SUCCESS ;
	
} /* VSis_ancestry_valid */
/*----------------------------------------------------------------------------*/

