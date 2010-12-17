/******************************************************************************

Doc:	utl_open_debug
	utl_print_debug
	utl_close_debug

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_prnt.c

Author:	Jeff Silvaggi

Date:	23-NOV-1992

SDM Number:

Description:	These functions handle maintainance of output debug files.

Examples:
	handle = utl_open_debug( filename );
	utl_print_debug( handle, flag, format, ... )
	utl_close_debug( handle );

Return Status:
	Can't fail

History:
******************************************************************************/
#include <stdio.h>
#include <stdarg.h>
#include "utl.h"

/****************************************************************************
        Name: utl_open_debug
 Description: This function opens the requested debug file for printing,
	allocates a debug structure and returns the pointer to it for use
	in calling the utl_print_debug function.
****************************************************************************/
long utl_open_debug( char *filename )
{
FILE *fp;
utl_dbg_str *dbg;

/* Open the debug file */
fp = fopen( filename, "w" );
if( fp == 0 ) return( -1 );

/* Allocate a debug structure */
dbg = (utl_dbg_str *)malloc( sizeof( utl_dbg_str ) );
if( dbg == 0 )
{
  fclose( fp );
  return( -1 );
}

/* Fill in the structure */
dbg->fp = (long)fp;
dbg->lvls = 1;
setbuf( fp, 0 );

/* Return the handle */
return( (long)dbg );
} /* End of utl_open_debug */

/****************************************************************************
        Name: utl_print_debug
 Description: This function prints debug output to the requested debug file.
****************************************************************************/
void utl_print_debug( int handle, int lvl, char *fmt, ... )
{
static char *blanks="                              ";
FILE *fp;
int nblanks;
utl_dbg_str *dbg;
va_list vars;

dbg = (utl_dbg_str *)handle;
fp = (FILE *)dbg->fp;

if( lvl == UTL_INDENT ) dbg->lvls++;

/* Calculate number of blanks for indent */
nblanks = (dbg->lvls - 1) << 1;

/* If function entered */
if( lvl == UTL_INDENT )
{
  if( nblanks ) fwrite( blanks, nblanks, 1, fp );
  fprintf( fp, "|--------\n");
}

/* Format debug line */
if( lvl != UTL_CONTINUE )
{
  if( nblanks ) fwrite( blanks, nblanks, 1, fp );
  fprintf( fp, "| " );
}
va_start ( vars, fmt );
vfprintf ( fp, fmt, vars );
va_end ( vars );

/* If function exitted */
if( lvl == UTL_UNINDENT )
{
  if( nblanks ) fwrite( blanks, nblanks, 1, fp );
  fprintf( fp, "|--------\n");
  dbg->lvls--;
}

return;
} /* End of iml_debug() */

/****************************************************************************
        Name: utl_close_debug
 Description: This function closes the requested debug file.
****************************************************************************/
utl_close_debug( long handle )
{
FILE *fp;
utl_dbg_str *dbg;

dbg = (utl_dbg_str *)handle;
fp = (FILE *)dbg->fp;

/* Free up resources and return */
fclose( fp );
free( dbg );
return( 0 );
} /* End of utl_close_debug() */
