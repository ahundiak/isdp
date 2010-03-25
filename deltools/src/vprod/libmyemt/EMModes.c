#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMError.h"


void	_EMSetQMModes ();
void	_EMSetGTModes ();
void	_EMSetNumericModes ();
void	_EMResetQMModes ();
void	_EMResetGTModes ();
void	_EMResetNumericModes ();
void	_EMUpdateKeyboardMode ();
void	_EMSet132Columns ();
void	_EMSet80Columns ();
void	_EMReverseScreenColors ();




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMChangeTerminalModes				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMChangeTerminalModes (TCB, terminator)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  terminator;	-- the escape sequence terminator	*/
/*				     (either "h" or "l")		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[n;n;n...nh" (set mode) and	*/
/*	  "<ESC>[n;n;n...nl" (reset mode) sequences.  The first		*/
/*	   parameter can be a question mark, a greater-than sign, or	*/
/*	   a numeric value.  All subsequent parameters are assumed	*/
/*	   to be numeric.						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMChangeTerminalModes (TCB, terminator)

EM_TCB	*TCB;
char	terminator;
{
	unsigned char	*parameter_ptr;	/* pointer into the escape	*/
					/*  sequence buffer to the 	*/
					/*  next parameter		*/

	parameter_ptr = TCB->esc_seq_buffer;

	switch (*parameter_ptr)
	{
	    case '?':
		parameter_ptr++;
		if (terminator == 'h')
		    _EMSetQMModes (TCB, parameter_ptr);
		else
		    _EMResetQMModes (TCB, parameter_ptr);
		break;

	    case '>':
		parameter_ptr++;
		if (terminator == 'h')
		    _EMSetGTModes (TCB, parameter_ptr);
		else
		    _EMResetGTModes (TCB, parameter_ptr);
		break;

	    default:
		if (terminator == 'h')
		    _EMSetNumericModes (TCB, parameter_ptr);
		else
		    _EMResetNumericModes (TCB, parameter_ptr);
		break;
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetQMModes					*/
/*			_EMSetGTModes					*/
/*			_EMSetNumericModes				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void set_[QM | GT | numeric]_modes (TCB, parameter_ptr)	*/
/*									*/
/*	  EM_TCB  *TCB;			  -- pointer to active TCB	*/
/*	  unsigned char	  *parameter_ptr; -- pointer into the escape	*/
/*					     sequence buffer to the	*/
/*					     next parameter		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  These functions process escape sequences terminated by "h."	*/
/*									*/
/*	  "_EMSetQMModes" processes sequences whose third byte is a	*/
/*			 question mark (QM).				*/
/*									*/
/*	  "_EMSetGTModes" processes sequences whose third byte is a	*/
/*			 greater-than (GT) sign.			*/
/*									*/
/*	  "_EMSetNumericModes" processes sequences whose third byte	*/
/*			      is an integer.				*/
/*									*/
/*	RETURNED VALUE: none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetQMModes (TCB, parameter_ptr)

EM_TCB		*TCB;
unsigned char	*parameter_ptr;
{
	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 1:
		    /* Set cursor keys to application mode. */
		    TCB->term_settings.normalCursorKeys = FALSE;
		    break;

		case 3:
		    /* Set 132-column mode. */
		    if (TCB->term_settings.eighty)
		    {
			_EMSet132Columns (TCB);
			_EMClearScreen (TCB);
			_EMDisplayScreen (TCB, 0, TCB->displayed_rows,
					  0, TCB->col_width, TRUE);
		    }
		    break;

		case 5:
		    /* Set inverse video mode. */
		    if (! TCB->term_settings.screenReverse)
		    {
			TCB->term_settings.screenReverse = TRUE;
			_EMReverseScreenColors (TCB);
			_EMClearScreen (TCB);
			_EMDisplayScreen (TCB, 0, TCB->displayed_rows,
					  0, TCB->col_width, TRUE);
		    }
		    break;

		 case 6:
		    /* Set cursor origin relative to scroll region. */
		    TCB->term_settings.cursorOrigin = TRUE;
		    _EMUpdatePosAbsolute (TCB, TCB->top_scroll, FALSE);
		    break;

		 case 7:
		    /* Turn autowrap mode on. */
		    TCB->term_settings.autoWrap = TRUE;
		    break;

		 case	8:
		    /* Turn auto repeat mode on. */
		    if (!(TCB->term_settings.autoRepeat))
		    {
			keybd_auto_repeat(TRUE);
			TCB->term_settings.autoRepeat = TRUE;
		    }
		    break;

		 case 18:
		    /* Set the "print screen" terminator to FF. */
		    TCB->term_settings.printTerminator = TRUE;
		    break;

		 case 25:
		    /* Make the cursor visible. */
		    TCB->term_settings.cursorVisible = TRUE;
		    break;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}
}



