#include <string.h>
#include <ctype.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"

/**********************/
/* Initial font names */
/**********************/
static char font132_15[] = "/usr/ip32/vt200/font/fixt.7";
static char font132_7[] = "/usr/ip32/vt200/font/fix.7";
static char *font132 = font132_15;
static char *font_mods[12] = {	"", "ds", "ds", "dd", "dd", "sd",
				".g", "ds.g", "ds.g", "dd.g",
				"dd.g", "sd.g"};

/* Font drawing modes:		*/
/* 	0	normal		*/
/*	1	top half	*/
/*	2	bottom half	*/
int _EMFontModes[12] = { 0, 1, 2, 1, 2, 0, 0, 1, 2, 1, 2, 0 };


char EMfont_name_80[12][64];
char EMfont_name_132[12][64];

struct scr_info _EMScreenInfo[MAX_SCREENS];


void	_EMLoadRGBVLT ();
int	_EMEscLevelOne();
void	_EMUpdateKeyboardMode ();
void	_EMPutEnv ();
char	*getenv ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInitTCB					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMInitTCB (TCB, window, font, setup, color,		*/
/*			  col_flag, x1, y1, x2, y2, buf_scr)		*/
/*									*/
/*	  EM_TCB  *TCB;							*/
/*	  int	  window;						*/
/*	  char	  *font;						*/
/*	  int	  setup;						*/
/*	  int	  color;						*/
/*	  int	  col_flag;						*/
/*	  int	  x1, y1, x2, y2;					*/
/*	  int	  buf_scr;						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function initializes all fields of a terminal control	*/
/*	  block structure.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If the TCB is successfully initialized, a zero value is   	*/
/*	  returned.  A non-zero error value is returned if any of	*/
/*	  the following conditions are true:				*/
/*									*/
/*		1.  The specified font cannot be loaded.		*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMInitTCB (TCB, window, font, setup, color, col_flag, x1, y1, x2, y2,
		buf_scr)

EM_TCB	*TCB;
int	window;
char	*font;
int	setup;
int	color;
int	col_flag;
int	x1, y1, x2, y2;
int	buf_scr;
{
	int	char_height;	/* pixel height of a character cell	*/
	int	char_width;	/* pixel width of a character cell	*/
	int	maxWidth;
	int	baseline;
	int	i, j;		/* loop counters			*/
	int 	load_error;	/* status indicator for font loads	*/
				/*  (0 => no error, 1 => error)		*/
	int	return_code;	/* status code returned to caller	*/
	int	vs_no;		/* virtual screen number		*/
	int	screens;	/* size of scroll buffer		*/
	char	*slash;
	char	*suffix80;	/* suffix of 80 column font name	*/
	char	*suffix132;	/* suffix of 132 column font name	*/
	char	prefix80[32];	/* prefix of 80 column font name	*/
	char	prefix132[32];	/* prefix of 132 column font name	*/



	/*--------------------------------------------------------------*/
	/*	Initialize Window Variables				*/
	/*--------------------------------------------------------------*/
	TCB->window = window;

	/* Save coordinates of terminal */
	TCB->x1 = x1;
	TCB->y1 = y1;
	TCB->x2 = x2;
	TCB->y2 = y2;

	TCB->wx1 = x1 + XBORDER;
	TCB->wy1 = y1 + YBORDER;
	TCB->wx2 = x2 - XBORDER;
	TCB->wy2 = y2 - XBORDER;

	/* Initialize the clipbox stack */
	TCB->sIndex = 0;


	/* Initialize the font name arrays */
	if (((slash = strrchr (font, '/')) != NULL) &&
	    !strcmp (slash + 1, "fix.7"))
	    font132 = font132_7;

	suffix80 = strrchr (font, '.');
	strncpy (prefix80, font, suffix80 - font);
	prefix80[suffix80 - font] = '\0';
	suffix132 = strrchr (font132, '.');
	strncpy (prefix132, font132, suffix132 - font132);
	prefix132[suffix132 - font132] = '\0';
	for (i = 0; i < 12; i++)
	{
	    sprintf (EMfont_name_80[i], "%s%s%s", prefix80, font_mods[i],
		     suffix80);
	    sprintf (EMfont_name_132[i], "%s%s%s", prefix132, font_mods[i],
		     suffix132);
	}

	/* Initialize the font-id tables.  A -1 indicates that a font is */
	/* not currently open.						 */
	for (i = 0; i < 12; i++)
	{
	    TCB->font_table_80[i] = -1;
	    TCB->font_table_132[i] = -1;
	}    

	/* Load the requested font. */
	load_error = Load_symbol_file (font, &TCB->font_table_80[0]);

	if (!load_error)
	{
	    /*--------------------------------------------------*/
	    /*	Initialize Font, Cursor, and Character Size	*/
	    /* 	Variables					*/
	    /*--------------------------------------------------*/

	    /* Find the character cell height and width of the font. */
	    Inq_font (TCB->font_table_80[0], &char_height, &maxWidth,
		      &baseline);
	    if (char_height < 15)	/* there's always a kludge... */
		char_height++;

	    Inq_string_width (TCB->font_table_80[0], "X", 1, &char_width);

	    TCB->char_width[0] = char_width;
	    TCB->char_width[1] = 2 * char_width;
	    TCB->char_height = char_height;

	    /* Initialize other cursor and font variables. */
	    TCB->active_width = TCB->cell_width = TCB->char_width[0];
	    TCB->font_table = &TCB->font_table_80[0];
	    TCB->g0_font = 0;
	    TCB->g1_font = 0;
	    TCB->character_set = 0;

	    /* Load the 132-column font */
	    load_error = Load_symbol_file (EMfont_name_132[0], 
					   &TCB->font_table_132[0]);

	    if (load_error)	/* If fixt.7 doesn't exist... */
	    {
		strcpy (EMfont_name_132[0], font132_7);
		load_error = Load_symbol_file (EMfont_name_132[0], 
					       &TCB->font_table_132[0]);
	    }

	    if (!load_error)
	    {
		Inq_font (TCB->font_table_132[0], &char_height, &maxWidth,
			  &baseline);
		Inq_string_width (TCB->font_table_132[0], "X", 1, &char_width);

		TCB->char_width[2] = char_width;
		TCB->char_width[3] = 2 * char_width;
	    }


	    /*------------------------------------------*/
	    /*	Initialize Color and ReGIS Variables	*/
	    /*------------------------------------------*/

	    /* Initialize the ReGIS state table. */
	    Inq_win_vs (window, &vs_no);
	    _EMSetScreenNumber (&TCB->state_table, vs_no);
	    _EMSetWindowNumber (&TCB->state_table, TCB->window);

	    /* Initialize the fixed vlt offset */
	    for (i = 0; i < MAX_SCREENS; i++)
	    {
		if (_EMScreenInfo[i].vsi_flags & VSI_VLT_FIXED)
		{
		    _EMFixedVLTOffset[i] =
				_EMScreenInfo[i].vsi_fixed_vlt_start +
				_EMScreenInfo[vs_no].vsi_fixed_vlt_size;
		}
		else
		    _EMFixedVLTOffset[i] = 1;
	    }

	    if (color && _EMEnoughBitPlanes (vs_no))
	    {
		/* Load the ReGIS color table (VLT). */
		_EMDefaultSettings (&TCB->state_table, COLOR);

		/* Load the RGB (ANSI) VLT. */
		_EMLoadRGBVLT (vs_no);
	    }
	    else
		_EMDefaultSettings (&TCB->state_table, BILEVEL);

	    Set_win_vs_swap (TCB->window, _EMSwapVSAbility (color));

	    /* Initialize other color and ReGIS variables. */
	    TCB->ReGIS_mode = 0;
	    TCB->ReGIS_buf_ptr = TCB->ReGIS_com_buffer;
	    TCB->nest_level = 0;
	    TCB->foreground_color =
			_EMGetColorIndex (&TCB->state_table, FOREGROUND) +
			VLT_OFFSET + _EMFixedVLTOffset[vs_no];
	    TCB->background_color =
			_EMGetColorIndex (&TCB->state_table, BACKGROUND) +
			VLT_OFFSET + _EMFixedVLTOffset[vs_no];


	    /*------------------------------------------*/
	    /*	Initialize Screen Matrix Variables	*/
	    /*------------------------------------------*/

	    /* Calculate the number of displayable rows and columns. */
	    TCB->displayed_rows = (TCB->wy2 - TCB->wy1 + 1) / TCB->char_height;
	    if (col_flag == -1)
		TCB->col_width = (TCB->wx2 - TCB->wx1 + 1) / TCB->char_width[0];
	    else
		TCB->col_width = (col_flag ? 132 : 80);

	    if (TCB->displayed_rows > VTROW)
		TCB->displayed_rows = VTROW;

	    if (TCB->col_width > VTCOL)
		TCB->col_width = VTCOL;

	    TCB->wx2 = TCB->wx1 + TCB->col_width * TCB->cell_width - 1;
	    TCB->wy2 = TCB->wy1 + TCB->displayed_rows * TCB->char_height - 1;

	    /* Allocate the screen matrix */
	    TCB->screen = (EMscreen_row *) malloc (TCB->displayed_rows *
						   sizeof (EMscreen_row));

	    /* Initialize the screen matrix */
	    _EMInitRows (TCB, 0, TCB->displayed_rows);

	    /* Initialize the "current row" pointer. */
	    TCB->current_row = &TCB->screen[0];


	    /*------------------------------------------*/
	    /*	Initialize Scrolling Variables		*/
	    /*------------------------------------------*/

	    /* Initialize the pixel coordinates the block of	*/
	    /* raster data to be scrolled			*/
	    TCB->scr_x1 = TCB->wx1;
	    TCB->scr_y1 = TCB->wy1;
	    TCB->scr_x2 = TCB->wx2;
	    TCB->scr_y2 = TCB->wy2;

	    TCB->in_region = TRUE;


	    /*------------------------------------------*/
	    /*	Initialize Row Order Variables		*/
	    /*------------------------------------------*/

	    /* Initialize the row order matrix to indicate a	*/
	    /* sequential ordering, starting at row 0		*/
	    for (i = 0; i < VTROW; i++)
		TCB->row_order[i] = i;

	    /* Initialize other row order variables. */
	    TCB->top_scroll = 0;
	    TCB->bot_scroll = TCB->displayed_rows - 1;
	    TCB->current_line = 0;

	    /*--------------------------------------------------*/
	    /* 	Initialize Escape Sequence and Keyboard		*/
	    /*	Processing Variables.				*/
	    /*--------------------------------------------------*/
	    TCB->esc_func = _EMEscLevelOne;
	    TCB->within_esc_seq = FALSE;
	    TCB->within_func_key = FALSE;
	    TCB->withinCursorKey = FALSE;
	    TCB->keyboardState = TRUE;
	    TCB->translateC1 = TRUE;
	    TCB->current_line = 0;
	    TCB->insert_mode = FALSE;
	    TCB->erase_character = SPACE;
	    TCB->esc_buff_ptr = TCB->esc_seq_buffer;
	    TCB->last_param = TCB->esc_seq_buffer;
	    TCB->report_buffer = NULL;
	    TCB->report_count = 0;


	    /*----------------------------------------------------*/
	    /* 	Initialize Macros				*/
	    /*----------------------------------------------------*/
	    for (i = 0; i < 512; i++)
	    {
		TCB->key_type[i] = NORMAL_CHAR;
		TCB->key_macro[i].ptr = NULL;
	    }
	    TCB->macroEnable = TRUE;


	    /*------------------------------------------*/
	    /* 	Initialize UDKs				*/
	    /*------------------------------------------*/
	    for (i = 0; i < 15; i++)
		TCB->udk[i] = '\0';


	    /*--------------------------------------------------*/
	    /*	Initialize Terminal Settings and Display  	*/
	    /*	Attributes					*/
	    /*--------------------------------------------------*/
	    _EMInitTermSettings (&TCB->term_settings, buf_scr);
	    _EMInitDisplayAttr (&TCB->active_attributes,
				TCB->foreground_color, TCB->background_color);
	    TCB->setup_enabled = setup;
	    TCB->last_menu = (char) 0;
	    TCB->hold_status = XON;
	    _EMUpdateKeyboardMode (TCB);


	    /*--------------------------------------------------*/
	    /*	Initialize Scroll Buffer Variables		*/
	    /*--------------------------------------------------*/

	    TCB->buf_lines = 0;
	    TCB->buf_win = 0;
	    TCB->scroll_buf = 0;
	    TCB->start_sel = TCB->end_sel = 0;

	    screens = TCB->term_settings.bufScreens;
	    TCB->term_settings.bufScreens = 0;
	    _EMSetBufferSize (TCB, screens);	/* init scroll buffer */
	    TCB->save_screen = NULL;


	    /*------------------------------------------*/
	    /*	Initialize Printer Variables		*/
	    /*------------------------------------------*/
	    TCB->printer_port = -1;


	    /*--------------------------------------------------*/
	    /* 	Initialize the Save/Restore Variables which	*/
	    /*    are used with the ESC 7 and ESC 8 sequences.	*/
	    /*--------------------------------------------------*/
	    _EMInitTermSettings (&TCB->save_term_settings, buf_scr);
	    _EMInitDisplayAttr (&TCB->save_attributes, 
				TCB->foreground_color, TCB->background_color);
	    TCB->save_line = 0;
	    TCB->save_col = 0;
	    TCB->save_char_set = TCB->character_set; 
	    TCB->save_g0_font = TCB->g0_font;
	    TCB->save_g1_font = TCB->g1_font;

	    /*------------------------------------------*/
	    /*	Initialize Miscellaneous		*/
	    /*------------------------------------------*/
	    TCB->log_file = NULL;

	    EMActivate (TCB->TCBD);

	    return_code = EM_NO_ERROR;
	}
	else
	    /* The specified font could not be loaded. */
	    return_code = EM_LOAD_FONT_FAILED;


	/* Return to caller. */
	return (return_code);
}





