#include <stdio.h>
#include <stdlib.h>
#if defined (CLIX)
#include <EG.h>
#endif
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "hstiler.h"
#include "hslight.h"
#include "hplot.h"
#include "hsdef.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HPtiming.h"
#include "HPdef.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

/*---------------------------
 *  for
 *    HSactivate_window
 */

#include "HSe2_mesher.h" 
#include "HSpr_tiler_f.h"

/*--------------------------*/

#define	IROUND(x)	((int)(x+0.5))

/*
 *  Prototype declaration for static functions
 */
 
#if defined(__STDC__) || defined(__cplusplus)

#if defined(__cplusplus)
extern "C" {
#endif

static int HPbuild_colortable( unsigned short ct[512][6],
				     IGRshort size );

static int CEIL( double x );

#if defined(__cplusplus)
}
#endif

#else

static int HPbuild_colortable();
static int CEIL();

#endif


/*---CEIL---------------------------------------------------------------*/

/*
NAME
	CEIL (static)
	
KEYWORD
	HSplot
	ceiling
	
DESCRIPTION
	Compute the "ceiling" of the given floating point number.

PARMETERS
	x	:(IN) :  The floating point number to compute the
			 ceiling of.
			 
GLOBALS USED
	<none>
	
RETURN VALUES
	a:  An integer containing the ceiling of argument x
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

static int	CEIL( double x )

	{
	int	a;
	
	a = (int)x;
	if( (double)a != x ) a++;
	
	return(a);
	}

/*---HPinit_zbuffering--------------------------------------------------*/

/*
NAME
	HPinit_zbuffering
	
KEYWORDS
	HSplot
	question coding
	initialization
	
DESCRIPTION
	Given the viewport size, and using a value that indicates the
	workstation available main memory, in bytes, compute the 
	band size and number of bands.  Also, initialize the
	colortable and scale the point lights.
	
PARAMETERS
	device_scale		:
	world_to_view_scale	:
	
GLOBALS USED
	HPglobal: global structure
		id               : Initialized to 1
		color_table      : Colortable read from the shaded plotfile, 
			         : passed into HPcreate_colortable to form a 
			         : colortable to used during the shaded plot 
			         : processing
		color_table_size : Number of base colors in color_table
		perspective      : Referenced to see if the view is in perspective
		num_global_lights: Referenced: the number of global lights
		global_lights    : If perspective is active, the global point
			         : lights, radius is scaled
		light_coord_sys  : Initialized to 1.
		xdits, ydits     : Plot's size computed from "viewport"
		viewport         : used to compute xdits and ydits.
		total_bytes      : Number of bytes of main memory available
		overlap          : Number of scanline to overlap between bands
		bytes_per_pixel  : Either 5 or 6.
		total_bytes      : Number of bytes for z/image buffers
		total_bands      : Number of bands need for entire viewport
		band_height      : Number of scanlines in band
		total_pixels     : Number of pixels in a band
		band_buffer      : Pointer to memory allocated for the band
		debug            : If we are in a debug mode or not
		band_count       : Initialized to 1
	HPband_info: global structure
		world_to_view_scale: Set equal to the argument of the same name
	HPreport_file            : File pointer to an optional report file.  
	
RETURN VALUES
	Will return HP_I_Success if the zbuffer was allocated, otherwise
	will return HP_F_NoZMem.

FUNCTIONS CALLED
	HPbuild_colortable
	HPinq_available_memory
	HPdisplay_job_information (debug)
	HPflush_report_file (debug)
	HPinit_band
	
NOTES
	QUESTION: The world_to_view_scale is simply moved into the 
	global structure HPband_info.  The caller could do this and 
	save an argument.
	
HISTORY
	??/??/??	M. Lanier
		Create
*/

#if defined(__STDC__) || defined(__cplusplus)
	int HPinit_zbuffering    (IGRdouble device_scale, 
				     double world_to_view_scale)
#else
	int	HPinit_zbuffering( 
			device_scale,
			world_to_view_scale )

	IGRdouble			device_scale;
	double				world_to_view_scale;
