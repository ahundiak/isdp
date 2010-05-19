/*
	I/VDS	Copy
*/
#include <stdio.h>
#ifndef _LIMITS_H
#	include <limits.h>
#endif
#ifndef _STRING_H
#	include <string.h>
#endif
#ifndef _STDLIB_H
#	include <stdlib.h>
#endif
#ifndef _SYS_TYPES_H
#	include <sys/types.h>
#endif
#ifndef _SYS_STAT_H
#	include <sys/stat.h>
#endif
#ifndef  _SYS_PARAM_H
#	include <sys/param.h>
#endif

#include "UNIXerrdef.h"
#include "msdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*----------------------------------------------------------------------------*/
int VD_findDirsInPath( msg, relPath, count, absPaths )

long		*msg ;
const char	*relPath ;
int		*count ;
char		**absPaths ; {

	int	i,
		size ;
	char	dir[1+MAXPATHLEN] ;

	*msg = MSSUCC ; *count = 0 ; *absPaths = 0 ;

	for( i = size = 0 ; ; i++ ) {
	  	if( !ex$get_path(	index	= i,
	  				path	= dir,
	  			 	len	= sizeof( dir ) )
	  	    || !*dir ) {
	  	    	break ;
	  	}
	  	strcat( dir, relPath ) ;
	  	if( VD_isReadableUNIXDir( dir ) ) {
	  		size += 1 + strlen( dir ) ;
		}
	}

	if( !size ) goto wrapup ;

	if( !( *absPaths = _MALLOC( size, char ) ) ) {
		*msg = EMS_E_NoDynamicMemory ;
	}
	for( i = size = 0 ; ; i++ ) {
	  	if( !ex$get_path(	index	= i,
	  				path	= dir,
	  			 	len	= sizeof( dir ) )
	  	    || !*dir ) {
	  	    	break ;
	  	}
	  	strcat( dir, relPath ) ;
	  	if( VD_isReadableUNIXDir( dir ) ) {
	  		strcpy( *absPaths + size, dir ) ;

	  		size += 1 + strlen( dir ) ;
	  		(*count)++ ;
	  	}
	}

	wrapup :
		return *msg & 1 ;

} /* VD_findDirsInPath */
/*----------------------------------------------------------------------------*/
int VD_findFileInPath( msg, relName, absName )

long		*msg ;
const char	relName[1+MAXPATHLEN] ;
char		absName[1+MAXPATHLEN] ; {

	int		i ;
	char		dir[1+MAXPATHLEN] ;
	struct stat	buffer ;

	*msg		= UNIX_E_ENOENT ;
	*absName	= '\0' ;

	for( i = 0 ; ; i++ ) {
	  	if( !ex$get_path(	index	= i,
	  				path	= dir,
	  			 	len	= sizeof( dir ) )
	  	    || !*dir ) {
	  	    	break ;
	  	}
	  	strcat( dir, relName ) ;
		if( stat( dir, &buffer ) == 0 && S_ISREG( buffer.st_mode ) ) {
			/*
			 * Found it !
			 */
			strcpy( absName, dir ) ;
			*msg = MSSUCC ;
			break ;
		}
	}

	return *msg & 1 ;

} /* VD_findFileInPath */
/*----------------------------------------------------------------------------*/
int VD_findFileInPwdOrPath( msg, relName, absName )

long		*msg ;
const char	relName[1+MAXPATHLEN] ;
char		absName[1+MAXPATHLEN] ; {

	const char	*p ;
	char		inPwd[1+MAXPATHLEN] ;
	struct stat	buffer ;

	strcpy( inPwd, "./" ) ;

	if( p = strrchr( relName, '/' ) )	p++ ;
	else					p = relName ;
	
	strcpy( inPwd + 2, p ) ;

	if( stat( inPwd, &buffer ) == 0 && S_ISREG( buffer.st_mode ) ) {
		/*
		 * Found it !
		 */
		strcpy( absName, inPwd ) ;
		*msg = MSSUCC ;
	} else {
		VD_findFileInPath( msg, relName, absName ) ;
	}

	return *msg & 1 ;

} /* VD_findFileInPwdOrPath */
/*----------------------------------------------------------------------------*/
int VD_findFileInDirOrProductPaths(	msg,
					fileToFind,
					dirToSearchFirst,
					dirInProdPathToSearchThen,
					absPathName )

long		*msg ;
const char	fileToFind			[1+MAXPATHLEN] ;
const char	dirToSearchFirst		[1+MAXPATHLEN] ;
const char	dirInProdPathToSearchThen	[1+MAXPATHLEN] ;
char		absPathName			[1+MAXPATHLEN] ; {

	/*
	 * Finds the absolute pathname of 'fileToFind' (which maybe a pathname)
	 * by searching first in 'dirToSearchFirst' and then in
	 * the sub-directories 'dirInProdPathToSearchThen' in the product
	 * paths. For instance, if fileToFind = "a/b/F",
	 * dirToSearchFirst = "." and dirInProdPathToSearchThen = "config/d",
	 * then the following files will be looked for:
	 * 1 "./a/b/F"
	 * 2 "<user-path>/config/d/a/b/F"
	 * 3 "<struct>/config/d/a/b/F"
	 * 4 "<vds>/config/d/a/b/F"
	 * etc.
	 * If 'fileToFind' contains an absolute pathname then it is not
	 * looked for in other directories.
	 */
	struct stat fs ;

	*msg		= MSFAIL ;
	*absPathName	= '\0' ;
	
	if( *fileToFind == '/' ) {

		if(    stat( fileToFind, &fs ) == 0
		    && S_ISREG( fs.st_mode ) ) {
			strcpy( absPathName, fileToFind ) ;
			*msg = MSSUCC ;
		}
	} else {
		char try[1+MAXPATHLEN] ;

		sprintf( try, "%s/%s", dirToSearchFirst, fileToFind ) ;

		if(    stat( try, &fs ) == 0 && S_ISREG( fs.st_mode ) ) {
			strcpy( absPathName, try ) ;
			*msg = MSSUCC ;
		} else {
			sprintf( try, "%s/%s",	dirInProdPathToSearchThen,
						fileToFind ) ;
			VD_findFileInPath( msg, try, absPathName ) ;
		}
	}

	return *msg & 1 ;

} /* VD_findFileInDirOrProductPaths */
/*----------------------------------------------------------------------------*/

