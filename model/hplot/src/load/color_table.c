#include <stdio.h>
#include "odi.h"
#include "HPdef.h"
#include "strmacros.h"


/*---color_table-------------------------------------------*/

int	color_table( src_file, out_file, line )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int	status;		/* return code from called functions */
	int	token;		/* input token */
	long	pos;		/* input file position */
	int	lct = 1;	/* local source line counter for second pass */
	uint16	count = 0;	/* table size counter */
	char	token_str[200];	/* token string if more than one char */
	uint8	command[2];	/* current command being processed */


	/* 
	 * remember file location because we must first count the table entries 
	 */
	 
	pos = ftell( src_file );

	/* 
	 * get a token.	if it's the word "table", ignore it, get new file pos 
	 */
	 
	token = get_token( token_str, src_file, line );
	if( token == 'w' )
		if( _str_eq( token_str, "table" ) )
			{
			pos = ftell( src_file );
			token = get_token( token_str, src_file, line );
			}
		else
			{
			fprintf( stderr, "line %d: unknown color option \"%s\"\n", *line,
				token_str );
				
			return HSplot_error;
			}

	/* 
	 * count table entries to end of command ; -- i.e. rgb triples 
	 */
	 
	while( token != EOF && token != ';' )
		{
		status = get_rgb(	2, 
					&token, 
					token_str, 
					src_file, 
					NULL, 
					line );
					
		if( status ) return HSplot_error;
		
		++count;
		token = get_token( token_str, src_file, line );
		}

	/* 
	 * write command id, count 
	 */
	 
	command [0] = SETUP_COMMAND;
	command [1] = SET_COLOR_TABLE_RGB;
	
	status  = fwrite( command, sizeof(uint8), 2, out_file );
	status |= fwrite( &count, sizeof(count), 1, out_file );
	if( status <= 0 ) return HSplot_error;
	
	/* 
	 * position file and read table again, writing entries as we go 
	 */
	 
	status = fseek( src_file, pos, 0 );
	if( status ) return HSplot_error;

	token = get_token( token_str, src_file, &lct );
	while( token != EOF && token != ';' )
		{
		status = get_rgb(	2, 
					&token, 
					token_str, 
					src_file, 
					out_file, 
					&lct );
					
		if( status ) return HSplot_error;
		token = get_token( token_str, src_file, &lct );
		}

	if( status )
		return HSplot_error;
	else
		return HSplot_success;
	}
