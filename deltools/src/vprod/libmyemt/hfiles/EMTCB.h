#ifndef _EMTYPES
#define _EMTYPES	0


#ifndef MAX_SCREENS
#include <tools.h>
#endif

#include <stdio.h>
#include "EMTerm.h"
#include "EMState.h"


typedef unsigned char	Char8;
typedef unsigned short	Char16;


/************************************************************************/
/*									*/
/*	Keyboard Macro Type Definition					*/
/*									*/
/************************************************************************/

typedef union
{
	Char16	*ptr;	/* pointer to macro string if >1 character	*/
	Char16	chr;	/* character, if macro is single character	*/
} EMmacro;


/************************************************************************/
/*									*/
/*	Attribute Flags Type Definition					*/
/*									*/
/************************************************************************/

typedef struct
{
	unsigned normal		: 1;	/* T => character possesses the	*/
	unsigned underline	: 1;	/*	specified attribute	*/
	unsigned reverse	: 1;
	unsigned bold		: 1;	/* F => character does not	*/
	unsigned graphics	: 1;	/*	possess the specified	*/
	unsigned erasable	: 1;	/*	attribute		*/
	unsigned color		: 1;
	unsigned blinking	: 1;

	short	text_color;		/* current text color		*/
	short	cell_color;		/* current character cell color */
} EMattribute_flags;


/************************************************************************/
/*									*/
/*	Screen Row Type Definition					*/
/*									*/
/************************************************************************/

typedef struct
{
	Char8	character[VTCOL];	/* character's ASCII code	*/
	Char8	char_attr[VTCOL];	/* display attributes		*/
	Char8	char_color[VTCOL];	/* character's color		*/
	Char8	cell_color[VTCOL];	/* character cell's color	*/
	char	font_table;		/* row's font table		*/
	char	all_chars_norm;		/* T => all characters on row	*/
					/*	are normal		*/
					/* F => some characters on row	*/
					/*	have other attributes	*/
					/*	(e.g., bold, underlined)*/
} EMscreen_row;


/* Character Attribute Bit Masks (for EMscreen_row.char_attr) */
#define	CHAR_NORMAL	0x01
#define	CHAR_REVERSE	0x02
#define	CHAR_UNDERLINE  0x04
#define	CHAR_BOLD	0x08
#define	CHAR_GRAPHICS   0x10
#define	CHAR_ERASABLE   0x20
#define	CHAR_COLOR	0x40	/* character has non-default colors */
#define CHAR_BLINK      0x80



/************************************************************************/
/*									*/
/*	Terminal Control Block (TCB) Type Definition			*/
/*									*/
/************************************************************************/

