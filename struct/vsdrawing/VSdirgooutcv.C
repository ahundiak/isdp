/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMprimitives.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMerrordef.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bscrossp.h"
#include "bscveval.h"
#include "bscvnormal.h"
#include "bsfreecv.h"
#include "bslngen.h"
#include "bsmerge_cv.h"
#include "bsprptoncv.h"
#include "bspt_in_cv.h"
#include "maaddvc.h"
#include "vsvecmxproto.h"

extern long	VSallocForBSmerge_cv(	long*,
					struct IGRbsp_curve*,
					struct IGRbsp_curve*,
					struct IGRbsp_curve** ) ;
/*----------------------------------------------------------------------------*/
long VSfindDirectionToGoOutsideCurve( msg, cvGeom, ptOnCv, direction )

long			*msg ;
struct IGRbsp_curve	*cvGeom ;
IGRpoint		ptOnCv ;
IGRvector		direction ; {

	/*
	 * Given a XY planar curve ( cvGeom ), a point on the curve ( ptOnCv ),
	 * this function returns a vector ( direction ) to go outside the
	 * curve from the input point.
	 *
	 *     .----------------------	<- curve.
	 *	.		     |
	 *	 .		     *	<- point on the curve.
	 *	  .		     |
	 *	   .		     |
	 *	    .-----------------
	 *
	 *		----> returned direction vector.
	 *
	 * Notes :
	 * =======
	 *	- If the input curve is linear, this function returns
	 *	  '*msg = EMS_E_InvalidArg' and 'sts = OM_E_INVARG'.
	 *	- If the input curve is not closed, this function closes it
	 *	  (...) and processes the closed curve.
	 */

	long		sts,		/* OM return code.		      */
			bsRC ;		/* BS return code.		      */
	struct IGRbsp_curve
			*wkGeom,	/* Geometry of closed curve.	      */
			*lnGeom ;	/* Geometry of line segment from      */
					/* first to last point of input       */
					/* curve if it's not closed.	      */
	IGRpoint	ptAt0,		/* Start point of input curve.	      */
			ptAt1,		/* End point of input curve.	      */
			tangent[2],	/* Tangent at input point on closed   */
					/* curve.			      */
			ptTest ;	/* Point test to see if it's outside  */
					/* closed curve.		      */
	IGRvector	normal ;	/* Normal of closed curve.	      */
	double		pm,		/* Parameter of input point on        */
					/* closed curve.		      */
			tollenvec ;	/* Minimum vector length.	      */
	IGRboolean	on_curve,	/* Is input point really on closed    */
					/* curve ?			      */
			pos_orient ;	/* Unused, just for BSpt_in_cv().     */
	int		ind ;		/* Point test outside closed curve ?  */

	SetProc( VSfindDirectionToGoOutsideCurve ); Begin

	__DBGpr_vec( "Point to find direction", ptOnCv ) ;

	wkGeom = lnGeom = NULL ;

	/*
	 * See if the input curve is linear.
	 */
	if( vs$is_curve_linear( msg = msg, curveGeom = cvGeom ) ) {
		__DBGpr_com( "Curve is linear" ) ;
		vs$inv_arg() ;
	}

	/*
	 * Close the input curve if it's not closed.
	 */
	if( !cvGeom->phy_closed ) {
		int	type ;

		__DBGpr_com( "Curve not closed -> close it" ) ;

		/*
		 * Find end points of input curve.
		 */
		BScveval( cvGeom, 0., 0, (IGRpoint *) ptAt0, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		BScveval( cvGeom, 1., 0, (IGRpoint *) ptAt1, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		/*
		 * Construct a line segment from first to last points of
		 * input curve.
		 */
		BSalloccv( 2,
			   2,
			   FALSE,
			   0,
			   &lnGeom,
			   &bsRC ) ;

		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		BSlngen( &bsRC, ptAt0, ptAt1, lnGeom, &type ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		/*
		 * Merge the input curve and the above line segment.
		 */
		sts = VSallocForBSmerge_cv( msg, cvGeom, lnGeom, &wkGeom ) ;
		__CheckRC( sts, *msg, "VSallocForBSmerge_cv", wrapup ) ;

		BSmerge_cv( &bsRC, cvGeom, lnGeom, wkGeom ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	} else {
		__DBGpr_com( "Curve is closed" ) ;
		wkGeom = cvGeom ;
	}

	/*
	 * Find normal of closed curve.
	 */
	BScvnormal( &bsRC, wkGeom, normal ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	__DBGpr_vec( "Normal of closed curve", normal ) ;

	/*
	 * Find parameter of input point on closed curve.
	 */
	BSprptoncv( &bsRC, wkGeom, ptOnCv, &pm, &on_curve ) ;
	if( BSERROR( bsRC ) || !on_curve ) vs$error( msgval = EMS_E_BSerror ) ;

	__DBGpr_dbl( "Parameter of point on closed curve", pm ) ;

	/*
	 * Find tangent at input point on closed curve.
	 */
	BScveval( wkGeom, pm, 1, tangent, &bsRC ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	__DBGpr_vec( "Tangent", tangent[1] ) ;

	/*
	 * If the point test ( input point + ( (normal X tangent) scaled with
	 * 5*tollenvec ) ) is outside the closed curve, the direction vector
	 * is ( normal X tangent ). Otherwise is -( normal X tangent ).
	 */
	BSEXTRACTPAR( &bsRC, BSTOLLENVEC, tollenvec ) ;

	BScrossp( &bsRC, normal, tangent[1], direction ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	BSnorvec( &bsRC, direction ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	MAaddvc( msg,
		 ptOnCv,
		 VSscalvc( 5*tollenvec, direction, direction ),
		 ptTest ) ;

	__DBGpr_vec( "Point test", ptTest ) ;

	BSpt_in_cv( wkGeom,
		    ptTest,
		    FALSE,
		    &pos_orient,
		    &ind,
		    &bsRC ) ;

	if( BSERROR( bsRC ) || 2 == ind ) vs$error( msgval = EMS_E_BSerror ) ;

	if( 1 == ind ) {
		__DBGpr_com( "Direction is -( normal X tangent )" ) ;
		VSnegvc( direction, direction ) ;
	} else	__DBGpr_com( "Direction is ( normal X tangent )" ) ;

	BSnorvec( &bsRC, direction ) ;
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	__DBGpr_vec( "Direction vector", direction ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) VSzerovc( direction ) ;

		if( wkGeom && wkGeom != cvGeom ) BSfreecv( &bsRC, wkGeom ) ;
		if( lnGeom		       ) BSfreecv( &bsRC, lnGeom ) ;

		End
		return sts ;

} /* VSfindDirectionToGoOutsideCurve */
/*----------------------------------------------------------------------------*/
