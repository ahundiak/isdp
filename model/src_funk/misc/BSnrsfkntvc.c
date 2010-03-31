/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

BSnrsfkntvc ( surface)
struct IGRbsp_surface *surface;

{
	IGRlong  u_num_poles, v_num_poles;
	IGRshort	 u_order, v_order;
	IGRint	 k;
	IGRdouble u_lower_bnd, u_upper_bnd;
	IGRdouble v_lower_bnd, v_upper_bnd;
	IGRdouble diff;
	
	u_order = surface->u_order;
	v_order = surface->v_order;
	u_num_poles = surface->u_num_poles;
	v_num_poles = surface->v_num_poles;
	
	/*
	 * normalize u_knot vector
	 */
	
	u_lower_bnd = surface->u_knots[u_order-1];
	u_upper_bnd = surface->u_knots[u_num_poles];
	diff = u_upper_bnd - u_lower_bnd;
	
	for ( k = 0; k < (u_order + u_num_poles); k++)
	{
		surface->u_knots[k] -= u_lower_bnd;
		surface->u_knots[k] /= diff;
	}
	
	/*
	 * normalize v_knot vector
	 */
	
	v_lower_bnd = surface->v_knots[v_order-1];
	v_upper_bnd = surface->v_knots[v_num_poles];
	diff = v_upper_bnd - v_lower_bnd;
	
	for ( k = 0; k < (v_order + v_num_poles); k++)
	{
		surface->v_knots[k] -= v_lower_bnd;
		surface->v_knots[k] /= diff;
	}
	
	return (1);
	
}
