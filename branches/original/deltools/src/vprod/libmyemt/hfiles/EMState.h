#ifndef _EMSTATE
#define _EMSTATE	0


/************************************************************************/
/*									*/
/*	Definitions for a ReGIS state table.				*/
/*									*/
/************************************************************************/

typedef struct
{
	short	command_level;		/* current command level	*/
	short	color_mode;		/* screen color mode-- either	*/
					/*  COLOR, MONOCHROME, or	*/
					/*  BILEVEL			*/
	float	color_table [4][4];	/* the ReGIS color map		*/
	short	fg_col_index;		/* pointer into color_table 	*/
					/*  entry which holds		*/
					/*  foreground color		*/
	short	bg_col_index;		/* pointer into color_table	*/
					/*  entry which holds		*/
					/*  background color		*/
	int	window_number;		/* number of window in which	*/
					/*  the terminal is operating	*/
	int	screen_number;		/* number of virtual screen	*/
					/*  window resides in		*/
} ReGIS_state;


/* Settings for color_mode field */

#define COLOR		0
#define MONOCHROME	1
#define BILEVEL		2


/* Column Indices for color_table[][] matrix				*/
/*									*/
/* The color table is a 4 x 4 matrix.  Each row represents an entry	*/
/* in the ReGIS color map (i.e., four different colors are displayable	*/
/* at any one time).  Each entry is composed of four entries (columns).	*/
/* The contents of each column are implied by the following definitions.*/

#define HUE		0
#define LIGHTNESS	1
#define SATURATION	2
#define MONO_LIGHTNESS	3


/* Miscellaneous Preprocessor Symbols */

#define COLOR_ONLY		0	/* used when setting color 	*/
#define MONO_AND_COLOR		1	/*  table entries		*/

#define INVALID_LOCATION	0	/* denotes out-of-range loc.	*/
#define VALID_LOCATION		1	/* denotes in-range location	*/

#define FOREGROUND		0	/* color index specifiers	*/
#define BACKGROUND		1

#define MIN_BIT_PLANES		4	/* minimum number of planes	*/
					/*  needed to enter COLOR or	*/
					/*  (four shade) MONOCHROME	*/
					/*  mode			*/

#define BLACK			0	/* black index when in BILEVEL	*/
					/*  mode			*/
#define WHITE			-1	/* white index when in BILEVEL	*/
					/*  mode			*/

#define BLACK_FIXED		3	/* black index when in BILEVEL	*/
					/*  mode in fixed vlt		*/
#define WHITE_FIXED		7	/* white index when in BILEVEL	*/
					/*  mode in fixed vlt		*/

#define VLT_OFFSET		0	/* offset from fixed_vlt_offset	*/
					/*  to start of color table	*/

#define RGB_VLT_OFFSET		4	/* offset for RGB vlt		*/

#define BACK_CT_INDEX		0	/* default color table index	*/
					/*  for the background color	*/

#define BOLD_CT_INDEX		2	/* color table index for the	*/
					/*  bold character color	*/

#define FORE_CT_INDEX		3	/* default color table index	*/
					/*  for the foreground color	*/


/* Declarations for functions */

extern void	_EMDefaultSettings ();
extern void	_EMSetCommandLevel ();
extern short	_EMGetCommandLevel ();
extern void	_EMSetColorMode ();
extern short	_EMGetColorMode ();
extern void	_EMSetColorTable ();
extern int	_EMReadColorTable ();
extern void	_EMSetColorIndex ();
extern short	_EMGetColorIndex ();
extern void	_EMSetForeground ();
extern void	_EMSetBackground ();
extern void	_EMColorTableToVlt ();
extern void	_EMSetScreenNumber ();
extern int	_EMGetScreenNumber ();
extern void	_EMSetWindowNumber ();
extern int	_EMGetWindowNumber ();


#endif
