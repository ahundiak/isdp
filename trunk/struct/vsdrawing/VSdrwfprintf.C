/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>


#ifdef ENV5
#include <stdarg.h>
#elif defined(X11)
#include "standards.h"
#include "varargs.h"
#include "stdarg.h"
#endif


extern FILE	*VSdrwGetLogFile __(( void )) ;
extern int	VSyydrwlineno ;
/*----------------------------------------------------------------------------*/
void VSdrwPrintf( va_alist ) va_dcl {

	va_list	args ;
	char	*fmt ;
	FILE	*logFile = VSdrwGetLogFile() ;

	va_start( args, 0 ) ;
		fprintf( logFile, "%4d ", VSyydrwlineno ) ;
		fmt = va_arg( args, char * ) ;
		vfprintf( logFile, fmt, args ) ;
	va_end( args ) ;

} /* VSdrwPrintf */
/*----------------------------------------------------------------------------*/

