#include <string.h>
#include <ctype.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


void	_EMInsertCharacter ();
void	_EMProcReGISSequence ();
void	_EMSetCharacterAttr ();
int	_EMEscLevelOne ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMWrite						*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMWrite (TCBD, in_buffer, in_count, return_buffer,	*/
/*		       return_count)					*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance to write to		*/
/*									*/
/*	  char  *in_buffer;	 -- buffer of data to write/interpret   */
/*									*/
/*	  int	in_count;	 -- number of bytes of input		*/
/*									*/
/*	  char  **return_buffer; -- buffer of data to be written to	*/
/*				    the host (device reports or ENQ)	*/
/*									*/
/*	  int	*return_count;	 -- number of bytes returned		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function accepts a buffer of ASCII characters, control	*/
/*	  characters, and control (escape) sequences.  It displays 	*/
/*	  any printable characters and interprets and executes any	*/
/*	  control characters and sequences.  				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned;  invalid input data is	*/
/*	  simply ignored.						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMWrite (TCBD, in_buffer, in_count, return_buffer, return_count)

int		TCBD;
unsigned char	*in_buffer;
int		in_count;
char		**return_buffer;
int		*return_count;
{
	EM_TCB		*TCB;		/* pointer to active TCB	*/
	unsigned char	*char_ptr;	/* pointer to the current	*/
					/*   character being processed	*/
	unsigned char	the_char;	/* current character		*/
	int		chars_to_print; /* # of printable characters    */
					/*   on the current line	*/
	int		first_col;	/* column index of first char.	*/
					/*   of a string of printable	*/
					/*   characters			*/


	/* Point the the TCB for this terminal instance. */
	TCB = EM_TCB_list[TCBD];


	/* If the terminal is in printer controller mode, send the buffer */
	/* to the printer and return if everything went.	*/
	if (TCB->term_settings.printerMode == PRINTER_CONTROLLER_MODE)
	{
	    _EMDataToPrinter (TCB, &in_buffer, &in_count);

	    if (in_count == 0)
	    {
		*return_count = 0;
		return (EM_NO_ERROR);
	    }
	}


	/* set the clipbox to the correct size */
	_EMSetClipBox (TCB, 0, 0, -1, -1);
	_EMGraphicsNormal (TCB);

	/* Erase the screen and terminal cursors until the buffer has	*/
	/* been processed. */
	hidecursor (TCB->window);
	_EMEraseCursor (TCB); 

	/* Save the current column position. */
	chars_to_print = 0;
	first_col = TCB->current_col;

	/* Scan the input buffer. */
	char_ptr = in_buffer;
	while (in_count--)
	{
	    the_char = *char_ptr;

	    /* Strip off the high bit if in VT-100 mode. */
	    if (! TCB->term_settings.bit8)
		the_char &= 0x7F;

	    /* If the character is a member of an escape sequence, send */
	    /* it to the current escape sequence processor.		  */
	    if ((TCB->within_esc_seq) && (the_char != ESC))
	    {
		if ((the_char == CAN) || (the_char == SUB))
		    TCB->within_esc_seq = FALSE;
		else
		{
		    if (the_char != NUL)
			(*TCB->esc_func) (TCB, the_char);
		}

		if (! TCB->within_esc_seq)
		{
		    /* Reset the "first_col" index. */
		    first_col = TCB->current_col;	
		}
		char_ptr++;

		if (TCB->term_settings.printerMode == PRINTER_CONTROLLER_MODE)
		    _EMDataToPrinter (TCB, &char_ptr, &in_count);
	    }
	    else
	    {
		if (TCB->ReGIS_mode)
		{
		    _EMProcReGISSequence (TCB, the_char, &first_col,
					  &chars_to_print);
		}
		else
		{
		    /* If the character is a printable character, */
		    /* place it in the screen matrix.	      */
		    if (((the_char >= 0x20) && (the_char <= 0x7E)) ||
			((the_char >= 0xA0) && (the_char <= 0xFE)))
		    {
			chars_to_print++;
			_EMInsertCharacter (TCB, the_char, &first_col, 
					    &chars_to_print);
		    }
		    else
		    {
			if (TCB->term_settings.displayControls)
			{
			    chars_to_print++;
			    _EMDisplayControlChar (TCB, the_char, &first_col, 
						   &chars_to_print);
			}
			else
			{
			    if (chars_to_print)
				_EMDisplayScreen (TCB, TCB->current_line,
						  1, first_col, chars_to_print,
						  FALSE);

			     _EMExecControlChar (TCB, the_char);

			     chars_to_print = 0;
			     first_col = TCB->current_col;
			}
		    }
		}
		char_ptr++;
	    }
	}

	/* Update the screen display if there are any characters to print. */
	if (chars_to_print)
	    _EMDisplayScreen (TCB, TCB->current_line, 1, first_col, 
			      chars_to_print, FALSE);

	/* Display the screen and terminal cursors. */
	_EMDrawCursor (TCB);
	showcursor (TCB->window);
	flushbuffer (TCB->window);
	_EMRestoreClipBox (TCB);

	/* Check if a buffer needs to be returned to the caller. */
	if (TCB->report_count)
	{
	    *return_buffer = TCB->report_buffer;
	    *return_count = TCB->report_count;

	    /* Reset report buffer and count for next call. */
	    TCB->report_buffer = NULL;
	    TCB->report_count = 0;
	}
	else
	    *return_count = 0;

	/* Return to caller. */
	return (EM_NO_ERROR);
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInsertCharacter				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMInsertCharacter (TCB, character, first_col, 		*/
/*				   chars_to_print)			*/
/*									*/
/*	  EM_TCB  *TCB		-- TCB of active terminal instance	*/
/*	  char    character	-- character to be placed in the screen */
/*				     matrix				*/
/*	  int	*first_col						*/
/*	  int	*chars_to_print						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function inserts a character into the screen matrix	*/
/*	  at the current position and displays the updated matrix.	*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMInsertCharacter (TCB, character, first_col, chars_to_print)

EM_TCB	*TCB;
char	character;
int	*first_col;
int	*chars_to_print;
{
	unsigned char
		attributes;	/* attribute mask of character to be 	*/
				/*   inserted				*/
	char	*char_source;		/* ptrs to sources and destinations */
	char	*char_dest;		/*   of chars and attribute masks */
	unsigned char	*attr_source;	/*   to be shifted if insert mode */
	unsigned char	*attr_dest;	/*   is in effect		*/
	int	chars_to_shift;	/* number of characters which need to	*/
				/*   be shifted 			*/


	/* If the cursor is at the end of a line and autowrap mode is	*/
	/* in effect, move to the next line.				*/
	if (TCB->current_col == TCB->col_width - 1)
	{
	    if ((TCB->end_of_line) && (TCB->term_settings.autoWrap))
	    {
		if (TCB->term_settings.printerMode == AUTO_MODE)
		    _EMPrintScreen (TCB, TCB->current_line, 1, LF);

		_EMToLogFile (TCB, TCB->current_line);
		_EMUpdatePosition (TCB, TCB->current_line + 1, 0);
		*first_col = TCB->current_col;
		TCB->end_of_line = FALSE;
	    }
	}
	else
	    TCB->end_of_line = FALSE;


	/* Set the attribute mask based on the currently active */
	/* display attribues. 					*/
	_EMSetCharacterAttr (&TCB->active_attributes, &attributes, 
			     TCB->current_row, TCB->current_col);


	if (TCB->insert_mode)
	{
	    /* Shift all characters at or to the right of the current	*/
	    /* column to the right one character position.  The		*/
	    /* right-most character is lost.				*/

	    chars_to_shift = TCB->col_width - TCB->current_col - 1;

	    char_dest = &TCB->current_row->character[TCB->col_width - 1];
	    char_source = char_dest - 1;
	    attr_dest = &TCB->current_row->char_attr[TCB->col_width - 1];
	    attr_source = attr_dest - 1;

	    while (chars_to_shift--)
	    {
		*(char_dest--) = *(char_source--);
		*(attr_dest--) = *(attr_source--);
	    }

	    /* Display the shifted characters. */
	    _EMDisplayScreen (TCB, TCB->current_line, 1, TCB->current_col + 1,
			      TCB->col_width - TCB->current_col - 1, FALSE);
	}


	/* Place the character in the screen matrix. */
	TCB->current_row->character[TCB->current_col] = character;
	TCB->current_row->char_attr[TCB->current_col] = attributes;

	/* Update the current row and column pointers. */
	TCB->current_col++;

	if (TCB->current_col == TCB->col_width)
	{
	    /* The current position is at the end of a line; */
	    /* display the current row on the screen and set */
	    /* the end-of-line marker.  The cursor will be   */
	    /* moved to the next line upon receipt of the    */
	    /* next character.				     */
	    TCB->current_col--;
	    _EMDisplayScreen (TCB, TCB->current_line, 1, *first_col,
			      *chars_to_print, FALSE);
	    *chars_to_print = 0;
	    TCB->end_of_line = TRUE;
	}
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMProcReGISSequence				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMProcReGISSequence (TCB, character, chars_to_print)	*/
/*									*/
/*	  EM_TCB  *TCB;		    -- pointer to active TCB		*/
/*	  char	  character;	    -- next character to process	*/
/*	  int	  *chars_to_print;  -- pointer to the counter for the   */
/*				         number of characters placed    */
/*					 in the screen matrix		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This fucntion places the next character into the ReGIS	*/
/*	  command buffer, incrementing and decrementing the 		*/
/*	  "nest_level" appropriately as parentheses are received	*/
/*	  and sending the buffer to be executed when the "nest_level"   */
/*	  reaches zero.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMProcReGISSequence (TCB, character, first_col, chars_to_print)

EM_TCB	*TCB;
char	character;
int	*first_col;
int	*chars_to_print;
{
	if (character == ESC)
	{
	    TCB->within_esc_seq = TRUE;
	    TCB->esc_func = _EMEscLevelOne;
	}	     
	else
	{
	    *(TCB->ReGIS_buf_ptr++) = character;

	    switch (character)
	    {
		case '(':  /* Increment the nesting level. */
		    TCB->nest_level++;
		    break;

		case ')':  /* Decrement the nesting level. */
		    TCB->nest_level--;

		    if (TCB->nest_level == 0)
		    {
			_EMReGISCommand (&TCB->state_table, 
					 TCB->ReGIS_com_buffer, 
					 TCB->ReGIS_buf_ptr - 1);
			TCB->ReGIS_buf_ptr = TCB->ReGIS_com_buffer;
		    }

		    break;

		case ';':  /* Discard the current command. */
		    TCB->nest_level = 0;
		    TCB->ReGIS_buf_ptr = TCB->ReGIS_com_buffer;
		    break;
	    }

	    /* If the command level is greater than one and the char	*/
	    /* is a printing character, display the character.		*/
	    if ((_EMGetCommandLevel (&TCB->state_table) > 1) &&
		(character >= 0x20) && (character <= 0x7E))
	    {
		(*chars_to_print)++;
		_EMInsertCharacter (TCB, character, first_col, chars_to_print);
	    }
	}	     
}	





