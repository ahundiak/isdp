/*
	I/STRUCT
*/
class implementation VSsplBeam ;

#include <stdlib.h>
#include "exmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "EMSmsgdef.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "EMSsffmacros.h"
#include "vsdelbndries.h"
#include "vsioproto.h"

extern void			VSsetGRids() ;
extern long			VSsplitCurveWithOneOrTwoPoints() ;
extern IGRboolean		ASbroadcast_in_progress ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid	*listOfOutputs ) {

	long		sts ;		/* OM return code		*/
	struct GRobj_env
			operand,	/* ... of this operation	*/
			botSf,		/* Bottom sf. of operator plate	*/
			topSf ;		/* Top sf. of operator plate	*/
	struct GRvg_construct 
			cst ;		/* ... of resulting boolean	*/
	unsigned	myMask ;	/* My mask of sub-beams		*/
	int		i,		/* Loop index			*/
			nbIntwbot,	/* # of intersections w/ bot sf.*/
			nbIntwtop,	/* # of intersections w/ top sf.*/
			maxSubBeams,	/* Max. # of sub-beams		*/
			botWasCopied,	/* Was bottom surface copied ?	*/
			topWasCopied ;	/* Was top    surface copied ?	*/
	struct GRid 	*intwbot,	/* Intersections w/ bottom sf.	*/
			*intwtop,	/* Intersections w/ top    sf.	*/
			parentOutput,	/* My parent beam's output	*/
			sfCopy,		/* Copy of top or bot. sf. w/o
					   boundaries.			*/
			intPnts[2],	/* Intersection points		*/
			subAxes[2] ;	/* Results of axis-splitting	*/
	struct GRobj_env
			suppAxis ;	/* My support axis		*/
	struct GRlc_info
			optrInfo,	/* Arg. to EMintersect_two_...	*/
			opndInfo ;	/* Arg. to EMintersect_two_...	*/
	IGRboolean	saveBroadcast ;

#define ParentPlate	(listOfInputs[1])	/* Operator */

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	saveBroadcast		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress	= TRUE ;

	VSsetGRids( myEnv->_MD_OS, 2, subAxes  ) ;	
	VSsetGRids( myEnv->_MD_OS, 2, listOfOutputs ) ;
	intwbot		= intwtop	= NULL ;
	nbIntwbot	= nbIntwtop	= 0 ;
	topWasCopied	= botWasCopied	= FALSE ;

	/*
	 * The operand is the parent I consume.
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= myEnv,
				Cnst_list	= cst ) ;

	/*
	 * Consume parent and get rid of graphics immediately (we don't need
	 * them !). The following call will set `operand.mod_env'.
	 */
	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				objEnv	= &operand.mod_env,
				nbfeet	= 1,
				feet	= &parentOutput ) ;
	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;
	vs$bulk_delete(	count = 1, theEnv = myEnv, grids = &parentOutput ) ;

	/*
	 * Get bottom and top surface of operator plate.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plBotSfPath,
							&botSf._grid,
							&botSf._matrix_type,
							botSf._matrix ),
			targetid= listOfInputs[1].objid,
			targetos= listOfInputs[1].osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	
	botSf._md_os = botSf._osnum ;
	ex$get_modid( mod_osnum = botSf._md_os, mod_id = &botSf._md_id ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plTopSfPath,
							&topSf._grid,
							&topSf._matrix_type,
							topSf._matrix ),
			targetid= listOfInputs[1].objid,
			targetos= listOfInputs[1].osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	
	topSf._md_os = topSf._osnum ;
	ex$get_modid( mod_osnum = topSf._md_os, mod_id = &topSf._md_id ) ;

	/*
	 * Bottom and top surface may have holes on them, if high-priority
	 * plate has undergone impose-boundaries operation of if its support
	 * had holes in it. This holes may give several intersection curves
	 * which we don't want: we remove the boundaries if any, since we
	 * cannot alter those surfaces directly (they belong to the high-
	 * priority plate), a copy will be returned if there was boundaries
	 * which have been removed. Those copies are deleted upon exit.
	 * If they were not copied (no boundaries), the following function
	 * returns the input surface.
	 */
	sts = VSdelete_boundaries_if_any(	msg,
						&botSf.mod_env,
						&botSf._grid,
						myEnv,
						&sfCopy,
						&botWasCopied ) ;
	__CheckRC( sts, *msg, "VSdelete_boundaries_if_any", wrapup ) ;
	if( botWasCopied ) {
		botSf.mod_env = *myEnv ; botSf._grid = sfCopy ;
	}

	sts = VSdelete_boundaries_if_any(	msg,
						&topSf.mod_env,
						&topSf._grid,
						myEnv,
						&sfCopy,
						&topWasCopied ) ;
	__CheckRC( sts, *msg, "VSdelete_boundaries_if_any", wrapup ) ;
	if( topWasCopied ) {
		topSf.mod_env = *myEnv ; topSf._grid = sfCopy ;
	}

	/*
	 * Get axis.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
						msg, myEnv, &suppAxis ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	opndInfo.located_obj = suppAxis._grid ;
	opndInfo.module_info = suppAxis.mod_env ;

	/*
	 * Intersect axis with operator's bottom surface.
	 */
	optrInfo.located_obj	= botSf._grid ;
	optrInfo.module_info	= botSf.mod_env ;
	sts = EMintersect_two_element(	&opndInfo,
					&optrInfo,
					TRUE,
					&cst,
					&nbIntwbot,
					&intwbot,
					msg ) ;
	__CheckRC( sts, *msg, "EMintersect_two_element", wrapup ) ;

	if( !nbIntwbot ) {
		*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}   

	/*
	 * Intersect operand's surface with operator's top surface.
	 */
	optrInfo.located_obj	= topSf._grid ;
	optrInfo.module_info	= topSf.mod_env ;
	sts = EMintersect_two_element(	&opndInfo,
					&optrInfo,
					TRUE,
					&cst,
					&nbIntwtop,
					&intwtop,
					msg ) ;
	__CheckRC( sts, *msg, "EMintersect_two_element", wrapup ) ;

	if( !nbIntwtop ) {
		*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	/*
	 * Split axis with intersection points (we here hope that intersecting
	 * the top & bottom surfaces of the plate with the axis of the beam
	 * gave out points, if not the following call wil fail).
	 */
	intPnts[0] = intwbot[0] ; intPnts[1] = intwtop[0] ;
	sts = VSsplitCurveWithOneOrTwoPoints(	msg,
						&suppAxis.mod_env,
						&suppAxis._grid,
						2,
						cst.env_info,
						intPnts,
						NULL,
						&cst,
						listOfOutputs + 0,
						listOfOutputs + 1 ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;
	
	*countOfOutputs =    !IF_NULL_OBJID( listOfOutputs[0].objid )
			  +  !IF_NULL_OBJID( listOfOutputs[1].objid ) ;

	if( purpose & VS_K_InitialPlacement ) {
		if( *countOfOutputs == 1 ) {
			if( IF_NULL_OBJID( listOfOutputs[0].objid ) ) {
			  listOfOutputs[0].objid = listOfOutputs[1].objid ;
			  listOfOutputs[1].objid = NULL_OBJID ;
			}
			sts = om$send(	msg	= message VSdivFeature.VSsetSubMask(
							msg, VS_K_SET_BITS, 1 ),
					targetid= my_id ) ;
		}
	} else {
		/*
		 * Sub-beams may have been deleted purposedly by user: do not
		 * put them back.
		 */
		sts = om$send(	msg	= message VSdivFeature.VSgetSubMask(
					msg, &myMask, &i, &maxSubBeams ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSdivFeature.VSgetSubMask", wrapup ) ;

		for( i = 0 ; i < maxSubBeams ; i++ ) {
			if( myMask & ( 1 << i ) ) {
				/* Keeping result */
			} else {
				vs$bulk_delete(	count 	= 1,
						grids	= listOfOutputs + i,
						theEnv	= myEnv ) ;
			}
		}
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :

	vs$dotsInStsFld( dots = clear ) ;

	if( !( sts & 1 & *msg ) ) {
		vs$bulk_delete(	count	= *countOfOutputs,
				grids	= listOfOutputs,
				theEnv	= myEnv ) ;
	    	/*
	    	 * Placement : failure. Compute : degraded state.
	    	 */
	    	if( purpose & VS_K_InitialPlacement ) {
	    		/*
	    		 * Unconsuming parent.
	    		 */
			long rc ; VSdspRep myRep ;

			om$send(msg	= message ACncpx.ACget_NV_rep( &myRep ),
				targetid= my_id ) ;
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
	} else {
		/*
		 * Update beam tag, don't check return code: will be
		 * OM_W_NOTTAGGED if object has no tag connection.
		 */
		om$change_tag_version() ;
	}

	/*
	 * Delete copies of top, bottom and operand surfaces if any.
	 */
	if( botWasCopied ) {
		vs$bulk_delete(	count = 1, objenvs = &botSf ) ;
	}
	if( topWasCopied ) {
		vs$bulk_delete(	count = 1, objenvs = &topSf ) ;
	}
	/*
	 * Delete objects created when computing intersections.
	 */
	vs$bulk_delete( count = nbIntwbot, grids = intwbot, theEnv = myEnv ) ;
	vs$bulk_delete( count = nbIntwtop, grids = intwtop, theEnv = myEnv ) ;

	if( nbIntwbot ) _FREE( intwbot ) ;
	if( nbIntwtop ) _FREE( intwtop ) ;

	ASbroadcast_in_progress	= saveBroadcast ;
	return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSsplBeam ;
