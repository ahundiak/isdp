/*
	I/STRUCT
*/
class implementation VSbooPlate ;

#include "exmacros.h"
#include "EMSutlmacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetFaceCount( long *msg ; int *count ) {

	long			sts ;		/* OM return code	*/
	VSpartAttr		myAttr ;	/* My part attributes	*/
	VSplateAttr		myInfo ;	/* Some attributes	*/
	int			isNatNorm ;	/* Is normal natural ?	*/
	struct GRid		botSurf,
				solid,
				parentId ;
	struct GRvg_construct	cst ;
	struct GRmd_env		parentEnv ;

	solid.objid = NULL_OBJID ;

	/*
	 * Get attributes.
	 */
	myAttr.Iwant	= VS_m_Thickness | VS_m_Orientation
			| VS_m_CutOff	 | VS_m_Offset ;
	myAttr.specific	= (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	switch( myInfo.orientation ) {
		default		       : /* Should never get here */
		case VS_K_USE_NAT_NORM : isNatNorm = TRUE  ; break ;
		case VS_K_USE_REV_NORM : isNatNorm = FALSE ; break ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
						msg, &parentId, &parentEnv ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetConsumedParent", wrapup ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plBotSfPath,
							&botSurf,
							NULL, NULL ),
			targetid= parentId.objid,
			targetos= parentId.osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;


	vs$fill_cnst_list(	Env_info	= &parentEnv,
				Cnst_list	= cst ) ;

	sts = vs$offset_surface_to_solid(
					msg		= msg,
					surfId		= &botSurf,
					surfEnv		= &parentEnv,
					offset		= myInfo.thickness,
					isNatNorm	= isNatNorm,
					cst		= &cst,
					isPlanar	= DONT_KNOW,
					offSolId	= &solid ) ;
	__CheckRC( sts, *msg, "vs$offset_surface_to_solid", wrapup ) ;

	{ OM_S_CHANSELECT toOutputs ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toOutputs ) ;
	  sts = om$get_channel_count(	objid		= solid.objid,
					osnum		= solid.osnum,
					count		= (OMuint *) count,
					p_chanselect	= &toOutputs ) ;
	}

	wrapup :
		vs$bulk_delete(	theEnv	= cst.env_info,
				grids	= &solid ) ;
		return sts ;

} /* method VSgetFaceCount */
/*----------------------------------------------------------------------------*/

end implementation VSbooPlate ;

