/*
	I/STRUCT
*/
class implementation EMSplane ;

#include "msdef.h"
#include "ma.h"
#include "bserr.h"
#include "bstypes.h"
#include "growner.h"
#include "emssfintdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "malswcmx.h"
#include "matypemx.h"
#include "mawclsmx.h"
#include "bscrossp.h"
#include "bsorthovec.h"
#include "bsptinbx.h"
#include "vsiscvabvpln.h"
#include "vsplcontncrv.h"
#include "vsvecmxproto.h"

extern OMuword		OPP_EMSplane_class_id ;
/*----------------------------------------------------------------------------*/
void VScreatePlaneCS( plane, l2w, w2l )

struct IGRplane		*plane ;	/* Input plane			*/
IGRmatrix		l2w,		/* Matrix world -> plane CS	*/
			w2l ; {		/* Matrix plane CS -> world	*/

	long		msg ;
	int		i ;		/* Loop index			*/
	IGRvector	xvec,		/* Vector normal to plNormal	*/
			yvec ;		/* Vector normal to both above	*/
	IGRmatrix	rotmx ;		/* Rot matrix, no translation	*/

	/*
         * Create system of axes x, y and z = plNormal, local to the curve's
	 * plane.
	 */
	BSorthovec( &msg, plane->normal, xvec ) ;
	BScrossp( &msg, plane->normal, xvec, yvec ) ;

	MAidmx( &msg, rotmx ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		rotmx[4*i+0] = xvec[i] ;
		rotmx[4*i+1] = yvec[i] ;
		rotmx[4*i+2] = plane->normal[i] ;
	}

	/*
	 * Create tranformation matrices world <-> plane CS.
	 */
	MAwclsmx( &msg, plane->point, rotmx, w2l ) ;
	MAlswcmx( &msg, plane->point, rotmx, l2w ) ;

} /* VScreatePlaneCS */
/*----------------------------------------------------------------------------*/
long VSplaneContainingCurve( msg, curve, more, cst, plane )

long			*msg ;
struct GRobj_env	*curve ;
double			more ;
struct GRvg_construct	*cst ;
struct GRid		*plane ; {

	/*
	 * NOTE: the input curve is supposed to be planar.
	 */
	long		sts ;
	GRrange		cvRange ;	/* Range of curve		*/
	struct IGRplane	cvPlane ;	/* Plane of curve		*/
	IGRvector	plNormal ;	/* Normal to plane of curve	*/
	IGRpoint	plPoint,	/* Point on plane of curve	*/
			corners[3],	/* 3 corners of rng box in pl CS*/
			plDefPts[3] ;	/* Points defining new plane	*/
	IGRmatrix	w2l,		/* Matrix world -> plane CS	*/
			l2w ;		/* Matrix plane CS -> world	*/
	short		type ;		/* Type of matrix w2l		*/
	int		i ;		/* Loop index			*/
	IGRboolean	world = TRUE ;	/* For GRgetrang		*/

	cvPlane.normal	= plNormal;
	cvPlane.point	= plPoint ;

