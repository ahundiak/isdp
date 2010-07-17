/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/lock.h>
#include <time.h>
#include <sys/stat.h>
#include "unistd.h"
#include <FI.h>
#include "VX_FIproto.h"
#include "vsridef.h"
#include "vsri.h"
#include "vsriglobals.h"
#include "vsriproto.h"
/*----------------------------------------------------------------------------*/
void prompt( const char *text ) {
	FIfld_set_text( _form, FI_PROMPT_FIELD, 0, 0, (char *) text, FALSE ) ;
}
/*----------------------------------------------------------------------------*/
void msg( const char *text ) {
	FIfld_set_text( _form, FI_MSG_FIELD, 0, 0, (char *) text, FALSE ) ;
	if( *text ) {
		FIg_display( _form, WARNING ) ;
	} else {	
		FIg_erase( _form, WARNING ) ;
	}
} /* msg */
/*----------------------------------------------------------------------------*/
void fatal( const char *text ) {
	FIf_delete( _form ) ;
	fprintf( stderr, "\n%sAbort.\n", text ) ;
	exit( 2 ) ;
} /* fatal */
/*----------------------------------------------------------------------------*/
void badFileFormat(	const char	*file,
			int		line,
			const char	*expected,
			const char	*got ) {

	char err[1024] ;

	sprintf( err,
		 "Bad format for %s (line %d):\n\texpected: %s\n\tgot     : %s\n",
		 file,
		 line,
		 expected,
		 got ) ;

	fatal( err ) ;

} /* badFileFormat */
/*----------------------------------------------------------------------------*/

