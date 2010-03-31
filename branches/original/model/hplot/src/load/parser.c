#include <stdio.h>
#include "odi.h"
#include "HPdef.h"

#define	HPload_F_WRITERR	-1
#define	HPload_F_READERR	-2
#define	HPload_F_SEEKERR	-3


#define if_token(x) if (!strcmp (token_str, x))


/*---ems_metafile_parser---------------------------------------*/

int	ems_metafile_parser( src_file, out_file )

FILE	 *src_file;	/* source file pointer */
FILE	 *out_file;	/* output file pointer */

	{
	int		status;			/* return code from called functions */
	int		token;			/* input token */
	int		cmds_processed = 0;	/* counter of cmds processed */
	int		line = 1;		/* source line counter */
	int		at_line= 0;		/* saved source line number */
	int		errors = 0;		/* error counter */
	char		at_tok[200];		/* saved token str */
	char		token_str[200];	/* token string if more than one char */
	uint8		command[2];		/* current command being processed */
	char		found_header = 0;	/* flag, found header record */

	extern char	debug_flag;


	/* 
	 *  get first token, process it, read another until end of file 
	 */

	token = get_token( token_str, src_file, &line );
	for(;;)
		{
		status = HSplot_success;
		switch( token )
			{
			case EOF:
				if( !found_header )
					{
					fprintf( stderr, "line %d: header not found\n", line );
					++errors;
					}

				if( debug_flag )
					fprintf( stderr, "processed %d commands.  %d errors.\n",
						cmds_processed, errors );
						
				if( errors ) return HSplot_error;
				return HSplot_success;

			case ',':
			case ';':
				break;

			case 'w':
				at_line = line;
				strcpy( at_tok, token_str );
				if_token( "header" )
					{
					if( cmds_processed )
						{
						fprintf( stderr, "line %d: header must be first\n", line );
						++errors;
						}
						
					found_header = 1;
					status = header_block( src_file, out_file, &line );
					break;
					}
					
				else if_token( "view" )
					{
					status = set_view_data( src_file, out_file, &line );
					break;
					}
					
				else if_token( "hidden_symbology" )
					{
					status = hidden_symbology( src_file, out_file, &line );
					break;
					}
					
				else if_token( "user_line_style" )
					{
					status = user_line_style( src_file, out_file, &line );
					break;
					}
					
				else if_token( "color" )
					{
					status = color_table( src_file, out_file, &line );
					break;
					}
					
				else if_token( "tiling_tolerance" )
					{
					status = tiling_tolerance( src_file, out_file, &line );
					break;
					}
					
				else if_token( "shading_accuracy" )
					{
					status = shading_accuracy( src_file, out_file, &line );
					break;
					}
					
				else if_token( "depth" )
					{
					status = depth_cues( src_file, out_file, &line );
					break;
					}
					
				else if_token( "parallel" ) 
					{
					while( token != ';' )
						token = get_token( token_str, src_file, &line );
					 				  
					command[0] = SETUP_COMMAND;
					command[1] = SET_VIEW_IN_PARALLEL;
					status = fwrite( command, sizeof(uint8), 2, out_file );
				  
					status = HSplot_success;
					break;
					}
					
				else if_token( "perspective" )
					{
					while( token != ';' )
						token = get_token( token_str, src_file, &line );
					
					command[0] = SETUP_COMMAND;
					command[1] = SET_VIEW_IN_PERSPECTIVE;
					status = fwrite( command, sizeof(uint8), 2, out_file );
					
					status = HSplot_success;
					break;
					}
					
				else if_token( "window" )
					{
					status = light_source( src_file, out_file, &line, 0 );
					break;
					}
					
				else if_token( "global" )
					{
					status = light_source( src_file, out_file, &line, 1 );
					break;
					}
					
				else if_token( "ambient" )
					{
					status = light_source( src_file, out_file, &line, 2 );
					break;
					}
					
				else if_token( "foreground" )
					{
					status = set_color( 'f', src_file, out_file, &line );
					break;
					}
					
				else if_token( "rendering" )
					{
					status = rendering_mode( src_file, out_file, &line );
					break;
					}
					
				else if_token( "translucency" )
					{
					status = translucency( src_file, out_file, &line );
					break;
					}
					
				else if_token( "viewport_to_wld" )
					{
					status = viewport_to_wld( src_file, out_file, &line );
					break;
					}
					
				else if_token( "rotation" )
					{
					status = rotation( src_file, out_file, &line );
					break;
					}
					
				else if_token( "post" )
					{
					status = post_rotation( src_file, out_file, &line );
					break;
					}
					
				else if_token( "line" )
					{
					status = line_element( src_file, out_file, &line );
					break;
					}
				else if_token( "edge" )
					{
					status = edge_element( src_file, out_file, &line, ';' );
					break;
					}
					
				else if_token( "curve" )
					{
					status = curve_element( src_file, out_file, &line, ';' );
					break;
					}
					
				else if_token( "surface" )
					{
					status = surface_element( src_file, out_file, &line );
					break;
					}
					
			 default:
				status = HSplot_error;
				fprintf (stderr, "line %d: unknown command \"%s\"\n",
					 line, token_str);
				break;
			}

		if( status )
			{
			if( debug_flag > 1 )
				fprintf( stderr, "line %d tok %s\n", at_line, at_tok );
				
			++errors;
			
			do
				token = get_token( token_str, src_file, &line );
			while( token != EOF && token != ';' );
			}
		else
			{
			++cmds_processed;
			token = get_token( token_str, src_file, &line );
			}
		 }
	}
