/*
	I/STRUCT

Abstract
	Checks if input object's class is among list or is a sub-class of
	classes in list, or conversly, checks if input object's class is
	NOT among list or is NOT a sub-class of classes in list.

Arguments
	IN	OM_S_OBJID		objid		Id of object to test.
	IN	OMuword			osnum		Object space number
							of object to test.
	IN	OM_S_CLASSLIST		*classList	Class list for check

Note
	To check if objects are NOT in the class list `classList->w_flags`
	must be set to `OM_CLST_negation'. This is the only flag recognized.
*/
/*---------------------------------------------------------------------------*/
#include <stdio.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "VDobj.h"
#include "vsdbgmacros.h"
/*---------------------------------------------------------------------------*/
int VSis_object_of_classes( objid, osnum, classList )

OM_S_OBJID		objid ;
OMuword			osnum ;
const OM_S_CLASSLIST	*classList ; {

	OMuword	objcls,
		*classes = classList->p_classes ;
	int	rc = FALSE,
		CLneg = ( classList->w_flags & OM_CLST_negation ) != 0 ;

	if( !classList ) { rc = TRUE ; goto wrapup ; }

	if( 1 & om$get_classid(	objid		=  objid,
				osnum		=  osnum,
				p_classid	= &objcls ) ) {

		int is_of_class, c ;

		for( c = 0 ; c < classList->w_count ; c++ ) {

			is_of_class = om$is_ancestry_valid(
						superclassid	= classes[c],
						subclassid	= objcls )
						== OM_S_SUCCESS ;
			if( is_of_class ) {
				rc = TRUE ;
				break ;
			} else if( CLneg ) {
				rc = TRUE ;
				break ;
			}
		}
	}

	wrapup :
		return rc ;

} /* VSis_object_of_classes */
/*---------------------------------------------------------------------------*/

