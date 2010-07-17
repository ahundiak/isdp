/*
	I/STRUCT
*/ 
class implementation VSsubPlate ;

#include "exmacros.h"
#ifndef EMSopt_include
#	include "EMSopt.h"
#endif
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

extern IGRboolean	ASbroadcast_in_progress ;

from	EMSsurface	import	EMrevorient ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts,		/* OM return code	*/
				amConsumed ;	/* Am I consumed	*/
	VSpartAttr		myAttr ;	/* My part attributes	*/
	VSplateAttr		myInfo ;	/* Some attributes	*/
	double			myThickness ;	/* For offset solid	*/
	int			myIndex,	/* On parent's channel	*/
				u ;		/* Loop index		*/
	struct GRobj_env	operand,	/* Of this operation	*/
				parentOutput,	/* My parent's output	*/
				plate0,		/* Temporary object	*/
				toDel[3] ;	/* Temporary objects	*/
	struct GRvg_construct   cst ;		/* Construction list	*/
	double			myOffset ;	/* Offset from support	*/
	VSdspRep		myRep ;		/* My display rep	*/
	int			isNatNorm,	/* Is normal natural ?	*/
				isNatNormCorr,	/* Correction to above	*/
				parentOrient ;	/* Parent's orientation	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/
	IGRboolean		saveBroadcast ;
	struct GRid		result ;	/* Of this operation	*/

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	saveBroadcast           = ASbroadcast_in_progress ;
	ASbroadcast_in_progress	= TRUE ;

	/*
	 * What gets deleted at the end of this method:
	 * Display	| no offset	| offset
	 * -------------+---------------+-------------------------------
	 * 2-D		| nothing	| consumed foot
	 * 3-D		| consumed foot	| consumed foot & offset surface
	 */

        *msg = MSSUCC ;

	result.objid = NULL_OBJID ;
	for( u = 0 ; u < 3 ; u++ ) toDel[u]._objid = NULL_OBJID ;

	/*
	 * The operand is the parent plate I consume (case 1) or the parent
	 * plate I use foot of (case 0).
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

	/*
	 * Fill construction list.
	 */
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
	 * Find your position in manager parent's ordering, Then get its foot
	 * at the same index.
	 */
	sts = om$send(	msg	= message VSsubFeature.VSgetIndex( msg, &myIndex ),
			targetid= my_id ) ;

	switch( myIndex ) {

	struct GRid	outputs[2] ;
	struct GRmd_env	fromEnv ;

	/*
	 * If sub-plate #0, do a give-foot then copy it, if sub-plate #1
	 * consume parent's outputs, then delete unused one.
	 */

	case 0 :
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_cpGrCmpSurf0,
							&plate0._grid,
							&fromEnv._MATRIX_TYPE,
							fromEnv._MATRIX ),
				targetid= operand._objid,
				targetos= operand._osnum ) ;
		*msg = *msg ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		fromEnv._MD_OS = plate0._osnum ;
		ex$get_modid(	mod_osnum	= fromEnv._MD_OS,
				mod_id		= &fromEnv._MD_ID ) ;

		parentOutput.mod_env	= *myEnv ;

		sts = vs$grCopy(	msg	= msg,
					frEnv	= &fromEnv,
					frObj	= &plate0._grid,
					toEnv	= &parentOutput.mod_env,
					toObj	= &parentOutput._grid ) ;
		__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

		toDel[2] = parentOutput ;
		break ;

	case 1 :
	  	sts = vs$consume(	msg	= msg,
					objId	= &operand._grid,
					objEnv	= &operand.mod_env,
					ftEnv	= myEnv,
					nbfeet	= 2,
					feet	= outputs ) ;
 		__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

		parentOutput.mod_env = *myEnv ;

		/*
		 * Keep foot #1, delete the other.
		 */
		parentOutput._grid = outputs[1] ;
		vs$bulk_delete(	count	= 1,
				grids	= &outputs[0],
				theEnv	= &parentOutput.mod_env ) ;

		toDel[0] = parentOutput ;
		break ;

	default :	*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	/*
	 * Get display representation.
	 */
	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	sts = vs$fixIfNoRep(	inRep	= myRep,
				parentId= &operand._grid,
				outRep	= &myRep ) ;

	/*
	 * Get parent's orientation.
	 */
	myAttr.Iwant	= VS_m_Orientation ;
	myAttr.specific	= (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= operand._objid,
			targetos= operand._osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;
	parentOrient = myInfo.orientation ;

	/*
	 * Get attributes.
	 */
	myAttr.Iwant	= VS_m_Offset | VS_m_Orientation | VS_m_Thickness ;
	myAttr.specific	= (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	switch( myInfo.orientation ) {
		default		       : /* Should never get here */
		case VS_K_USE_NAT_NORM : isNatNorm = TRUE  ; break ;
		case VS_K_USE_REV_NORM : isNatNorm = FALSE ; break ;
	}

	isNatNormCorr = isNatNorm ;
	if( isNatNormCorr ) {
		switch( parentOrient ) {
			case VS_K_USE_NAT_NORM : break ;
			/*
			 * Parent's orientation is reversed, since you want
			 * the natural orientation, reverse it anew.
			 */
			case VS_K_USE_REV_NORM : isNatNormCorr = FALSE ; break ;
		}
	} else {
		switch( parentOrient ) {
			case VS_K_USE_NAT_NORM : break ;
			/*
			 * Parent's orientation is natural, since you want
			 * the reverse orientation, reverse it.
			 */
			case VS_K_USE_REV_NORM : isNatNormCorr = TRUE ; break ;
		}
	}

	/*
	 * If this sub-plate does not carry attributes (i.e. it is an image
	 * of some plate up in the hierarchy), it does not need to worry
	 * about offset (since the other parent plate took care of it); but
	 * if this sub-plate carries attributes, then it must perform an
	 * offset. This offset is relative to the support of the highest
	 * source plate in the hierarchy, thus the offset to be performed
	 * here will be :
	 *		(my offset) - (offset of source plate)
	 */
	{
		VSpartAttr	srcAttr ;
		VSplateAttr	srcInfo ;
		long		rc ;

		srcAttr.Iwant	= VS_m_Offset ;
		srcAttr.specific= (void *) &srcInfo ;
		sts = om$send(	msg	= message VSfeature.VSforwardToSource(
					&rc,
					OM_e_wrt_object,
					message GRvg.GRgetattr(	msg,
								(char *) &srcAttr ) ),
				targetid= operand._objid,
				targetos= operand._osnum ) ;
		if( !( rc & 1 ) ) *msg = rc ;
		myOffset = myInfo.offset - srcInfo.offset ;

		__CheckRC( sts, *msg, "VSfeature.VSforwardToSource", wrapup ) ;
	}

	if( myOffset != 0. ) {
		/*
		 * Create an offset surface, which becomes the new surface to
		 * be acted upon. It will have to be deleted in the cases where
		 * it is no longer needed.
		 */
		struct GRid	offsetSurface ;
		int		offSfNatNorm ;

		offSfNatNorm = isNatNorm == isNatNormCorr ;

		sts = vs$make_offset_surface(
					msg		= msg,
					surfEnv		= &parentOutput.mod_env,
					surfId		= &parentOutput._grid,
					offset		= myOffset,
					isNatNorm	= offSfNatNorm,
					isPlanar 	= DONT_KNOW,
					cst		= &cst,
					offSurfId 	= &offsetSurface ) ;

		__CheckRC( sts, *msg, "vs$make_offset_surface", wrapup ) ;

		parentOutput._grid = offsetSurface ;
		toDel[1]._grid	= offsetSurface ;
		toDel[1].mod_env= *cst.env_info ;
	}

	/*
	 * Whatever the representation setting, the simplified one is used if
	 * I am consumed so those who consume me can be sure they will get a
	 * surface-foot when they send me an NDmacro.ACconsume message.
	 */
	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &amConsumed),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;
	if( amConsumed & 1 ) {
		om$send(msg	= message VSfeature.VSgetConsumedRep( &myRep ),
			targetid= my_id ) ;
		if( !myRep ) myRep = AC_2D_REP ;
	}

	switch( myRep ) {

	case AC_3D_REP :
			myThickness = myInfo.thickness ;
			goto OFFSET_SURF ;

	case AC_ENV_REP	:
			myThickness = myInfo.cut_off ;

	OFFSET_SURF :
		sts = vs$offset_surface_to_solid(
					msg		= msg,
					surfId		= &parentOutput._grid,
					surfEnv		= &parentOutput.mod_env,
					offset		= myThickness,
					isNatNorm	= isNatNormCorr,
					isPlanar	= DONT_KNOW,
					cst		= &cst,
					offSolId	= &result ) ;
		__CheckRC( sts, *msg, "vs$offset_surface_to_solid", wrapup ) ;
		break ;

	case VS_m_2dWCompute	:
	case AC_2D_REP		:
		if( myOffset != 0. ) {
			/*
			 * Keep offset surface, get rid of parent's consumed
			 * foot.
			 */
			toDel[1]._objid = NULL_OBJID ;
		} else {
			/*
			 * No offset surface, don't get rid of parent's
			 * consumed foot for either sub-plate #0 or #1
			 * (ie. slot 0 or 2).
			 */
			toDel[0]._objid = NULL_OBJID ;
			toDel[2]._objid = NULL_OBJID ;
		}
		/*
                 * Do not reverse the orientation if you are consumed:
		 * consuming child expects a surface with the same orientation
		 * as the support surface !
                 */
		if( !isNatNormCorr ) {
			sts = om$send(
				msg	= message
						EMSsurface.EMrevorient( msg ),
				targetid= parentOutput._objid,
        	                targetos= parentOutput._osnum ) ;

		}
		result = parentOutput._grid ;
		break ;

	default :	/* Bad display type */
			*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	*countOfOutputs	 = 1 ;
	listOfOutputs[0] = result ;

        wrapup :
		ASbroadcast_in_progress = saveBroadcast ;

        	if( !( sts & 1 & *msg ) ) {
	    		/*
	    		 * Placement : failure. Compute : degraded state.
	    		 */
	    		if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
	    		} else {
	    			if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
			}
		} else {
			/*
			 * Update plate tag, don't check return code: will be
			 * OM_W_NOTTAGGED if object has no tag connection.
			 */
			om$change_tag_version() ;
		}
		vs$bulk_delete(	count = 3, objenvs = toDel ) ;

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSsubPlate ;
