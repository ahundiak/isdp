/*
	I/STRUCT
*/
#include <time.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <dirent.h>
#include "UNIXerrdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsunixdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

static char	VStimeBuffer[VS_K_TIME_BUFF_LEN],
		VSdateBuffer[VS_K_TIME_BUFF_LEN] ;
/*----------------------------------------------------------------------------*/
char *VSdate __(( void )) {
	time_t	t = time( NULL ) ;
	cftime( VSdateBuffer, "%e %B %Y", &t ) ;
	return VSdateBuffer ;
} /* VSdate */
/*----------------------------------------------------------------------------*/
char *VStime __(( void )) {
	time_t	t = time( NULL ) ;
	cftime( VStimeBuffer, "%H:%M:%S", &t ) ;
	return VStimeBuffer ;
} /* VStime */
/*----------------------------------------------------------------------------*/
FILE *VSopenFile( msg, filename, mode )

long		*msg ;
const char	*filename ;
const char	*mode  ; {

	struct stat	fstat ;
	FILE		*fp ;
	long		rc ;

	/*
	 * Opens a file in "r"(ead), "w"(rite) or "a"(ppend) mode, returning
	 * an ad hoc error message in case of error.
	 */
	fp = NULL ;

	if( stat( filename, &fstat ) == -1 ) {

		switch( errno ) {

		case ENOENT	: 
			switch( *mode ) {
				case 'r' :
					rc = UNIX_E_ENOENT	; break ;
				case 'a' :
				case 'w' :
					if( fp = fopen( filename, "w" ) ) {
						rc = MSSUCC ;
					} else {
						rc = UNIX_E_ENOTDIR ;
					}
					break ;
				default :
					rc = EMS_E_InvalidArg ; break ;
			}
			break ;
						
		case ENOTDIR	: rc = UNIX_E_ENOTDIR	; break ;
		case EPERM	: rc = UNIX_E_EPERM	; break ;
		case EACCES	: rc = UNIX_E_EACCES	; break ;
		default		: rc = MSFAIL		; break ;

		}
	} else {
		switch( *mode ) {
			case 'r' : mode = "r" ; break ;
			case 'a' : mode = "a" ; break ;
			case 'w' : mode = "w" ; break ;
			default	 : rc = EMS_E_InvalidArg ; goto wrapup ;
		}
		 if( fp = fopen( filename, mode ) ) {
			rc = MSSUCC ;
		} else {
			rc = UNIX_E_EPERM ;
		}
	}
	wrapup :
		*msg = rc ;
		return fp ;

} /* VSopenFile */
/*----------------------------------------------------------------------------*/
char *VSreadASCIIfileToBuffer( msg, filename, isASCII )

