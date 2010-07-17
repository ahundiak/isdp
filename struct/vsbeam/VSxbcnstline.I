/*
	I/STRUCT
*/
class implementation VSxtrBeam ;

#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsbeammacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VScnst_linear_rep(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*trimSurf ;
				struct GRvg_construct	*cst ;
				struct GRid		*linearRep ) {

	long		sts ;			/* OM return code	*/
	struct GRobj_env
			extAxis ;		/* Id of extended axis	*/
	struct GRid	profile ;		/* Profile curve of beam*/
	VSsuppList	supports ;		/* List of supports	*/
	int		count ;			/* Count of supports	*/

	/*
	 * Init stuff.
	 */
	linearRep->objid = NULL_OBJID ;

	sts = om$send(	msg	= message VSxtrBeam.VSextendAxis(
					msg, trimSurf, cst, &extAxis._grid ),
			targetid =my_id ) ;
	__CheckRC( sts, *msg, "VSxtrBeam.VSextendAxis", wrapup ) ;

	extAxis.mod_env = *cst->env_info ;

	/*
	 * Get supports wrt message: we can use ancestor's method since here
	 * we do not want to get the extended axis but the orinal one not to
	 * have profile sitting at an end of the axis but in between : this
	 * will show in linear rep how much beam was extended.
	 */
	sts = om$send(	msg	= message VSmodBeam.VSgetSupports(
						msg, myEnv, &count, supports ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbooBeam.VSgetSupports", wrapup ) ;

	/*
	 * Construct a cross-section to include it in complex of linear (light)
	 * representation.
	 */
	sts = om$send(	msg	= message VSbeam.VSextractProfile(
								msg,
								myEnv,
								supports + 0,
								supports + 1,
								0,
								cst,
								AC_2D_REP,
								&profile ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

	/*
	 * Construct complex of linear representation.
	 */
	sts = vs$make_linear_beam_rep(	msg		= msg,
					xSection	= &profile,
					surface		= supports + 0,
					axis		= &extAxis,
					copyAxis	= FALSE,
					cst		= cst,
					linearRep	= linearRep ) ; 
	 __CheckRC( sts, *msg, "vs$make_linear_beam_rep", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VScnst_linear_rep */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;
