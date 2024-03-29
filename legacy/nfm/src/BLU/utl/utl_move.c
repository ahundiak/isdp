/******************************************************************************

Doc:	utl_move

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_move.c

Author:	Jeff Silvaggi

Date:	02-OCT-1992

SDM Number:

Description:	This function moves a file from one filename to another. If
	the input and output files are located on the same file system, the
	Berkely rename() function is used. Otherwise, the file is copied to
	the new location, removed from the old location, and an attempt is
	made to set the time and permissions back to the way the original file
	had them.

Examples:
	status = utl_move( from, to )

Return Status:
	 0 = Successful completion
	-1 = Error

History:
******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <utime.h>
#define BLOCK_SIZE 30000

utl_move( from, to )
char *from;
char *to;
{
FILE *infile, *ofile;
int bytes_this_read, bytes_to_read, byte;
int status, same_fsys;
char *buf, *ptr;
char fname[132];
struct stat sb, sb2;
struct utimbuf ub;

setbuf( stdout, 0 );

/* Get info about input file */
if( stat( from, &sb ) )
{
  printf("Error accessing file %s\n", from);
  return( -1 );
}

/* Determine if same file system */
same_fsys = 0;
if( from[0] != '/' && to[0] != '/' )
{
  same_fsys = 1;
}
else
{
  strcpy( fname, to );

  ptr = strrchr( fname, '/' );
  if( ptr ) *ptr = 0;
  else
  {
    getcwd( fname, 132 );
  }

  if( stat( fname, &sb2 ) ) return( -1 );
  if( sb.st_dev == sb2.st_dev ) same_fsys = 1;
}

/* If same file system, just rename the file */
if( same_fsys )
{
  status = rename( from, to );
  return( status );
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

/* Remove old file */
unlink( from );

/* Set time of output file */
ub.actime = sb.st_atime;
ub.modtime = sb.st_mtime;
utime( fname, &ub );

/* Set permissions */
chmod( fname, sb.st_mode );
chown( fname, sb.st_uid, sb.st_gid );

return( 0 );
} /* end of utl_move() */
