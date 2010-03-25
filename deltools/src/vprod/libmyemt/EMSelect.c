#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMConvertSelection				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMConvertSelection (TCB, row, col)			*/
/*									*/
/*	  int	TCB;		 -- Terminal Control Block pointer	*/
/*	  int	row, col;	 -- cell to convert			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  Buffer index.							*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function converts the specified character cell to the	*/
/*	  corresponding scroll buffer index.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMConvertSelection (TCB, row, col)

EM_TCB	*TCB;
int	row, col;
{
    return ((TCB->buf_win + row) * VTCOL + col);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetSelectionRange				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMGetSelectionRange (TCB, row1, col1, row2, col2)	*/
/*									*/
/*	  int	TCB;		 -- Terminal Control Block pointer	*/
/*	  int	*row1, *col1;	 -- starting cell of text selection	*/
/*	  int	*row2, *col2;	 -- ending cell of text selection	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  TRUE if a text selection exists; FALSE otherwise.		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the row/col range of the current text	*/
/*	  selection, whether or not it is in the window.		*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMGetSelectionRange (TCB, row1, col1, row2, col2)

EM_TCB	*TCB;
int	*row1, *col1, *row2, *col2;
{
    if (TCB->start_sel >= TCB->end_sel)
    {
	*row1 = *row2 = *col1 = *col2 = 0;
	return (FALSE);
    }
    else
    {
	*row1 = TCB->start_sel / VTCOL;
	*row2 = TCB->end_sel / VTCOL;
	*col1 = TCB->start_sel % VTCOL;
	*col2 = TCB->end_sel % VTCOL;
    }
    return (TRUE);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetWinSelectionRange				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMGetWinSelectionRange (TCB, row1, col1, row2, col2)	*/
/*									*/
/*	  int	TCB;		 -- Terminal Control Block pointer	*/
/*	  int	*row1, *col1;	 -- starting cell of text selection	*/
/*	  int	*row2, *col2;	 -- ending cell of text selection	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  TRUE if a text selection is visible in the window;		*/
/*	  FALSE otherwise.						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the row/col range of the current text	*/
/*	  selection that is visible in the window.			*/
/*	  NOTE:  A return value of FALSE does not mean that a text	*/
/*	  selection is not current made, but only that it is not	*/
/*	  visible in the window.					*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMGetWinSelectionRange (TCB, row1, col1, row2, col2)

EM_TCB	*TCB;
int	*row1, *col1, *row2, *col2;
{
    if (_EMGetSelectionRange (TCB, row1, col1, row2, col2))
    {
	(*row1) -= TCB->buf_win;
	(*row2) -= TCB->buf_win;

	if (*row1 < 0)
	{
	    *row1 = 0;
	    *col1 = 0;
	}
	if (*row2 >= TCB->displayed_rows)
	{
	    *row2 = TCB->displayed_rows;
	    *col2 = 0;
	}

	if ((*row1 < *row2) || ((*row1 == *row2) && (*col1 < *col2)))
	    return (TRUE);
    }

    return (FALSE);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMHiliteText					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMHiliteText (TCB, row1, col1, row2, col2)		*/
