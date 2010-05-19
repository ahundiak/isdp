/* $Id: VDHllDbg_Fn.C,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdhulldbg/func / VDHllDbg_Fn.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDHllDbg_Fn.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*    
   File :		VDHllDbg_Fn.C
   Author :		Alain CLAUDE
   Revision date :	93/02/23
   Description :	Utility - Command "Debug In a Hull"
   History :
	93/02/23	Implement VDis_ascii_file()
*/

 
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>


int VDis_ascii_file(filename)
char *filename ;
/*
   Description :
   -----------
	Given a file name, this function tries to guess its type.

   Return codes :
   ------------
	1	success
	0	failure		=> file is not a regular ascii file

   Implementation note :
   -------------------
	- First, the st_mode of the file is checked to keep regular file
 	- Then, we check if the regular file is an ascii one :
	The file is read by block of BUFSIZ characters.  A file is
	considered as an ASCII one, if we are able to find at least an 
	occurrence of '\n' for each read block.
 */
{
char 		fbuf[BUFSIZ] ;
struct stat	mbuf ;
int		ifd  ;
int		num_read, i ;
long		rc ;

ifd = -1;
if (stat(filename, &mbuf) < 0) {
	#ifdef DEBUG
	printf("VDis_ascii_file() : stat(%s) failed \n", filename) ;
	#endif
	rc = 0 ; goto quit ;
	}

switch(mbuf.st_mode & S_IFMT) {	/* file type */

   case S_IFDIR : case S_IFCHR : case S_IFBLK : case S_IFIFO : case S_IFSOCK :
	#ifdef DEBUG
	printf("VDis_ascii_file() : invalid file type \n") ;
	#endif
	rc = 0 ; goto quit ;

   case S_IFREG : case S_IFLNK : /* OK */
	rc = 1 ;
	break  ;

   default :
	printf("VDis_ascii_file() : unknown file type \n") ;
	rc = 0 ; goto quit ;
   }

ifd = open(filename, O_RDONLY) ;
if (ifd < 0) { 
	#ifdef DEBUG
	printf("VDis_ascii_file() : open(%s, O_RDONLY) failed \n", filename) ;
	#endif
	rc = 0 ; goto quit ; 
	}

rc = 0 ; /* initialization for empty file */
while (num_read = read(ifd, fbuf, BUFSIZ) > 0) {
	for (i = 0 ; fbuf[i] != '\n' && i < BUFSIZ ; i++) ;
	if (i < BUFSIZ ) { rc = 1 ; continue ; }
	else { rc = 0 ; break ; /* error => out */ }
	}

quit : 
	#ifdef DEBUG
	if (rc)  { printf("%s is an ascii file \n", filename) ; }
	else { printf("%s is not a regular ascii file \n", filename) ; }
	#endif

	close(ifd) ;
	return rc  ;
} /* VDis_ascii_file() */

