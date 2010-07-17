/* $Id: VScpcnstfeet.I,v 1.3 2001/04/16 20:01:40 jayadev Exp $  */
/*************************************************************************
 * I/STRUCT
 *
 * File:      vsplate/VScpcnstfeet.I
 *
 * Description: split plate construction
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VScpcnstfeet.I,v $
 *      Revision 1.3  2001/04/16 20:01:40  jayadev
 *      TR#MP5031
 *
 *      Revision 1.2  2001/01/16 23:59:56  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/05/21  14:18:06  pinnacle
# Created: struct/vsplate/VScpcnstfeet.I by rchennup for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR   DESCRIPTION
 * 05/21/00  Jayadev  child surface swapping when one of the parent surf is
 *		      deleted - etl#2354 
 * 04/16/01  Jayadev  TR5031 - return status set properly
 *************************************************************************/

/*
	I/STRUCT
*/
class implementation VSsplPlate ;

/*
#define	vsDEBUG		1
#define	vserrDEBUG	1
*/

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "vsmeasmacros.h"

#include "bsmkvec.h"
#include "bslenvec.h"

#define MAX_DOUBLE	100000.0
extern long	VSinfPlaneSfInt() ;
extern OMuword	OPP_EMSplane_class_id ;

/* ---- Correction --------------------------------------------------
   Because splitting curve orientation can be inversed, the recompute
   of VSsplPlate no more swap child surfaces.
   This is done by evaluating centroids of child surfaces before and
   after recompute. Minimum distance between centroids preserve from
   surface swapping.

Marc Fournier (COC shipbuilding, Paris)			02/24/2000
------------------------------------------------------------------ */

