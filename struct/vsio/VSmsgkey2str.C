/*
	I/STRUCT

Abstract
	Converts a message number to a message string.
Argument
	long	msgkey		message number
Returns
	A pointer to a static buffer containing the message string.
Caveats
	The static buffer is overwritten at each invocation of the function
 */
#include "OMminimum.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "exdef.h"		/* Constants for exec (IGE)	*/
#include "ex.h"			/* Structs EX*			*/
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
/*----------------------------------------------------------------------------*/
char *VSmsgkey2string( msgkey ) long msgkey ; {

	static char msg[1+MS_MAX_MSG_LENGTH] ;

	*msg = '\0' ;
 	if( msgkey != MS_NO_MSG ) {

		ex$message(	msgnumb	= msgkey,
				buff	= msg ) ;
	}
	return msg ;

} /* VSmsgkey2string */
/*----------------------------------------------------------------------------*/

