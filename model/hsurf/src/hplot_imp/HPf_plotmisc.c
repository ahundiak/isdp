
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <string.h>
#include <FI.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "HSplot.h"
#include "HSplot_def.h"

#include "wl.h"
#include "HSpr_hplot.h"

/*---HPcvtsize-------------------------------------------------*/

/*
NAME
	HPcvtsize
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Convert the argument from one unit to another
	
PARAMETERS
	x	:(IN/OUT):  Value to convert
	old_unit:(IN)    :  old unit of x
	new_unit:(IN)    :  new unit of x
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HPcvtsize( IGRdouble *x,
			     IGRchar old_unit,
			     IGRchar new_unit )
#else
	IGRint	HPcvtsize( x, old_unit, new_unit )

	IGRdouble	*x;
	IGRchar		old_unit;
	IGRchar		new_unit;
#endif

	{
	IGRint		sts;
	IGRdouble	factor = 1.0;

	sts = PI_S_SUCCESS;

	switch( old_unit )
		{
		case UNIT_INCHES:
			switch( new_unit )
				{
				case UNIT_INCHES:
					factor = 1.0;
					break;
					
				case UNIT_CENTIMETERS:
					factor = 2.54; 
					break;
					
				case UNIT_METERS:
					factor = 0.0254; 
					break;
				};
				
			break;
			
		case UNIT_CENTIMETERS:
			switch( new_unit )
				{
				case UNIT_INCHES:
					factor = 0.3937;
					break;
					
				case UNIT_CENTIMETERS:
					factor = 1.0; 
					break;
					
				case UNIT_METERS:
					factor = 0.01; 
					break;
				};
				
			break;
			
		case UNIT_METERS:
			switch( new_unit )
				{
				case UNIT_INCHES:
					factor = 39.37;
					break;
					
				case UNIT_CENTIMETERS:
					factor = 100.0; 
					break;
					
				case UNIT_METERS:
					factor = 1.0; 
					break;
				};
				
			break;
			
		};
		
	*x *= factor;
	
	return( sts );
	}
