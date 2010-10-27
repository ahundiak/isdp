/* $Id: VDmsgkey2str.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDmsgkey2str.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmsgkey2str.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS

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
char *VDmsgkey2string( msgkey ) long msgkey ; {

	static char msg[1+MS_MAX_MSG_LENGTH] ;

	*msg = '\0' ;
 	if( msgkey != MS_NO_MSG ) {

		ex$message(	msgnumb	= msgkey,
				buff	= msg ) ;
	}
	return msg ;

} /* VDmsgkey2string */
/*----------------------------------------------------------------------------*/

