
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

/*
 * This file contains all the routines that set per-facet global values.
 */

#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsmath.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"


/*---HSset_facet_normal------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSset_facet_normal( IGRdouble x,
				 IGRdouble y,
				 IGRdouble z )
#else
	void HSset_facet_normal( x, y, z )

	IGRdouble	x, y, z;
#endif

/*
 * ABSTRACT:	HSset_facet_normal sets the facet normal.
 *
 * HISTORY:	02/28/90  Created			C. M. Jablonski
 */

	{
	element_parms.facet_normal[0] = x;
	element_parms.facet_normal[1] = y;
	element_parms.facet_normal[2] = z;
	}


/*---HSset_unscaled_facet_normal---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSset_unscaled_facet_normal( IGRdouble x,
					  IGRdouble y,
					  IGRdouble z )
#else
	void HSset_unscaled_facet_normal( x, y, z )

	IGRdouble	x, y, z;
#endif

/*
 * ABSTRACT:	HSset_unscaled_facet_normal sets the unscaled facet normal.
 *
 * HISTORY:	02/28/90  Created			C. M. Jablonski
 */

	{
	element_parms.unscaled_facet_normal[0] = x;
	element_parms.unscaled_facet_normal[1] = y;
	element_parms.unscaled_facet_normal[2] = z;
	}


/*--- HSsave_and_scale_facet_normal -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSsave_and_scale_facet_normal(void)
#else
	void	HSsave_and_scale_facet_normal()
#endif

/*
 * ABSTRACT:	HSsave_and_scale_facet_normal saves the facet normal as
 *		"unscaled_facet_normal", then scales the facet normal from
 *		normalized coordinates into view-aligned coordinates by
 *		multiplying by the non-uniform perspective scale factors
 *		of the active window.
 *
 * HISTORY:	01/06/87 created			S. A. Rapa
 */

	{
	HSset_unscaled_facet_normal(	element_parms.facet_normal[0],
					element_parms.facet_normal[1],
					element_parms.facet_normal[2] );

	element_parms.facet_normal[0] *= active_window->persp_x_scale;
	element_parms.facet_normal[1] *= active_window->persp_y_scale;
	element_parms.facet_normal[2] *= active_window->persp_z_scale;
	}


/*---HSnormalize_facet_normal------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSnormalize_facet_normal(void)
#else
	void HSnormalize_facet_normal()
#endif

/*
 * ABSTRACT:	HSnormalize_facet_normal normalizes the facet normal.
 *
 * HISTORY:	02/28/90  Created			C. M. Jablonski
 */

{
IGRdouble	vector_length;

	vector_length = SQRT((element_parms.facet_normal[0] * element_parms.facet_normal[0]) +
			     (element_parms.facet_normal[1] * element_parms.facet_normal[1]) +
			     (element_parms.facet_normal[2] * element_parms.facet_normal[2]));

	if (vector_length > 0.0)
		{
		element_parms.facet_normal[0] /= vector_length;
		element_parms.facet_normal[1] /= vector_length;
		element_parms.facet_normal[2] /= vector_length;
		}
	else
		{
		element_parms.facet_normal[0] = 0.0;
		element_parms.facet_normal[1] = 0.0;
		element_parms.facet_normal[2] = 0.0;
		}
}


/*---HSnegate_facet_normal---------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSnegate_facet_normal(void)
#else
	void HSnegate_facet_normal()
#endif

/*
 * ABSTRACT:	HSnegate_facet_normal negates the facet normal.
 *
 * HISTORY:	02/28/90  Created			C. M. Jablonski
 */

	{
	element_parms.facet_normal[0] = -element_parms.facet_normal[0];
	element_parms.facet_normal[1] = -element_parms.facet_normal[1];
	element_parms.facet_normal[2] = -element_parms.facet_normal[2];
	}


#ifndef MICROCODE
/*---HSset_front_facing_flag-------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSset_front_facing_flag( IGRboolean flag )
#else
	void HSset_front_facing_flag( flag )

	IGRboolean	flag;
#endif

/*
 * ABSTRACT:	HSset_front_facing_flag sets the facet direction flag.
 *		TRUE = front-facing; FALSE = back-facing.
 *
 * HISTORY:	02/28/90  Created			C. M. Jablonski
 */

	{
	element_parms.front_facing_facet = flag;
	}
#endif
