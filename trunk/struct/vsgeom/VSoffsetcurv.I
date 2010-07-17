/*
	I/STRUCT
*/
class implementation GRcurve ;

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maaddvc.h"
#include "bscrossp.h"
#include "bscveval.h"
#include "bsdistptpt.h"
#include "bsnorvec.h"
#include "vspratpt.h"
#include "vsvecmxproto.h"

extern OMuword		OPP_GRcompcurve_class_id ;

from	GRowner	import GRget_number_components ;
/*----------------------------------------------------------------------------*/
static long VSgetSideForCvToOffset( msg, cvEnv, cvId, normal, rightSide )

long		*msg ;
struct GRmd_env	*cvEnv ;
struct GRid	*cvId ;
IGRvector	normal ;
int		*rightSide ; {
	
	long			sts,
				rc ;
	struct IGRbsp_curve	*cvGeom = NULL ;
	GRrange			range ;
	IGRpoint		pntMin,
				pntMax,
				pnt1Min,
				pnt2Min,
				pnt1Max,
				pnt2Max ;
	IGRvector		crosspMin,
				crosspMax ;
	double			pmMin,
				pmMax,
				evalMin[6],
				evalMax[6],
				dist1,
				dist2 ;
	struct GRparms		pm ;
	short			rangInWld = TRUE ;
	
	*rightSide = FALSE ;
	
	/*
	 * Get range of curve.
	 */
	sts = om$send( msg      = message GRcurve.GRgetrang( 
						           msg,
						           &cvEnv->_MATRIX_TYPE,
						           cvEnv->_MATRIX,
						           &rangInWld,
						           range ),
		       senderid = cvId->objid,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRgetrang", wrapup ) ;
	
	/*
	 * Get tangents and points of range onto curve.
	 */
	sts = om$send( msg      = message GRcurve.GRptproject( 
	 						   msg,
							   &cvEnv->_MATRIX_TYPE,
						           cvEnv->_MATRIX,
						           range,
						           pntMin,
						           &pm ),
		       senderid = cvId->objid,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRptproject", wrapup ) ;

	sts = VSpratpt( msg, cvEnv, cvId->objid, pntMin, &pmMin ) ;
	__CheckRC( sts, *msg, "VSpratpt", wrapup ) ;

	sts = om$send( msg      = message GRcurve.GRptproject( 
	 						   msg,
							   &cvEnv->_MATRIX_TYPE,
						           cvEnv->_MATRIX,
						           range +3,
						           pntMax,
						           &pm ),
		       senderid = cvId->objid,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRptproject", wrapup ) ;

	sts = VSpratpt( msg, cvEnv, cvId->objid, pntMax, &pmMax ) ;
	__CheckRC( sts, *msg, "VSpratpt", wrapup ) ;

	sts = vs$get_geometry( msg	= msg,
			       grobjId  = cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;			       
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
	
	BScveval( cvGeom, pmMin, 1, (IGRpoint *) evalMin, &rc ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;
	
	BScveval( cvGeom, pmMax, 1, (IGRpoint *) evalMax, &rc ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	/*
	 * Compute cross product between tangents and given normal.
	 */
	BScrossp( &rc, evalMin +3, normal, crosspMin ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;
	
	BSnorvec( &rc, crosspMin ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	BScrossp( &rc, evalMax +3, normal, crosspMax ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;
	
	BSnorvec( &rc, crosspMax ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	/*
	 * Translate the two cross products and their opposites to the 
	 * corresponding point onto curve, to have two reference points 
	 * pnt1xxx and pnt2xxx for the two corners.
	 */
	MAaddvc( &rc, evalMin, crosspMin, pnt1Min ) ;
	MAaddvc( &rc, evalMin, VSnegvc( crosspMin, crosspMin ), pnt2Min ) ;

	MAaddvc( &rc, evalMax, crosspMax, pnt1Max ) ;
	MAaddvc( &rc, evalMax, VSnegvc( crosspMax, crosspMax ), pnt2Max ) ;
	
	/*
	 * If the distance between the first reference point min and the first
	 * reference point max is bigger than the distance between the second
	 * reference point min and the second reference point max, that means 
	 * the offset direction is outside the range of curve. Thus, right side
	 * should be TRUE.
	 */
	dist1 = BSdistptpt( &rc, pnt1Min, pnt1Max ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	dist2 = BSdistptpt( &rc, pnt2Min, pnt2Max ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;
		
	if( dist1 > dist2 ) {
		/* Offset direction is TANGENT x NORMAL */
		*rightSide = TRUE ;
	} else {
		/* Offset direction is -( TANGENT x NORMAL ) */
	}
	
	wrapup :
		_FREE( cvGeom ) ;
		return sts ;

} /* VSgetSideForCvToOffset */
/*----------------------------------------------------------------------------*/
long VSoffsetCurve( msg, cvEnv, cvId, offset, normal, cst, offCvId )

long			*msg ;
struct GRmd_env		*cvEnv ;
struct GRid		*cvId,
			*offCvId ;
struct GRvg_construct	*cst ;
double			offset ;
IGRvector		normal ; {

/*
 * This function interfaced by macro vs$offsetCurve
 */

	long		sts,			/* OM return code	*/
			cnt ;			/* Count of components	*/
	int		offCode = BSCONSTOFF,	/* How BS offsets	*/
			*p_offCode = NULL,
			rightSide ;
	double		*p_offset  = NULL ;
	struct IGResbc	esbc ;			/* Attributes of curve	*/
	IGRvector	cvNormal ;		/* Buffer for normal	*/
	char		*saveClassAttr ;

	/*
	 * Check that offset is beyond offset tolerance and positive.
	 */
	if( offset <= 0 ) offset = 0 ;
	else {
		double	offTol ; /* System's offset tolerance	*/

		BSEXTRACTPAR( msg, BSTOLOFFSET, offTol ) ;
		if( offset <= offTol ) offset = 0 ;
	}

	if( offset == 0. ) {
		*offCvId	= *cvId ;
		*msg		= EMS_I_Fail ;
		sts		= OM_S_SUCCESS ;
		goto wrapup ;
	}

	offCvId->objid = NULL_OBJID ;

	if( !normal ) {
		/*
		 * Normal not input : get it. Will fail if curve is not planar.
		 */
		struct IGRplane	cvPlane ;
		IGRpoint	ptOnPlane ;

		cvPlane.point	= ptOnPlane ;
		cvPlane.normal	= cvNormal ;
		
		sts = om$send(	msg	= message GRvg.GRdetplane(
							msg,
							&cvEnv->_MATRIX_TYPE,
							cvEnv->_MATRIX,
							&cvPlane ),
				senderid= cvId->objid,
				targetid= cvId->objid,
				targetos= cvId->osnum ) ;
		if( !( *msg & 1 ) ) {
			*msg = EMS_E_InvalidArg ;
			if( sts & 1 ) sts = OM_W_ABORT ;
			goto wrapup ;
		}
		normal = cvNormal ;
	}

	if( vs$is_ancestry_valid(	object	= cvId,
					classid	= OPP_GRcompcurve_class_id ) ) {
		int	count, i ;

		sts = om$send(
			msg	= message GRowner.GRget_number_components(
								msg, &count ),
			senderid= cvId->objid,
			targetid= cvId->objid,
			targetos= cvId->osnum ) ;

		if( !( p_offCode = _MALLOC( count, int    ) ) ) vs$mem_fail() ;
		if( !( p_offset  = _MALLOC( count, double ) ) ) vs$mem_fail() ;

		for( i = 0 ; i < count ; i++ ) {
			p_offCode[i]	= BSCONSTOFF ;
			p_offset [i]	= offset ;
		}
	} else {
		p_offCode	= &offCode ;
		p_offset	= &offset ;
	}
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &esbc ),
			senderid= cvId->objid,
			targetid= cvId->objid,
			targetos= cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	saveClassAttr	= cst->class_attr ;
	cst->class_attr = (char *) &esbc ;

	VSgetSideForCvToOffset( msg, cvEnv, cvId, normal, &rightSide ) ;
	sts = om$send(	msg	= message GRcurve.EMcvoffset(
							msg,
							&cvEnv->_MATRIX_TYPE,
							cvEnv->_MATRIX,
							cst,
			/* Offset distance	*/	p_offset,
			/* Normal vector	*/	normal,
			/* Right side		*/	rightSide,
			/* Uniform		*/	TRUE,
			/* Offset code		*/	p_offCode,
			/* Fillet		*/	FALSE,
			/* Remove loops		*/	TRUE,
			/* Offset curve		*/	offCvId,
			/* # of loops (unused)	*/	&cnt,
							NULL,
							NULL ),
			senderid= cvId->objid,
			targetid= cvId->objid,
			targetos= cvId->osnum ) ;

	cst->class_attr = saveClassAttr ;

	*msg = VSchgEMSseverity( *msg ) ;

	__CheckRC( sts, *msg, "GRcurve.EMcvoffset", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( p_offCode && p_offCode != &offCode ) {
			free( (char *) p_offCode ) ;
		}
		if( p_offset  && p_offset  != &offset  ) {
			free( (char *) p_offset  ) ;
		}

		return sts ;

} /* VSoffsetCurve */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;
