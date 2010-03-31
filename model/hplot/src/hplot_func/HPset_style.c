#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"


static	double	style0[7] = { 81.28,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00 };
static	double	style1[7] = {  5.08, 15.24,  0.00,  0.00,  0.00,  0.00,  0.00 };
static	double	style2[7] = { 20.32, 10.16, 15.24, 10.16, 15.24, 10.16,  0.00 };
static	double	style3[7] = { 30.48, 10.16,  0.00,  0.00,  0.00,  0.00,  0.00 };
static	double	style4[7] = { 45.72, 15.24,  5.08, 15.24,  0.00,  0.00,  0.00 };
static	double	style5[7] = { 10.16, 10.16,  0.00,  0.00,  0.00,  0.00,  0.00 };
static	double	style6[7] = { 25.40, 15.24,  5.08, 15.24,  5.08, 15.24,  0.00 };
static	double	style7[7] = { 45.72, 10.16, 15.24, 10.16,  0.00,  0.00,  0.00 };

extern double	*style;

/*---HPset_line_style--------------------------------------------------*/

/*
NAME
	HPset_line_style
	
KEYWORDS
	HSplot
	style
	
DESCRIPTION
	Set the active line style to one of the 8 pre-defined styles.
	
PARAMETERS
	line_style_index	:(IN) :  Line style index 0-7
	
GLOBALS USED
	style0-7	: The 8 pre-defined line styles
	style		: pointer to the active style
	
NOTES
	I don't think this is being called any more
	
HISTORY	
	??/??/??	M. Lanier
		Created
*/


#if defined(__STDC__) || defined(__cplusplus)
	HPset_line_style( int	line_style_index )
#else
	HPset_line_style( line_style_index )

	int	line_style_index;
#endif

	{
	switch( line_style_index )
		{
		case 0:
			style = style0;
			break;
					
		case 1:
			style = style1;
			break;
					
		case 2:
			style = style2;
			break;
					
		case 3:
			style = style3;
			break;
					
		case 4:
			style = style4;
			break;
					
		case 5:
			style = style5;
			break;
					
		case 6:
			style = style6;
			break;
					
		case 7:
			style = style7;
			break;
					
		};
	}


