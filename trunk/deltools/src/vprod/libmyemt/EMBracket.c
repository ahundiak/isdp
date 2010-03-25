#include <ctype.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


void	_EMCursorPosition ();
void	_EMChangeCursor ();
void	_EMSetDisplayAttr ();
void	_EMClearTabStop ();
void	_EMLightLED ();
void	_EMChangeTerminalModes ();
void	_EMChangeScrollRegion ();
void	_EMInsertSpaces ();
void	_EMDeleteCharacters ();
void	_EMInsertBlankLines ();
void	_EMDeleteLines ();
void	_EMEraseLineRegion ();
void	_EMEraseScreenRegion ();
void	_EMChangeEraseChar ();
void	_EMEraseCharacters ();
void	_EMChangePrinterMode ();
void	_EMDAReport ();	
void	_EMDSRReport ();
void	_EMExecEscSequence ();
void	_EMExecControlChar();
void	_EMUpdateScrollVars ();
void	_EMResetTerminal ();
void	_EMPutEnv ();
int	_EMQuote ();
int	_EMSoftTerminalReset ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMBracket					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMBracket (TCB, character)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- next character of an "<ESC>[..."	*/
/*				     sequence				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes escape sequences whose second		*/
/*	  chracter is "[."  These sequences change terminal modes,	*/
/*	  move the cursor, select character attributes (graphics	*/
/*	  rendition), erase portions of the screen, request device	*/
/*	  reports, change the scroll region, and also cause other	*/
/*	  actions to be performed.					*/
/*									*/
/*	  If the received character represents a digit, the number	*/
/*	  in the current position of the escape sequence buffer is	*/
/*	  multiplied by ten, and the value of the digit is added.	*/
/*									*/
/*	  If the received character is a semicolon, which acts as	*/
/*	  a parameter separator, the pointer into the escape sequence	*/
/*	  buffer is incremented and the new position is set to zero.	*/
/*	  Question marks (?) and greater-than signs (>) serve as	*/
/*	  parameters and are also stored in the buffer and cause 	*/
/*	  the buffer pointer to be incremented.				*/
/*									*/
/*	  If the received character is a double _EMQuote (") or an	*/
/*	  exclamation mark (!), the escape function of the current	*/
/*	  TCB is changed to point to a third-level escape processing	*/
/*	  function.							*/
/*									*/
/*	  If the received character is an alphabetic character,		*/
/*	  which acts as an escape sequence terminator, the sequence	*/
/*	  is executed, with its parameters having been previously	*/
/*	  stored in the escape sequence buffer.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMBracket (TCB, character)

EM_TCB	*TCB;
char	character;
{
	int	digit;		/* digit represented by the character	*/


	if (isdigit (character))
	{
	    digit = character - '0';
	    *(TCB->esc_buff_ptr) = (*(TCB->esc_buff_ptr) * 10) + digit;
	}
	else
	{
	    if ((isalpha (character)) || (character == '@'))
	    {
		TCB->last_param = TCB->esc_buff_ptr;
		TCB->esc_buff_ptr = TCB->esc_seq_buffer;
		_EMExecEscSequence (TCB, character);
		TCB->within_esc_seq = FALSE;
	    }	  
	    else
	    {
		switch (character)
		{
		    case ';':
			if (TCB->esc_buff_ptr < &TCB->esc_seq_buffer[30])
			    TCB->esc_buff_ptr++;
			*(TCB->esc_buff_ptr) = 0;
			break;

		    case '?':
		    case '>':
			*(TCB->esc_buff_ptr) = character;
			if (TCB->esc_buff_ptr < &TCB->esc_seq_buffer[30])
			    TCB->esc_buff_ptr++;
			*(TCB->esc_buff_ptr) = 0;
			break;

		    case '"':
			TCB->esc_func = _EMQuote;
			break;

		    case '!':
			TCB->esc_func = _EMSoftTerminalReset;
			break;

		    default:
			/* Execute the character if it is a C0 */
			/* control character.		       */
			if ((character > 0x00) && (character <= 0x1F))
			    _EMExecControlChar (TCB, character);
		}
	    }
	}		  

	/* Return to caller. */
	return (EM_NO_ERROR);
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMExecEscSequence				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMExecEscSequence (TCB, terminator)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  terminator;	-- terminating character of sequence    */
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes an escape sequence.  The parameters	*/
/*	  of the sequence are expected to be in the escape sequence	*/
/*	  buffer.							*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMExecEscSequence (TCB, terminator)

EM_TCB	*TCB;
char	terminator;
{
/*--------------------------------------------------------------------*/
/*
	int	i;
	int	n;

	n = TCB->last_param - TCB->esc_seq_buffer;

	printf ("<ESC>[");

	for (i = 0; i < n; i++)
	    printf ("%d;", TCB->esc_seq_buffer[i]);

	printf ("%d%c\n", TCB->esc_seq_buffer[n], terminator);
*/
/*--------------------------------------------------------------------*/

	switch (terminator)
	{
	    case 'A':
	    case 'B':
	    case 'C':
	    case 'D':
	    case 'f':
	    case 'H':
		/* Change the position of the cursor. */
		_EMCursorPosition (TCB, terminator);
		break;

	    case 'v':
		/* Change the appearance of the cursor. */
		_EMChangeCursor (TCB);
		break;

	    case 'm':
		/* Set display attributes. */
		_EMSetDisplayAttr (TCB);
		break;

	    case 'g':
		/* Clear a specific tab stop or all tab stops. */
		_EMClearTabStop (TCB);
		break;

	    case 'q':
		/* Turn on/off an LED. */
		_EMLightLED (TCB);
		break;

	    case 'h': 
	    case 'l':
		/* Change terminal modes. */
		_EMChangeTerminalModes (TCB, terminator); 
		break;

	    case 'r':
		/* Change the scroll region. */
		_EMChangeScrollRegion (TCB);
		break;

	    case '@':
		/* Insert spaces at the cursor position. */
		_EMInsertSpaces (TCB);
		break;

	    case 'P':
		/* Delete characters, starting at the cursor position. */
		_EMDeleteCharacters (TCB);
		break;

	    case 'L':
		/* Insert blank lines at the current line. */
		_EMInsertBlankLines (TCB);
		break;

	    case 'M':
		/* Delete lines, starting at the current line. */
		_EMDeleteLines (TCB);
		break;

	    case 'J':
		/* Erase a portion of the screen. */
		_EMEraseScreenRegion (TCB);
		break;

	    case 'K':
		/* Erase a portion of the current line. */
		_EMEraseLineRegion (TCB);
		break;

	    case 's':
		/* Change the erase character. */
		_EMChangeEraseChar (TCB);
		break;

	    case 'X':
		/* Erase a given number of characters to the */
		/* right of the cursor.			   */
		_EMEraseCharacters (TCB);
		break;

	    case 'i':
		/* Change the printer mode or print a portion */
		/* of the screen matrix.			    */
		_EMChangePrinterMode (TCB);
		break;

	    case 'c':
		/* Return a device attributes (DA) report. */
		_EMDAReport (TCB);
		break;

	    case 'n':
		/* Return a device status report (DSR) report. */
		_EMDSRReport (TCB);
		break;

	    case 'E':
		/* NEL (newline) character:  perform a CR-LF. */
		_EMUpdatePosition (TCB, TCB->current_line + 1, 0);
		TCB->within_esc_seq = FALSE;
		break;
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMCursorPosition				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMCursorPosition (TCB, terminator)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char    terminator;	-- last character of the escape 	*/
/*			  	     sequence				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes the cursor movement escape 		*/
/*	  sequences:							*/
/*									*/
/*	       <ESC>[nA	    -- move cursor up "n" rows			*/
/*	      								*/
/*	       <ESC>[nB	    -- move cursor down "n" rows		*/
/*									*/
/*	       <ESC>[nC	    -- move cursor forward "n" columns		*/
/*									*/
/*	       <ESC>[nD	    -- move cursor backward "n" columns		*/
/*									*/
/*	       <ESC>[r;cH   -- position the cursor at row "r" and	*/
/*	       <ESC>[r;cf      column "c"				*/
/*									*/
/*	  The screen is not scrolled if the cursor is moved off the	*/
/*	  screen or scroll region.  					*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMCursorPosition (TCB, terminator)

EM_TCB	*TCB;
char	terminator;
{
	int	row;				/* current row		*/
	int	col;				/* current column	*/
	unsigned char	parameter;		/* next parameter	*/


	parameter = *(TCB->esc_buff_ptr++);
	row = TCB->current_line;
	col = TCB->current_col;

	switch (terminator)
	{
	    case 'A':
		if (! parameter)
		    parameter = 1;
		_EMUpdatePosRestricted (TCB, row - parameter, col);
		break;

	    case 'B':
		if (! parameter)
		    parameter = 1;
		_EMUpdatePosRestricted (TCB, row + parameter, col);
		break;

	    case 'C':
		if (! parameter)
		    parameter = 1;
		_EMUpdatePosRestricted (TCB, row, col + parameter);
		break;

	    case 'D':
		if (! parameter)
		    parameter = 1;
		_EMUpdatePosRestricted (TCB, row, col - parameter);
		break;

	    case 'f':
	    case 'H':
		if (TCB->term_settings.cursorOrigin)
		{
		    /* Place cursor relative to scroll region. */
		    if (parameter)
			row = TCB->top_scroll + parameter - 1;
		    else
			row = TCB->top_scroll;

		    parameter = *(TCB->esc_buff_ptr);

		    if (parameter)
			col = parameter - 1;
		    else
			col = 0;

		    _EMUpdatePosRestricted (TCB, row, col);
		}
		else
		{
		    /* Place cursor relative to upper left corner. */
		    if (parameter)
			row = parameter - 1;
		    else
			row = 0;

		    parameter = *(TCB->esc_buff_ptr);

		    if (parameter)
			col = parameter - 1;
		    else
			col = 0;

		    _EMUpdatePosAbsolute (TCB, row, col); 
		}
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMChangeCursor					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMChangeCursor (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[nv" sequences.  The actions	*/
/*	  performed for permissible values of "n" are given below:	*/
/*									*/
/*	       n = 	Action						*/
/*	       ---      ------						*/
/*	  	0	makes cursor visible				*/
/*	        1	makes cursor invisible				*/
/*		2	makes cursor an underline cursor		*/
/*		3	makes cursor a block cursor			*/
/*									*/
/*	  Omitting "n" has the same effect as having "n" equal zero.	*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMChangeCursor (TCB)

EM_TCB	*TCB;
{
	unsigned char	*parameter_ptr;	/* pointer into the escape	*/
					/*   sequence buffer to the 	*/
					/*   next paramater		*/

	parameter_ptr = TCB->esc_seq_buffer;

	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 0:
		    TCB->term_settings.cursorVisible = TRUE;
		    break;

		case 1:
		    TCB->term_settings.cursorVisible = FALSE;
		    break;

		case 2:
		    TCB->term_settings.cursorBlock = FALSE;
		    break;

		case 3:
		    TCB->term_settings.cursorBlock = TRUE;
		    break;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}
}	




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetDisplayAttr				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetDisplayAttr (TCB)					*/
/*	  								*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[n;n; ... nm" sequences.	*/
/*	  These sequences change the display attributes of any		*/
/*	  subsequent characters.					*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetDisplayAttr (TCB)

EM_TCB	*TCB;
{
	unsigned char	*parameter_ptr;	/* pointer into the escape	*/
					/*   sequence buffer to the 	*/
					/*   next paramater		*/

	parameter_ptr = TCB->esc_seq_buffer;

	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 0:
		    /* Turn off all attributes. */
		    TCB->active_attributes.underline = FALSE;
		    TCB->active_attributes.reverse = FALSE;
		    TCB->active_attributes.bold = FALSE;
		    TCB->active_attributes.color = FALSE;
		    TCB->active_attributes.blinking = FALSE;
		    break;

		case 1:
		    /* Display bold characters. */
		    TCB->active_attributes.bold = TRUE;
		    break;

		case 4:
		    /* Display underlined characters. */
		    TCB->active_attributes.underline = TRUE;
		    break;

		case 5:
		    /* Display blinking characters. */
		    TCB->active_attributes.blinking = TRUE;
		    break;

		case 7:
		    /* Display reversed characters. */
		    TCB->active_attributes.reverse = TRUE;
		    break;

		case 22:
		    /* Turn bold attribute off. */
		    TCB->active_attributes.bold = FALSE;
		    break;

		case 24:
		    /* Turn underline attribute off. */
		    TCB->active_attributes.underline = FALSE;
		    break;

		case 25:
		    /* Turn blinking attribute off. */
		    TCB->active_attributes.blinking = FALSE;
		    break;

		case 27:
		    /* Turn reverse attribute off. */
		    TCB->active_attributes.reverse = FALSE;
		    break;

		case 30:
		case 31:
		case 32:
		case 33:
		case 34:
		case 35:
		case 36:
		case 37:
		    /* Change the active text color. */
		    if (_EMGetColorMode (&TCB->state_table) != BILEVEL)
		    {
			TCB->active_attributes.color = TRUE;
			TCB->active_attributes.text_color = (short) 
				(*parameter_ptr - 30 + RGB_VLT_OFFSET +
				_EMFixedVLTOffset[_EMGetScreenNumber
							(&TCB->state_table)]);
		    }
		    break;

		case 40:
		case 41:
		case 42:
		case 43:
		case 44:
		case 45:
		case 46:
		case 47:
		    /* Change the active cell background color. */
		    if (_EMGetColorMode (&TCB->state_table) != BILEVEL)
		    {
			TCB->active_attributes.color = TRUE;
			TCB->active_attributes.cell_color = (short) 
				(*parameter_ptr - 40 + RGB_VLT_OFFSET +
				_EMFixedVLTOffset[_EMGetScreenNumber
							(&TCB->state_table)]);
		    }
		    break;	 
	    }

	    /* Determine whether or not all attributes have been	*/
	    /* turned off.						*/
	    if ((! TCB->active_attributes.underline) &&
		(! TCB->active_attributes.bold) &&
		(! TCB->active_attributes.reverse) &&
		(! TCB->active_attributes.graphics) &&
		(! TCB->active_attributes.blinking) &&
		(! TCB->active_attributes.color))
		TCB->active_attributes.normal = TRUE;
	    else
		TCB->active_attributes.normal = FALSE;

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMClearTabStop					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMClearTabStop (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[ng" sequences.  If "n" is	*/
/*	  omitted or zero, the tab stop at the current position (if	*/
/*	  one exists) is cleared.  If "n" is 3, all tab stops are	*/
/*	  cleared.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMClearTabStop (TCB)

EM_TCB	*TCB;
{
	unsigned char	parameter;	/* escape sequence parameter	*/
	int	i;

	parameter = TCB->esc_seq_buffer[0];

	switch (parameter)
	{
	    case 0:
		/* Clear the tab stop at the current position. */
		TCB->term_settings.tabMap[TCB->current_col] = FALSE;
		break;

	    case 3:
		/* Clear all tab stops. */
		for (i = 0; i < VTCOL; i++)
		    TCB->term_settings.tabMap[i] = FALSE;
		break;
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMLightLED					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMLightLED (TCB)					*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[n;n...;nq" sequences.  If	*/
/*	  "n" is zero, all LED's are turned off. If "n" is between	*/
/*	  1 and 4 (inclusive), then the nth LED on the keyboard is	*/
/*	  turned on.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMLightLED (TCB)

EM_TCB	*TCB;
{	
	unsigned char	*parameter_ptr;	/* pointer into the escape	*/
					/*   sequence buffer to the 	*/
					/*   next paramater		*/
	int	LED_state;		/* new LED state		*/
	int	LED_enable;		/* enable mask			*/


	parameter_ptr = TCB->esc_seq_buffer;

	LED_state = 0;
	LED_enable = 1;

	while (parameter_ptr <= TCB->last_param)
	{
	    switch (*parameter_ptr)
	    {
		case 0:
		    /* Turn off all LED's. */
		    LED_state = 0;
		    break;

		case 1:
		    /* Turn on "L1." (bit 2 on) */
		    LED_state |= 4;
		    break;

		case 2:
		    /* Turn on "L2." (bit 3 on) */
		    LED_state |= 8;
		    break;

		case 3:
		    /* Turn on "L3." (bit 4 on) */
		    LED_state |= 16;
		    break;

		case 4:
		    /* Turn on "L4." (bit 5 on) */
		    LED_state |= 32;
		    break;

		default:
		    LED_enable = 0;
	    }

	    /* Increment the parameter pointer. */
	    parameter_ptr++;
	}

	/* If all parameters were valid, call the LED routine. */
	if (LED_enable)
	{
	    if (LED_state == 0)
		LED_enable = 4 | 8 | 16 | 32;
	    else
		LED_enable = LED_state;
	    Keybdled (LED_state, LED_enable);
	}
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMChangeScrollRegion				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMChangeScrollRegion (TCB)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes the "<ESC>[n;mr" sequence, which	*/
/*	  sets the scroll region to be from row "n" to row "m."		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMChangeScrollRegion (TCB)

EM_TCB	*TCB;
{
	int	top_row;
	int	bottom_row;


	top_row = (int) (TCB->esc_seq_buffer[0] - 1);
	bottom_row = (int) (TCB->esc_seq_buffer[1] - 1);

	/* If the top row specification was omitted, the top row	*/
	/* defaults to row 0.						*/
	if (top_row < 0)
	    top_row = 0;

	/* If the bottom row specification was omitted, the bottom row	*/
	/* defaults to the last displayable row.			*/
	if (bottom_row < 0)
	    bottom_row = TCB->displayed_rows - 1;

	/* Ignore the command if the specified region is smaller than	*/
	/* two lines or if the bottom row is off the screen.		*/
	if ((top_row < bottom_row) && (bottom_row < TCB->displayed_rows))
	{
	    _EMUpdateScrollVars (TCB, top_row, bottom_row);

	    /* Move the cursor to the origin. */
	    if (TCB->term_settings.cursorOrigin)
		_EMUpdatePosAbsolute (TCB, TCB->top_scroll, 0);
	    else
		_EMUpdatePosAbsolute (TCB, 0, 0);
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMUpdateScrollVars				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMUpdateScrollVars (TCB, top_row, bottom_row)		*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to the active TCB		*/
/*	  int	  top_row;	-- index into the "row_order" array	*/
/*				     of the top row of the scrolling	*/
/*				     region				*/
/*	  int	  bottom_row;	-- index of the bottom scroll row	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function recalculates the scrolling coordinates and 	*/
/*	  sets the scrolling region to be from "top_row" to 		*/
/*	  "bottom_row."							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMUpdateScrollVars (TCB, top_row, bottom_row)

EM_TCB	*TCB;
int	top_row;
int	bottom_row;
{
	/* Update the scrolling coordinates */
	_EMCalcMatrixBounds (TCB, top_row, bottom_row - top_row + 1,
			     0, TCB->col_width,
			     &TCB->scr_x1, &TCB->scr_y1,
			     &TCB->scr_x2, &TCB->scr_y2);

	/* Reset the scrolling region */
	TCB->top_scroll = top_row;
	TCB->bot_scroll = bottom_row;
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMQuote					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMQuote (TCB, character)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- next character in the sequence	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes '<ESC>[n"q' and '<ESC>[n1;n2p".	*/
/*									*/
/*	  Sequences ending with 'q' set the "erasability" of subsequent */
/*	  characters.  If "n" is 0 or 2, subsequent characters are	*/
/*	  erasable; if "n" is 1, subsequent characters are not		*/
/*	  erasable.  The sequence is valid only if VT-200 mode is	*/
/*	  in effect.							*/
/*									*/
/*	  Sequences ending with 'p' change the operating mode of the	*/
/*	  emulation:							*/
/*		n1	n2	mode					*/
/*		--	--	----					*/
/*		61	-	VT-100					*/
/*		62	-	VT-200, 8-bit				*/
/*		62	0,2	VT-200, 8-bit				*/
/*		62	1	VT-200, 7-bit				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero is always returned.					*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMQuote (TCB, character)

EM_TCB	*TCB;
char	character;
{
	unsigned char	parameter;	/* escape sequence parameter	*/
	unsigned char	parameter2;	/* 2nd escape sequence parameter*/


	switch (character)
	{
	    case 'p':
		/* Set emulation mode. */
		parameter = TCB->esc_seq_buffer[0];
		parameter2 = TCB->esc_seq_buffer[1];

		if (parameter == 61)
		{
		    TCB->term_settings.vt200 = FALSE;
		    TCB->term_settings.bit8 = FALSE;
		}
		else if ((parameter == 62) &&
			 ((parameter2 == 0) || (parameter2 == 2)))
		{
		    TCB->term_settings.vt200 = TRUE;
		    TCB->term_settings.bit8 = TRUE;
		}
		else if ((parameter == 62) && (parameter2 == 1))
		{
		    TCB->term_settings.vt200 = TRUE;
		    TCB->term_settings.bit8 = FALSE;
		}
		_EMPutEnv (TCB);	/* set TERM env variable */
		break;


	   case 'q':
		/* Set character erasability. */
		parameter = TCB->esc_seq_buffer[0];

		if ((parameter == 0) || (parameter == 2))
		    TCB->active_attributes.erasable = TRUE;
		else
		    if (parameter == 1)
			TCB->active_attributes.erasable = FALSE;
		break;				
	}

	/* Terminate the escape sequence. */
	TCB->within_esc_seq = FALSE;

	/* Return to caller. */
	return (EM_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSoftTerminalReset				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMSoftTerminalReset (TCB, character)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- next character in the sequence	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes the "<ESC>[!p" sequence, which	*/
/*	  performs a soft terminal reset.  The sequence is ignored	*/
/*	  if VT-200 mode is not in effect.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero is always returned.					*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMSoftTerminalReset (TCB, character)

EM_TCB	*TCB;
char	character;
{
	if ((TCB->term_settings.vt200) && (character == 'p'))
	    _EMResetTerminal (TCB);

	/* Terminate the escape sequence. */
	TCB->within_esc_seq = FALSE;

	/* Return to caller. */
	return (EM_NO_ERROR);
}
