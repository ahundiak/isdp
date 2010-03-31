
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

/*
 * hsurf_global.c contains the definitions of all global variables
 * in the HSURF library.
 */

#include "wl.h"

#if defined (X11)
#define	MAX_WINDOW	40
#endif

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hrstruct.h"
#include "hsvhl.h"
#include "hsurf.h"
#include "hsmacdef.h"
#include "gr.h"
#include "HSlvhl.h"
#include "hnmilling.h"
#include "hnerror.h"
#include "hnorient.h"
#include "hnsimulate.h"
#include "hntiming.h"
#include "hntool.h"
#include "hntoolpath.h"
#include "hnmill.h"
#include "hsmemory.h"

#define VEDGE	1

extern IGRchar	*HMinit();
extern void	*HMfree();


/*
 * Global variables for tiler
 */

struct HSlvhl_info		HSlvhl = { 0 };
 
struct HS_window_parms		*active_window	= { 0 };
struct HS_element_parms		element_parms	= { 0 };

struct HS_tiler_parms		tiling_parms	= {	4,	/* number_colors	*/
							3,	/* number_shades	*/
							3,	/* apparent_shades	*/
                                                        0,      /* apparent_shades_fem  */
                                                        -1,     /* start_slot_fem       */
							1,	/* base_color		*/
							HSSTAT_OK,	/* status	*/
							
							0, 0,	/* x/y offset		*/
							
							HS_PMODE_USE_EDGE2 |
							HS_PMODE_DIRECT |
							HS_PMODE_TRANS_1x1 |
							HS_PMODE_CLIP,	/* processing_mode	*/

							2147483640.0,	/* maximum_z	*/
							
							HMinit,	/* malloc function	*/
							HMinit, /* realloc function	*/
							HMfree,	/* free function 	*/

							FALSE,		/* not updating display region */
							HS_STYLE_WIREFRAME,	/*Wireframe region as default	*/
							HS_STYLE_WIREFRAME,	/*Wireframe region for window original default*/
							HS_STYLE_WIREFRAME,	/*Wireframe as default for window with region in it	*/
							0,0,0,0,	/* dr_xmin,dr_ymin,dr_xmax,dr_ymax,	*/
							0,0,		/* dr window_x_dits & window_y_dits */
							0		/* hardware type dr */
							
						};



OM_S_OBJID HSglobal_IGEcolor_id = 0;
OMuword    HSglobal_IGEcolor_os = 0;


/*
 * Global variables for NC Verification
 */
 
struct NC_error_flags	NCerror_flags	= {0};
struct NC_shading_parms	NCshading	= {0};
struct NC_sim_data	NCsim_data	= {0};
struct NC_tool_arrays	NCtool_arrays	= {0};
struct NC_tool_data	NCtool_data	= {0};
struct NC_tool_orient	NCtool_orient	= {0};
struct NC_toolpath_data	NCtoolpath_data	= {0};
struct NC_window_parms	NCwindow	= {0};
NCcbuf NCbackground_c = 0;

#if NC_TIMING
struct NCtd		nc_timing_data[NUM_NC_TIMES] = {0};
#endif

/* Global Variables for rendering */

struct HRrendering_globals rendering_globals = {0};


/* Global Variables for styled raster edges */

double	*style = NULL;
int	style_state = 1;

/*
 * global variables for raster/vector edges
 */

#if VEDGE 
int	curr_span = 0;
#endif

/*
 *  stuff for texture maps
 */

struct MMinfo_list	*MMinfo_list_top = NULL;
struct MMinfo_list	*MMinfo_list_bottom = NULL;
int			MMtexture_memory_limit = 0;
int			MMtexture_memory_used = 0;

/*
 * Translucency 3x3 grid pattern.
 */

unsigned char trans_pat6[6][6] = { 1, 1, 1, 0, 0, 0,
				  1, 1, 1, 0, 0, 0,
				  1, 1, 1, 0, 0, 0,
				  0, 0, 0, 1, 1, 1,
				  0, 0, 0, 1, 1, 1,
				  0, 0, 0, 1, 1, 1 };

