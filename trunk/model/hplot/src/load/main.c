#include <stdio.h>
#include "odi.h"
#include "HPdef.h"

char debug_flag = 0;

/*---load---(main)-------------------------------------------*/

main( argc, argv )

int	argc;		/* command line argument count */
char	*argv[];	/* pointers to command line argument strings */

	{
	FILE	*sfp;			/* input source file pointer from fopen */
	FILE	*mfp;			/* metafile file pointer from fopen */
	int	status;			/* return code from called functions */
	int	i;			/* counter */
	char	*ptr;			/* char finger */
	char	*srcfile_name = 0;	/* pointer to source file name string */
	char	*metafile_name = 0;	/* pointer to metafile name string */
	char	ch;			/* a char */


	HPdload( "load_dload.o" );
	
	if( argc < 2 )
		{
		printf( "usage: %s <source file name> <metafile name>\n", argv [0] );
		exit(0);
		}

	for( i=1; i<argc; ++i )
		{
		ptr = argv[i];
		ch = *ptr++;
		if( ch == '-' )
			{
			ch = *ptr++;
			switch( ch )
				{
				case 'd':
				case 'D':
					debug_flag = 1;
					break;
					
				case 'v':
				case 'V':
					debug_flag = 2;
					break;
					
				default:
					fprintf (stderr, "unknown option %c\n", ch);
					break;
				}
			}

		else
			if( !srcfile_name ) 
				srcfile_name = argv[i];
			else
				if( !metafile_name )
					metafile_name = argv [i];
				else
					{
					fprintf( stderr, "too many arguments\n" );
					exit(1);
					}
		}

	if( !srcfile_name )
		{
		fprintf( stderr, "no source file argument\n" );
		exit(1);
		}
		
	if( !metafile_name )
		{
		fprintf( stderr, "no metafile argument\n" );
		exit(1);
		}
		
	if( debug_flag )
		fprintf( stderr, "load_mf: %s -> %s\n", srcfile_name, metafile_name );

	/* 
	 * open source file for reading 
	 */
	 
	sfp = fopen( srcfile_name, "r" );
	if( !sfp )
		{
		fprintf( stderr, "load_mf: error opening %s for read\n", srcfile_name );
		status = HSplot_error;
		goto quit;
		}

	/* 
	 * open metafile for writing 
	 */
	 
	mfp = fopen( metafile_name, "w" );
	if( !mfp )
		{
		fprintf( stderr, "load_mf: error opening %s for write\n", metafile_name );
		status = HSplot_error;
		goto quit;
		}

	/* 
	 * read source and create metafile 
	 */
	 
	status = ems_metafile_parser( sfp, mfp );

quit:
	if( status )
		exit(1);
	else
		exit(0);
	}
