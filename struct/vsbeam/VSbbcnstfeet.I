/* $Id: VSbbcnstfeet.I,v 1.5 2001/07/31 16:10:30 jayadev Exp $ */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSbbcnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSbbcnstfeet.I,v $
 *  Revision 1.5  2001/07/31 16:10:30  jayadev
 *  *** empty log message ***
 *
 *  Revision 1.4  2001/03/14 00:53:54  jayadev
 *  reduce range for boolean beams
 *
 *  Revision 1.3  2001/03/02 19:53:58  jayadev
 *  no ASCII process cutout control for beams
 *
 *  Revision 1.2  2001/01/17 00:13:39  ramarao
 *  *** empty log message ***
 *
# Revision 1.2  2000/12/02  19:28:42  pinnacle
# Replaced: struct/vsbeam/VSbbcnstfeet.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/11/09  17:47:56  pinnacle
# Created: struct/vsbeam/VSbbcnstfeet.I by jpulapar for Service Pack
#
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 *      11/08/00    Jayadev     TR#MP3357- VSget_graphic_input output changed
 *	12/02/00    Jayadev     vs$make_boolean_difference - args added
 *	03/01/00    Jayadev     undone changes for TR#MP3357 no ASCII process
 *                              cutout control for beams
 *	07/31/01    Jayadev     TR#5469 
 ***************************************************************************/
/*
  I/STRUCT
*/
class implementation VSbooBeam ;

#include <stdlib.h>
#include <string.h>
#include "OMmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vsgeommacros.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsipthmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsmkpenetcyl.h"
#include "vsvirtualinf.h"

extern long	VSfilterNotches	__((	long *,
					struct GRobj_env *,
					int,
					struct GRobj_env *,
					int *,
					struct GRobj_env * )) ;