unsigned char trans_pat4[4][4]  = { 1, 1, 1, 0,
		 		   1, 0, 0, 1,
				   0, 1, 1, 0,
				   1, 0, 1, 1 };


/*
	A 4x4 dither pattern is used to display 16 intermediate shades between
	two consecutive shades.  The pattern matrix is defined as follows:

	The dither pattern is based on the following 4x4 matrix:

		+---+---+---+---+
		| 1 | 9 | 3 | 11|
		+---+---+---+---+
		| 13| 5 | 15| 7 |
		+---+---+---+---+
		| 4 | 12| 2 | 10|
		+---+---+---+---+
		| 16| 8 | 14| 6 |
	      x +---+---+---+---+
	       / y

	If you think of the screen as a collection of 4x4 patches of pixels,
	then this matrix would represent any one of those patches.  Therefore,
	given that the base origin is <0,0>, and that its value is 16, then 
	pixel <5,0> also has a value of 16, <0,5> has a value of 16, <5,5> has
	a value of 16, an so on.

		To find the value of a given pixel, mod the x and y offset of
	the pixel with 4, and use the results to index into the matrix.

		Using the 4x4 matrix, we can represent 16 shades: 1 pure shade,
	i.e., all the pixels in the 4x4 area will be the same intensity, plus
	15 more shades that are a combination of the current shade and the next
	consecutive intensity.  Therefore, if, for a given color, we have
	defined 4 shades, (or 4 different levels of intensity), we can display
	49 different shades, (49 = 3 * 16 + 1: three pairs of shades from which
	we can make 16 shades, plus one extra).

		The ENVIRON V library has three routines that can be used to
	display the dither pattern: FGCOLOR, BGCOLOR and BLENDLINE.  Using
	FGCOLOR and BGCOLOR, I can specify two different colors, (in this case,
	two consecutive shades of a given  color).  Then, using BLENDLINE, I
	can define how those two shades are to be mixed for the coming draw.
	Therefore, if I know how the colors are to be mixed for a shade, then
	I can tell BLENDLINE, and do a single draw.

		For use with BLENDLINE, I have defined a matrix, PATTERN,
	which contains all possible bit patterns for all 16 shades.  

		The first consideration in the matrix is that when BLENDLINE is 
	called the pattern starts at the current pen position (pen position 
	being where we stopped after the last draw or move), and the patterns
	are anchored to the screen origin.  Therefore, if the pattern to 
	download is '0001', then:

		x mod 4 | download
		--------+---------
		   0    | 0001
		   1    | 0010
		   2    | 0100
		   3    | 1000

		Therefore, for a given pattern, there are four possiblites to
	download.   Considering speed, I decided to save all four possiblites
	in the pattern matrix.

		The next consideration is that a pattern is along a row, that
	for a given shade, there will be four possible patterns depending on
	the y location of the row.  Therefore, for a given shade, there are
	four row patterns.  From the first consideration, this means that
	for any one shade, there are 16 possible patterns to download.

		Since the table has to represent 16 shades, the final table
	contains 256 entries.  The indexing into this table is:

		PATTERN [Y mod 4] [SHADE mod 16] [X mod 4]

	where
		x, y --- the offset of the pixel
		shade -- the shade of the pixel


		Given the shade and color of the pixel, plus the number of
	shades and colors defined in the color table, to calculate the values
	for BLENDLINE, do

		C1 = shade / 16 * num_shades + color
		C2 = shade / 16 * num_shades + color + num_colors

	with  C1 sent to FGCOLOR and C2 sent to BGCOLOR. When the DRAW 
	procedure is called, it looks at the pattern from BLENDLINE, and if a
 	pixel to be drawn has a represented value of 1, then the FGCOLOR
	value is used, else the BGCOLOR entry is used.
*/
 
unsigned char	pattern[4][4] = {  0,  8,  2, 10,
				  12,  4, 14,  6,
				   3, 11,  1,  9,
				  15,  7, 13,  5  };

