#include <stdio.h>
#include "odi.h"
#include "HPdef.h"

#define if_token(x) if (!strcmp (tok_str, x))


/*---set_color-----------------------------------------------*/

int	set_color( which, src_file, out_file, line )

char	which;
FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int	status;		/* return code from called functions */
	int	token;		/* input token */
	char	tok_str[200];	/* token string if more than one char */
	uint8	command[2];	/* current command being processed */
	uint16	index;		/* color table index */


	/* 
	 * get keyword to determine if set color by index or by rgb 
	 */
	 
	command[0] = BASIC_ATTR_COMMAND;
	switch( which )
		{
		case 'p':
			strcpy( tok_str, "index" );
			break;
			
		default:
			token = get_token( tok_str, src_file, line );
			break;
		}

	if_token( "index" )
		{

		/* 
		 * xxx index -- set color by color table index 
		 */
		 
		switch( which )
			{
			case 'f':
				command[1] = SET_ACTIVE_FG_COLOR_INDEX;
				break;
				
			default:
				return HSplot_error;
			}
			
		token = get_token( tok_str, src_file, line );
		if( token != 'i' )
			{
			fprintf( stderr, "line %d: expected color index, got \"%s\"\n",
					*line, tok_str );
					
			return HSplot_error;
			}
			
		index = atoi( tok_str );
		status = fwrite( command, sizeof( uint8 ), 2, out_file );
		if( status <= 0 ) return HSplot_error;

		status = fwrite( &index, sizeof( index ), 1, out_file );
		if( status <= 0 ) return HSplot_error;
		}
	else
		{

		/* 
		 * attribute not recognized 
		 */
		 
		fprintf( stderr, "line %d: unknown set color attribute \"%s\"\n",
			*line, tok_str );
			
		return HSplot_error;
		}

	/* 
	 * check end of command 
	 */
	 
	token = get_token( tok_str, src_file, line );
	if( token != ';' )
		{
		fprintf( stderr, "line %d: expected ';' for set color command, got \"%s\"\n",
			*line, tok_str );
			
		return HSplot_error;
		}

	return HSplot_success;
	}
