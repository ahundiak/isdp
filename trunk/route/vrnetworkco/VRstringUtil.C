#define __APGE__

#include <stdio.h>
#include <varargs.h>
#include "msdef.h"
#include "msmacros.h"

/*----------------------------------------------------------------------------*/
char *VRstrcatMsg( va_alist ) va_dcl {
	
	/*
	 * For each argument, this function retrieves the message associated
	 * to the argument and return a string composed like this :
	 *
	 * "message#1       message#2      ......message#n",
	 *  |<- 11 chars ->|<- 11 chars ->|
	 * 
	 * Notes : 
	 *	- The last argument should be -1. 
	 *	- The string returned should be freed by the user.
	 */

	va_list		list ;
	long		msg_key ;
	char		buffer[80] ;
	char		ret_string[132] ;
	
	va_start( list ) ;
	
		msg_key = va_arg( list, long ) ;
		
		ex$message( msgnumb = msg_key,
			    buff    = buffer ) ;
			    
		sprintf( ret_string, "%-11s", buffer ) ;
		
		while( ( msg_key = va_arg( list, long ) ) != -1 ) {
		
			ex$message( msgnumb = msg_key,
				    buff    = buffer ) ;
				    
			sprintf( buffer, "%-11s", buffer ) ;
	
			strcat( ret_string, buffer ) ;
		}

	va_end( list ) ;
	
	return ret_string ;
}
/*----------------------------------------------------------------------------*/
