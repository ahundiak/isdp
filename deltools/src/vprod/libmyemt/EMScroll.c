#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"



void	_EMScroll ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMScrollUp					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMScrollUp (TCBD)						*/
/*									*/
/*	  int	TCBD;		-- terminal instance			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function moves the buffer display window down one row	*/
/*	  (i.e., scrolls the buffer up).  This should be called only	*/
/*	  when the user wishes to scroll back into the scroll buffer.	*/
/*	  No data from the host is allowed until it is scrolled back	*/
/*	  down to the primary portion of the scroll buffer.		*/
/*									*/
/*	RETURNED VALUE:	 zero						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMScrollUp (TCBD)

int	TCBD;
{
	return (EMMoveScroll (TCBD, EM_TCB_list[TCBD]->buf_win + 1));
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMScrollDown					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMScrollDown (TCBD)					*/
/*									*/
/*	  int	TCBD;		-- terminal instance			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function moves the buffer display window up one row	*/
/*	  (i.e., scrolls the buffer down).  This should be called only	*/
/*	  when the user wishes to scroll back into the scroll buffer.	*/
/*	  No data from the host is allowed until it is scrolled back	*/
/*	  down to the primary portion of the scroll buffer.		*/
/*									*/
/*	RETURNED VALUE:	 zero						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMScrollDown (TCBD)

int	TCBD;
{
	return (EMMoveScroll (TCBD, EM_TCB_list[TCBD]->buf_win - 1));
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMMoveScroll					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMMoveScroll (TCBD, new_row)				*/
/*									*/
/*	  int	TCBD;		-- terminal instance			*/
/*	  int	new_row;	-- which row to scroll to		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function moves the window of the scroll buffer		*/
/*	  to the specified row.						*/
/*	  This should be called only when the user wishes to		*/
/*	  scroll in the saved scroll buffer.				*/
/*	  No data from the host should be allowed until it is scrolled	*/
/*	  back down to the primary portion of the scroll buffer.	*/
/*									*/
/*	RETURNED VALUE:  non-zero iff new_row is out of range		*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMMoveScroll (TCBD, new_row)

int	TCBD;
int	new_row;
{
	int	col;			/* column index			*/
	int	row;			/* pointer into row order array */
	int	num_rows;		/* displayed rows		*/
	int	row_index;		/* row_order value		*/
	int	buf_row;		/* scroll buffer row index	*/
	int	old_row_order[VTROW];	/* place to save row_order	*/
	int	diff;			/* diff. between old & new pos	*/
	int	offset;			/* offset for moving row_order	*/
	EM_TCB	*TCB;

	TCB = EM_TCB_list[TCBD];

	new_row = MAX (new_row, 0);
	new_row = MIN (new_row, TCB->buf_lines);
	if (new_row == TCB->buf_win)
	    return (EM_NO_ERROR);

	_EMGraphicsNormal (TCB);
	num_rows = TCB->displayed_rows;	
	diff = TCB->buf_win - new_row;

	/* save attributes of primary portion of screen buffer if	*/
	/* just starting to scroll back					*/
	if (! TCB->scrolled_back)
	{
	    TCB->save_screen = (EMscreen_row *) malloc (num_rows *
							sizeof (EMscreen_row));
	    memcpy (TCB->save_screen, TCB->screen,
		    sizeof (EMscreen_row) * num_rows);
	}

	/* save the contents of the row_order array */
	for (row = 0; row < num_rows; row++)
	    old_row_order[row] = TCB->row_order[row];

	/* modify the row_order array to stay in sync with scrolling */
	offset = _EMMod (diff, num_rows);
	TCB->buf_win = new_row;
	for (row = 0; row < num_rows; row++)
	    TCB->row_order[_EMMod (row + offset, num_rows)] =
							old_row_order[row];

	/* fill the screen matrix */
	for (row = 0; row < num_rows; row++)
	{
	    row_index = TCB->row_order[row];
	    buf_row = _EMMod (TCB->bot_buf + new_row + row, TCB->buf_lines);

	    if (new_row + row >= TCB->buf_lines)
	    {
		memcpy (&TCB->screen[row_index],
			&TCB->save_screen[row_index],
			sizeof (EMscreen_row));
	    }
	    else
	    {
		for (col = 0; col < VTCOL; col++)
		    TCB->screen[row_index].character[col] =
					TCB->scroll_buf[buf_row * VTCOL + col];

		/* Set default attributes for the chars on the row */
		TCB->screen[row_index].all_chars_norm = TRUE;
		TCB->screen[row_index].font_table = NORMAL_OFFSET;
	    }
	}

	hidecursor (TCB->window);

	_EMScroll (TCB, TCB->wx1, TCB->wy1, TCB->wx2, TCB->wy2,
		   0, diff * TCB->char_height);

	if (new_row != TCB->buf_lines)
	{
	    TCB->scrolled_back = TRUE;
	    _EMEraseCursor (TCB);
	}
	else
	{
	    free (TCB->save_screen);
	    TCB->save_screen = NULL;

	    TCB->scrolled_back = FALSE;
	    _EMDrawCursor (TCB);
	}

	showcursor (TCB->window);
	flushbuffer (TCB->window);

	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetBufferSize					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetBufferSize (TCBD)					*/
