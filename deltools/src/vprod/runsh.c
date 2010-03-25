#include	"main.h"
#include	<pwd.h>
#include	<signal.h>
#include	<sdl.h>
#include	<sys/xio/xerr.h>
#include	<termio.h>
#include	<EMTools.h>
#include	<items.h>
#include	"vtmisc.h"
#include	"vterror.h"
#include	"EMTCB.h"
#include	"EMGlobals.h"

#define		WIN_XMIN	550
#define		WIN_YMIN	500
#define		KB_BUFSIZE	1
#define		SMALL_FONT	"/usr/ip32/vt200/font/fix.7"
#define		BUFFER_LEN	132

extern void	child_death ();
extern int	exec_pid;
extern int	vs;

char	logo[MAX_LOGO];
char	exec_cmd[MAX_CMD];
int	Color;
int     mdev_no;		/* PTY minor device number		*/
int	screen;			/* physical screen number		*/
int	window;			/* window number			*/
int     TCBD;			/* TCB descriptor			*/
long    wait_mask;		/* mask of events to wait on		*/
char	linename[6];		/* name of ttx device			*/
char    host0_inbuf[BUFFER_LEN];/* first host input buffer		*/
char    host1_inbuf[BUFFER_LEN];/* second host input buffer		*/
int	bufLines;
ITItem	scrollBar;		/* vertical scroll bar			*/
EMTermSettings	termSettings;	/* current terminal settings		*/

struct  scr_info screenInfo[MAX_SCREENS];	/* virtual screen info	*/

int     *colors, sbColors[16], monosbColors[16];

void     scrolled_back ();
int     ScrollBarAction ();

ITValuatorSpec sbSpec =
{
    {
        IT_VALUATOR_CLASS, IT_VALUATOR_SCROLLBAR0,
        0, NULL, 0,
        0.0, 0.0, (float)SB_WIDTH, 0.0, 1.0,
        IT_ATTR_ENABLE, 0, 0, NULL, NULL,
        NULL, 0.0, NULL, NULL, NULL, NULL, 0, 0
    },
    0, 0.0, 0.0, 0.0, 0.0, ScrollBarAction
};



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  clean_up					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void clean_up (w_num, exitstatus)				*/
/*									*/
/*	  int	w_num		-- window number of terminal emulation  */
/*	  int   exitstatus	-- status passed in by the caller and	*/
/*				     returned to the operating system   */
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function closes the host input channel and exits the	*/
/*	  tools library.						*/
/*									*/
/*	PROGRAMMER:  Brad Graves					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

clean_up (wnum, exitstatus)

int	wnum;
int	exitstatus;
{
    if (wnum)
	Delete_win (wnum);
    Exit_tools ();

    if (mdev_no)
    {
	signal (SIGCLD, SIG_DFL);	/* reset so no respawn */
	Close_ptty (mdev_no);		/* close PTY (kills children) */
	wait (0);			/* wait for child */
    }
   return (exitstatus);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  writehost 					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void writehost (buffer, bufcnt, brk)				*/
/*									*/
/*	  char	*buffer;	-- buffer of data to be sent to host	*/
/*	  int	bufcnt;		-- number of bytes of data in buffer    */
/*	  int	brk;		-- T => break key was hit		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function determines the host type and sends a buffer of  */
/*	  data to the host.  If the break key was hit, the appropriate	*/
/*	  action is taken.						*/
/*									*/
/*	PROGRAMMER:  Brad Graves					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void writehost (buffer, bufcnt, brk)

char	*buffer;
int	bufcnt;
int	brk;
{
    Put_ptty_data (mdev_no, buffer, bufcnt);

    if (brk)
    {
	/* Send the answerback message to the host */
	EMGetTermSettings (TCBD, &termSettings);
	writehost (termSettings.answerback,
		   strlen (termSettings.answerback), FALSE);
    }
}

