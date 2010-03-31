#include <stdio.h>
#include "odi.h"

#include "igrtypedef.h"
#include "igr.h"
#include "hsurf.h"
#include "HSplot_def.h"
#include "HPdef.h"

#define if_token(x) if (!strcmp (tok_str, x))

/* attributes seen flags */

#define _color			0x0001
#define _style			0x0002
#define _weight			0x0004
#define	_use_orig_color		0x0008
#define	_use_orig_weight	0x0010
#define _use_orig_style		0x0020

/*---user_line_style--------------------------------------------------------*/

int user_line_style( src_file, out_file, line )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int	status;		/* return code from called functions */
	int	token, i;		/* input token */
	char	tok_str[200];	/* token string if more than one char */
	uint8	command[2];	/* current command being processed */
	
	unsigned short	index, pattern;
	
	token = get_token( tok_str, src_file, line );
	index = atoi( tok_str );

	pattern = 0;
	
	token = get_token( tok_str, src_file, line );


	while( token != EOF && token != ';' )
		{
		for( i=0; i<16; i++ )
			{
			pattern <<= 1;
			
			if( tok_str[i] == '-' )
				pattern |= 1;
			}
		
		
		/* keHP going to ';' */
		
		token = get_token( tok_str, src_file, line );
		}

	command[0] = SETUP_COMMAND;
	command[1] = SET_USER_LINE_STYLE;
		
	status = fwrite( command, sizeof( uint8 ), 2, out_file );	
	status = fwrite( &index, sizeof( unsigned short ), 1, out_file );
	status = fwrite( &pattern, sizeof( unsigned short ), 1, out_file );
	
	return HSplot_success;
	} /* user_line_style */