/*									*/
/*	  int	TCB;		 -- Terminal Control Block pointer	*/
/*	  int	row1, col1;	 -- starting cell to be hilited		*/
/*	  int	row2, col2;	 -- ending cell to be hilited		*/
/*									*/
/*	RETURNED VALUE:							*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function hilites the specified range of characters.	*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMHiliteText (TCB, row1, col1, row2, col2)

EM_TCB	*TCB;
int	row1, col1, row2, col2;
{
    int	end_col;
    int	x1, y1, x2, y2;

    while (row1 <= row2)
    {
	end_col = (row1 == row2) ? MIN (col2, TCB->col_width) : TCB->col_width;

	_EMCalcMatrixBounds (TCB, row1, 1, col1, end_col - col1,
			     &x1, &y1, &x2, &y2);
	if (x1 < x2)
	{
	    int	colorMode;

	    /* If BILEVEL, must enable planes so black & white swap */
	    colorMode = _EMGetColorMode (&TCB->state_table);
	    if (colorMode == BILEVEL)
	    {
		enableplane (TCB->window,
			     TCB->background_color ^ TCB->foreground_color);
	    }
	    else	/* otherwise, use all 8 planes */
		enableplane (TCB->window, 0xFF);

	    flipblock (TCB->window, x1, y1, x2, y2);

	    enableplane (TCB->window, 0xFFFF);
	}

	row1++;
	col1 = 0;
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDrawTextHilite				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMDrawTextHilite (TCB, rowA, colA, rowB, colB, matrix)	*/
/*									*/
/*	  int	TCB;		 -- Terminal Control Block pointer	*/
/*	  int	rowA, colA;	 -- starting cell to be hilited		*/
/*	  int	rowB, colB;	 -- ending cell to be hilited		*/
/*	  int	matrix;		 -- T => do rectangular matrix		*/
/*				    F => do range of char cells		*/
/*									*/
/*	RETURNED VALUE:							*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function updates the current hilited characters within	*/
/*	  the given range of character cells.  If the matrix flag is	*/
/*	  false, treat as a range of cells; otherwise, treat as a	*/
/*	  rectangular matrix of cells (used by _EMDisplayScreen()).	*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMDrawTextHilite (TCB, rowA, colA, rowB, colB, matrix)

EM_TCB	*TCB;
int	rowA, colA, rowB, colB;
int	matrix;
{
    int	row1, col1, row2, col2;
    int	rowl, coll, rowh, colh;

    if ((rowA < rowB) || ((rowA == rowB) && (colA < colB)))
    {
	coll = colA;
	rowl = rowA;
	colh = colB;
	rowh = rowB;
    }
    else
    {
	coll = colB;
	rowl = rowB;
	colh = colA;
	rowh = rowA;
    }

    if (_EMGetWinSelectionRange (TCB, &row1, &col1, &row2, &col2))
    {
	if (rowl > row1)
	    col1 = coll;
	else if (rowl == row1)
	    col1 = MAX (col1, coll);

	if (rowh < row2)
	    col2 = colh;
	else if (rowh == row2)
	    col2 = MIN (col2, colh);

	row1 = MAX (row1, rowl);
	row2 = MIN (row2, rowh);

	if (matrix)
	    _EMHiliteText (TCB, row1, col1, row2, col2);
	else
	{
	    int	end_col;

	    while (row1 <= row2)
	    {
		end_col = (row1 == row2) ? col2 : colh;

		_EMHiliteText (TCB, row1, col1, row1, end_col);

		row1++;
		col1 = coll;
	    }
	}
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMTextSelect					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMTextSelect (TCBD, button, x, y, proc)			*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*	  int	button;		 -- mouse button pressed		*/
/*	  int	x, y;		 -- initial position of mouse		*/
/*	  void	(*proc)();	 -- procedure to execute while button	*/
/*				    is held down			*/
/*									*/
/*	RETURNED VALUE:	zero						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function controls the selection of text in the terminal	*/
/*	  instance's window until the mouse button is released.	 It is	*/
/*	  assumed that the mouse button is initially pressed.  As long	*/
/*	  as the button is pressed, the specified function is called	*/
/*	  whenever the text selection changes.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMTextSelect (TCBD, button, x, y, proc)

int	TCBD;
int	button;
int	x, y;
void	(*proc)();
{
    int		nx, ny;		/* next position of mouse		*/
    int		down;		/* TRUE while button is down		*/
    int		wno;		/* window number where button goes UP	*/
    int		event_button;	/* button number of button event	*/
    int		trans;		/* button transition			*/
    int		tmp;		/* scratch int				*/
    int		wflag;		/* TRUE iff mouse position is in	*/
				/*   working area			*/
    int		num_cols;	/* total number of columns		*/
    int		num_rows;	/* total number of rows			*/
    int		row, col;	/* current character cell		*/
    int		lastRow,
		lastCol;	/* last character cell			*/
    int		first, sel,
		lastSel;	/* text selection points		*/
    int		amount;
    int		lastBufWin;
    long	events;		/* event mask				*/
    EM_TCB	*TCB;		/* Terminal Control Block pointer	*/


    TCB = EM_TCB_list[TCBD];

    if ((x < TCB->x1) || (x > TCB->x2) || (y < TCB->y1) || (y > TCB->y2))
	return (EM_NO_ERROR);

    _EMSetClipBox (TCB, 0, 0, -1, -1);
    _EMGraphicsNormal (TCB);

    num_cols = TCB->col_width;
    num_rows = TCB->displayed_rows;

    _EMFindPosition (TCB, x, y, &row, &col);
    if (row < 0)
	row = col = 0;
    else if (row >= num_rows)
    {
	row = num_rows - 1;
	col = num_cols;
    }

    lastRow = row;
    lastCol = col;
    first = sel = lastSel = _EMConvertSelection (TCB, row, col);

    down = TRUE;
    while (down)
    {
	lastBufWin = TCB->buf_win;
	if (row < 0)		/* off the top? */
	{
	    amount = (row - 1) / 2;
	    row = 0;
	    if (TCB->buf_win > 0)
		EMMoveScroll (TCB->TCBD, TCB->buf_win + amount);
	}
	else if (row >= num_rows)	/* off the bottom? */
	{
	    amount = (row - num_rows) / 2 + 1;
	    row = num_rows - 1;
	    if (TCB->scrolled_back)
		EMMoveScroll (TCB->TCBD, TCB->buf_win + amount);
	}
	lastRow -= (TCB->buf_win - lastBufWin);

	sel = _EMConvertSelection (TCB, row, col);
	if (sel != lastSel)	/* did position change? */
	{
	    /* hilite new selection/deselection */
	    TCB->start_sel = MIN (sel, first);
	    TCB->end_sel = MAX (sel, first);

	    hidecursor (TCB->window);

	    if (sel < lastSel)
		_EMHiliteText (TCB, row, col, lastRow, lastCol);
	    else
		_EMHiliteText (TCB, lastRow, lastCol, row, col);

	    showcursor (TCB->window);

	    lastCol = col;
	    lastRow = row;
	    lastSel = sel;

	    if (proc != NULL)
		(*proc)();

	    /* Graphics attributes may have changed */
	    _EMResetClipBox (TCB);
	    _EMGraphicsNormal (TCB);

	    flushbuffer (TCB->window);
	}

	Inq_events (&events);
	if (events & BUTTON_EVENT)
	{
	    Get_button_data (&wno, &nx, &ny, &event_button, &trans, &tmp);
	    down = !((event_button == button) &&
		     ((trans == UP) || (trans == UP_DOWN_UP)));
	}
	else
	{
	    Mouseposition (TCB->window, &x, &y, &wflag);
	    _EMFindPosition (TCB, x, y, &row, &col);
	}
    }

    flushbuffer (TCB->window);
    _EMRestoreClipBox (TCB);

    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMFindPosition					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMFindPosition (TCB, x, y, row, col)			*/
