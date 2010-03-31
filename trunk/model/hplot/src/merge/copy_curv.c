#include <stdio.h>

static double	*poles = NULL;
static double	*knots = NULL;
static double	*weights = NULL;
static int	pole_size = 0;
static int	knot_size = 0;
static int	weight_size = 0;
static short	order;
static short	num_poles;
static short	num_knots;
static short	non_uniform;
static short	rational;

#define		CV_NON_UNIFORM_M	0x0002
#define		CV_RATIONAL_M		0x0004

/*---copy_nurb_curve------------------------------------------------------*/

int	copy_nurb_curve( infil, outfil, dimension )

FILE	*infil, *outfil;
int	dimension;

	{
	int		status;		/* return code from called functions */
	short		valu16;		/* a 16 bit integer value */
	int		vali;		/* an int value */

	extern double	*malloc ();

	status = fread( (char *)&order, sizeof(order), 1, infil );
	status = fwrite((char *)&order, sizeof(order), 1, outfil );
	 
	status = fread( (char *)&valu16, sizeof(valu16), 1, infil );
	status = fwrite((char *)&valu16, sizeof(valu16), 1, outfil );
	
	non_uniform = (valu16 & CV_NON_UNIFORM_M) != 0;
	rational    = (valu16 & CV_RATIONAL_M) != 0;

	 
	status = fread( (char *)&vali, sizeof(vali), 1, infil );
	status = fwrite((char *)&vali, sizeof(vali), 1, outfil );
	
	num_poles = vali;
	
	if( vali > pole_size )
		{
		pole_size = (vali / 100 + 1) * 100;
		if( poles ) free( poles );
		
		poles = malloc( pole_size * dimension * sizeof(double) );
		}


	/* 
	 *  read poles 
	 */

	if( vali > 0 )
		{
		status = fread( poles, sizeof(double), vali * dimension, infil );
		status = fwrite(poles, sizeof(double), vali * dimension, outfil );
		}

	vali = num_poles + order;
	num_knots = vali;
	if( vali > knot_size )
		{
		knot_size = (vali / 100 + 1) * 100;
		if( knots ) free (knots);
		
		knots = malloc( knot_size * sizeof(double) );
		}


	/* 
	 *  Read the knots if the curve is non-uniform. If 
	 *  the curve is uniform, then calculate the knot vector.
	 */
	 
	if( non_uniform )
		{
		if( vali > 0 )
			{
			status = fread( knots, sizeof(double), vali, infil );
			status = fwrite(knots, sizeof(double), vali, outfil );
			}
		}
		
	/* 
	 *  check that weights will fit in buffer provided, 
	 *  alloc new if not 
	 */
	 
	vali = num_poles;
	if( vali > weight_size )
		{
		weight_size = (vali / 100 + 1) * 100;
		if( weights ) free( weights );
		
		weights = malloc( weight_size * sizeof(double) );
		}


	/* 
	 *  read weights if rational 
	 */
	 
	if( rational && vali > 0 )
		{
		status = fread( weights, sizeof(double), vali, infil );
		status = fwrite(weights, sizeof(double), vali, outfil );
		}
	}