/************************************************************************/
/*									*/
/*	FUNCTION NAME:  exec_setup					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  exec_setup () 						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	DESCRIPTION:							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void exec_setup()
{
    int     stat;
    int     i;

    signal (SIGINT, SIG_IGN);
    signal (SIGHUP, SIG_IGN);

    for (i = 0; i < BUFFER_LEN; i++) {
	host0_inbuf[i] = 0;
	host1_inbuf[i] = 0;
    }

    stat = Open_ptty_avail (host0_inbuf, host1_inbuf, BUFFER_LEN, &mdev_no);

    if (stat)
    {				/* minor device number opened */
	Error_num_box (ERR_MSG1, stat, 1);
	clean_up (0, -1);
    }

    /* Set the ptty read line mode */
    Set_ptty_read_mode (mdev_no, 1);
    sprintf (linename, "ttx%02d", mdev_no - 1);
    exec_command();
    signal (SIGCLD,child_death);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  ScrollBarAction					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int ScrollBarAction (sb, part)				*/
/*									*/
/*	  ITItem	sb;	- the scroll bar			*/
/*	  int		part;	- the part number			*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	DESCRIPTION:							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int ScrollBarAction (sb, part)

ITItem	sb;
int	part;
{
    int		rows, cols;
    double	value;

    hidecursor (window);

    ITValuatorGetValue (sb, &value);

    if (part != IT_VAL_INDICATOR)
    {
	switch (part)
	{
	    case IT_VAL_LINE_UP:
		value -= 1.0;
		break;

	    case IT_VAL_LINE_DOWN:
		value += 1.0;
		break;

	    case IT_VAL_PAGE_UP:
	    case IT_VAL_PAGE_DOWN:
		EMGetSize (TCBD, &rows, &cols);
		value += (double) ((part == IT_VAL_PAGE_UP) ? -rows : rows);
		break;

	    case IT_VAL_TOP:
	    case IT_VAL_BOTTOM:
		value = (double) ((part == IT_VAL_TOP) ? 0 : bufLines);
		break;

	    default:
		break;
	}

	ITValuatorSetValue (sb, value);
	ITValuatorGetValue (sb, &value);
    }

    EMMoveScroll (TCBD, (int) value);

    showcursor (window);
    flushbuffer (window);	/* sync code with graphics */

    return (0);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  select_proc					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void select_proc ()						*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function handles the scroll bar value while text		*/
