/* $Id: VSipcnstfeet.I,v 1.5 2001/08/15 15:46:58 jayadev Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsplate/VSipcnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSipcnstfeet.I,v $
 *  Revision 1.5  2001/08/15 15:46:58  jayadev
 *  *** empty log message ***
 *
 *  Revision 1.4  2001/03/13 17:13:17  jayadev
 *  changes for ASCII control
 *
 *  Revision 1.3  2001/03/02 20:16:27  jayadev
 *  ASCII prcCutout changes only for VSholPlates
 *
 *  Revision 1.2  2001/01/16 23:59:58  ramarao
 *  *** empty log message ***
 *
# Revision 1.4  2000/11/09  17:42:00  pinnacle
# Replaced: struct/vsplate/VSipcnstfeet.I for:  by jpulapar for Service Pack
#
 # Revision 1.3  2000/05/05  14:02:44  pinnacle
 # Replaced: struct/vsplate/VSipcnstfeet.I for:  by rchennup for Service Pack
 #
 # Revision 1.1  2000/05/04  04:01:18  pinnacle
 # Created: struct/vsplate/VSipcnstfeet.I by rchennup for Service Pack
 #
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 *      05/03/00    Jayadev     Modified for TR179901434
 *      11/06/00    Jayadev     TR#MP3357- VSget_graphic_input output changed
 *      03/02/01    Jayadev     ASCII prcCutout control only for hole plates 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSimbPlate ;

#include <string.h>
#include "EMSmsgdef.h"
#ifndef emsmapdef_include
#	include "emsmapdef.h"
#endif
#ifndef emsimpdef_include
#	include "emsimpdef.h"
#endif
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsplcvinfpln.h"

extern IGRboolean		ASbroadcast_in_progress;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ; 
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long		sts,		/* OM return code		*/
			amConsumed ;	/* Am I consumed ?		*/
	double		offset ;	/* For surface -> solid		*/
	struct GRvg_construct
			cst ;		/* Construction list of result	*/
	struct GRobj_env
			operand,	/* ... of this operation	*/
			parentOutput,	/* My parent plate's output	*/
			parOE,	      