typedef struct
{
	int	TCBD;		/* terminal instance descriptor		*/
				/* (index into EM_TCB_list array)	*/

	/*--------------------------------------------------------------*/
	/*	Window Variables					*/
	/*--------------------------------------------------------------*/
	int	window;		/* number of the window in which the	*/
				/*  terminal instance is displayed	*/
	int	x1, y1;		/* coordinates of terminal relative to	*/
	int	x2, y2;		/*  window's origin (x1 and y1 are	*/
				/*  always zero)			*/
	int	wx1, wy1;	/* coordinates of terminal relative to	*/
	int	wx2, wy2;	/*  window's origin (excluding border)	*/

	int	cx1, cy1;	/* current clipbox			*/
	int	cx2, cy2;
	int	sx1[5], sy1[5];	/* clipbox stack (for nesting)		*/
	int	sx2[5], sy2[5];
	int	sIndex;		/* clipbox stack index			*/

	/*--------------------------------------------------------------*/
	/*	Scrolling Variables					*/
	/*--------------------------------------------------------------*/
	int	scr_x1;		/* coordinates defining the block	 */
	int	scr_y1;		/*  of raster data which will be	*/
	int	scr_x2;		/*  scrolled up or down			*/
	int	scr_y2;

	int	in_region;	/* T => cursor is inside scroll region	*/
				/* F => cursor is outside scroll region	*/


	/*--------------------------------------------------------------*/
	/*	Font, Cursor, and Character Size Variables		*/
	/*--------------------------------------------------------------*/
	int	cell_width;	/* pixel width of a character cell;	*/
				/*  independent of current font		*/
	int	active_width;	/* pixel width of a character in the	*/
				/*  currently used font		*/
	int	char_width[4];	/* pixel widths for single-width and	*/
				/*  double-width characters in 80 and	*/
				/*  132 column fonts			*/
	int	char_height;	/* pixel height of all characters	*/

	int	font_table_80[12];	/* table of 80-column font IDs	*/
	int	font_table_132[12];	/* table of 132-column font IDs	*/

	int	*font_table;	/* pointer to the beginning of the	*/
				/*  current font table			*/

	int	g0_font;	/* F => G0 font is ASCII text font	*/
				/* T => G0 font is special graphics	*/

	int	g1_font;	/* F => G1 font is ASCII text font	*/
				/* T => G1 font is special graphics	*/

	int	character_set;	/* T => G1 character set active		*/
				/* F => G0 character set active		*/

	char	blink;		/* blink state of cursor; when		*/
				/*  blinking, tells if cursor is	*/
				/*  currently on or off			*/
	char	blink_t;	/* blink state of text; 		*/


	/*--------------------------------------------------------------*/
	/* 	Row Order Variables					*/
	/*--------------------------------------------------------------*/
	int	row_order[VTROW];	/* array of indices into screen	*/
					/*  matrix; reflects the proper	*/
					/*  ordering of rows		*/

	int	top_scroll;	/* points into the "row_order" array to */
				/*  the first line (row) of a scroll	*/
				/*  region; usually the top line of	*/
				/*  the scroll buffer			*/

	int	bot_scroll;	/* points into the "row_order" array to */
				/*  the last line of a scroll region;	*/
				/*  usually the bottom line of the	*/
				/*  scroll buffer			*/

	int	current_line;	/* points into the "row_order" array to */
				/*  the current line			*/

	/*--------------------------------------------------------------*/
	/*	Escape Sequence and Keyboard Processing Variables	*/
	/*--------------------------------------------------------------*/
	int	(*esc_func) ();		/* pointer to current escape	*/
					/*  seq. processing function	*/

	int	within_esc_seq;		/* T => currently processing an	*/
					/*  escape sequence		*/

	int	within_func_key;	/* T => currently processing a	*/
					/*	function key code	*/

	int	withinCursorKey;	/* T => currently processing a	*/
					/*	keypad/cursor key code	*/

	int	end_of_line;		/* T => cursor is at the last	*/
					/*	column of a line	*/

	int	active;			/* T => active TCB		*/

	int	keyboardState;		/* F => XOFF has been received	*/
					/* T => accept keyboard input	*/

	int	translateC1;		/* T => translate C1 to C0	*/

	int	insert_mode;		/* T => insert mode		*/
					/* F => over-write mode		*/

	char	erase_character;	/* character used to over-write	*/
					/*  erased characters		*/

	Char8	esc_seq_buffer[30];	/* buffer for stored	*/
					/*  esc seq. parameters	*/
	Char8	*esc_buff_ptr;		/* ptr to current pos'n	*/
	Char8	*last_param;		/* ptr to last param in	*/
					/*  escape seq. buffer	*/

	char	*report_buffer;		/* ptr to buffer of data to be	*/
					/*  returned to host		*/
	int	report_count;		/* # of bytes in the buffer	*/

	/*--------------------------------------------------------------*/
	/*	Screen Matrix Variables					*/
	/*--------------------------------------------------------------*/
	int		displayed_rows; 	/* number displayed	*/
						/*  columns		*/
	int		col_width;		/* number of displayed	*/
						/*  columns 		*/

	EMscreen_row	*screen;		/* screen contents	*/

	EMscreen_row	*current_row;		/* pointer to current	*/
						/*  row of screen	*/

	int		current_col;		/* current column of	*/
						/*  screen		*/

	/*--------------------------------------------------------------*/
	/*	Scroll Buffer Variables					*/
	/*--------------------------------------------------------------*/
	char	*scroll_buf;			/* circular scroll	*/
						/* buffer		*/

	int	bot_buf;			/* 1 + bottom line of	*/
						/*  buffer; i.e., next	*/
						/*  line to write to	*/

	int	buf_lines;			/* # of lines in buffer	*/

	int	scrolled_back;			/* boolean; tells when	*/
						/*  scrolled back into	*/
						/*  buffer		*/

	int	buf_win;			/* first line of buffer	*/
						/*  that is displayed	*/
						/*  in the window	*/

	int	start_sel, end_sel;		/* start & end of text	*/
						/*  selection		*/

	EMscreen_row	*save_screen;		/* attributes of pri-	*/
						/* mary screen saved	*/
						/* here when scrolling	*/
						/* in scroll buffer	*/

	/*--------------------------------------------------------------*/
	/*	Keyboard Macro Arrays					*/
	/*--------------------------------------------------------------*/
	Char8	key_type[512];		/* array of key types for every	*/
					/*  key on the keyboard		*/

	EMmacro key_macro[512];		/* array of macro string	*/
					/*  pointers/characters for	*/
					/*  every key			*/

	int	macroEnable;		/* used for preventing		*/
					/*  recursive macros		*/


	/*--------------------------------------------------------------*/
	/*	User-definable function keys				*/
	/*--------------------------------------------------------------*/
	char	*udk[15];	/* strings for each udk (shift F6-F20)	*/

	int	udk_index;	/* current udk being defined		*/

	char	*udk_char_ptr;	/* ptr to next udk char defined		*/

	int	udk_digit;	/* tells which digit of hex pair is	*/
				/*  being defined			*/


	/*--------------------------------------------------------------*/
	/*	Terminal Settings and Display Attributes		*/
	/*--------------------------------------------------------------*/
	EMattribute_flags
		active_attributes;	/* active display attributes	*/

	EMTermSettings
		term_settings;		/* terminal states		*/

	int	unused;		/* used to be bit_8; moved to		*/
				/*  term_settings (above)		*/

	int	setup_enabled;	/* F => "setup" disabled		*/
				/* T => "setup" enabled			*/

	char	last_menu;	/* first character of the command	*/
				/*  string of the last menu brought up	*/

	int	hold_status;	/* current on/off state stored as	*/
				/*  either XON or XOFF			*/


	/*--------------------------------------------------------------*/
	/*	ReGIS Processing Variables and Color Variables		*/
	/*--------------------------------------------------------------*/
	short	foreground_color;	/* VLT index for fg color	*/
	short	background_color;	/* VLT index for bg color	*/

	int	ReGIS_mode;		/* T => executing in ReGIS mode	*/
	int	ReGIS_com_level;	/* level ReGIS was entered at	*/
	int	nest_level;		/* level of nesting within a	*/
					/*  ReGIS command.  0 between	*/
					/*  commands, incremented after	*/
					/*  '(', decremented after ')'	*/

	char	ReGIS_com_buffer[80];
	char	*ReGIS_buf_ptr;
	ReGIS_state	state_table;

	/*--------------------------------------------------------------*/
	/*	Printer Variables					*/
	/*--------------------------------------------------------------*/
	int	printer_port;		/* auxilliary port to which the */
					/*  printer is connected	*/

	/*--------------------------------------------------------------*/
	/*	ESC 7 and ESC 8 Save/Restore Variables			*/
	/*--------------------------------------------------------------*/
	EMattribute_flags	save_attributes;
	EMTermSettings		save_term_settings;
	int			save_line;
	int			save_col;
	int			save_char_set;
	int			save_g0_font;
	int			save_g1_font;

	/*--------------------------------------------------------------*/
	/*	Miscellaneous						*/
	/*--------------------------------------------------------------*/
	FILE	*log_file;		/* log file stream pointer	*/

} EM_TCB;


/* Macro Key Types (for EM_TCB.key_type) */
#define  NORMAL_CHAR	0	/* no macro assigned to key		*/
#define  SINGLE_CHAR	0x01	/* macro is single character		*/
#define  STRING_CHAR	0x02	/* macro contains more than one char	*/

/* All keyboard modes but this one are #defined in <tools.h> */
#define	KEYBD_DEC_APPL_CURSOR_MODE	0x10000


#endif