/*	  selection is taking place.					*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void select_proc ()
{
    int		x1, y1, x2, y2, position;
    double	value;

    /* set value of scroll bar if it exists */
    if (bufLines > 0)
    {
	Inq_win_region (window, &x1, &y1, &x2, &y2);
	clipbox (window, 0, 0, x2 - x1, y2 - y1);
	position = EMGetBufferPos (TCBD);
	ITValuatorGetValue (scrollBar, &value);
	if ((int) value != position)
	{
	    hidecursor (window);
	    ITValuatorSetValue (scrollBar, (double) position);
	    showcursor (window);

	    if (position == bufLines)
		scrolled_back (FALSE);
	    else
		scrolled_back (TRUE);
	}
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  scrolled_back					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void scrolled_back (flag)					*/
/*									*/
/*	  int flag;	- scrolled back flag				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function enables/disables certain events and window	*/
/*	  icons depending on whether or not the buffer is scrolled	*/
/*	  back.								*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

void scrolled_back (flag)

int flag;
{
    if (flag)
    {
	Disable_events (KEYBOARD_EVENT | PTTY_EVENT);
/*
	if (!icons_gone)
	{
 	    icons_gone = TRUE;
	    Set_win_user_icon (window, RESET_VALUE, FALSE);
	    Set_win_user_icon (window, RESIZE_VALUE, FALSE);
	    Set_win_user_icon (window, CLS_VALUE, FALSE);
	    Set_win_user_icon (window, PASTE_VALUE, FALSE);
	    Set_win_user_icon (window, -2, FALSE);
	    Set_win_sys_icon (window, MODIFY_ICON_VALUE, FALSE);
	    Update_win_icon (window);
	}
*/
    }
    else
    {
	Enable_events (KEYBOARD_EVENT | PTTY_EVENT);
/*
	if (icons_gone)
	{
	    icons_gone = FALSE;
	    Set_win_user_icon (window, CLS_VALUE, TRUE);
	    Set_win_user_icon (window, RESIZE_VALUE, !NoModify);
	    Set_win_user_icon (window, RESET_VALUE, TRUE);
	    Set_win_user_icon (window, PASTE_VALUE, TRUE);
	    Set_win_user_icon (window, -2, TRUE);
	    Set_win_sys_icon (window, MODIFY_ICON_VALUE, !NoModify);
	    Update_win_icon (window);
	}
*/
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  Error_num_box					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  Error_num_box (string, number, type)				*/
/*									*/
/*	  char  *string;	-- pointer to error message string	*/
/*	  int	number;		-- associated error number		*/
/*	  int	type;		-- error type				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This subroutine displays the error message string along	*/
/*	  the error number in a standard error box.			*/
/*									*/
/*	RETURN VALUE:							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

Error_num_box (string, number, type)

char	*string;
int	number;
int	type;
{
    char    error_msg[512];

    if (number)    
    {
	sprintf (error_msg, "%s\n\nError = %d.", string, number);
	Error_box (screen, error_msg, type);
    }
    else
	Error_box (screen, string, type);
}


/************************************************************************/
/*									*/
/*	Main Routine							*/
/*									*/
/************************************************************************/

run_shell(command, pause, scroll)
char	*command;
int	pause;
int	scroll;
{
int i;
    int		first_receipt = 1;
    char	kb_buf[KB_BUFSIZE]; /* keyboard buffer			*/
    char	*trans_buf;	/* translated keyboard data		*/
    int		x1, y1, x2, y2,
		rx1, ry1, rx2, ry2;
    int		width, height;
    int		brk;
    long	current_mask;	/* current event mask			*/
    int		op_mask;	/* operations mask returned by		*/
				/*   "Get_refresh_data"			*/
    int		aWindow;	/* window involved in cover or		*/
				/*   refresh event			*/
    int		show;
    int		result;
    int		tmp;
    char	*VT_font;	/* font being used			*/
    int		scrapCount;	/* size of scrap buffer			*/
    int		paste_count;	/* next part of buffer to paste		*/
    int		paste_step;	/* amount to paste			*/
    int		paste_done;	/* boolean to tell when pasting is done	*/
    int         quickPaste;     /* boolean to tell whether button paste */
    int		host_echoed;	/* boolean to tell if host echoed some	*/
				/*   and then stopped echoing		*/
    int		any_echoed;	/* boolean to tell if any echoed yet	*/
    int		active;		/* boolean; is vterm active process?	*/
    int		rows, cols;
    int		prev_ev_mask;
    char	*prev_bufaddr;
    int		prev_bufsize;
    int		prev_kb_mode;
    EM_TCB  *TCB;



/* Save current mode settings so they can be restored as we leave */

    Inq_enabled_events(&prev_ev_mask);
    Inq_keyboard_buffer(&prev_bufaddr, &prev_bufsize);
    Inq_keyboard_mode(&prev_kb_mode);

    paste_done = TRUE;
    host_echoed = TRUE;

    mdev_no = 0;

    Inq_displayed_vs(&vs);
    screen = screenInfo[vs].vsi_screen_num;

    Color = FALSE;
    strncpy (exec_cmd, command, MAX_CMD);
    strncpy (logo, exec_cmd, MAX_LOGO);
    logo[MAX_LOGO - 1] = '\0';

    Set_logo (logo);	/* set the logo */

    for (i = 0; i < NUMBER_OF_SLOTS; i++)
	EM_TCB_list[i] = NULL;

    VT_font = SMALL_FONT;

    if (result = EMWindowSize (24, 80, VT_font, &height, &width))
    {
	Error_num_box (ERR_MSG30, result, 1);
	clean_up (0, -1);
    }

    x1 = WIN_XMIN;
    y1 = WIN_YMIN;
    x2 = x1 + width - 1 + SB_WIDTH;
    y2 = y1 + height - 1;

    if (scroll)
	bufLines = 10;
    else
	bufLines = 0;

    /* Create the terminal window */
    if (result = Create_win_no_cstrip (vs, x1, y1, x2, y2, &window))
    {
	Error_num_box (ERR_MSG3, result, 1);
	clean_up (0, -1);
    }

    Set_win_auto_act (window, FALSE);
    Set_win_button_mode (window, 3);

    /* Create a terminal instance. */
    if (result = EMCreateTerm (&TCBD, window, VT_font, TRUE, Color, 0, 0, 0,
			       x2 - x1 - ((bufLines > 0) ? SB_WIDTH : 0),
			       y2 - y1, bufLines))
    {
	Error_num_box (ERR_MSG4, result, 1);
	clean_up (window, -1);
    }

    /* Get the default terminal settings */
    EMGetTermSettings (TCBD, &termSettings);

    if (EMSetLogFileName(TCBD, LOGFILE) || EMSetLogFileStatus(TCBD, TRUE))
    {
	EMSetLogFileName(TCBD, "/usr/tmp/log");
	EMSetLogFileStatus(TCBD, FALSE);
	Error_num_box(EM_LOG_FILE_ERRMSG, 0, 3);
    }

    TCB = EM_TCB_list[TCBD];
    setbuf(TCB->log_file, 0);

    /** Create the scroll bar **/
    EMGetSize (TCBD, &rows, &cols);
    bufLines = EMGetBufferSize (TCBD);
    sbSpec.item.wNo = window;
    sbSpec.item.xOrg = x2 - x1 - (float)SB_WIDTH + 1.0;
    sbSpec.item.ySize = y2 - y1 + 1.0;
    sbSpec.maxValue = sbSpec.value = (double) bufLines;
    sbSpec.view = (double) rows / (bufLines + rows);
    ITCreate (&sbSpec, &scrollBar);

    /** Set the fixed-color colors correctly **/
    ITSetColor (scrollBar, 1, NULL);
    ITGetColor (scrollBar, &tmp, &colors);
    memcpy (sbColors, colors, IT_NUM_COLORS * sizeof (int));
    sbColors[IT_FLUSH_COLOR] = sbColors[IT_ERASE_COLOR] = 3;
    sbColors[IT_FLUSH_CONT0_COLOR] = 2;
    sbColors[IT_FLUSH_CONT1_COLOR] = 1;

    /** Set the 2-color colors correctly **/
    ITSetColor (scrollBar, 0, NULL);
    ITGetColor (scrollBar, &tmp, &colors);
    memcpy (monosbColors, colors, IT_NUM_COLORS * sizeof (int));
    monosbColors[IT_FLUSH_COLOR] = monosbColors[IT_ERASE_COLOR] = 0;
    monosbColors[IT_FLUSH_CONT0_COLOR] = -1;
    monosbColors[IT_FLUSH_CONT1_COLOR] = -1;

    if (screenInfo[vs].vsi_flags & VSI_VLT_FIXED)
        ITSetColor (scrollBar, 1, sbColors);
    else
        ITSetColor (scrollBar, 0, monosbColors);

    /* Set up the keyboard input buffer. */
    Set_keyboard_buffer (kb_buf, KB_BUFSIZE);

    /* Make sure everything's cleaned out first */
    Clear_ptty_data(mdev_no);
    Clear_keyboard_data();

    first_receipt = 1;
    paste_step = 40;
/*    wait_mask = KEYBOARD_EVENT | REFRESH_EVENT |
 *		PTTY_EVENT | DELETE_EVENT | BUTTON_EVENT |
 *		WINDOW_ICON_EVENT | TIMER_EVENT | PROCESS_EVENT |
 *		USER_EVENT;
 */
    wait_mask = KEYBOARD_EVENT | REFRESH_EVENT |
		PTTY_EVENT | DELETE_EVENT | BUTTON_EVENT |
		PROCESS_EVENT | USER_EVENT;

    /* Open the correct host input channel. */
    exec_setup();
    Enable_events (wait_mask);

    for (;;)			/* exits via the DELETE_EVENT */
    {
	if (paste_done)
	{
	    Wait_for_events (wait_mask, &current_mask);
	}
	else	/* see if there is any more pasted data coming back from host */
	{
	    Wait_timer (3);

	    Inq_events (&current_mask);

	    if (!(current_mask & PTTY_EVENT) && any_echoed)
		host_echoed = TRUE;		/* host stopped echoing */
	}

	/* Delete event MUST be serviced first, due to tools design */

	if (current_mask & DELETE_EVENT)
	{
	    Get_delete_data (&aWindow);

	    if (aWindow == window)
	    {
		if (pause)
		    sleep(5);
		EMClose (TCBD);
		if (mdev_no)
		    Close_ptty(mdev_no);
		Delete_win(window);
		return(0);
	    }
	}


	if (current_mask & USER_EVENT)
	{
	    long	userData;

	    Get_user_data (&userData);
	    if (pause)
		sleep(5);
	    Clear_ptty_data(mdev_no);
	    Clear_keyboard_data();
	    EMSetLogFileStatus(TCBD, FALSE);
	    EMClose (TCBD);
	    if (mdev_no)
		Close_ptty(mdev_no);
	    Delete_win(window);
	    Set_keyboard_buffer(prev_bufaddr, prev_bufsize);
	    Set_keyboard_mode(prev_kb_mode);
	    Enable_events(prev_ev_mask);
	    return(userData);
	}

	if ((current_mask & KEYBOARD_EVENT) && paste_done)
	{
	    int	kbState, kbCount, transCount;

	    /** Accept keyboard input iff the host can handle it **/
	    EMGetKeyboardState (TCBD, &kbState);
	    if (kbState)
	    {
		Get_keyboard_data (&kbCount);

		if (kbCount > 0)
		{
		    EMTranslateKeys (TCBD, kb_buf, kbCount, &trans_buf,
				     &transCount, &brk);
		    if (trans_buf) {
			    writehost (trans_buf, transCount, brk);
			    free (trans_buf);
		    }
		}
	    }
	}


	if (current_mask & BUTTON_EVENT)
	{
	    int		button, trans;
	    ITItem	anItem;

	    Get_button_data (&aWindow, &x1, &y1, &button, &trans, &tmp);

	    if (trans == DOWN)
	    {
                if ((bufLines > 0) &&
		    (ITFindByButton (scrollBar, window, x1, y1, &anItem) | 1) &&
                    (anItem != NULL))
                {
                    Inq_win_region (window, &rx1, &ry1, &rx2, &ry2);
                    clipbox (window, 0, 0, rx2 - rx1, ry2 - ry1);

                    if (anItem == scrollBar)
                    {
                        int     topLine, complete;
                        double  value;

                        ITTrackButton (scrollBar, x1, y1, button, trans, tmp,
                                       &complete);
                        ITValuatorGetValue (scrollBar, &value);
                        topLine = EMGetBufferPos (TCBD);
                        if ((int) value != topLine)
                            EMMoveScroll (TCBD, (int) value);

                        /* stop input from host if scrolled back */
                        if ((int) value == bufLines)
                            scrolled_back (FALSE);
                        else
                            scrolled_back (TRUE);
                    }
                }
                else
                {
		    if (!active)
		    {
			Activate_process ();
		    }
		    else if (button == MIDDLE_BUTTON)
		    {
			EMClearSelection (TCBD);
			EMTextSelect (TCBD, button, x1, y1, select_proc);
		    }
		    else if (button == RIGHT_BUTTON)
		    {
			EMClearSelection (TCBD);
		    }
		    else if ((button == LEFT_BUTTON) && paste_done)
		    {
			scrapCount=EMGetSelection(TCBD,&trans_buf);
			if (scrapCount>0)
			{
			    char *ptr,*endPtr;
			    quickPaste=TRUE;
			    paste_done=FALSE;
			    paste_count=0;
			    endPtr = &trans_buf[scrapCount];
			    for (ptr = trans_buf; ptr < endPtr; ptr++)
			    {
				if (*ptr == '\n')
				    *ptr = '\r';
			    }
			}
			else
			    free(trans_buf);
		    }
		}
	    }
	    continue;
	}



	if (current_mask & REFRESH_EVENT)
	{
	    Get_refresh_area_data (&aWindow, &vs, &x1, &y1,
			      &x2, &y2, &rx1, &ry1, &rx2, &ry2, &op_mask);

	    if (aWindow == window)
	    {
		/* Lock the screen to speed things up a bit */
		Lock_screen ();

		if (op_mask & WN_CHANGED_VS)
		{
		    Inq_win_vs (window, &vs);
                    if(screenInfo[vs].vsi_flags & VSI_VLT_FIXED)
                        ITSetColor(scrollBar,1,sbColors);
                    else
                        ITSetColor(scrollBar,0,monosbColors);
 
		}
		if (op_mask & WN_CHANGED_SIZE)	/* did window change size? */
		{
		    if (bufLines > 0) 		/* does scrollbar exist? */
		    {
			hidecursor(window);
	    
			EMSetWinSize (TCBD, 0, 0, x2 - x1 - SB_WIDTH , y2 - y1);

                        EMGetSize (TCBD, &rows, &cols);
                        ITImmediateDec (scrollBar);
                        ITSetSize (scrollBar, (float)SB_WIDTH, y2 - y1 + 1.0);
                        ITSetPosition (scrollBar, x2 - x1 - (float)SB_WIDTH + 1.0, 0.0);
                        ITValuatorSetView (scrollBar,
                                           (double) rows / (bufLines + rows));
                        ITImmediateInc (scrollBar);
                        ITDraw (scrollBar);

                        showcursor (window);
                    }
                    else
                        EMSetWinSize (TCBD, 0, 0, x2 - x1, y2 - y1);

		    /* Redraw the contents of the terminal instance.	*/
		    /* Size has already changed, so turn off _SIZE bit	*/

		    EMUpdate (TCBD, 1, op_mask & ~WN_CHANGED_SIZE,
			      0, 0, x2 - x1, y2 - y1);
		}
		else
		{
		    if (bufLines > 0)	/* does scrollbar exist? */
                    {
                        clipbox (window, rx1, ry1, rx2, ry2);
                        hidecursor (window);
                        ITDraw (scrollBar);
                        showcursor (window);
                        clipbox (window, 0, 0, x2 - x1, y2 - y1);
                    }

		    EMUpdate (TCBD, 1, op_mask, rx1, ry1, rx2, ry2);
		}

		flushbuffer (window);
		Unlock_screen ();
	    }
	}


	if (current_mask & PTTY_EVENT)
	{
	    char	*bufptr, *returnBuffer;
	    int		buffer_num, count, returnCount;

	    show = TRUE;
	    any_echoed = TRUE;

	    Get_ptty_data (&mdev_no, &buffer_num, &count);

	    bufptr = (buffer_num == 0) ? host0_inbuf : host1_inbuf;

	    EMGetTermSettings (TCBD, &termSettings);
	    if (termSettings.online)
	    {
		if (first_receipt == 1) {
		    Activate_process ();
		    active = TRUE;
		    Display_win (window);
		    Pop_win_to_top(window);
		    EMUpdate (TCBD, 1, WN_WAS_OFF_SCREEN, 0, 0, x2 - x1, y2 - y1);
		    if (bufLines > 0)   /* draw scroll bar if necessary */
		    {
			hidecursor (window);
			clipbox (window, 0, 0, x2 - x1, y2 - y1);
			ITImmediateInc (scrollBar);
			ITDraw (scrollBar);
			showcursor (window);
			flushbuffer (window);
		    }
		    first_receipt = 0;
		}

		EMWrite (TCBD, bufptr, count, &returnBuffer,
			 &returnCount);

		if (returnCount > 0)
		{
		    writehost (returnBuffer, returnCount, FALSE);
		    free (returnBuffer);
		}
		if (*bufptr == '\n')
		    fflush(TCB->log_file);
	    }

	    if (show)
	    {
		int	collapsed;

		Inq_win_collapse_stat (window, &collapsed);

		if (collapsed)
		{
		    Uncollapse_win (window);
		    Pop_win_to_top (window);
		}
	    }
	}

	if (current_mask & PROCESS_EVENT)
	    Get_process_data (&active);
    }
}
