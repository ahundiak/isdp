#include <sys/param.h>
#include <errno.h>
#include <malloc.h>
#include <string.h>
#include "error.h"		/* libxc header file */

#define BADSIZE		0
#define NULLNAME	1
#define BUFOVFLW	2
#define NOMEM		3
#define INVPATHSYN	4
#define BADBUFSIZ	5
#define CWDERR		6
#define INVALARG	7

static char prefix[]="expand_filename: ";

static char *exf_messages[] = {

/* BADSIZE */       "size of path \"%s\"  > maximum file name size (%d)\n",
/* NULLNAME */ 	    "null file name given\n",
/* BUFOVFLW */      "buffer overflow (absolute pathname too large for buffer)\n",
/* NOMEM */	    "no dynamic memory available\n",
/* INVPATHSYN */    "invalid path syntax within \"%s\"\n",
/* BADBUFSIZ */     "given file name already exceeds given buffer size\n",
/* CWDERR */        "unable to get CWD (may be buffer too small)\n",
/* INVALARG */      "Invalid argument \"%s\" contains NULL pointer\n"

};


ERRDESCR exf_errdescr = {  { ERR_DFLT, ERR_DFLT, ERR_DFLT, ERR_DFLT },	/* handlers */
		 	   { prefix, prefix, prefix, prefix },		/* prefixes */
 	    		     exf_messages				/* message_table */
			};

/************************************************************
 *
 *   expand_filename
 *
 *	    Translates given filename to absolute path
 *          expanding all shell variables, compressing
 *          consecutive slashes to a single slash and
 *	    translating all embedded "." and "..".
 *
 *	If "*size" == zero then a buffer of size MAXPATHLEN + 1
 *      will be allocated using malloc. "MAXPATHLEN" is defined
 *      in <sys/param.h>.  The resultant absolute file name will
 *      be returned in the buffer.
 *
 *      If size is given the resultant string will be placed 
 *      into the given buffer.
 *
 *	In either case the int pointed to by size will be updated 
 *	to reflect the resultant string length.
 *
 *	Processing will terminate in error once the output
 *      path name size exceeds MAXPATHLEN.
 *
 *      Strlen( fname ) must be <= MAXPATHLEN.
 *
 *      No metacharacters are accepted.
 *	
 ************************************************************/

char *expand_filename( buf, size )
char *buf;
int *size;
{
 register char  *tmp = 0;
 register int   indx, ondx, buf_size;
 int  		tmp_size;

 if( !buf  ||  !size ) {
	report_error( &exf_errdescr, INVALARG, ERR_ERROR, 0, ((buf) ? "size" : "buf" ) );
	return( (char *)-1 );
 }

 if( buf[ 0 ] == 0 ) {
	report_error( &exf_errdescr, NULLNAME, ERR_ERROR, 0 );
	return( (char *)-1 );
 }

	/* For the next two conditionals use "indx" to hold the size 
	 * of the given file name plus an additional byte for the null.
	 */

 if( (indx = strlen( buf ) ) > MAXPATHLEN ) {
	report_error( &exf_errdescr, BADSIZE, ERR_ERROR, 0, buf, MAXPATHLEN );
	return( (char *)-1 );
 }

 if( *size  &&  indx > *size )  {
	report_error( &exf_errdescr, BADBUFSIZ, ERR_ERROR, 0 );
	return( (char *)-1 );
 }

 buf_size = (*size) ? *size : MAXPATHLEN + 1;

 if( (tmp = malloc( buf_size ) ) == NULL ) {
	report_error( &exf_errdescr, NOMEM, ERR_ERROR, 0 );
	return( (char *)-1 );
 }

#ifdef DEBUG
 printf("\n SHELL Expansion:\n\tBEFORE: %s", buf );
#endif

	/* "expand_shell" returns:
	 *	 0  for success
	 *      -1  for syntax error
	 *	-2  for size error
	 */

	/* Use "indx" as a temporary variable */
 tmp_size = buf_size;
 if( (indx = expand_shell( buf, &tmp_size, 0 ) ) != NULL ) return( (char *)indx );  

#ifdef DEBUG
 printf("\n\t After: %s\n", buf );
#endif
    
 if( buf[ 0 ] != '/' ) {
 	if( getcwd( tmp, buf_size ) ) {
		if( (ondx = strlen( tmp ) ) > buf_size - 2 ) {
			report_error( &exf_errdescr, BUFOVFLW, ERR_ERROR, 0 );
			goto ERR_RET;
		}
		strcat( tmp, "/" );
		ondx++;
	} else {
		report_error( &exf_errdescr, CWDERR, ERR_ERROR, 0 );
		goto ERR_RET;
	}
 } else {
	ondx=0;
 }

 for( indx=0; buf[ indx ]; indx++ ) {

	/*  Look for embedded "." or ".." and if found modify the output string as necesary.
         *  For ".." remove it and the previous directory specification.
         *      "."  remove only the dot 
	 *
	 *  Compress multiple consecutive slashes (/) into a single slash.
	 *
         *  It should be impossible for either of the two constructs to begin the imput
         *  string because of the code above that pre-pends the "CWD" if no beginning
         *  "/" is found.
	 */

	if( buf[ indx ] == '.'  &&  buf[ indx - 1 ] == '/' ) {
		register char next, backup=0;

	    	if( (next=buf[ indx + 1 ]) == '/'  ||  next == 0 ) backup = 1;
	    	else if( next == '.'  &&  (next=buf[ indx + 2 ]) == '/'  ||  next == 0 ) backup = 2;

		if( backup ) {
			indx += backup;
	                for( ; ondx ; ondx-- ) 
				if( tmp[ ondx-1 ] == '/'  &&  !(--backup) ) break;
	                if( backup ) { 
				report_error( &exf_errdescr, INVPATHSYN, ERR_ERROR, 0, buf );
				goto ERR_RET;
	        	}
			continue;
	    	}
	} else if( buf[ indx ] == '/'  &&  indx > 0  &&  buf[ indx - 1 ] == '/' ) continue;

	tmp[ ondx++ ] = buf[ indx ];
	if( ondx >= buf_size ) {
		report_error( &exf_errdescr, BUFOVFLW, ERR_ERROR, 0);
		goto ERR_RET;
        } if( ondx > MAXPATHLEN + 1 ) {
		report_error( &exf_errdescr, BADSIZE, ERR_ERROR, 0, tmp, MAXPATHLEN );
		goto ERR_RET;
	}
 }

 tmp_size = *size;
 tmp[ *size = ondx ] = 0;
 return( (tmp_size) ? (strcpy( buf, tmp ), free( tmp ), buf) : tmp );

ERR_RET:
 if( tmp ) free( tmp );
 return( (char *)-1 );
}
