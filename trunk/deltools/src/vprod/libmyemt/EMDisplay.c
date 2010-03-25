#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"


static long _EMWhite[32] =
{
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
};

void	_EMScroll ();
void	_EMDisplayString ();
void	_EMEraseWindowRegion ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDrawSymbols					*/
/*									*/
/*	SYNOPSIS:							*/
/*	void  _EMDrawSymbols (TCB, font_id, font_mode, x1, y1,		*/
/*			      x2, y2, string, string_length)		*/
/*									*/
/*	EM_TCB	*TCB;		-- terminal control block pointer	*/
/*	int	font_id;	-- font descriptor of font to be used	*/
/*	int	font_mode;	-- font mode				*/
/*	int	x1, y1, x2, y2;	-- rectangle to display it in		*/
/*	char	*string;	-- text string to be displayed		*/
/*	int	string_length;	-- number of characters in the string	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This routine draws the string in the specified font.  The	*/
/*	  font mode determines what type of font (normal, top, bottom)	*/
/*	  it is.							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  none								*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void  _EMDrawSymbols (TCB, font_id, font_mode, x1, y1, x2, y2, string, 
		      string_length)

EM_TCB	*TCB;
int	font_id;
int	font_mode;
int	x1, y1, x2, y2;
char	*string;
int	string_length;
{
    if (font_mode != 0)
	_EMSetClipBox (TCB, x1, y1, x2, y2);

    if (font_mode == 2)
	y1 -= (y2 - y1);

    drawsymbols (TCB->window, font_id, x1, y1, string, string_length);

    if (font_mode != 0)
	_EMRestoreClipBox (TCB);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDisplayScreen				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDisplayScreen (TCB, row, row_count, col, col_count,	*/
/*				 matrix)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  int	  row;		-- pointer into the "row_order" array   */
/*				     to the first row to display	*/
/*	  int     row_count;	-- number of rows to display		*/
/*	  int	  col;		-- index of first column to display	*/
/*	  int	  col_count;	-- number of columns to display per row */
/*	  int	  matrix;	-- T: disregard double-high characters;	*/
/*				   just draw the specified char matrix	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function displays a portion of the screen matrix on	*/
/*	  the terminal screen (window).  The rectangular area defined   */
/*	  by (row, col) and (row + row_count - 1, col + col_count - 1)  */
/*	  is displayed.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMDisplayScreen (TCB, start_row, row_count, start_col, col_count, matrix)

EM_TCB	*TCB;
int	start_row, row_count, start_col, col_count;
int	matrix;
{
	EMscreen_row	*row_ptr;	/* pointer to current row being	*/
					/*  displayed			*/
	int	row;			/* index of row being displayed	*/
	int	col;			/* current column index		*/
	int	last_row;		/* index of last row to display	*/
	int	last_col;		/* index of last column on row	*/
	int	font_offset;		/* font-type offset for current	*/
					/*  row				*/
	int	font_id;		/* font ID for current row	*/
	int	status;			/* "_EMLoadFont" status		*/
	int	string_start;		/* index of first character in	*/
					/*  a string of like chars.	*/
	int	char_cnt;		/* used for space truncating	*/
	int	wRatio;			/* ratio of active/cell width	*/
	int	x1, y1, x2, y2;		/* pixel coordinates of the	*/
					/*  character "cell"		*/

	if ((row_count == 0) || (col_count == 0))
	    return;

	last_row = start_row + row_count;
	last_col = start_col + col_count;

	for (row = start_row; row < last_row; row++)
	{
	    row_ptr = &TCB->screen[TCB->row_order[row]];
	    font_offset = row_ptr->font_table;
	    font_id = _EMLoadFont (TCB, CHAR_NORMAL, font_offset, &status);
	    wRatio = matrix ? TCB->active_width / TCB->cell_width : 1;

	    /* Display the entire row if all characters are "normal." */
	    if (row_ptr->all_chars_norm)
	    {
		/* erase the portion of the row that is to be displayed */
		fgcolor (TCB->window, TCB->background_color);
		_EMCalcMatrixBounds (TCB, row, 1,
				   start_col / wRatio, col_count / wRatio,
				   &x1, &y1, &x2, &y2);
		rectf (TCB->window, x1, y1, x2, y2);

		/* truncate spaces at end of row */
		char_cnt = col_count;
	 	while ((char_cnt > 0) &&
		    (row_ptr->character[start_col / wRatio + char_cnt - 1] ==
		     SPACE))
		    char_cnt--;

		/* Set the text color and draw the characters. */
		fgcolor (TCB->window, TCB->foreground_color);
		if (char_cnt > 0)
		    _EMDrawSymbols (TCB, font_id, _EMFontModes[font_offset],
				    x1, y1, x2, y2,
				    &row_ptr->character[start_col / wRatio],
				    char_cnt);
	    }
	    else
	    {
		/* Display the row piece-by-piece. */
		col = start_col / wRatio;

	 	while (col < last_col)
		{
		    /* Find a string of characters with similar		*/
		    /* attributes, starting at the current column.	*/
		    string_start = col;

		    col++;
		    while ((col < last_col) &&
			   (row_ptr->char_attr[col-1] ==
						row_ptr->char_attr[col]) &&
			   (row_ptr->char_color[col-1] ==
						row_ptr->char_color[col]) &&
			   (row_ptr->cell_color[col-1] ==
						row_ptr->cell_color[col]) )
			col++;

		    /* Display the string. */
		    _EMDisplayString (TCB, font_id, font_offset, 
				      row_ptr->char_attr[string_start], 
				      &row_ptr->character[string_start], 
				      row, string_start, col - string_start,
				      matrix);
		}
	    }

	    /* draw the bottom buffer indicator if necessary */
	    if ((row + TCB->buf_win) == (TCB->buf_lines - 1))
	    {
		y1 = TCB->wy1 + TCB->char_height * (row + 1) - 1;
		blendline (TCB->window, 0xAAAA);
		move (TCB->window, TCB->wx1, y1);
		draw (TCB->window, TCB->wx2, y1);
		blendline (TCB->window, 0xFFFF);
	    }
	}

	/* Hilite characters if they are selected */
	wRatio = matrix ? 1 : (TCB->active_width / TCB->cell_width);
	_EMDrawTextHilite (TCB, start_row, start_col * wRatio,
			   last_row - 1, last_col * wRatio, TRUE);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDisplayString				*/
