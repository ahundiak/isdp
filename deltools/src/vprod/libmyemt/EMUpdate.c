#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


void	_EMPutEnv ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMUpdate					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMUpdate (TCBD, event, change_mask, x1, y1, x2, y2)	*/
/*									*/
/*	  int  TCBD;		-- TCB descriptor of the terminal	*/
/*				   instance to be updated		*/
/*									*/
/*	  int  event;		-- code describing the type of event    */
/*				   which caused the update:		*/
/*					0 => COVER_EVENT		*/
/*					1 => REFRESH_EVENT		*/
/*									*/
/*	  int  change_mask;	-- operations mask defined by the	*/
/*				   "Get_refresh_data" routine		*/
/*									*/
/*	  int  x1, y1, x2, y2	-- area that needs to be refreshed	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function updates the terminal instance's window		*/
/*	  after a refresh or cover event has occurred.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  Non-zero iff the event is invalid.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int EMUpdate (TCBD, event, change_mask, x1, y1, x2, y2)

int	TCBD;
int	event;
int	change_mask;
int	x1, y1, x2, y2;
{
	int	return_code;
	EM_TCB	*TCB;			/* pointer to the TCB */


	/* Point to the TCB for this instance. */
	TCB = EM_TCB_list[TCBD];

	switch (event)
	{
	    case 0:
		/* Cover events are ignored */
		break;

	    case 1:
		return_code = _EMServiceRefreshEvent (TCB, change_mask,
						      x1, y1, x2, y2);
		break;

	    default:
		return_code = EM_INVALID_EVENT;
		break;
	}

	/* Return to caller. */
	return (return_code);	  
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMServiceRefreshEvent				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMServiceRefreshEvent (TCB, change_mask)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to the TCB			*/
/*	  int	change_mask;	-- "Get_refresh_data" operations mask   */
/*	  int	x1, y1, x2, y2	-- refresh area				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function updates the scrolling flags as needed and	*/
/*	  redisplays the terminal window if necessary.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMServiceRefreshEvent (TCB, change_mask, rx1, ry1, rx2, ry2)

EM_TCB	*TCB;
int	change_mask;
int	rx1, ry1, rx2, ry2;
{
	int	x1, y1, x2, y2;		/* coordinates of window after  */
					/*  the event			*/
	int	vs_no;			/* virtual screen number	*/
	int	row, rows, column, columns;
	unsigned int vsflags;
	int lastScreenNumber;

	/* If the window changed virtual screens, update   */
	/* the virtual screen field of the state table.    */
	if (wn_changed_vs (change_mask))
	{
	    lastScreenNumber = TCB->state_table.screen_number;
	    Inq_win_vs (TCB->window, &vs_no);
	    _EMSetScreenNumber (&TCB->state_table, vs_no);
	    if(( (vsflags = _EMScreenInfo[vs_no].vsi_flags) ^
		_EMScreenInfo[lastScreenNumber].vsi_flags)
	       & VSI_VLT_FIXED)
	    {
		/* If one screen has fixed colors and the other does not */
		EMSetColorSettings (TCB->TCBD, TCB->state_table.color_mode,
			    TCB->state_table.color_table);
 	    }

	    if (_EMGetColorMode (&TCB->state_table) != BILEVEL)
	    {
		/* Set the VLT of the new virtual screen. */
		_EMColorTableToVLT (&TCB->state_table);
		_EMLoadRGBVLT (_EMGetScreenNumber (&TCB->state_table));
	    }
	}


	/* If the window changed size, update the window	*/
	/* coordinates and shift the rows of the screen so	*/
	/* that the current line is visible.			*/
	/* NOTE:  EMSetSize() should be used in most		*/
	/*	  cases instead of this feature.  If so, then	*/
	/*	  don't pass WN_CHANGED_SIZE in to this routine.*/

	if (wn_changed_size (change_mask))
	{
	    Inq_win_region (TCB->window, &x1, &y1, &x2, &y2);	
	    EMSetWinSize (TCB->TCBD, 0, 0, x2 - x1, y2 - y1);
	}


	rx1 = MAX (rx1, TCB->x1);
	ry1 = MAX (ry1, TCB->y1);
	rx2 = MIN (rx2, TCB->x2);
	ry2 = MIN (ry2, TCB->y2);

	if ((rx1 <= rx2) && (ry1 <= ry2))
	{
	    _EMGetRectChars (TCB, rx1, ry1, rx2, ry2,
			     &row, &rows, &column, &columns);
	    _EMSetClipBox (TCB, rx1, ry1, rx2, ry2);

	    _EMGraphicsNormal (TCB);
	    hidecursor (TCB->window);
	    _EMClearScreen (TCB);
	    _EMDisplayScreen (TCB, row, rows, column, columns, FALSE);
	    _EMDrawCursor (TCB);
	    showcursor (TCB->window);
	    flushbuffer (TCB->window);

	    _EMRestoreClipBox (TCB);
	}

	return (EM_NO_ERROR);
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetWinSize					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetWinSize (TCBD, x1, y1, x2, y2)			*/
/*									*/
/*	  int  TCBD;		-- TCB descriptor of the terminal	*/
/*				   instance to be updated		*/
/*									*/
/*	  int  x1, y1, x2, y2;	-- new size of terminal instance	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the size of the terminal instance.  This	*/
/*	  is not necessarily the size of the window.  No update is	*/
/*	  done.								*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMSetWinSize (TCBD, x1, y1, x2, y2)

int	TCBD;
int	x1, y1, x2, y2;
{
	int		i, j, oldRows, diff;
	EM_TCB		*TCB;
	EMscreen_row	*newScreen;

	TCB = EM_TCB_list[TCBD];

	/* Update the window coordinates. */
	TCB->x1 = x1;
	TCB->y1 = y1;
	TCB->x2 = x2;
	TCB->y2 = y2;

	TCB->wy2 = y2 - XBORDER;

	/* Calculate the number of displayable rows. */
	oldRows = TCB->displayed_rows;
	TCB->displayed_rows = (TCB->wy2  - TCB->wy1 + 1) / TCB->char_height;
	TCB->displayed_rows = MAX (TCB->displayed_rows, 1);
	TCB->displayed_rows = MIN (TCB->displayed_rows, VTROW);

	TCB->wy2 = TCB->wy1 + TCB->displayed_rows * TCB->char_height - 1;

	if (TCB->displayed_rows < oldRows)
	{
	    TCB->start_sel = TCB->end_sel = 0;	/* clear selection */

	    newScreen = (EMscreen_row *) malloc (TCB->displayed_rows *
						 sizeof (EMscreen_row));

	    /* Copy the last rows into the lowest row data */
	    diff = MAX (TCB->current_line - TCB->displayed_rows + 1, 0);
	    for (i = 0; i < TCB->displayed_rows; i++)
	    {
		memcpy (&newScreen[i], &TCB->screen[TCB->row_order[i + diff]],
			sizeof (EMscreen_row));
	    }

	    for (i = 0; i < TCB->displayed_rows; i++)
		TCB->row_order[i] = i;

	    free (TCB->screen);
	    TCB->screen = newScreen;

	    TCB->current_line -= diff;
	}
	else
	{
	    /* Reallocate the screen */
	    TCB->screen = (EMscreen_row *) realloc (TCB->screen,
				TCB->displayed_rows * sizeof (EMscreen_row));

	    /* Initialize the new rows */
	    _EMInitRows (TCB, oldRows, TCB->displayed_rows - oldRows);
	}

	_EMUpdateScrollVars (TCB, 0, TCB->displayed_rows - 1);

	/* Move to the current position. */
	TCB->in_region = TRUE;
	_EMUpdatePosAbsolute (TCB, TCB->current_line, TCB->current_col);

	/* Change the value of the buffer screens variable */
	TCB->term_settings.bufScreens = TCB->buf_lines / TCB->displayed_rows;

	_EMPutEnv (TCB);

	return (EM_NO_ERROR);
}





/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMPutEnv					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMPutEnv (TCB)						*/
/*									*/
/*	  EM_TCB  *TCB;		   -- pointer to the TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This routine takes care of updating all pertinent environment	*/
/*	  variables for the TCB.					*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMPutEnv (TCB)

EM_TCB	*TCB;
{
    static char	envLines[20];

    sprintf (envLines, "LINES=%d", TCB->displayed_rows);
    putenv (envLines);

    if (TCB->term_settings.vt200)
	putenv ("TERM=vt220");
    else
	putenv ("TERM=vt100");
}
