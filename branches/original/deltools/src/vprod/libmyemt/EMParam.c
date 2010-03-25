#include "../hfiles/EMDefines.h"
#include "../hfiles/EMState.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


void	_EMCopyTermSettings ();
void	_EMLoadRGBVLT ();
void	_EMPutEnv ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetParms					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetParms (TCBD, term_settings, color_mode, color_table)	*/
/*									*/
/*	  int  TCBD;	    -- TCB descriptor of terminal instance to	*/
/*			       whose parameter table is to be returned	*/
/*									*/
/*	  EMTermSettings;  -- pointer to the structure in which the	*/
/*			       parameter table is to be returned	*/
/*									*/
/*	  color_mode	    -- address in which to return the color 	*/
/*			       mode					*/
/*									*/
/*	  color_table	    -- pointer to the structure (array) in	*/
/*			       which the color table is to be returned  */
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns a copy of the terminal instance's	*/
/*	  parameter table and color settings.				*/
/*									*/
/*	NOTES								*/
/*	  This function is obsoleted by EMGetTermSettings()		*/
/*	  and EMGetColorSettings().					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int EMGetParms (TCBD, term_settings, color_mode, color_table)
     
int		TCBD;
EMTermSettings	*term_settings;
short		*color_mode;
float		color_table[4][4];
{
	EMGetTermSettings (TCBD, term_settings);
	EMGetColorSettings (TCBD, color_mode, color_table);

	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetTermSettings				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetTermSettings (TCBD, term_settings)			*/
