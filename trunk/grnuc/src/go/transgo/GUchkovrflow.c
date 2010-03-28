/* #######################    APOGEE COMPILED   ######################## */

#include "grimport.h"
#include "igrtypedef.h"
#include "madef.h"
#include "godef.h"
#include "msdef.h"


/*
 *  This function will check an array doubles to see if they
 *  will overflow when converted to integer values.  If any
 *  of the values will overflow, FALSE is returned and msg is 
 *  set to MSFAIL.  Also, if the absolute value of the double 
 *  that will cause overflow is greater than max_overflow, then
 *  max_overflow is set to that absloute value.  Otherwise, TRUE
 *  is returned and msg is set to MSSUCC.
 */


IGRboolean GUcheck_overflow ( msg, num_values, values, max_overflow )

IGRlong		*msg;		/* return message			*/
IGRlong		*num_values;	/* number of values to be checked	*/
IGRdouble	*values;	/* array of values to check		*/
IGRdouble	*max_overflow;	/* maximum absolute value which has	*/
				/* caused an overflow			*/

{
    IGRint	i;
    IGRdouble	abs_value;
    IGRboolean	status = TRUE;

    *msg = MSSUCC;

    for ( i = 0; i < *num_values; i++ )
    {
    	/*
    	 *  Check for integer overflow.
    	 */
 
    	if ( values[i] < GRDGNLIMITS_MIN_I  ||  values[i] > GRDGNLIMITS_MAX_I )
    	{
	    *msg = MSFAIL;
	    status = FALSE;
	    abs_value = values[i];
	    abs_value = MAabsolute ( abs_value );
	    if ( abs_value > *max_overflow )
	    {
		*max_overflow = abs_value;
	    }
	
    	}
    }

    return ( status );

}
