#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"


void	_EMResetTerminal ();
void	_EMSaveCursor ();
void	_EMRestoreCursor ();
void	_EMExecControlChar ();
void	_EMDAReport ();
void	_EMUpdateKeyboardMode ();
int	_EMChangeLineAttr ();
int	_EMDesignateG0Font ();
int	_EMDesignateG1Font ();
int	_EMBracket ();
int	_EMBlank ();
int	_EMDeviceControl ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEscLevelOne					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMEscLevelOne (TCB, next_char)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  next_char;    -- second byte of an escape sequence    */
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes the first level of escape sequence	*/
/*	  processing.  If the escape sequence is a two-byte sequence,	*/
/*	  is it executed.  Otherwise, the "esc_func" pointer of the	*/
/*	  currently active TCB is set to point to the appopriate	*/
/*	  second level escape sequence processing function.		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMEscLevelOne (TCB, next_char)

EM_TCB	*TCB;
char	next_char;
{
	switch (next_char)
	{
	    case '#':
		TCB->esc_func = _EMChangeLineAttr; 
		break;

	    case ')':
		TCB->esc_func = _EMDesignateG1Font;
		break;

	    case '(':
		TCB->esc_func = _EMDesignateG0Font;
		break;

	    case '[':
		TCB->esc_func = _EMBracket;
		break;

	    case ' ':
		TCB->esc_func = _EMBlank;
		break;

	    case 'P':
		TCB->esc_func = _EMDeviceControl;
		break;

	    case '\\':
		/* If in ReGIS mode, exit ReGIS mode */
		TCB->ReGIS_mode = FALSE;
		TCB->within_esc_seq = FALSE;
		break;

	    case 'c':
		/* Perform a hard terminal reset. */
		_EMResetTerminal (TCB);
		TCB->within_esc_seq = FALSE;
		break;

	    case '7':
		/* Save selected terminal attributes. */
		_EMSaveCursor (TCB);
		TCB->within_esc_seq = FALSE;
		break;

	    case '8':
		/* Restore saved terminal attributes. */
		_EMRestoreCursor (TCB);
		TCB->within_esc_seq = FALSE;
		break;

	    case '=':
		/* Select application keypad mode. */
		TCB->term_settings.numericKeypad = FALSE;
		TCB->within_esc_seq = FALSE;
		break;

	    case '>':
		/* Select numeric keypad mode. */
		TCB->term_settings.numericKeypad = TRUE;
		TCB->within_esc_seq = FALSE;
		break;

	    case 'D':
		/* IND (index) character:  move the cursor down one line. */
		_EMUpdatePosition (TCB, TCB->current_line + 1,
				   TCB->current_col);
		TCB->within_esc_seq = FALSE;
		break;

	    case 'H':
		/* HTS (horizontal tab set) character:  set a tab stop. */
		TCB->term_settings.tabMap[TCB->current_col] = TRUE;
		TCB->within_esc_seq = FALSE;
		break;

	    case 'M':
		/* RI (reverse index) character:  move the cursor up a line. */
		_EMUpdatePosition (TCB, TCB->current_line - 1,
				   TCB->current_col);
		TCB->within_esc_seq = FALSE;
		break;

	    case 'Z':
		/* Return a device attributes (DA) report. */
		_EMDAReport (TCB);
		break;

	    case 'E':
		/* NEL (newline) character:  perform a CR-LF. */
		_EMUpdatePosition (TCB, TCB->current_line + 1, 0);
		TCB->within_esc_seq = FALSE;
		break;

	    default:
		/* If the character is a C0 control char, execute it.	*/
		/* Otherwise, discard the entire sequence.		*/
		if ((next_char > 0x00) && (next_char <= 0x1F))
		    _EMExecControlChar (TCB, next_char);
		else
		    TCB->within_esc_seq = FALSE;
	}

	/* Return to caller. */
	return(EM_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMResetTerminal				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMResetTerminal (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	 This function performs a terminal reset.  That is, it:		*/
/*									*/
/*	      1.  sets all terminal settings to their original,		*/
/*		  states,						*/
/*	      2.  clears the screen,					*/
/*	      3.  moves the cursor to the upper left hand corner	*/
/*	   	  of the screen,					*/
/*	      4.  sets the active display attributes to "normal,"	*/
/*	      5.  turns off insert mode (replacement mode on), and	*/
/*	      6.  selects default character sets.			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMResetTerminal (TCB)

EM_TCB	*TCB;
{
	int	screen_index;	/* index into the screen matrix		*/


	/* Set all terminal settings to their original states. */
	_EMInitTermSettings (&TCB->term_settings,
			     TCB->term_settings.bufScreens);

	/* Clear the screen and set display attributes to normal. */
	TCB->foreground_color = _EMGetColorIndex (&TCB->state_table, FOREGROUND)
		+ VLT_OFFSET +
		_EMFixedVLTOffset[_EMGetScreenNumber (&TCB->state_table)];
	TCB->background_color = _EMGetColorIndex (&TCB->state_table, BACKGROUND)
		+ VLT_OFFSET +
		_EMFixedVLTOffset[_EMGetScreenNumber (&TCB->state_table)];
	_EMClearScreenMatrix (TCB);
	_EMInitDisplayAttr (&TCB->active_attributes, TCB->foreground_color, 
			    TCB->background_color);

	for (screen_index = 0; screen_index < TCB->displayed_rows;
	     screen_index++)
	{
	    TCB->screen[screen_index].font_table = NORMAL_OFFSET;
	    TCB->screen[screen_index].all_chars_norm = TRUE;
	}

	/* Turn off insert mode. */
	TCB->insert_mode = FALSE;

	/* Select default character sets. */
	TCB->character_set = 0;
	TCB->g0_font = 0;
	TCB->g1_font = 0;
	TCB->font_table = TCB->font_table_80;

	/* Set the scrolling region to be the entire screen. */
	_EMUpdateScrollVars (TCB, 0, TCB->displayed_rows - 1);

	/* Darken all keyboard LED's. */
	Keybdled (0, 0x3F);

	/* Unlock the keyboard */
	TCB->keyboardState = TRUE;

	/* Move the cursor to "home." */
	_EMUpdatePosAbsolute (TCB, 0, 0);

	/* redisplay everything */
	_EMSet80Columns(TCB);
	_EMClearScreen (TCB);
	_EMDisplayScreen (TCB, 0, TCB->displayed_rows, 0, TCB->col_width, TRUE);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSaveCursor					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSaveCursor (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;	 -- pointer to active TCB			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function saves the cursor position, active attributes,	*/
/*	  character set shift, autowrap state, origin mode state, and	*/
/*	  selective erase state.  It should be called upon receipt of	*/
/*	  an ESC 7 sequence.						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSaveCursor (TCB)

EM_TCB	*TCB;
{
	/* Save the current position. */
	TCB->save_line = TCB->current_line;
	TCB->save_col = TCB->current_col;

	/* Save the active display and erase attributes. */
	TCB->save_attributes.normal = TCB->active_attributes.normal;
	TCB->save_attributes.underline = TCB->active_attributes.underline;
	TCB->save_attributes.reverse = TCB->active_attributes.reverse;
	TCB->save_attributes.bold = TCB->active_attributes.bold;
	TCB->save_attributes.blinking = TCB->active_attributes.blinking;
	TCB->save_attributes.graphics = TCB->active_attributes.graphics;
	TCB->save_attributes.erasable = TCB->active_attributes.erasable;
	TCB->save_attributes.color = TCB->active_attributes.color;
	TCB->save_attributes.text_color = TCB->active_attributes.text_color;
	TCB->save_attributes.cell_color = TCB->active_attributes.cell_color;

	/* Save the character set and shift states. */
	TCB->save_g0_font = TCB->g0_font;
	TCB->save_g1_font = TCB->g1_font;
	TCB->save_char_set = TCB->character_set;

	/* Save the autowrap and origin mode states. */
	TCB->save_term_settings.autoWrap = TCB->term_settings.autoWrap;
	TCB->save_term_settings.cursorOrigin =
					TCB->term_settings.cursorOrigin;
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMRestoreCursor				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMRestoreCursor (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function restores the values saved by "_EMSaveCursor."	*/
/*	  It should be called upon receipt of an ESC 8 sequence.	*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMRestoreCursor (TCB)

EM_TCB	*TCB;
{
	/* Restore the current position. */
	TCB->current_line = TCB->save_line;
	TCB->current_col = TCB->save_col;
	_EMUpdatePosAbsolute (TCB, TCB->current_line, TCB->current_col);

	/* Restore the active display and erase attributes. */
	TCB->active_attributes.normal = TCB->save_attributes.normal;
	TCB->active_attributes.underline = TCB->save_attributes.underline;
	TCB->active_attributes.reverse = TCB->save_attributes.reverse;
	TCB->active_attributes.bold = TCB->save_attributes.bold;
	TCB->active_attributes.blinking = TCB->save_attributes.blinking;
	TCB->active_attributes.graphics = TCB->save_attributes.graphics;
	TCB->active_attributes.erasable = TCB->save_attributes.erasable;
	TCB->active_attributes.color = TCB->save_attributes.color;
	TCB->active_attributes.text_color = TCB->save_attributes.text_color;
	TCB->active_attributes.cell_color = TCB->save_attributes.cell_color;

	/* Restore the character set and shift states. */
	TCB->g0_font = TCB->save_g0_font;
	TCB->g1_font = TCB->save_g1_font;
	TCB->character_set = TCB->save_char_set;

	if (TCB->character_set)
	    _EMSetFont (TCB, TCB->g1_font);
	else    
	    _EMSetFont (TCB, TCB->g0_font);

	/* Restore the autowrap and origin mode states. */
	TCB->term_settings.autoWrap = TCB->save_term_settings.autoWrap;
	TCB->term_settings.cursorOrigin = 
					TCB->save_term_settings.cursorOrigin;
}	




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDesignateG0Font				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMDesignateG0Font (TCB, character)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- next character in the escape 	*/
/*				     sequence				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>(0" and "<ESC>(B" sequences.	*/
/*	  The former designates the G0 font as the special graphics	*/
/*	  font, while the latter designates the G0 font as the		*/
/*	  "normal" ASCII text font.					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMDesignateG0Font (TCB, character)

EM_TCB	*TCB;
char	character;
{
	switch (character)
	{
	    case '0':
		TCB->g0_font = 1;	/* G0 font is graphics	*/
		break;

	    case 'B':
		TCB->g0_font = 0;	/* G0 font is text	*/
		break;
	}

	/* If the G0 font is the currently active font, the change	*/
	/* is immediately apparent.					*/
	if (! TCB->character_set)
	    _EMSetFont (TCB, TCB->g0_font);

	/* Terminate the escape sequence. */
	TCB->within_esc_seq = FALSE;

	/* Return to caller. */
	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDesignateG1Font				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMDesignateG1Font (TCB, character)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- next character in the escape 	*/
/*				     sequence				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>)0" and "<ESC>)B" sequences.	*/
/*	  The former designates the G1 font as the special graphics	*/
/*	  font, while the latter designates the G1 font as the		*/
/*	  "normal" ASCII text font.					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMDesignateG1Font (TCB, character)

EM_TCB	*TCB;
char	character;
{
	switch (character)
	{
	    case '0':
		TCB->g1_font = 1;	/* G1 font is graphics	*/
		break;

	    case 'B':
		TCB->g1_font = 0;	/* G1 font is text	*/
		break;
	}

	/* If the G1 font is the currently active font, the change	*/
	/* is immediately apparent.					*/
	if (TCB->character_set)
	    _EMSetFont (TCB, TCB->g1_font);

	/* Terminate the escape sequence. */
	TCB->within_esc_seq = FALSE;

	/* Return to caller. */
	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMChangeLineAttr				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMChangeLineAttr (TCB, character)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- next character of an <ESC># sequence */
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>#n" sequences.  These sequences */
/*	  change the text size of an entire line of text.  The action   */
/*	  performed for each permissible value of "n" is given below:	*/
/*									*/
/*	       n = 	Action						*/
/*	       ---      ------						*/
/*	        3	changes the text to the top half of 		*/
/*			double-high, double-wide characters		*/
/*									*/
/*		4	changes the text to the bottom half of		*/
/*			double-high, double-wide characters		*/ 
/*									*/
/*	        5	changes the text to normal characters		*/
/*									*/
/*		6	changes the text to single-high, double-wide	*/
/*		        characters					*/
/*									*/
/*	 	:	changes the text to the top half of		*/
/*			double-high, single-wide characters		*/
/*									*/
/*		;	changes the text to the bottom half of 		*/
/*			double-high, single-wide characters		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMChangeLineAttr (TCB, character)

EM_TCB	*TCB;
char	character;
{
	int	status;		/* status returned by "_EMLoadFont"	*/
	int	DW_col_width;	/* number of double-wide characters	*/
				/*  which can fit on a  line		*/
	int	new_type_offset; /* row's font-type offset		*/
	int	new_length;	/* line length with new font		*/
	int	valid_parameter; /* F => valid parameter received	*/
				 /* T => no valid parameter received	*/

	DW_col_width = TCB->col_width / 2;

	valid_parameter = TRUE;

	switch (character)
	{
	    case '3':
		new_type_offset = DHDWTOP_OFFSET;
		new_length = DW_col_width;
		break;

	    case '4':
		new_type_offset = DHDWBOT_OFFSET;
		new_length = DW_col_width;
		break;

	    case '5':
		new_type_offset = NORMAL_OFFSET;
		new_length = TCB->col_width;
		break;

	    case '6':
		new_type_offset = SHDW_OFFSET;
		new_length = DW_col_width;
		break;

	    case ':':
		new_type_offset = DHSWTOP_OFFSET;
		new_length = TCB->col_width;
		break;

	    case ';':
		new_type_offset = DHSWBOT_OFFSET;
		new_length = TCB->col_width;
		break;

	    default:
		valid_parameter = FALSE;
	}

	if (valid_parameter)
	    _EMLoadFont (TCB,
			 TCB->current_row->char_attr[TCB->current_col], 
			 new_type_offset, &status);
	else
	    status = 1;

	if (! status)
	{
	    TCB->current_row->font_table = new_type_offset;

	    if (new_length == DW_col_width)
		_EMFillScreen (TCB, TCB->current_line, DW_col_width, 
			       TCB->current_line, TCB->col_width - 1, 
			       SPACE, FALSE);

	    _EMDisplayScreen (TCB, TCB->current_line, 1, 0, new_length, FALSE);

	    if (TCB->current_col > (new_length - 1))
		_EMUpdatePosition (TCB, TCB->current_line, new_length - 1);
	}

	/* Terminate the escape sequence. */
	TCB->within_esc_seq = FALSE;

	/* Return to caller. */
	return (EM_NO_ERROR);
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMBlank					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMBlank (TCB, character)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- next character of an "<ESC> ...."	*/
/*				     sequence				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes escape sequences whose second		*/
/*	  character is " "  This sequence changes terminal mode 	*/
/*	  to automatically accepts 7_bit forms of c1 controls.		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  Nan Frizzell					*/
/*									*/
/************************************************************************/

int _EMBlank (TCB, character)

EM_TCB	*TCB;
char	character;
{
	switch (character)
	{
	    case 'F':
		TCB->translateC1 = TRUE;
		break;

	    case 'G':
		TCB->translateC1 = FALSE;
		break;
	}
	TCB->within_esc_seq = FALSE;
	return (EM_NO_ERROR);
}
