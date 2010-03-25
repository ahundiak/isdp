#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"


void	_EMUpdatePosAbsolute ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInsertSpaces					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMInsertSpaces (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processed "<ESC>[n@" sequences, which insert    */
/*	  "n" spaces at the current position.  If "n" is omitted or	*/
/*	  is zero, "n" defaults to one.	 Characters shifted past the	*/
/*	  right side of the screen are lost.				*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMInsertSpaces (TCB)

EM_TCB	*TCB;
{
	int	chars_to_shift;		/* # of chars which need to	*/
					/*  be shifted to the right	*/
	char	*char_source;		/* pointer to character to move	*/
	char	*char_dest;		/* pointer to its new position	*/
	unsigned char	*attr_source;	/* pointer to attribute to move	*/
	unsigned char	*attr_dest;	/* pointer to its new position	*/
	int	i;			/* loop counter			*/
	int	spaces_to_insert;	/* number of spaces to insert	*/


	/* Ignore the command if VT-200 is not in effect. */
	if (TCB->term_settings.vt200)
	{
	    /* Determine the number of spaces to insert. */
	    spaces_to_insert = TCB->esc_seq_buffer[0];

	    if (spaces_to_insert == 0)
		spaces_to_insert = 1;

	    /* Determine the # of chars to be shifted */
	    chars_to_shift = TCB->col_width - TCB->current_col -
			     spaces_to_insert;

	    /* Set the source and destination pointers. */
	    char_dest = &TCB->current_row->character[TCB->col_width - 1];
	    char_source = char_dest - spaces_to_insert;
	    attr_dest = &TCB->current_row->char_attr[TCB->col_width - 1];
	    attr_source = attr_dest - spaces_to_insert;

	    /* Shift the characters. */
	    for (i = 1; i <= chars_to_shift; i++)
	    {
		*(char_dest--) = *(char_source--);
		*(attr_dest--) = *(attr_source--);
	    }	    

	    /* Insert the spaces and display the line. */
	    _EMFillScreen (TCB, TCB->current_line, TCB->current_col,
			   TCB->current_line, 
			   TCB->current_col + spaces_to_insert - 1, SPACE, 0);

	    _EMDisplayScreen (TCB, TCB->current_line, 1, TCB->current_col, 
			      TCB->col_width - TCB->current_col, FALSE);
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDeleteCharacters				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDeleteCharacters (TCB)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processed "<ESC>[nP" sequences, which delete    */
/*	  "n" characters, starting at the current position.  If "n" is  */
/*	  omitted or is zero, "n" defaults to one.  Blanks are shifted  */
/*	  in from the right side of the screen.				*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMDeleteCharacters (TCB)

EM_TCB	*TCB;
{
	int	chars_to_shift;		/* # of chars which need to	*/
					/*  be shifted to the right	*/
	char	*char_source;		/* pointer to character to move	*/
	char	*char_dest;		/* pointer to its new position	*/
	unsigned char	*attr_source;	/* pointer to attribute to move	*/
	unsigned char	*attr_dest;	/* pointer to its new position	*/
	int	i;			/* loop counter			*/
	int	chars_to_delete;	/* number of chars to delete	*/


	/* Ignore the command if VT-200 mode is not in effect. */
	if (TCB->term_settings.vt200)
	{
	    /* Determine the number of spaces to insert. */
	    chars_to_delete = TCB->esc_seq_buffer[0];

	    if (chars_to_delete == 0)
		chars_to_delete = 1;

	    /* Determine the # of characters to be shifted */
	    chars_to_shift = TCB->col_width - TCB->current_col - 
			     chars_to_delete;

	    /* Set the source and destination pointers. */
	    char_dest = &TCB->current_row->character[TCB->current_col];
	    char_source = char_dest + chars_to_delete;
	    attr_dest = &TCB->current_row->char_attr[TCB->current_col];
	    attr_source = attr_dest + chars_to_delete;

	    /* Shift the characters. */
	    for (i = 1; i <= chars_to_shift; i++)
	    {
		*(char_dest++) = *(char_source++);
		*(attr_dest++) = *(attr_source++);
	    }	    

	    /* Add blanks to the right side of the line. */
	    _EMFillScreen (TCB, TCB->current_line, 
			   (TCB->col_width - 1) - chars_to_delete,
			   TCB->current_line, TCB->col_width - 1, SPACE, 0);

	    _EMDisplayScreen (TCB, TCB->current_line, 1, TCB->current_col,
			      TCB->col_width - TCB->current_col, FALSE);
	}
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInsertBlankLines				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMInsertBlankLines (TCB)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes the "<ESC>[nL" sequence, which	*/
/*	  inserts "n" blank lines, starting at the current line.	*/
/*	  If "n" is omitted or is zero, "n" defaults to one. Lines	*/
/*	  are not inserted below the bottom of the scroll region, and   */
/*	  the sequence is ignored if the current position is outside	*/
/*	  the scroll region.						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMInsertBlankLines (TCB)

EM_TCB	*TCB;
{
	int	lines_to_insert;	/* # of lines to be inserted	*/
	int	first_line;		/* first inserted blank line	*/
	int	last_line;		/* last inserted blank line	*/
	int	save_line[VTROW];	/* used to shift lines down	*/
	int	i;			/* loop counter			*/

	EMscreen_row	*row_ptr;	/* pointer to row being deleted	*/


	/* Execute the escape sequence only if the current position is	*/
	/* within the scroll region and VT-200 mode is in effect.	*/
	if ((TCB->in_region) && (TCB->term_settings.vt200))
	{
	    /* Determine how many lines are to be inserted. */
	    lines_to_insert = TCB->esc_seq_buffer[0];
	    if (lines_to_insert == 0)
		lines_to_insert = 1;

	    /* Lines may be inserted only within the scroll region. */
	    if (lines_to_insert > (TCB->bot_scroll - TCB->current_line + 1))
		lines_to_insert = TCB->bot_scroll - TCB->current_line + 1;

	    first_line = TCB->current_line;
	    last_line = first_line + lines_to_insert - 1;

	    if (last_line >= TCB->bot_scroll)
	    {
		/* Clear the lines  from the current line to the end of	*/
		/* the scroll region.  					*/
		for (i = first_line; i <= last_line; i++)
		{
		    row_ptr = &TCB->screen[TCB->row_order[i]];
		    row_ptr->all_chars_norm = 1;
		    row_ptr->font_table = NORMAL_OFFSET;
		}

		_EMFillScreen (TCB, first_line, 0, last_line, 
			       TCB->col_width - 1, SPACE, 0);

		/* Reflect the blank lines on the screen. */
		_EMDisplayScreen (TCB, first_line, lines_to_insert, 0, 
				  TCB->col_width, FALSE);
	    }
	    else
	    {
		/* Blank-out the lines which will be inserted and set	*/
		/* their attributes to normal.				*/
		for (i = 0; i < lines_to_insert; i++)
		{
		    row_ptr = &TCB->screen[TCB->row_order[TCB->bot_scroll-i]];
		    row_ptr->all_chars_norm = 1;
		    row_ptr->font_table = NORMAL_OFFSET;
		    _EMFillScreen (TCB, TCB->bot_scroll - i, 0, 
				   TCB->bot_scroll - i, TCB->col_width - 1, 
				   SPACE, 0);
		}    

		/* Save indices of the cleared lines. */
		for (i = 0; i < lines_to_insert; i++)
		    save_line[i] = TCB->row_order[TCB->bot_scroll - i];

		/* Scroll down "lines_to_insert" times. */
		for (i = TCB->bot_scroll - lines_to_insert;
		     i >= first_line; i--)
		    TCB->row_order[i + lines_to_insert] = TCB->row_order[i];

		/* Re-assign the saved rows to the inserted lines. */
		for (i = 0; i < lines_to_insert; i++)
		    TCB->row_order[first_line + i] = save_line[i];

		/* Re-display the area from the current line to the 	*/
		/* bottom of the scroll region.			*/
		_EMDisplayScreen (TCB, first_line, 
				  TCB->bot_scroll - first_line + 1, 
				  0,  TCB->col_width, FALSE);

	    }

	    /* Move to the first column of the current line. */
	    _EMUpdatePosAbsolute (TCB, first_line, 0);
	}
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDeleteLines					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDeleteLines (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes the "<ESC>[nM" sequence, which	*/
/*	  deletes the current line and the n - 1 following lines.	*/
/*	  If "n" is omitted or is zero, "n" defaults to one.  Lines	*/
/*	  below the bottom of the scroll region are not deleted, and	*/
/*	  the sequence is ignored if the current position is outside	*/
/*	  the scroll region.						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMDeleteLines (TCB)

EM_TCB	*TCB;
{
	int	lines_to_delete;	/* # of lines to be deleted	*/
	int	first_line;		/* first line to delete		*/
	int	last_line;		/* last line to delete		*/
	int	save_line[VTROW];	/* saves indices of bottom rows	*/
					/*  of the scroll region	*/
	int	i;			/* loop counter			*/

	EMscreen_row	*row_ptr;	/* pointer to row being deleted	*/


	/* Execute the escape sequence only if the current position is	*/
	/* within the scroll region and VT-200 mode is in effect.	*/
	if ((TCB->in_region) && (TCB->term_settings.vt200))
	{
	    /* Determine how many lines are to be deleted. */
	    lines_to_delete = TCB->esc_seq_buffer[0];
	    if (lines_to_delete == 0)
		lines_to_delete = 1;

	    /* Only lines within the scroll region may be deleted. */
	    if (lines_to_delete > (TCB->bot_scroll - TCB->current_line + 1))
		lines_to_delete = TCB->bot_scroll - TCB->current_line + 1;

	    first_line = TCB->current_line;
	    last_line = first_line + lines_to_delete - 1;

	    if (last_line >= TCB->bot_scroll)
	    {
		/* Delete from the current line to the end of the	*/
		/* scroll region.  					*/
		for (i = first_line; i <= last_line; i++)
		{
		    row_ptr = &TCB->screen[TCB->row_order[i]];
		    row_ptr->all_chars_norm = 1;
		    row_ptr->font_table = NORMAL_OFFSET;
		}

		/* Fill the deleted lines with blanks. */
		_EMFillScreen (TCB, first_line, 0, last_line, 
			       TCB->col_width - 1, SPACE, 0);

		/* Reflect the blank lines on the screen. */
		_EMDisplayScreen (TCB, first_line, lines_to_delete, 0, 
				  TCB->col_width, FALSE);
	    }
	    else
	    {
		/* Fill the deleted lines with blanks and set their	*/
		/* attributes to normal.				*/
		for (i = first_line; i <= last_line; i++)
		{
		    row_ptr = &TCB->screen[TCB->row_order[i]];
		    row_ptr->all_chars_norm = 1;
		    row_ptr->font_table = NORMAL_OFFSET;
		    _EMFillScreen (TCB, i, 0, i, TCB->col_width - 1, SPACE, 0);
		}    

		/* Save indices of the deleted lines. */
		for (i = 0; i < lines_to_delete; i++)
		    save_line[i] = TCB->row_order[first_line + i];

		/* Scroll up the lines below the last deleted line. 	*/
		for (i = first_line;
		     i <= TCB->bot_scroll - lines_to_delete; i++)
		    TCB->row_order[i] = TCB->row_order[i + lines_to_delete];

		/* Re-assign the saved rows to the bottom of the scroll	*/
		/* region.						*/
		for (i = 0; i < lines_to_delete; i++)
		    TCB->row_order[TCB->bot_scroll - i] = save_line[i];

		/* Re-display the area from the current line to the	*/
		/* bottom of the scroll region.				*/
		_EMDisplayScreen (TCB, first_line, 
				  TCB->bot_scroll - first_line + 1, 
				  0,  TCB->col_width, FALSE);
	    }

	    /* Move to the first column of the current line. */
	    _EMUpdatePosAbsolute (TCB, first_line, 0);
	}
}
