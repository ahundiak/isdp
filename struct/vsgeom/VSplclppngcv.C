/*
	I/STRUCT
*/
#include <stdlib.h>
#include "bstypes.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bspl_cv_int.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
int VSisPlaneClippingCurve( cvGeom, plane, firstIntPoint, firstIntPm )

const struct IGRbsp_curve	*cvGeom ;	
const struct IGRplane		*plane ;
IGRpoint			firstIntPoint ;
double				*firstIntPm ; {

	/*
	 * This function is interfaced by macro vs$isPlaneClippingCurve
	 * defined in vsgeommacros.h.
	 */
	long			rc ;
	int			clipping	= FALSE,
				n,
				npoles,
				npts		= 0,
				nsegs		= 0 ;
	double			*buffer 	= NULL,
				*pnts,		/* Arguments for ...	*/
				*u,		/*			*/
				*a,		/*			*/
				*b ;		/* ... BSpl_cv_int.	*/

	/*
	 * Allocate memory for BSpl_cv_int.
	 */
	npoles = cvGeom->num_poles ;
	n = npoles * ( 3 /*pnts*/ + 1 /*u*/ + 1 /*a*/ + 1 /*b*/ ) ;
	if( !( buffer = _MALLOC( n, double ) ) ) goto wrapup ;

	pnts	= buffer ;
	u	= pnts + 3 * npoles ;
	a	= u    + npoles ;
	b	= a    + npoles ;

	BSpl_cv_int(	&rc,
			(struct IGRbsp_curve *) cvGeom,
			plane->point,
			plane->normal,
			&npts,
			pnts,
			u,
			&nsegs,
			a,
			b ) ;

	if( BSOKAY( rc ) ) {
		if( npts ) {
			clipping = TRUE ;
			if( firstIntPoint ) VSvccpy( firstIntPoint, pnts ) ;
			if( firstIntPm    ) *firstIntPm = *u ;
		}
	} else clipping = FALSE ;

	_FREE( buffer ) ;

	wrapup :
		return clipping ;

} /* VSisPlaneClippingCurve */
/*----------------------------------------------------------------------------*/

