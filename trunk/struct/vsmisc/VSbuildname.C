/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "msdef.h"
#include "vsnamemacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"

/*
Function VSbuildName

Abstract
	Given a directory name and a pattern ( consisting of an alpha string
	terminated by an integer, e.g. "abcde43" ), finds the next available
	name in the directory. The pattern may not end with an integer ( e.g.
	"abc" ).

Arguments
	IN	long	*msg		Completion code.
	IN	char	*directory	Directory wherein to find name.
	IN	char	*pattern	The input pattern.
	OUT	char	*name		The found name (it is a base name,
					not a full path name). Must have size
					at least equal to DI_PATH_MAX.
*/
/*----------------------------------------------------------------------------*/
static char *VSincreaseName( name ) char *name ; {

	char	*p, *end ;
	int	i, l ;

	l = strlen( name ) ; p = end = name + l - 1 ;
	while( p >= name ) {
		if( isdigit( *p ) ) p-- ;
		else break ;
	}
	if( p < end ) {
		p++ ;
		i = atoi( p ) + 1 ;
		sprintf( p, "%d", i ) ;
	} else {
		/*
		 * Does not end with a number.
		 */
		*(end + 1) = '1' 	;
		*(end + 2) = '\0'	;
	}
	return name ;

} /* VSincreaseName */
/*----------------------------------------------------------------------------*/
long VSbuildName( msg, directory, pattern, name )

long	*msg ;
char	*directory,
	*pattern,
	*name ; {

	char		template[DI_PATH_MAX],
			attempt[DI_PATH_MAX] ;
	OM_S_OBJID	objid ;
	OMuword		osnum ;
	int		firstTime = TRUE ;

	strcpy( template, pattern ) ;

	*name = '\0' ;

	while( TRUE ) {
		if( firstTime ) {
			firstTime = FALSE ;
			*msg = DIstmcpy(	attempt,
						directory,
						template,
						NULL ) ;
		} else {
			*msg = DIstmcpy(	attempt,
						directory,
						VSincreaseName( template ),
						NULL ) ;
		}
		if( !( *msg & 1 ) ) goto wrapup ;

		*msg = di$translate(	objname	= attempt,
					p_objid	= &objid,
					p_osnum	= &osnum ) ;
		switch( *msg ) {
			case DIR_S_SUCCESS :
				/*
				 * Name already in use, go on searching.
				 */
				 break ;
			case DIR_W_NAME_NOT_FOUND :
				/*
				 * Name not used, exit.
				 */
				*msg = MSSUCC ;
				strcpy( name, template ) ;

			default :
				/*
				 * Problem, exit.
				 */
				 goto wrapup ;
		}
	}
	wrapup :
	return *msg & 1 ;

} /* VSbuildName */
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) short: here
   templateOS causes it to choke...
 */
void VSbuildNameInSameDirIfPossible(	OMuword	actModOs,
					OMuword	templateOS,
					char	*templateName,
					char	*cwd,
					char	*newName )
#else
void VSbuildNameInSameDirIfPossible( actModOs, templateOS, templateName, cwd,
					newName )
OMuword	actModOs,
	templateOS ;
char	*templateName,
	*cwd,
	*newName ;
#endif

{

	long		msg ;
	char		basename[DI_PATH_MAX],
			*p ;
	OM_S_OBJID	objid ;
	OMuword		osnum ;

	p = strrchr( templateName, DIR_G_car_dir ) ;

	/*
	 * Sometimes an object in the active file uses the name of the
	 * parent it consumes which is in a reference file ...
	 */
	msg = di$translate(	objname	= templateName,
				p_objid	= &objid,
				p_osnum	= &osnum ) ;
	if( msg & 1 ) {
		if( osnum != templateOS ) templateOS = osnum ;
	}

	if( actModOs == templateOS ) {
		*p = '\0' ;
		VSbuildName( &msg, templateName, p + 1, basename ) ;
		DIstmcpy( newName, templateName, basename, NULL ) ;
		*p = DIR_G_car_dir ;
	} else if( cwd ) {
		int	writable ;

		vs$isDirUsable(	dirname	= cwd,
				writable= &writable ) ;
		if( writable ) {
			p++ ;
			VSbuildName( &msg, cwd, p, basename ) ;
			DIstmcpy( newName, cwd, basename, NULL ) ;
		} else {
			*newName = '\0' ;
		}
	} else {
		/*
		 * No directory given in which to build new name: create
		 * a path in thi object space replicating that of the
		 * template pathname: if the template pathname is
		 *        :<active-file>:ref:<ref-file>:usr:a:b
		 *        1             2   3          4
		 * then create
		 *       :<active-file>:usr:a:b
		 * if it does not already exist.
		 */
		char newDir[DI_PATH_MAX] ;
		char OsPath[DI_PATH_MAX] ;
		char save = *(p+1) ;
		char   *q = templateName + 1 ;               /* Skip 1st ':' */

		*(p+1) = '\0' ; /* Must keep a ':' at the end for mkpath */

		q = strchr( q    , DIR_G_car_dir ) ;	     /* Skip 2nd ':' */
		*q = '\0' ;
		strcpy( newDir, templateName ) ;	     /* Act file name*/
		strcpy( OsPath, newDir ) ;
		*q =  DIR_G_car_dir ;
		if( q ) q = strchr( q + 1, DIR_G_car_dir ) ; /* Skip 3rd ':' */
		if( q ) q = strchr( q + 1, DIR_G_car_dir ) ; /* Get  4th ':' */
		strcat( newDir, q ) ;
		msg = di$mkpath( pathname = newDir ) ;
		*(p+1) = save ;

		{
		  char *destDir ;
		  if( !( msg & 1 ) && msg != DIR_E_DIR_DUP ) {
			di$report_error( sts = msg ) ;
			/*
			 * Well do it in :<active-file>:usr ...
			 */
			strcat( OsPath, ":usr" ) ;
			destDir = OsPath ;
		  } else {
		  	destDir = newDir ;
		  }
		  VSbuildName( &msg, destDir, p + 1, basename ) ;
		  /*
		   * Avoid similar names, even if in different directories.
		   */
		  if( !strcmp( p + 1, basename ) ) {
		  	char	newTemplate[DI_PATH_MAX] ;
		  	sprintf( newTemplate, "%s_1", p + 1 ) ;
		  	VSbuildName( &msg, destDir, newTemplate, basename ) ;
		  }
		}
		DIstmcpy( newName, newDir, basename, NULL ) ;
	}

} /* VSbuildNameInSameDirIfPossible */
/*----------------------------------------------------------------------------*/

