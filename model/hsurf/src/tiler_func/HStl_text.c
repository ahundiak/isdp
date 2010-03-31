
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
#include "gr.h"

#include "bsvalues.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------
 *  for function
 *     HSpaint
 */
 
#include "HSpr_display.h"

/*-------------------------------*/

/*---HStext_tiler -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HStext_tiler( IGRint pipe_no,
			   IGRint num_coords,
			IGRdouble *buffer,
			   IGRint color,
			   IGRint options,
			IGRdouble *clip_range )
#else
	void HStext_tiler( pipe_no, num_coords, buffer, color, options, clip_range )

	IGRint     pipe_no;
	IGRint	   num_coords;
	IGRdouble  *buffer;
	IGRint	   color;
	IGRint     options;
	IGRdouble  *clip_range;
#endif

/*
DESCRIPTION
	This function takes the feedback buffer of a stroked text element
	and generates the polylines to be displayed.
	
HISTORY
	S.P. Rogers  12/16/87  Creation Date
*/

	{
	IGRint             ii;
	struct IGRpolyline polyline;
	
	/* initialize painting routine */
	if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
	        (*active_window->init_paint[active_window->active_zbuffer]) (&color, &options);
	
	polyline.points = buffer;
	polyline.num_points = 0;
	for ( ii = 0; ii < num_coords; ii++ )
	   {
	   if ( *buffer != MAXDOUBLE )
	      {
	      /* not a terminator => keep going */
	      (polyline.num_points)++;
	      buffer += 3;
	      }
	   else
	      {
	      /* terminator => send polyline and start a new one */
	      HSpline_tiler( pipe_no, &polyline, color, options, FALSE, clip_range );
	      buffer += 3;
	      polyline.points = buffer;
	      polyline.num_points = 0;
	      }
	   }
	
	/* flush last polyline */
	if ( polyline.num_points > 1 )
	   HSpline_tiler( pipe_no, &polyline, color, options, FALSE, clip_range );

	/* paint the text */
#ifndef MICROCODE
        if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK)) HSpaint( 0 );
#endif

	}  /* HStext_tiler */

