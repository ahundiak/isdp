/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "bstypes.h"
/*
 * Includes of function prototypes.
 */
#include "marptsxfo.h"
#include "maoptsxfo.h"
/*----------------------------------------------------------------------------*/
int VSxformCurve( msg, mxType, mx, curve )

/*
 * Given a transformation matrix and type, applies it to a B-spline curve
 * geometry.
 * This function is interfaced by macro vs$xform_curve.
 */

long			*msg ;
short			mxType ;
IGRmatrix		mx ;
struct IGRbsp_curve	*curve ; {

	if( curve->rational ) {
		MArptsxform(	msg,
				&curve->num_poles,
				&curve->rational,
				curve->weights,
				mx,
				curve->poles,
				curve->poles ) ;
	} else {
		MAoptsxform(	msg,
				&curve->num_poles,
				&mxType,
				mx,
				curve->poles,
				curve->poles ) ;
	}
	return *msg & 1 ;

} /* VSxformCurve */
/*----------------------------------------------------------------------------*/

