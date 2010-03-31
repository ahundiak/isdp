
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <FI.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "godef.h"
#include "dpstruct.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSplot.h"
#include "HSpr_lvhl.h"

/*--------------------------
 *  for function
 *     HSactivate_window
 */
 
#include "HSpr_tiler_f.h"

/*---------------------------*/


#define	DEBUG	0

#define	CEIL(x)	(int)((x)+1.0)

/*---HSlvhl_allocate_zbuffer_memory-----------------------*/
 
#if defined(__STDC__) || defined(__cplusplus)
	int HSlvhl_allocate_zbuffer_memory( int pipe_no,
					    int *xmin,
					    int *xmax,
					    int *ymin,
					    int *ymax,
					    int optimization,
					    int *xdits_scaled,
					    int *ydits_scaled )
#else
	int	HSlvhl_allocate_zbuffer_memory( 
			pipe_no,
			xmin, xmax,
			ymin, ymax,
			optimization,
			xdits_scaled, ydits_scaled )

	int	pipe_no;
	int	*xmin, *xmax;
	int	*ymin, *ymax;
	int	optimization;
	int	*xdits_scaled;
	int	*ydits_scaled;
#endif

	{
	int	total_bytes;
	int	x_dits, y_dits, x, y;
	HSzbuf	*zb, *zbuf;
	HScbuf  *cbuf;
	double	scale;
	
#	if DEBUG
		fprintf( stderr, "HSlvhl_allocate_zbuffer_memory\n" );
		fprintf( stderr, "   xmin, xmax, ymin, ymax:  %d %d %d %d\n", 
			*xmin, *xmax, *ymin, *ymax );
		fprintf( stderr, "   optimization:            %d\n", optimization );
#	endif

	/*
	 *  First, we have to determine how many bytes are needed
	 *  for the big buffer.  The total bytes is equal to the
	 *  product of the x/y pixels, times the optimization
	 *  times 4 (LVHL needs 4 bytes/pixel)
	 */

	scale = sqrt( ((double)optimization) );

	*xmin = *xmin * scale;
	*ymin = *ymin * scale;
	*xmax = CEIL( ((double)*xmax * scale) );
	*ymax = CEIL( ((double)*ymax * scale) );
	
	x_dits = *xmax - *xmin;
	y_dits = *ymax - *ymin;

	total_bytes = x_dits * y_dits * 4;
	
#	if DEBUG
		fprintf( stderr, "   x_dits, y_dits:          %d %d\n", x_dits, y_dits );
		fprintf( stderr, "   total_bytes:             %d\n", total_bytes );
#	endif
		
	/*
	 *  Just to get started, I won't worry about any existing big
	 *  buffers, or try snatching memory from a shading window.
	 *  I'll save this code for later.  For now, I'll immplement
	 *  option 3 only.
	 */
	 
	
	/*
	 *  Call malloc to allocate the big buffer.  If this fails
	 *  return an error (False)
	 */

	zbuf = (HSzbuf *)(*tiling_parms.zmalloc)( 2, total_bytes, NULL, active_window );
	
	if( zbuf == NULL ) return( 0 );

	/* 
	 *  Initialize the memory
	 */
	 
	
	zb = zbuf;

	x = x_dits;
	while( --x )
		*(zb++) = 0x00ffffff;
	
	y = y_dits;
	while( --y )
		{
		memcpy( zb, zbuf, sizeof( HSzbuf ) * x_dits );
		zb += x_dits;
		}
		
	/*
	 *  activate a window and put the zbuffer in its structure
	 */

	HSactivate_window( pipe_no );
	active_window->zbuf = zbuf;
	cbuf = (HScbuf *)(zbuf + total_bytes);
	active_window->cbuf = cbuf;

	*xdits_scaled = x_dits;
	*ydits_scaled = y_dits;

	return( 1 );
	}

/*---HSlvhl_free_zbuffer_memory----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_free_zbuffer_memory( int pipe_no )
#else
	void	HSlvhl_free_zbuffer_memory( pipe_no )

	int	pipe_no;
#endif

	{
	HSactivate_window( pipe_no );
	(*tiling_parms.zfree)( 2, active_window->zbuf );
	}