#endif

	{
	IGRboolean	allocated;
	IGRint		HPinq_available_memory();
	IGRint		i;
	int		yo, ob, rb, sb, sl;
	

	/*
	 *  Call HSset_active_window to initialize an active pipe for the
	 *  scene.  The argument to this routine is normally the gpipe_id,
	 *  but since we will only process one scene at a time, we can hard
	 *  code a value.  I used 1 instead of 0 because I didn't know if
	 *  0 had any special meaning
	 */

#	if HS14
		HSset_active_window( HPglobal.id = 1 );
#	else
		HSactivate_window( HPglobal.id = 1 );
#	endif

	/*
	 *  transfer input info into global info
	 */
	 
	HPbuild_colortable( 
		HPglobal.color_table, 
		HPglobal.color_table_size );

	/*
	 *  Scale to radius of point lights
	 */
	 	
	if( HPglobal.perspective )
		for( i=0; i<HPglobal.num_global_lights; i++ )
			if( HPglobal.global_lights[i].flags & HS_LIGHT_POINT )
				HPglobal.global_lights[i].radius *= device_scale;

	HPglobal.light_coord_sys = 1;
	
	HPglobal.xdits = IROUND(HPglobal.viewport[3]) - (int)(HPglobal.viewport[0]);
	HPglobal.ydits = IROUND(HPglobal.viewport[4]) - (int)(HPglobal.viewport[1]);
	
	HPglobal.total_bytes = HPinq_available_memory();
	
	/*
	 *  Band memory calculation
	 *    given
	 *      xdits ----- (scanlines) (HPglobal.xdits)
	 *      ydits ----- (pixels/scanline) (HPglobal.ydits)
	 *      ov -------- overlap constant (HPglobal.overlap)
	 *      bp -------- (bytes/pixel) (HPglobal.bytes_per_pixel)
	 *      ab -------- (bytes) available bytes (HPglobal.total_bytes)
	 *
	 *  [1]  yo = ydits + 2ov;         (pixels/scanline) w/ overlap
	 *  [2]  ob = yo * bp * 2ov;       (bytes)           bytes in overlap region
	 *  [3]  rb = ab - ob;             (bytes)           available bytes less overlap region
	 *  [4]  sb = yo * bp;             (bytes/scanline)  number of bytes in a scanline
	 *  [5]  sl = rb / sb;             (scanlines/band)  max scanlines in a band
	 *  [6]  tb = CEIL( xdits / sl );  (bands)           (HPglobal.total bands)
	 *  [7]  bh = ROUND( xdits / tb ); (scanlines/band)  HPglobal.band_height;
	 *  [8]  bb = (bh + 2ov) * sb;     (bytes/band)      HPglobal.total_bytes.
	 */
	 
	yo = HPglobal.ydits + (HPglobal.overlap << 1);
	sb = yo * HPglobal.bytes_per_pixel;
	ob = sb * (HPglobal.overlap << 1);
	rb = HPglobal.total_bytes - ob;
	sl = rb / sb;
	
	HPglobal.total_bands = CEIL/*IROUND*/( ((double)(HPglobal.xdits) / (double)(sl) )  );
	if( HPglobal.total_bands < 1 ) HPglobal.total_bands = 1;
/*HPglobal.total_bands = 4;*/
			
	/*
	 *  Attempt to allocate memory for the band.  The bytes to allocate is
	 *  the viewport height divided by the total number of bands, rounded
	 *  up, times the viewport width, time 6 bytes per pixel.  If this 
	 *  fails, then increment the total number of bands by 1 and try again.  
	 */
	 
	allocated = FALSE;
	while( !allocated )
		{
		HPglobal.band_height = 
			CEIL( ((double)(HPglobal.xdits) / (double)(HPglobal.total_bands)) );
		
		HPglobal.total_pixels = 
			(HPglobal.band_height + (HPglobal.overlap << 1)) * yo;
		  
		HPglobal.total_bytes = HPglobal.total_pixels * HPglobal.bytes_per_pixel;
			
		HPglobal.band_buffer = (unsigned long *)malloc( HPglobal.total_bytes );
		
		if( HPglobal.band_buffer != NULL )
			{
			allocated = TRUE;
			}
		else
			{
			if( HPglobal.debug )
				fprintf( stderr, "   Unable to allocate memory, increase bands and try again\n" );
			
			(HPglobal.total_bands)++;
			}
		}
	
	if( HPglobal.debug )
		HPdisplay_job_information( stderr );

	if( HPreport_file != NULL )
		{
		HPdisplay_job_information( HPreport_file );
		HPflush_report_file( &HPreport_file );
		}
	
	HPglobal.band_count = 1;	
	HPband_info.world_to_view_scale = world_to_view_scale;
		
	if( HPglobal.band_buffer == NULL ) 
		{
		return( HP_F_NoZMem );
		}
	else
		{
		HPinit_band();
		return( HP_I_Success );
		}
	}
	

