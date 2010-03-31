#include <stdio.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>
#if defined (CLIX)
#include "odi.h"
#endif
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPstruct.h"
#include "hsvhl.h"

#ifdef X11
#include "X11/Xlib.h"
#include "X11/Xutil.h"
#endif

struct HPglobal_struct				HPglobal = { 0 };
struct HPcommand_line_info_struct		HPcommand_line = { 0 };
struct HPplotfile_header			HPheader = { 0 };
struct HPdevice_info_struct			HPdevice = { 0 };
struct HPenvironment_variable_info_struct	HPenv_var = { 0 };


struct HPband_info_struct	HPband_info		= { 0 };

FILE				*HPreport_file		= NULL;

struct	timing_stuff
		{
		int	stime, etime;
		int	atime;
		int	ncalls;
		};
		
struct	timing_stuff	timing[100] = { 0 };
struct	tms	 	tms_data = { 0 };

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
*
 
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



 *
 * Translucency 3x3 grid pattern.
 *

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




*/

#ifdef X11
Display		*EXdisplay;
int		EXscreen;
GC		EXgc[40];
unsigned int	EX_win[40];
int		EX_scr[40];
int		EXweight;
#endif

unsigned long int           NULL_OBJID;

