/* $Id: VSrdbCache.C,v 1.1.1.1 2001/01/04 21:10:30 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmdsup/VDrdbCache.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSrdbCache.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/11/02  17:21:34  pinnacle
 * Cache Fixes
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/02/97  ah      added header
 *                        Cache was having a problem when the part name
 *                        contained blanks, fixed this and made the cache
 *                        persistant.  Added VS_NO_LOGIN_CHECK=1 env var
 ***************************************************************************/

#ifdef ENV5
#include <stdarg.h>
#elif defined(X11)
#include "standards.h"
#include "varargs.h"
#include "stdarg.h"
#endif

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
/*
//#include "OMprimindex.h"
*/
#include "OMprimitives.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "GRtypedef.h"
#include "GRprims.h"
#include "igrtypedef.h"
#include "gr.h"
#include "DImacros.h"
#include "expression.h"
#include "expmacros.h"
#include "exmacros.h"

#include "vsdirdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsexpvalue.h"
extern OMuword	OPP_expression_class_id,
		OPP_DIrectory_class_id ;

/* ------------------------
 * Target directory for cache
 */
int VSrdbGetDir(char *path) 
{
  struct GRid dirId;

  ex$get_cur_mod(osnum = &dirId.osnum);

  di$give_pathname(
    osnum    = dirId.osnum,
    pathname = path
  );

  di$strcat(
    to    = path,
    from  = "structRDB"
  );

  return 1;
}

