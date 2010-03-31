#include <stdio.h>
#include "odi.h"
#include "HPdef.h"

/*---get_rgb-----------------------------------------*/

int	get_rgb( rgb_size, token, token_str, src_file, out_file, line )

int	rgb_size;	/* size of an r, g or b entry in bytes */
int	*token;		/* input token */
char	*token_str;	/* token string if more than one char */
FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int	status;			/* return code from called functions */
	int	j;			/* counter */
	uint16	rgb[3];			/* uint16 color table values */
	uint8	rgb1[3];		/* uint8 color table values */
	char	got_bracket = 0;	/* flag: saw leading bracket */
	char	ok;			/* flag: operation ok */


	/* 
	 * ignore leading brackets 
	 */
	 
	switch( *token )
		{
		case '{':
		case '(':
		case '[':
			got_bracket = *token;
			*token = get_token( token_str, src_file, line );
			break;
			
		default:
			break;
		}

	/* 
	 * get 3 ints 
	 */
	 
	for( j=0; j<3; ++j )
		{
		if( *token == 'i' ) 
			rgb[j] = atoi( token_str );
		else
			{
			fprintf( stderr, "line %d: expected integer rgb value, got %s\n",
					*line, token_str );
					
			return HSplot_error;
			}
			
		if( j < 2 ) *token = get_token( token_str, src_file, line );
		}

	/* 
	 * check trailing bracket 
	 */
	 
	if( got_bracket )
		{
		*token = get_token( token_str, src_file, line );
		switch( *token )
			{
			case '}':
				ok = got_bracket == '{';
				break;
				
			case ')':
				ok = got_bracket == '(';
				break;
				
			case ']':
				ok = got_bracket == '[';
				break;
				
			default:
				ok = 0;
				break;
			}
			
		if( !ok )
			{
			fprintf( stderr, "line %d: mismatched brackets -- %c %s\n", *line,
						got_bracket, token_str );
						
			return HSplot_error;
			}
		}

	/* 
	 * write out rgb if file given 
	 */
	 
	
	if( out_file )
		switch( rgb_size )
			{
			case 1:
				for( j=0; j<3; ++j) rgb1[j] = rgb[j];
				
				status = fwrite( rgb1, sizeof(uint8), 3, out_file );
				if( status <= 0 ) 
					{
					fprintf( stderr, "rgb write error, line %1d\n", *line );
					return HSplot_error;
					}					
				break;
				
			case 2:
				status = fwrite( rgb, sizeof(uint16), 3, out_file );
				if( status <= 0 )
					{
					fprintf( stderr, "rgb write error, line %1d\n", *line ); 
					return HSplot_error;
					}
				break;
				
			default:
				fprintf( stderr, "rgb write error, line %1d\n", *line );
				return HSplot_error;
			}

	return HSplot_success;
	}
