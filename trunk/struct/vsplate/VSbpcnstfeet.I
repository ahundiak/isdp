/* $Id: VSbpcnstfeet.I,v 1.10 2001/11/12 21:04:40 ylong Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsfeature/VSbpcnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbpcnstfeet.I,v $
 *	Revision 1.10  2001/11/12 21:04:40  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.9  2001/11/12 18:25:33  ylong
 *	review of algo for getting correct 2D rep
 *	
 *	Revision 1.8  2001/11/07 20:40:57  jayadev
 *	fix for TR# MP5729
 *	
 *	Revision 1.7  2001/10/01 16:52:56  jayadev
 *	changes for TR#MP5490
 *	
 *	Revision 1.6  2001/08/07 18:37:59  ahundiak
 *	ah 5490
 *	
 *	Revision 1.5  2001/04/02 22:03:08  ramarao
 *	Fixed TR# 4989.
 *	
 *	Revision 1.4  2001/03/14 00:39:20  jayadev
 *	reduce range for booPlates
 *	
 *	Revision 1.3  2001/01/31 17:38:56  jayadev
 *	changes made for compatibility with the boolean enhancement 
 *      of iteration by operator curve scaling
 *	
 *	Revision 1.2  2001/01/16 23:59:54  ramarao
 *	*** empty log message ***
 *	
# Revision 1.3  2000/05/05  13:57:46  pinnacle
# Replaced: struct/vsplate/VSbpcnstfeet.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/30  12:35:10  pinnacle
# Created: struct/vsplate/VSbpcnstfeet.I by rchennup for Service Pack
#
# Revision 1.5  2000/03/31  22:55:24  pinnacle
# (No comment)
#
# Revision 1.4  2000/03/30  23:00:20  pinnacle
# (No comment)
#
# Revision 1.3  2000/03/28  21:24:04  pinnacle
# (No comment)
#
# Revision 1.2  2000/03/15  22:38:34  pinnacle
# Replaced: vsplate/VSbpcnstfeet.I for:  by impd252 for struct
#
*
* History:
*	MM/DD/YY	AUTHOR		DESCRIPTION
*
*	03/31/00	Ming	       TR179901209
*      	04/30/00        Jayadev         TR179901413 - deleted waste graphics
*      	05/03/00	Jayadev         TR179901434
*      	01/31/00	Jayadev         enchanced boolean compatibility changes
*     	04/02/01	Rama Rao	TR# 4989
*       08/07/01        ah              TR# 5490 Fixed 2d reps
*       10/01/01        Jayadev         TR# 5490   
*       11/07/01        Jayadev         TR# 5729 - base/offset of the booplate
*                                       children flipping as my 2dCompute is
*                                       giving my children a wrong surface 
*       11/12/01        Jayadev         TR# 5729 - geometry checks for getting
*                                       my base surface for 2D w.r.t parent
*                                       output - code tabbed in emacs 
***************************************************************************/
class implementation VSbooPlate ;

#include <string.h>
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "VDgeom.h"
#include "v_miscmacros.h"
#include "vsipthmacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "vsplatedef.h"
#include "bssfeval.h"
#include "bsmdistptsf.h"
#include "bserr.h"
/*
 * Includes of function prototypes.
 */
#include "vsmkpenetcyl.h"
#include "vsprtinasbly.h"
#include "vsvirtualinf.h"
#include "vsAPImac.h"

extern OMuword	OPP_GRcurve_class_id ;
extern IGRboolean               ASbroadcast_in_progress ;

extern GRclassid        OPP_VSsubPlate_class_id, OPP_VSbooPlate_class_id,
                        OPP_VSimbPlate_class_id, OPP_VSholPlate_class_id;
/*
 * This routine finds out the match for the parent surface from
 * the list of surfaces and returns the matching index in the list
 */ 
