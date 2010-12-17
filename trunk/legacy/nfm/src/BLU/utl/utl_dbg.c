/******************************************************************************

Doc:	utl_set_debug
	utl_debug

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_dbg.c

Author:	Jeff Silvaggi

Date:	12-AUG-1992

SDM Number:

Description:	This file contains a function to set the debug level for
	this process, and a function to return the current debug level.

Examples:
	utl_set_debug( client, server )
	utl_debug( &client, &server )

Return Status:
	Can't fail

History:
******************************************************************************/

int utl_client_dbg=0, utl_server_dbg=0;
long utl_dbg = 0;

utl_set_debug( client, server )
int client;				/* I - Client debug level */
int server;				/* I - Server debug level */
{
utl_client_dbg = client;
utl_server_dbg = server;
return( 0 );
} /* end of utl_set_debug() */

utl_debug( client, server )
int *client;				/* I/O - Pointer to client debug level */
int *server;				/* I/O - Pointer to server debug level */
{
*client = utl_client_dbg;
*server = utl_server_dbg;
return( 0 );
} /* end of utl_debug() */
