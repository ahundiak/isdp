
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

/*#include "hsurf_import.h"*/
#include "stdlib.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrtypedef.h"
#include "hsmath.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macros.h"

#include "HSpr_display.h"

#if defined(__STDC__) || defined(__cplusplus)
	fixed_divide(	int dividend,		/* 32:0 */
			int divisor,		/* 32:0 */
			int *sign,
			int *quotient_w,	/* 32:0 */
			int *quotient_f )	/* 1:31 */
#else
	fixed_divide( dividend, divisor, sign, quotient_w, quotient_f )

	int	dividend;	/* 32:0 */
	int	divisor;	/* 32:0 */
	int	*sign;
	int	*quotient_w;	/* 32:0 */
	int	*quotient_f;	/* 1:31 */
#endif

    {
	*quotient_w = dividend / divisor;
	*quotient_f = (((dividend - divisor * *quotient_w) << 16) / divisor)
			<< 15;
	if (*quotient_w < 0)
	    {
	    *sign = -1;
	    *quotient_w = -*quotient_w;
	    *quotient_f = -*quotient_f;
	    }
	else if (*quotient_f < 0)
	    {
	    *sign = -1;
	    *quotient_f = -*quotient_f;
	    }
	else
	    {
	    *sign = 1;
	    }
    }