IGRint VSgetBaseSrfIndex(
                         struct GRobj_env *parSrf,
                         VSipathANDid     *bfList, 
                         IGRint            bfCount,
                         struct GRmd_env  *myEnv, 
                         struct GRid      *myID, 
                         IGRint           *retIndex
                        )
{
  IGRint                i, retFlag = 0;
  IGRlong               sts, msg, rc;
  struct IGRbsp_surface *gensolSrfGeom, 
                        *parentSrfGeom;
  IGRpoint              srfPoint, parPoint; 
  IGRdouble             distSupp, u, v, tol;
  VSopHistory           *history=NULL, *h ;
  struct GRid           res_id;
  struct GRobj_env      par_plate, srfOE;
 
  gensolSrfGeom   = NULL;
  parentSrfGeom   = NULL;
  par_plate.obj_id.objid = NULL_OBJID; 
  srfOE.obj_id.objid     = NULL_OBJID; 

  vdgeom$GetTolerance(cht = &tol);

  __DBGpr_dbl("CHTOL ", tol);
  /* Try to get the parent surface from the topmost source plate
   * as the reference; If this attempt fails, we take the immediate
   * parent surface as our refernce for comparison against the 
   * input list of surfaces of gensolid 
   */
  sts = _VD_SEND_OBJN( *myID, VSfeature.VSgetOperationHistory(
                       &msg, myEnv, &history ) );
  if((sts&msg&1))
  {
    for( h = history ; h ; h = h->next )
    {
      res_id.objid = h->resultId;
      res_id.osnum = h->resultOs;
      
      __DBGpr_obj("Parent ", res_id );
      
      if( vd_$is_ancestry_valid( object  = &res_id,
				 classid  = OPP_VSbooPlate_class_id ) ||
	  vd_$is_ancestry_valid( object  = &res_id,
				 classid  = OPP_VSimbPlate_class_id ) ||
	  vd_$is_ancestry_valid( object  = &res_id,
				 classid  = OPP_VSholPlate_class_id ) )  continue;
      
      par_plate._objid  = h->resultId;
      par_plate._osnum  = h->resultOs;
      par_plate.mod_env = h->resultEnv;
    }
    if(par_plate.obj_id.objid == NULL_OBJID)
    {
      printf("\n FAILED to find parent source plate for [%d,%d] \n",
	     myID->objid, myID->osnum);
      goto immediate_parent;
    }
    __DBGpr_obj("myID ", *myID);
    __DBGpr_obj("my Source Parent  ", par_plate.obj_id);

    /* 
     * I expect my source parent to be in 2D by the
     * virtue of myself being in 2D
     */
    vdobj$GetFoot( objOE    = &par_plate,
		   footName = VS_K_plGrCmpName,
		   footOE   = &srfOE );
    if (srfOE.obj_id.objid == NULL_OBJID)
    {
      printf("\n FAILED to find bottom source for plate [%d,%d] \n",
	     par_plate.obj_id.objid, par_plate.obj_id.osnum);
      goto immediate_parent;
    }
    srfOE.mod_env = par_plate.mod_env;
    __DBGpr_obj("parent surface from source ", srfOE.obj_id);
    // get the geometry of the topmost parent surface
    vs$get_geometry(msg      = &msg ,
		    grobjId  = &srfOE.obj_id,
		    grobjEnv = &srfOE.mod_env,
		    geometry = &parentSrfGeom ) ;
    if(!(msg &1) || (parentSrfGeom == NULL))
    {
      __DBGpr_obj("FAILED parent surface geometry for ", parSrf->obj_id);
      goto immediate_parent;
    }
    __DBGpr_com("Successfully got parent surface from source ");
  }
  else
  { 
  immediate_parent:
    __DBGpr_com(" immediate_parent ");
    // get the geometry of the immediate parent surface
    vs$get_geometry(msg      = &msg ,
		    grobjId  = &parSrf->obj_id,
		    grobjEnv = &parSrf->mod_env,
		    geometry = &parentSrfGeom ) ;
    if(!(msg &1) || (parentSrfGeom == NULL))
    {
      __DBGpr_obj("FAILED parent surface geometry for ", parSrf->obj_id);
      goto wrapup;
    }
  }
  // index 0 has the solid in the bfList 
  for(i=1; i<bfCount; i++)
  {
    _FREE(gensolSrfGeom);
    __DBGpr_int("Check parent surface against gensolid surface at index", i);
    
    srfOE.obj_id = bfList[i].id;
    srfOE.mod_env= *myEnv;
    
    // get the geometry of the gensolid surface
    vs$get_geometry(msg      = &msg ,
                    grobjId  = &srfOE.obj_id,
                    grobjEnv = &srfOE.mod_env,
                    geometry = &gensolSrfGeom ) ;
    if(!(msg &1) || (gensolSrfGeom == NULL))
    {
      __DBGpr_obj("FAILED gensolid surface geometry for ", srfOE.obj_id);
      goto wrapup;
    } 
    BSsfeval( gensolSrfGeom, 0.5, 0.5, 0, srfPoint, &rc ) ;
    if( rc != BSSUCC)
    {
      printf("\n FAILED point [0.5,0.5] of gensolid surface at index %d \n", i);
      goto wrapup;
    }
    __DBGpr_vec("Point on gensolid surface", srfPoint);
    
    // check for distance from the parent surface
    __DBGpr_com(" check for distance from the parent surface ");
    
    distSupp = 0.0;
    BSmdistptsf(&rc, parentSrfGeom, srfPoint, &u, &v, parPoint, &distSupp);
    if(rc != BSSUCC)
    {
      printf("\n FAILED in BSmdistptsf - of parSurf.txt and Point\n");
      VDdumpSurface(NULL, parentSrfGeom, "parSurf.txt");
      printf("\n Point [%f,%f,%f] \n", srfPoint[0],
	                               srfPoint[1], srfPoint[2]);
      goto wrapup;
    }
    __DBGpr_int("index ", i); 
    __DBGpr_dbl("distSupp ", distSupp); 
    if(distSupp < tol)
    {
      __DBGpr_int("gensolid has correct base surface at index ", i);
      *retIndex = i;
      retFlag = 1;
      goto wrapup;
    }
    
  }
  
  //Some surface should match parent surface by this time
  __DBGpr_com("FAILURE: None of gensolid's surfaces matched to parent ");
  retFlag = 0;
 wrapup:
  if( history ) VSfreeOpHistory( history ) ;
  _FREE(parentSrfGeom);
  _FREE(gensolSrfGeom);
  return retFlag;
  
}

