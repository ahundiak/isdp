#include <string.h>
#include <malloc.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMError.h"


void	_EMToLogFile ();
int	_EMEscLevelOne ();	/* escape sequence processor	*/


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMExecControlChar				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMExecControlChar (TCB, character) 			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;	-- control character to execute		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes a control character.  Any unsupported  */
/*	  control characters are ignored.  If an 8-bit character is     */
/*	  received, it is converted to the equivalent 7-bit escape	*/
/*	  sequence, and the second byte of this sequence is sent to	*/
/*	  first-level escape sequence processor.			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMExecControlChar (TCB, character)

EM_TCB	*TCB;
char	character;
{
	int	column;			/* used to search for the next	*/
					/*  tab stop			*/
	int	i;			/* used to clear the escape	*/
					/*  sequence buffer		*/
	int	answ_length;		/* length of answerback message */
	char	*report_ptr;		/* pointer to report buffer	*/

	unsigned char	C1_char;	/* 8-bit control character	*/


	switch (character)
	{
	    case CR:
		if (TCB->term_settings.newLine)
		{
		    _EMToLogFile (TCB, TCB->current_line);
		    _EMUpdatePosition (TCB, TCB->current_line + 1, 0);
		}
		else
		    _EMUpdatePosition (TCB, TCB->current_line, 0);
		break;


	    case LF:
	    case VT:
		/* Print the current line if in auto print mode. */
		if (TCB->term_settings.printerMode == AUTO_MODE)
		    _EMPrintScreen (TCB, TCB->current_line, 1, character);

	   	/* Move to the next line. */
		if (TCB->term_settings.newLine)
		{
		    _EMToLogFile (TCB, TCB->current_line);
		    _EMUpdatePosition (TCB, TCB->current_line + 1, 0);
		}
		else
		{
		    _EMToLogFile (TCB, TCB->current_line);
		    _EMUpdatePosition (TCB, TCB->current_line + 1, 
				       TCB->current_col);     
		}
		break;


	    case TAB:
		/* Find the next tab stop (or the end of the line). */
		column = TCB->current_col + 1;

		while ((! TCB->term_settings.tabMap[column]) && 
		       (column < TCB->col_width))
		{
		    column++;
		}

		/* Move to the tab stop. */
		if (TCB->term_settings.tabMovement)
		{
		    /* The tab writes spaces. */
		    _EMFillScreen (TCB, TCB->current_line, TCB->current_col, 
				   TCB->current_line, column - 1, SPACE, 0);
		    _EMEraseWindowRegion (TCB, TCB->current_line, 1, 
					  TCB->current_col, 
					  column - TCB->current_col);
		}

		_EMUpdatePosAbsolute (TCB, TCB->current_line, column);
		break;


	    case ENQ:
		/* Return the anwerback message. */
		answ_length = strlen (TCB->term_settings.answerback);

		/* Allocate storage for the answerback message. */
		if (TCB->report_buffer)
		    TCB->report_buffer = (char *) realloc (TCB->report_buffer,
					TCB->report_count +  answ_length);
		else
		    TCB->report_buffer = (char *) malloc (answ_length);

		/* Copy the answerback message to the allocated memory. */
		if (TCB->report_buffer)
		{
		    report_ptr = TCB->report_buffer + TCB->report_count;
		    strncpy (report_ptr, TCB->term_settings.answerback, 
			     answ_length);
		    TCB->report_count += answ_length;
		}
		break;


	    case BELL:
		if (TCB->term_settings.warningBell)
		    Keybdbell (0);
		break;


	    case BS:
		_EMUpdatePosAbsolute (TCB, TCB->current_line,
				      TCB->current_col - 1);
		break;


	    case FF:
		/* Print the current line if in auto print mode. */
		if (TCB->term_settings.printerMode == AUTO_MODE)
		    _EMPrintScreen (TCB, TCB->current_line, 1, character);

		if (TCB->term_settings.formFeed)
		{
		    /* Form feed clears the screen and goes to "home." */
		    _EMClearScreenMatrix (TCB);
		    _EMClearScreen (TCB);
		    _EMDisplayScreen (TCB, 0, TCB->displayed_rows,
				      0, TCB->col_width, TRUE);
		    _EMUpdatePosAbsolute (TCB, 0, 0);
		}
		else
		{
		    /* Form feed acts as a line feed. */
		    _EMToLogFile (TCB, TCB->current_line);
		    _EMUpdatePosition (TCB, TCB->current_line + 1, 
				       TCB->current_col);
		}
		break;


	    case SO:
		/* Invoke the G1 font. */
		_EMSetFont (TCB, TCB->g1_font);
		TCB->character_set = 1;
		break;


	    case SI:
		/* Invoke the G0 font. */
		_EMSetFont (TCB, TCB->g0_font);
		TCB->character_set = 0;
		break;


	    case ESC:
		TCB->within_esc_seq = TRUE;
		TCB->esc_func = _EMEscLevelOne;
		TCB->esc_buff_ptr = TCB->esc_seq_buffer;

		/* Clear the escape sequence buffer. */
		for (i = 0; i <= 30; i++)
		    TCB->esc_seq_buffer[i] = 0;
		break;


	   case XOFF:
		TCB->keyboardState = FALSE;
		Keybdled (0x1, 0x1);
		break;


	   case XON:
		TCB->keyboardState = TRUE;
		Keybdled (0x0, 0x1);
		break;


	   default:
		C1_char = (unsigned char) character;

		/* Test for 8-bit control characters. */
	 	if (((C1_char >= 0x84) && (C1_char <= 0x97)) ||
		    ((C1_char >= 0x9B) && (C1_char <= 0x9F)))
		{
		    TCB->within_esc_seq = TRUE;
		    TCB->esc_func = _EMEscLevelOne;
		    TCB->esc_buff_ptr = TCB->esc_seq_buffer;

		    /* Clear the escape sequence buffer. */
		    for (i = 0; i <= 30; i++)
			TCB->esc_seq_buffer[i] = 0;

		    /* Convert the character to a 7-bit character. */
		    C1_char = C1_char - 0x40;

		    /* Send the converted character to the escape  */
		    /* sequence processor.			    */
		    (*TCB->esc_func) (TCB, C1_char);
		}
		break;
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDisplayControlChar				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDisplayControlChar (TCB, character, first_col,	*/
/*				      chars_to_print)			*/
/*									*/
/*	  EM_TCB  *TCB;		    -- pointer to active TCB		*/
/*	  char	  character;	    -- control character to display	*/
/*	  int	  *first_col;	    -- "first_col" and "chars_to_print" */
/*	  int	  *chars_to_print;       are used by			*/
/*					 "_EMInsertCharacter"		*/
/*					 and modified only if a line	*/
/*					 feed is received		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function displays a control character.  7-bit		*/
/*	  characters are displayed as follows:  hex 40 is added to	*/
/*	  the character, and the new character is printed reversed.     */
/*	  8-bit characters are printed similarly, execpt that the	*/
/*	  character is underlined and its high bit stripped off 	*/
/*	  before the addition.						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMDisplayControlChar (TCB, character, first_col, chars_to_print)

EM_TCB	*TCB;
char	character;
int	*first_col;
int	*chars_to_print;
{
	int	save_attr;		/* saves an "active_attributes"	*/
					/*  flag			*/
	int	normal_chars;		/* saves the "normal" attribute	*/
					/*  flag			*/
	int	save_line;		/* current line before the	*/
					/*  character is placed into	*/
					/*  the screen matrix		*/

	/* Ignore NUL and DEL characters. */
	if ((character == NUL) || (character == DEL))
	    return;

	/* Save the number of the current row. */
	save_line = TCB->current_line;

	/* Save the "normal" flag of the active attributes. */
	normal_chars = TCB->active_attributes.normal;
	TCB->active_attributes.normal = FALSE;

	if (character & 0x80)
	{
	    /* 8-bit control character */
	    character &= 0x7F;			/* Strip off high bit. */
	    character += 0x40;

	    /* Save the state of the "underline" attribute and set	*/
	    /* it to true.						*/
	    save_attr = TCB->active_attributes.underline;
	    TCB->active_attributes.underline = TRUE;

	    /* Put the character in the screen matrix.	*/
	    _EMInsertCharacter (TCB, character, first_col, chars_to_print);

	    /* Restore the saved state. */
	    TCB->active_attributes.underline = save_attr;
	}
	else
	{
	    /* 7-bit control character */
	    character += 0x40;

	    /* Save the state of the "reverse" attribute and set	*/
	    /* it to true.						*/
	    save_attr = TCB->active_attributes.reverse;
	    TCB->active_attributes.reverse = TRUE;

	    /* Put the character in the screen matrix.	*/
	    _EMInsertCharacter (TCB, character, first_col, chars_to_print);

	    /* Restore the saved state. */
	    TCB->active_attributes.reverse = save_attr;
	}

	/* Restore the "normal" flag. */
	TCB->active_attributes.normal = normal_chars;

	/* In "display controls" mode, line feeds are displayed as	*/
	/* described above, but they are also interpreted as		*/
	/* newlines (unless the cursor has already been moved to	*/
	/* the next row because of autowrap.				*/
	if ((character - 0x40 == LF) && (save_line == TCB->current_line))
	{
	    _EMDisplayScreen (TCB, TCB->current_line, 1, *first_col, 
			      *chars_to_print, FALSE);
	    _EMUpdatePosition (TCB, TCB->current_line + 1, 0);
	    *first_col = TCB->current_col;
	    *chars_to_print = 0;
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMToLogFile					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMToLogFile (TCB, row)					*/
/*									*/
/*	  EM_TCB  *TCB;		    -- pointer to active TCB		*/
/*	  int row;		    -- row to output to log file	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function outputs the given row (index into the row_order	*/
/*	  array) to the log file if the log file option is chosen.	*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMToLogFile (TCB, row)

EM_TCB	*TCB;
int	row;
{
	int	end_col;	/* used to truncate trailing blanks	*/
	int	the_row;	/* the actual row in the screen matrix	*/

	if (TCB->term_settings.logFlag)
	{
	    if (TCB->log_file == NULL)
		TCB->log_file =
		  (_EMusr_access(TCB->term_settings.logFile))
			? NULL : fopen (TCB->term_settings.logFile, "a");

	    if (TCB->log_file != NULL)
	    {
		the_row = TCB->row_order[row];

		for (end_col = TCB->col_width; end_col > 0; end_col--)
		    if (TCB->screen[the_row].character[end_col - 1] != SPACE)
			break;

		if (end_col)
		{
		    if (fwrite (TCB->screen[the_row].character, 1,
				end_col, TCB->log_file) != end_col)
		    {
			fclose (TCB->log_file);
			TCB->log_file =
			    (_EMusr_access(TCB->term_settings.logFile))
			       ? NULL : fopen (TCB->term_settings.logFile, "a");

			if (TCB->log_file != NULL)
			    fwrite (TCB->screen[the_row].character, 1,
				    end_col, TCB->log_file);
		    }
		}

		fputc ('\n', TCB->log_file);
	    }
	}
}
