
/* 
 *  Name:
 *    FBsensor.c
 *
 *  Attention:
 *    This is a SPARC only executable which is to be run as super user.
 *
 *  Description:
 *    This routine is a stand alone executable to be run at EMS installation
 *    to determine the type of frame buffer the machine is using as its
 *    primary frame buffer.
 *
 *  History:  
 *    22 Mar 95  scw  Genesis
 *    11 Nov 96  scw  Accounted for Creator3D (type 27) graphics card
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <sys/errno.h>
#include <sys/fbio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

main()
{
   int             sts,
                   file_des,
                   req_type = FBIOGTYPE;
   struct fbtype   active_fb_type;

   /* int open( const char *path, int oflag, (mode_t mode) ... ); */
   file_des = open( "/dev/fb", O_RDONLY | O_NDELAY );

   if ( file_des == -1 )
   {
      perror("Unable to access frame buffer");
      return (255);
   }

   /* initialize to a bogus FB type */
   active_fb_type.fb_type = 27;

   /* int ioctl( int fildes, int request, (arg) .... ); */
   sts = ioctl( file_des, req_type, &active_fb_type );

   if ( active_fb_type.fb_type == 19 ||  active_fb_type.fb_type == 27 )
      /*
       * Type 19: (ZX card)
       *      FBTYPE_SUNLEO in Solaris 2.4, 2.5
       *      FBTYPE_RESERVED in Solaris 2.2 
       * Type 27: (Creator3D card)
       *      Unknown symbol in Solaris 2.5
       */ 
      printf( "XGL\n" );
   else
      printf( "NON XGL\n" );

   close( file_des );
   return (1);
}
