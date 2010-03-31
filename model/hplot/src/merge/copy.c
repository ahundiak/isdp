#include <stdio.h>
#include "odi.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hplot.h"
#include "HStl_window.h"
#include "HPstruct.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "hpmsg.h"

extern int debug;

/*---copy--------------------------------------------------*/

int	copy( infil, outfil, flag )

FILE	*infil, *outfil;
int	flag;
	
	{
	int		status;		/* return code from called functions */
	char		ch, *cptr;	/* for reading char strings */

	/* element structures -- these must be static as we either return the address */
	/*   of same (buffers) or they are used for buffer pointers and alloc sizes */

	static struct HS_light_source			light_src;
	static struct HS_old_light_source		old_light_src;
	static struct HPnurb_surface_struct		surf;	/* a bspline surface */
	static struct IGRbsp_curve			line_poly;
	static struct IGRbsp_curve			curve;		/* a bspline curve */
	static HPsimple_union				simple;		/* simple data types */

	static int	num_ls_knots = 0;
	static int	num_ls_pole_verts = 0;

	static char	*char_buffer_ptr = NULL;	/* a char buffer and size */
	static int	char_buffer_size = 0;
	static short	*short_buffer_ptr = NULL;	/* a short buffer and size */
	static int	short_buffer_size = 0;
	static double	matrix[16];			/* a 4x4 or 3x3 transformation matrix */
	static double	clips[6];			/* diagonal points of clip box */
	static short	rgb[3];				/* red, green, blue color values */
	static double	range[6];

	static int	commands_processed	= 0;	/* counter of commands processed */
	static char	initialized 		= 0;	/* been here flag */
	static long	length;
	static int	surface_count = 0;
	static int	curve_count = 0;

	int		surface_type;
	char		view_number;
	short		level;
	char		command[2];

	/* 
	 * initialize some stuff 
	 */
	
	if( !initialized )
		{
		initialized = 1;
		
		memset( &light_src,   0, sizeof( struct HS_light_source ) );
		memset( &curve,       0, sizeof( curve ) );
		memset( &surf,        0, sizeof( surf ) );
		
		char_buffer_size = 32 * 4;
		char_buffer_ptr = (char *)calloc( 1, char_buffer_size );
		
		line_poly.order = 2;
		line_poly.non_uniform = FALSE;
		line_poly.rational = FALSE;
		line_poly.weights = NULL;
		line_poly.num_boundaries = 0;
		line_poly.bdrys = NULL;
		}

	/* 
	 * read command type, read rest of command, return it 
	 */
	 
	level = 0;
	
	status = fread( command, sizeof(char), 2, infil );
	if( status <= 0 ) return 1;

	if( flag == 1 &&
	   ((command[0] == SETUP_COMMAND      && command[1] == SET_COLOR_TABLE_RGB) ||
	    (command[0] == SETUP_COMMAND      && command[1] == SET_WINDOW_LIGHT_SOURCE) ||
	    (command[0] == SETUP_COMMAND      && command[1] == SET_GLOBAL_LIGHT_SOURCE) ||
	    (command[0] == SETUP_COMMAND      && command[1] == SET_AMBIENT_LIGHT_SOURCE) ||
	    (command[0] == SETUP_COMMAND      && command[1] == SET_VIEW_ORIENTATION_RANGE) ||
	    (command[0] == BASIC_ATTR_COMMAND && command[1] == SET_ACTIVE_ROTATION_MATRIX) ||
	    (command[0] == BASIC_ATTR_COMMAND && command[1] == SET_ACTIVE_POST_ROTATION_MATRIX) ))
	    	{
		}
	else
		{
		status = fwrite( command, sizeof(char), 2, outfil );
		}

	/* process individual command */

	switch( command[0] )
		{
		case SETUP_COMMAND:
			switch( command[1] )
				{
				case SET_COLOR_TABLE_RGB:
					status = copy_ctbl( infil, outfil, flag );
					break;
						
				case SET_TRANSLUCENCY_GRID:
					status = fread(	(char *)&simple.i8, 
							sizeof( simple.i8 ),
							1, 
							infil );
								
					status = fwrite((char *)&simple.i8, 
							sizeof( simple.i8 ),
							1, 
							outfil );
					break;
						
				case SET_DEPTH_CUE_INTENSITIES:
					status = fread(	(char *)char_buffer_ptr, 
							sizeof( char ),
							2, 
							infil );
							
					status = fwrite((char *)char_buffer_ptr, 
							sizeof( char ),
							2, 
							outfil );
					break;
							
				case SET_WINDOW_LIGHT_SOURCE:
				case SET_GLOBAL_LIGHT_SOURCE:
				case SET_AMBIENT_LIGHT_SOURCE:
					status = fread(	&light_src,
							sizeof( struct HS_light_source ),
							1, 
							infil );
							
					if( flag == 0 )
					status = fwrite(&light_src,
							sizeof( struct HS_light_source ),
							1, 
							outfil );
					break;

				case OLD_WINDOW_LIGHT_SOURCE:
				case OLD_GLOBAL_LIGHT_SOURCE:
				case OLD_AMBIENT_LIGHT_SOURCE:
					status = fread(	&old_light_src,
							sizeof( struct HS_old_light_source ),
							1, 
							infil );
							
					if( flag == 0 )
					status = fwrite(&old_light_src,
							sizeof( struct HS_old_light_source ),
							1, 
							outfil );
					break;

				case SET_VIEW_ORIENTATION_RANGE:
					status = fread(	&view_number,
							sizeof( view_number ), 
							1, 
							infil );
					
					if( flag == 0 )		
					status = fwrite(&view_number,
							sizeof( view_number ), 
							1, 
							outfil );
				
					status = fread( matrix, 
							sizeof( double ), 
							16, 
							infil );
							
					if( flag == 0 )		
					status = fwrite(matrix, 
							sizeof( double ), 
							16, 
							outfil );
		
					status = fread( range, 
							sizeof( double ), 
							6, 
							infil );
								
					if( flag == 0 )		
					status = fwrite(range, 
							sizeof( double ), 
							6, 
							outfil );
					break;
						
				case SET_VIEW_IN_PARALLEL:
				case SET_VIEW_IN_PERSPECTIVE:
					break;
						
				default:
					goto unknown_cmd;
					break;
				}
			break;
				
		case BASIC_ATTR_COMMAND:
			switch( command[1] )
				{
				case SET_ACTIVE_FG_COLOR_INDEX:
					status = fread(	&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							infil );
								
					status = fwrite(&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							outfil );
					break;
						
				case SET_ACTIVE_LINE_STYLE:
					status = fread(	&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							infil );
								
					simple.i16 = 5;
					status = fwrite(&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							outfil );
					break;
					
				case SET_ACTIVE_TILING_TOLERANCE:
					status = fread( &simple.f64,
							sizeof( simple.f64 ),
							1,
							infil );
							
					status = fwrite(&simple.f64,
							sizeof( simple.f64 ),
							1,
							outfil );
							
					break;
											
				case SET_ACTIVE_SHADING_ACCURACY:
					status = fread(	&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							infil );
								
					status = fwrite(&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							outfil );
					break;
											
				case SET_ACTIVE_LINE_WIDTH:
					status = fread(	&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							infil );
								
					status = fwrite(&simple.i16, 
							sizeof( simple.i16 ),
							1, 
							outfil );
					break;
											
				case SET_ACTIVE_RENDERING_MODE:
					status = fread(	&simple.i8, 
							sizeof( simple.i8 ),
							1, 
							infil );
								
					simple.i8 = 6; /* change to styled raster */
					status = fwrite(&simple.i8, 
							sizeof( simple.i8 ),
							1, 
							outfil );
					break;
						
				case SET_ACTIVE_TRANSLUCENCY:
					status = fread(	&simple.i8, 
							sizeof( simple.i8 ),
							1, 
							infil );
								
					status = fwrite(&simple.i8, 
							sizeof( simple.i8 ),
							1, 
							outfil );
					break;
						
				case SET_ACTIVE_ROTATION_MATRIX:
					status = fread( matrix, 
							sizeof( double ), 
							16, 
							infil );

					if( flag == 0 )
					status = fwrite(matrix, 
							sizeof( double ), 
							16, 
							outfil );
					break;
		
				case SET_ACTIVE_POST_ROTATION_MATRIX:
					status = fread( matrix, 
							sizeof( double ), 
							16, 
							infil );

					if( flag == 0 )
					status = fwrite(matrix, 
							sizeof( double ), 
							16, 
							outfil );
					break;
		
				default:
					goto unknown_cmd;
					break;
				}
			break;
				
		case DRAW_PRIMITIVE_COMMAND:
			
			status = fread( &level, 
					sizeof( short ), 
					1, 
					infil );
						
			status = fwrite(&level, 
					sizeof( short ), 
					1, 
					outfil );
				
			switch( command[1] )
				{
				case DRAW_NURB_CURVE:
					if( debug )
					if( ((++curve_count) % debug) == 0 )
					fprintf( stderr, "curve #%1d\n", curve_count );
					status = copy_nurb_curve(
							infil, outfil,
							3, flag );
					break;
						
				case DRAW_NURB_SURFACE:
					if( debug )
					if( ((++surface_count) % debug) == 0 )
					fprintf( stderr, "surface #%1d\n", surface_count );
					status = copy_nurb_surface(
							infil, outfil, flag ); 
					break;
						
				default:
					goto unknown_cmd;
					break;
				}
			break;
				
		default:
			
			/* 
			 * error -- unknown command type 
			 */
			goto unknown_cmd;
			break;
		}
		
	return 0;

/*--- unknown command error ------------------------------------------*/

unknown_cmd:
	printf( "unknown command\n" );
	return 1;
	}