void _EMSetGTModes (TCB, parameter_ptr)

EM_TCB		*TCB;
unsigned char	*parameter_ptr;
{
	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 4:
		    /* Interpret form-feeds as "home and clear." */
		    TCB->term_settings.formFeed = TRUE;
		    break;

		case 9:
		    /* Erase the screen after a column change. */
		    TCB->term_settings.chngWdErase = TRUE;
		    break;

		case 11:
		    /* Erase only the scroll region after a clear */
		    /* screen or erase command.			 */
		    TCB->term_settings.eraseExtent = TRUE;
		    break;

		case 12:
		    /* Cause a tab to print spaces. */
		    TCB->term_settings.tabMovement = TRUE;
		    break;

		case 14:
		    /* Echo keyboard data locally. */
		    TCB->term_settings.localEcho = TRUE;
		    break;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}

}



void _EMSetNumericModes (TCB, parameter_ptr)

EM_TCB		*TCB;
unsigned char	*parameter_ptr;
{
	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 4:
		    /* Set insert mode. */
		    TCB->insert_mode = TRUE;
		    break;

		case 12:
		    /* Turn off local echo. */
		    TCB->term_settings.localEcho = FALSE;
		    break;

		case 20:
		    /* Interpret line feeds, form feeds,  and	*/
		    /* vertical tabs as newlines.		*/
		    TCB->term_settings.newLine = TRUE;
		    break;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}

}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMResetQMModes					*/
/*			_EMResetGTModes					*/
/*			_EMResetNumericModes				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void reset_[QM | GT | numeric]_modes (TCB, parameter_ptr)	*/
/*									*/
/*	  EM_TCB  *TCB;		  	-- pointer to active TCB	*/
/*	  char	  *parameter_ptr;	-- pointer into the escape	*/
/*					     sequence buffer to the	*/
/*					     next parameter		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  These functions process escape sequences terminated by "l."	*/
/*									*/
/*	  "_EMResetQMModes" processes sequences whose third byte is a	*/
/*			 question mark (QM).				*/
/*									*/
/*	  "_EMResetGTModes" processes sequences whose third byte is a	*/
/*			 greater-than (GT) sign.			*/
/*									*/
/*	  "_EMResetNumericModes" processes sequences whose third byte	*/
/*			       is an integer.				*/
/*									*/
/*	RETURNED VALUE: none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMResetQMModes (TCB, parameter_ptr)

EM_TCB		*TCB;
unsigned char	*parameter_ptr;
{
	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 1:
		    /* Reset cursor keys to normal mode. */
		    TCB->term_settings.normalCursorKeys = TRUE;
		    break;

		case 3:
		    /* Reset 80-column mode. */
		    if (! TCB->term_settings.eighty)
		    {
			_EMSet80Columns (TCB);
			_EMClearScreen (TCB);
			_EMDisplayScreen (TCB, 0, TCB->displayed_rows,
					  0, TCB->col_width, TRUE);
		    }
		    break;

		case 5:
		    /* Reset normal video mode. */
		    if (TCB->term_settings.screenReverse)
		    {
			TCB->term_settings.screenReverse = FALSE;
			_EMReverseScreenColors (TCB);
			_EMClearScreen (TCB);
			_EMDisplayScreen (TCB, 0, TCB->displayed_rows,
					  0, TCB->col_width, TRUE);
		    }
		    break;

		 case 6:
		    /* Reset cursor origin relative the upper	*/
		    /* left corner of the screen.		*/
		    TCB->term_settings.cursorOrigin = FALSE;
		    TCB->in_region = FALSE;
		    _EMUpdatePosAbsolute (TCB, 0, 0);
		    break;

		 case 7:
		    /* Turn autowrap mode off. */
		    TCB->term_settings.autoWrap = FALSE;
		    break;

		 case	8:
		    /* Turn auto repeat mode off. */
		    if (TCB->term_settings.autoRepeat)
		    {
			keybd_auto_repeat(FALSE);
			TCB->term_settings.autoRepeat = FALSE;
		    }
		    break;

		 case 18:
		    /* Set the "print screen" terminator to none. */
		    TCB->term_settings.printTerminator = FALSE;
		    break;

		 case 25:
		    /* Make the cursor invisible. */
		    TCB->term_settings.cursorVisible = FALSE;
		    break;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}
}



