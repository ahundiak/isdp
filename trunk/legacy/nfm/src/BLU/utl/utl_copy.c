/******************************************************************************

Doc:	utl_copy

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_copy.c

Author:	Jeff Silvaggi

Date:	07-OCT-1992

SDM Number:

Description:	This function copy a file from one filename to another.

Examples:
	status = utl_copy( from, to )

Return Status:
	 0 = Successful completion
	-1 = Error

History:
******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#define BLOCK_SIZE 30000

utl_copy( from, to )
char *from;
char *to;
{
FILE *infile, *ofile;
int bytes_this_read, bytes_to_read, byte;
char *buf, *ptr;
char fname[132];
struct stat sb, sb2;

setbuf( stdout, 0 );

/* Get info about input file */
if( stat( from, &sb ) )
{
  printf("Error accessing file %s\n", from);
  return( -1 );
}

/* Error if input file is a directory */
if( sb.st_mode & 040000 )
{
  printf("%s .. File is a directory\n", from);
  return( -1 );
}

/* If output file is a directory append the input filename to it */
strcpy( fname, to );
if( ! stat( to, &sb2 ) )
{
  if( sb2.st_mode & 040000 )
  {
    ptr = strrchr( from , '/' );
    if( ! ptr ) ptr = from;
    sprintf( fname, "%s/%s", to, ptr );
  }
}

bytes_to_read = sb.st_size;

/* Open input file */
infile = fopen( from, "rb" );
if( infile == 0 )
{
  printf("Error opening %s for input\n", from);
  return( -1 );
}

/* Open output file */
ofile = fopen( fname, "wb" );
if( ofile == 0 )
{
  printf("Error creating file %s\n", fname);
  fclose( infile );
  return( -1 );
}

/* Allocate copy buffer */
buf = (char *)malloc( BLOCK_SIZE );
if( buf == 0 )
{
  printf("Error allocating memory for copy\n");
  fclose( infile );
  fclose( ofile );
  unlink( fname );
  return( -1 );
}
  
/******* Copy file *******/
byte = 0;
while( 1 )
{
  bytes_this_read=((byte+BLOCK_SIZE)<=bytes_to_read) ? BLOCK_SIZE:(bytes_to_read-byte);
  if( bytes_this_read <= 0 ) break;
  byte += bytes_this_read;

  /* Read input file */
  if( (fread( buf, bytes_this_read, 1, infile )) != 1 )
  {
    printf("Error reading input file\n");
    free( buf );
    fclose( infile );
    fclose( ofile );
    unlink( fname );
    return( -1 );
  }

  /* Write output file */
  if( (fwrite( buf, bytes_this_read, 1, ofile )) != 1 )
  {
    printf("Error writing to output file\n");
    free( buf );
    fclose( infile );
    fclose( ofile );
    unlink( fname );
    return( -1 );
  }
}

/* Clean up */
free( buf );
fclose( infile );
fclose( ofile );

#ifdef NOTUSED  mjf 7-jan-94

/* Set permissions */
chmod( fname, sb.st_mode );
chown( fname, sb.st_uid, sb.st_gid );
#endif

return( 0 );
} /* end of utl_copy() */
