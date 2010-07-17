/*
	I/STRUCT
*/
#include "OMminimum.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "exdef.h"		/* Constants for exec (IGE)	*/
#include "ex.h"			/* Structs EX*			*/
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "vsglobalmsg.h"
/*----------------------------------------------------------------------------*/
long VSdotsInStatusField( count, msg ) int count ; long msg ; {

/*
 * count	>= 0 : prints "Processing ...." ( with `count' dots)
 * count	= -1 : clears status field
 * count	= -2 : use preceeding count plus one.
 * This function is interfaced by macro "vs$dotsInStsFld".
 */
#define	MAXDOTS	12

	static char	dots[MAXDOTS+2] = "............." ;
	static int	prevCount = 0 ;

	if( count == -1 ) {
	  ex$message(	msgnumb		= VS_gI_EmptyMessage,
			justification	= CENTER_JUS ) ;
	  prevCount = 0 ;
	} else if( count == -2 ) {
	  count = prevCount + 1 ;
	  goto PROCESSING ;
	} else if( count >= 0 ) {
	  PROCESSING :
	    count = count % ( MAXDOTS + 1 ) ;

	    dots[count] = '\0' ;

	    ex$message(
	    	msgnumb	      = msg == MS_NO_MSG ? VS_gI_ProcessingSomething
	    	                                 : msg,
		justification = CENTER_JUS,
		type	      = "%s",
		var	      = dots ) ;

	    dots[count] = '.' ;
	    prevCount = count ;
	}

	return prevCount ;

} /* VSdotsInStatusField */
/*----------------------------------------------------------------------------*/