void _EMResetGTModes (TCB, parameter_ptr)

EM_TCB		*TCB;
unsigned char	*parameter_ptr;
{
	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 4:
		    /* Interpret form-feeds as line feeds. */
		    TCB->term_settings.formFeed = FALSE;
		    break;

		case 9:
		    /* Preserve the screen after a column change. */
		    TCB->term_settings.chngWdErase = FALSE;
		    break;

		case 11:
		    /* Erase the entire screen after a clear	*/
		    /* screen or erase command.			*/
		    TCB->term_settings.eraseExtent = FALSE;
		    break;

		case 12:
		    /* Cause direct tab movement (no spaces). */
		    TCB->term_settings.tabMovement = FALSE;
		    break;

		case 14:
		    /* Turn off local echo. */
		    TCB->term_settings.localEcho = FALSE;
		    break;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}

}



void _EMResetNumericModes (TCB, parameter_ptr)

EM_TCB		*TCB;
unsigned char	*parameter_ptr;
{
	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 4:
		    /* Reset insert mode to replacement mode. */
		    TCB->insert_mode = FALSE;
		    break;

		case 12:
		    /* Echo keyboard data locally. */
		    TCB->term_settings.localEcho = TRUE;
		    break;

		case 20:
		    /* Interpret line feeds, form feeds,  and	*/
		    /* vertical tabs as line feeds.		*/
		    TCB->term_settings.newLine = FALSE;
		    break;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}

}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSet132Columns				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSet132Columns (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to the active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function enables 132-column mode.  If the 132-column	*/
/*	  font is not opened or setup is disabled, no action is 	*/
/*	  performed.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMSet132Columns (TCB)

EM_TCB	*TCB;
{	
	if (TCB->font_table_132[0] != -1)
	{
	    TCB->font_table = TCB->font_table_132;
	    TCB->cell_width = TCB->char_width[2];
	    TCB->term_settings.eighty = FALSE;

	    if (TCB->term_settings.chngWdErase)
	    {
		_EMClearScreenMatrix (TCB);
		_EMUpdatePosAbsolute (TCB, 0, 0);
	    }		  

	    /* Set the new column width. */
	    TCB->col_width = 132;
	    TCB->scr_x2 = TCB->wx2 = TCB->wx1 +
				TCB->col_width * TCB->char_width[2] - 1;
	}
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSet80Columns					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSet80Columns (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to the active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function enables 80-column mode.  If the 80-column	*/
/*	  font is not opened or setup is disabled, no action is 	*/
/*	  performed.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMSet80Columns (TCB)

EM_TCB	*TCB;
{
	if (TCB->font_table_80[0] != -1)
	{
	    TCB->font_table = TCB->font_table_80;
	    TCB->cell_width = TCB->char_width[0];
	    TCB->term_settings.eighty = TRUE;

	    if (TCB->term_settings.chngWdErase)
	    {
		_EMClearScreenMatrix (TCB);
		_EMUpdatePosAbsolute (TCB, 0, 0);
	    }		  

	    /* Set the new column width. */
	    TCB->col_width = 80;
	    TCB->scr_x2 = TCB->wx2 = TCB->wx1 +
				TCB->col_width * TCB->char_width[0] - 1;

	    /* Check if the current position is past	*/
	    /* the end of the shorter line.		*/
	    if (TCB->current_col >= TCB->col_width)
	    {
		TCB->current_col = TCB->col_width - 1;
		_EMUpdatePosAbsolute (TCB, TCB->current_line, TCB->col_width);
	    }
	}	
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMReverseScreenColors				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMReverseScreenColors (TCB)				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function inverts the screen display.			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMReverseScreenColors (TCB)

	EM_TCB	*TCB;
{
	short	swap_color;		/* used to swap screen colors */

	swap_color = TCB->foreground_color;
	TCB->foreground_color = TCB->background_color;
	TCB->background_color = swap_color;
}
