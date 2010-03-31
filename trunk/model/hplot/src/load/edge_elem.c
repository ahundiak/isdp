#include "odi.h"
#include <stdio.h>
#include "ems_plot_def.h"
#include "HPdef.h"

#define is_token(x) (!strcmp (token_str, x))
#define if_token(x) if (is_token (x))

/* attributes seen flags */

# define _order		1
# define _knots		2
# define _weights	4
# define _poles		8
# define _periodic	16
# define _non_uniform	32
# define _rational	64
# define _planar	128
# define _closed	256
# define _level		512
# define _range		1024
# define _soo		2048

/*---edge_element---------------------------------------------------------*/

int	edge_element( src_file, out_file, line, end_token )

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */
int	end_token;	/* token to end with */

	{
	int		status;		/* return code from called functions */
	int		token;		/* input token */
	char		token_str[200];	/* token string if more than one char */
	int		lct = 1;	/* local source line counter for second pass */
	long		pole_pos = 0;	/* file position for poles */
	long		knot_pos = 0;	/* file position for knots */
	long		soo_pos = 0;
	long		weight_pos = 0;	/* file position for weights */
	uint32		num_poles = 0;	/* number of poles */
	uint8		command[2];	/* current command being processed */
	uint16		level = 0;	/* graphic level */
	uint16		order = 0;	/* spline order */
	uint16		flags = 0;	/* edge flags */
	uint16		num_knots = 0;	/* number of knots */
	uint16		num_weights = 0;/* number of weights */
	uint32		num_soos = 0;
	uint16		attrs_seen = 0;	/* flags: attributes seen in input */
	real64		range [6];	/* range if element has it */
	int		tmp;

	/* 
	 *  get keyword attributes to end of command ; 
	 */
	 
	token = get_token( token_str, src_file, line );
	while( token != EOF && token != end_token )
		{

		/* 
		 * save position in case of no-keyword pole specification 
		 */
		 
		if( !(_poles & attrs_seen)) pole_pos = ftell(src_file);

		/* 
		 * get level number, save value 
		 */
		 
		if( is_token("level") || is_token("group") )
			{
			if( end_token != ';' )
				{
				fprintf( stderr, "line %d: %s not allowed\n", *line, token_str );
				return HSplot_error;
				}
				
			if( _level & attrs_seen ) goto dup_error;

			attrs_seen |= _level;

			token = get_token( token_str, src_file, line );
			if( token != 'i' )
				{
				fprintf( stderr, "line %d: expected level number, got \"%s\"\n",
							*line, token_str );
				return HSplot_error;
				}
				
			level = atoi( token_str );
			}

		/* 
		 *  range box, 2 points 
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

			token = get_token( token_str, src_file, line);
			status = get_doubles(	3,
						&range[3], 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;
			}

		/* 
		 *  get order number, save value 
		 */
		 
		else if_token( "order" )
			{
			if( _order & attrs_seen ) goto dup_error;
			attrs_seen |= _order;

			token = get_token( token_str, src_file, line );
			if( token != 'i' )
				{
				fprintf( stderr, "line %d: expected order value, got \"%s\"\n",
							*line, token_str);
				return HSplot_error;
				}

			order = atoi( token_str );
			}

		/* 
		 *  get number of poles, no write 
		 */
		 
		else if_token( "poles" )
			{
			if( _poles & attrs_seen ) goto dup_error;
			attrs_seen |= _poles;

			pole_pos = ftell( src_file );
			token = get_token( token_str, src_file, line );
			if( end_token == ';' )
				status = get_points(	&num_poles, 
							&token, 
							token_str, 
							src_file,
							NULL, 
							line, 
							end_token );
							
			else
				status = get_pairs( 	&num_poles, 
							&token, 
							token_str, 
							src_file,
							NULL, 
							line );
							
			if( status ) return HSplot_error;
			continue;
			}

		/* 
		 *  get number of poles, no write 
		 */
		 
		else if_token( "soo" )
			{
			if( _soo & attrs_seen ) goto dup_error;
			attrs_seen |= _soo;
			flags |= CV_HAS_SOO;

			soo_pos = ftell( src_file );
			token = get_token( token_str, src_file, line );
			status = get_soos(	&num_soos, 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line, 
						end_token );
						
			if( status ) return HSplot_error;
			}

		/* 
		 *  get number of knots, no write 
		 */
		 
		else if_token( "knots" )
			{
			if( _knots & attrs_seen ) goto dup_error;
			attrs_seen |= _knots;

			knot_pos = ftell( src_file );
			token = get_token( token_str, src_file, line );

			status = get_run(	&num_knots, 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;
			continue;
			}

		/* 
		 *  get number of weights, no write 
		 */
		 
		else if_token( "weights" )
			{
			if( _weights & attrs_seen ) goto dup_error;
			attrs_seen |= _weights;

			weight_pos = ftell( src_file );
			token = get_token( token_str, src_file, line );
			
			status = get_run(	&num_weights, 
						&token, 
						token_str, 
						src_file,
						NULL, 
						line );
						
			if( status ) return HSplot_error;
			continue;
			}

		/* flags */
		
		else if_token( "periodic" )
			{
			attrs_seen |= _periodic;
			flags |= CV_PERIODIC_M;
			}
			
		else if_token( "non_uniform" )
			{
			attrs_seen |= _non_uniform;
			flags |= CV_NON_UNIFORM_M;
			}
			
		else if_token( "rational" )
			{
			attrs_seen |= _rational;
			flags |= CV_RATIONAL_M;
			}
			
		else if_token( "planar" )
			{
			attrs_seen |= _planar;
			flags |= CV_PLANAR_M;
			}
			
		else if_token( "closed" )
			{
			attrs_seen |= _closed;
			flags |= CV_PHY_CLOSED_M;
			}

		/* 
		 *  get number of poles, no write 
		 */
		 
		else
			{
			if( _poles & attrs_seen ) goto dup_error;
			attrs_seen |= _poles;

			if( end_token == ';')
				status = get_points(	&num_poles, 
							&token, 
							token_str, 
							src_file,
							NULL, 
							line, 
							end_token );
							
			else
				status = get_pairs(	&num_poles, 
							&token, 
							token_str, 
							src_file,
							NULL, 
							line );
							
			if( status ) return HSplot_error;
			continue;
			}
			
		token = get_token( token_str, src_file, line );
		}

	/* 
	 *  check for required things: order and poles 
	 */
	 
	if( !( _order & attrs_seen ) )
		{
		fprintf( stderr, "line %d: edge order not specified\n", *line );
		return HSplot_error;
		}

	if( !( _poles & attrs_seen ) )
		{
		fprintf( stderr, "line %d: no pole for edge\n", *line );
		return HSplot_error;
		}

	/* 
	 *  need knots if non-uniform 
	 */

	if( _non_uniform & attrs_seen )
		{
		if( num_knots !=( order + num_poles ) )
			{
			fprintf( stderr, "line %d: need %d knots for edge\n", *line,
					order+num_poles );
			return HSplot_error;
			}
		}

	/* 
	 *  need weights if rational 
	 */
	 
	if( _rational & attrs_seen )
		{
		if( num_weights != num_poles )
			{
			fprintf( stderr, "line %d: need %d weights for edge\n", *line,
					num_poles);
			return HSplot_error;
			}
		}

	/* 
	 * write command: id, level, order, flags, number of poles 
	 */
	 
	if( end_token == ';' )
		{
		command [0] = PRIMITIVE_COMMAND;
		command [1] = NURB_EDGE;

		status = fwrite( command, sizeof(uint8), 2, out_file );
		if( status <= 0 ) return HSplot_error;

		status = fwrite( &level, sizeof(level), 1, out_file );
		if( status <= 0 ) return HSplot_error;
		if( _range & attrs_seen )
			{
			status = fwrite( range, sizeof(real64), 6, out_file );
			if( status <= 0) return HSplot_error;
			}
		}
		
	status = fwrite( &order, sizeof(order), 1, out_file );
	if( status <= 0 ) return HSplot_error;
	
	status = fwrite( & flags, sizeof( flags), 1, out_file );
	if( status <= 0 ) return HSplot_error;
	
	status = fwrite( & num_poles, sizeof( num_poles), 1, out_file );
	if( status <= 0 ) return HSplot_error;

	/* 
	 *  write poles 
	 */
	 
	status = fseek( src_file, pole_pos, 0 );
	token = get_token( token_str, src_file, & lct );
	if( end_token == ';')
		status = get_points(	NULL, 
					&token, 
					token_str, 
					src_file, 
					out_file, 
					&lct,
					end_token );
	else
		status = get_pairs(	NULL, 
					&token, 
					token_str, 
					src_file, 
					out_file, 
					&lct );
					
	if( status ) return HSplot_error;

	/* 
	 *  write knots if needed 
	 */
	 
	if( _non_uniform & attrs_seen )
		{
		status = fseek( src_file, knot_pos, 0 );
		token = get_token( token_str, src_file, &lct );
		
		status = get_run( 	NULL, 
					&token, 
					token_str, 
					src_file, 
					out_file, 
					&lct );
					
		if( status ) return HSplot_error;
		}

	/* 
	 *  write weights if needed 
	 */
	 
	if( _rational & attrs_seen )
		{
		status = fseek( src_file, weight_pos, 0 );
		token = get_token( token_str, src_file, &lct );
		
		status = get_run(	NULL, 
					&token, 
					token_str, 
					src_file, 
					out_file, 
					&lct );
					
		if( status ) return HSplot_error;
		}

	if( _soo & attrs_seen )
		{
		tmp = num_soos;
		status = fwrite( &tmp, sizeof(int), 1, out_file );
		if( status <= 0 ) return HSplot_error;

		status = fseek( src_file, soo_pos, 0 );
		token = get_token( token_str, src_file, & lct );
		status = get_soos(	NULL, 
					&token, 
					token_str, 
					src_file, 
					out_file, 
					&lct,
					end_token );
		}
		
	/* 
	 *  done 
	 */
	 
	return HSplot_success;

dup_error:
	fprintf( stderr, "line %d: duplicate edge attribute \"%s\"\n",
			*line, token_str );
			
	return HSplot_error;
	}