long		*msg ;
const char	*filename ;
int		*isASCII ; {

	struct stat	fstat ;
	FILE		*f	= NULL ;
	char		*buf	= NULL ;
	register char	*c ;

	*isASCII = TRUE ;

	stat( filename, &fstat ) ;

	if( !S_ISREG( fstat.st_mode ) ) {
		/*
		 * Not a regular file, hence not an ASCII one.
		 */
		*msg = EMS_E_InvalidArg ; goto wrapup ;
	}

	if( !( buf = _MALLOC( fstat.st_size + 1, char ) ) ) {
		*isASCII = FALSE ; *msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}

	if( !fstat.st_size ) {
		*buf = '\0' ;
	} else {
		int	rc ;
		char	*stop ;

		f = VSopenFile( msg, filename, "r" ) ;
		if( !( *msg & 1 ) ) goto wrapup ;

		rc = read( fileno( f ), buf, fstat.st_size ) ;
		buf[fstat.st_size] = '\0' ;
		fclose( f ) ;
		if( rc == -1 ) {
			/*
			 * Read failed for some reason.
			 */
			*msg = MSFAIL ; goto wrapup ;
		}
		/*
		 * Make sure it was an ASCII file.
		 */
		stop = buf + fstat.st_size ;
		for( c = buf ; c < stop ; c++ ) {

			if( !(     isascii( *c )
			       && ( isprint( *c ) || isspace( *c ) ) ) ) {
				*msg = EMS_E_InvalidArg ;
				*isASCII = FALSE ;

				goto wrapup ;
			}
		}
	}
	*msg = MSSUCC ;

	wrapup :
		if( !( *msg & 1 ) ) {
			_FREE( buf ) ; buf = NULL ;
		}
		return buf ;

} /* VSreadASCIIfileToBuffer */
/*----------------------------------------------------------------------------*/
typedef char FILENAME[1+FILENAME_MAX] ;
/*----------------------------------------------------------------------------*/
int VSisRegularFile( const char *pathName ) {

	struct stat	fstat ;
	return stat( pathName, &fstat ) == 0 && S_ISREG( fstat.st_mode ) ;
	
} /* VSisRegularFile */
/*----------------------------------------------------------------------------*/
int VSisASCIIFile( const char *pathName ) {

	int isASCII = FALSE ;

	if( VSisRegularFile( pathName ) ) {
		int f ;
		if( ( f = open( pathName, O_RDONLY, 0 ) ) != -1 ) {
			/* Read 1st 2000 bytes */
			char buf[2000] ;
			int n = read( f, buf, 2000 ) ;
			if( n != -1 ) {
				int i ;
				isASCII = TRUE ;
				for( i = 0 ; i < n ; i++ ) {
					if( !( isascii( buf[i] )
					       && (    isprint( buf[i] )
						    || isspace( buf[i] ) ) ) ) {
						isASCII = FALSE ; break ;
					}
				}
			}
			close( f ) ;
		}
	}
	return isASCII ;

} /* VSisASCIIFile */
/*----------------------------------------------------------------------------*/
int VSls( msg, directory, fregexp, filter, count, files )

long		*msg ;
const char	*directory ;
const char	*fregexp ;
int		*count ;
FILENAME	**files ;
int		(*filter) __(( const char *pathname )) ; {

	struct dirent	*fentry ;
	DIR		*dirp = NULL ;
	char		fname[1+MAXPATHLEN] ;
	int		fcount = 0 ;

	*count = 0 ; *files = NULL ;

	if( fregexp && !VSmatchRE( fregexp, NULL ) ) {
		/* Invalid regular expression */
		*msg = MSINARG ; goto wrapup ;
	}

	if( !( dirp = opendir( directory ) ) ) {
		*msg = UNIX_E_ENOTDIR ; goto wrapup ;
	}

	fcount = 0 ;
	while( fentry = readdir( dirp ) ) {

		/* Bypass 'hidden' files */
		if( *fentry->d_name == '.' ) continue ;

		sprintf( fname, "%s/%s", directory, fentry->d_name ) ;

		if( fregexp ) {
			if( !VSmatchRE( fregexp, fentry->d_name ) ) continue ;
		}

		if( filter( fname ) ) fcount++ ;
	}

	if( !fcount ) { *msg = MSSUCC ; goto wrapup ; }
	if( !( *files = _MALLOC( fcount, FILENAME ) ) ) {
		*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}

	rewinddir( dirp ) ;

	fcount = 0 ;
	while( fentry = readdir( dirp ) ) {
		if( *fentry->d_name == '.' ) continue ;

		sprintf( fname, "%s/%s", directory, fentry->d_name ) ;
		if( fregexp ) {
			if( !VSmatchRE( fregexp, fentry->d_name ) ) continue ;
		}

		if( filter( fname ) ) {
			strcpy( (*files)[fcount++], fentry->d_name ) ;
		}
	}

	*msg = MSSUCC ;

	wrapup :
		if( *msg & 1 ) {
			*count = fcount ;
		} else {
			*count = 0 ;
			*files = NULL ;
		} 
		if( dirp ) closedir( dirp ) ;

		return *msg & 1 ;

} /* VSls */
/*----------------------------------------------------------------------------*/
int VSlsRegFiles( msg, directory, fregexp, count, files )

