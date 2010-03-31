
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dpdef.h"

#include "hstiler.h"
#include "hslight.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

#include "hsurf.h"

/*----------------------
 *  for function
 *     HSget_hilite
 */
 
#include "HSpr_dpb_imp.h"

/*------------------------*/

#define COLOR_MASK	0x0ffffff

#ifndef MICROCODE
/*---get_color_index-----------------------------------------------------------*/

IGRint	get_color_index( IGRint *color )

/*
 * ABSTRACT:	Get_color_index returns the vlt index that corresponds to
 *		the given logical color.
 *
 * HISTORY:	03/21/90 Rewritten.				C. M. Jablonski
 *
 */

{
	return( HSlogical_color_to_physical_slot( *color, active_window->context_no ));
}
#endif


/*-- front_facing_facet -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean front_facing_facet( IGRint perspective,
				    IGRdouble eye_vector[3] )
#else
	IGRboolean	front_facing_facet (perspective, eye_vector)

	IGRint		perspective;		/* input - is view perspected	*/
	IGRdouble	eye_vector[3];		/* input - vector from eye	*/
#endif

/*
 * Returns TRUE if the facet is front-facing, FALSE if it is back-facing.
 *
 * HISTORY: 09/01/86 created				S. A. Rapa
 *	    12/17/86 Switched to global facet normal.	S. A. Rapa
 *	    01/14/87 Using facet normal from tiler.	S. A. Rapa
 *	    02/11/87 Changed algorithm (perspective).	S. A. Rapa
 */

 {
   IGRdouble	dot;

   /*
    * For perspective, find out what side is visible by dotting
    * a ray vector from the eye with the unscaled facet normal.
    */

   if (perspective)
      dot = (element_parms.unscaled_facet_normal[0] * eye_vector[0]) +
	    (element_parms.unscaled_facet_normal[1] * eye_vector[1]) +
	    (element_parms.unscaled_facet_normal[2] * eye_vector[2]);
   else
      dot = element_parms.facet_normal[2];

   if (dot <= 0.0)
      return (TRUE);
   else
      return (FALSE);
}

static IGRdouble view_vector[3], eye_point[3];

/*--- HScan_cull_facet -------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HScan_cull_facet( IGRboolean perspective,
				      IGRdouble Point[3] )
#else
	IGRboolean HScan_cull_facet( perspective, Point )
	
	IGRboolean perspective;
	IGRdouble Point[3];
#endif

{
	IGRdouble dot;

#if FALSE
	int i;

	for( i = 0; i < 16; i++ )
	{
		fprintf( stderr, "%lf\t\t", active_window->transform_matrix[i/4][i%4] );
		if( ((i+1) % 4) == 0 ) fprintf( stderr, "\n" );
	}
#endif

	if( perspective )
	{
		/* Create a view vector at the given point */
		view_vector[0] = Point[0] - eye_point[0];
		view_vector[1] = Point[1] - eye_point[1];
		view_vector[2] = Point[2] - eye_point[2];
	}

	switch( element_parms.culling_back_planes )
	{
	case HS_CULL_POSITIVE:
		dot =	(element_parms.facet_normal[0] * view_vector[0]) +
			(element_parms.facet_normal[1] * view_vector[1]) +
			(element_parms.facet_normal[2] * view_vector[2]);
		break;
	case HS_CULL_NEGATIVE:
		dot =	(element_parms.facet_normal[0] * view_vector[0]) +
			(element_parms.facet_normal[1] * view_vector[1]) +
			(element_parms.facet_normal[2] * view_vector[2]);
		dot = -dot;
		break;
	case HS_CULL_NONE:
	default:
		return( FALSE );
	}

	if (dot <= 0.0)
		return (TRUE);
	else
		return (FALSE);

} /* HScan_cull_facet */

/*--- HScalc_world_view_vector -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScalc_world_view_vector( IGRdouble rotation[4][4],
				      IGRboolean perspective,
				       IGRdouble eye_pt[3] )
#else
	void HScalc_world_view_vector( rotation, perspective, eye_pt )

	IGRdouble rotation[4][4];
	IGRboolean perspective;
	IGRdouble eye_pt[3];
#endif

{

#if DEBUG
	int i;

	for( i = 0; i < 16; i++ )
	{
		fprintf( stderr, "%lf\t\t", rotation[i/4][i%4] );
		if( ((i+1) % 4) == 0 ) fprintf( stderr, "\n" );
	}
#endif
	if( perspective )
	{
		/* Keep the Eye point in world coordinates */
		memcpy( eye_point, eye_pt, (3 * sizeof(IGRdouble) ) );
	}
	else
	{
		view_vector[0] = 0.0;
		view_vector[1] = 0.0;
		view_vector[2] = 1.0;
		/* Get the view vector with a world orientation */
		HSUnRotateVectors( 1, view_vector );
	}

} /* HScalc_world_view_vector */

