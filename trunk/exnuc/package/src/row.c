/*
 * This program implements the idb row command. It uses popen to
 * kick off an awk command.
 *
 * Compile instructions:
 * cc -o row row.c
 *
 * History:
 *  2/?/89     gja     Written from row.sh prototype.
 */

#include <stdio.h>
#include <string.h>
#include <fcntl.h>

#define NOT !
#define SYS_ERR -1

char command[1024]="awk 'BEGIN {FS=OFS=\"	\";} {";
FILE *fdescr, *rowf;

main( argc, argv )
int argc;
char *argv[];
{
 register int ndx=1, status=0;
 char	string[ 1024], *ptr, *nxt_ptr;

 fflush( stdout );

 if( NOT (ptr = gets(string) ) ) exit( 1 );

 printf("%s\n", ptr );

 if( argc > 1 ) {
    char tmp[256];

    while( nxt_ptr = strtok(ptr, "\t") ) {
	sprintf( tmp, "%s=$%d; ", nxt_ptr, ndx );
	strcat( command, tmp );
        if(ndx++ == 1) ptr = 0;
    }

    strcat( command, "} ");
    strcat( command, argv[1]);
    strcat( command, " {print;}'");
 }

 if( NOT (ptr = gets(string) ) ) exit( 1 );
 printf("%s\n", string );

#if DEBUG
    rowf = fopen("/tmp/row.dat", "a" );
    fprintf(rowf, "Command: = %s\n", command );
#endif	

 if( argc > 1 ) {
    fflush( stdout );
    fdescr = (FILE *)popen( command, "w" );
    while( ptr = gets( string ) ) {
	 fprintf(fdescr, "%s\n", ptr);
#if DEBUG
	 fprintf(rowf, "%s\n", ptr);
#endif
    }
#if DEBUG
    fprintf( rowf, "%x\n", (status=pclose(fdescr)) );
    fflush( rowf );
    fclose( rowf );
#else
    status = pclose( fdescr );
#endif
 } else
    while( ptr = gets( string ) ) printf("%s\n", ptr);

 exit( status );
}
