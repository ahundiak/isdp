#include <string.h>
#include <ctype.h>
#include <signal.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMWindowSize					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMWindowSize (rows, columns, font, height, width) 	*/
/*									*/
/*	  int	rows;		-- number of rows desired		*/
/*									*/
/*	  int   columns;	-- number of columns desired		*/
/*									*/
/*	  char  *font;		-- pathname of desired font		*/
/*									*/
/*	  int	*height		-- required height of window in pixels  */
/*									*/
/*	  int   *width;		-- required width of window in pixels	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function accepts a number of rows, a number of columns,  */
/*	  and font pathname and returns the dimensions of a window	*/
/*	  large enough to display the given number of rows and columns  */
/*	  of text with the specified font.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A non-zero value is returned if any of the following error	*/
/*	  conditions are present:					*/
/*									*/
/*		1.  a non-existent font is specified,			*/
/*		2.  the number of rows is outside the range 1..VTROW,	*/
/*		3.  the number of columns is outside the range		*/
/*		    1..VTCOL.						*/
/*									*/
/*	  Otherwise, a zero value is returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int EMWindowSize (rows, columns, font, height, width)

int	rows, columns;
char	*font;
int	*height, *width;
{
	int	font_descriptor;
	int	char_width;		/* pixel width of a character cell  */
	int	char_height;		/* pixel height of a character cell */
	int	maxWidth;
	int	baseline;
	int	return_code;		/* status code returned to caller   */
	int	status;			/* status returned by 		    */
					/*   "Load_symbol_file"		    */


	/* Load the desired font. */
	status = Load_symbol_file (font, &font_descriptor);

	if (!status)
	{
	    /* Find the height and width of a character displayed with     */
	    /* the font (" " was chosen to represent a typical character   */
	    /* and to allow for proportional fonts to be kludgily used)    */
	    Inq_font (font_descriptor, &char_height, &maxWidth, &baseline);
	    Inq_string_width (font_descriptor, " ", 1, &char_width);

	    if (char_height < 15)	/* there's always a kludge... */
		char_height++;

	    if ((char_height != 0) && (char_width != 0))
	    {
		if ((rows > 0) && (rows <= VTROW))
		{
		    if ((columns > 0) && (columns <= VTCOL))
		    {
			*height = rows * char_height + (2 * YBORDER);
			*width  = columns * char_width + (2 * XBORDER);
			return_code = EM_NO_ERROR;
		    }
		    else
			return_code = EM_COLUMN_OUT_OF_RANGE;
		}
		else
		    return_code = EM_ROW_OUT_OF_RANGE;
	    }
	    else
		return_code = EM_INVALID_FONT;
	}
	else
	    return_code = EM_INVALID_FONT;

	return (return_code);
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMClearScreen					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMClearScreen (TCBD)					*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function clears the screen of the specified terminal	*/
/*	  instance.							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMClearScreen (TCBD)

int	TCBD;
{
	EM_TCB	*TCB;

	TCB = EM_TCB_list[TCBD];

	_EMSetClipBox (TCB, 0, 0, -1, -1);
	_EMGraphicsNormal (TCB);
	hidecursor (TCB->window);
	_EMClearScreenMatrix (TCB);
	_EMClearScreen (TCB);
	_EMDisplayScreen (TCB, 0, TCB->displayed_rows, 0, TCB->col_width, TRUE);
	_EMUpdatePosAbsolute (TCB, 0, 0);
	_EMDrawCursor (TCB);
	showcursor (TCB->window);
	flushbuffer (TCB->window);
	_EMRestoreClipBox (TCB);

	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMResetTerminal					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMResetTerminal (TCBD)					*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function resets the terminal.  All setup values will	*/
