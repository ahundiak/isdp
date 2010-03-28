/*
$Log: chkerror.c,v $
Revision 1.1.1.1  2001/12/17 22:39:36  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:17:09  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:31:31  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  18:00:17  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/07  00:05:08  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:41:17  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:43:23  tim
 * COMMENT : added Log variable
 *
*/

/*  void chkerror( sts, string )
 *
 *  This function will printout an error message if sts is
 *  non-zero and return TRUE, otherwise it will just return
 *  a FALSE.
 */

#include <stdio.h>
#include "ex1.h"

int chkerror( sts, string )
  int sts;
  char *string;
{
  if ( sts ) {
    fprintf( stderr, "Error (%d): %s\n", sts, string );
    return( TRUE );
  }
  else
    return( FALSE );
}
