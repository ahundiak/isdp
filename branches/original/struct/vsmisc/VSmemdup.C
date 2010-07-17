/*
	I/STRUCT

Abstract
	Mallocs a buffer and copies input buffer to it.

Arguments
	void		*buffer		buffer to copy
	unsigned	nbytes		size in bytes of input buffer
Returns
	A pointer to the allocated buffer if success else NULL.
*/
#include <stdio.h>	/* For NULL	*/
#include <stdlib.h>	/* For malloc()	*/
#include <string.h>	/* For memcpy()	*/
/*----------------------------------------------------------------------------*/
void *VSmemdup( buffer, nbytes ) void *buffer ; unsigned nbytes ; {

	register void *dup ;

	if( buffer && nbytes ) {
		if( dup = malloc( nbytes ) ) {
			memcpy( dup, buffer, nbytes ) ;
		}
	} else dup = NULL ;
	return dup ;

} /* VSmemdup */
/*----------------------------------------------------------------------------*/