/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInitTermSettings				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMInitTermSettings (term_settings, buf_scr)		*/
/*									*/
/*	  EMTermSettings *term_settings;	-- pointer to parameter	*/
/*						   table to initialize	*/
/*									*/
/*	  int buf_scr;			      -- number of buffered	*/
/*						 screens desired	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function initializes all fields of a specified		*/
/*	  "EMTermSettings" structure.					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMInitTermSettings (term_settings, buf_scr)

EMTermSettings	*term_settings;
int		buf_scr;
{
	int	i;

	term_settings->online = TRUE;
	term_settings->vt200 = TRUE;
	term_settings->numericKeypad = TRUE;
	term_settings->normalCursorKeys = TRUE;
	term_settings->newLine = FALSE;
	term_settings->keyClick = FALSE;
	term_settings->warningBell = TRUE;
	term_settings->answerbackConcealed = FALSE;
	term_settings->tabMovement = FALSE;
	term_settings->eighty = TRUE;
	term_settings->autoWrap = TRUE;  
	term_settings->noScroll = FALSE;
	term_settings->screenReverse = FALSE;
	term_settings->cursorVisible = TRUE;
	term_settings->cursorBlock = TRUE;
	term_settings->formFeed = FALSE;
	term_settings->chngWdErase = FALSE;
	term_settings->cursorOrigin = FALSE;
	term_settings->eraseExtent = FALSE;
	term_settings->localEcho = FALSE;
	term_settings->displayControls = FALSE;
	term_settings->autoRepeat = TRUE;
	keybd_auto_repeat(TRUE);
	term_settings->logFlag = FALSE;
	term_settings->cursorBlinking = FALSE;
	term_settings->bit8 = TRUE;
	if (term_settings->printerMode != NO_PRINTER)
	  term_settings->printerMode = NORMAL_MODE;
	term_settings->printTerminator = FALSE;
	term_settings->udkLock = FALSE;

	/* Initialize the pad */
	for (i = 0; i < 5; i++)
	    term_settings->pad[i] = 0;

	/* Initialize the answerback field. */
	sprintf (term_settings->answerback, "%s", "Hello World!");

	/* Clear the tab map. */
	for (i = 0; i < VTCOL; i++)
	    term_settings->tabMap[i] = FALSE;

	/* Set a tab stop every 8 columns. */
	for (i = 0; i < VTCOL; i += 8)
	    term_settings->tabMap[i] = TRUE;

	/* set number of buffered screens of text scrolled off top */
	term_settings->bufScreens = buf_scr;

	/* no log file name */
	sprintf (term_settings->logFile, "%s", "/usr/tmp/log");

	/* Return to caller. */
	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInitDisplayAttr				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMInitDisplayAttr (attributes, text_color, cell_color)	*/