/*									*/
/*	SYNOPSIS:							*/
/*	void  _EMDisplayString (TCB, font_id, font_offset, attributes,	*/
/*				string, row, col, string_length,	*/
/*				matrix)					*/
/*									*/
/*	EM_TCB	*TCB;		-- pointer to active TCB		*/
/*	int	font_id;	-- font descriptor of font to be used	*/
/*	int	font_offset;	-- font-type offset for current row	*/
/*	unsigned char							*/
/*		attributes;	-- attribute mask for characters in 	*/
/*				     the string				*/
/*	char	*string;	-- text string to be displayed		*/
/*	int	row;		-- row index of row to be displayed	*/
/*	int	col;		-- column index of string's first	*/
/*				     character				*/
/*	int	string_length;	-- number of characters in the string	*/
/*	int	matrix;		-- T: disregard double-high characters;	*/
/*				   just draw the specified char matrix	*/
/*									*/
/*	DESCRIPTION:							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  none								*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void  _EMDisplayString (TCB, font_id, font_offset, attributes, string, 
			row, col, string_length, matrix)

EM_TCB	*TCB;
int	font_id;
int	font_offset;
unsigned char	attributes;
char	*string;
int	row;
int	col;
int	string_length;
int	matrix;
{
	int		x1, y1, x2, y2;	/* pixel coordinates for region	*/
					/*  surrounding string		*/
	int		color_mode;	/* terminal's color mode	*/
	int		cell_color;
	int		text_color;
	int		swap_color;
	int		status;		/* "_EMLoadFont" return status	*/
	int		charWidth;
	EMscreen_row	*row_ptr;	/* pointer to the row being	*/
					/*  displayed			*/

	charWidth = matrix ? TCB->cell_width : TCB->active_width;

	/* Find the coordinates of the rectangular character background	*/
	x1 = TCB->wx1 + charWidth * col ;
	y1 = TCB->wy1 + TCB->char_height * row;
	x2 = x1 + (charWidth * string_length) - 1;
	y2 = y1 + TCB->char_height - 1;

	/* Point the row structure of the row being displayed. */
	row_ptr = &TCB->screen[TCB->row_order[row]];

	/* Get the terminal's color mode. */
	color_mode = _EMGetColorMode (&TCB->state_table);

	/* Set default cell and character colors. */
	cell_color = TCB->background_color;
	text_color = TCB->foreground_color;

	if (attributes & CHAR_BOLD)
	{
	    /* Determine the text color. */
	    if (color_mode != BILEVEL)
		text_color = BOLD_CT_INDEX + VLT_OFFSET +
		    _EMFixedVLTOffset[_EMGetScreenNumber (&TCB->state_table)];

	    /* Determine the cell background color. */
	    if (attributes & CHAR_COLOR)
		if (TCB->term_settings.screenReverse)
		    cell_color = row_ptr->char_color[col];
		else
		    cell_color = row_ptr->cell_color[col];
	}
	else if (attributes & CHAR_COLOR)
	{
	    if (TCB->term_settings.screenReverse)
	    {
		text_color = row_ptr->cell_color[col];
		cell_color = row_ptr->char_color[col];
	    }
	    else
	    {
		text_color = row_ptr->char_color[col];
		cell_color = row_ptr->cell_color[col];
	    }
	}

	/* If the character has the "inverse character" attribute,	*/
	/* interchange the cell and text colors.			*/
	if (attributes & CHAR_REVERSE)
	{
	    swap_color = cell_color;
	    cell_color = text_color;
	    text_color = swap_color;
	}


	/* Draw the character cell. */
	fgcolor (TCB->window, cell_color);
	rectf (TCB->window, x1, y1, x2, y2);

	/* Set the text color and draw the characters. */
	fgcolor (TCB->window, text_color);

	if (attributes & CHAR_GRAPHICS)
	    font_id = _EMLoadFont (TCB, CHAR_GRAPHICS, font_offset, &status);

	_EMDrawSymbols (TCB, font_id, _EMFontModes[font_offset],
			x1, y1, x2, y2, string, string_length);


	if ((attributes & CHAR_BOLD) && (color_mode == BILEVEL))
	{
	    /* Redraw the text string one pixel over for thickness. */
	    _EMDrawSymbols (TCB, font_id, _EMFontModes[font_offset],
			    x1 + 1, y1, x2, y2, string, string_length);
	}

	if (attributes & CHAR_UNDERLINE)
	{
	    /* Don't draw the underline if the string is the upper-half	*/
	    /* of a double-high text string.				*/
	    if ((font_offset != DHDWTOP_OFFSET) && 
		(font_offset != DHSWTOP_OFFSET))
	    {
		/* Draw the underline. */
		move (TCB->window, x1, y2 - 2);
		draw (TCB->window, x2, y2 - 2);

		/* If the string is double-high, make the line twice	*/
		/* as thick.						*/
		if ((font_offset != NORMAL_OFFSET) && 
		    (font_offset != SHDW_OFFSET))
		{
		    move (TCB->window, x1, y2 - 3);
		    draw (TCB->window, x1, y2 - 3);
		}
	    }
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMFillScreen					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMFillScreen (TCB, row_1, col_1, row_2, col_2, 		*/
/*			      fill_char, check_erase)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  int	  row_1;	-- upper row of region to fill		*/
/*	  int	  col_1;	-- left column of region to fill	*/
/*	  int	  row_2;	-- lower row of region to fill		*/
/*	  int	  col_2;	-- right column of region to fill	*/
/*	  char	  fill_char;	-- character to be placed in region	*/
/*	  int	  check_erase;  -- flag:  F => do not check whether	*/
/*				               or not characters in	*/
/*					       the region are erasable  */
/*					  T => check for erasable	*/
/*					       characters		*/
/*	  								*/
/*	DESCRIPTION:							*/
/*	  This function fills a rectangular region of the screen	*/
/*	  matrix with a specified fill character.  If the "check_erase" */
/*	  flag is set, non-erasable characters are over-written and	*/
/*	  none of the character attributes are altered (not even	*/
/*	  the attributes of over-written characters).  Otherwise,	*/
/*	  all characters in the specified region are over-written	*/
/*	  and their attributes are set to "normal."			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMFillScreen (TCB, row_1, col_1, row_2, col_2, fill_char, check_erase)

EM_TCB	*TCB;
int	row_1, col_1;
int	row_2, col_2;
char	fill_char;
int	check_erase;
{
	Char8	*char_ptr;	/* pointer into the screen matrix to 	*/
				/*  the current character		*/
	Char8	*attr_ptr;	/* pointer into the screen matrix to	*/
				/*  the current character's attribute	*/
				/*  mask				*/
	Char8	erase;		/* flag which indicates that the 	*/
				/*  current character is erasable	*/
	EMscreen_row *row_ptr;	/* pointer into the screen matrix to	*/
				/*  the row being filled		*/
	int	row, col;	/* loop counters			*/


	/* Set the erase flag. */
	if (check_erase)
	    erase = CHAR_ERASABLE;
	else
	    erase = 0xFF;


	/* Fill the region with the fill character. */
	for (row = row_1; row <= row_2; row++)
	{
	    row_ptr = &TCB->screen[TCB->row_order[row]];
	    char_ptr = &row_ptr->character[col_1];
	    attr_ptr = &row_ptr->char_attr[col_1];

	    for (col = col_1; col <= col_2; col++)
	    {
		/* Over-write erasable characters. */
		if (*attr_ptr & erase)	
		    *char_ptr = fill_char;

		/* If the "check_erase" flag is not set, set the 	*/
		/* attribute mask for the current position to "normal."	*/
		if (! check_erase)
		    *attr_ptr = CHAR_NORMAL;

		char_ptr++;
		attr_ptr++;
	    }
	}
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInitRows					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMInitRows (TCB, row1, row2)				*/
/*									*/
/*	  EM_TCB	*TCB;	-- pointer to active TCB		*/
/*	  int		row;	-- first row to initialize		*/
/*	  int		rows;	-- number of rows to initialize		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function initializes the specified rows to the normal	*/
/*	  state.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMInitRows (TCB, row, rows)

EM_TCB	*TCB;
int	row, rows;
{
    int			i, j, endRow;
    EMscreen_row	*rowPtr;

    rowPtr = &TCB->screen[row];
    endRow = row + rows;
    for (i = row; i < endRow; i++)
    {
	TCB->row_order[i] = i;

	for (j = 0; j < VTCOL; j++)
	{
	    rowPtr->character[j] = SPACE;
	    rowPtr->char_attr[j] = CHAR_NORMAL;
	    rowPtr->char_color[j] = TCB->foreground_color;
	    rowPtr->cell_color[j] = TCB->background_color;
	}

	rowPtr->font_table = NORMAL_OFFSET;	  
	rowPtr->all_chars_norm = TRUE;
	rowPtr++;
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMClearScreenMatrix				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMClearScreenMatrix (TCB)				*/
/*									*/
/*	  EM_TCB  *TCB		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function clears the screen matrix of the currently	*/
/*	  active terminal instance.					*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMClearScreenMatrix (TCB)

EM_TCB	*TCB;
{
	EMscreen_row	*row_ptr;
	EMscreen_row	*last_row;


	/* Fill the screen matrix with blanks. */
	_EMFillScreen (TCB, 0, 0, TCB->displayed_rows - 1, VTCOL - 1, SPACE, 0);

	/* Set all row attributes to normal. */
	row_ptr = &TCB->screen[0];
	last_row = &TCB->screen[TCB->displayed_rows - 1];

	while (row_ptr <= last_row)
	{
	    row_ptr->all_chars_norm = TRUE;
	    row_ptr->font_table = NORMAL_OFFSET;
	    row_ptr++;
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMClearScreen					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMClearScreen (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function clears the screen (window) of the currently	*/
/*	  active terminal instance.  The screen matrix is not modified.	*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMClearScreen (TCB)

EM_TCB	*TCB;
{
	fgcolor (TCB->window, TCB->background_color);
	rectf (TCB->window, TCB->x1, TCB->y1, TCB->x2, TCB->y2);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEraseWindowRegion				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMEraseWindowRegion (TCB, start_row, row_count,		*/
/*				     start_col, col_count)		*/
/*									*/
/*	  EM_TCB  *TCB		-- pointer to active TCB		*/
/*	  int	  start_row;	-- pointer into the "row_order" array   */
/*				     to the first row to erase		*/
/*	  int     row_count;	-- number of rows to erase		*/
/*	  int	  start_col;	-- index of first column to erase	*/
/*	  int	  col_count;	-- number of columns to erase per row	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function erases a portion of the screen window of the	*/
/*	  currently active terminal instance.  It is useful for 	*/
/*	  clearing an an area known to contain blanks (e.g., after	*/
/*	  a call to "_EMFillScreen").					*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMEraseWindowRegion (TCB, start_row, row_count, start_col, col_count)

EM_TCB	*TCB;
int	start_row, row_count, start_col, col_count;
{
	int	x1, y1, x2, y2;	/* pixel coordinates of screen region	*/
				/*   to be cleared			*/


	fgcolor (TCB->window, TCB->background_color);

	_EMCalcMatrixBounds (TCB, start_row, row_count, start_col, col_count,
			     &x1, &y1, &x2, &y2);
	rectf (TCB->window, x1, y1, x2, y2);

	/* redisplay text selection */
	_EMDrawTextHilite (TCB, start_row, start_col, start_row + row_count - 1,
			   start_col + col_count, TRUE);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDrawCursor					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDrawCursor (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function draws the cursor at the current position	*/
/*	  and draws the character under the cursor.			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMDrawCursor(TCB)

EM_TCB	*TCB;
{
	unsigned char	attribute_mask;	/* attribute mask of the char.	*/
					/*  under the cursor		*/
	int	all_chars_norm;
	int	color;			/* color of underline cursor	*/
	int	x1, y1, x2, y2;		/* coordinates of underline	*/
					/*  cursor			*/


	if ((TCB->term_settings.cursorVisible) && !TCB->scrolled_back)
	{
	    if (TCB->term_settings.cursorBlock)	
	    {
		/* Save the attributes of the current line and char	*/
		attribute_mask = 
				TCB->current_row->char_attr[TCB->current_col];
		all_chars_norm = TCB->current_row->all_chars_norm;

		/* Drawing the character reversed simulates the drawing */
		/* of the block cursor.					*/
		TCB->current_row->char_attr[TCB->current_col] ^= CHAR_REVERSE;
		TCB->current_row->all_chars_norm = FALSE;

		_EMDisplayScreen (TCB, TCB->current_line, 1, 
				  TCB->current_col, 1, FALSE);

		/* Restore the line and character attributers.	*/
		TCB->current_row->char_attr[TCB->current_col] = attribute_mask;
		TCB->current_row->all_chars_norm = all_chars_norm;
	    }
	    else
	    {   
		/* Determine the color of the underline cursor. */
		attribute_mask = TCB->current_row->char_attr[TCB->current_col];

		if (attribute_mask & CHAR_REVERSE)
		    color = TCB->background_color;
		else
		    if ((attribute_mask & CHAR_BOLD) &&
			_EMGetColorMode (&TCB->state_table) != BILEVEL)
			color = BOLD_CT_INDEX + VLT_OFFSET +
				_EMFixedVLTOffset[_EMGetScreenNumber
							(&TCB->state_table)];
		    else
			color = TCB->foreground_color;

		/* Determine the coordinates of the underline cursor. */
		x1 = TCB->wx1 + TCB->current_col * TCB->active_width;
		x2 = x1 + TCB->active_width - 1;
		y1 = TCB->wy1 + (TCB->current_line + 1) * TCB->char_height - 5;
		y2 = y1 + 2;

		/* Draw the underline cursor */
		fgcolor (TCB->window, color);
		rectf (TCB->window, x1, y1, x2, y2);
	    }
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEraseCursor					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMEraseCursor (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function erases the cursor and redisplays the character  */
/*	  that was underneath the cursor.				*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMEraseCursor (TCB)

EM_TCB	*TCB;
{
	int	line;

	line = TCB->current_line + (TCB->buf_lines - TCB->buf_win);
	if (line < TCB->displayed_rows)
	    _EMDisplayScreen (TCB, line, 1, TCB->current_col, 1, FALSE);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMScrollUp					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMScrollUp (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function scrolls the scroll area up one row and updates	*/
/*	  the screen variables.  If the top of the scroll area is the	*/
/*	  first row, the text is appended to the scroll buffer.		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMScrollUp (TCB)

EM_TCB	*TCB;
{
	int	new_bottom_row;		/* pointer into row order array	*/
					/*  to the new bottom row	*/
	int	row;


	/* Update the row order array. */
	new_bottom_row = TCB->row_order[TCB->top_scroll];

	for (row = TCB->top_scroll; row < TCB->bot_scroll; row++)
	    TCB->row_order[row] = TCB->row_order[row + 1];

	TCB->row_order[TCB->bot_scroll] = new_bottom_row;

	/* Save top row to the scroll buffer iff buffer exists and	*/
	/* top row is in scroll region					*/
	if (TCB->buf_lines && (TCB->top_scroll == 0))
	{
	    strncpy (&TCB->scroll_buf[TCB->bot_buf * VTCOL],
		     TCB->screen[new_bottom_row].character, VTCOL);
	    TCB->bot_buf = (TCB->bot_buf + 1) % TCB->buf_lines;
	}

	/* scroll text selection iff entire window is scrolling */
	if ((TCB->top_scroll == 0) &&
	    (TCB->bot_scroll == TCB->displayed_rows - 1))
	{
	    TCB->start_sel = MAX (TCB->start_sel - VTCOL, 0);
	    TCB->end_sel  = MAX (TCB->end_sel - VTCOL, 0);
	}
	else	/* clear the text selection */
	    _EMClearSelection (TCB->TCBD);

	/* Fill the new bottom row with blanks. */
	_EMFillScreen (TCB, TCB->bot_scroll, 0, TCB->bot_scroll, VTCOL - 1,
		       SPACE, 0);

	/* Set default attributes for the characters on the new bottom row. */
	TCB->screen[new_bottom_row].all_chars_norm = TRUE;
	TCB->screen[new_bottom_row].font_table = NORMAL_OFFSET;

	/* Scroll the raster block representing the screen up one "row" */
	_EMScroll (TCB, TCB->scr_x1, TCB->scr_y1, 
		   TCB->scr_x2, TCB->scr_y2, 0, -TCB->char_height);
}	




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMScrollDown					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMScrollDown (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function scrolls the display down one row and updates	*/
/*	  the screen variables.  This should be called only when the	*/
/*	  primary portion of the scroll buffer is fully displayed.	*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMScrollDown (TCB)

EM_TCB	*TCB;
{
	int	new_top_row;		/* pointer into row order array	*/
					/*  to the new top row		*/
	int	row;


	/* Update the row order array. */
	new_top_row = TCB->row_order[TCB->bot_scroll];

	for (row = TCB->bot_scroll; row > TCB->top_scroll; row--)
	    TCB->row_order[row] = TCB->row_order[row - 1];

	TCB->row_order[TCB->top_scroll] = new_top_row;

	/* Fill the new top row with blanks. */
	_EMFillScreen (TCB, TCB->top_scroll, 0, TCB->top_scroll, VTCOL - 1,
		       SPACE, 0);

	/* Set default attributes for the characters on the new top row. */
	TCB->screen[new_top_row].all_chars_norm = TRUE;
	TCB->screen[new_top_row].font_table = NORMAL_OFFSET;

	/* Scroll the raster block representing the screen up one "row." */
	_EMScroll (TCB, TCB->scr_x1, TCB->scr_y1, 
		   TCB->scr_x2, TCB->scr_y2, 0, TCB->char_height);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMScroll					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMScroll (TCB)						*/
/*									*/
/*	  EM_TCB	*TCB;		-- pointer to active TCB	*/
/*	  int		x1, y1, x2, y2;	-- rectangle to scroll		*/
/*	  int		dx, dy;		-- how much to scroll		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function scrolls the specified rectangle and updates the	*/
/*	  appropriate characters.					*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMScroll (TCB, x1, y1, x2, y2, dx, dy)

EM_TCB	*TCB;
int	x1, y1, x2, y2;
int	dx, dy;
{
	int	i, rx1[10], ry1[10], rx2[10], ry2[10], numRects;
	int	row, rows, column, columns;

	/* Scroll only 8 planes (especially on Mark I) */
	enableplane (TCB->window, 0xFF);

	blockscroll (TCB->window, MAX (x1, TCB->x1), MAX (y1, TCB->y1),
		     MIN (x2, TCB->x2), MIN (y2, TCB->y2), dx, dy,
		     rx1, ry1, rx2, ry2, 10, &numRects);

	enableplane (TCB->window, 0xFFFF);

	/* Redraw the characters within the rectangle list */
	for (i = 0; i < numRects; i++)
	{
	    _EMGetRectChars (TCB, rx1[i], ry1[i], rx2[i], ry2[i],
			     &row, &rows, &column, &columns);

	    _EMSetClipBox (TCB, rx1[i], ry1[i], rx2[i], ry2[i]);
	    _EMDisplayScreen (TCB, row, rows, column, columns, TRUE);
	    _EMRestoreClipBox (TCB);
	}
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetClipBox					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMSetClipBox (TCB, x1, y1, x2, y2)			*/
/*									*/
/*	  EM_TCB	*TCB;	 -- terminal control block pointer	*/
/*	  int	x1, y1, x2, y2;	 -- second rectangle to clip to		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function handles nested clipping.  If x1, y1, x2, & y2	*/
/*	  are valid, it is set to the intersection of the current clip	*/
/*	  rectangle and the specified rectangle.  The coordinates are	*/
/*	  invalid if they don't form a positive rectange; e.g., (0, 0,	*/
/*	  -1, -1).							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMSetClipBox (TCB, x1, y1, x2, y2)

EM_TCB	*TCB;
int	x1, y1, x2, y2;
{
	if ((x1 > x2) || (y1 > y2))	/* invalid rectangle? */
	{
	    x1 = TCB->x1;
	    y1 = TCB->y1;
	    x2 = TCB->x2;
	    y2 = TCB->y2;
	}

	if (TCB->sIndex == 0)
	{
	    int	wx1, wy1, wx2, wy2;

	    /** Initialize the clipbox stack **/
	    Inq_win_region (TCB->window, &wx1, &wy1, &wx2, &wy2);
	    TCB->cx1 = TCB->cy1 = 0;
	    TCB->cx2 = wx2 - wx1;
	    TCB->cy2 = wy2 - wy1;
	}

	/** Save the current clip rectangle **/
	TCB->sx1[TCB->sIndex] = TCB->cx1;
	TCB->sy1[TCB->sIndex] = TCB->cy1;
	TCB->sx2[TCB->sIndex] = TCB->cx2;
	TCB->sy2[TCB->sIndex] = TCB->cy2;
	TCB->sIndex++;

	/** AND the current clipbox with the new one **/
	TCB->cx1 = MAX (x1, TCB->cx1);
	TCB->cy1 = MAX (y1, TCB->cy1);
	TCB->cx2 = MIN (x2, TCB->cx2);
	TCB->cy2 = MIN (y2, TCB->cy2);

	clipbox (TCB->window, TCB->cx1, TCB->cy1, TCB->cx2, TCB->cy2);

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMRestoreClipBox				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMRestoreClipBox (TCB)					*/
/*									*/
/*	  EM_TCB	*TCB;	 -- terminal control block pointer	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function restores the previous clipbox.  See		*/
/*	  _EMSetClipBox.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMRestoreClipBox (TCB)

EM_TCB	*TCB;
{
	TCB->sIndex--;
	TCB->cx1 = TCB->sx1[TCB->sIndex];
	TCB->cy1 = TCB->sy1[TCB->sIndex];
	TCB->cx2 = TCB->sx2[TCB->sIndex];
	TCB->cy2 = TCB->sy2[TCB->sIndex];

	clipbox (TCB->window, TCB->cx1, TCB->cy1, TCB->cx2, TCB->cy2);

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMResetClipBox					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMSetClipBox (TCB)					*/
/*									*/
/*	  EM_TCB	*TCB;	 -- terminal control block pointer	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function resets the clipbox back to what the TCB thinks	*/
/*	  it is.							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMResetClipBox (TCB)

EM_TCB	*TCB;
{
	clipbox (TCB->window, TCB->cx1, TCB->cy1, TCB->cx2, TCB->cy2);

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGraphicsNormal				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMGraphicsNormal (TCB)					*/
/*									*/
/*	  EM_TCB	*TCB;	 -- terminal control block pointer	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the graphics attributes to normal.		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMGraphicsNormal (TCB)

EM_TCB	*TCB;
{
	int	window;

	window = TCB->window;

	blendarea (window, _EMWhite);
	texture (window, _EMWhite);
	blendline (window, 0xFFFF);
	linestyle (window, 0xFFFF);
	weight (window, 0);

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetRectChars					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMGetRectChars (TCB, x1, y1, x2, y2, row, rows, column,	*/
/*			       columns)					*/
/*									*/
/*	  EM_TCB	*TCB;		 -- terminal control block ptr	*/
/*	  int		x1, y1,		 -- the rectangle		*/
/*			x2, y2;						*/
/*	  int		*row, *rows,	 -- character matrix		*/
/*			*column, *columns;				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function calculates the character matrix that completely	*/
/*	  encloses the specified rectangle (window coordinates).	*/
/*	  It is used for calculating which character actually need to	*/
/*	  be drawn in certain instances.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMGetRectChars (TCB, x1, y1, x2, y2, row, rows, column, columns)

EM_TCB	*TCB;
int	x1, y1, x2, y2;
int	*row, *rows, *column, *columns;
{
	int	r1, c1, r2, c2;

	r1 = (y1 - TCB->wy1) / TCB->char_height;
	r1 = MAX (r1, 0);
	r1 = MIN (r1, TCB->displayed_rows);

	c1 = (x1 - TCB->wx1) / TCB->cell_width;
/*	c1 = MAX (c1, 0);
	c1 = MIN (c1, TCB->col_width);
*/
	c1 = 0;

	r2 = (y2 - TCB->wy1 + TCB->char_height) / TCB->char_height;
	r2 = MAX (r2, 0);
	r2 = MIN (r2, TCB->displayed_rows);

/*	c2 = (x2 - TCB->wx1 + TCB->cell_width) / TCB->cell_width;
	c2 = MAX (c2, 0);
	c2 = MIN (c2, TCB->col_width);
*/
	c2 = TCB->col_width;

	/* Make columns values even so double-high chars can be drawn */
	c1 &= ~1;
	c2 = (c2 + 1) & ~1;

	*row = r1;
	*column = c1;
	*rows = r2 - r1;
	*columns = c2 - c1;

	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMCalcMatrixBounds				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMCalcMatrixBounds (TCB, row, rows, column, columns,	*/
/*				   x1, y1, x2, y2)			*/
/*									*/
/*	  EM_TCB	*TCB;		 -- terminal control block ptr	*/
/*	  int		row, rows,	 -- character matrix		*/
/*			column, columns;				*/
/*	  int		*x1, *y1,	 -- the rectangle		*/
/*			*x2, *y2;					*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function calculates the rectangle that completely	*/
/*	  encloses the specified character matrix.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMCalcMatrixBounds (TCB, row, rows, column, columns, x1, y1, x2, y2)

EM_TCB	*TCB;
int	row, rows, column, columns;
int	*x1, *y1, *x2, *y2;
{
	*x1 = TCB->wx1 + TCB->active_width * column;
	*y1 = TCB->wy1 + TCB->char_height * row;
	*x2 = *x1 + (TCB->active_width * columns) - 1;
	*y2 = *y1 + (TCB->char_height * rows) - 1;

	return (EM_NO_ERROR);
}
