#include "../hfiles/EMState.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"

int	_EMFixedVLTOffset[MAX_SCREENS];	/* offset for all vlt references */


void	_EMSetCommandLevel ();
void	_EMSetColorMode ();
void	_EMSetColorTable ();
void	_EMSetColorIndex ();
void	_EMColorTableToVLT ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMHLSToRGB					*/
/*									*/
/*	ARGUMENTS: (all 'float')					*/
/*	  red, green, blue	     --- RGB settings output in range	*/
/*					 [0, 1]				*/
/*	  hue, lightness, saturation --- HLS settings  		 	*/
/*					   hue in range [0, 360]	*/
/*					   lightness, saturation in	*/
/*					   range [0, 1]			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  none								*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function accepts hue, lightness, and saturation values   */
/*	  and returns corresponding red, green, and blue values.	*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/*	NOTE:  This function was taken from page 619 of 'Fundamentals	*/
/*	       of Interactive Computer Graphics', by Foley and 		*/
/*	       Van Dam.  It was modified to handle Tektronix type	*/
/*	       HLS settings (i.e., hue = 0 is blue rather than red.).   */
/*									*/
/************************************************************************/


/************************************************************************/
/*									*/
/*	function 'value'						*/
/*									*/
/************************************************************************/

float value (m1, m2, hue)

float	m1, m2, hue;
{
	if (hue > 360)
	    hue -= 360;

	if (hue < 0)
	    hue += 360;

	if (hue < 60)
	    return (m1 + (m2 - m1) * hue / 60);
	else	
	    if (hue < 180)
		return (m2);
	    else
		if (hue < 240)
		    return (m1 + (m2 - m1) * (240 - hue) / 60);
		else
		    return (m1);
}



/************************************************************************/
/*									*/
/*	function '_EMHLSToRGB'						*/
/*									*/
/************************************************************************/

void _EMHLSToRGB (hue, lightness, saturation, red, green, blue)

