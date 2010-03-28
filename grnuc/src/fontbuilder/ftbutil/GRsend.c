/** ii_send.c -- This file takes its arguments and does a "system"   **/
/**		 call with them.  The executable made from this file **/
/**		 should have the "setuid" bit ON, and be owned by    **/
/**		 root.  This effectively gives super-user privileges **/
/**		 to the system command invoked from here.	     **/
/** 		 Created by JAJ on 05-04-88 			     **/

/*
$Log: GRsend.c,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:30  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:47  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:41  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:54:06  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:58  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:41:39  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>

main ( argc, argv )
  int argc;
  char * argv[];
{
  char  cmd[500];
  short ii;

  cmd[0] = '\0';
  
  for ( ii = 1; ii < argc ; ii++ )
    {
      strcat ( cmd, argv[ii] );
      strcat ( cmd, " " );
    }

  /***
  printf ( "ii_send:  About to '%s'\n", cmd );
  ***/

  system ( cmd );
}
