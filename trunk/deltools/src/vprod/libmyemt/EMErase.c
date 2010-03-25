#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEraseLineRegion				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMEraseLineRegion (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[nK" and "<ESC>[?nK" sequences. */
/*	  These sequences erase a portion of the current line.  The	*/
/*	  actions performed for permissible values of "n" are given	*/
/*	  below:							*/
/*									*/
/*	       n =	Action						*/
/*	       ---	------						*/
/*		0	erase from the cursor position to the end of	*/
/*		          the line					*/
/*		1	erase from the beginning of the line to the   	*/
/*			  cursor position				*/
/*		2	erase the entire line				*/
/*									*/
/*	  If "n" is ommited, the action for n = 0 is taken.  		*/
/*									*/
/*	  The "?" indicates that non-erasable characters and display	*/
/*	  attributes are to be left alone.  It is interpreted only in	*/
/*	  VT-220 mode; it is ignored in VT-100 mode.			*/
/*									*/
/*	  The cursor position remains unchanged in any case.		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMEraseLineRegion (TCB)

EM_TCB	*TCB;
{
	int	check_erase;		/* flag sent to "_EMFillScreen"	*/
					/*  which indicates whether	*/
					/*  to check for non-erasable	*/
					/*  characters			*/
	unsigned char	*parameter_ptr;	/* pointer to the next escape	*/
					/*  sequence parameter		*/
	int	valid_parameter;	/* flag which indicates whether	*/
					/*  a valid parameter is in 	*/
					/*  the buffer			*/
	int	start_col;		/* first column to erase	*/
	int	end_col;		/* last column to erase		*/


	parameter_ptr = TCB->esc_buff_ptr++;

	if (*parameter_ptr == '>')
	    parameter_ptr++;

	/* Determine whether or not to check for erasable characters.	*/
	check_erase = FALSE;
	if (*parameter_ptr == '?')
	{
	    parameter_ptr++;
	    check_erase = TCB->term_settings.vt200;
	}

	valid_parameter = TRUE;

	switch (*parameter_ptr)
	{
	    case 0:
		/* Erase from the cursor the the end of the line. */
		start_col = TCB->current_col;
		end_col = TCB->col_width - 1;
		break;

	    case 1:
		/* Erase from the beginning of the line to the cursor	*/
		start_col = 0;
		end_col = TCB->current_col;
		break;

	    case 2:
		/* Erase the entire line. */
		start_col = 0;
		end_col = TCB->col_width - 1;
		break;

	    case 3:
		/* Erase the given column range. */
		if (TCB->last_param - parameter_ptr == 2)
		{
		    start_col = *(++parameter_ptr) - 1;
		    end_col = *(++parameter_ptr) - 1;
		}
		else
		    valid_parameter = FALSE;
		break;

	    default:
		valid_parameter = FALSE;
	}

	if (valid_parameter)
	{
	    _EMFillScreen (TCB, TCB->current_line, start_col, TCB->current_line,
			   end_col, TCB->erase_character, check_erase);

	    if (check_erase)
		_EMDisplayScreen (TCB, TCB->current_line, 1, start_col, 
				  end_col - start_col + 1, FALSE);
	    else
		_EMEraseWindowRegion (TCB, TCB->current_line, 1, start_col, 
				      end_col - start_col + 1);
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEraseScreenRegion				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMEraseScreenRegion (TCB)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[nJ" and "<ESC>[?nJ" sequences. */
/*	  These sequences erase a portion of the screen.  The actions	*/
/*	  performed for permissible values of "n" are given below:	*/
/*									*/
/*	       n =	Action						*/
/*	       ---	------						*/
/*		0	erase from the cursor position to the end of	*/
/*		          the screen					*/
/*		1	erase from the beginning of the screen to the   */
/*			  cursor position				*/
/*		2	erase the entire screen				*/
/*									*/
/*	  If "n" is ommited, the action for n = 0 is taken.  		*/
/*									*/
/*	  The "?" indicates that non-erasable characters and display	*/
/*	  attributes are to be left alone.  It is interpreted only in	*/
/*	  VT-220 mode; it is ignored in VT-100 mode.			*/
/*									*/
/*	  The cursor position remains unchanged in any case.		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMEraseScreenRegion (TCB)

EM_TCB	*TCB;
{
	int	check_erase;		/* flag sent to "_EMFillScreen"	*/
					/*  which indicates whether	*/
					/*  to check for non-erasable	*/
					/*  characters			*/
	unsigned char	*parameter_ptr;	/* pointer to the next escape	*/
					/*  sequence parameter		*/
	int	start_col;		/* first and last column on	*/
	int	end_col;		/*  current line to erase	*/
	int	start_row;		/* first and last rows to	*/
	int	end_row;		/*  erase, excluding the	*/
					/*  current line		*/
	int	row;			/* loop counter			*/
	int	valid_parameter;	/* indicates whether or not a	*/
					/*  valid parameter is in	*/
					/*  the buffer			*/
	EMscreen_row	*row_ptr;	/* points into the screen	*/
					/*  matrix to the row whose	*/
					/*  attributes are being	*/
					/*  reset to normal		*/


	/* Determine whether or not to check for erasable characters.	*/
	parameter_ptr = TCB->esc_buff_ptr++;

	check_erase = FALSE;
	if (*parameter_ptr == '?')
	{
	    parameter_ptr++;
	    check_erase = TCB->term_settings.vt200;
	}

	valid_parameter = TRUE;

	switch (*parameter_ptr)
	{
	    case 0:
		/* Erase from the cursor the the end of the screen	*/
		/* or scroll region, depending on the erase extent.	*/
		start_col = TCB->current_col;
		end_col = TCB->col_width - 1;
		start_row = TCB->current_line + 1;

		if (TCB->term_settings.eraseExtent)
		    end_row = TCB->bot_scroll;
		else
		    end_row = TCB->displayed_rows - 1;
		break;

	    case 1:
		/* Erase from the beginning of the screen or scroll	*/
		/* region, depending upon the erase extent, to the 	*/
		/* cursor.						*/
		start_col = 0;
		end_col = TCB->current_col;

		if (TCB->term_settings.eraseExtent)
		    start_row = TCB->top_scroll;
		else	
		    start_row = 0;

		end_row = TCB->current_line - 1;
		break;

	    case 2:
		/* Erase the entire screen or scroll region. */
		start_col = 0;
		end_col = TCB->col_width - 1;

		if (TCB->term_settings.eraseExtent)
		{
		    start_row = TCB->top_scroll;
		    end_row = TCB->bot_scroll;
		}
		else
		{
		    start_row = 0;
		    end_row = TCB->displayed_rows - 1;
		}
		break;

	    default:
		valid_parameter = FALSE; 
	}

	if (valid_parameter)
	{
	    /* Erase characters on the current line. */
	    _EMFillScreen (TCB, TCB->current_line, start_col, 
			   TCB->current_line, end_col, TCB->erase_character, 
			   check_erase);

	    if (check_erase)
		_EMDisplayScreen (TCB, TCB->current_line, 1, start_col,
				  end_col - start_col + 1, FALSE);
	    else
		_EMEraseWindowRegion (TCB, TCB->current_line, 1, start_col,
				      end_col - start_col + 1);

	    /* If the entire current line was erased and we are not	*/
	    /* concerned with non-erasable characters, set the		*/
	    /* current line's attributes to normal.			*/
	    if ((start_col == 0) && (end_col == TCB->col_width - 1) &&
		(! check_erase))
	    {
		TCB->current_row->all_chars_norm = TRUE;
		TCB->current_row->font_table = NORMAL_OFFSET;
	    }

	    /* Erase all specified rows, excluding the current line. */
	    _EMFillScreen (TCB, start_row, 0, end_row, TCB->col_width, 
			   TCB->erase_character, check_erase);

	    for (row = start_row; row <= end_row; row++)
	    {
		if (! check_erase)
		{
		    row_ptr = &TCB->screen[TCB->row_order[row]];
		    row_ptr->all_chars_norm = TRUE;
		    row_ptr->font_table = NORMAL_OFFSET;
		}
	    }

	    /* Display the updated screen. */
	    if (check_erase)
		_EMDisplayScreen (TCB, start_row, (end_row - start_row + 1), 
				  0, TCB->col_width, FALSE);
	    else
		_EMEraseWindowRegion (TCB, start_row, end_row - start_row + 1, 
				      0, TCB->col_width);
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEraseCharacters				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMEraseCharacters (TCB)					*/
/*	 								*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes the "<ESC>[nX" sequence.  This	*/
/*	  sequence erases "n" characters, starting with the character	*/
/*	  under the cursor.  It is valid only in VT-220 mode.		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMEraseCharacters (TCB)

EM_TCB	*TCB;
{
	char	chars_to_erase;		/* number of chars to erase	*/
	int	start_col;		/* first column to erase	*/
	int	end_col;		/* last column to erase		*/


	if (TCB->term_settings.vt200)
	{
	    chars_to_erase = TCB->esc_seq_buffer[0];

	    if (chars_to_erase == 0)
		chars_to_erase = 1;

	    start_col = TCB->current_col;
	    end_col = start_col + chars_to_erase - 1;

	    if (end_col >= TCB->col_width)
		end_col = TCB->col_width - 1;

	    _EMFillScreen (TCB, TCB->current_line, start_col, 
			   TCB->current_line, end_col, TCB->erase_character, 0);
	    _EMDisplayScreen (TCB, TCB->current_line, 1, start_col, 
			      end_col - start_col + 1, FALSE);
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMChangeEraseChar				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMChangeEraseChar (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[ns" and "<ESC>[>ns" sequences, */
/* 	  which change the erase character.  If "n" is omitted, the	*/
/*	  erase character is changed to be the space character.		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMChangeEraseChar (TCB)

EM_TCB	*TCB;
{
	char	new_erase_char;


	new_erase_char = TCB->esc_seq_buffer[0];

	if (new_erase_char == '>')
	    new_erase_char = TCB->esc_seq_buffer[1];

	if (new_erase_char)
	    TCB->erase_character = new_erase_char;
	else
	    TCB->erase_character = SPACE;
}