float	hue, lightness, saturation, *red, *green, *blue;
{
	float	m1;
	float	m2;


	if (lightness <= 0.5)
	    m2 = lightness * (1 + saturation);
	else
	    m2 = lightness + saturation - (lightness * saturation);

	m1 = (2 * lightness) - m2;

	if (saturation == 0)
	{
	    *red = lightness;		/* gray shade */
	    *green = lightness;
	    *blue = lightness;
	}
	else
	{
	    *red = value (m1, m2, hue);
	    *green = value (m1, m2, hue + 240);
	    *blue = value (m1, m2, hue + 120);
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME: _EMDefaultSettings				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDefaultSettings (state_table)				*/
/*	    								*/
/*	  ReGIS_state  *state_table -- pointer to state table to	*/
/*		 		         initialize			*/
/*	  short	       color_mode   -- either COLOR, MONOCHROME, or	*/
/*					 BILEVEL			*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This routine initializes all fields of the state table, 	*/
/*	  except for the window number and virtual screen number, 	*/
/*	  which must be initialized by the caller.			*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMDefaultSettings (state_table, color_mode)

ReGIS_state	*state_table;
short		color_mode;
{
	int	vs_no;


	/* Initialize command level to level 0. */
	_EMSetCommandLevel (state_table, 0);

	/* Get the virtual screen number */
	vs_no = _EMGetScreenNumber (state_table);

	/* Set either BILEVEL or COLOR mode as the default, depending	*/
	/* upon the color mode specifier received.  It is assumed that	*/
	/* the necessary planes are present if color_mode is not	*/
	/* BILEVEL.							*/

	if (color_mode == BILEVEL)
	{
	    int	white, black;

	    _EMSetColorMode (state_table, BILEVEL);

	    if (_EMScreenInfo[vs_no].vsi_flags & VSI_VLT_FIXED)
	    {
		white = WHITE_FIXED;
		black = BLACK_FIXED;
	    }
	    else
	    {
		white = WHITE;
		black = BLACK;
	    }

	    _EMSetColorIndex (state_table, FOREGROUND, white - VLT_OFFSET -
			      _EMFixedVLTOffset[vs_no]);
	    _EMSetColorIndex (state_table, BACKGROUND, black - VLT_OFFSET -
			      _EMFixedVLTOffset[vs_no]);
	}
	else
	{
	    /* Set color mode as default mode. */
	    _EMSetColorMode (state_table, COLOR);

	    /* Set foreground and background indices. */
	    _EMSetColorIndex (state_table, FOREGROUND, FORE_CT_INDEX); 
	    _EMSetColorIndex (state_table, BACKGROUND, BACK_CT_INDEX); 

	    /* Set monochrome lightness levels.				*/
	    /*	index 0 -- black		(background color)	*/
	    /*	index 1 -- dark gray					*/
	    /*	index 2 -- light gray		(bold text)		*/
	    /*	index 3 -- white		(normal text)		*/

	    _EMSetColorTable (state_table, 0, 0.0, 0.00, 0.0, MONO_AND_COLOR);
	    _EMSetColorTable (state_table, 1, 0.0, 0.25, 0.0, MONO_AND_COLOR);
	    _EMSetColorTable (state_table, 2, 0.0, 0.50, 0.0, MONO_AND_COLOR);
	    _EMSetColorTable (state_table, 3, 0.0, 0.75, 0.0, MONO_AND_COLOR);

	    /* Set default color settings without changing mono levels.	*/
	    /*	index 0 -- black	(background color)		*/
	    /*	index 1 -- blue						*/
	    /*	index 2 -- red		(bold text)			*/
	    /*	index 3 -- white	(normal text)			*/

	    _EMSetColorTable (state_table, 0,   0.0, 0.0, 0.0, COLOR_ONLY);
	    _EMSetColorTable (state_table, 1,   0.0, 0.5, 1.0, COLOR_ONLY);
	    _EMSetColorTable (state_table, 2, 120.0, 0.5, 1.0, COLOR_ONLY);
	    _EMSetColorTable (state_table, 3,   0.0, 1.0, 0.0, COLOR_ONLY);

	    _EMColorTableToVLT (state_table);
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetCommandLevel				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetCommandLevel (state_table, level)			*/
/*									*/
/*	  ReGIS_state  *state_table -- pointer to state table to update */
/*	  short	       level        -- command level to set		*/
/*									*/
/*	RETURNED VALUE:	none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the command level in the ReGIS state 	*/
/*	  table.  If the command level is outside the range [0, 3], 	*/
/*	  the command level is set to 0.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetCommandLevel (state_table, level)

ReGIS_state	*state_table;
short		level;
{
	if ((level < 0) || (level > 3))
	    level = 0;

	state_table->command_level = level;
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetCommandLevel				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  short _EMGetCommandLevel (state_table)			*/
/*									*/
/*	  ReGIS_state  *state_table -- pointer to state table to read   */
/*					 from				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  The command level is returned.				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the command level from the state table. */
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

short _EMGetCommandLevel (state_table)

ReGIS_state	*state_table;
{
	return (state_table->command_level);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetColorMode					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetColorMode (state_table, mode_specifier)		*/
/*									*/
/*	  ReGIS_state  *state_table   -- state table to update		*/
/*	  short        mode_specifier -- COLOR, MONOCHROME, or BILEVEL  */
/*									*/
/*	RETURNED VALUE:							*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the color mode to either COLOR, BILEVEL,   */
/*	  or MONOCHROME.  If an invalild mode specifier is received,	*/
/*	  COLOR mode is set.						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetColorMode (state_table, mode_specifier)

ReGIS_state	*state_table;
short		 mode_specifier;
{
	if ((mode_specifier != COLOR) && (mode_specifier != MONOCHROME) &&
	    (mode_specifier != BILEVEL))    
	    mode_specifier = COLOR;
	state_table->color_mode = mode_specifier;
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetColorMode					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  short _EMGetColorMode (state_table)				*/
/*									*/
/*	  ReGIS_state  *state_table -- pointer to table to read from	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  The color mode is returned.					*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the color mode from the state table.	*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

short _EMGetColorMode (state_table)

ReGIS_state	*state_table;
{
	return (state_table->color_mode);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetColorTable				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetColorTable (state_table, location, hue, lightness,	*/
/*	 			 saturation, restriction)		*/
/*									*/
/*	  ReGIS_state  *state_table  -- pointer to table to update	*/
/*	  short	       location      -- color table location to set	*/
/*	  float	       hue           -- HLS description of color to set */
/*	               lightness          hue in range [0.0,  360.0],	*/
/*		       saturation         others in range [0.0, 1.0]	*/
/*	  short	       restriction   -- either COLOR_ONLY or		*/
/*					  MONO_AND_COLOR		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function places a specified color in a specified color   */
/*	  table location.  The lightness value is loaded for both	*/
/*	  monochrome and color unless COLOR_ONLY is specified.	The	*/
/*	  video lookup table for the virtual screen on which the	*/
/*	  terminal window appears is not changed.			*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetColorTable (state_table, location, hue, lightness, saturation, 
		       restriction)

ReGIS_state	*state_table;
short		location;
float		hue, lightness, saturation;
short		restriction;
{
	if ((location >= 0) && (location < 4))
	{
	    state_table->color_table[location][HUE] = hue;
	    state_table->color_table[location][LIGHTNESS] = lightness;
	    state_table->color_table[location][SATURATION] = saturation;

	    if (restriction != COLOR_ONLY)
		state_table->color_table[location][MONO_LIGHTNESS] = lightness;
	}
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMReadColorTable				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMReadColorTable (state_table, location, hue, lightness,	*/
/*				 saturation, color_mode)		*/
/*	 								*/
/*	  see synopsis for "_EMSetColorTable" for parameter description	*/
/*									*/
/*	  short  color_mode  -- either COLOR or MONOCHROME		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of INVALID_LOCATION is returned if the specified	*/
/*	  location is outside of the range [0, 3].			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the contents of a specified color	*/
/*	  table location.						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/
    
int _EMReadColorTable (state_table, location, hue, lightness, saturation, 
		       color_mode)

ReGIS_state	*state_table;
short		location;
float		*hue, *lightness, *saturation;
short		color_mode;
{
	int	error_status;


	if ((location >= 0) && (location < 4))
	{
	    if (color_mode == COLOR)
	    {
		*hue = state_table->color_table[location][HUE];
		*lightness = state_table->color_table[location][LIGHTNESS];
		*saturation = state_table->color_table[location][SATURATION];
	    }
	    else
	    {
		*hue = 0.0;
		*lightness = state_table->color_table[location][MONO_LIGHTNESS];
		*saturation = 0.0;
	    }		  

	    error_status = VALID_LOCATION;
	}
	else
	    error_status = INVALID_LOCATION;

	return (error_status);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetColorIndex				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetColorIndex (state_table, index_specifier,		*/
/*				 location)				*/
/*									*/
/*	  ReGIS_state  *state_table    -- pointer to table to update	*/
/*	  short        index_specifier -- either FOREGROUND or		*/
/*					    BACKGROUND			*/
/*	  short	       location        -- set the index to point to	*/
/*					    this color table location   */
/*									*/
/*	RETURNED VALUE:	none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the specified index to point to the	*/
/*	  specified location.  If an improper index (neither 		*/
/*	  FOREGROUND nor BACKGROUND) or location is specified, no	*/
/*	  action is performed.						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetColorIndex (state_table, index_specifier, location)

ReGIS_state	*state_table;
short		index_specifier, location;
{
	if (index_specifier == FOREGROUND)
	    if ((location >= 0) && (location < 4) || 
		(_EMGetColorMode (state_table)) == BILEVEL)
		state_table->fg_col_index = location;

	if (index_specifier == BACKGROUND)
	    if ((location >= 0) && (location < 4) ||
		(_EMGetColorMode (state_table)) == BILEVEL)
		state_table->bg_col_index = location;
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetColorIndex				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  short get_color_table_index (state_table, index_specifier)	*/
/*									*/
/*	  ReGIS_state  *state_table    -- table to read from		*/
/*	  short	       index_specifier -- either FOREGROUND or		*/
/*					    BACKGROUND			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  The contents of the specified index is returned.		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the contents of the specified index.	*/
/*	  If an invalid index is specified, the contents of the fore-	*/
/*	  ground color index is returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

short _EMGetColorIndex (state_table, index_specifier)

ReGIS_state	*state_table;
short		index_specifier;
{
	if (index_specifier == BACKGROUND)
	    return (state_table->bg_col_index);
	else
	    return (state_table->fg_col_index);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetForeground				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetForeground (state_table)				*/
/*									*/
/*	  ReGIS_state  *state_table -- table containing foreground	*/
/*					 color index			*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the Interpro 32 foreground color to that 	*/
/*	  foreground color specified in the state table.		*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetForeground (state_table)

ReGIS_state	*state_table;
{
	fgcolor (state_table->window_number, 
		 state_table->fg_col_index + VLT_OFFSET +
		 _EMFixedVLTOffset[_EMGetScreenNumber (state_table)]);
}	

/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetBackground				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetBackground (state_table)				*/
/*									*/
/*	  ReGIS_state  *state_table -- table containing foreground	*/
/*					 color index			*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sets the Interpro 32 background color to that 	*/
/*	  background color specified in the state table.		*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetBackground (state_table)

ReGIS_state	*state_table;
{

	bgcolor (state_table->window_number, 
		 state_table->bg_col_index + VLT_OFFSET +
		 _EMFixedVLTOffset[_EMGetScreenNumber (state_table)]);
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMColorTableToVLT				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMColorTableToVLT (state_table)				*/
/*									*/
/*	  ReGIS_state  *state_table -- table contining the color table  */
/*					 to be loaded			*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function reads the current VLT and overlays the color	*/
/*	  table on locations VLT_OFFSET to VLT_OFFSET + 3.		*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMColorTableToVLT (state_table)

ReGIS_state  *state_table;
{
	struct	vlt_slot vlt[4];	/* vlt structure		*/
	float	H, L, S;	/* HLS values from color table		*/
	float	R, G, B;	/* red, green, and blue equivalents	*/
	int	status;		/* return status			*/
	short	mode;		/* color mode of emulator		*/
	short	i;		/* loop index				*/
	int	vs_no;		/* virtual screen number		*/

	/* Determine the number of available bit planes. */
	vs_no = _EMGetScreenNumber (state_table);

	mode = _EMGetColorMode (state_table);

	/* Place the color table into the new vlt. */
	for (i = 0; i < 4; i++)
	{
	    status = _EMReadColorTable (state_table, i, &H, &L, &S, mode);

	    if (status == VALID_LOCATION)
	    {
		_EMHLSToRGB (H, L, S, &R, &G, &B);
		vlt[i].v_slot = i + VLT_OFFSET + _EMFixedVLTOffset[vs_no];
		vlt[i].v_red = (unsigned short) (65535 * R);
		vlt[i].v_green = (unsigned short) (65535 * G);
		vlt[i].v_blue = (unsigned short) (65535 * B);
	    }
	}

	Loadvlt (vs_no, vlt, 4);

	/* Set up the vlt so text selection looks reasonable */
	_EMSetTextSelectColors (state_table);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetScreenNumber				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetScreenNumber (state_table, vs_no)			*/
/*									*/
/*	  ReGIS_state  *state_table;	-- pointer to table		*/
/*	  int vs_no;			-- virtual screen number	*/
/*									*/
/*	RETURNED VALUE:	none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function places the given vs number in the state table.	*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMSetScreenNumber (state_table, vs_no)

ReGIS_state	*state_table;
int		vs_no;
{
	state_table->screen_number = vs_no;
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetScreenNumber				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMSetScreenNumber (state_table)				*/
/*									*/
/*	  ReGIS_state  *state_table -- pointer to table to read from	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  The screen number is returned.				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the virtual screen number on which the  */
/*	  emulator window is being displayed.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMGetScreenNumber (state_table)

ReGIS_state	*state_table;
{
	return (state_table->screen_number);
}	

/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetWindowNumber				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetWindowNumber (state_table, window_number)		*/
/*									*/
/*	  ReGIS_state  *state_table   -- pointer to table to be updated	*/
/*	  int		window_number -- window in which the emulator   */
/*					   is executing			*/
/*									*/
/*	RETURNED VALUE:	none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function stores the number of the window in which the    */
/*	  emulator is executing in the state table.			*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetWindowNumber (state_table, window_number)

ReGIS_state	*state_table;
int		window_number;
{
	state_table->window_number = window_number;
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetWindowNumber				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMGetWindowNumber (state_table)				*/
/*									*/
/*	  ReGIS_state  *state_table -- pointer to table to be read from	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  The window number in the state table is returned.		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the window number stored in the state	*/
/*	  table.							*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMGetWindowNumber (state_table)

ReGIS_state	*state_table;
{
	return (state_table->window_number);
}	


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetTextSelectColors				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetTextSelectColors (state_table)			*/
/*									*/
/*	  ReGIS_state  *state_table -- pointer to table			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function attempts to set up the colors so the text	*/
/*	  flipblock functions as well as possible.  The colors in the	*/
/*	  ReGIS state table are mirrored so that the flipblock looks	*/
/*	  OK.  If the colors will run into the RGB color indices, they	*/
/*	  are not set in the vlt.					*/
/*									*/
/*	RETURNED VALUE:							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMSetTextSelectColors (state_table)

ReGIS_state	*state_table;
{
	struct vlt_slot f_vlt[4], t_vlt[4];
	int t_index, f_index, i, planes, count, vs_no;

	vs_no = _EMGetScreenNumber (state_table);
	planes = _EMScreenInfo[vs_no].vsi_num_planes;

	Readvlt (vs_no, f_vlt, 4, VLT_OFFSET + _EMFixedVLTOffset[vs_no]);

	for (i = 0, count = 0; i < 4; i++)
	{
	    switch (i)		/* calculate the index to mirror from */
	    {
		case BACK_CT_INDEX:
		    f_index = FORE_CT_INDEX;
		    break;

		case FORE_CT_INDEX:
		case BOLD_CT_INDEX:
		    f_index = BACK_CT_INDEX;
		    break;

		default:
		    f_index = BACK_CT_INDEX;
		    break;
	    }

	    /* calculate the index to mirror to */
	    t_index = ((i + VLT_OFFSET + _EMFixedVLTOffset[vs_no]) ^ 0xFF) &
		      ((1 << planes) - 1);

	    /* change it iff it does not run into the RGB table */
	    if ((t_index < RGB_VLT_OFFSET + _EMFixedVLTOffset[vs_no]) ||
		(t_index >= RGB_VLT_OFFSET + _EMFixedVLTOffset[vs_no] + 8))
	    {
		t_vlt[count].v_slot = t_index;
		t_vlt[count].v_red = f_vlt[f_index].v_red;
		t_vlt[count].v_green = f_vlt[f_index].v_green;
		t_vlt[count].v_blue = f_vlt[f_index].v_blue;
		count++;
	    }
	}

	Loadvlt (vs_no, t_vlt, count);

	return (EM_NO_ERROR);
}
