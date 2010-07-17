class implementation VLabstract;

#include	<stdio.h>
#include	"vlprototype.h"
#include	<math.h>

/* ========================================================================== */
/*	This function overrides atan2() defined </usr/include/math.h>.	      */
/*	In case of quasi-null value of 2nd argument (cos), a null value is    */
/*	returned. This solve undefined returns.				      */
/* ========================================================================== */

IGRdouble	VLatan2 (	IGRdouble	sin,
				IGRdouble	cos	)
{
	IGRdouble	val=0.0;

	if (fabs(cos) > 0.0)	val = atan2 ( sin, cos);

	return (val);
}
/* ========================================================================== */

end implementation VLabstract;