unsigned char	patterns[4][16][4] =
	{ 0xff, 0xff, 0xff, 0xff,
	  0x77, 0xff, 0xff, 0xff,
	  0x77, 0xff, 0xdd, 0xff,
	  0x77, 0xff, 0x55, 0xff,
	  0x55, 0xff, 0x55, 0xff,
	  0x55, 0xbb, 0x55, 0xff,
	  0x55, 0xbb, 0x55, 0xee,
	  0x55, 0xbb, 0x55, 0xaa,
	  0x55, 0xaa, 0x55, 0xaa,
	  0x55, 0x22, 0x55, 0xaa,
	  0x55, 0x22, 0x55, 0x88,
	  0x55, 0x22, 0x55, 0x00,
	  0x55, 0x00, 0x55, 0x00,
	  0x11, 0x00, 0x55, 0x00,
	  0x11, 0x00, 0x44, 0x00,
	  0x11, 0x00, 0x00, 0x00,

	  0xff, 0xff, 0xff, 0xff,
	  0xee, 0xff, 0xff, 0xff,
	  0xee, 0xff, 0xbb, 0xff,
	  0xee, 0xff, 0xaa, 0xff,
	  0xaa, 0xff, 0xaa, 0xff,
	  0xaa, 0x77, 0xaa, 0xff,
	  0xaa, 0x77, 0xaa, 0xdd,
	  0xaa, 0x77, 0xaa, 0x55,
	  0xaa, 0x55, 0xaa, 0x55,
	  0xaa, 0x44, 0xaa, 0x55,
	  0xaa, 0x44, 0xaa, 0x11,
	  0xaa, 0x44, 0xaa, 0x00,
	  0xaa, 0x00, 0xaa, 0x00,
	  0x22, 0x00, 0xaa, 0x00,
	  0x22, 0x00, 0x88, 0x00,
	  0x22, 0x00, 0x00, 0x00,

	  0xff, 0xff, 0xff, 0xff,
	  0xdd, 0xff, 0xff, 0xff,
	  0xdd, 0xff, 0x77, 0xff,
	  0xdd, 0xff, 0x55, 0xff,
	  0x55, 0xff, 0x55, 0xff,
	  0x55, 0xee, 0x55, 0xff,
	  0x55, 0xee, 0x55, 0xbb,
	  0x55, 0xee, 0x55, 0xaa,
	  0x55, 0xaa, 0x55, 0xaa,
	  0x55, 0x88, 0x55, 0xaa,
	  0x55, 0x88, 0x55, 0x22,
	  0x55, 0x88, 0x55, 0x00,
	  0x55, 0x00, 0x55, 0x00,
	  0x44, 0x00, 0x55, 0x00,
	  0x44, 0x00, 0x11, 0x00,
	  0x44, 0x00, 0x00, 0x00,  

	  0xff, 0xff, 0xff, 0xff,
	  0xbb, 0xff, 0xff, 0xff,
	  0xbb, 0xff, 0xee, 0xff,
	  0xbb, 0xff, 0xaa, 0xff,
	  0xaa, 0xff, 0xaa, 0xff,
	  0xaa, 0xdd, 0xaa, 0xff,
	  0xaa, 0xdd, 0xaa, 0x77,
	  0xaa, 0xdd, 0xaa, 0x55,
	  0xaa, 0x55, 0xaa, 0x55,
	  0xaa, 0x11, 0xaa, 0x55,
	  0xaa, 0x11, 0xaa, 0x44,
	  0xaa, 0x11, 0xaa, 0x00,
	  0xaa, 0x00, 0xaa, 0x00,
	  0x88, 0x00, 0xaa, 0x00,
	  0x88, 0x00, 0x22, 0x00,
	  0x88, 0x00, 0x00, 0x00 };


struct fem_rgb	fem_column[MAX_NUM_FEM_SHADES] = { 0 };
int 		fem_background = 0;
int 		fem_meshcolor = 0;

IGRint     num_intens = 0;
IGRshort   *context_rgb_table = NULL;
/*struct WLcmap_entry       IGEphys_vlt[512] = { 0 };*/

/* To help offset memory management problems in Display Image, we need to */
/* keep track of the amount of memory freed in previous calls to the      */
/* command.                                                               */
IGRint     freed_mem = 0;