	sts = om$send(	msg	= message GRvg.GRdetplane(
							msg,
							&curve->_matrix_type,
							curve->_matrix,
							&cvPlane ),
			senderid= curve->_objid,
			targetid= curve->_objid,
			targetos= curve->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;

	/*
         * Create system of axes x, y and z = plNormal, local to the curve's
	 * plane.
	 */
	VScreatePlaneCS( &cvPlane, l2w, w2l ) ;

	MAtypemx( msg, w2l, &type ) ;
	/*
	 * Get range of curve in the CS of the plane of the curve.
	 */
	sts = om$send(	msg	= message GRgraphics.GRgetrang(
					msg, &type, w2l, &world, cvRange ),
			senderid= curve->_objid,
			targetid= curve->_objid,
			targetos= curve->_osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	/*
	 * Extend range box in plane CS's x- and y-directions.
	 */
	cvRange[0+0] -= more ; cvRange[0+1] -= more ;
	cvRange[3+0] += more ; cvRange[3+1] += more ;

	/*
	 * Choose 3 corners of range box.
	 */
	VSvccpy( corners[0], cvRange + 0 ) ;
	VSvccpy( corners[2], cvRange + 3 ) ;
	VSvccpy( corners[1], cvRange + 0 ) ;
	corners[1][1] = corners[2][1] ;

	/*
	 * Project the 3 corners on the plane of the curve. Since we are in
	 * local co-ordinates here and that the plane's normal is the z-axis,
	 * it amounts to zeroing out the z-co-ordinate of the corners.
	 */
	corners[0][2] = corners[1][2] = corners[2][2] = 0 ;

	/*
	 * Now get co-ordinates of projections of corners in the world CS.
	 */
	for( i = 0 ; i < 3 ; i++ ) {
		VSmxprodpt( l2w, corners[i], plDefPts[i] ) ;
	}

	/*
	 * Now construct plane.
	 */
	plane->osnum = cst->env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_EMSplane_class_id,
				p_objid	= &plane->objid,
				osnum	= plane->osnum ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	sts = om$send(	msg	= message EMSplane.EMplane(
						(int *) msg, cst, plDefPts, 0 ),
			senderid= plane->objid,
			targetid= plane->objid,
			targetos= plane->osnum ) ;
	__CheckRC( sts, *msg, "EMSplane.EMplane", wrapup ) ;

	wrapup :
		return sts ;

} /* VSplaneContainingCurve */
/*----------------------------------------------------------------------------*/
long VSisCvAbovePlane( msg, curve, plane, more, abovePlane )

long			*msg ;
struct GRobj_env	*curve,
			*plane ;
double			more ;
int			*abovePlane ; {

	/*
	 * Tests whether a curve is above or on a plane, ie. if it is planar,
	 * if the curve plane is parallel to the input plane and if the curve
	 * does not go outside the boundaries of the plane:
	 *
	 *    ------------ cv	 ------------ cv ----------- cv   ------ pl
	 * ----------------- pl     ------ pl      ---------- pl         ---- pl
	 *         OK               not OK            not OK        not OK
	 * The input curve is already supposed here
	 * - to be planar
	 * - that its plane is // to the input plane.
	 */

	long		sts ;
	struct IGRplane	inPlane ;	/* Definition of input plane	*/
	IGRpoint	ipPoint ;	/* Point on input plane		*/
	IGRvector	ipNormal ;	/* Normal to input plane	*/
	IGRmatrix	w2l,		/* Matrix world -> in. plane CS	*/
			l2w ;		/* Matrix in. plane CS -> world	*/
	GRrange		cvRange,	/* Range of curve		*/
			ipRange ;	/* Range of input plane		*/
	IGRboolean	world = TRUE ;	/* For GRgetrang		*/
	short		type ;		/* Type of matrix w2l		*/
	int		two = 2 ;

	*abovePlane = FALSE ;

	inPlane.point = ipPoint ; inPlane.normal = ipNormal ;

	sts = om$send(	msg	= message GRvg.GRdetplane(
							msg,
							&plane->_matrix_type,
							plane->_matrix,
							&inPlane ),
			senderid= plane->_objid,
			targetid= plane->_objid,
			targetos= plane->_osnum ) ;
	__CheckRC( sts, *msg, "EMplane.EMplaneDef", wrapup ) ;

	/*
         * Create system of axes x, y and z = plNormal, local to the input
	 * plane.
	 */
	VScreatePlaneCS( &inPlane, l2w, w2l ) ;

	MAtypemx( msg, w2l, &type ) ;

	/*
	 * Get range of curve and input plane in the CS of the input plane.
	 */
	sts = om$send(	msg	= message GRgraphics.GRgetrang(
					msg, &type, w2l, &world, cvRange ),
			senderid= curve->_objid,
			targetid= curve->_objid,
			targetos= curve->_osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	sts = om$send(	msg	= message GRgraphics.GRgetrang(
					msg, &type, w2l, &world, ipRange ),
			senderid= plane->_objid,
			targetid= plane->_objid,
			targetos= plane->_osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	/*
	 * Extend range box of curve in plane CS's x- and y-directions, if
	 * `more' is non-zero we'll have a bigger box (this is to make sure in
	 * some cases that some curve parts are not too close to the plane's
	 * boundaries ).
	 */
	cvRange[0+0] -= more ; cvRange[0+1] -= more ;
	cvRange[3+0] += more ; cvRange[3+1] += more ;

	/*
	 * Zero out z-coordinates of the range points of the curve, in case
	 * the box is not `flat' since, the curve being planar, it has no range
	 * in the local z-direction. Same for the range box of the plane.
	 *
	 *   +-range box------+
	 *   | -cv------      |       ==>	-cv------
	 *   +----------------+
	 *
	 * -----ip---------------           --+-range box------+-- ip
	 *
	 * NOTE: we do not actually zero out but just call `BSptinbx' with
	 * the points' dimension set to 2, so it will only compare the x- and
	 * y-co-ordinates.
	 */

	*abovePlane =  BSptinbx( msg, cvRange+0, ipRange+0, ipRange+3, &two )
		    && BSptinbx( msg, cvRange+3, ipRange+0, ipRange+3, &two ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSisCvAbovePlane */
/*----------------------------------------------------------------------------*/

end implementation EMSplane ;
