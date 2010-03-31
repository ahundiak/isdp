#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"

static int bbound = 0;

static struct IGRbsp_surface		*surface;
static struct IGRbsp_curve		*bdry_curves;
static struct IGRbsp_curve		*bdry_curve_ptr;
static int				curves_size;
static int				surface_type;
static int				first_time = 1;

#define		SF_U_PERIODIC_M		0x0001
#define		SF_V_PERIODIC_M		0x0002
#define		SF_U_NON_UNIFORM_M	0x0004
#define		SF_V_NON_UNIFORM_M	0x0008
#define		SF_RATIONAL_M		0x0010
#define		SF_PLANAR_M		0x0020
#define		SF_U_CLOSED_M		0x0040
#define		SF_V_CLOSED_M		0x0080
#define		SF_ORIENTATION_M	0x0100
#define		SF_SOLID_HOLE_M		0x0200

extern int debug;
static int bcount = 0;

/*--- copy_nurb_surface --------------------------------------------------*/

int	copy_nurb_surface( infil, outfil )

FILE	*infil, *outfil;


	{
	int		status;		/* return code from called functions */
	int		nec_pole_size;	/* necesary pole size (u * v * sizeof) */
	short		flags;		/* flags word as read from file */
	int		i;		/* counter */
	int		num_poles;	/* total number of poles (u * v) */
	short		sf_type;	/* surface type code */

	int		surf_pole_size;	/* size of surf poles buffer (in points) */
	int		u_knot_size;	/* size of surf knots buffer -- u direction */
	int		v_knot_size;	/* size of surf knots buffer -- v direction */
	int		weight_size;	/* size of surf weights buffer */
	
	int		nb;

	extern double	*malloc();


	if( first_time )
		{
		first_time = 0;
		surface = (struct IGRbsp_surface *)malloc( sizeof( struct IGRbsp_surface ) );
		memset( surface, 0, sizeof( struct IGRbsp_surface ) );
		}
		
	/* 
	 *  free old boundaries, if any 
	 */

	if( surface->bdrys )
		{
		for( i=0; i<surface->num_boundaries; i++ )
			if( (char *)surface->bdrys[i].points )
				{
				free( (char *)surface->bdrys[i].points );
				}

		free( (char *)surface->bdrys );
		surface->bdrys = NULL;
		}

	/* 
	 *  calculate current buffer sizes == surf number 
	 *  rounded up to nearest 100 
	 */

	surf_pole_size = ( (surface->u_num_poles * surface->v_num_poles + 99) / 100 ) * 100;

	u_knot_size = ( (surface->u_num_knots + 99) / 100 ) * 100;
	v_knot_size = ( (surface->v_num_knots + 99) / 100 ) * 100;

	if( surface->weights )
		weight_size = surf_pole_size;
	else
		weight_size = 0;

	/* 
	 *  read order 
	 */

	status = fread( (char *)&surface->u_order, sizeof(short), 1, infil );
	status = fwrite((char *)&surface->u_order, sizeof(short), 1, outfil );

	status = fread( (char *)&surface->v_order, sizeof(short), 1, infil );
	status = fwrite((char *)&surface->v_order, sizeof(short), 1, outfil );


	/* 
	 *  read flags and distribute them 
	 */

	status = fread( (char *)&flags, sizeof(short), 1, infil );
	status = fwrite((char *)&flags, sizeof(short), 1, outfil );
	
	surface->u_periodic	= (flags & SF_U_PERIODIC_M) != 0;
	surface->v_periodic	= (flags & SF_V_PERIODIC_M) != 0;
	surface->u_non_uniform	= (flags & SF_U_NON_UNIFORM_M) != 0;
	surface->v_non_uniform	= (flags & SF_V_NON_UNIFORM_M) != 0;
	surface->rational	= (flags & SF_RATIONAL_M) != 0;
	surface->planar		= (flags & SF_PLANAR_M) != 0;
	surface->u_phy_closed	= (flags & SF_U_CLOSED_M) != 0;
	surface->v_phy_closed	= (flags & SF_V_CLOSED_M) != 0;
	surface->pos_orient	= (flags & SF_ORIENTATION_M) != 0;
	surface->on_off		= (flags & SF_SOLID_HOLE_M) != 0;


	/*
	 *  Read surface type
	 */
	 	
	status = fread( (char *)&sf_type, sizeof(short), 1, infil );	
	status = fwrite((char *)&sf_type, sizeof(short), 1, outfil );	

	surface_type = sf_type;


	/* 
	 *  read number of poles 
	 */
	
	status = fread( (char *)&surface->u_num_poles, sizeof(long), 1, infil );
	status = fwrite((char *)&surface->u_num_poles, sizeof(long), 1, outfil );
	
	status = fread( (char *)&surface->v_num_poles, sizeof(long), 1, infil );
	status = fwrite((char *)&surface->v_num_poles, sizeof(long), 1, outfil );
	

	/* 
	 *  read the number of boundaries 
	 */
	
	status = fread( (char *)&surface->num_boundaries, sizeof(short), 1, infil );
	status = fwrite((char *)&surface->num_boundaries, sizeof(short), 1, outfil );
	

	/* 
	 *  check that poles will fit in buffer provided, alloc new if not 
	 */
	
	num_poles = surface->u_num_poles * surface->v_num_poles;
	nec_pole_size = num_poles * 3;
	
	if( num_poles > surf_pole_size )
		{
		surf_pole_size = ( (num_poles + 99) / 100 ) * 100;
		
		if( surface->poles ) free( (char *)surface->poles );
		
		surface->poles = malloc( surf_pole_size * 3 * sizeof(double) );		
		}

	/* 
	 *  read poles 
	 */
	
	status = fread( (char *)surface->poles, sizeof(double), nec_pole_size, infil );
	status = fwrite((char *)surface->poles, sizeof(double), nec_pole_size, outfil );
	

	/* 
	 *  check that the u-knots will fit in buffer provided, 
	 *  alloc new if not 
	 */
	
	surface->u_num_knots = surface->u_order + surface->u_num_poles;
	
	if( surface->u_num_knots > u_knot_size )
		{
		u_knot_size = ((surface->u_num_knots + 99) / 100) * 100;
		
		if( surface->u_knots ) free( (char *)surface->u_knots );

		surface->u_knots = malloc( u_knot_size * sizeof(double) );
		}

	/* 
	 *  Read the u_knots if the surface is u-non-uniform. If the surface is 
	 *  u-uniform, then the knot vector will be calculated.
	 */
	 
	if (surface->u_non_uniform)
		{
		status = fread( (char *)surface->u_knots, sizeof(double), surface->u_num_knots, infil );
		status = fwrite((char *)surface->u_knots, sizeof(double), surface->u_num_knots, outfil );
		}

	/* 
	 *  check that the v-knots will fit in buffer 
	 *  provided, alloc new if not 
	 */
	
	surface->v_num_knots = surface->v_order + surface->v_num_poles;
	
	if( surface->v_num_knots > v_knot_size )
		{
		v_knot_size = ( (surface->v_num_knots + 99) / 100 ) * 100;
		
		if( surface->v_knots ) free( (char *)surface->v_knots );
		
		surface->v_knots = malloc( v_knot_size * sizeof(double) );
		}

	/* 
	 *  Read the v_knots if the surface is v-non-uniform. If the surface is 
	 *  v-uniform, then the knot vector will be calculated.
	 */
	 
	if( surface->v_non_uniform )
		{
		status = fread( (char *)surface->v_knots, sizeof(double), surface->v_num_knots, infil );
		status = fwrite((char *)surface->v_knots, sizeof(double), surface->v_num_knots, outfil );
		}

	/* 
	 *  read weights if rational 
	 */
	
	if( surface->rational )
		{
			
		/* 
		 *  check that weights will fit in buffer provided, 
		 *  alloc new if not 
		 */
		
		if( num_poles > weight_size )
			{
			weight_size = ( (num_poles + 99) / 100 ) * 100;
			
			if( surface->weights ) free( (char *)surface->weights );
			
			surface->weights = malloc( weight_size * sizeof(double) );
			}

		status = fread( (char *)surface->weights, sizeof(double), num_poles, infil );
		status = fwrite((char *)surface->weights, sizeof(double), num_poles, outfil );
		}

	/* 
	 *  Read the boundaries. Since the boundaries are stored in the metafile as
	 *  NURB curves, we read the bsp_curve(s) into our surface definition.
	 *  Anybody who calls this read function must be aware that the bsp_surface
	 *  does not have the boundary definitions yet and must convert the boundaries
	 *  to bsp_bdry_pts (u,v linestring format) before calling gpipe, etc.
	 */
	 
	for( i=0; i<surface->num_boundaries; i++ )
		{
		if( debug )
		if( ((++bcount) % debug) == 0 )
		fprintf( stderr, "boundary #%1d\n", bcount );
		
		copy_nurb_curve( infil, outfil, 2 );
		}
	}
