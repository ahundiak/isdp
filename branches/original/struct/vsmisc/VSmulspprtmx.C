/*
	I/STRUCT
*/
#include <stdio.h>		/* For NULL			*/
#include <string.h>		/* For memcpy()			*/
#include "madef.h"
#include "vs.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
void VSmulSupportMx( elmEnv, count, supports )

struct GRmd_env	*elmEnv ;
int		count ;
VSsuppList	supports ; {

	int	i ;

	if( !elmEnv || elmEnv->_MATRIX_TYPE == MAIDMX ) return ;

	for( i = 0 ; i < count ; i++ ) {

		if( supports[i]._matrix_type == MAIDMX ) {

			 supports[i]._matrix_type = elmEnv->_MATRIX_TYPE ;

			 memcpy( (char *) supports[i]._matrix,
			 	 (char *) elmEnv->_MATRIX,
			 	 sizeof( IGRmatrix ) ) ;
		} else {
			VSmulmx( supports[i]._matrix,
				 elmEnv->_MATRIX,
				 supports[i]._matrix,
				&supports[i]._matrix_type ) ;
		}
	}

} /* VSmulSupportMx */
/*----------------------------------------------------------------------------*/
