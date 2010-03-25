#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"


void	_EMUpdatePosAbsolute ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMUpdatePosition				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMUpdatePosition (TCB, new_row, new_col)		*/
/*									*/
/*	  EM_TCB  *TCB;		-- TCB of active terminal instance	*/
/*	  int	  new_row 	-- pointer into the "row_order" array	*/
/*				     to the new row position		*/
/*	  int	  new_col	-- new column position			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function updates the current position.  If the new 	*/
/*	  position is outside the defined scroll region (or screen), 	*/
/*	  the display is scrolled appropriately.			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMUpdatePosition (TCB, new_row, new_col)

EM_TCB	*TCB;
int	new_row, new_col;
{
	/* Check if the new row position is beneath the scroll region. */
	if ((new_row > TCB->bot_scroll) && (TCB->in_region))
	{
	    _EMScrollUp (TCB); 
	    new_row = TCB->bot_scroll;
	}
	else
	{
	    /* Check if the new row position is above the scroll region */
	    if ((new_row < TCB->top_scroll) && (TCB->in_region))
	    {
		_EMScrollDown (TCB);
		new_row = TCB->top_scroll;
	    }
	}

	_EMUpdatePosAbsolute (TCB, new_row, new_col);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMUpdatePosRestricted				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMUpdatePosRestricted (TCB, new_row, new_col)		*/
/*									*/
/*	  EM_TCB  *TCB;		-- TCB of active terminal instance	*/
/*	  int	  new_row 	-- pointer into the "row_order" array	*/
/*				     to the new row position		*/
/*	  int	  new_col	-- new column position			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function updates the current position.  If the cursor	*/
/*	  is inside the scrolling region, it cannot move out of the	*/
/*	  region.  Otherwise, the cursor is free to move anywhere in	*/
/*	  the screen matrix.						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMUpdatePosRestricted (TCB, new_row, new_col)

EM_TCB	*TCB;
int	new_row, new_col;
{
	if (TCB->in_region)
	{
	    if (new_row > TCB->bot_scroll)
		new_row = TCB->bot_scroll;
	    else if (new_row < TCB->top_scroll)
		new_row = TCB->top_scroll;
	}

	_EMUpdatePosAbsolute (TCB, new_row, new_col);
}	



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMUpdatePosAbsolute				*/
/*								 	*/
/*	SYNOPSIS:							*/
/*	  void _EMUpdatePosAbsolute (TCB, new_row, new_col)		*/
/*									*/
/*	  EM_TCB  *TCB;		-- TCB of active terminal instance	*/
/*	  int	  new_row 	-- pointer into the "row_order" array	*/
/*				     to the new row position		*/
/*	  int	  new_col	-- new column position			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function updates the current position.  The cursor	*/
/*	  is moved to the absolute (row, column) position specified.	*/
/*	  No scrolling occurs.						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMUpdatePosAbsolute (TCB, new_row, new_col)

EM_TCB	*TCB;
int	new_row, new_col;
{
	int	line_length;		/* line length of current row	*/


	/* Ensure that the specified position lies within the screen matrix. */
	if (new_row < 0)
	    new_row = 0;

	if (new_row >= TCB->displayed_rows)
	    new_row = TCB->displayed_rows - 1;

	/* Update scrolling and screen matrix variables. */
	TCB->current_row = &TCB->screen[TCB->row_order[new_row]];

	if (TCB->current_row->font_table > DHSWBOT_OFFSET)
	    line_length = TCB->col_width / 2;
	else
	    line_length = TCB->col_width;

	if (new_col >= line_length)
	    new_col = line_length - 1;

	if (new_col < 0)
	    new_col = 0;

	TCB->current_line = new_row;
	TCB->current_col = new_col;

	if ((new_row >= TCB->top_scroll) && (new_row <= TCB->bot_scroll))
	    TCB->in_region = TRUE;
	else
	    TCB->in_region = FALSE;
}	
