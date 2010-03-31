#include "odi.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPstruct.h"
#include "HPdef.h"


#define if_token(x) if (!strcmp (token_str, x))

#define	_version		0x0001
#define	_world_to_viewport	0x0002
#define	_sd_rasterfile		0x0004
#define	_sd_textfile		0x0008
#define	_textfile		0x0010
#define	_rasterfile		0x0020
#define	_xysize			0x0040
#define _line_width_constant	0x0080
#define _max_line_width		0x0100
#define _user_line_width	0x0200
#define	_shading_style		0x0400

#define	SIZE_OF_REST (512-2-2-8-2-2-80-80-80-8-8-8-2-2-2)

/*---header_block----------------------------------------------------------*/

int	header_block( src_file, out_file, line )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int	status;				/* return code from called functions */
	int	j;				/* counter */
	int	token;				/* input token */
	char	token_str[200];			/* token string if more than one char */
	uint8	command[2];			/* current command being processed */
	uint16	attrs_seen = 0;			/* flags: attributes seen in input */
	uint8	version[4];			/* version numbers */
	char	rest[SIZE_OF_REST];
	struct HPplotfile_header	header;

	header.world_to_viewport_scale = 1.0;

	/* 
	 * get keyword attributes to end of command ; 
	 */
	 
	token = get_token( token_str, src_file, line );
	while( token != EOF && token != ';' )
		{
		/* 
		 * get version number 
		 */

		if_token( "version" )
			{
			if( _version & attrs_seen ) goto dup_error;
			attrs_seen |= _version;

			for( j=0; j<4; ++j )
				{
				token = get_token( token_str, src_file, line );
				if( token != 'i' )
					{
					fprintf( stderr, "line %d: expected version %d number, got \"%s\"\n",
						*line, j, token_str );
						
					return HSplot_error;
					}
					
				version[j] = atoi( token_str );
				}
			}

		/* 
		 * get world to meters scale factor 
		 */
		 
		else if_token( "world_to_viewport_scale" )
			{
			if( _world_to_viewport & attrs_seen ) goto dup_error;
			attrs_seen |= _world_to_viewport;

			token = get_token( token_str, src_file, line );
			
			status = get_signed_double(	&header.world_to_viewport_scale, 
							&token, 
							token_str,
							src_file, 
							line );
							
			if( status )
				{
				fprintf( stderr, "error getting world to viewport scale, line %1d\n", *line ); 
				return HSplot_error;
				}
			}

		else if_token( "line_width_constant" )
			{
			if( _line_width_constant & attrs_seen ) goto dup_error;
			attrs_seen |= _line_width_constant;

			token = get_token( token_str, src_file, line );
			
			status = get_signed_double(	&header.line_width_constant, 
							&token, 
							token_str,
							src_file, 
							line );
							
			if( status )
				{ 
				fprintf( stderr, "error getting line_width_constant, line %1d\n", *line );
				return HSplot_error;
				}
			}

		else if_token( "max_line_width" )
			{
			if( _max_line_width & attrs_seen ) goto dup_error;
			attrs_seen |= _max_line_width;

			token = get_token( token_str, src_file, line );
			
			header.max_line_width = atoi( token_str );
			}

		else if_token( "user_line_width" )
			{
			if( _user_line_width & attrs_seen ) goto dup_error;
			attrs_seen |= _user_line_width;

			token = get_token( token_str, src_file, line );
			
			header.user_line_width = atoi( token_str );
			}

		else if_token( "shading_style" )
			{
			if( _shading_style & attrs_seen ) goto dup_error;
			attrs_seen |= _shading_style;

			token = get_token( token_str, src_file, line );
			
			header.shading_style = atoi( token_str );
			}

		else if_token( "xsize_ysize" )
			{
			if( _xysize & attrs_seen ) goto dup_error;
			attrs_seen |= _xysize;

			token = get_token( token_str, src_file, line );
			
			status = get_signed_double(	&header.xsize, 
							&token, 
							token_str,
							src_file, 
							line );
							
			if( status )
				{
				fprintf( stderr, "error getting xsize, line %1d\n", *line );
				return HSplot_error;
				}
				
			token = get_token( token_str, src_file, line );
			
			status = get_signed_double(	&header.ysize, 
							&token, 
							token_str,
							src_file, 
							line );
							
			if( status )
				{
				fprintf( stderr, "error getting ysize, line %1d\n", *line );
				return HSplot_error;
				}				
			}

		else if_token( "rasterfile" )
			{
			if( _rasterfile & attrs_seen ) goto dup_error;
			attrs_seen |= _rasterfile;

			token = get_token( token_str, src_file, line );
			if( token == '"' || token == '\'' )
				strcpy( header.rasterfile, token_str );
			else
				{
				fprintf( stderr, "line %d: expected rastfile file, got \"%s\"\n",
						*line, token_str );
						
				return HSplot_error;
				}
			}

		else if_token( "textfile" )
			{
			if( _textfile & attrs_seen ) goto dup_error;
			attrs_seen |= _textfile;

			token = get_token( token_str, src_file, line );
			if( token == '"' || token == '\'' )
				strcpy( header.textfile, token_str );
			else
				{
				fprintf( stderr, "line %d: expected textfile file, got \"%s\"\n",
						*line, token_str );
						
				return HSplot_error;
				}
			}

		else if_token( "save" )
			{
			token = get_token( token_str, src_file, line );
			if_token( "rasterfile" )
				{
				header.save_rasterfile = 1;
				}
			
			else if_token( "textfile" )
				{
				header.save_textfile = 1;
				}
			else
				{
				fprintf( stderr, "line %d: save textfile/rasterfile, got \"%s\"\n",
						*line, token_str );
						
				return HSplot_error;
				}
			}
				
		else if_token( "delete" )
			{
			token = get_token( token_str, src_file, line );
			if_token( "rasterfile" )
				{
				header.save_rasterfile = 0;
				}
			
			else if_token( "textfile" )
				{
				header.save_textfile = 0;
				}
			else
				{
				fprintf( stderr, "line %d: delete textfile/rasterfile, got \"%s\"\n",
						*line, token_str );
						
				return HSplot_error;
				}
			}
				
		/* 
		 * error 
		 */
		 
		else
			{
			fprintf( stderr, "line %d: unknown header attribute \"%s\"\n",
						*line, token_str );
						
			return HSplot_error;
			}

		token = get_token( token_str, src_file, line );
		}

	/* 
	 * check for required things: version 
	 */
	 
	if( !(_version & attrs_seen) )
		{
		fprintf( stderr, "line %d: header version not specified\n", *line );
		return HSplot_error;
		}

	/* 
	 * write command: id, version 
	 */
	 
	command [0] = 'H';
	command [1] = 'S';
		
	header.version = (version[0] & 15) << 12 | (version[1] & 15) << 8 |
			   (version[2] & 15) << 4  | (version[3] & 15);
		      
	status = fwrite( command, sizeof(IGRchar), 2, out_file );
	status = fwrite( &header.version, sizeof(IGRshort), 1, out_file );
	status = fwrite( &header.world_to_viewport_scale, sizeof(IGRdouble), 1, out_file );
	status = fwrite( &header.save_textfile, 2, 1, out_file );
	status = fwrite( &header.save_rasterfile, 2, 1, out_file );
	status = fwrite( header.textfile, sizeof(IGRchar), 80, out_file);
	status = fwrite( header.rasterfile, sizeof(IGRchar), 80, out_file);
	status = fwrite( header.rasterfile, sizeof(IGRchar), 80, out_file);
	status = fwrite( &header.xsize, sizeof(IGRdouble), 1, out_file );
	status = fwrite( &header.ysize, sizeof(IGRdouble) , 1, out_file );
	status = fwrite( &header.line_width_constant, sizeof(IGRdouble), 1, out_file );
	status = fwrite( &header.max_line_width, sizeof(IGRshort), 1, out_file );
	status = fwrite( &header.user_line_width, sizeof(IGRshort), 1, out_file );
	status = fwrite( &header.shading_style, sizeof(IGRshort), 1, out_file );
	status = fwrite( rest, 1, SIZE_OF_REST, out_file );

	return HSplot_success;

dup_error:
	fprintf( stderr, "line %d: duplicate header attribute \"%s\"\n", *line, token_str );
	return HSplot_error;
	}

