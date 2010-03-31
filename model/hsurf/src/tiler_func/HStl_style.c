
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"


/*---HSset_line_style--------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	HSset_line_style( int visible_style, int hidden_style )
#else
	HSset_line_style( visible_style, hidden_style )

	int	visible_style, hidden_style;
#endif

/**
NAME
	HSset_line_style
	
DESCRIPTION	
	Convert visible and hidden styles, represents as on/off bit 
	patterns, into arrays of millimeters on, millimeters off, to
	be used for RHL display
	
PARAMETERS
	visible_style	:(IN) : visible style index
	hidden_style	:(IN) : hidden style index
	
GLOBALS USED
	element_parms	: global structure containing element parameters
				releative to the current object.

HISTORY	
	??/??/??	M. Lanier
		Creation Date
		
**/


	{
	unsigned short	pattern;
	int		i;
	int		index;
	int		state;


	/*
	 *  Store the style indices in the element_parms structure
	 *  then convert the patterns to on/off millimeters
	 */
	 
	element_parms.visible_style = visible_style;
	element_parms.hidden_style = hidden_style;

	/*
	 *  get the bit pattern for the visible style and initialize
	 *  the visible array to 0.0.  An entry of 0.0 means end of
	 *  pattern so we don't want any old pattern hanging around.
	 */
	 	
	DPinq_style( visible_style, &pattern );
	
	for( i=0; i<9; i++ ) element_parms.v_pattern[i] = 0.0;

	/*
	 *  We will analyize the pattern  from left to right starting
	 *  at the high bit.  The pat_on_off flag tells us in the
	 *  first run is either on or off.
	 */
	 	
	state = pattern & 0x8000;
	element_parms.v_pat_on_off = state ? 1 : 0;
	index = 0;
	
	/*
	 *  Loop through all 16 bits accumulating multiples of 5.08 
	 *  millimeters for each on/off run.  5.08??? A numbers 
	 *  whose derivation is far to complex to  explain within 
	 *  the context of this source file. (IE. Your guess is as 
	 *  good as mine, and I dreamed the thing up! {ML}).
	 */
	 
	for( i=0; i<16; i++ )
		{
		if( (pattern & 0x8000) != state )
			{
			index++;
			state = (pattern & 0x8000);
			}

		element_parms.v_pattern[index] += 5.08;
		pattern <<= 1;
		}
	
	/*
	 *  Now do the same thing for the hidden style
	 */
	 
	DPinq_style( hidden_style, &pattern );
	
	for( i=0; i<9; i++ ) element_parms.h_pattern[i] = 0.0;
	
	state = pattern & 0x8000;
	element_parms.h_pat_on_off = state ? 1 : 0;
	index = 0;
	for( i=0; i<16; i++ )
		{
		if( (pattern & 0x8000) != state )
			{
			index++;
			state = (pattern & 0x8000);
			}

		element_parms.h_pattern[index] += 5.08;
		pattern <<= 1;
		}
	}