/*									*/
/*	  int	TCBD;		-- terminal instance			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the current scroll buffer size of the	*/
/*	  specified terminal instance.					*/
/*									*/
/*	RETURNED VALUE:	 scroll buffer size				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetBufferSize (TCBD)

int	TCBD;
{
	return (EM_TCB_list[TCBD]->buf_lines);
}






/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetBufferPos					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetBufferPos (TCBD)					*/
/*									*/
/*	  int	TCBD;		-- terminal instance			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the current scroll position of the	*/
/*	  specified terminal instance.					*/
/*									*/
/*	RETURNED VALUE:	 position of window in scroll buffer		*/
/*	  range: 0 to bufsize						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetBufferPos (TCBD)

int	TCBD;
{
	return (EM_TCB_list[TCBD]->buf_win);
}






/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetBufferSize				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMSetBufferSize (TCB, screens)				*/
/*									*/
/*	  int	TCB;		-- pointer to terminal instance		*/
/*	  int	screens;	-- number of buffered screens		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the scroll buffer size (number of screens)	*/
/*	  to the specified value.  The scroll buffer is reallocated	*/
/*	  accordingly.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMSetBufferSize (TCB, screens)

EM_TCB	*TCB;
int	screens;
{
    int size;			/* new character size of scroll buffer	*/
    char *new_buf;		/* new scroll buffer			*/
    char *ptr1, *ptr2, *mark;	/* used for copying old buffer into new	*/


    if (TCB->term_settings.bufScreens != screens)
    {
	_EMClearSelection (TCB->TCBD);	/* clear text selection */

	size = screens * TCB->displayed_rows * VTCOL;	/* new buffer size */

	if (screens)
	{
	    new_buf = (char *) malloc (size);	/* create new buffer */

	    if (new_buf == NULL)	/* did malloc fail? */
	    {
		return (EM_G_MENU_ERROR);
	    }
	    else	/* initialize the buffer and its variables */
	    {
		memset (new_buf, SPACE, size);

		if (TCB->term_settings.bufScreens)	/* did buffer exist? */
		{
		    EMMoveScroll (TCB->TCBD, TCB->buf_lines);

		    /* copy backward into new buffer */
		    ptr1 = new_buf + size - 1;
		    mark = &TCB->scroll_buf[TCB->bot_buf * VTCOL];
		    ptr2 = mark - 1;
		    while ((ptr1 >= new_buf) && (ptr2 >= TCB->scroll_buf))
		    {
			*ptr1 = *ptr2;
			ptr1--;
			ptr2--;
		    }

		    ptr2 = &TCB->scroll_buf[TCB->buf_lines * VTCOL] - 1;
		    while ((ptr1 >= new_buf) && (ptr2 >= mark))
		    {
			*ptr1 = *ptr2;
			ptr1--;
			ptr2--;
		    }

		    free (TCB->scroll_buf);
		}

		TCB->bot_buf = 0;
		TCB->scroll_buf = new_buf;
		TCB->buf_win = TCB->buf_lines = size / VTCOL;
		TCB->scrolled_back = FALSE;
	    }
	}
	else if (TCB->term_settings.bufScreens)	/* did buffer exist? */
	{
	    EMMoveScroll (TCB->TCBD, TCB->buf_lines);	/* unscroll it */

	    free (TCB->scroll_buf);
	    TCB->scroll_buf = 0;
	    TCB->buf_lines = 0;
	    TCB->buf_win = 0;
	}

	TCB->term_settings.bufScreens = screens;	
    }
    
    return (EM_NO_ERROR);
}