/*									*/
/*	  EM_TCB	*TCB;		-- the terminal instance	*/
/*	  int		x, y;		-- mouse position		*/
/*	  int		*row, *col;	-- row & column			*/
/*									*/
/*	RETURNED VALUE:							*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function finds the row & column that the specified	*/
/*	  mouse position lies on.					*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMFindPosition (TCB, x, y, row, col)

EM_TCB	*TCB;
int	x, y;
int	*row, *col;
{
    *col = (x - TCB->wx1 + TCB->cell_width/2) / TCB->cell_width;
    *row = (y - TCB->wy1) / TCB->char_height;

    /* Due to the incorrectness of the integer division...	*/
    if (y - TCB->wy1 < 0)
	(*row)--;	/* this isn't quite correct, but good enough */

    if ((*row < 0) && (TCB->buf_win == 0))
	*col = 0;
    else if ((*row >= TCB->displayed_rows) && !TCB->scrolled_back)
	*col = TCB->col_width;
    else
    {
	*col = MIN (TCB->col_width, *col);
	*col = MAX (0, *col);
    }
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMClearSelection				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMClearSelection (TCBD)					*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function clears the current text selection without	*/
/*	  hiding the cursor and setting the clipbox.			*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMClearSelection (TCBD)

int	TCBD;
{
    EM_TCB	*TCB;

    TCB = EM_TCB_list[TCBD];

    _EMDrawTextHilite (TCB, 0, 0, TCB->displayed_rows, 0, TRUE);
    TCB->start_sel = TCB->end_sel = 0;

    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMClearSelection				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMClearSelection (TCBD)					*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	RETURNED VALUE:							*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function clears the current text selection.		*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMClearSelection (TCBD)

int	TCBD;
{
    EM_TCB	*TCB;

    TCB = EM_TCB_list[TCBD];

    _EMSetClipBox (TCB, 0, 0, -1, -1);
    _EMGraphicsNormal (TCB);
    hidecursor (TCB->window);

    _EMClearSelection (TCBD);

    showcursor (TCB->window);
    flushbuffer (TCB->window);
    _EMRestoreClipBox (TCB);

    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetSelection					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetSelection (TCBD, buffer)				*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*	  char	**buffer;	 -- buffer of characters		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  The size of the buffer is returned.				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns a character buffer representing the	*/