/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
			countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ; 
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {
  
  long		        sts,		/* OM return code		*/
                        amConsumed ;	/* Am I consumed ?		*/
  int		        nbNotches,	/* Number of solids		*/
                        i,j,		/* Loop-on-operators index	*/
                        consumed,	/* TRUE : if plate is consumed  */
                        bfCount ;	/* Count of cmps in input solid	*/
  VSipathANDid	        *bfList ;	/* List of cmps in input solid	*/
  struct GRid	        myGRid, result ;/* ... of this operation	*/
  struct GRobj_env
                        operand,	/* ... of this operation	*/
#define MAX VS_K_bpMAX_NOTCHES
			notchList[MAX],	/* Graphic input of operators	*/
			parentOutput ;	/* My parent plate's output	*/
	struct GRvg_construct
			cst ;
	VSdspRep	myRep,		/* My display representation	*/
			oldRep ;	/* Parent's rep before place	*/
	struct GRsymbology
			mySymb ;	/* My symbology			*/
	IGRchar		cylsToDel[MAX] ;/* Flags cyls to be deleted	*/
	struct GRobj_env myOperand;
	IGRboolean	compute2DFlag=FALSE;
        IGRboolean      saveBroadcast ; /* Save-broadcast flag          */
	VSboolRef       refList[MAX];
        int             refCount = 0;
        struct GRobj_env 
                        gensolOE;
        GRrange         solidRange;
        IGRshort        world = TRUE;

	SetProc( VSboo_ACconstruct ); Begin
					
	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }
	
	*msg		= MSSUCC ;
	sts		= OM_S_SUCCESS ;
	consumed	= FALSE ;
	result.objid	= NULL_OBJID ;
	bfList		= NULL ;
	bfCount		= 0 ;
	
        myOperand.obj_id.objid = NULL_OBJID ;
	memset( cylsToDel, 0, MAX ) ;

        myGRid.objid = my_id;	
        myGRid.osnum = OM_Gw_current_OS;	
	/*
	 * The operand of the operation is the parent plate I consume.
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
	/*
	 * This should not be the cause for a failure. - RR TR# 4989.
	 */
        if( !(sts&1&(*msg)) && !( purpose & VS_K_InitialPlacement) )
        {
          sts = om$send(  msg     = message GRvg.GRgetsymb( msg, &mySymb ),
			  mode    = OM_e_wrt_message,
			  targetid= my_id ) ;
        }
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;
	
	vs$fill_cnst_list(	Env_info	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;
	
	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;
	
	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	oldRep = myRep ;
	sts = vs$fixIfNoRep(	inRep	= myRep,
				parentId= &operand._grid,
				outRep	= &myRep ) ;
	
	/*
	 * We need parent to have a solid output.
	 */
	if(( purpose & VS_K_InitialPlacement )
	   || oldRep != myRep
	   || VSisPartInAssembly( msg, &operand._grid ) ) 
	{
	  
	  sts = om$send(msg = message VSmodPlate.VSforceParentRep(
	                                         msg,
	                                         myEnv,
	                                         &operand._grid,
	                                         AC_2D_REP, VS_m_2dWCompute,
	                                         AC_3D_REP, AC_3D_REP,
	                                         &oldRep ),
			targetid= my_id ) ;
	  __CheckRC( sts, *msg, "VSmodPlate.VSforceParentRep", wrapup );
	  
	} else if( myRep & AC_2D_REP ) {
	  sts = om$send(msg = message VSmodPlate.VSforceParentRep(
	                                         msg,
	                                         myEnv,
	                                         &operand._grid,
	                                         AC_3D_REP, AC_3D_REP,
	                                         myRep, myRep,
	                                         &oldRep ),
			targetid= my_id ) ;
	}
	
	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &amConsumed),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;
	
	if( amConsumed & 1 ) {
	  om$send(msg	= message VSfeature.VSgetConsumedRep( &myRep ),
		                  targetid= my_id ) ;
	}
	
	/* Added by Ming for TR179901209 */
        /*
        ** We need to create temporary solid to construct 3D rep. since
        ** parent object will be consumed with surface definition.
        */
        sts = vs$return_gr_copy( msg     = msg,
                                 strEnv  = myEnv,
                                 strElement= operand.obj_id,
                                 solidRep = &myOperand.obj_id );
        __CheckRC( sts, *msg, "VSreture_gr_copy", wrapup ) ;
        myOperand.mod_env = *myEnv;
	
	/*
	 * Consume parent. The following call will set `operand.mod_env'.
	 */
	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				nbfeet	= 1,
				objEnv	= &operand.mod_env,
				feet	= &parentOutput._grid ) ;
	__CheckRC( sts, *msg, "VSconsume", wrapup ) ;
	
	parentOutput.mod_env = *myEnv ;
	
        __DBGpr_obj("ParentOutput ",parentOutput.obj_id);
	
        gensolOE = myOperand;
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
	consumed = TRUE ;
	
	nbNotches = countOfInputs - 1 ;
	
	if( nbNotches > MAX ) nbNotches = MAX ;
	/*
	 * Get root operator solids.
	 */
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
	                           object  = &notchList[i]._grid,
	                           classid = OPP_GRcurve_class_id ) ) {
	    
	    struct GRid	cylinder ;
	    int		saveStyle ;
	    
	    saveStyle 		= cst.display->style ;
	    cst.display->style	= 3 ;
	    sts = VSmakePenetratingCyl(	msg,
					&parentOutput._grid,
					&parentOutput.mod_env,
					&notchList[i]._grid,
					&notchList[i].mod_env,
					&cst,
					&cylinder,
					solidRange ) ;
	    cst.display->style	= saveStyle ;
	    if( !( sts & 1 & *msg ) ) goto wrapup ;
	    
	    cylsToDel[i]		= TRUE ;
	    notchList[i]._grid	        = cylinder ;
	    notchList[i].mod_env	= *cst.env_info ;
	    
	    refList[i].type             = VS_K_blCurve ;
	    refList[i].new              = notchList[i] ;
	  }
	}
        refCount = nbNotches ;
	
	switch( myRep ) {
	  
	  case VS_m_2dWCompute	:
	  case AC_2D_REP:
	  case AC_ENV_REP		:
	  case AC_3D_REP		:
	    /*
	     * Save component structure of operand solid before boolean
	     * operation.
	     */
	    /* Commented by Ming for TR179901209 
	       sts = vs$getIPATHsandIDs(
	                     msg        = msg,
	                     owner	= &parentOutput._grid,
	                     ownerIndex	= 0,
	                     count	= &bfCount,
	                     p_list	= &bfList ) ;
	       __CheckRC( sts, *msg, "vs$getIPATHsandIDs", wrapup ) ;
	    */
	    
	    /* Modified by Ming for TR179901209 */
	    
	    /* commented for making use of boolean changes of operator 
	     * curve scaling;
	     *********************************************************
	     sts = om$send( msg	= message VSbooPlate.VSconstruct_3D_rep(
	                                  msg,
	                                  nbNotches,
	                                  notchList,
	                                  &parentOutput,
	                                  &cst,
	                                  &result ),
	                targetid= my_id ) ;
	     __CheckRC( sts, *msg, "VSbooPlate.VSconstruct_3D_rep", wrapup );
	    ***************************************************************/
	    
	    /*
	     * `vs$make_boolean_difference' copies the operators, so save as
	     * broadcast to prevent graph copy.
	     */
	    saveBroadcast           = ASbroadcast_in_progress ;
	    ASbroadcast_in_progress = TRUE ;
	    
	    sts =vs$make_boolean_difference(msg             = msg,
					    optrCount       = nbNotches,
					    optrList        = notchList,
					    operand         = &myOperand,
					    resCst          = &cst,
					    compress        = TRUE,
					    oneAtATime      = TRUE,
					    result          = &result,
					    refCount        = refCount, 
					    refList         = refList,
					    range           = solidRange );
	    ASbroadcast_in_progress = saveBroadcast ;
	    __CheckRC( sts, *msg, "make_boolean_difference", wrapup );
	    
	    /*
	    ** Get component structure of the solid
	    */
	    sts = vs$getIPATHsandIDs(
	                             msg        = msg,
	                             owner      = &result,
	                             ownerIndex	= 0,
	                             count	= &bfCount,
	                             p_list	= &bfList ) ;
	    __CheckRC( sts, *msg, "vs$getIPATHsandIDs", wrapup ) ;
	    
	    if( myRep == AC_3D_REP || myRep == AC_2D_REP || myRep == VS_m_2dWCompute) {
	      
	      struct GRid virtual ;
	      
	      /*
	       * Get virtual parent since real parent may be a
	       * pretend.
	       */
	      sts = VSgetVirtualInfo( msg, &operand._grid, NULL,
				      &virtual ) ;
	      sts = om$send(
		msg	=  message VSdprPart.VSbuildIPATHs(
		                             msg,
		                             0,
		                             bfCount,
		                             bfList,
		                             &virtual,
		                             &result ),
		           targetid= my_id ) ;
	      __CheckRC( sts, *msg, "VSdprPart.VSbuildIPATHs", wrapup ) ;
	    }
	    if( myRep == AC_2D_REP || myRep == VS_m_2dWCompute) {
	      
	      struct GRid solidID;
              IGRint      index, retSts;
              IGRint      isPlanar = TRUE;
	      solidID = result;
	      
              index  = -1;
              retSts =  0;
	      
              /*
               * Geometry check has been commented for time being
               * Will be used if necessary in the future 
               * 
              retSts = VSgetBaseSrfIndex(&parentOutput,bfList, bfCount, 
                                         cst.env_info,&myGRid,&index); 
              if((retSts == 0) || (index == -1)) 
              {
                printf("FAILED to get the base surface index for [%d,%d] \n",
		       my_id, OM_Gw_current_OS);

              }
               *
               */
              /*
               * Get the proper index of my base surface - TR# MP5729
               * Hard code index based on the way EMS arranges surfaces
               * of solid; Look at documentation in VSpltopbotmp.I file
               */
               
              isPlanar = vs$is_surface_planar(
	                         msg = msg,
                             surfId  = &parentOutput.obj_id,
                             surfEnv = &parentOutput.mod_env );

              if(isPlanar) index = 2;
    	      else         index = 1; 

	      sts = vs$grCopy(msg	= msg,
			      frEnv	= cst.env_info,
			      frObj	= &bfList[index].id,
			      toEnv	= cst.env_info,
			      toObj	= &result,
			      symb	= &mySymb ) ;  
	      
	      vs$bulk_delete( count   = 1,
			      grids   = &solidID,
			      theEnv  =  cst.env_info) ; 
	      
	    }
	    
	    break ;
	    /* -----------------------------------
	     * TR5490 The 2d stuff was just not working even on simple plates
	     * so let the solid be computed then just copy out the base surface
	     */
#if 0	    
	  case VS_m_2dWCompute	:
	    /*
             * changes for TR179901434
             */
	    printf("VSbooPlate.ACconstruct_feet VS_m_2dWCompute\n");
	    
	    sts = om$send( msg	= message VSbooPlate.VSconstruct_2D_rep(
	                                  msg,
	                                  nbNotches,
	                                  notchList,
	                                  &parentOutput,
	                                  &cst,
	                                  &result ),
			   targetid= my_id ) ;
	    /* continue the process- minimum 2D rep is that of the parent feet
	     *__CheckRC( sts, *msg, "VSbooPlate.VSconstruct_2D_rep", wrapup ) ;
	     * always return success so that my parent output graphics will be 
	     * my rep(feet) if i fail to construct my 2D rep
	     */ 
	    if(!(sts&*msg&1)) compute2DFlag = TRUE;
	    
	    sts = OM_S_SUCCESS ;*msg =MSSUCC;
	    
	    break ;
#endif
#if 0	    
	  case AC_2D_REP		: /* No computation */
	    result = parentOutput._grid ;
	    break ;
#endif
	}

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
	*countOfOutputs	 = 1 ;
	listOfOutputs[0] = result ;
	
	wrapup :	
	  
	  if( myOperand.obj_id.objid != NULL_OBJID )
	  {
	    vs$bulk_delete( count   = 1,
			    objenvs = &myOperand ) ;
	  }
	
	// Delete the gensolid always - TR179901413
	if(!compute2DFlag) // parent output may be my graphics
	  vs$bulk_delete( count	= 1,
	         	  objenvs= &parentOutput ) ;
	
	/*
	 * Delete created cutting cylinders, if any.
	 */
	for( i = 0 ; i < MAX ; i++ ) {
	  if( cylsToDel[i] ) vs$bulk_delete( objenvs = notchList + i ) ;
	}
	if( !( sts & 1 & *msg ) ) {
	  /*
	   * Post-failure restore !
	   */
	  
	  /*
	   * Placement : failure. Compute : degraded state.
	   */
	  if( purpose & VS_K_InitialPlacement ) {
	    if( consumed ) {
	      long rc ;
	      vs$unconsume(	msg	= &rc,
				object	= &operand._grid,
				mod_env	= &operand.mod_env,
				rep	= oldRep,
				compute	= TRUE ) ;
	    }
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
	
	if( bfCount ) _FREE( bfList ) ;
	
	End
	  return sts ;
	
} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSbooPlate ;
