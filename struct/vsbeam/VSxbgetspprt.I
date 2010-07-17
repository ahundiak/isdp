/*
	I/STRUCT
*/
class implementation VSxtrBeam ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetinpbynm.h"
#include "vsmkgrobjtmp.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportAxis(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env 	*axis ) {

	long		sts ;		/* OM return code		*/
	struct GRobj_env
			trimSf ;	/* Parent trimming surface	*/
	struct GRvg_construct
			axisCst ;
	struct GRsymbology
			axisSymb ;
	struct GRid	moi ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;

	/*
	 * Get parent trimming surface.
	 */
	sts = VSgetInputByName(	msg, &moi, VS_K_xbTrimSurf, &trimSf._grid,
					&trimSf.mod_env ) ;

	/*
	 * Get original support (the one to be extended).
	 */
	sts = om$send(	msg	= message VSmodBeam.VSgetSupportAxis(
							     msg, myEnv, axis ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSmodBeam.VSgetSupportAxis", wrapup ) ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &axisSymb ),
			targetid= axis->_objid,
			targetos= axis->_osnum ) ;

	/*
	 * Create axis invisible ( "Properties = 0" => non-loca/displayable )
	 * since it will always be used for computation purposes.
	 */
	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= &axis->mod_env,
				Display		= &axisSymb.display_attr,
				Level		= axisSymb.level,
				Properties	= 0,
				Cnst_list	= axisCst ) ;

	/*
	 * Now extend axis to trimming surface (we get a new object).
	 */
	sts = om$send(	msg	= message VSxtrBeam.VSextendAxis(
					msg, &trimSf, &axisCst, &axis->_grid ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSxtrBeam.VSextendAxis", wrapup ) ;

	/*
	 * Create a support-only source object, since we have created a new one
	 * and want the system to get rid of it when no longer needed.
	 */
	sts = VSmakeGraphicObjectTemporary( msg, &axis->_grid, TRUE ) ;
	__CheckRC( sts, *msg, "VSmakeGraphicObjectTemporary", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSgetSupportAxis */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;