/*									*/
/*	  int  TCBD;	    -- TCB descriptor of terminal instance to	*/
/*			       whose parameter table is to be returned	*/
/*									*/
/*	  EMTermSettings						*/
/*	     term_settings; -- pointer to the structure in which the	*/
/*			       parameter table is to be returned	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns a copy of the terminal instance's	*/
/*	  parameter table.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetTermSettings (TCBD, term_settings)
     
int		TCBD;
EMTermSettings	*term_settings;
{
	EM_TCB  *TCB;		/* pointer to the TCB for this instance */


	/* Point to the TCB for this instance. */
	TCB = EM_TCB_list[TCBD];

	/* Copy the parameter table. */
	_EMCopyTermSettings (term_settings, &TCB->term_settings);

	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetColorSettings				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetColorSettings (TCBD, color_mode,			*/
/*					   color_table)			*/
/*									*/
/*	  int  TCBD;	    -- TCB descriptor of terminal instance to	*/
/*			       whose color settings are to be returned	*/
/*									*/
/*	  color_mode	    -- address in which to return the color 	*/
/*			       mode					*/
/*									*/
/*	  color_table	    -- pointer to the structure (array) in	*/
/*			       which the color table is to be returned  */
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns a copy of the terminal instance's	*/
/*	  color settings.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetColorSettings (TCBD, color_mode, color_table)
     
int	TCBD;
short	*color_mode;
float	color_table[4][4];
{
	EM_TCB  *TCB;		/* pointer to the TCB for this instance */
	int	i, j;		/* color table indices			*/


	/* Point to the TCB for this instance. */
	TCB = EM_TCB_list[TCBD];

	/* Get the color mode. */
	*color_mode = _EMGetColorMode (&TCB->state_table);

	/* Copy the color table. */
	for (i = 0; i < 4; i++)
	    for (j = 0; j < 4; j++)
		color_table[i][j] = TCB->state_table.color_table[i][j];

	return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetParms					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetParms (TCBD, term_settings, color_mode, color_table)	*/
/*									*/     
/*	  int			TCBD;					*/
/*	  EMTermSettings	*term_settings;				*/
/*	  short			color_mode;				*/
/*	  float			color_table[4][4];			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This routine sets the terminal and color settings for the	*/
/*	  specified terminal instance.  An update is performed.		*/
/*									*/
/*	NOTES								*/
/*	  This function is obsoleted by EMSetTermSettings()		*/
/*	  and EMSetColorSettings().					*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMSetParms (TCBD, term_settings, color_mode, color_table)
     
int		TCBD;
EMTermSettings	*term_settings;
short		color_mode;
float		color_table[4][4];
{
	int	vs_no,phys_no;


	EM_TCB	*TCB;

	TCB = EM_TCB_list[TCBD];

	if (EMSetTermSettings (TCB->TCBD, term_settings))
	{
	    EMSetLogFileName(TCBD,"usr/tmp/log");
	    EMSetLogFileStatus(TCBD,FALSE);
	    vs_no=_EMGetScreenNumber(&TCB->state_table);
	    phys_no=_EMScreenInfo[vs_no].vsi_screen_num;
	    Error_box(phys_no,EM_LOG_FILE_ERRMSG, 3);
	}

	EMSetColorSettings (TCB->TCBD, color_mode, color_table);

	/* Update the screen display */
	hidecursor (TCB->window);

	/* Unscroll the scroll buffer */
	EMMoveScroll (TCB->TCBD, TCB->buf_lines);

	_EMClearScreen (TCB);
	_EMDisplayScreen (TCB, 0, TCB->displayed_rows, 0, TCB->col_width, TRUE);
	_EMDrawCursor (TCB);

	showcursor (TCB->window);
	flushbuffer (TCB->window);

	return (EM_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetTermSettings				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetTermSettings (TCBD, term_settings)			*/
/*									*/
/*	  int			TCBD;					*/
/*	  EMTermSettings	*term_settings;				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This routine sets the terminal settings for the specified	*/
/*	  terminal instance.  No update is performed.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned,  unless there is an	*/
/*	  error setting the name or status of the log tile,  in which	*/
/*	  case an EM_LOG_FILE_ERROR (=30) is returned			*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMSetTermSettings (TCBD, term_settings)

int		TCBD;
EMTermSettings	*term_settings;
{
	EM_TCB	*TCB;		/* pointer to the TCB for this instance */
int result;
	/* Point to the TCB for this instance. */
	TCB = EM_TCB_list[TCBD];

	/* Change the scroll buffer if necessary */
	if (TCB->term_settings.bufScreens != term_settings->bufScreens)
	    _EMSetBufferSize (TCB, term_settings->bufScreens);

	if (TCB->term_settings.screenReverse != term_settings->screenReverse)
	    _EMReverseScreenColors (TCB);

	/* Copy the parameter table into the TCB. */
	_EMCopyTermSettings (&TCB->term_settings, term_settings);

	/* Set the column width. */
	if (TCB->term_settings.eighty)
	    _EMSet80Columns (TCB);
	else
	    _EMSet132Columns (TCB);

	/* set the TERM environment variable */
	_EMPutEnv (TCB);

	/* set the log file name and status */
	if (EMSetLogFileName (TCB->TCBD, term_settings->logFile) ||
	        EMSetLogFileStatus (TCB->TCBD, term_settings->logFlag))
	    return (EM_LOG_FILE_ERROR);
	else
	    return (EM_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetColorSettings				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetColorSettings (TCBD, color_mode, color_table)	*/
/*									*/
/*	  int	TCBD;							*/
/*	  short	color_mode;						*/
/*	  float	color_table[4][4];					*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This routine sets the color settings for the specified	*/
/*	  terminal instance.  No update is performed.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMSetColorSettings (TCBD, color_mode, color_table)

int	TCBD;
short	color_mode;
float	color_table[4][4];
{
	int	i, j;		/* color table indices		        */
	int	vs_no;		/* virtual screen number		*/
	EM_TCB	*TCB;		/* pointer to the TCB for this instance */

	/* Point to the TCB for this instance. */
	TCB = EM_TCB_list[TCBD];

	vs_no = _EMGetScreenNumber (&TCB->state_table);

	/* Set the color mode to default (black & white) */
	_EMDefaultSettings (&TCB->state_table, BILEVEL);

	/* Initialize colors */
	TCB->foreground_color =
			_EMGetColorIndex (&TCB->state_table, FOREGROUND) +
			VLT_OFFSET + _EMFixedVLTOffset[vs_no];
	TCB->background_color =
			_EMGetColorIndex (&TCB->state_table, BACKGROUND) +
			VLT_OFFSET + _EMFixedVLTOffset[vs_no];

	/* Set the screen colors. */
	if ((color_mode != BILEVEL) && 
	    (_EMEnoughBitPlanes (_EMGetScreenNumber (&TCB->state_table))))
	{
	    Set_win_vs_swap (TCB->window,
			     _EMSwapVSAbility (color_mode != BILEVEL));

	    /* Set the TCB's state table's color mode and color indices. */
	    _EMSetColorMode (&TCB->state_table, COLOR);
	    _EMSetColorIndex (&TCB->state_table, FOREGROUND, FORE_CT_INDEX);
	    _EMSetColorIndex (&TCB->state_table, BACKGROUND, BACK_CT_INDEX);

	    /* Set the TCB's color indices. */
	    TCB->foreground_color =
			_EMGetColorIndex (&TCB->state_table, FOREGROUND) +
			VLT_OFFSET + _EMFixedVLTOffset[vs_no];
	    TCB->background_color =
			_EMGetColorIndex (&TCB->state_table, BACKGROUND) +
			VLT_OFFSET + _EMFixedVLTOffset[vs_no];

	    /* Copy the color table into the TCB. */
	    for (i = 0; i < 4; i++)
		for (j = 0; j < 4; j++)
		    TCB->state_table.color_table[i][j] = color_table[i][j];

	    /* Set the VLT. */
	    _EMColorTableToVLT (&TCB->state_table);
	    _EMLoadRGBVLT (vs_no);
	}
	else
	    Set_win_vs_swap (TCB->window, _EMSwapVSAbility (FALSE));

	/* Note::                                                */
        /* If the term is currently set for a light background,  */
	/* This routine has just set it back                     */

	if (TCB->term_settings.screenReverse)
	    _EMReverseScreenColors (TCB);


	return (EM_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMCopyTermSettings				*/ 
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMCopyTermSettings (destination, source)		*/
/*	  								*/
/*	  EMTermSettings	*destination;				*/
/*	  EMTermSettings	*source;				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function copies the "source" parameter table (terminal	*/
/*	  settings table) to the "destination."				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  none								*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMCopyTermSettings (destination, source)

EMTermSettings	*destination;
EMTermSettings	*source;
{
	memcpy (destination, source, sizeof (EMTermSettings));
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEnoughBitPlanes 				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMEnoughBitPlanes (vs_no)				*/
/*									*/
/*	  int 	vs_no;							*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns a positive value if the specified	*/
/*	  virtual screen possesses enough bit planes to support color.	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  If color can be supported, 1 is returned; if not, 0 is	*/
/*	  returned.							*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMEnoughBitPlanes (vs_no)

int	vs_no;
{
	if (_EMScreenInfo[vs_no].vsi_num_planes < MIN_BIT_PLANES)
	    return (FALSE);
	else
	    return (TRUE);		  
}
