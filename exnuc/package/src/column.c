/*
 * This program implements the idb column command. It uses popen to
 * kick off an awk command.
 *
 * Compile instructions:
 * cc -o column column.c
 *
 * History:
 *  2/?/89     gja     Written from column.sh prototype.
 *  07/08/91   jww     removed the calloc() definition.
 */

#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define  MAXARGS  100

#define NOT !

static  char new_col[2] = { '-', '\0' };

main( argc, argv )
int argc;
char *argv[];
{
  char *ptr, string[1024];

 if( NOT (ptr = gets(string) ) ) exit( 1 );

 if( argc > 1 ) {
    register int ndx, ndx2, last = 0;
    register char *tab, *nxt_ptr;
    char **str_ptr = (char **)malloc( argc * sizeof( char * ) );
    char *dup_col  = calloc( 1, argc * sizeof( char ) );
    char *disp_col = calloc( 1, (MAXARGS+1)*sizeof(char) );  /* rel to 1 */

    for( ndx=1 ; ndx<argc; ndx++ ) str_ptr[ndx] = new_col;

    ndx = 1;
    while( nxt_ptr = strtok(ptr, "\t") ) {
	int dup_ndx = 0;

	for( ndx2=1; ndx2 < argc; ndx2++ ) {
	    if( NOT strcmp( nxt_ptr, argv[ndx2] ) ) {
		if( disp_col[ ndx ] ) {
		    dup_col[ dup_ndx ] = ndx2;
		} else {
		    disp_col[ ndx ] = ndx2;
		}
                dup_ndx = ndx2;
#if DEBUG
	    printf("Found match: header[%3d] = %s\n", ndx, nxt_ptr );
#endif
	        last = ndx;
	    }
	}

#if DEBUG
        if( NOT disp_col[ ndx ] )
	    printf("   No match: header[%3d] = %s\n", ndx, nxt_ptr );
#endif

 	if( ndx++ == 1 ) ptr = 0;

    }

    printf("%s", argv[1]);
    for(ndx2=2; ndx2<argc; ndx2++) printf("\t%s", argv[ ndx2]);
    printf("\n");

    while ( ptr = gets( string ) ) {
	ndx = 1;
	tab = (char *)1;

	do {

#if DEBUG
	printf("\nNDX = %d :: DISP_COL :: %d\n", ndx, disp_col[ ndx ] );
#endif
	    for( ndx2=disp_col[ ndx ]; ndx2; ndx2=dup_col[ndx2] ) 
		str_ptr[ ndx2 ] = ptr;
	    if( tab  &&  (tab = strchr( ptr, '\t' )) ) {
		*tab = '\0';
		ptr = ++tab;
	    } else
		ptr = new_col;

#if DEBUG
	printf("\nPTR = %s ::  TAB = %x\n", ptr, tab );
#endif

	} while ( ndx++ < last  ||  tab );

	printf( "%s", str_ptr[ ndx = 1 ] );
	while( ++ndx < argc ) printf("\t%s", str_ptr[ ndx ] );
        printf("\n");
	if( new_col[0] ) new_col[0] = '\0';
    }
 } else {
   printf("%s\n", string);
   while ( gets( string ) ) printf("%s\n", string );
 }
}