/*	  take on their default values.					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMResetTerminal (TCBD)

int	TCBD;
{
	EM_TCB	*TCB;


	TCB = EM_TCB_list[TCBD];

	_EMSetClipBox (TCB, 0, 0, -1, -1);
	_EMGraphicsNormal (TCB);
	hidecursor (TCB->window);
	_EMResetTerminal (TCB);
	_EMDrawCursor (TCB);
	showcursor (TCB->window);
	flushbuffer (TCB->window);
	_EMRestoreClipBox (TCB);

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetSize					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetSize (TCBD, rows, cols)				*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*	  int	*rows;		 -- number of rows			*/
/*	  int	*cols;		 -- number of columns			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the current size of the screen matrix	*/
/*	  of the specified terminal instance.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetSize (TCBD, rows, cols)

int	TCBD;
int	*rows, *cols;
{
	EM_TCB	*TCB;


	TCB = EM_TCB_list[TCBD];

	*rows = TCB->displayed_rows;
	*cols = TCB->col_width;

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetKeyboardState				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetKeyboardState (TCBD, kbState)			*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*	  int	*kbState;	 -- current keyboard state		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the current keyboard state of the	*/
/*	  specified terminal instance.  If FALSE, no keyboard input	*/
/*	  should be accepted.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetKeyboardState (TCBD, kbState)

int	TCBD;
int	*kbState;
{
	*kbState = EM_TCB_list[TCBD]->keyboardState;

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMCalcSize					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMCalcSize (TCBD, rows, cols, height, width)		*/
/*									*/
/*	  int	TCBD;		-- TCB descriptor of the terminal	*/
/*				   instance				*/
/*	  int	rows;		-- desired number of rows		*/
/*	  int	cols;		-- desired number of columns		*/
/*	  int	*height;	-- calculated height			*/
/*	  int	*width;		-- calculated width			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function calculates the size of the terminal, given the	*/
/*	  desired rows & columns.  It uses the current font.		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMCalcSize (TCBD, rows, cols, height, width)

int	TCBD;
int	rows, cols;
int	*height, *width;
{
	int	status;
	EM_TCB	*TCB;


	TCB = EM_TCB_list[TCBD];

	/* Make sure the correct width is active */
	_EMLoadFont (TCB, CHAR_NORMAL, NORMAL_OFFSET, &status);

	*height = rows * TCB->char_height + (2 * YBORDER);
	*width = cols * TCB->cell_width + (2 * XBORDER);

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetCursor					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetCursor (TCBD, row, col)				*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*	  int	*row;		 -- current row				*/
/*	  int	*col;		 -- current column			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the current cursor position		*/
/*	  of the specified terminal instance.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetCursor (TCBD, row, col)

int	TCBD;
int	*row, *col;
{
	EM_TCB	*TCB;


	TCB = EM_TCB_list[TCBD];

	*row = TCB->current_line;
	*col = TCB->current_col;

	return (EM_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMMod						*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMMod (a, b)						*/
/*									*/
/*	  int	a;		 -- dividend				*/
/*	  int	b;		 -- divisor; base of modulus operation	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the modulus operation of a & b; i.e.,	*/
/*	  the remainder of a/b rounded down (not toward zero).  It is	*/
/*	  defined as:							*/
/*	    a - b * int( (float)a / (float)b )				*/
/*	  unlike the C symbol '%', which is not defined consistently	*/
/*	  when a is negative.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMMod (a, b)

int a, b;
{
	int c;

	c = a % b;
	if (c < 0)
	    c += b;

	return (c);
}





/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMBlinkCursor					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMBlinkCursor (TCBD)					*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function causes the cursor to change visibility states.	*/
/*	  A timer event should be set up to call this routine at	*/
/*	  regular intervals.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMBlinkCursor (TCBD)

int	TCBD;
{
	EM_TCB	*TCB;


	TCB = EM_TCB_list[TCBD];

	_EMGraphicsNormal (TCB);

	hidecursor (TCB->window);
	if (TCB->blink)
	{
	    TCB->blink = FALSE;
	    _EMEraseCursor (TCB);
	}
	else
	{
	    TCB->blink = TRUE;
	    _EMDrawCursor (TCB);
	}
	showcursor (TCB->window);
	flushbuffer (TCB->window);

	return (EM_NO_ERROR);
}





/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetLogFileName				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetLogFileName (TCBD, filename)				*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	  char	*filename;	 -- name of log file to be used		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the name of the log file.  It does not	*/
/*	  enable or disable file logging.				*/
/*	  See EMSetLogFileStatus ().					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If there is an error opening the log file, EM_LOG_FILE_ERROR	*/
/*	  (=30) is returned. Otherwise, zero is returned.		*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMSetLogFileName (TCBD, filename)

int	TCBD;
char	*filename;
{
	EM_TCB *TCB;

	TCB = EM_TCB_list[TCBD];

	strncpy (TCB->term_settings.logFile, filename, 31);
	TCB->term_settings.logFile[31] = '\0';

	if (TCB->term_settings.logFlag)
	{
	    if (TCB->log_file != NULL)
	    {
		fflush (TCB->log_file);
		fclose (TCB->log_file);
	    }

	    TCB->log_file= (_EMusr_access(TCB->term_settings.logFile))
		? NULL : fopen (TCB->term_settings.logFile, "a");
	    if (TCB->log_file==NULL)
		return(EM_LOG_FILE_ERROR);
	}

	return (EM_NO_ERROR);
}






/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetLogFileStatus				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetLogFileStatus (TCBD, status)				*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	  int	stat;		 -- F => turn logging off		*/
/*				    T => turn logging on		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the file logging status.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If there is an error opening the log file, EM_LOG_FILE_ERROR	*/
/*	  (=30) is returned. Otherwise, zero is returned.		*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMSetLogFileStatus (TCBD, status)

int	TCBD;
int	status;
{
	EM_TCB *TCB;

	TCB = EM_TCB_list[TCBD];

	/* check to see if log file flag changed */
	if (!TCB->term_settings.logFlag != !status)
	{
	    TCB->term_settings.logFlag = status;
	    if (status)
	    {
		if (TCB->term_settings.logFile[0] == '\0')
		    TCB->term_settings.logFlag = FALSE;
		else
		    TCB->log_file= (_EMusr_access(TCB->term_settings.logFile))
			? NULL : fopen (TCB->term_settings.logFile, "a");
		    if (TCB->log_file==NULL)
			TCB->term_settings.logFlag = FALSE;
	    }
	    else
	    {
		if (TCB->log_file != NULL)
		{
		    fflush (TCB->log_file);
		    fclose (TCB->log_file);
		    TCB->log_file = NULL;
		}
	    }
	}

	if (TCB->term_settings.logFlag != status)    /*failed to change stat*/
	    return(EM_LOG_FILE_ERROR);
	else
	    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMusr_access					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  _EMusr_access(filename)						*/
