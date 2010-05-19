/*
	I/VDS	Copy

Abstract
	Checks if input object space number is among list.

Arguments
	IN	OMuword			osnum		object space number
							of object to test.
	IN	int			spaceCount	count of input OSes
	IN	OMuword			spaceList[]	list of input OSes

*/

#include "OMminimum.h"
/*---------------------------------------------------------------------------*/
int VD_is_osnum_in_list( osnum, spaceCount, spaceList )

OMuword		osnum ;
const OMuword	*spaceList ;
int		spaceCount ; {

	int rc ;

	if( spaceCount && spaceList ) {
		const OMuword	*last = spaceList + spaceCount ;
	
		rc = FALSE ;
		for( ; spaceList < last ; spaceList++ ) {
			if( osnum == *spaceList ) {
				rc = TRUE ;
				break ;
			}
		}
	} else rc = TRUE ;

	return rc ;
	
} /* VD_is_osnum_in_list */
/*---------------------------------------------------------------------------*/