/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetCharacterAttr				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetCharacterAttr (active_attributes, 			*/
/*				    attribute_mask, current_row, 	*/
/*				    current_col)			*/
/*									*/
/*	  EMattribute_flags  *active_attributes; -- currently active	*/
/*						      attributes	*/
/*	  unsigned char	     *attribute_mask;    -- return mask		*/
/*	  EMscreen_row	     *current_row;	 -- pointer to current	*/
/*						      row		*/
/*	  int		     current_col;	 -- current column	*/
/*						      index		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the attribute mask of a character based	*/
/*	  upon the currently active attributes.	 If the character has	*/
/*	  any attributes other then "normal," the "all_chars_norm"	*/
/*	  flag for the current row is set to zero.			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetCharacterAttr (active_attributes, attributes, current_row, 
			  current_col)

EMattribute_flags	*active_attributes;
unsigned char		*attributes;
EMscreen_row		*current_row;
int			current_col;
{
	if (active_attributes->normal)
	    *attributes = CHAR_NORMAL;
	else
	{
	    *attributes = 0;

	    if (active_attributes->underline)
		*attributes |= CHAR_UNDERLINE;

	    if (active_attributes->reverse)
		*attributes |= CHAR_REVERSE;

	    if (active_attributes->bold)
		*attributes |= CHAR_BOLD;

	    if (active_attributes->graphics)
		*attributes |= CHAR_GRAPHICS;

	    if (active_attributes->color)
		*attributes |= CHAR_COLOR;

	    if (active_attributes->blinking)
		*attributes |= CHAR_BLINK;

	    current_row->char_color[current_col] =
				(unsigned char) active_attributes->text_color;
	    current_row->cell_color[current_col] =
				(unsigned char) active_attributes->cell_color;

	    current_row->all_chars_norm = FALSE;
	} 

	if (active_attributes->erasable)
	    *attributes |= CHAR_ERASABLE;
}
