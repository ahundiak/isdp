/*
	I/STRUCT
*/
class implementation VSbmEndPnts ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

extern OMuword OPP_GR3dpoint_class_id ;

from VSbeam import VSgetSegmentEnds ;
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
	IGRpoint		endpt[2];	/* End points of beam	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	struct IGRpolyline	geometry ;	/* Of one end point	*/
	int			i ;		/* Loop index		*/

	VSsetGRids( myEnv->_MD_OS, 2, listOfOutputs ) ;

	sts = VSgetVirtualInfo(	msg,
				listOfInputs + 0,	/* Parent beam	*/
				&beam.mod_env,
				&beam._grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetSegmentEnds(
						msg, &beam.mod_env, endpt ),
			targetid= beam._objid,
			targetos= beam._osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSegmentEnds", wrapup ) ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Geometry	= &geometry,
				Cnst_list	= cst ) ;

	geometry.num_points = 1 ;

	for( i = 0 ; i < 2 ; i++ ) {
		geometry.points = &endpt[i][0] ;

		*msg = EMS_E_OMerror ;
		sts = om$construct(	classid	= OPP_GR3dpoint_class_id,
					osnum	= listOfOutputs[i].osnum,
					p_objid	= &listOfOutputs[i].objid ) ;
		__CheckRC( sts, 1, "om$construct", wrapup ) ;

		sts = om$send(	msg	= message GRvg.GRaltconstruct( &cst ),
				targetid= listOfOutputs[i].objid,
				targetos= listOfOutputs[i].osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRaltconstruct", wrapup ) ;
	}

	*countOfOutputs = 2 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;
	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids	= listOfOutputs,
					count	= 2,
					theEnv	= cst.env_info ) ;

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

end implementation VSbmEndPnts ;