/*---HSget_z_span_of_range----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_z_span_of_range( IGRdouble *range,
				    IGRdouble *z_min,
				    IGRdouble *z_max )
#else
	void	HSget_z_span_of_range( range, z_min, z_max )
	IGRdouble	*range, *z_min, *z_max;
#endif

/*
 * Forms a range cube, transforms the points to normalized coordinates, and
 * returns the minimum and maximum z values.
 *
 * HISTORY: 07/14/88 created				C. M. Jablonski
 */

{
IGRint		x,y,z;
IGRdouble	rng[32], *rng_ptr;

		/* build the range cube out of the two range points */
		rng_ptr = (IGRdouble *)rng;
                for ( x=0; x<6; x+=3 )
		for ( y=1; y<6; y+=3 )
               	for ( z=2; z<6; z+=3 )
               		{
               		*rng_ptr++ = range[x];
               		*rng_ptr++ = range[y];
               		*rng_ptr++ = range[z];
               		}

		/* transform the range cube to normalized coordinates */
		transform_points( active_window->perspective, 8, rng, 8);

		/* find the min and max z-values in the transformed cube */
		*z_min = *z_max = rng[2];

		for (z=5;z<24;z+=3)
			{
			if (*z_min>rng[z])
				{
				*z_min=rng[z];
				}
			else if (*z_max<rng[z])
				{
				*z_max=rng[z];
				}
			}
}

/*---HScalc_window_z_range-----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScalc_window_z_range( IGRdouble *fit_range,
				    IGRdouble *z_min,
				    IGRdouble *z_max )
#else
	void	HScalc_window_z_range( fit_range, z_min, z_max )

	IGRdouble	*fit_range, *z_min, *z_max;
#endif

/*
 * Determines an appropriate z-range for the current window using the current
 * dit-clip-range and the given top-level fit range.  If dit clip Z range is
 * large, try to use the fit range to get reasonable z_max, z_min.
 *
 * HISTORY: 07/15/88 created				C. M. Jablonski
 */

{
IGRdouble	tmp, tmp2;

	if ((active_window->dit_clip_range[5] - active_window->dit_clip_range[2]) <
	    (tiling_parms.maximum_z / 10000.0))
		{
		/*
		 * Dit clip range is reasonable, assuming a typical world
		 * chord height tolerance of 1.0e-5 and 1-to-1 world-to-
		 * viewport scale.
		 */

		*z_min = active_window->dit_clip_range[2];
		*z_max = active_window->dit_clip_range[5];
		}
	else
		{
		/*
		 * Get the near and far Z of the fit range.
		 */

		HSget_z_span_of_range( fit_range, z_min, z_max );

		/*
		 * Spread the range to allow for growth before the next update.
		 * The net effect is to multiply the range by 10.
		 */

		tmp = (*z_max - *z_min + 1) * 4.5;
		*z_min -= tmp;
		*z_max += tmp;

		/*
		 * Check against the window clip range.
		 */

		if (tiling_parms.processing_mode & HS_PMODE_DEXEL)
			{
			/*
			 * Set z_min, z_max.  Use the (dit_clip_range*10) values only if they are
			 * within the expanded fit range.
			 */
		 
			tmp2 = (active_window->dit_clip_range[5] - active_window->dit_clip_range[2]) * 4.5;

			if (*z_min < (tmp = active_window->dit_clip_range[2] - tmp2))
				*z_min = tmp;

			if (*z_max > (tmp = active_window->dit_clip_range[5] + tmp2))
				*z_max = tmp;
			}
		else
			{
			/*
			 * Set z_min, z_max.  Use the dit_clip_range values only if they are
			 * within the expanded fit range.
			 */
		 
			if (*z_min < active_window->dit_clip_range[2])
				*z_min = active_window->dit_clip_range[2];

			if (*z_max > active_window->dit_clip_range[5])
				*z_max = active_window->dit_clip_range[5];
			}
		}
}


/*-- HSoutside_z_range ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HSoutside_z_range( IGRboolean checking_min_z_plane, 
				       IGRdouble z_val,
				       IGRdouble *range )
#else
	IGRboolean	HSoutside_z_range ( checking_min_z_plane, z_val, range )

	IGRdouble	*range, z_val;
	IGRboolean	checking_min_z_plane;
#endif
/*
 * Returns TRUE if any part of the range box defined by range is on the 
 * "outside" of the plane z=z_val.  If checking_min_z_plane is TRUE the 
 * "outside" is the region z<z_val, and if checking_min_z_plane is FALSE,
 * the "outside" is the region z>z_val. 
 *
 * HISTORY: 02/22/88 created.				C. M. Jablonski
 */

{
IGRdouble	z_min, z_max;
IGRboolean	outside;

	/* get the min and max z for the given range cube */
	HSget_z_span_of_range( range, &z_min, &z_max );

	/* test for clipping */
	if (checking_min_z_plane)
	   outside = (z_min < z_val);
	else
	   outside = (z_max > z_val);

	return (outside);
}
