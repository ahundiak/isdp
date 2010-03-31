/*		Apogee compliant		*/

#include "hsurf_import.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HSlvhl_info.h"
#include "HStl_window.h"
#include "HStl_global.h"

#define	DEBUG	1

#define	CEIL(x)	(int)((x)+1.0)

/*---HSallocate_lvhl_zbuffer_memory-----------------------*/
 
int	HSallocate_lvhl_zbuffer_memory( 
		pipe_no,
		xmin, xmax,
		ymin, ymax,
		lvhl_info )

int			pipe_no;
int			xmin, xmax;
int			ymin, ymax;
struct HSlvhl_info	*lvhl_info;

	{
	int	total_bytes;
	int	x_dits, y_dits, x, y;
	HSzbuf	*zb, *zbuf;
	HScbuf  *cbuf;
	/*double	sqrt();*/
	
#	if DEBUG
		fprintf( stderr, "HSallocate_lvhl_zbuffer_memory\n" );
		fprintf( stderr, "   xmin, xmax, ymin, ymax:  %d %d\n", xmin, xmax, ymin, ymax );
		fprintf( stderr, "   lvhl_info->optimization: %d\n", lvhl_info->optimization );
#	endif

	/*
	 *  First, we have to determine how many bytes are needed
	 *  for the big buffer.  The total bytes is equal to the
	 *  product of the x/y pixels, times the lvhl_info->optimization
	 *  times 4 (LVHL needs 4 bytes/pixel)
	 */

	lvhl_info->scale = sqrt( ((double)lvhl_info->optimization) );

	lvhl_info->min_x_dep = xmin * lvhl_info->scale;
	lvhl_info->min_y_dep = ymin * lvhl_info->scale;
	lvhl_info->max_x_dep = CEIL( ((double)xmax * lvhl_info->scale) );
	lvhl_info->max_y_dep = CEIL( ((double)ymax * lvhl_info->scale) );
	
	x_dits = lvhl_info->max_x_dep - lvhl_info->min_x_dep;
	y_dits = lvhl_info->max_y_dep - lvhl_info->min_y_dep;
	
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

	cbuf = (HScbuf *)malloc(sizeof(HScbuf));
	HSactivate_window( pipe_no );
	active_window->zbuf = zbuf;
	*cbuf = (HScbuf)((int)zbuf + total_bytes);
	active_window->cbuf = cbuf;
	lvhl_info->xdits = x_dits;
	lvhl_info->ydits = y_dits;

	return( 1 );
	}

/*---HSfree_lvhl_memory--------------------------------------------__*/

void	HSfree_lvhl_memory( pipe_no )

int	pipe_no;

	{
	HSactivate_window( pipe_no );
	(*tiling_parms.zfree)( 2, active_window->zbuf );
	}