/*---HPbuild_colortable--------------------------------------------------*/

/*
NAME
	HPbuild_colortable
	
KEYWORDS
	HSplot
	initialization
	colortable
	
DESCRIPTION
	Given a colortable with max of 480 color entries. (2 entries for 
	each of at most 240 base colors, with the first entry being the 
	RGB of the color at intensity 255 and the second the color at 
	intensity 0) calculate a delta color, and store it as the second
	color entry.  Also, setup table of primaries and create map table
	from base_color index to primary index;
	
PARAMETERS
	ct	:(IN/OUT): The colortable read from the shaded plot file
	size	:(IN)    : The number of base colors in the colortable
	
GLOBALS_USED
	HPcommand_line
	
RETURN VALUES
	O:  Always
	
HISTORY
	08/11/92	M. Lanier
		Change argument size, type from int to IGRshort
		
	??/??/??	M. Lanier
		Created
*/
 
#if defined(__STDC__) || defined(__cplusplus)
	static int HPbuild_colortable ( unsigned short ct[512][6],
					      IGRshort size )					 
#else
	static int HPbuild_colortable( ct, size )

	unsigned short	ct[512][6];
	IGRshort	size;
#endif

	{
	int		i, j;
	unsigned short	*primary;	
	int		hi, lo;
	
	if( HPglobal.white_background )
		{
			
		/*
		 *  force the background color to white
		 */
	 
		ct[0][0] = 0xffff;
		ct[0][1] = 0xffff;
		ct[0][2] = 0xffff;
		}
	else
		{
		if( HPglobal.black_and_white_edges )
			{
			
			/*
			 *  force the background color to black
			 */
	 
			ct[0][0] = 0x0000;
			ct[0][1] = 0x0000;
			ct[0][2] = 0x0000;
			}
		}

	/*
	 *  for each of the base colors:
	 *     o  calculate a delta color
	 *     o  map it to a primary color
	 */

	for( i=1; i<size; i++ )
		{
		for( j=0; j<3; j++ )
			{
			hi = (int)((unsigned short)ct[i][j]);
			lo = (int)((unsigned short)ct[i][j+3]);
			
			ct[i][j+3] = (short)((hi - lo) / 255);
			}
		}
				
	/*
	 *  setup primary colors
	 */
	 
	primary = &ct[240][0];
	
	*primary++ = 0x0000;     *primary++ = 0x0000;     *primary++ = 0x0000;	
	*primary++ = 0x0000;     *primary++ = 0x0000;     *primary++ = 0x0000;	

	*primary++ = 0x0000;     *primary++ = 0x0000;     *primary++ = 0xff00;	
	*primary++ = 0x0000;     *primary++ = 0x0000;     *primary++ = 0x0100;	

	*primary++ = 0x0000;     *primary++ = 0xff00;     *primary++ = 0x0000;	
	*primary++ = 0x0000;     *primary++ = 0x0100;     *primary++ = 0x0000;	

	*primary++ = 0x0000;     *primary++ = 0xff00;     *primary++ = 0xff00;	
	*primary++ = 0x0000;     *primary++ = 0x0100;     *primary++ = 0x0100;	

	*primary++ = 0xff00;     *primary++ = 0x0000;     *primary++ = 0x0000;	
	*primary++ = 0x0100;     *primary++ = 0x0000;     *primary++ = 0x0000;	

	*primary++ = 0xff00;     *primary++ = 0x0000;     *primary++ = 0xff00;	
	*primary++ = 0x0100;     *primary++ = 0x0000;     *primary++ = 0x0100;	

	*primary++ = 0xff00;     *primary++ = 0xff00;     *primary++ = 0x0000;	
	*primary++ = 0x0100;     *primary++ = 0x0100;     *primary++ = 0x0000;	

	*primary++ = 0xff00;     *primary++ = 0xff00;     *primary++ = 0xff00;	
	*primary++ = 0x0100;     *primary++ = 0x0100;     *primary++ = 0x0100;
	
	return(0);
	}
