/******************************************************************************

Doc:	utl_getid

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_getid.c

Author:	Jeff Silvaggi

Date:	21-AUG-1992

SDM Number:

Description:	This function generates a unique id for use in writing
	debug files.

Examples:

Return Status:
	Can't fail

History:
******************************************************************************/
#include <string.h>

utl_getid( id, display_name )
char *id;			/* O - Pointer to where the id should be stored */
char *display_name;		/* I - Pointer to display name if setting or 0 */
{
int n1, n2;
char *ptr, dname[20];
char addr[30];
static int client_id=0;

/* If setting display */
if( display_name )
{
  /* See if this is a client id or display name */
  ptr = display_name;
  while( *ptr )
  {
    if( isdigit( *ptr ) )
    {
      ++ptr;
      continue;
    }
    break;
  }

  if( ptr )
  {
    /* Remove ':' if present */
    strcpy( dname, display_name );
    ptr = strchr( dname, ':' );
    if( ptr ) *ptr = 0;
  
    /* Get Internet address of display node */
    if( get_tcp( dname, addr ) )
    {
      sprintf( id, "%.5d", getpid() );
      return( 0 );
    }
  
    /* Parse address and use last 2 sets of numbers as ID */
    ptr = strchr( addr, '.' );
    ptr = strchr( ++ptr, '.' );
    n1 = atoi( ++ptr );
    ptr = strchr( ptr, '.' );
    n2 = atoi( ++ptr );
    sprintf( id, "%.3d%.3d", n1, n2 );
  
    /* Save ID for future reference and return */
    client_id = atoi( id );
    return( 0 );
  }
  else
  {
    client_id = atoi( display_name );
  }
}

/* If ID has already been set, return it otherwise use the process id */
if( client_id )
  sprintf( id, "%.6d", client_id );
else
  sprintf( id, "%.6d", getpid() );

return( 0 );
} /* end of utl_getid() */