/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct  GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	bndry[2],	/* GO of boundary	*/
        			parFtCpy ;	/* Cpy of my parent
        					    plate's ft.		*/
        struct GRid		*results ;	/* Cmps of split plate	*/
	struct GRobj_env	operand ;	/* Of this operation	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/
	unsigned		myMask ;	/* My mask of sub-plates*/
	int			i,		/* Loop index		*/
				maxSubPlates ;	/* Max. # of sub-plates	*/
	VSdspRep		oldRep ;	/* Of parent bef. place	*/
	int			delCurve ;	/* Temp. curve to del.? */

	struct	GRobj_env	SURF;
	IGRpoint		COG[4];
	IGRvector		VEC;
	IGRdouble		DST[4];
	BSrc			rc;
	struct	GRid		SWAP;
	IGRboolean		Cog3_Failed = FALSE , Cog2_Failed = FALSE ;


	__DBGpr_int ( "\n>> ACconstruct_feet on object", my_id );

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	delCurve= FALSE ;
	results = NULL ;
	parFtCpy._objid = NULL_OBJID ;

	/*
	 * The operand is the parent I consume.
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

	/*
	 * Fill construction list.
	 */
	__DBGpr_com ( ">> ACconstruct_feet:GRgetsymb" );
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	/*
	 * We need parent to have a surface output.
	 */
	__DBGpr_com ( ">> ACconstruct_feet:VSforceParentRep" );
 	sts = om$send(	msg	= message VSmodPlate.VSforceParentRep(
	 					msg,
						myEnv,
	 					&operand._grid,
	 					AC_3D_REP,
						AC_ENV_REP,
						VS_m_2dWCompute,
						VS_m_2dWCompute,
						&oldRep ),
 			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSmodPlate.VSforceParentRep", wrapup ) ;

	/*
	 * Consume parent plate, and get an image of its graphic member upon
	 * which we are going to act.
	 * The following call will set `operand.mod_env'.
	 */
	__DBGpr_com ( ">> ACconstruct_feet:vs$consume" );
  	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				nbfeet	= 1,
				objEnv	= &operand.mod_env,
                         	feet	= &parFtCpy._grid ) ;
  	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

	parFtCpy.mod_env = *myEnv ;

	__DBGpr_com ( ">> ACconstruct_feet:VSget_graphic_input" );
	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
			     msg, countOfInputs - 1, listOfInputs + 1, bndry ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	__DBGpr_com ( ">> ACconstruct_feet:VSgetSubMask" );
	sts = om$send(	msg	= message VSdivFeature.VSgetSubMask(
					msg, &myMask, &i, &maxSubPlates ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSgetSubMask", wrapup ) ;

	__DBGpr_com ( ">> ACconstruct_feet:_MALLOC" );
	if( !( results = _MALLOC( maxSubPlates, struct GRid ) ) ) vs$mem_fail();
	for ( i=0; i<maxSubPlates; i++ ) {
		results[i].objid = NULL_OBJID;
		results[i].osnum = myEnv->md_id.osnum;
	}

	if( vs$is_ancestry_valid(	object	= &bndry[0]._grid,
					classid = OPP_EMSplane_class_id ) ) {

		struct GRvg_construct	cst ;
		struct GRid		inter ;

		__DBGpr_com ( ">> ACconstruct_feet:vs$fill_cnst_list" );
		vs$fill_cnst_list(	Msg		= msg,
					Env_info	= myEnv,
					Display		= &mySymb.display_attr,
					Level		= mySymb.level,
					Cnst_list	= cst ) ;

		__DBGpr_com ( ">> ACconstruct_feet:VSinfPlaneSfInt" );
		sts = VSinfPlaneSfInt( msg, &bndry[0], &parFtCpy, &cst,
				       &inter ) ;
		__CheckRC( sts, *msg, "VSinfPlaneSfInt", wrapup ) ;

		delCurve = TRUE ;
		bndry[0]._grid	 = inter ;
		bndry[0].mod_env = *myEnv ;
	}

	/* Split surface with curve */
	__DBGpr_com ( ">> ACconstruct_feet:vs$split_surface_with_curve" );
	sts = vs$split_surface_with_curve(
					msg		= msg,
					surfId		= &parFtCpy._grid,
					surfEnv		= &parFtCpy.mod_env,
					curveId		= &bndry[0]._grid,
					curveEnv	= &bndry[0].mod_env,
					resultSymb	= &mySymb,
					resultList	= results ) ;
	__CheckRC( sts, *msg, "vs$split_surface_with_curve", wrapup ) ;

	__DBGpr_int ( "countOfInputs ", countOfInputs );

	/* Extract new surfaces centroids */
	if ( (countOfInputs == 3)
	||   (  (countOfInputs == 2)
	     && ((purpose & VS_K_InitialPlacement) == 0) ) ) {
		
		/* Get results[0] center */
                sts = vs$get_area_props ( msg      = msg,
                                          surfId   = &results[0],
                                          surfEnv  = myEnv,
                                          centroid = COG[0] );
                __CheckRC( sts, *msg, "vs$get_area_props()", EndOfCorrection ) ;
		
		/* Get results[1] center */
                sts = vs$get_area_props ( msg      = msg,
                                          surfId   = &results[1],
                                          surfEnv  = myEnv,
                                          centroid = COG[1] );
                __CheckRC( sts, *msg, "vs$get_area_props()", EndOfCorrection ) ;
	}

	/* Track Point correction */
	if (countOfInputs == 3) {
		
		/* Get track point */
		sts = om$send ( msg = message GRvg.GRcenter (
				msg,
				&bndry[1].mod_env.md_env.matrix_type,
				bndry[1].mod_env.md_env.matrix,
				COG[2] ),
				targetid = bndry[1].obj_id.objid,
				targetos = bndry[1].obj_id.osnum) ;
		__CheckRC( sts, *msg, "GRvg.GRcenter", EndOfCorrection ) ;
	
		/* Evaluate distances */
		BSmkvec ( &rc, VEC, COG[0], COG[2] );
		DST[0] = BSlenvec ( &rc, VEC );
		__DBGpr_dbl ( "distance Surface0/TrackPoint", DST[0] );
		
		BSmkvec ( &rc, VEC, COG[1], COG[2] );
		DST[2] = BSlenvec ( &rc, VEC );
		__DBGpr_dbl ( "distance Surface1/TrackPoint", DST[2] );
		
		/* Apply correction if needed */
		if (DST[0] <= DST[2]) {
			__DBGpr_str ( "Track point correction",
				      "surfaces well oriented." ); 
		}
		else {
			SWAP.objid       = results[0].objid;
			SWAP.osnum       = results[0].osnum;
			results[0].objid = results[1].objid;
			results[0].osnum = results[1].osnum;
			results[1].objid = SWAP.objid;
			results[1].osnum = SWAP.osnum;
			__DBGpr_str ( "Track point correction",
				      "swap surfaces." ); 
		}
	}

	/* Centroids correction */
	if (  (countOfInputs == 2)
	   && ((purpose & VS_K_InitialPlacement) == 0) ) {
	
		/* Initialize */
		SURF.mod_env.md_id.objid = myEnv->md_id.objid;
		SURF.mod_env.md_id.osnum = myEnv->md_id.osnum;
		
		/* Get centroid of Input:Surface0 */
		SURF.obj_id.objid = NULL_OBJID;
		sts = om$send ( msg = message NDmacro.ACreturn_foot (
				msg,
				VS_K_cpGrCmpSurf0,
				&SURF.obj_id,
				&SURF.mod_env.md_env.matrix_type,
				SURF.mod_env.md_env.matrix ),
				targetid = my_id ) ;
		if( !(sts & *msg & 1 )) Cog2_Failed = TRUE ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", Check_Surface1 ) ;
		
		/* Get Input:Surface0 center */
                sts = vs$get_area_props ( msg      = msg,
                                          surfId   = &SURF.obj_id,
                                          surfEnv  = &SURF.mod_env,
                                          centroid = COG[2] );
		if( !(sts & *msg & 1 )) Cog2_Failed = TRUE ;
                __CheckRC( sts, *msg, "vs$get_area_props()", Check_Surface1 ) ;
	
		/* Get centroid of Input:Surface1 */

Check_Surface1:
		SURF.obj_id.objid = NULL_OBJID;
		sts = om$send ( msg = message NDmacro.ACreturn_foot (
				msg,
				VS_K_cpGrCmpSurf1,
				&SURF.obj_id,
				&SURF.mod_env.md_env.matrix_type,
				SURF.mod_env.md_env.matrix ),
				targetid = my_id ) ;
		if( !(sts & *msg & 1 )) Cog3_Failed = TRUE ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", Check_Order ) ;
		
		/* Get Input:Surface1 center */
                sts = vs$get_area_props ( msg      = msg,
                                          surfId   = &SURF.obj_id,
                                          surfEnv  = &SURF.mod_env,
                                          centroid = COG[3] );
		if( !(sts & *msg & 1 )) Cog3_Failed = TRUE ;
                __CheckRC( sts, *msg, "vs$get_area_props()", Check_Order ) ;

Check_Order:
                if(Cog2_Failed && Cog3_Failed){
                        __DBGpr_com("compute of split failed"); 
                        goto wrapup; 
                }
                else
                {
                    /*
                     * one of the old feet exist
                     * set the return message properly 
                     * for TR#5031
                     */
                        sts = *msg = 1;
                } 
	
		if( Cog2_Failed ){
			DST[0] = MAX_DOUBLE ;
			DST[2] = MAX_DOUBLE ;
		}
		else{
			BSmkvec ( &rc, VEC, COG[0], COG[2] );
			DST[0] = BSlenvec ( &rc, VEC );

			BSmkvec ( &rc, VEC, COG[1], COG[2] );
			DST[2] = BSlenvec ( &rc, VEC );
		}

		if( Cog3_Failed ){
			DST[1] = MAX_DOUBLE ;
			DST[3] = MAX_DOUBLE ;
		}
		else{
			BSmkvec ( &rc, VEC, COG[0], COG[3] );
			DST[1] = BSlenvec ( &rc, VEC );

			BSmkvec ( &rc, VEC, COG[1], COG[3] );
			DST[3] = BSlenvec ( &rc, VEC );
		}
		__DBGpr_dbl ( "distance NewSurface0/OldSurface0", DST[0] );
		__DBGpr_dbl ( "distance NewSurface0/OldSurface1", DST[1] );
		__DBGpr_dbl ( "distance NewSurface1/OldSurface0", DST[2] );
		__DBGpr_dbl ( "distance NewSurface1/OldSurface1", DST[3] );
		if(Cog2_Failed){
			if(DST[3]<DST[1]) goto EndOfCorrection;
			else goto Swap_Surfaces;
		}
                if(Cog3_Failed){
                        if(DST[0]<DST[2]) goto EndOfCorrection;  
                        else goto Swap_Surfaces;       
                }	
	
		if ( (DST[0] <= DST[1]) && (DST[3] <= DST[2]) ) {
			__DBGpr_str ( "Centroids correction",
				      "surfaces don't need to swap." ); 
		}
		else if ( (DST[0] >= DST[1]) && (DST[3] >= DST[2]) ) {
Swap_Surfaces :
			SWAP.objid       = results[0].objid;
			SWAP.osnum       = results[0].osnum;
			results[0].objid = results[1].objid;
			results[0].osnum = results[1].osnum;
			results[1].objid = SWAP.objid;
			results[1].osnum = SWAP.osnum;
			__DBGpr_str ( "Centroids correction",
			 	      "prevents surfaces swapping." ); 
		}
		else {
			__DBGpr_str ( "Error case",
				      "can't apply correction." ); 
		}
	}

EndOfCorrection:
	for( i = 0 ; i < maxSubPlates ; i++ ) {
		if( myMask & ( 1 << i ) ) {
			/* Keeping result: NO OP */
		} else {
			vs$bulk_delete(	count	= 1,
					grids	= results + i,
					theEnv	= &parFtCpy.mod_env ) ;
		}
	}

	*countOfOutputs = maxSubPlates ;

	for( i = 0 ; i < maxSubPlates ; i++ ) listOfOutputs[i] = results[i] ;

	vs$dotsInStsFld( dots = clear ) ;

        wrapup :
        	if( delCurve ) {
        		vs$bulk_delete(	count	= 1,
					objenvs	= &bndry[0] ) ;
        	}
        	if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	count	= 1,
					objenvs	= &parFtCpy ) ;

	    		/*
	    		 * Placement : failure. Compute : degraded state.
	    		 */
	    		if( purpose & VS_K_InitialPlacement ) {
				/*
				 * Restore things since method failed.
				 */
				long rc ;

				vs$unconsume(	msg	= &rc,
						object	= &operand._grid,
						mod_env	= &operand.mod_env,
						rep	= oldRep,
						compute	= oldRep != AC_2D_REP );

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

		_FREE( results ) ;

	__DBGpr_com ( "\n<< ACconstruct_feet" );

                return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSsplPlate ;