/*	  currently selected text.					*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetSelection (TCBD, buffer)

int	TCBD;
char	**buffer;
{
    EM_TCB *TCB;		/* TCB pointer			*/
    int	row, col;		/* a character cell		*/
    int row1, col1, row2, col2;	/* text selection range		*/
    int	therow;			/* offset from row		*/
    int	buf_row;		/* scroll buffer row		*/
    int	end_col;		/* start of trailing spaces	*/
    int	bufindex;		/* buffer pointer		*/
    int	start;			/* start position for strncpy	*/
    EMscreen_row *row_ptr;	/* actual row pointer		*/


    TCB = EM_TCB_list[TCBD];

    bufindex = 0;
    *buffer = (char *) malloc ((TCB->buf_lines + TCB->displayed_rows) *
			       TCB->col_width);

    if (_EMGetSelectionRange (TCB, &row1, &col1, &row2, &col2))
    {
	for (row = row1; row <= row2; row++)
	{
	    if (row >= TCB->buf_lines)
	    {
		therow = row - TCB->buf_lines;

		if (TCB->scrolled_back)
		    row_ptr = &TCB->save_screen[_EMMod (TCB->row_order[therow] +
			TCB->buf_lines - TCB->buf_win, TCB->displayed_rows)];
		else
		    row_ptr = &TCB->screen[TCB->row_order[therow]];

		/* search backward for first non_space in row */
		for (end_col = TCB->col_width; end_col > 0; end_col--)
		    if (row_ptr->character[end_col - 1] != SPACE)
			break;
		if (row == row1)
		    end_col = MAX (end_col, col1);
		if (row == row2)
		    end_col = MIN (end_col, col2);

		/* copy all selected text except trailing spaces */
		for (col = ((row == row1) ? col1 : 0); col < end_col; col++)
		    (*buffer)[bufindex++] = row_ptr->character[col];
	    }
	    else
	    {
		buf_row = _EMMod (row + TCB->bot_buf, TCB->buf_lines);

		for (end_col = TCB->col_width; end_col > 0; end_col--)
		    if (TCB->scroll_buf[buf_row * VTCOL + end_col - 1] != SPACE)
			break;
		if (row == row1)
		    end_col = MAX (end_col, col1);
		if (row == row2)
		    end_col = MIN (end_col, col2);

		start = ((row == row1) ? col1 : 0);
		strncpy (&((*buffer)[bufindex]),
			 &TCB->scroll_buf[buf_row * VTCOL + start],
			 end_col - start);
		bufindex += (end_col - start);
	    }

	    if (row < row2)
		(*buffer)[bufindex++] = '\n';
	}
    }

    *buffer = (char *) realloc (*buffer, bufindex);

    return (bufindex);
}