/*									*/
/*	  char *filename						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function mirrors the function access, which checks	*/
/*	  to see if the user can open the file under his privileges,	*/
/*	  rather than the process's effective uid (which could be	*/
/*	  root privileges, in which case the process can overwrite	*/
/*	  any file on the system. Two differences: this routine		*/
/*	  checks only for write privileges, and if the file doesn't	*/
/*	  exist, it creates it with the owner's real uid privileges.	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  0 if successful (file exists and can be written to)		*/
/*	  -1 if not successful						*/
/*									*/
/*	PROGRAMMER:  Bill Jones	09/27/89				*/
/*									*/
/************************************************************************/

int _EMusr_access(filename)
char *filename;
{
static int privilege_level_ok;	/* Completion results from child */

FILE *file;
int exec_pid,tmp;
void (*hsig)();

    hsig=signal(SIGCLD,SIG_DFL);
    if ((exec_pid=vfork())!=-1)	/* if successful vfork ... */
    {
        if (!exec_pid) /*if child*/
        {
            setuid(getuid());	/* Switch to user privs */
            setgid(getgid());	/* Switch to group privs */
            privilege_level_ok=((file=fopen(filename,"a"))!=NULL);
            if (privilege_level_ok) fclose(file); /* if open works, close */
            _exit();
        }
	wait(&tmp);
	signal(SIGCLD,hsig);
    }
    else return(-1);	/* Leave early if fork unsuccessful */
    if (privilege_level_ok) return(0); else return (-1); /*Send back results*/
 }


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMFlipText			         	*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMFlipText(TCBD)                                        */
/*									*/
/*	  int    TCBD           -- index to TCB record                  */
/*									*/
/*	DESCRIPTION:							*/
/*	  This function toggles the state of all displayed text with    */
/*        the "blinking attribute set.                                	*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Bill Jones                                         */
/*									*/
/************************************************************************/

int EMFlipText (TCBD)

int	TCBD;
{
  EM_TCB	*TCB;
  unsigned char hold_attr;
  int     hold_color,row,col,string_start;
  EMscreen_row *row_ptr;
  int	font_offset;		/* font-type offset for current	*/
                                /*  row				*/
  int	font_id;		/* font ID for current row	*/
  int	status;			/* "_EMLoadFont" status		*/
  int	wRatio;			/* ratio of active/cell width	*/
  int   cursor_hidden = FALSE;  /* Whether hidecursor has been called */


  TCB = EM_TCB_list[TCBD];

  if (TCB->blink_t)      /* if true, display text as normal */
    {
      TCB->blink_t=FALSE;
    }
  else
    {
      TCB->blink_t=TRUE;
    }


  for (row = 0; row < TCB->displayed_rows; row++)
    {
      row_ptr = &TCB->screen[TCB->row_order[row]];
      font_offset = row_ptr->font_table;
      font_id = _EMLoadFont (TCB, CHAR_NORMAL, font_offset, &status);
      wRatio =  TCB->active_width / TCB->cell_width;

      /* Skip the entire row if all characters are "normal." */
      if (!(row_ptr->all_chars_norm))
	{

	  col=0;
	  /* Display the row piece-by-piece. */
	  while (col < TCB->col_width)
	    {
	      /* Find a string of characters with similar		*/
	      /* attributes, starting at the current column.	*/
	      string_start = col;

	      col++;
	      while ((col < TCB->col_width) && 
		     (row_ptr->char_attr[col-1] ==
		      row_ptr->char_attr[col]) &&
		     (row_ptr->char_color[col-1] ==
		      row_ptr->char_color[col]) &&
		     (row_ptr->cell_color[col-1] ==
		      row_ptr->cell_color[col]) )
		col++;

	      hold_attr=row_ptr->char_attr[string_start];
	      hold_color=TCB->foreground_color;
	      if (hold_attr & CHAR_BLINK)
		{
		  if(!cursor_hidden)
		    hidecursor(TCB->window);
		  cursor_hidden=TRUE;
		  if (!TCB->blink_t)
		    {
		      if (hold_attr & CHAR_REVERSE)
			{
			  hold_attr ^= CHAR_REVERSE;
			}
		      else
			{
			  if (hold_attr & CHAR_BOLD)
			    {
			      hold_attr ^= CHAR_BOLD;
			    }
			  else
			    {
			      TCB->foreground_color=TCB->background_color;
			    }
			}
		    }

		  /* Display the string. */
		  _EMDisplayString (TCB, font_id, font_offset, 
				    hold_attr,
				    &row_ptr->character[string_start], 
				    row,string_start, col - string_start,
				    FALSE);

		  TCB->foreground_color=hold_color;

		}
	    }
	}
    }

  if (cursor_hidden)
    {
      showcursor(TCB->window);
      flushbuffer(TCB->window);
    }
}


