#include <stdio.h>
#include "odi.h"

#include "igrtypedef.h"
#include "igr.h"
#include "HSplot_def.h"
#include "HPdef.h"
#include "HStl_window.h"
#include "HPstruct.h"
#include "grdpbdef.h"

#define if_token(x) if (!strcmp (tok_str, x))

/* attributes seen flags */

#define _color			0x0001
#define _style			0x0002
#define _weight			0x0004
#define	_use_orig_color		0x0008
#define	_use_orig_weight	0x0010
#define _use_orig_style		0x0020

/*---hidden_symbology--------------------------------------------------------*/

int hidden_symbology( src_file, out_file, line )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int	status;		/* return code from called functions */
	int	token;		/* input token */
	char	tok_str[200];	/* token string if more than one char */
	uint8	command[2];	/* current command being processed */
	short	which;		/* which attr was seen */
	char	attrs_seen = 0;	/* flags: attributes seen in input */
	char	which_str[40];	/* string for which attr */

	struct GRhesym		hsym;

	/* ------- code ------------------------------------------------------------- */

	hsym.color = 1;
	hsym.weight = 0;
	hsym.style = 0;
	hsym.flags = 0;
	
	token = get_token( tok_str, src_file, line );
	
	while( token != EOF && token != ';' )
		{
		strcpy( which_str, tok_str );
		if_token( "color" )
			{
			which = _color;
			token = get_token( tok_str, src_file, line );
			hsym.color = atoi( tok_str );
			}
		else if_token( "weight" )
			{
			which = _weight;
			token = get_token( tok_str, src_file, line );
			hsym.weight = atoi( tok_str );
			}
		else if_token( "style" )
			{
			which = _style;
			token = get_token( tok_str, src_file, line );
			hsym.style = atoi( tok_str );
			}
		else if_token( "use_original_color" )
			{
			which = _use_orig_color;
			hsym.flags |= DPB_USE_ORIG_COLOR;
			}
		else if_token( "use_original_weight" )
			{
			which = _use_orig_weight;
			hsym.flags |= DPB_USE_ORIG_WEIGHT;
			}
		else if_token( "use_original_style" )
			{
			which = _use_orig_style;
			hsym.flags |= DPB_USE_ORIG_STYLE;
			}
		else
			{

			/* attribute not recognized */

			fprintf( stderr, "line %d: unknown light source attribute \"%s\"\n",
				*line, tok_str );
			return HSplot_error;
			}

		/* check for duplicate attribute specification */
		
		if( which & attrs_seen )
			{
			fprintf( stderr, "line %d: duplicate light source attribute \"%s\"\n",
				*line, which_str );
			return HSplot_error;
			}
			
		attrs_seen |= which;

		/* keHP going to ';' */
		
		token = get_token( tok_str, src_file, line );
		}


	command[0] = BASIC_ATTR_COMMAND;
	command[1] = SET_HIDDEN_SYMBOLOGY;
		
	status = fwrite( command, sizeof( uint8 ), 2, out_file );	
	status = fwrite( &hsym, sizeof( struct GRhesym ), 1, out_file );

	return HSplot_success;
	} /* hidden_symbology */
