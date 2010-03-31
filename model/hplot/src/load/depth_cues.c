#include "odi.h"
#include <stdio.h>
#include "HPdef.h"

#define if_token(x) if (!strcmp (token_str, x))

# define _near	1
# define _far	2

/*---depth_cues-------------------------------------------------------*/

int depth_cues( src_file, out_file, line )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int	status;		/* return code from called functions */
	int	token;		/* input token */
	char	token_str[200];	/* token string if more than one char */
	uint8	command[2];	/* current command being processed */
	uint8	near, far;	/* intensities at near and far plane */
	char	which;		/* which attr was seen */
	char	attrs_seen = 0;	/* flags: attributes seen in input */
	char	need;		/* flag: need token */



	/* 
	 * if next token is "cues" ignore it 
	 */
	 
	token = get_token( token_str, src_file, line );
	if_token( "cues" ) token = get_token( token_str, src_file, line );

	/* 
	 * get keyword attributes to end of command ; 
	 */
	 
	while( token != EOF && token != ';' )
		{
		need = 1;
		if_token( "near" )
			which = _near;
			
		else if_token( "far" )
			which = _far;
			
		else if( token == 'i' )
			{
				
			/* 
			 * positional notation, expect near then far 
			 */
			 
			need = 0;
			switch( attrs_seen )
				{
				case 0:
				case _far:
					which = _near;
					break;
					
				case _near:
					which = _far;
					break;
					
				default:
					fprintf( stderr, "line %d: too many depth cue values \"%s\"\n",
						*line, token_str );
					
					return HSplot_error;
				} 
			}
		else
			{
					
			/* 
			 * attribute not recognized 
			 */
				 
			fprintf( stderr, "line %d: unknown depth cue attribute \"%s\"\n",
					*line, token_str );
						
			return HSplot_error;
			}

		/* 
		 * check for duplicate attribute specification 
		 */
			 
		if( which & attrs_seen )
			{
			fprintf( stderr, "line %d: duplicate depth cue attribute \"%s\"\n",
					*line, token_str );
						
			return HSplot_error;
			}
				
		attrs_seen |= which;

		/* 
		 * get another token if needed, better be an integer value 
		 */
			 
		if( need ) token = get_token( token_str, src_file, line );
		if( token != 'i' )
			{
			fprintf( stderr, "line %d: expected depth cue value, got \"%s\"\n",
					*line, token_str );
						
			return HSplot_error;
			}
				
		if( which == _near )
			near = atoi( token_str );
		else
			far = atoi( token_str );

		/* 
		 * keep going to ';' 
		 */
			 
		token = get_token( token_str, src_file, line );
		}

	/* 
	 * near and far both are required 
	 */
		 
	if( !(_near & attrs_seen) )
		{
		fprintf( stderr, "line %d: near depth cue not specified\n", *line );
		return HSplot_error;
		}
			
	if( !(_far & attrs_seen) )
		{
		fprintf( stderr, "line %d: far depth cue not specified\n", *line );
		return HSplot_error;
		}

	/* 
	 * write command: id, near, far 
	 */
	 
	command[0] = SETUP_COMMAND;
	command[1] = SET_DEPTH_CUE_INTENSITIES;
	
	status = fwrite( command, sizeof(uint8), 2, out_file );
	status = fwrite( &near, sizeof(near), 1, out_file );
	status = fwrite( &far, sizeof(far), 1, out_file );
	
	if( status <= 0) 
		return HSplot_error;
	else
		return HSplot_success;
	}