long		*msg ;
const char	*directory ;
const char	*fregexp ;
int		*count ;
FILENAME	**files ; {

	return VSls( msg, directory, fregexp, VSisRegularFile, count, files ) ;
}
#if 0
int VSlsRegFiles( msg, directory, fregexp, count, files )

long		*msg ;
char		*directory,
		*fregexp ;
int		*count ;
FILENAME	**files ; {

	struct dirent	*fentry ;
	DIR		*dirp = NULL ;
	char		fname[1+MAXPATHLEN] ;
	struct stat	fstat ;
	int		fcount = 0 ;

	*count = 0 ; *files = NULL ;

	if( fregexp && !VSmatchRE( fregexp, NULL ) ) {
		*msg = MSINARG ; goto wrapup ;
	}

	if( !( dirp = opendir( directory ) ) ) {
		*msg = UNIX_E_ENOTDIR ; goto wrapup ;
	}

	fcount = 0 ;
	while( fentry = readdir( dirp ) ) {

		if( *fentry->d_name == '.' ) continue ;

		sprintf( fname, "%s/%s", directory, fentry->d_name ) ;

		stat( fname, &fstat ) ;
		if( fstat.st_mode & S_IFREG ) {
			if( fregexp ) {
				if( VSmatchRE( fregexp, fentry->d_name ) ) {
					fcount++ ;
				}
			} else fcount++ ;
		}
	}

	if( !fcount ) { *msg = MSSUCC ; goto wrapup ; }
	if( !( *files = _MALLOC( fcount, FILENAME ) ) ) {
		*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}

	rewinddir( dirp ) ;

	fcount = 0 ;
	while( fentry = readdir( dirp ) ) {
		if( *fentry->d_name == '.' ) continue ;

		sprintf( fname, "%s/%s", directory, fentry->d_name ) ;
		stat( fname, &fstat ) ;
		if( fstat.st_mode & S_IFREG ) {
			if( fregexp ) {
				if( VSmatchRE( fregexp, fentry->d_name ) ) {
					strcpy( (*files)[fcount++],
						fentry->d_name ) ;
				}
			} else strcpy( (*files)[fcount++], fentry->d_name ) ;
		}
	}

	*msg = MSSUCC ;

	wrapup :
		if( *msg & 1 ) {
			*count = fcount ;
		} else {
			*count = 0 ;
			*files = NULL ;
		} 
		if( dirp ) closedir( dirp ) ;

		return *msg & 1 ;

} /* VSlsRegFiles */
#endif
/*----------------------------------------------------------------------------*/
int VSisReadableUNIXDir( dirname ) const char *dirname ; {

	struct stat	fstat ;

	return stat( dirname, &fstat ) == 0 && S_ISDIR( fstat.st_mode ) ;

} /* VSisReadableUNIXDir */
/*----------------------------------------------------------------------------*/
#if 0 /* NOT USED */
void VSreadLine( fp, max, line, eof )

register FILE	*fp ;
int		max,
		*eof ;
register char	*line ; {

	/*
	 * Reads a line from "fp", into "line" up to "max" characters,
	 * terminating the line with "\0", and discarding further input, if
	 * any, till a newline is encountered (newline also discarded).
	 * "*eof" is TRUE if end-of-file has been reached, else FALSE.
	 */

	register int	c,
			i ;
	int		readOn ;

	*eof = FALSE ;
	for( i = 0, readOn = TRUE ; readOn ; ) {
		switch( c = getc( fp ) ) {
			case EOF  : *eof   = TRUE  ;
			case '\r' :
			case '\n' : readOn = FALSE ; break ;
			default	  : line[i++] = c ;
				    if( i == max ) {
					/*
					 * Flush rest of line.
					 */
					while(    ( c = getc( fp ) ) != '\n'
					       && c != '\r' ) {
						if( c == EOF ) {
							*eof	= TRUE  ;
							break ;
						}
					}
					readOn  = FALSE ;
				    }
				    break ;
		}
	}
	line[i] = '\0' ;

} /* VSreadLine */
#endif
/*----------------------------------------------------------------------------*/