#define MAX VS_K_MAX_BOUNDARIES
			bdryList[MAX],	/* List of boundaries		*/
			copyToDelete ;	/* Temporary to get rid of	*/
	VSpartAttr	myAttr ;	/* My part attributes		*/
	VSplateAttr	myInfo ;	/* My plate attributes		*/
	int		bdryCount,	/* Count of boundaries		*/
			filterCount,	 		
			consumed,	/* TRUE if parent consumed	*/
			surfaceIsPlanar;/* TRUE if surface if a plane	*/
	VSdspRep	myRep,		/* My NV representation		*/
			oldRep ;	/* Of parent before placement	*/
	IGRboolean	saveBroadCast ;	/* Saves AS broadcast		*/
	struct GRsymbology
			mySymb;		/* My symbology			*/
	struct GRid	result ;	/* ... of operation		*/
	char		mustDel[MAX] ;	/* Proj's of bdries to be del'd	*/
	int		i,retSts, retSts1;	
	IGRboolean      *processFlags;
	
	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }
	
	*msg			= MSSUCC ;
	consumed		= FALSE ;
	copyToDelete._objid	= result.objid = NULL_OBJID ;
	bdryCount		= 0 ;
	filterCount		= 0 ;
        processFlags            = NULL;
	memset( mustDel, 0, MAX ) ;
	
	/*
	 * The operand is the parent I consume.
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

        parOE.obj_id.objid = NULL_OBJID;
        parOE.obj_id.osnum = 2;

        // get the parent of the ACpretend
        __DBGpr_obj("pretendID ",operand.obj_id);
        retSts1 = VDobjGetPretendParent(&operand.obj_id,&parOE.obj_id);
        if(!(retSts&1) || (parOE.obj_id.objid == NULL_OBJID))
        {
          retSts1 = 1;
          parOE.obj_id = operand.obj_id;
        }
        __DBGpr_obj("parent plate ",parOE.obj_id);
	
	/*
	 * Inhibit broadcast since offsetting will copy input surface.
	 */
	saveBroadCast = ASbroadcast_in_progress;
	ASbroadcast_in_progress = TRUE ;
	
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
	
	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;
	
	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	sts = vs$fixIfNoRep(	inRep	= myRep,
				parentId= &operand._grid,
				outRep	= &myRep ) ;
	
	/*
	 * We need parent to have a surface output.
	 */
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
	/*
         * continue the process even we fail to force the rep on parent 
	 * __CheckRC( sts, *msg, "VSmodPlate.VSforceParentRep", wrapup );
         */
	
	/*
	 * Get attributes.
	 */
	myAttr.Iwant	= VS_m_Thickness | VS_m_CutOff ;
	myAttr.specific	= (void *) &myInfo ;
	
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;
	
	/*
	 * Whatever the representation setting, the simplified one is used if
	 * I am consumed so those who consume me can be sure they will get a
	 * surface-output when they send me an NDmacro.ACconsume message.
	 */
	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &amConsumed),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;
	if( amConsumed & 1 ) {
	  om$send(msg	= message VSfeature.VSgetConsumedRep( &myRep ),
		  targetid= my_id ) ;
	  if( !myRep ) myRep = AC_2D_REP ;
	}
	
 	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				nbfeet	= 1,
				objEnv	= &operand.mod_env,
				feet	= &parentOutput._grid ) ;
  	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;
	
	parentOutput.mod_env = *myEnv ;
	parOE.mod_env        = operand.mod_env ;
	
	consumed = TRUE ;
	
	if( myRep == AC_2D_REP ) {
	  /*
	   * Skip computation: just return the output that you just
	   * consumed.
	   */
	  goto SURFACE_DISPLAY ;
	}
	bdryCount = countOfInputs - 1 ;
	if( bdryCount > MAX ) bdryCount = MAX ;
	
	/*
	 * Knowing if plate lies on a plane can speed up the impose-boundary
	 * operation.
	 */
	surfaceIsPlanar = vs$is_surface_planar(	msg	= msg,
						surfId	= &parentOutput._grid,
						surfEnv	= &parentOutput.mod_env ) ;


	sts = om$send(msg = message VScpx.VSget_graphic_input(
	                    msg, bdryCount, listOfInputs + 1, bdryList ),
		      targetid = my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;
	
        if(bdryCount>0) processFlags = _MALLOC(bdryCount, IGRboolean);

	for(i = 0; i<bdryCount; i++) processFlags[i] = TRUE;

        retSts = 0;

        __DBGpr_com("Trying the ASCII macro Filter");	
	retSts = VSfilterASCIImacros(parOE, listOfInputs + 1, 
                                     processFlags, bdryList, bdryCount);
	if(retSts)
	{
	  __DBGpr_com("VSfilterASCIImacros successful");
	  
	  for(i=0; i<bdryCount; i++)
	  {
	    if(processFlags[i])
	    {
	      bdryList[filterCount] = bdryList[i];
	      filterCount ++;
	    }
	  }
	  __DBGpr_int(" filterCount ",filterCount);
	  
	  if(filterCount == 0) goto skip_impose;

	  bdryCount = filterCount;
	}
	if(bdryCount == 0) goto skip_impose;
	
	if( surfaceIsPlanar ) {
	  /*
	   * If the surface is planar, then all boundaries which are
	   * planar curves are projected onto the surface using the
	   * normals of the boundaries' planes as projection vectors.
	   * Then the projections of the boundaries are used for the
	   * imposition.
	   */
	  struct IGRplane	plOfSf, plOfCv ;
	  IGRpoint	        ptPlSf, ptPlCv ;
	  IGRvector	        nmPlSf, nmPlCv ;
	  struct GRid	        prjCv ;
	  
	  plOfSf.point = ptPlSf ; plOfSf.normal = nmPlSf ;
	  plOfCv.point = ptPlCv ; plOfCv.normal = nmPlCv ;
	  
	  sts = om$send(	msg	= message GRvg.GRdetplane(
						  msg,
						  &parentOutput._matrix_type,
						  parentOutput._matrix,
						  &plOfSf ),
				targetid= parentOutput._objid,
				targetos= parentOutput._osnum ) ;
	  
	  for( i = 0 ; i < bdryCount ; i++ ) {
	    sts = om$send(	msg	= message GRvg.GRdetplane(
						       msg,
						       &bdryList[i]._matrix_type,
						       bdryList[i]._matrix,
						       &plOfCv ),
				targetid= bdryList[i]._objid,
				targetos= bdryList[i]._osnum ) ;
	    if( !( sts & 1 & *msg ) ) continue ;
	    
	    sts = VSprjCvOntoInfPlane(
				      msg,
				      &bdryList[i]._grid,
				      &bdryList[i].mod_env,
				      &plOfSf,
				      plOfCv.normal,
				      &cst,
				      &prjCv ) ;
	    if( sts & 1 & *msg ) {
	      bdryList[i]._grid 	= prjCv ;
	      bdryList[i].mod_env	= *cst.env_info ;
	      mustDel[i] = TRUE ;
	    }
	  }
	  
	}
	sts = om$send(	msg	= message VSimbPlate.VSimposeBoundary(
						     msg,
						     bdryCount,
						     bdryList,
						     &parentOutput,
						     surfaceIsPlanar ),
			targetid= my_id ) ;
        if( !( sts & 1 & *msg ) ) {
	  if( purpose & VS_K_InitialPlacement ){
	    printf("Error impose boundary on Plate!!\n" );
	    UI_status(" Error impose boundary on Plate !!" );
	    sleep( 2 );
	  }
	  else{
	    printf("Error Compute impose boundary %d, %d \n",OM_Gw_current_OS, my_id);
	  }
	  goto wrapup ;
        }
 skip_impose:
	switch( myRep ) { 
	  
	case AC_3D_REP		:
	  offset = myInfo.thickness ;
	  goto OFFSET_SURF ;
	  
	case AC_ENV_REP		:
	  offset = myInfo.cut_off ;
	  /* No "break" intentionally */
	  
	  OFFSET_SURF :
	    vs$dotsInStsFld( dots = 1 ) ;
	  copyToDelete = parentOutput ;
	  
	  /*
	   * "isNatNorm" is TRUE, since the top source plate took care
	   * of reversing the orientation if need be.
	   */
	  sts = vs$offset_surface_to_solid(
					   msg		= msg,
					   surfId	= &parentOutput._grid,
					   surfEnv	= &parentOutput.mod_env,
					   offset	= offset,
					   isNatNorm	= TRUE,
					   cst		= &cst,
					   isPlanar	= surfaceIsPlanar,
					   offSolId	= &result ) ;
	  
	  __CheckRC( sts, *msg, "vs$offset_surface_to_solid", wrapup ) ;
	  break ;
	  
	case VS_m_2dWCompute	:
	  SURFACE_DISPLAY		:
	    result = parentOutput._grid ;
	  break ;
	  
	default    : /* Should never get here. */
	  *msg = MSINARG ; sts = OM_W_ABORT ; goto wrapup ;
	}
	
	*countOfOutputs  = 1 ;
	listOfOutputs[0] = result ;
	
	wrapup :
        _FREE(processFlags);
	  ASbroadcast_in_progress = saveBroadCast ;
	/*
	 * EMS has output info message to the status field.
	 */
	vs$dotsInStsFld( dots = clear ) ;
	
	/*
	 * Delete projections of boundaries, if any.
	 */
	for( i = 0 ; i < bdryCount ; i++ ) {
	  if( mustDel[i] ) {
	    vs$bulk_delete(	objenvs = bdryList + i ) ;
	  }
	}
	if( !IF_NULL_OBJID( copyToDelete._objid ) ) {
	  /*
	   * Must delete surface which was input to offset
	   * operation.
	   */
	  vs$bulk_delete(	count	= 1,
				objenvs	= &copyToDelete ) ;
	}
	if( !( ( sts & 1 ) && ( *msg & 1 ) ) && consumed ) {
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
				compute	= TRUE ) ;
	    
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
	
	return sts ;
	
} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSimbPlate ;

