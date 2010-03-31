#include <stdio.h>
#include "odi.h"
#include "HPdef.h"

#define if_token(x) if (!strcmp (token_str, x))

# define _matrix	1
# define _range		2


/*---set_view_data---------------------------------------------*/

int	set_view_data( src_file, out_file, line )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	double	matrix[16];		/* transformation matrix */
	double	range[6];		/* viewport range diagonal */
	int	status;			/* return code from called functions */
	int	j;			/* counter */
	int	token;			/* input token */
	char	token_str[200];		/* token string if more than one char */
	uint8	command[2];		/* current command being processed */
	uint16	attrs_seen = 0;		/* flags: attributes seen in input */
	uint8	view_num;		/* the view id number */


	/* 
	 * init unit matrix 
	 */
	 
	for( j=1; j<15; ++j ) matrix[j] = 0.0;
	
	matrix[0] = 1.0;
	matrix[5] = 1.0;
	matrix[10] = 1.0;
	matrix[15] = 1.0;


	/* 
	 * get keyword attributes to end of command ; 
	 */
	 
	token = get_token( token_str, src_file, line );
	while( token != EOF && token != ';' )
		{

		/* 
		 * get view transformation matrix 
		 */
		 
		if_token( "matrix" )
			{
			if( _matrix & attrs_seen ) goto dup_error;
			attrs_seen |= _matrix;

			token = get_token( token_str, src_file, line );
			status = get_doubles(	4, 
						matrix, 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;

			token = get_token( token_str, src_file, line );
			status = get_doubles(	4, 
						&matrix[4], 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );

			if( status ) return HSplot_error;

			token = get_token( token_str, src_file, line );
			status = get_doubles(	4, 
						&matrix[8], 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;

			token = get_token( token_str, src_file, line );
			status = get_doubles(	4, 
						&matrix[12], 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;
			}

		/* 
		 * get viewport range diagonal 
		 */
		 
		else if_token( "range" )
			{
			if( _range & attrs_seen ) goto dup_error;
			attrs_seen |= _range;

			token = get_token( token_str, src_file, line );
			status = get_doubles(	3, 
						range, 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;

			token = get_token( token_str, src_file, line );
			status = get_doubles(	3, 
						&range[3], 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;
			}

		/* error */
		else
			{
			fprintf( stderr, "line %d: unknown view attribute \"%s\"\n",
					*line, token_str );
					
			return HSplot_error;
			}
			
		token = get_token( token_str, src_file, line );
		}

	/* 
	 * check for required things: range 
	 */
	 
	if( (_range | _matrix) & attrs_seen )
		{
		if( !(_range & attrs_seen) )
			{
			fprintf(stderr, "line %d: view range not specified\n", *line );
			return HSplot_error;
			}
			
		command[0] = SETUP_COMMAND;
		command[1] = SET_VIEW_ORIENTATION_RANGE;
		}
	else
		{
		return HSplot_error;
		}

	/* 
	 * write command: id, view number 
	 */
	 
	view_num = 1;
	status  = fwrite( command, sizeof(uint8), 2, out_file );
	status |= fwrite( &view_num, sizeof(view_num), 1, out_file );

	/* 
	 * if set-up command, write view transformation matrix and range 
	 */
	 
	status |= fwrite( matrix, sizeof(double), 16, out_file );
	status |= fwrite( range, sizeof(double), 6, out_file );

	if( status <= 0 )
		return HSplot_error;
	else
		return HSplot_success;

dup_error:
	fprintf( stderr, "line %d: duplicate view attribute \"%s\"\n",
		*line, token_str );
		
	return HSplot_error;
	}
