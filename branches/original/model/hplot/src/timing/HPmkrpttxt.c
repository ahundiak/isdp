#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

	
struct function_info
	{
	int		shown;
	unsigned char	title[132];
	int		num_func_calls;
	int		func_calls[100];
	};
	
struct function_info	functions[100];
int			nfuncs;

FILE	*fp, *fopen();

main()
	{
	int	i, j;
	
	get_report_info();
	output_cfile_header();
	
	j = 0;
	for( i=0; i<nfuncs; i++ )
		{
		output_func_info( i, j );
		}
	
	output_cfile_tail();
	}
	
get_report_info()

	{
	int			fp;
	struct stat		buf;
	unsigned char		*buffer;
	unsigned char		string[132];
	int			bufsiz;
	
	int			i, j, k;
	int			a, b, c;
	unsigned char		stuff[132];
	
	
	fp = open( "HPtiming.dat", 2 );
	fstat( fp, &buf );
	buffer = (char *)malloc(buf.st_size);
	bufsiz = read( fp, buffer, buf.st_size );
	close( fp );

	memset( functions, 0, sizeof( struct function_info ) * 100 );

	
	buffer[bufsiz] = 0;
	
	i = 0;
	nfuncs = 0;
	
	while( i < bufsiz )
		{
		nfuncs++;
		j = 0;

		memset( string, 0, 132 );
		while( buffer[i] != 10 )
			string[j++] = buffer[i++];
		
		j = 0;
		parse_int( string, &j, &a );
		parse_quoted_string( string, &j, stuff );

		k = 0;
		while( stuff[k] != 0 )
			{
			functions[a].title[k] = stuff[k];
			k++;
			}
			
		while( k <= 23 )
			functions[a].title[k++] = ' ';
			
		functions[a].title[k] = 0;
		
		k = 0;
		
		do	{
			parse_int( string, &j, &b );
			if( b >= 0 )
				functions[b].func_calls[functions[b].num_func_calls++] = a;
			}
		while( b >= 0 );
		
		i++;
		}
		
	display_funcs();
	}
	
parse_int( s, index, value )

unsigned char	*s;
int		*index, *value;

	{
	int	a;
	int	i;
	
	i = *index;
	
	while( !(s[i] >= '0' && s[i] <= '9') && s[i] != 0 ) i++;
	
	if( s[i] == 0 )
		{
		*index = i+1;
		*value = -1;
		}
	else
		{
		a = 0;
		while( s[i] >= '0' && s[i] <= '9' )
			a = a * 10 + s[i++] - '0';

		*index = i+1;
		*value = a;
		}
	}

parse_quoted_string( s, index, string )

unsigned char	*s, *string;
int		*index;

	{
	int	i, j;
	
	i = *index;
	
	while( s[i++] != '"' );
	
	j = 0;
	while( s[i] != '"' )
		string[j++] = s[i++];
	string[j] = 0;
		
	*index = i+1;
	}

display_funcs()

	{
	int	i, j;
	
	for( i=0; i<nfuncs; i++ )
		{
		fprintf( stderr, "%5d %s\n", i, functions[i].title );
		
		j = 0;
		while( functions[i].func_calls[j] != 0 )
			{
			fprintf( stderr, "         %s\n",
				functions[functions[i].func_calls[j]].title );
			j++;
			}
		}
	}
	
