
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/


#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hstiler.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSpr_render.h"

/*-----------------------------
 *  for functions
 *     perspective_projection
 *     transform_points
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*----------------------------*/

	
/*---- HRget_dit_range ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRget_dit_range( IGRint num_poles,
			   IGRdouble *poles,
			   IGRdouble *weights,
			   IGRdouble range[6] )
#else
	void HRget_dit_range( num_poles, poles, weights, range )

	IGRint    num_poles;
	IGRdouble *poles;
	IGRdouble *weights;
	IGRdouble range[6];
#endif
	
/*
DESCRIPTION
	This function determines the dit range box for a set of weighted
	or unweighted poles.  It uses the function 'transform_points' to
	transform the points to the view.  'transform_points' uses the
	transformation defined for the current 'active_pipe'.
	
HISTORY
	S.P. Rogers  07/08/89  Creation Date
	S.P. Rogers  09/08/89  Added perspective support
*/

	{
	IGRboolean has_weights;
	IGRint     i;
	struct HSvertex  vertex;

	range[0] = range[1] = range[2] =  1e100;
	range[3] = range[4] = range[5] = -1e100;
	
	has_weights = ( weights != NULL );
	
	/* circularly linked list of one vertex */
	vertex.next = &vertex;
	
	for ( i = 0; i < num_poles; i++ )
	   {
	   if ( has_weights )
	      {
	      /* unweight pole */
	      vertex.coord[0] = *poles++ / *weights;
	      vertex.coord[1] = *poles++ / *weights;
	      vertex.coord[2] = *poles++ / *weights++;
	      }
	   else
	      {
	      vertex.coord[0] = *poles++;
	      vertex.coord[1] = *poles++;
	      vertex.coord[2] = *poles++;
	      }

	   /* transform pole to view */
	   vertex.coord[3] = 1.0;
	   transform_points( active_window->perspective, 1, vertex.coord, 1 );

	   if ( active_window->perspective )
	      perspective_projection( &vertex );

	   if ( vertex.coord[0] < range[0] )
	      range[0] = vertex.coord[0];
	   if ( vertex.coord[0] > range[3] )
	      range[3] = vertex.coord[0];

	   if ( vertex.coord[1] < range[1] )
	      range[1] = vertex.coord[1];
	   if ( vertex.coord[1] > range[4] )
	      range[4] = vertex.coord[1];

	   if ( vertex.coord[2] < range[2] )
	      range[2] = vertex.coord[2];
	   if ( vertex.coord[2] > range[5] )
	      range[5] = vertex.coord[2];

	   }  /* end: for */

	}  /* HRget_dit_range */
	

