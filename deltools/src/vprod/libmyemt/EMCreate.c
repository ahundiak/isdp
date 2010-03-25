#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


EM_TCB	*EM_TCB_list[NUMBER_OF_SLOTS] = { NULL };

static int	globals_uninitialized = TRUE;


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMCreateTerm					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMCreateTerm (TCBD, window, font, setup, color,		*/
/*			    col_flag, x1, y1, x2, y2, buf_scr)		*/
/*									*/
/*	  int	*TCBD;	  -- returned terminal control block descriptor */
/*			     to be used in all future calls to emulator */
/*			     routines					*/
/*									*/
/*	  int	window;	  -- number of the window to be associated 	*/
/*			     with the terminal instance			*/
/*									*/
/*	  char	*font;	  -- full pathname of the font to be used	*/
/*									*/
/*	  int	setup;	  -- F => no "setup" capability desired		*/
/*			     T => ability to change terminal attributes */
/*				  via "setup" desired			*/
/*									*/
/*	  int	color;	  -- F => color capability is not desired	*/
/*			     T => color capability is desired		*/
/*									*/
/*	  int	col_flag; -- 0 => 80 column terminal			*/
/*			     1 => 132 column terminal			*/
/*			    -1 => calculate it from x1, x2 (kludge)	*/
/*									*/
/*	  int	x1, y1,							*/
/*		x2, y2;   -- size and position of terminal instance	*/
/*			     within the window				*/
/*									*/
/*	  int	buf_scr;  -- number of buffered screens saved as text	*/
/*			     is scrolled off top			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function creates a terminal instance.  It searches the	*/
/*	  TCB list for a free slot and allocates and initializes a 	*/
/*	  TCB if one is found.  A TCB descriptor for the TCB is		*/
/*	  returned.  Unlike EMCreate(), the terminal instance		*/
/*	  need not occupy the entire window.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If the terminal instance is successfully created, a zero      */
/*	  value is returned.  A non-zero error value is returned if 	*/
/*	  any of the following conditions are true:			*/
/*									*/
/*		1.  the TCB list is full				*/
/*		2.  memory cannot be allocated for a new TCB		*/
/*		3.  an error occurs during TCB initialization		*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMCreateTerm (TCBD, window, font, setup, color, col_flag,
		  x1, y1, x2, y2, buf_scr)

int	*TCBD;
int	window;
char	*font;
int	setup;
int	color;
int	col_flag;
int	x1, y1, x2, y2;
int	buf_scr;
{
	int	not_found;	/* TRUE  => free TCB slot not found	*/
				/* FALSE => free TCB slot found		*/
	int	free_slot;	/* index of current slot in TCB list	*/
	EM_TCB	*TCB;		/* pointer to newly allocated TCB	*/
	int	return_code;	/* status code returned to caller	*/


	/*--------------------------------------------------------------*/
	/*  Initialize global variables if they are uninitialized.	*/
	/*--------------------------------------------------------------*/
	if (globals_uninitialized)
	{
	    return_code = _EMInitGlobals ();

	    if ((return_code == EM_NO_ERROR) && setup)
	    {
		return_code = _EMCreateMenus ();
		globals_uninitialized = FALSE;
	    }
	}
	else
	    return_code = EM_NO_ERROR;

	if (return_code == EM_NO_ERROR)
	{
	    /*----------------------------------------------------------*/
	    /*  Find the next free slot in the TCB list			*/
	    /*----------------------------------------------------------*/
	    not_found = TRUE;
	    free_slot = 0;

	    while ((not_found) && (free_slot < NUMBER_OF_SLOTS))
	    {
		if (EM_TCB_list[free_slot] == NULL)
		    not_found = FALSE;
		else
		    free_slot++;
	    }


	    /* If a free slot was found, allocate memory for the new TCB. */
	    if (!not_found && (free_slot < NUMBER_OF_SLOTS))
	    {
		/*------------------------------------------------------*/
		/*  Allocate memory for the new TCB.			*/
		/*------------------------------------------------------*/
		TCB = (EM_TCB *) malloc ((unsigned) sizeof (EM_TCB));

		if (TCB != NULL)
		{
		    /*------------------------------------------*/
		    /*  Add an entry in the TCB list and set	*/
		    /*  the caller's TCB descriptor for return. */
		    /*------------------------------------------*/
		    EM_TCB_list[free_slot] = TCB;
		    TCB->TCBD = free_slot;
		    *TCBD = TCB->TCBD;

		    /*--------------------------------------------------*/
		    /*  Initialize the TCB.				*/
		    /*--------------------------------------------------*/
		    return_code = _EMInitTCB (TCB, window, font, 
					      setup, color, col_flag,
					      x1, y1, x2, y2, buf_scr);

		    if (return_code == 0)
		    {
			/*----------------------------------------------*/
			/* 	Clear the screen and place the cursor	*/
			/* 	in the upper-left hand corner.		*/
			/*----------------------------------------------*/
			_EMClearScreenMatrix (TCB);
			_EMSetClipBox (TCB, 0, 0, -1, -1);
			_EMGraphicsNormal (TCB);
			hidecursor (TCB->window);
			_EMClearScreen (TCB);
			_EMUpdatePosAbsolute (TCB, 0, 0);
			_EMDrawCursor (TCB);
			showcursor (TCB->window);
			flushbuffer (TCB->window);
			_EMRestoreClipBox (TCB);
		    }
		    else
		    {
			EM_TCB_list[free_slot] = NULL;
			free (TCB);
		    }
		}
		else
		    /* The attempt to allocate memory for a TCB failed. */
		    return_code = EM_MALLOC_FAILED;
	    }
	    else
		/* No free slot was found; the TCB list is full. */
		return_code = EM_TCB_LIST_FULL;
	}
	else
	    /* Global variables could not be initialized. */
	    return_code = EM_GLOBAL_INIT_FAILED;

	/* Return to caller. */
	return (return_code);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMCreate					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMCreate (TCBD, window, font, setup, color)		*/
/*									*/
/*	  int	*TCBD;	  -- returned terminal control block descriptor */
/*			     to be used in all future calls to emulator */
/*			     routines					*/
/*									*/
/*	  int	window;	  -- number of the window to be associated 	*/
/*			     with the terminal instance			*/
/*									*/
/*	  char	*font;	  -- full pathname of the font to be used	*/
/*									*/
/*	  int	setup;	  -- F => no "setup" capability desired		*/
/*			     T => ability to change terminal attributes */
/*				  via "setup" desired			*/
/*									*/
/*	  int	color;	  -- F => color capability is not desired	*/
/*			     T => color capability is desired		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function creates a terminal instance.  It searches the	*/
/*	  TCB list for a free slot and allocates and initializes a 	*/
/*	  TCB if one is found.  A TCB descriptor for the TCB is		*/
/*	  returned.							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If the terminal instance is successfully created, a zero      */
/*	  value is returned.  A non-zero error value is returned if 	*/
/*	  any of the following conditions are true:			*/
/*									*/
/*		1.  the TCB list is full				*/
/*		2.  memory cannot be allocated for a new TCB		*/
/*		3.  an error occurs during TCB initialization		*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMCreate (TCBD, window, font, setup, color)
     
int	*TCBD;
int	window;
char	*font;
int	setup;
int	color;
{
	int x1, y1, x2, y2;	/* size of window */


	Inq_win_region (window, &x1, &y1, &x2, &y2);

	return (EMCreateTerm (TCBD, window, font, setup, color, -1,
			      0, 0, x2 - x1, y2 - y1, 0));
}