/*									*/
/*	  EMattribute_flags  *attributes;  -- pointer to the attribute  */
/*			   		      flags structure to	*/
/*					      initialize		*/
/*									*/
/*	  short		     text_color;   -- VLT index for text color  */
/*									*/
/*	  short		     cell_color;   -- VLT index for character   */
/*					      cell background color	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function initializes all fields of a specified		*/
/*	  "EMattribute_flags" structure.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMInitDisplayAttr (attributes, text_color, cell_color)

EMattribute_flags	*attributes;
short			text_color;
short			cell_color;
{
	attributes->normal = TRUE;
	attributes->underline = FALSE;
	attributes->reverse = FALSE;
	attributes->bold = FALSE;
	attributes->blinking = FALSE;
	attributes->graphics = FALSE;
	attributes->erasable = TRUE;
	attributes->color = FALSE;

	attributes->text_color = text_color;
	attributes->cell_color = cell_color;

	/* Return to caller. */
	return (EM_NO_ERROR);
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMLoadRGBVLT					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMLoadRGBVLT (vs_no)					*/
/*									*/
/*	  int 	vs_no;	-- virtual screen whose VLT is to be loaded	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function loads the RGB colors into the VLT for the	*/
/*	  specified virtual screen.					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  none								*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMLoadRGBVLT (vs_no)

int	vs_no;
{
	int		i;
	struct vlt_slot	vlt[8];
	static struct vlt_slot RGB_vlt[8] =
	{	{0, 0, 0, 0},			/* Black	*/
		{1, 65535, 0, 0},		/* Red		*/
		{2, 0, 65535, 0},		/* Green	*/
		{3, 65535, 65535, 0},		/* Yellow	*/
		{4, 0, 0, 65535},		/* Blue		*/
		{5, 65535, 0, 65535},		/* Magenta	*/
		{6, 0, 65535, 65535},		/* Cyan		*/
		{7, 65535, 65535, 65535}	/* White	*/
	};

	memcpy (vlt, RGB_vlt, sizeof (RGB_vlt));

	/* adjust slot # */
	for (i = 0; i < 8; i++)
	    vlt[i].v_slot += RGB_VLT_OFFSET + _EMFixedVLTOffset[vs_no];

	Loadvlt (vs_no, vlt, 8);
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSwapVSAbility				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMSwapVSAbility (color)					*/
/*									*/
/*		int	color;		-- color flag			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function decides whether or not the window should be	*/
/*	  given the ability to swap virtual screens.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  Boolean							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMSwapVSAbility (color)

int	color;
{
	int	i;

	if (color)
	{
	    /* Decide if the window can swap vs */
	    for (i = 0; i < MAX_SCREENS; i++)
	    {
		if ((_EMScreenInfo[i].vsi_flags & VSI_VIRTUAL_SCREEN) &&
		    !_EMEnoughBitPlanes (i))
		    return (FALSE);
	    }
	}
	return (TRUE);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMUpdateKeyboardMode				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMUpdateKeyboardMode (TCB)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to a TCB			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function updates the keyboard mode of the TCB.  If the	*/
/*	  specified TCB is active, the Environ V keyboard mode is set	*/
/*	  to the appropriate value.					*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMUpdateKeyboardMode (TCB)

EM_TCB	*TCB;
{	
    if (TCB->active)
	Set_keyboard_mode (KEYBD_DEC_3KEY_MODE | KEYBD_DEC_APPL_KEYPAD_MODE);
}
