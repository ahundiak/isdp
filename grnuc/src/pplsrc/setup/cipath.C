/*
 * get the good file name for CI
 * Etienne BEEKER
 * Dominique GARDELLA	( FRANCE )
 * NOV 87
 */

#	include "OMminimum.h"
#	include "igrtypedef.h"
#	include "igetypedef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "exmacros.h"
#	include "msdef.h"
#	include "msmacros.h"
#	include "cimsg.h"
#	include <string.h>
#	include <stdio.h>
#	include <unistd.h>
#	include <sys/param.h>
#	include <sys/types.h>
#	include <sys/stat.h>
#	include "cidef.h"
#	include "cisetup.h"
/*----------------------------------------------------------------------*/
int CIgetname(filename, expanded_name)
char *filename, *expanded_name;
/*
 * gets the name of the file to be read
 * result is in expanded_name which must be allocated
 * filename and expanded_name can be the same variable
 */
{
#ifdef DEBUG
printf("getname pour %s\n",filename);
#endif
	strcpy(expanded_name, filename);

	/* if suffix ".u" not given, add it */
	if( !ends_with_dot_u(expanded_name) )
	{
		strcat(expanded_name,".u");
	}

	if( !CIfind_path(expanded_name) )
		return 0;
#ifdef DEBUG
printf("getname apres CIfind_path, expanded_name = %s\n",expanded_name);
#endif
	/* at this stage, if expanded_name ends with .e, do nothing */
	/* cannot compare with a .u file */
	if( ends_with_dot_u(expanded_name) ){
		UNIXpath execfile ;
		
		/* compare the dates of eventual execfile and expanded_name */
		strcpy( execfile, expanded_name ) ;
		execfile[strlen(execfile)-1] = 'e';
 		if( is_more_recent(  execfile, expanded_name) )
			expanded_name[strlen(expanded_name)-1] = 'e';
	} 
#ifdef DEBUG
printf("getname exiting, expanded_name = %s\n",expanded_name);
#endif
	return 1;
}

/*----------------------------------------------------------------------------*/
int CIfind_path( src_file )

char *src_file ;			/* (path) name of the source file */

/*
 * 1. - Look into ".".
 * 2. - Look into user paths.
 * 3. - Look into all "ppl/bin" directories in product.
 * `src_file' is updated with the full path name with extension changed from
 * ".u" to ".e" if "<src_file>.e" exists ( by `CIaccess' ).
 * RETURNS: TRUE if file found else FALSE.
 */
{
    char	usr_paths[1+CIPATHLEN] ;/* User paths			    */
    UNIXpath	expnd_path	,	/* User path expanded		    */
    		expnd_file	,	/* `src_file' expanded		    */
		rel_path	,	/* Relative path ppl/bin/<src_file> */
		abs_path	;	/* Absolute path for above	    */
    int		i, rc		;	/* Mere index and return code	    */
    char	*dirs[10]	;	/* Component dirs of CIsrc_path	    */

/* -- Expand shell variables if any...
   -- */
   CIexpand( src_file, expnd_file, 1 + CI_PATH_MAX ) ;
   strcpy( src_file, expnd_file ) ;

/* -- Absolute path ?
   -- */
   if( src_file[0] == '/' ) return CIaccess( src_file ) ;

/* --	1. Try ".".
   -- */
   if( CIaccess( src_file ) ) return TRUE ;

/* --	2. User paths.
   -- */
   strcpy( usr_paths, CIsrc_path )	;
   CIsplit_path( usr_paths, dirs, 10 )	;

   for( i = 0 ; dirs[i] != NULL ; i++ ) {

	CIexpand( dirs[i], expnd_path, 1 + CI_PATH_MAX )	;
   	strcat( strcat( expnd_path, "/" ), expnd_file )	;
   	if( CIaccess( expnd_path ) ) {
		strcpy( src_file, expnd_path ) ;
		rc = TRUE	;
		goto wrapup	;
   	}
   }

/* --	3. Product's paths.
   -- */
   sprintf( rel_path, "%s/%s", CI_SYS_SRC_DIR, expnd_file ) ;
   for( i = 0 ;; i++ ) {
#ifdef DEBUG
  printf( "CIfind_path: path %d rel <%s>\n", i, rel_path ) ; fflush( stdout ) ;
#endif
   	if( ex$get_path(	index	= i		,
   				path	= abs_path	,
   				len	= 1 + CI_PATH_MAX	) ) {
   		strcat( abs_path, rel_path ) ;
   		if( CIaccess( abs_path ) ) {
   			strcpy( src_file, abs_path ) ;
			rc = TRUE	;
			goto wrapup	;
   		}
   	} else break ;
   }

   rc = FALSE ;
   wrapup :
#ifdef DEBUG
  printf( "CIfind_path: file <%s>, rc = %d\n", src_file, rc ) ; fflush( stdout ) ;
#endif
   return rc ;

} /* CIfind_path */
/*----------------------------------------------------------------------------*/
int ends_with_dot_u(filename)
char *filename;
{
	int len;
	
	len = strlen( filename );
	if (  filename[len-1] != 'u' )
		return 0;
	if (  filename[len-2] != '.' )
		return 0;
	return 1;
}
/*----------------------------------------------------------------------------*/
int ends_with_dot_e(filename)
char *filename;
{
	int len;
	
	len = strlen( filename );
	if (  filename[len-1] != 'e' )
		return 0;
	if (  filename[len-2] != '.' )
		return 0;
	return 1;
}
/*----------------------------------------------------------------------------*/
int CIaccess(filename)
char *filename;
/*
 * looks if *.u is accessible
 * else looks if *.e is accessible
 * in this case changes the file name ended with .e
 */
{
    if ( access(filename, R_OK ) == 0 )
	return 1;
    filename[strlen(filename) - 1] = 'e';
    if ( access(filename, R_OK ) == 0 )
	return 1;
	
    /* restore original filename */
    filename[strlen(filename) - 1] = 'u';
    return 0;
}
/*----------------------------------------------------------------------------*/
int is_more_recent( f1, f2 )
char *f1, *f2;
/*
 * returns 1 if f1 is more recent than f2, 
 * 0 otherwise
 */
{
	struct stat	statbuf;	/* Buffer used by 'stat'*/
	time_t		mtime;		/* Modification time	*/
		
	if ( !stat(f1, &statbuf) ){
		mtime = statbuf.st_mtime;
		if ( !stat(f2, &statbuf) )
		    if ( mtime > statbuf.st_mtime )
			return 1;
	}
	return 0;
}
/*----------------------------------------------------------------------------*/
int give_path( src_file )

char *src_file ;			/* jla's using this one */
{ return CIfind_path( src_file ) ; }