output_cfile_header()

	{
	fp = fopen( "HPtiming.c", "w" );
	
	fprintf( fp, "#include <stdio.h>\n" );
	fprintf( fp, "#include <sys/types.h>\n" );
	fprintf( fp, "#include <sys/stat.h>\n" );
	fprintf( fp, "#include <sys/times.h>\n" );
	fprintf( fp, "\n" );
	fprintf( fp, "struct	timing_stuff\n" );
	fprintf( fp, "		{\n" );
	fprintf( fp, "		int	stime, etime;\n" );
	fprintf( fp, "		int	atime;\n" );
	fprintf( fp, "		int	ncalls;\n" );
	fprintf( fp, "		};\n" );
	fprintf( fp, "		\n" );
	fprintf( fp, "extern struct	timing_stuff	timing[100];\n" );
	fprintf( fp, "extern struct	tms	 	tms_data;\n" );
	fprintf( fp, "\n" );
	fprintf( fp, "/*---HPtiming_report-------------------------------------------------------------*/\n" );
	fprintf( fp, "	\n" );
	fprintf( fp, "/*	\n" );
	fprintf( fp, "NAME\n" );
	fprintf( fp, "	HPtiming_report\n" );
	fprintf( fp, "	\n" );
	fprintf( fp, "KEYWORD\n" );
	fprintf( fp, "	HSplot\n" );
	fprintf( fp, "	timing\n" );
	fprintf( fp, "	\n" );
	fprintf( fp, "DESCRIPTION\n" );
	fprintf( fp, "	Display timing information for each of the set of timing nodes\n" );
	fprintf( fp, "	\n" );
	fprintf( fp, "HISTORY\n" );
	fprintf( fp, "	??%c??%c??	M. Lanier\n", (char)47, (char)47 );
	fprintf( fp, "		Created\n" );
	fprintf( fp, "		\n" );
	fprintf( fp, "*/	\n" );
	fprintf( fp, "\n" );
	fprintf( fp, "HPtiming_report( outfile )\n" );
	fprintf( fp, "\n" );
	fprintf( fp, "FILE	*outfile;\n" );
	fprintf( fp, "\n" );
	fprintf( fp, "	{\n" );
	fprintf( fp, "	double	atime;\n" );
	fprintf( fp, "	int	i;\n\n" );
	fprintf( fp, "	fprintf( outfile, \"\\n\\nTiming Results.\\n\" );\n" );
	fprintf( fp, "	fprintf( outfile, \"-------------------------------------------------------------\\n\" );\n" );
	fprintf( fp, "	fprintf( outfile, \"routine                  number accumulated avg. time pct tot\\n\" );\n" );
	fprintf( fp, "	fprintf( outfile, \"name                     calls  time sec    per call   time\\n\" );\n" );
	fprintf( fp, "	fprintf( outfile, \"------------------------ ------ ----------- --------- -------\\n\" );\n\n" );
	}
	
output_cfile_tail()

	{
	fprintf( fp, "	}\n" );
	fclose( fp );
	}


output_func_info( who, indent )

int	who, indent;

	{
	int	i, j;
	char	title[50];

	if( functions[who].shown == 1 ) return;

	functions[who].shown = 1;	
	fprintf( fp, "	if( timing[%1d].ncalls != 0 )\n", who );
	fprintf( fp, "		{\n" );
	fprintf( fp, "		atime  = (double)timing[%1d].atime;\n", who );

	i = 0;
	while( functions[who].func_calls[i] != 0 )
		{
		fprintf( fp, "		atime -= (double)timing[%1d].atime;\n", 
			functions[who].func_calls[i] );
		i++;
		}
	fprintf( fp, "\n" );

	for( i=0; i<indent; i++ ) title[i] = ' ';
	for( j=0; i<21;    i++ ) title[i] = functions[who].title[j++];
	title[21] = 0;

	fprintf( fp, "		fprintf( outfile, \"%22s ", title );
	fprintf( fp, "%c6d %c11.3f %c9.5f %c7.2f\\n\",\n", '%', '%', '%', '%' );
	fprintf( fp, "				timing[%1d].ncalls,\n", who );
	fprintf( fp, "				atime / 60.0,\n" );
	fprintf( fp, "				(atime / (double)timing[%1d].ncalls) / 60.0,\n", who );
	fprintf( fp, "				(atime / (double)timing[0].atime) * 100 );	\n", 
		functions[who].title, who, who, who );
	fprintf( fp, "		}\n\n" );

	for( i=0; i<functions[who].num_func_calls; i++ )
		{
		output_func_info( functions[who].func_calls[i], indent+1 );
		}
	}
