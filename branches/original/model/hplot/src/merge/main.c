#include <stdio.h>

int	debug;

main( argc, argv )

int	argc;
char	*argv[];

	{
	FILE	*infil, *outfil;
	char	*expr, *getenv();
	
	expr = getenv( "HSplot_DEBUG" );
	sscanf( expr, "%d", &debug );
	
	if( argc == 4 )
		{
		infil = fopen( argv[1], "r" );
		outfil = fopen( argv[3], "w" );
		
		read_header( infil );
		write_header( outfil );
		
		while( copy( infil, outfil, 0 ) != 1 );
		
		fclose( infil );
		infil = fopen( argv[2], "r" );
		
		read_header( infil );
		
		while( copy( infil, outfil, 1 ) != 1 );
		
		fclose( infil );
		fclose( outfil );
		}
	else
		{
		printf( "Not enough arguments\n" );
		}
	}
