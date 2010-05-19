/*
	I/VDS	Copy
*/
#include <stdlib.h>
#include "bstypes.h"
#include "bserr.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "growner.h"
#include "EMSmsgdef.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bspl_cv_int.h"
#include "v_vecmxproto.h"
/*----------------------------------------------------------------------------*/
int VD_isPlaneClippingCurve( cvGeom, plane, firstIntPoint, firstIntPm )

const struct IGRbsp_curve	*cvGeom ;	
const struct IGRplane		*plane ;
IGRpoint			firstIntPoint ;
double				*firstIntPm ; {

	/*
	 * This function is interfaced by macro vd_$isPlaneClippingCurve
	 * defined in v_geommacros.h.
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
			if( firstIntPoint ) VD_vccpy( firstIntPoint, pnts ) ;
			if( firstIntPm    ) *firstIntPm = *u ;
		}
	} else clipping = FALSE ;

	_FREE( buffer ) ;

	wrapup :
		return clipping ;

} /* VD_isPlaneClippingCurve */
/*----------------------------------------------------------------------------*/

