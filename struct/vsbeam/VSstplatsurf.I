/*
	I/STRUCT
*/
class implementation VSstfBeam ;

#include "vsplatedef.h"
#include "vsplate.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsvcmpmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "ASsupport.h"
#include "vsgetinpbynm.h"
#include "vsvirtualinf.h"

from VSbeamAxis import VSgeneratePerpSfToParentSf ;
/*----------------------------------------------------------------------------*/
method VSgetPlateSurface(	long			*msg ;
				struct GRmd_env 	*myEnv ;
				struct GRid		*plate ;
				struct GRobj_env	*surface ) {

	long		sts ;		/* OM return code		*/
	struct GRid	Plate,		/* Buffer if `plate' is NULL	*/
			sourceId,	/* Source on the above		*/
			beamAxis ;	/* Macro of axis		*/
	struct GRobj_env
			myAxis,		/* Axis of stiffener		*/
			sfOfPrj ;	/* Surface of projection	*/
			
	int		mySide, 	/* Which side am I on ? 	*/
			myCstTyp,	/* My construction type 	*/
			plateSideUsed,	/* Plate side used, not new obj.*/
			ACrc ;		/* ACreturn code		*/
	char		*sideName ;	/* Name of plate side surface	*/
	struct GRvg_construct
			cst ;		/* For surface of projection	*/
	double		halfWidth ;	/* Of surface of projection	*/

	sfOfPrj._objid = NULL_OBJID ; plateSideUsed = FALSE ;

	if( !plate ) {
		plate = &Plate ;

		sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
							&ACrc,
							VS_K_stSuppPlate,
							plate ),
				targetid= my_id ) ;
		*msg = ACrc ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;
	}

	/*
	 * Now find which side we are on.
	 */
	sts = om$send(	msg	= message VSstfBeam.VSgetPlateSide(
								msg, &mySide ),
			targetid= my_id ) ;

	switch( mySide ) {
		default 		 :
		case VS_K_stOnTopOfPlate :
			sideName = VS_K_plTopSfPathABS ; break ;
		case VS_K_stOnBotOfPlate :
			sideName = VS_K_plBotSfPathABS ; break ;
	}

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							sideName,
							&surface->_grid,
							NULL,
							NULL ),
			targetid= plate->objid,
			targetos= plate->osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * Module environment of surface is that of parent plate.
	 */
	VSgetVirtualInfo( msg, plate, &surface->mod_env, NULL ) ;

	sts = om$send(	msg	= message VSstfBeam.VSgetConstructionType(
							msg, &myCstTyp ),
			targetid= my_id ) ;

	if( myCstTyp == VS_K_stNormalToSide ) {
		/*
		 * We're done.
		 */
		goto wrapup ;
	}

	/*
	 * Get support.
	 */
	{ struct GRid	moi ;

	  moi.objid = my_id ;
	  moi.osnum = OM_Gw_current_OS ;
	  sts = VSgetInputByName( msg, &moi, VS_K_bmSuppAxis, &myAxis._grid,
				  &myAxis.mod_env ) ;
	  __CheckRC( sts, *msg, "VSgetInputByName", wrapup ) ;
	}

	/*
	 * Get macro of axis.
	 */
	ASget_as_owner( &myAxis._grid, &beamAxis ) ;

	/*
	 * Make constructed surface of projection non-locatatble
	 * and non-displayable.
	 */
	vs$fill_cnst_list(	Cnst_list	= cst,
				Properties	= 0,
				Msg		= msg,
				Env_info	= myEnv ) ;

	/*
	 * Use the profile width for the surface of projection.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetSectionParameter(
					msg, VS_K_bmWidthAttr, myEnv,
					&halfWidth ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSectionParameter", wrapup ) ;

	if( halfWidth == 0. ) halfWidth = 100. ;

	sts = om$send( msg	= message VSbeamAxis.VSgeneratePerpSfToParentSf(
							     msg,
							     &cst,
							     halfWidth,
							     &sfOfPrj,
							     &plateSideUsed ),
		       targetid = beamAxis.objid,
		       targetos = beamAxis.osnum ) ;
	__CheckRC( sts, *msg, "VSbeamAxis.VSgeneratePerpSfToParentSf", wrapup );

	if( !plateSideUsed ) {
		/*
		 * Put a source object on it which won't last long. We here make
		 * believe that the surface of projection (new object) is in
		 * fact the side of the plate.
		 */
		sts = vs$makeVirtualComponent(	msg	= msg,
						modEnv	= &sfOfPrj.mod_env,
						owner	= plate,
						grObj	= &sfOfPrj._grid,
						path	= sideName,
						virtCmp = &sourceId ) ;
		__CheckRC( sts, *msg, "vs$makeVirtualComponent", wrapup ) ;
	}

	*surface= sfOfPrj ;
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) && !plateSideUsed ) {
			vs$bulk_delete( objenvs	= &sfOfPrj ) ;
		}
		return sts ;

} /* method VSgetPlateSurface */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;
