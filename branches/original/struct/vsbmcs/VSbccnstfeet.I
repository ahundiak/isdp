/*
	I/STRUCT
*/
class implementation VSbeamCS ;

#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsconstrctcs.h"
#include "vsevalbeamcs.h"
#include "vsvirtualinf.h"

extern IGRboolean  ASbroadcast_in_progress ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	beam ;		/* Virtual beam parent	*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/
	VSbmCsPos		myAttr ;	/* End and card. point	*/
	IGRmatrix		matrix ;	/* Matrix of CS		*/
	IGRboolean		saveBroadcast ;

	/*
	 * Modify broadcast flag so possible GRcopy messages won't trigger
	 * a graph copy.
	 */
	saveBroadcast		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

	VSsetGRids( myEnv->_MD_OS, 1, listOfOutputs ) ;

	/*
	 * Real parent may be an ACpretend: get corresponding beam.
	 */
	sts = VSgetVirtualInfo(	msg,
				listOfInputs + 0,	/* Parent beam	*/
				&beam.mod_env,
				&beam._grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * Get attributes.
	 */
	sts = om$send(	msg	= message GRvg.GRgetattr(
							msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * Compute matrix of CS at desired end of beam and desired cardinal
	 * point.
	 */
	sts = VSevalBeamCS(	msg,
				&beam,
				myAttr.endNo,
				(enum VScardinal_point) myAttr.cardPt,
				matrix ) ;
	__CheckRC( sts, *msg, "VSevalBeamCS", wrapup ) ;

	/*
	 * Construct CS.
	 */
	sts = VSconstructCS( msg, matrix, &cst, listOfOutputs + 0 ) ;
	__CheckRC( sts, *msg, "VSconstructCS", wrapup ) ;

	*countOfOutputs = 1 ;

	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	wrapup :
		ASbroadcast_in_progress = saveBroadcast ;

		if( !( sts & 1 & *msg ) ) {

			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
	    		}
		}

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSbeamCS ;
