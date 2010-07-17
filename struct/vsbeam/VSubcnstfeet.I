/*
	I/STRUCT
*/ 
class implementation VSsubBeam ;

#include "OMmacros.h"
#include "exmacros.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

extern IGRboolean	ASbroadcast_in_progress ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	int			myIndex,	/* On parent's channel	*/
				u ;		/* Loop index		*/
	struct GRobj_env	operand,	/* Of operation		*/
				axis,		/* My one foot		*/
				realParent,
				axis0,		/* Temporary object	*/
				toDel[2] ;	/* Temporary objects	*/
	struct GRvg_construct   cst ;		/* Construction list	*/
	VSdspRep		myRep ;		/* My display rep	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/
	IGRboolean		saveBroadcast ;
	struct GRid		profile ;	/* Profile curve	*/
	VSsuppList		mySupps ;

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	saveBroadcast           = ASbroadcast_in_progress ;
	ASbroadcast_in_progress	= TRUE ;
	profile.objid		= NULL_OBJID ;
	for( u = 0 ; u < 2 ; u++ ) toDel[u]._objid = NULL_OBJID ;

	/*
	 * The operand is the parent beam I consume (case 1) or the parent beam
	 * I use foot of (case 0).
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
	if( !( sts & 1 & *msg ) ) {
		sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
				mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	}

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
	/*
	 * If sub-beam #0, do a give-foot then copy it, if sub-beam #1
	 * consume parent's outputs, then delete unused one.
	 */

	case 0 :
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_cbAxis0,
							&axis0._grid,
							&axis0._matrix_type,
							axis0._matrix ),
				targetid= listOfInputs[0].objid,
				targetos= listOfInputs[0].osnum ) ;
		*msg = *msg ? MSSUCC : MSFAIL ;

		/*
		 * For some reason parent may have been unable to generate
		 * the foot.
		 */
		if( !( *msg & 1 ) || IF_NULL_OBJID( axis0._objid ) ) {
			*msg			= MSSUCC ;
			sts			= OM_S_SUCCESS ;
			listOfOutputs[0].objid	= NULL_OBJID ;
			goto wrapup ;
		}
		axis0._md_os = axis0._osnum ;
		ex$get_modid(	mod_osnum	= axis0._md_os,
				mod_id		= &axis0._md_id ) ;

		axis.mod_env	= *myEnv ;
		axis._osnum	= myEnv->_MD_OS ;
		sts = om$send( msg      = message GRgraphics.GRcopy(
                                                    	msg,
               						&axis0.mod_env,
							myEnv,
							&axis._objid ),
        	              targetid = axis0._objid,
                	      targetos = axis0._osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

		toDel[1] = axis ;
		break ;

	case 1 :

	  	sts = vs$consume(	msg	= msg,
					objId	= &operand._grid,
					ftEnv	= myEnv,
					objEnv	= &operand.mod_env,
					nbfeet	= 2,
					feet	= outputs ) ;
 		__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

		/*
		 * Keep foot #1, delete the other.
		 */
		vs$bulk_delete( grids = &outputs[0], theEnv = myEnv ) ;

		/*
		 * For some reason parent may have been unable to generate
		 * the foot.
		 */
		if( IF_NULL_OBJID( outputs[1].objid ) ) {
			*msg			= MSSUCC ;
			sts			= OM_S_SUCCESS ;
			listOfOutputs[0].objid	= NULL_OBJID ;
			goto wrapup ;
		}

		axis.mod_env	= *myEnv ;
		axis._grid	= outputs[1] ;
		toDel[0]	= axis ;

		break ;

	default :	/* Bad index */
			*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
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

	sts = VSgetVirtualInfo( msg, &operand._grid, &realParent.mod_env,
				&realParent._grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetSupportSf(
					msg, &realParent.mod_env, mySupps + 0 ),
			targetid= realParent._objid,
			targetos= realParent._osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportSf", wrapup ) ;

	mySupps[1] = axis ;

	sts = om$send(	msg	= message VSbeam.VSextractProfile(
					msg, myEnv, mySupps + 0,
					mySupps + 1, 0.0, &cst, myRep, &profile ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

	switch( myRep ) {

	case AC_2D_REP		:
		sts = om$send(	msg	= message VSsrcBeam.VScnst_line_rep(
							msg,
							myEnv,
							mySupps,
							&cst,
							&profile,
							listOfOutputs + 0 ),
				targetid= my_id ) ;	
		__CheckRC( sts, *msg, "VSsrcBeam.VScnst_line_rep", wrapup ) ;
		break ;

	case VS_m_3dWFillet	:
	case VS_m_2dSurface	:
	case AC_3D_REP		:
	case AC_ENV_REP		:

		sts = om$send(	msg	= message VSsrcBeam.VScnst_solid_rep(
							msg,
							myEnv,
							&cst,
							mySupps + 0,
							mySupps + 1,
							&profile,
							listOfOutputs + 0 ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSsrcBeam.VScnst_solid_rep", wrapup ) ;
		break ;

	default :	/* Bad representation */
			*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	*countOfOutputs = 1 ;

        wrapup :
		/*
		 * Except in linear case (pure AC_2D_REP), where the section
		 * is part of outputs, the section curve has to be deleted.
		 */
		if( myRep != AC_2D_REP ) {
			vs$bulk_delete(	grids = &profile, theEnv = myEnv ) ;
		}
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
			 * Update beam tag, don't check return code: will be
			 * OM_W_NOTTAGGED if object has no tag connection.
			 */
			om$change_tag_version() ;
		}
		vs$bulk_delete(	count = 2, objenvs = toDel ) ;

		ASbroadcast_in_progress = saveBroadcast ;

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSsubBeam ;
