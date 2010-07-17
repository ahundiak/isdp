/*
	I/STRUCT
*/
class implementation VSxtrBeam ;

#include <stdlib.h>
#include "OMmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vsgeommacros.h"
#include "vsipthmacros.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
#include "vsvirtualinf.h"

extern IGRboolean		ASbroadcast_in_progress ;
extern OMuword			OPP_EMSplane_class_id ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid	*listOfOutputs ) {

	long		sts ;		/* OM return code		*/
	int		bfCount ;	/* Count of cmps in input solid	*/
	VSipathANDid	*bfList ;	/* List of cmps in input solid	*/
	struct GRvg_construct 
			cst ;		/* ... of resulting boolean	*/
	struct GRid	parentOutput ;	/* My parent beam's output	*/
	struct GRobj_env
			operand,	/* ... of this operation	*/
			trimSurf,	/* Surface to trim against	*/
			trimSfCpy,	/* Copy of above surface	*/
			bigPlane ;
	VSdspRep	myRep ;		/* My representation		*/
	struct GRsymbology
			mySymb ;	/* My symbology			*/
	IGRboolean	saveBroadcast ;

	saveBroadcast = ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

	bigPlane._objid	= listOfOutputs[0].objid = trimSfCpy._objid
			= NULL_OBJID ;
	bfList		= NULL ;
	bfCount		= 0 ;

	/*
	 * The operand is the parent beam I consume.
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

	/*
	 * Get surface to trim parent against.
	 */
	sts = om$send( msg	= message VScpx.VSget_graphic_input(
								msg,
								1,
								listOfInputs + 1,
								&trimSurf ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

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
	 * Consume your beam parent. The following call will set
	 * `operand.mod_env'.
	 */
	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				objEnv	= &operand.mod_env,
				ftEnv	= myEnv,
				nbfeet	= 1,
				feet	= &parentOutput ) ;
	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

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
	 * If input surface against which beam must be extended and trimmed is
	 * a plane, consider it as infinite.
	 */
	if( vs$is_ancestry_valid(	object	= &trimSurf._grid,
					classid	= OPP_EMSplane_class_id ) ) {

		struct GRobj_env	element ;
		struct GRid		plane ;

		element._grid	= parentOutput ;
		element.mod_env	= *myEnv ;

		sts = vs$makeBiggerPlane(	msg	= msg,
						inPlane	= &trimSurf,
						element	= &element,
						scale   = 2,
						cst	= &cst,
						bigPlane= &plane ) ;
		if( sts & 1 & *msg ) {
			bigPlane._grid	= plane ;
			bigPlane.mod_env= *cst.env_info ;
			trimSurf	= bigPlane ;
		}
	}

	if( myRep == AC_2D_REP ) {
		/*
		 * Delete output #0 (parent beam's light representation graphics).
		 * We do not need it.
		 */
		vs$bulk_delete(	grids = &parentOutput, theEnv = myEnv ) ;
							
		/*
		 * Simply extend axis to surface and put arrow heads.
		 */
		sts = om$send(	msg	= message VSxtrBeam.VScnst_linear_rep(
							msg,
							myEnv,
							&trimSurf,
							&cst,
							listOfOutputs + 0 ),
				targetid= my_id ) ;
	} else {
		/*
		 * Extend solid segments.
		 */
		struct GRid		parentSolid,
					virtual ;
		unsigned long		parentType ;	/* Type of parent */

		/*
		 * Copy the input trimming surface.
		 */
		trimSfCpy._osnum	= cst.env_info->_MD_OS ;
		trimSfCpy.mod_env	= *cst.env_info ;
		sts = om$send(	msg     = message GRgraphics.GRcopy(
							msg,
							&trimSurf.mod_env,
							&trimSfCpy.mod_env,
							&trimSfCpy._objid ),
				targetid= trimSurf._objid,
				targetos= trimSurf._osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

		parentSolid = parentOutput ;

		/*
		 * Save component structure of operand solid before boolean operation.
		 */
		sts = vs$getIPATHsandIDs(	msg		= msg,
						owner		= &parentSolid,
						ownerIndex	= 0,
						count		= &bfCount,
						p_list		= &bfList ) ;
		__CheckRC( sts, *msg, "vs$getIPATHsandIDs", wrapup ) ;

		sts = VSgetVirtualInfo(	msg, &operand._grid, NULL, &virtual ) ;
		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		sts = om$send(	msg	= message VSfeature.VSgetResultType(
							msg, &parentType ),
				targetid= virtual.objid,
				targetos= virtual.osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

		sts = om$send(	msg	= message VSxtrBeam.VScnst_solid_rep(
							msg,
							myEnv,
							parentType,
							&trimSfCpy,
							myRep,
							&cst,
							myEnv,
							&parentSolid,
							listOfOutputs + 0 ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSxtrBeam.VScnst_solid_rep", wrapup ) ;

		/*
		 * Build index paths into logical faces of beam so connexions
		 * will place nicely on this beam even though it has undergone
		 * DPR operations.
		 */
		sts = om$send(	msg	=  message VSdprPart.VSbuildIPATHs(
							msg,
							0,
							bfCount,
							bfList,
							&virtual,
							listOfOutputs + 0 ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSdprPart.VSbuildIPATHs", wrapup ) ;

		/*
		 * Trimming operator will have been erased in the process when
		 * its copy (at the same location) gets absorbed by the boolean:
		 * redisplay it if it is not the temporary infinite plane.
		 */
		if( IF_NULL_OBJID( bigPlane._objid ) ) {
			vs$bulk_display(	count	= 1,
						objenvs	= &trimSurf,
						dpmode	= GRbd ) ;
		}
	}

	if( !( sts & 1 & *msg ) ) goto wrapup ;

	*countOfOutputs	= 1 ;

	wrapup :
		vs$dotsInStsFld( dots = clear ) ;

		vs$bulk_delete( objenvs = &bigPlane ) ;

		if( sts & 1 & *msg ) {
			/*
			 * Update beam tag, don't check return code: will be
			 * OM_W_NOTTAGGED if object has no tag connection.
			 */
			om$change_tag_version() ;

		} else {
			/*
			 * Post-failure restore !
			 * Delete copy of input trimming surface.
			 */
			vs$bulk_delete(	count = 1, objenvs = &trimSfCpy ) ;

			/*
		    	 * Placement : failure. Compute : degraded state.
		    	 */
		    	if( purpose & VS_K_InitialPlacement ) {
		    		/*
	    			 * Unconsuming parent.
	    			 */
		    		long rc ;
		    		vs$unconsume(	msg	= &rc,
	    					object	= &operand._grid,
	    					mod_env	= &operand.mod_env,
	    					rep	= myRep,
	    					compute	= TRUE ) ;
		    		if( *msg & 1 ) *msg = MSFAIL ;
		    		sts = OM_W_ABORT ;
		    	} else {
		    		if( *msg & 1 ) *msg = EMS_E_NoSolution ;
		    		sts = OM_S_SUCCESS ;
	    		}
		}
	 	ASbroadcast_in_progress = saveBroadcast ;
		if( bfCount ) _FREE( bfList ) ;

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;
