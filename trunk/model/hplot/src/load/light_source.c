#include <stdio.h>
#include "odi.h"

#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPstruct.h"
#include "HPdef.h"


#define if_token(x) if (!strcmp (tok_str, x))

/* attributes seen flags */

#define _index		0x0001
#define _parallel	0x0002
#define _point		0x0004
#define	_pencil		0x0008
#define	_spot		0x0010
#define _radius		0x0020
#define _coord		0x0040
#define	_color		0x0080
#define	_location	0x0100
#define _direction	0x0200
#define _angle		0x0300

/*---ight_source--------------------------------------------------------*/

int light_source( src_file, out_file, line, type )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */
int	type;		/* (0)window, (1)global, (2) ambient */

	{
	int	status;		/* return code from called functions */
	int	token;		/* input token */
	char	tok_str[200];	/* token string if more than one char */
	double	coord[3];	/* light point or direction */
	double	dcolor[3];	/* light source color */
	uint8	command[2];	/* current command being processed */
	short	which;		/* which attr was seen */
	char	attrs_seen = 0;	/* flags: attributes seen in input */
	char	which_str[40];	/* string for which attr */

	struct HS_light_source	light;

	/* ------- code ------------------------------------------------------------- */

	/* get keyword attributes to end of command ; */
	
	light.flags |= type == 2 ? 0 : 1;
	light.location[0] = 0.0;
	light.location[1] = 0.0;
	light.location[2] = 0.0;
	light.direction[0] = 0.0;
	light.direction[1] = 0.0;
	light.direction[2] = 0.0;
	light.red = 255;
	light.green = 255;
	light.blue = 255;
	light.radius = 0.0;
	light.angle = 0.0;
	
	token = get_token( tok_str, src_file, line );
	
	token = get_token( tok_str, src_file, line );
	
	while( token != EOF && token != ';' )
		{
		strcpy( which_str, tok_str );
		if_token( "location" )
			{
			which = _location;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, coord, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.location[0] = coord[0];
			light.location[1] = coord[1];
			light.location[2] = coord[2];
			}
		else if_token( "direction" )
			{
			which = _direction;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, coord, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.direction[0] = coord[0];
			light.direction[1] = coord[1];
			light.direction[2] = coord[2];
			}
		else if_token( "color" )
			{
			which = _color;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, dcolor, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.red = (int)dcolor[0];
			light.green = (int)dcolor[1];
			light.blue = (int)dcolor[2];			
			}
		else if_token( "radius" )
			{
			which = _radius;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 1, &light.radius, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			}
		else if_token( "angle" )
			{
			which = _angle;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 1, &light.angle, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			}
		else if_token( "parallel" )
			{
			which = _parallel;
			light.flags |= HS_LIGHT_PARALLEL;
			}
		else if_token( "point" )
			{
			which = _point;
			light.flags |= HS_LIGHT_POINT;
			}
		else if_token( "spot" )
			{
			which = _spot;
			light.flags |= HS_LIGHT_SPOT;
			}
		else if_token( "pencil" )
			{
			which = _pencil;
			light.flags |= HS_LIGHT_PENCIL;
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


	command[0] = SETUP_COMMAND;
	switch( type )
		{
		case 2:
			command[1] = SET_AMBIENT_LIGHT_SOURCE;
			break;
			
		case 1:
			command[1] = SET_GLOBAL_LIGHT_SOURCE;
			break;
			
		case 0:
			command[1] = SET_WINDOW_LIGHT_SOURCE;
			break;
		}
		
	status = fwrite( command, sizeof( uint8 ), 2, out_file );
	
	status = fwrite( &light, sizeof( struct HS_light_source ), 1, out_file );

	return HSplot_success;
	} /* light_source */

/*---old_light_source--------------------------------------------------------*/

int old_light_source( src_file, out_file, line, type )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */
int	type;		/* (0)window, (1)global, (2) ambient */

	{
	int	status;		/* return code from called functions */
	int	token;		/* input token */
	char	tok_str[200];	/* token string if more than one char */
	double	coord[3];	/* light point or direction */
	double	dcolor[3];	/* light source color */
	uint8	command[2];	/* current command being processed */
	short	which;		/* which attr was seen */
	char	attrs_seen = 0;	/* flags: attributes seen in input */
	char	which_str[40];	/* string for which attr */

	struct HS_old_light_source	light;

	/* ------- code ------------------------------------------------------------- */

	/* get keyword attributes to end of command ; */
	
	light.index = 0;
	light.type = type == 2 ? 0 : 1;
	light.location[0] = 0.0;
	light.location[1] = 0.0;
	light.location[2] = 0.0;
	light.direction[0] = 0.0;
	light.direction[1] = 0.0;
	light.direction[2] = 0.0;
	light.red = 255;
	light.green = 255;
	light.blue = 255;
	light.radius = 0.0;
	light.angle = 0.0;
	
	token = get_token( tok_str, src_file, line );
	
	token = get_token( tok_str, src_file, line );
	
	while( token != EOF && token != ';' )
		{
		strcpy( which_str, tok_str );
		if_token( "index" )
			{
			which = _index;
			token = get_token( tok_str, src_file, line );
			light.index = atoi( tok_str );
			}
		else if_token( "location" )
			{
			which = _location;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, coord, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.location[0] = coord[0];
			light.location[1] = coord[1];
			light.location[2] = coord[2];
			}
		else if_token( "direction" )
			{
			which = _direction;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, coord, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.direction[0] = coord[0];
			light.direction[1] = coord[1];
			light.direction[2] = coord[2];
			}
		else if_token( "color" )
			{
			which = _color;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, dcolor, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.red = (int)dcolor[0];
			light.green = (int)dcolor[1];
			light.blue = (int)dcolor[2];			
			}
		else if_token( "radius" )
			{
			which = _radius;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 1, &light.radius, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			}
		else if_token( "angle" )
			{
			which = _angle;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 1, &light.angle, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			}
		else if_token( "parallel" )
			{
			which = _parallel;
			light.type = 1;
			}
		else if_token( "point" )
			{
			which = _point;
			light.type = 2;
			}
		else if_token( "spot" )
			{
			which = _point;
			light.type = 3;
			}
		else if_token( "pencil" )
			{
			which = _point;
			light.type = 4;
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


	command[0] = SETUP_COMMAND;
	switch( type )
		{
		case 2:
			command[1] = SET_AMBIENT_LIGHT_SOURCE;
			break;
			
		case 1:
			command[1] = SET_GLOBAL_LIGHT_SOURCE;
			break;
			
		case 0:
			command[1] = SET_WINDOW_LIGHT_SOURCE;
			break;
		}
		
	status = fwrite( command, sizeof( uint8 ), 2, out_file );
	
	status = fwrite( &light, sizeof( struct HS_old_light_source ), 1, out_file );

	return HSplot_success;
	} /* old_light_source */


/*---old_old_light_source----------------------------------------------------------*/

int old_old_light_source( src_file, out_file, line, type )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */
int	type;		/* (0)window, (1)global, (2) ambient */

	{
	int	status;		/* return code from called functions */
	int	token;		/* input token */
	char	tok_str[200];	/* token string if more than one char */
	double	coord[3];	/* light point or direction */
	double	dcolor[3];	/* light source color */
	uint8	command[2];	/* current command being processed */
	short	which;		/* which attr was seen */
	char	attrs_seen = 0;	/* flags: attributes seen in input */
	char	which_str[40];	/* string for which attr */

	struct HS_old_old_light_source	light;

	/* ------- code ------------------------------------------------------------- */

	/* get keyword attributes to end of command ; */
	
	light.index = 0;
	light.type = type == 2 ? 0 : 1;
	light.x = 0.0;
	light.y = 0.0;
	light.z = 0.0;
	light.red = 255;
	light.green = 255;
	light.blue = 255;
	light.radius = 0.0;
	
	token = get_token( tok_str, src_file, line );
	
	token = get_token( tok_str, src_file, line );
	while( token != EOF && token != ';' )
		{
		strcpy( which_str, tok_str );
		if_token( "index" )
			{
			which = _index;
			token = get_token( tok_str, src_file, line );
			light.index = atoi( tok_str );
			}
		else if_token( "coord" )
			{
			which = _coord;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, coord, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.x = coord[0];
			light.y = coord[1];
			light.z = coord[2];
			}
		else if_token( "color" )
			{
			which = _color;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 3, dcolor, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			
			light.red = (int)dcolor[0];
			light.green = (int)dcolor[1];
			light.blue = (int)dcolor[2];			
			}
		else if_token( "radius" )
			{
			which = _radius;
			token = get_token( tok_str, src_file, line );
			status = get_doubles( 1, &light.radius, &token, tok_str, src_file, NULL, line );
			if( status ) return HSplot_error;;
			}
		else if_token( "point" )
			{
			which = _point;
			light.type = 2;
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


	command[0] = SETUP_COMMAND;
	switch( type )
		{
		case 2:
			command[1] = OLD_AMBIENT_LIGHT_SOURCE;
			break;
			
		case 1:
			command[1] = OLD_GLOBAL_LIGHT_SOURCE;
			break;
			
		case 0:
			command[1] = OLD_WINDOW_LIGHT_SOURCE;
			break;
		}
		
	status = fwrite( command, sizeof( uint8 ), 2, out_file );
	
	status = fwrite( &light, sizeof( struct HS_old_old_light_source ), 1, out_file );

	return HSplot_success;
	} /* old_old_light_source */

