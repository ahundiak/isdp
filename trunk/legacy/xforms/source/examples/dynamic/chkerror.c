/*  void chkerror( sts, string )
 *
 *  This function will printout an error message if sts is
 *  non-zero and return TRUE, otherwise it will just return
 *  a FALSE.
 */

#include <stdio.h>
#include "ex2.h"

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