/*----------------------------------------------------------------------------*/
/*
Function VSrdbIsCache

Abstract
	Tests that the RDB cache exists.
Arguments
	none
Sample Usage

	if( VSrdbIsCache() ) {
		...
	}

*/
int VSrdbIsCache() {

  int    retFlag = 0;
  long   sts;
  char   path[DI_PATH_MAX] ;
  struct GRid dirId;

  sts = VSrdbGetDir(path);
  if (!(sts & 1)) goto wrapup;

  sts = di$translate(	
    objname = path,
    p_objid = &dirId.objid
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
} /* VSrdbIsCache */

/*----------------------------------------------------------------------------*/
/*
Function VSrdbCacheMkpath

Abstract
	Creates a directory path in the RDB cache ( a sub-directory
	of ":transient:struct" ).
Arguments
	IN	char	*name1		First name.
	IN	char	*name2		Second name.
	...
	IN	char	*nameN		N-th name.
	IN		NULL		End-of-name-list marker.
Sample Usage
	To create path "steel:beam:type1" :

	long	sts ;

	sts = VSrdbCacheMkpath( "steel","beam", "type1", NULL ) ;

	if( sts & 1 ) {
		...
*/
long VSrdbCacheMkpath( va_alist ) va_dcl {

  va_list args;
  char	 *dirs[20];
  char    path[DI_PATH_MAX];
  int	  i,sts;
  int     count = 0;

  int retFlag = 0;

  va_start( args, 0 ) ;
    while( ( dirs[count++] = va_arg( args, char * ) ) != NULL ) ;
    count--;
  va_end( args ) ;

  sts = VSrdbGetDir(path);
  if (!(sts & 1)) goto wrapup;

  for( i = 0 ; i < count; i++ ) {
    DIstrcat( path, dirs[i] ) ;
  }
  DIstrcat( path, "" ) ;

  sts = di$mkpath( pathname = path ) ;

  // printf("Made Path '%s'\n",path);

  retFlag = 1;

wrapup:
  return retFlag;

} /* VSrdbCacheMkpath */
/*----------------------------------------------------------------------------*/
/*
Function VSrdbCacheLs

Abstract
	Lists the entries of a directory in the RDB cache ( a sub-directory
	of ":transient:struct" ).
Arguments
	IN	char	*name1		First name.
	IN	char	*name2		Second name.
	...
	IN	char	*nameN		N-th name.
	IN		NULL		End-of-name-list marker.
	IN	int	*count		Count of entries.
	IN	char	***lines	List of entries (memory allocated to
					be released with "di$free".
Sample Usage
	To list "steel:beam:type1" :

	long	sts ;
	int	count ;
	char	**line ;

	sts = VSrdbCacheLs( "steel","beam", "type1", NULL, &count, &lines ) ;
	if( sts & 1 ) {
		...
*/
long VSrdbCacheLs( va_alist ) va_dcl {

  va_list args ;
  char	 *dirs[20];
  char    path[DI_PATH_MAX];
  int     i,sts;
  int     retFlag = 0;
  int     count = 0 ;

  int   *p_count,cnt ;
  char  ***p_lines,**lines;

  char  buffer[DI_PATH_MAX];
  char *basename;

  va_start( args, 0 ) ;
    while( ( dirs[count++] = va_arg( args, char * ) ) != NULL ) ;
    count-- ;

  sts = VSrdbGetDir(path);
  if (!(sts & 1)) goto wrapup;

  for( i = 0 ; i < count ; i++ ) {
    DIstrcat( path, dirs[i] ) ;
  }
  DIstrcat( path, "*" ) ;

  p_count = va_arg( args, int *	 ) ;
  p_lines = va_arg( args, char *** ) ;

  sts = di$ls(
    ptr     = &cnt,
    lines   = &lines,
    regexp  =  path,
    options = 0 
  ) ;
  if (!(sts & 1)) goto wrapup;
			
  for( i = 0 ; i < cnt ; i++ ) {
    strcpy( buffer, lines[i] ) ;
    basename = strrchr(buffer,DIR_G_car_dir );
    if (basename) strcpy( lines[i], basename + 1 ) ;
//  printf("Line %d '%s'\n",i,basename+1);
  }
  *p_count = cnt;
  *p_lines = lines;

  va_end( args ) ;
  retFlag = 1;

wrapup:
  return retFlag;

} /* VSrdbCacheLs */
/*----------------------------------------------------------------------------*/
/*
Function VSrdbCachePutValue

Abstract
	Puts a value in a directory of the RDB cache ( a sub-directory
	of ":transient:struct" ).
Arguments
	IN	char	*name1		First name.
	IN	char	*name2		Second name.
	...
	IN	char	*nameN		N-th name.
	IN		NULL		End-of-name-list marker.
	IN	double	*p_value	Value to store.
Sample Usage
	To put "value" in "steel:plate:type1:8/10" :

	long	sts ;
	double	value ;

	sts = VSrdbCachePutValue( "steel","beam", "type1", NULL, &value ) ;

	if( sts & 1 ) {
		...
Note
	There may be only ONE value per directory.
*/
long VSrdbCachePutValue( va_alist ) va_dcl {

  va_list args ;
  char	 *dirs[20];
  char    path[DI_PATH_MAX];
  char    pwd [DI_PATH_MAX];
  char   *name;

  int   i,sts;
  int   count = 0 ;
  int   retFlag = 0;

  double *p_value;
  struct GRid expId;

  va_start( args, 0 ) ;
    while( ( dirs[count++] = va_arg( args, char * ) ) != NULL ) ;
    count-- ;

  sts = VSrdbGetDir(path);
  if (!(sts & 1)) goto wrapup;

  for( i = 0 ; i < count; i++ ) {
    DIstrcat( path, dirs[i] ) ;
  }
  strcat(path,":");

  name    = va_arg(args, char *);
  p_value = va_arg(args, double *) ;

/*
  expId.objid = NULL_OBJID;

  sts = di$translate(
    objname = path,
    p_objid = &expId.objid
  );

  // if (expId.objid != NULL_OBJID) goto wrapup;
*/			
 
  // printf("Exp %d '%s' %f\n",expId.osnum,name,*p_value);

  di$pwd(dirname = pwd );
  di$cd (dirname = path);

  expId.objid = NULL_OBJID;
  ex$get_cur_mod(osnum = &expId.osnum);
  VD_createExp(name,*p_value,expId.osnum,&expId.objid);

  di$cd(dirname = pwd);

  retFlag = 1;

wrapup:
  return retFlag;

} /* VSrdbCachePutValue */

/*----------------------------------------------------------------------------*/
/*
Function VSrdbCacheGetValue

Abstract
	Gets a value from a directory of the RDB cache ( a sub-directory
	of ":transient:struct" ).
Arguments
	IN	char	*name1		First name.
	IN	char	*name2		Second name.
	...
	IN	char	*nameN		N-th name.
	IN		NULL		End-of-name-list marker.
	OUT	double	*p_value	Value to obtain.
Sample Usage
	To get "value" in "steel:plate:type1:8/10" :

	long	sts ;
	double	value ;

	sts = VSrdbCacheGetValue( "steel","beam", "type1", NULL, &value ) ;

	if( sts & 1 ) {
		...
*/
long VSrdbCacheGetValue( va_alist ) va_dcl {

  va_list  args ;
  char	  *dirs[20];

  char	  path[DI_PATH_MAX] ;
  char   *name;

  int	  i,sts;
  int     count = 0 ;

  int retFlag = 0;

  double  *p_value;

  struct GRid expId;

  va_start( args, 0 ) ;

  while( ( dirs[count++] = va_arg( args, char * ) ) != NULL ) ;
  count-- ;

  sts = VSrdbGetDir(path);
  if (!(sts & 1)) goto wrapup;

  for( i = 0 ; i < count; i++ ) {
    sts = DIstrcat( path, dirs[i] ) ;
  }
  name    = va_arg(args, char *);
  p_value = va_arg(args, double *) ;

  DIstrcat( path, name) ;

  expId.objid = NULL_OBJID;

  di$translate(	
    objname = path,
    p_objid = &expId.objid,
    p_osnum = &expId.osnum
  ) ;
  
  if (expId.objid == NULL_OBJID) goto wrapup;

  VSexpValue( expId.objid, expId.osnum, p_value ) ;

  retFlag = 1;

wrapup:

  return retFlag;

} /* VSrdbCacheGetValue */
/*----------------------------------------------------------------------------*/
long VSrdbDelCache() {

	long		sts ;			/* DI return code	*/
	char		startDir[DI_PATH_MAX] ;	/* FIND's start dir.	*/
	DIgrid		*entries ;		/* Entries' ids		*/
	char		**lines ;		/* Entries' names	*/
	int		i,			/* Loop-on-entries index*/
			count ;			/* Count of entries	*/
	OMuword		classid ;		/* Of one entry		*/

	entries = NULL ; lines = NULL ; count = 0 ;
/*
	di$give_pathname(	osnum	= OM_Gw_TransOSnum_0,
				pathname= startDir ) ;

	di$strcat(	to	= startDir,
			from	= VS_K_STRUCTtransDir ) ;
*/
	VSrdbGetDir(startDir);

	sts = di$find(	start_dir	= startDir,
			grids		= &entries,
			ptr		= &count,
			lines		= &lines,
			options		= 0 ) ;

	if( sts == DIR_W_NAME_NOT_FOUND ) {
		/*
		 * No cache.
		 */
		return DIR_S_SUCCESS ;
	}

	/*
	 * We may be going to delete the CWD, so CD to a directory which will
	 * not be deleted, eg. "startDir".
	 */
	di$cd( dirname = startDir ) ;

	for( i = count - 1 ; i >= 0 ; i-- ) {

		om$get_classid(	objid		= entries[i].objid,
				osnum		= entries[i].osnum,
				p_classid	= &classid ) ;

		if( om$is_ancestry_valid(
				superclassid	= OPP_expression_class_id,
				subclassid	= classid ) == OM_S_SUCCESS ) {

			sts = di$rm_name(	regexp	= lines[i] ) ;
			if( !( sts & 1 ) ) {
				di$report_error( sts = sts ) ;
			}

			sts = exp$delete(	exp_id	= entries[i].objid,
						osnum	= entries[i].osnum,
						p_md_env= NULL ) ;

		} else if( om$is_ancestry_valid(
				superclassid	= OPP_DIrectory_class_id,
				subclassid	= classid ) == OM_S_SUCCESS ) {

			sts = di$rmdir( dirname = lines[i] ) ;

		}
	}

	/*
	 * Now CD back to the previous CWD, if di$cd fails, it means that
	 * the previous CWD has been removed, then just keep sitting where you
	 * are.
	 */
	di$cd( dirname = "-" ) ;

	if( count ) {
		if( lines ) di$free( lines = lines, count = count ) ;
		if( entries ) free( entries ) ;
	}

	return sts ;

} /* VSrdbDelCache */
/*----------------------------------------------------------------------------*/