extern OMuword			OPP_GRcurve_class_id ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
			countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid	*listOfOutputs ) {
  
	long		 sts, sts1;	/* OM return code		*/
	int		 nbNotches,	/* Count of notching solids	*/
			 validCount,	/* Count of valid notches	*/
			 bfCount,	/* Count of cmps in input solid	*/
			 i ;		/* Loop index			*/
	VSipathANDid	 *bfList ;
	struct GRvg_construct 		/* List of cmps in input solid	*/
			 cst ;		/* ... of resulting boolean	*/
	struct GRid	 parentInput,	/* My parent beam's input	*/
			 virtual,	/* My virtual consumed parent	*/
			 result ;	/* Boolean solid computed here	*/
#define MAX	VS_K_bbMAX_NOTCHES
	struct GRobj_env
			 notchList[MAX],	/* List of notching solids	*/
			 validList[MAX],	/* (possibly) valid notches	*/
			 operand,	/* ... of this operation	*/
			 operandSolid ;
	VSdspRep	 myRep ;		/* My display representation	*/
	struct GRsymbology
			 mySymb ;	/* My symbology			*/
	char		 cylsToDel[MAX] ;/* Flags cyls to be deleted	*/
	VSboolRef	 refList[MAX];
	int		 refCount = 0;
        IGRchar          className[128];
        GRclassid        classID;
        struct GRobj_env gensolOE;
        GRrange          solidRange;
        IGRshort         world = TRUE;
	
	/*
	 * NOTE: OM_S_OBJIDs are used here instead of GRid's because we deal
	 * with objects related with the owner-component channel ( AC complexes
	 * and inputs or solids and their components ) which is restricted hence
	 * all objects lie in the same object space.
	 */
	
	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }
	
	*countOfOutputs	= 1 ;
	result.objid	= listOfOutputs[0].objid = NULL_OBJID ;
	bfList		= NULL ;
	bfCount		= 0 ;
	memset( cylsToDel, 0, MAX ) ;

	/*
	 * The operand is the parent beam I consume.
	 */
	operand._grid	= listOfInputs[VS_K_ConsumedIx] ;

        __DBGpr_obj("Operand beam",operand.obj_id);	
	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
			? OM_e_wrt_message
			: OM_e_wrt_object,
			targetid= my_id ) ;
        /*
         * TR#5469 Beam had no graphics(for unknown reason !!!); 
         * needed to be generated on a recompute; similar thing
         * has also been done for boolean plate also
         */
        if( !(sts&1&(*msg)) && !( purpose & VS_K_InitialPlacement) )
        {
          sts = om$send(  msg     = message GRvg.GRgetsymb( msg, &mySymb ),
                        mode    = OM_e_wrt_message,
                        targetid= my_id ) ;
        }
        __CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;
	vs$fill_cnst_list(	Env_info 	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;
	/*
	 * Consume your beam parent, and get its end point which we will carry
	 * at positions 1 and 2 and flange points at 3 and 4.
	 * Get its solid input -> operand #0 of boolean operation. Note that if
	 * parent is in simplified display this input may not be booleaned;
	 * in this case we'll take it as an input.
	 * NOTE : the following call sets `operand.mod_env'.
	 */
	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				objEnv	= &operand.mod_env,
				nbfeet	= 1,
				feet	= &parentInput ) ;
	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;
        __DBGpr_obj("ParentInput ",parentInput);	

        sts = vs$grCopy(        msg     = msg,
                                frEnv   = &operand.mod_env,
                                frObj   = &parentInput,
                                toEnv   = cst.env_info,
                                toObj   = &gensolOE.obj_id) ;
        __CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;
        __DBGpr_obj("Gensolid copy for the beam ",gensolOE.obj_id);
        gensolOE.mod_env = *cst.env_info;

        sts = VDreduce_range(msg, &gensolOE.mod_env, 
                             &gensolOE.obj_id, solidRange);
        if(!(sts&*msg&1))
        { 
          __DBGpr_obj("VDreduce_range failed for ",gensolOE.obj_id); 
          
          sts = om$send ( msg = message GRgraphics.GRgetrang (
                                          msg,
                                          &gensolOE.mod_env.md_env.matrix_type,
                                          gensolOE.mod_env.md_env.matrix,
                                          &world,
                                          solidRange ),
                          senderid = NULL_OBJID,
                          targetid = gensolOE.obj_id.objid,
                          targetos = gensolOE.obj_id.osnum );
          __CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
        }
        __DBGpr_obj("VDreduce_range worked for ",gensolOE.obj_id); 

        __DBGpr_com("Gensolid Range ");
        __DBGpr_vec("Range[0] ",&solidRange[0]);	
        __DBGpr_vec("Range[1] ",&solidRange[3]);
	
	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;
	
	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	sts = vs$fixIfNoRep(	inRep	= myRep,
				parentId= &operand._grid,
				outRep	= &myRep ) ;
	
	if( myRep & AC_2D_REP ) {
	  listOfOutputs[0] = parentInput ;
	  goto wrapup ;
	}
	
	/*
	 * Get GO from solid parent -> operands #1 and up of boolean operation,
	 * after copy since boolean operations will eat up the originals.
	 */
	nbNotches = countOfInputs - 1 ;

	if( nbNotches > MAX ) nbNotches = MAX ;

	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
				  msg, nbNotches, listOfInputs + 1, notchList ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;
		

	/*
	 * For operators which are curves (supposed closed and planar),
	 * generate a cutting cylinder.
	 */
	for( i = 0 ; i < nbNotches ; i++ ) {
	  refList[i].org     = notchList[i] ;
	  refList[i].new     = notchList[i] ;
	  refList[i].type    = VS_K_blSolid;
	  refList[i].nb_iter = 0;
	  
	  if( vs$is_ancestry_valid(
				   object	= &notchList[i]._grid,
				   classid = OPP_GRcurve_class_id ) ) {
	    
	    struct GRid	cylinder ;
	    int		saveStyle ;
	    
	    saveStyle		= cst.display->style ;
	    cst.display->style	= 3 ;
	    sts = VSmakePenetratingCyl(	msg,
					&parentInput,
					myEnv,
					&notchList[i]._grid,
					&notchList[i].mod_env,
					&cst,
					&cylinder ,
                                        solidRange ) ;
	    cst.display->style	= saveStyle ;
	    if( !( sts & 1 & *msg ) ) goto wrapup ;
	    
	    cylsToDel[i]		= TRUE ;
	    notchList[i]._grid	        = cylinder ;
	    notchList[i].mod_env	= *cst.env_info ;

	    refList[i].type		= VS_K_blCurve ;
	    refList[i].new		= notchList[i] ;
	  }
	}
	refCount = nbNotches ;
	for( i = 0 ; i < refCount ; i++ ) {
	  sts1 = om$get_classname( objid     = refList[i].new.obj_id.objid,
				   osnum     = refList[i].new.obj_id.osnum,
				   classname = className );
	  strcpy(refList[i].className,className);

          om$get_classid( objid = refList[i].new.obj_id.objid,
                          osnum = refList[i].new.obj_id.osnum,
                          p_classid = &classID);

	  refList[i].classID = classID;

	  __DBGpr_int("refList index ",i);
	  __DBGpr_str("Curve class   ",className);
        }
	/*
	 * Save component structure of operand solid before boolean operation.
	 */
	sts = vs$getIPATHsandIDs(	msg		= msg,
					owner		= &parentInput,
					ownerIndex	= 0,
					count		= &bfCount,
					p_list		= &bfList ) ;
	__CheckRC( sts, *msg, "vs$getIPATHsandIDs", wrapup ) ;
	
	/*
	 * Filter input notches: only keep those susceptible to make boolean
	 * difference succeed...
	 */
	operandSolid._grid 	= parentInput ;
	operandSolid.mod_env	= *myEnv ;

	sts = VSfilterNotches( msg, &operandSolid, nbNotches, notchList,
			       &validCount, validList ) ;
	__CheckRC( sts, *msg, "VSfilterNotches", wrapup ) ;
	
	if( !validCount ) {
	  /*
	   * On placement: err off, on recompute: output parent's input,
	   * eg. solid left intact.
	   */
	  if( purpose & VS_K_InitialPlacement ) {
	    *msg = EMS_E_NoSolution ; goto wrapup ;
	  } else {
	    result = parentInput ;
	  }
	} else {
	  sts = vs$make_boolean_difference(
					   msg		= msg,
					   optrCount	= validCount,
					   optrList	= validList,
					   operand	= &operandSolid,
					   resCst	= &cst,
					   compress	= TRUE,
					   oneAtATime	= TRUE,
					   result	= &result,
					   refCount	= refCount,
					   refList	= refList, 
					   range        = solidRange ) ;
	  if( !( sts & 1 & *msg ) ) {
	    /*
	     * Output parent's input, eg. solid left intact.
	     */
	    result = parentInput ;
	  }
	}
	  /*
	   * Parent's input has been absorbed in the boolean solid or is used
	   * as our input, set it to NULL_OBJID, so we won't delete it upon
	   * cleanup.
	   */
	  parentInput.objid = NULL_OBJID ;
	
	/*
	 * Construct map of indices in operand --> indices in result.
	 * Note that my real parent may be a pretend, so I must get my virtual
	 * parent and pass it to the following message.
	 */
	sts = VSgetVirtualInfo( msg, &operand._grid, NULL, &virtual ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
	
	sts = om$send(	msg	=  message VSdprPart.VSbuildIPATHs(
						     msg,
						     0,
						     bfCount,
						     bfList,
						     &virtual,
						     &result ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdprPart.VSbuildIPATHs", wrapup ) ;
        sts = VDreduce_range(msg, myEnv, &result, solidRange);
        if(!(sts&*msg&1))
        { 
          __DBGpr_com("REDUCE RANGE ATTEMPT FAILED");
          __DBGpr_obj("VDreduce_range failed for ",result);
	}
        else
        { 
          __DBGpr_com("REDUCE RANGE ATTEMPT SUCCEEDED");
          __DBGpr_obj("VDreduce_range success for ",result);
	}
        listOfOutputs[0] = result ;
	
	wrapup :
	vs$bulk_delete(	count	= 1,
	        	grids	= &gensolOE.obj_id,
			theEnv	= &gensolOE.mod_env ) ;
	/*
	 * Delete created cutting cylinders, if any.
	 */
	for( i = 0 ; i < MAX ; i++ ) {
	  if( cylsToDel[i] ) {
	    
	    vs$bulk_delete(	objenvs = notchList + i ) ;
	  }
	}
	vs$dotsInStsFld( dots = clear ) ;
	
	if( !( sts & 1 & *msg ) ) {
	  /*
	   * Post-failure restore !
	   */
	  vs$bulk_delete(	count	= 1,
				grids	= &parentInput,
				theEnv	= myEnv ) ;
	  
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
	} else {
	  /*
	   * Update beam tag, don't check return code: will be
	   * OM_W_NOTTAGGED if object has no tag connection.
	   */
	  om$change_tag_version() ;
	}
	if( bfCount ) _FREE( bfList ) ;
	
	return sts ;
	
} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSbooBeam ;

