/*
	I/STRUCT
*/
class implementation VSrfsBeam ;

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vsrfldef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
method VSgetXdirectionForCrossSectionCS( long		*msg ;
					 int		*haveDir ;
					 IGRvector	xDir ) {

	long			sts ;		/* OM return code	*/
	struct GRid		myUsrAttr ;
	struct GRmd_env		env ;
	int			index ;		/* For ACgive_structure	*/
	struct ret_struct	rs ;		/* For ACgive_structure	*/

	MAidmx( msg, env._MATRIX ) ; env._MATRIX_TYPE = MAIDMX ;
	env._MD_OS = OM_Gw_current_OS ;
	env._MD_ID = NULL_OBJID ;

	sts = om$send(	msg	= message VSfeature.VSfindCollection(
					msg, VS_K_prUsrAttr, &myUsrAttr ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) || IF_NULL_OBJID( myUsrAttr.objid ) ) {
		*msg = MSFAIL ; goto wrapup ;
	}

	index = -1 ;
	sts = om$send(	msg	= message NDmacro.ACgive_structure(
						(int *) msg, &index,
						VS_K_rsXDirReversed, &rs,
						&env ),
			targetid= myUsrAttr.objid,
			targetos= myUsrAttr.osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACgive_structure", wrapup ) ;

	*haveDir = rs.var.root_pm_st.value != 0 ;

	if( *haveDir ) {
		VSsuppList	mySupps ;
		int		count ;
		VSpartAttr	part ;	/* My part attributes		   */
		VSbeamAttr	myAttr ;/* My beam attributes		   */
		IGRpoint	pntAtX ;/* Point of section on curve	   */
		IGRvector	tanAtX,	/* Tangent to curve at section 	   */
				normAtX,/* Surface normal at section	   */
				xvcAtX ;/* xvcAtX = normAtX ^ tanAtX	   */

		sts = om$send(	msg	= message VSpart.VSgetSupports(
						msg, &env, &count, mySupps ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

		part.Iwant	=  VS_m_xOffset
				 | VS_m_yOffset
				 | VS_m_RotAngle
				 | VS_m_cardPnt
				 | VS_m_Symmetry ;
		part.specific	= (void *) &myAttr ;
		sts = om$send(	msg	= message GRvg.GRgetattr(
							msg, (char *) &part ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

		sts = vs$getCS_from_cv_and_sf( 	msg	= msg,
						surface	= mySupps + 0,
						curve	= mySupps + 1,
						pntParm	= 0.,
						origin	= pntAtX,
						tangent	= tanAtX,
						normal	= normAtX,
						binormal= xvcAtX ) ;
		__CheckRC( sts, *msg, "vs$getCS_from_cv_and_sf", wrapup ) ;

		VSnegvc( xvcAtX, xDir ) ;
	} else {
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
	}
	
	wrapup :
		return sts ;

} /* VSgetXdirectionForCrossSectionCS */
/*----------------------------------------------------------------------------*/

end implementation VSrfsBeam ;

