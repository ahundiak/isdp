/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "bstypes.h"
#include "bserr.h"
#include "msdef.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "gr.h"			/* Structs GR* for graphic info	*/
#include "EMSmsgdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "matypemx.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bsfndstrort.h"
#include "bsorthovec.h"
#include "bstst_plan.h"
#include "bsunwght_p.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
int VSisPlanarCurveClockwise( msg, cvGeom, cvId, cvEnv, refVector, isClockwise )

/*
 * Determines if the input curve, supposed planar, is oriented clockwise or
 * counter-clockwise with respect to the normal vector of its plane.
 * This function will fail for line segments.
 * This functiuon is interfaced by macro vs$isPlanarCurveClockwise defined
 * in "vsgeommacros.h".
 */

long			*msg ;
struct IGRbsp_curve	*cvGeom ;
struct GRid		*cvId ;
struct GRmd_env		*cvEnv ;
IGRvector		refVector ;
int			*isClockwise ; {

	int		nbPoles,
			freeGeom = FALSE ;
	double		*unwghtp	= NULL,
			*poles		= NULL,
			*weights ;
	IGRvector	zcv,
			xcv,
			ycv ;
	IGRboolean	isPlanar,
			isCounterClockwise ;
	short		mxType ;
	IGRmatrix	mx ;

#define	XCOORD	0
#define YCOORD	1

	if( !cvGeom ) {
		if( cvId && cvEnv ) {
			vs$get_geometry(	msg	= msg,
						grobjId	= cvId,
						grobjEnv= cvEnv,
						geometry= &cvGeom ) ;
			if( !( *msg & 1 ) ) goto wrapup ;
			freeGeom = TRUE ;
		} else {
			*msg = MSINARG ; goto wrapup ;
		}
	}
	nbPoles	= cvGeom->num_poles ;
	poles	= cvGeom->poles ;
	weights	= cvGeom->weights ;
	/*
	 * Get normal to curve's plane. NOTE: BStst_plan will say a line segment
	 * is not planar.
	 */
	BStst_plan( nbPoles, poles, weights, &isPlanar, zcv, msg ) ;
	if( BSERROR( *msg )	) { *msg = EMS_E_BSerror    ; goto wrapup ; }
	if( !isPlanar		) { *msg = EMS_E_InvalidArg ; goto wrapup ; }

	if( BSdotp( msg, zcv, refVector ) < 0 ) VSnegvc( zcv, zcv ) ;

	/*
	 * Get two unit vectors in curve's plane such that ( xcv, ycv, zcv )
	 * is a direct orthonormal basis.
	 */
	BSorthovec( msg, zcv, xcv ) ;
	BScrossp( msg, zcv, xcv, ycv ) ;

	/*
	 * Map curve to world's xy-plane, such that `zcv' and the z-axis
	 * vector coincide.
	 */
	mx[ 0] = xcv[0] ; mx[ 1] = xcv[1] ; mx[ 2] = xcv[2] ; mx[ 3] = 0 ;
	mx[ 4] = ycv[0] ; mx[ 5] = ycv[1] ; mx[ 6] = ycv[2] ; mx[ 7] = 0 ;
	mx[ 8] = zcv[0] ; mx[ 9] = zcv[1] ; mx[10] = zcv[2] ; mx[11] = 0 ;
	mx[12] = 0      ; mx[13] = 0      ; mx[14] = 0      ; mx[15] = 1 ;

	MAtypemx( msg, mx, &mxType ) ;

	vs$xform_curve(	msg		= msg,
			mxType		= mxType,
			transMx 	= mx,
			curveGeom	= cvGeom ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	if( cvGeom->rational ) {
		long	npoles = nbPoles ;

		unwghtp = (double *) malloc( nbPoles * sizeof( IGRpoint ) ) ;
		if( !unwghtp ) {
			*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
		}
		BSunwght_p( msg, poles, weights, &npoles, unwghtp ) ;
	} else {
		unwghtp = poles ;
	}

	/*
	 * Closed curves have the 1st and last pole repeated, but `BSfndstrort'
	 * does not accept duplicate points.
	 */
	BSfndstrort(	XCOORD,
			YCOORD,
			cvGeom->phy_closed ? ( nbPoles - 1 ) : nbPoles,
			(IGRpoint *) unwghtp,
			&isCounterClockwise,
			msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_InvalidArg ; goto wrapup ; }

	*isClockwise = ! isCounterClockwise ;

	*msg = MSSUCC ;
	wrapup :
		if( unwghtp && unwghtp != poles ) {
			free( (char *) unwghtp ) ;
		}
		if( freeGeom ) _FREE( cvGeom ) ;
		return *msg & 1 ;

} /* VSisPlanarCurveClockwise */
/*----------------------------------------------------------------------------*/

