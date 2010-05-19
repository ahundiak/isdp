/* $Id: VDfiles.C,v 1.2 2002/03/29 22:55:41 ad Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbin/VDfiles.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDfiles.C,v $
 *	Revision 1.2  2002/03/29 22:55:41  ad
 *	Change the SUNOS into SUNOS5
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/11/04  20:37:40  pinnacle
 * moved from vdbin
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/11/03  17:16:06  pinnacle
 * Created: ./vdbin/VDfiles.C by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/03/95	adz		creation date
 *
 ***************************************************************************/

#include "exsysdep.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <OMerrordef.h>
#include <UNIXerrdef.h>
#include <sys/types.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/param.h>

#include <errno.h>
#include <sys/stat.h>
#include <OMOSfilehdr.h>
#include <expriv.h>

#ifdef BIG_ENDIAN
#include <exsysdep.h>
#endif


#ifdef BIG_ENDIAN
#define MYMAGIC 0x4f4d
#else
#define MYMAGIC 0x4d4f
#endif
#if defined (CLIX)
#define NAME_SIZE       16
#else
#define NAME_SIZE	OM_K_MAXOSNAME_LEN
#endif

extern char *VD_prGetPWD( char *, int );


typedef  char  ENTRY[NAME_SIZE];

void	VD_prHeader(){

printf("Filename       Product   Sys       Node      Objects   Last Saved \n");
printf("--------       -------   ---       ----      -------   ---------- \n");
}

void	VD_prLine( char *name , struct OM_sd_OS_filehdr_OM *buf ){

	int		i, j, len ;
	char		out[1024];
	char		tmp[1024];

	for( i=0; i<1023; i++) out[i] = ' ';

	len = strlen(name );

/*
 * LINE          18        28      36       46      56
Filename         Product   Sys     Node     Size    Saved
 */
	
	/*
	 * Print name.
	 */
	j=0;
	for( i=0  ; i<len; i++ ) out[j++] = name[i] ;
	for( i=len; i<15 ; i++ ) out[j++] = ' ';

	/*
	 * Add the product.
	 */
	len = strlen( buf->image_name );
	for( i=0  ; i<len; i++ ) out[j++] = buf->image_name[i] ;
	for( i=len; i<10 ; i++ ) out[j++] = ' ';

	len = strlen( buf->syst.mach_name.sysname );
	for( i=0  ; i<len; i++ ) out[j++] = buf->syst.mach_name.sysname[i] ;
	for( i=len; i<10 ; i++ ) out[j++] = ' ';

	len = strlen( buf->syst.mach_name.nodename );
	for( i=0  ; i<len; i++ ) out[j++] = buf->syst.mach_name.nodename[i] ;
	for( i=len; i<10 ; i++ ) out[j++] = ' ';

	/*
	 * Add the Number of Active Objects.
	 */
	sprintf( tmp, "%d", buf->i_num_objs );
	len = strlen( tmp );
	for( i=0  ; i<len; i++ ) out[j++] = tmp[i] ;
	for( i=len; i<10 ; i++ ) out[j++] = ' ';

	/*
	 * Add the Date Information.
	 *	FORMAT:	Sat Sep 23 11:22:33 1995
	 *	           (4)             (20)
	 */
	for( i=0  ; i<12 ; i++ ) out[j++] = buf->stop_time[4+i] ;
	for( i=0  ; i<2  ; i++ ) out[j++] = ' ' ;
	for( i=0  ; i<4  ; i++ ) out[j++] = buf->stop_time[20+i ] ;

	out[j] = '\0';

	printf("%s\n", out );
}

char *VD_prGetPWD( buf, size )
char *buf;
int size;
{

 if( buf  ||  ( buf = (char *)malloc( size ) ) ) {
#ifndef NT
    register int ret_status,child;
    int fildes[2];

    if( pipe( fildes ) == 0 ) {
#if defined(CLIX) || defined(SUNOS5)
        if( child = vfork() ) {
#elif defined(IRIX)
        if( child = fork() ) {
#else
#error OS not defined
#endif
            if( child != -1 ) {
                do {
                   ret_status = read( fildes[0], buf, size );   /* read pipe */
                } while ( ret_status == -1  &&  errno == EINTR );

                close( fildes[0] );                     /* close input pipe */
                close( fildes[1] );                     /* close output pipe */
                waitpid( child, 0, 0 );         /* cleanup child */
                if( ret_status != -1 ) {

                        /* eliminate NULL placed on end by "pwd" */

                    if( ret_status < size ) buf[ ret_status - 1 ] = '\0';

                    return( buf );

                 }

        }

        } else {


            /* Don't use fclose because of having used "vfork".  Since the
             * process is not actually copied the use of fclose would wind
             * up corrupting the data structures representing the stream
             * in the parent.
             */

            close( fileno(stdout) );    /* close standard out   */
            dup( fildes[1] );           /* dup O/P pipe into stdout slot */
            close( fildes[1] );         /* close output pipe */

            execlp( "pwd", "pwd", (char *)0 );
        }
    }
#else
    return _getcwd( buf, size );
#endif
 }
 return( (char *)NULL );
}



main( int argc , char *argv[] ){

	FILE				*f = NULL ;
	struct OM_sd_OS_filehdr_OM	buffer ;
	int				i, status ;
	char				cwd[MAXPATHLEN];
	struct	dirent			*dent = NULL ;
	DIR				*pdir = NULL ;

	VD_prHeader();

	if( argc < 2 ){
	  /*
	   * Get all files from current directory.
	   */
	  status = (int) VD_prGetPWD( cwd, MAXPATHLEN );
  	  if( ! status ){  return 0 ; }

	  pdir	= (DIR *) opendir( cwd );
	  if( ! pdir ){ return 0 ; }

	  rewinddir( pdir );
	  dent = readdir( pdir );		/* Read "." entry, discarf */

	  while( dent = readdir( pdir )){
	    f = (FILE *) fopen ( dent->d_name, "r" );
            if( f ){
		status =
		fread( &buffer, (sizeof(struct OM_sd_OS_filehdr_OM )) , 1, f);
                if( buffer.magic == MYMAGIC ){
		  VD_prLine( dent->d_name, &buffer );
		} /* IF MYMAGIC */
                fclose( f );
	    } /* if ( f ) */
	  } /* while ... */

	  printf("\n");
	  return 0 ;
	}
	else{
	  for( i=1; i<argc; i++ ){
	    f = (FILE *) fopen ( argv[i], "r" );
            if( f ){
		status =
		fread( &buffer, (sizeof(struct OM_sd_OS_filehdr_OM )) , 1, f);
                if( buffer.magic == MYMAGIC ){
		  VD_prLine( argv[i], &buffer );
                }
                fclose( f );
	    }
	  }
	  printf("\n");
	  return 0 ;
	}
}
