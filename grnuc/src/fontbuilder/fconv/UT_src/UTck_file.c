/*
$Log: UTck_file.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:38  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:52  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:52  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:46  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:08  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:42:17  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "FFstructs.h"

UTcheck_file( pathname )

	Typepath pathname;
{
	char   sval[256], *CX16to8();
	int    sts;
        struct stat stbuf;

   strcpy( sval, CX16to8(pathname) );
   sts = stat(sval, &stbuf);
   if (  sts == -1 )
      return( 0 );

   if ((stbuf.st_mode & S_IFMT) == S_IFREG)
       return ( 1 );
     else
       return ( 0 );

}
