/*
	I/STRUCT
*/ 
class implementation VSrfsBeam ;

#include "bstypes.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vsrfldef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "vsaddmodattr.h"
/*----------------------------------------------------------------------------*/
method VSimportData( long *msg ; int placement ; struct GRobj_env *fromBeam ) {

	long			sts ;		/* OM return code	*/
	IGRvector		xDir ;
	int			haveDir,
				xDirReversed ;
	struct GRid		myUsrAttr ;

	xDirReversed = 0 ;

	sts = om$send(
		msg	= message VSbeam.VSgetXdirectionForCrossSectionCS(
							msg, &haveDir, xDir ),
		targetid= fromBeam->_objid,
		targetos= fromBeam->_osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetXdirectionForCrossSectionCS", wrapup ) ;

	if( haveDir ) {
		long		bsRC ;
		VSsuppList	frBmSupps ;
		int		count ;
		VSpartAttr	part ;	/* From-beam's part attributes	   */
		VSbeamAttr	fbAttr ;/* From-beam's attributes	   */
		IGRpoint	pntAtX ;/* Point of section on curve	   */
		IGRvector	tanAtX,	/* Tangent to curve at section 	   */
				normAtX,/* Surface normal at section	   */
				xvcAtX ;/* xvcAtX = normAtX ^ tanAtX	   */

		sts = om$send(	msg	= message VSpart.VSgetSupports(
							msg,
							&fromBeam->mod_env,
							&count,
							frBmSupps ),
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

		part.Iwant	=  VS_m_xOffset
				 | VS_m_yOffset
				 | VS_m_RotAngle
				 | VS_m_cardPnt
				 | VS_m_Symmetry ;
		part.specific	= (void *) &fbAttr ;
		sts = om$send(	msg	= message GRvg.GRgetattr(
							msg, (char *) &part ),
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

		sts = vs$getCS_from_cv_and_sf( 	msg	= msg,
						surface	= frBmSupps + 0,
						curve	= frBmSupps + 1,
						pntParm	= 0.,
						origin	= pntAtX,
						tangent	= tanAtX,
						normal	= normAtX,
						binormal= xvcAtX ) ;
		__CheckRC( sts, *msg, "vs$getCS_from_cv_and_sf", wrapup ) ;

		if( BSdotp( &bsRC, xDir, xvcAtX ) < 0. ) {
			xDirReversed = 1 ;
		}
	}

	sts = om$send(	msg	= message VSrflBeam.VSimportData(
						msg, placement, fromBeam ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSrflBeam.VSimportData", wrapup ) ;

	/*
	 * We must have user attributes at this point even if our parent beam
	 * did not have any. They have been set in method `VSimportData'.
	 */
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
					msg, VS_K_prUsrAttr, &myUsrAttr ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) || IF_NULL_OBJID( myUsrAttr.objid ) ) {
		*msg = MSFAIL ; goto wrapup ;
	}

	{ double x = xDirReversed ;
	  sts = VSaddOrModAttr( msg, &myUsrAttr,
			        VS_K_rsXDirReversed, AC_ATTRIB_DOUBLE, &x ) ;
	  __CheckRC( sts, *msg, "VSaddOrModAttr", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* method VSimportData */
/*----------------------------------------------------------------------------*/

end implementation VSrfsBeam ;

