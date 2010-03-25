#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMFont.h"
#include "../hfiles/EMError.h"


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMLoadFont					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMLoadFont (TCB, attr, type_offset, status)	  	*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  unsigned char	attr;	-- attribute mask of current character	*/
/*	  int     type_offset;	-- font-type offset for current row	*/
/*	  int	  *status;	-- returned status code:  a -1		*/
/*	  			     indicates that the font could	*/
/*				     not be loaded			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function loads a specified font, places the font		*/
/*	  descriptor in the appopriate slot of the TCB's font table,    */
/*	  and also returns the font descriptor.  If the font cannot	*/
/*	  be loaded, "status" is set to -1 and the font descriptor	*/
/*	  of the default font is returned.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A font descriptor is returned. 				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int _EMLoadFont (TCB, attr, type_offset, status)

EM_TCB		*TCB;
unsigned char	attr;
int		type_offset;
int		*status;
{
	int	active_offset;
	int	fstatus;

	active_offset = type_offset;
	*status = 0;

	if (attr & CHAR_GRAPHICS)
	    active_offset += GRAPHICS_OFFSET;

	if (*(TCB->font_table + active_offset) < 0)
	{
	    if (TCB->term_settings.eighty)
	    {
		fstatus = Load_symbol_file(EMfont_name_80[active_offset],
					   &TCB->font_table_80[active_offset]);
		if (fstatus)
		{
		    *status = -1;
		    active_offset = 0;
		    type_offset = 0;
		}
	    }
	    else
	    {
		fstatus = Load_symbol_file (EMfont_name_132[active_offset],
					&TCB->font_table_132[active_offset]);
		if (fstatus)
		{
		    *status = -1;
		    active_offset = 0;
		    type_offset = 0;
		}
	    }
	}

	if (type_offset > DHSWBOT_OFFSET) 	/* chars are double wide */
	{
	    if (TCB->term_settings.eighty)
		TCB->active_width = TCB->char_width[1];
	    else
		TCB->active_width = TCB->char_width[3];
	}
	else
	{
	    if (TCB->term_settings.eighty)
		TCB->active_width = TCB->char_width[0];
	    else
		TCB->active_width = TCB->char_width[2];
	}

	return(*(TCB->font_table + active_offset));
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetFont					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMSetFont (TCB, font_type)				*/
/*									*/
/*	  EM_TCB  *TCB;	     	-- pointer to active TCB		*/
/*	  int	  font_type; 	-- F => text font			*/
/*				   T => graphics font			*/
/*									*/
/*	DESCRIPTION:							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMSetFont (TCB, font_type)

EM_TCB	*TCB;
int	font_type;
{
	int	status;		/* status returned by "_EMLoadFont"	*/

	if (font_type)
	{
	    _EMLoadFont (TCB, CHAR_GRAPHICS, 0, &status);

	    if (! status)
	    {
		TCB->active_attributes.normal = FALSE;
		TCB->active_attributes.graphics = TRUE;
	    }
	}
	else
	{
	    TCB->active_attributes.graphics = FALSE;

	    if ((! TCB->active_attributes.bold) &&
		(! TCB->active_attributes.blinking) &&
		(! TCB->active_attributes.underline) &&
		(! TCB->active_attributes.reverse) &&
		(! TCB->active_attributes.color))
		TCB->active_attributes.normal = TRUE;
	}
}
