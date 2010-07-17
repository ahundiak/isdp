/* $Id: VLGetWebPrji.I,v 1.7 2002/06/07 21:44:15 ramarao Exp $  */
/***************************************************************************
 * I/LOFT
 *
 * File: src/mrkLine/VLGetWebProji.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLGetWebPrji.I,v $
 *      Revision 1.7  2002/06/07 21:44:15  ramarao
 *      Freed the Surface using FREESF().
 *
 *      Revision 1.6  2001/07/16 22:02:12  jayadev
 *      extend stiffener surface in both [u,v] directions
 *
 *      Revision 1.5  2001/02/27 17:28:55  jayadev
 *      junk graphics lying around
 *
 *      Revision 1.4  2001/02/23 16:00:37  jayadev
 *      changes for etl#6185 and etl#5310
 *
 *      Revision 1.3  2001/02/20 01:04:50  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:56:16  ramarao
 *      *** empty log message ***
 *
# Revision 1.6  2000/10/16  17:29:38  pinnacle
# ah
#
# Revision 1.5  2000/09/28  18:05:28  pinnacle
# Replaced: loft/src/mrkLine/VLGetWebPrji.I for:  by jpulapar for Service Pack
#
# Revision 1.4  2000/07/10  21:11:26  pinnacle
# Replaced: loft/src/mrkLine/VLGetWebPrji.I for:  by rchennup for Service Pack
#
# Revision 1.3  2000/07/03  15:17:34  pinnacle
# Replaced: loft/src/mrkLine/VLGetWebPrji.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/05/23  15:37:46  pinnacle
# Replaced: loft/src/mrkLine/VLGetWebPrji.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/13  21:14:04  pinnacle
# Created: loft/src/mrkLine/VLGetWebPrji.I by rchennup for Service Pack
#
# Revision 1.5  2000/04/03  21:06:00  pinnacle
# Replaced VLGetWebPrji.I by jpulapar
#
# Revision 1.4  2000/03/24  17:54:18  pinnacle
# ah
#
# Revision 1.3  2000/03/17  16:45:36  pinnacle
# Replaced VLGetWebPrji.I by jpulapar
#
# Revision 1.2  2000/02/24  22:45:06  pinnacle
# Replaced VLGetWebPrji.I for TR179901034 by jpulapar
#
# Revision 1.1  2000/01/04  08:15:36  pinnacle
# New file for Automarking with leftWeb of Stiffener
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      09/02/99  Jayadev TR179900777 - Left web of the stiffener 
*                                      will be taken for automarking
*      02/24/00  Jayadev Modifications for TR179901034
*      03/15/00  Jayadev changed extension of webSurfaces 
*			 to avoid unwanted markings for TR179901226
*      03/15/00  Jayadev changes made for TR179901217 
*      03/24/00  ah      Removed VDgeom2.h
*      04/03/00  Jayadev Made changes for marking problems of unit 2131
*      05/23/00  Jayadev copy the plate surface for processing and cleanup
*      09/28/00  Jayadev fix for TR179901823 - nest macro parent plate surface
*      10/16/00  ah      Added env to VDdrawCurve
*      02/23/01  Jayadev unidirection extension of stiffener surface
*			 uv_extent_surface_geom() 
***************************************************************************/

class implementation VLmrkLine;

#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "asmacros.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "v_geommacros.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vsoptdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbeam.h"
#include "vsbeammacros.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "bsparameters.h"

#include "vldbgmacros.h"
#include "vlmark.h"

#define U_EXTEND 0
#define V_EXTEND 1 
#define MAX_ITER 3

extern IGRint uv_extent_surface_geom();
extern void BSsfeval();
extern void BSmdistptsf();

extern OMuword OPP_EMSsubbs_class_id;

//#define DEBUG 1

from VSbeam import VSgetSegmentEnds ;
from VSbeam import VSgetSupportAxis;
from  VSfeature import  VSforwardToSource ;

/* 
 * The idea is to get all the facenames of the beam (stiffener) and get the
 * right and the left webs of the beam. Get the minimum distance of each of 
 * these web surfaces from the plate surface to be marked  and 3.0 times that 
 * distance will be used for extending the web surfaces for generating the 
 * intersections with the plate surface. Now these intersections will be trimmed
 * to the stiffener ends to give the marking lines   
 */

IGRint VLGetWebProj(
                    struct GRobj_env      * stiffObj ,	//I: stiffener 
                    struct GRobj_env      * plateObj,       //I: plate 
		    struct GRmd_env       * md_env,		//I: active mod env
		    struct GRvg_construct * vg_cnst,    //I: constrn list
		    IGRint                  TypeSide,   //I: plate side to mark
		    struct GRid	          * Isocs ,	//O: the list of isos
		    IGRint		  * NumIsocs  	//0: numb of iso curves
		    )
  
{
  struct GRobj_env	leftWebOE,rightWebOE,plateSrfOE;
  struct GRobj_env      cp_obj,ParSidePtr,axis,markOE,resOE,surfOE;
  int                   ii,iii,kk,sts1,sts2,num_dists,numInters = 0;
  IGRlong	        msg	  = MSFAIL,sts,loc_msg,sts3;
  IGRint		retFlag	  = 0,count = 0,stat = OM_E_INVARG,nb_iter;	
  char                  **faceNames ,sideName[20];
  long                  *faceDescrs ,lsts = MSFAIL ;
  struct GRid           *leftMarks,*rightMarks,resID,leftMrkID,rightMrkID;
  struct GRid           markLeft, markRight;
  struct IGRbsp_curve   *leftTrmMrk=NULL,*rightTrmMrk=NULL; 
  struct GRlc_info      surfInfo, webInfo ; 
  struct GRid           deleteList[VLMrkNumFeet];
  struct IGRbsp_surface *leftWebBsp,*rightWebBsp,*plateSrfBsp;
  struct IGRbsp_surface *extSurf = NULL;
  BSrc                  rc;
  IGRdouble             *paruv1 = NULL,*paruv2 = NULL,dist[10],pars[2];
  IGRdouble             u_extension,v_extension;
  IGRpoint              *sfpt1 = NULL, *sfpt2 = NULL,endpt[2],axisendpt[2];
  VSpartAttr            PltAttr ;
  VSplateAttr           PltInfo ;  
  double                bastol = 0.0,chtol = 0.0,dot_prod = 0.0;
  double                save_chtol = 0.0;
  IGRboolean            failFlag = FALSE,axis_linear = TRUE,extDir;
  IGRboolean            mark_linear = TRUE,trimFlag = TRUE;
  struct IGRbsp_curve   *axisBsp= NULL,*markCrvBsp= NULL,*PartialCrv = NULL;
  IGRvector             axis_vector,curve_vector;
  IGRchar               debugfile[50];

  SetProc ( VLGetWebProj ); Begin
			      
  // argument check
  if ( !stiffObj || !md_env  || !plateObj  || ! Isocs  ) goto wrapup ;
  
  // init
  leftWebBsp = rightWebBsp = plateSrfBsp = NULL;
  leftMarks  = rightMarks  = NULL;
  leftWebOE.obj_id.objid   = NULL_OBJID;
  rightWebOE.obj_id.objid  = NULL_OBJID;
  plateSrfOE.obj_id.objid  = NULL_OBJID;
  markLeft.objid = markRight.objid = NULL_OBJID;
  u_extension = v_extension = 0.0;
  pars[0] = 0.0;
  pars[1] = 1.0;
  
  *NumIsocs = 2;
  
  BSxtractpar( &rc, BSTOLBASIS, &bastol );
  BSxtractpar( &rc, BSTOLCHRDHT, &chtol );
  
  save_chtol = chtol;
  
  __DBGpr_dbl("chtol ",chtol);
  __DBGpr_dbl("bastol ",bastol);
  if(TypeSide)
  {
    strcpy(sideName,"plate:offset");
  }
  else
  {
    strcpy(sideName,"plate:base");
  }
  
  // get the end points of the beam
  sts = om$send(  msg     = message VSbeam.VSgetSegmentEnds(
                                    &msg, &(stiffObj->mod_env), axisendpt),
		  senderid= NULL_OBJID,
		  targetid= stiffObj->obj_id.objid,
		  targetos= stiffObj->obj_id.osnum ) ;
  __CheckRC( sts, msg, "VSbeam.VSgetSegmentEnds", wrapup ) ;
  
  for(ii=0;ii<3;ii++) axis_vector[ii] = axisendpt[1][ii] - axisendpt[0][ii]; 
  BSnorvec(&rc,axis_vector); 
  if ( rc != BSSUCC ) goto wrapup;
  
  sts = vs$listBeamFaces(       msg     = &msg,
				beam    = &(stiffObj->obj_id),
				count   = &count,
				names   = &faceNames,
				descrs  = &faceDescrs ) ;
  __CheckRC( sts, msg, "vs$listBeamFaces", wrapup ) ;
  for(ii=0;ii<count;ii++)
  {
    if(!(strcmp(faceNames[ii],"beam:body:web_____r")))
    {
      vdobj$GetFoot(objOE = stiffObj, footName = faceNames[ii], footOE = &rightWebOE);
      if(rightWebOE.obj_id.objid == NULL_OBJID) goto wrapup;
      
      vdgeom$Get2(objOE = &rightWebOE, srf = &rightWebBsp);
      if (rightWebBsp == NULL) goto wrapup;
    }
    if(!(strcmp(faceNames[ii],"beam:body:web_____l")))
    {
      vdobj$GetFoot(objOE = stiffObj, footName = faceNames[ii], footOE = &leftWebOE);
      if(leftWebOE.obj_id.objid == NULL_OBJID) goto wrapup;
      
      vdgeom$Get2(objOE = &leftWebOE, srf = &leftWebBsp);
      if (leftWebBsp == NULL) goto wrapup;
    }
  }
 
  sts = om$send( msg = message VSfeature.VSforwardToSource ( &lsts ,
	                                                     OM_e_wrt_object ,
		       message NDmacro.ACreturn_foot(&msg,sideName,&(ParSidePtr.obj_id), 
                               &(ParSidePtr._matrix_type),ParSidePtr._matrix )),
                                       senderid = NULL_OBJID,
                                       targetid = plateObj->obj_id.objid,
                                       targetos = plateObj->obj_id.osnum ) ;
  
  __CheckRC( lsts, 1, "Mark: forward to source of plate", wrapup ) ;
  __CheckRC( sts, msg, "Mark: surface of 2nd plate ", wrapup ) ;
  ParSidePtr._md_os = ParSidePtr._osnum;
  sts = ex$get_modid( mod_osnum = ParSidePtr._md_os,
		      mod_id    = &ParSidePtr._md_id );
  // Get the actual graphics object
  VSget_actual_go( &ParSidePtr.obj_id, &ParSidePtr.mod_env,
                   &ParSidePtr.obj_id, &ParSidePtr.mod_env );
  
  /* always safe to work on the copy of the parent */
  
  sts = om$send(msg = message GRgraphics.GRcopy(
                                             &loc_msg,
                                             &ParSidePtr.mod_env,
                                             md_env,
                                             &cp_obj.obj_id.objid ),
                             senderid = NULL_OBJID,
                             targetid = ParSidePtr.obj_id.objid,
                             targetos = ParSidePtr.obj_id.osnum );
  cp_obj.obj_id.osnum = md_env->md_id.osnum;
  cp_obj.mod_env = *md_env; 
  
  vdgeom$Get2(objOE = &cp_obj, srf = &plateSrfBsp);
  if (plateSrfBsp == NULL) goto wrapup;
  
  //VDdumpSurface(NULL, plateSrfBsp, "platesurface"); 
  PltAttr.Iwant    = VS_m_Thickness;
  PltAttr.specific = (void *) &PltInfo ;
  
  sts = om$send(msg  = message GRvg.GRgetattr( &msg,
				    (char *) &PltAttr),
		senderid = NULL_OBJID,
		targetid = plateObj->obj_id.objid,
		targetos = plateObj->obj_id.osnum );
  if( ! (sts&msg&1)) goto wrapup;
  
  __DBGpr_dbl(" Plate thickness ",PltInfo.thickness);

  /* If the axis is linear and the raw marking (before trim) is perpendicular
   * to the axis and also linear, donot trim the marking 
   */
  sts = om$send( msg = message VSbeam.VSgetSupportAxis(
                                        &msg,
                                        &(stiffObj->mod_env),
                                        &axis ),
		 senderid = NULL_OBJID,
		 targetid = stiffObj->obj_id.objid,
		 targetos = stiffObj->obj_id.osnum  );
  __CheckRC( sts, msg, "VSbeam.VSgetSegmentEnds", wrapup ) ;
  
  vdgeom$Get2(objOE = &axis, crv = &axisBsp);
  if (axisBsp == NULL) goto wrapup;
  
  axis_linear = vd_$is_curve_linear( msg = &msg,
				     curveGeom = axisBsp);
#ifdef DEBUG
  if(axis_linear) printf("\n Axis of the stiffener is linear \n");
  strcpy(debugfile,"stfAxis.txt");
  sts3 = VDdumpCurve(NULL,axisBsp,debugfile);
  strcpy(debugfile,"plate_surface.txt");
  sts3 = VDdumpSurface(NULL,plateSrfBsp,debugfile);
  strcpy(debugfile,"leftWeb.txt");
  sts3 = VDdumpSurface(NULL,leftWebBsp,debugfile);
  strcpy(debugfile,"rightWeb.txt");
  sts3 = VDdumpSurface(NULL,rightWebBsp,debugfile);
#endif
  
  surfInfo.located_obj       =      cp_obj.obj_id;
  surfInfo.module_info       =      *md_env ;
  
  surfOE.obj_id		     = cp_obj.obj_id;
  surfOE.mod_env             = *md_env ;
  
  {
    double          extend = 0.0;
    IGRboolean      extDirKnown = FALSE;
    IGRboolean      extDirFail  = FALSE;
    paruv1 = paruv2 = NULL;
    sfpt1  = sfpt2  = NULL;
    num_dists       = 0;
    nb_iter         = 0;
    
  try_again1:
    
    extend += PltInfo.thickness;
    nb_iter ++;
    
    // extend and intersect the leftweb surf with the plate surf 
    webInfo.located_obj        =       leftWebOE.obj_id ;
    webInfo.module_info        =       leftWebOE.mod_env;
    
    // decide which direction to extend the stiffener surface : u or v
    
    if((!extDirKnown) && (!extDirFail))
    {
      sts2 = VSextendDir(plateSrfBsp,leftWebBsp,&extDir);
      if(!(sts2&1))
      {
	__DBGpr_com( "Attempt to determing extension direction failed" ) ;
	extDirKnown = FALSE;
	extDirFail  = TRUE;
      }
      else
      {
	extDirKnown = TRUE;
      }
    }
    extDirKnown = 0; 
    if(extDirKnown)
    {
      if(extDir == U_EXTEND)
      {
	__DBGpr_com(" U_EXTEND for leftWeb ");
	u_extension = extend;
	v_extension = 0.0;
      }
      else
      {
	__DBGpr_com(" V_EXTEND for leftWeb ");
	u_extension = 0.0;
	v_extension = extend;
      }
      
    }
    else
    {
      u_extension = v_extension = extend; // extend in both directions
      
    }
    __DBGpr_dbl(" u_extension for left web ",u_extension);
    __DBGpr_dbl(" v_extension for left web ",v_extension);
    
    sts2 = uv_extent_surface_geom(leftWebBsp,u_extension,v_extension, &extSurf);
    if(!(sts2&1) || (extSurf == NULL))
    {
      __DBGpr_com( "Attempt to extend left web surface failed" ) ;
      goto wrapup;
    }
    else{
      //VDdumpSurface(NULL,extSurf,"leftExt");
      resID.osnum =  vg_cnst->env_info->md_id.osnum;
      vg_cnst->geometry = (char*)extSurf ;
      
      // got the extend geom, build the surface
      resID.objid = NULL_OBJID;
      
      sts = om$construct(     classid = OPP_EMSsubbs_class_id ,
			      osnum   = resID.osnum  ,
			      p_objid = &resID.objid);
      if(resID.objid == NULL_OBJID)
      {
	__DBGpr_com( "construct of OPP_EMSsubbs_class_id failed" ) ;
	goto wrapup;
      }
      sts = om$send( msg  =     message GRgraphics.GRconstruct( vg_cnst ),
                     senderid = NULL_OBJID,
                     targetid = resID.objid,
                     targetos = resID.osnum  );
      __DBGpr_obj("resID ",resID);
      
      if(!(sts&1))
      {
	__DBGpr_com( "GRgraphics.GRconstruct of extSurf failed" ) ;
	goto wrapup;
      }
      
      webInfo.located_obj = resID;
      webInfo.module_info = *md_env;
    }
    
    resOE.obj_id = resID;
    resOE.mod_env= *md_env;

    sts2 = VScsInt2Elements(&msg,&resOE,&surfOE,md_env,&markLeft);
    if(!(sts2&msg&1) || (markLeft.objid == NULL_OBJID)){ 
      
      __DBGpr_com ("failed in VScsInt2Elements ");
      
      if(nb_iter < MAX_ITER)
      {
        vs$bulk_delete( count   = 1,
		        grids   = &resID,
		        theEnv  = md_env) ;
        goto try_again1;
      }
      else
      { 
	failFlag = TRUE;
	goto delete_marks;
      }
    }
    leftMarks = _MALLOC(1,struct GRid);
    __DBGpr_obj("markLeft ",markLeft); 
    leftMarks[0] = markLeft;
    
    VDahGetObjectEnv(&leftMarks[0],&markOE);
    if(markOE.obj_id.objid == NULL_OBJID)
    {
      vs$bulk_delete( count   = 1,
		      grids   = &leftMarks[0],
		      theEnv  = md_env) ;
      goto wrapup;
    }
    vdgeom$Get2(objOE = &markOE, crv = &markCrvBsp);
    if (markCrvBsp == NULL) 
    {
      vs$bulk_delete( count   = 1,
		      grids   = &markOE.obj_id,
		      theEnv  = md_env) ;
      goto wrapup;
    }
    BScvarrev0(&rc,markCrvBsp,&pars[0],1,endpt[0]);
    if ( rc != BSSUCC ) goto wrapup;
    BScvarrev0(&rc,markCrvBsp,&pars[1],1,endpt[1]);
    if ( rc != BSSUCC ) goto wrapup;
    
    mark_linear = vd_$is_curve_linear( msg = &msg,
				       curveGeom = markCrvBsp);
    
    if(mark_linear){__DBGpr_com (" The mark Curve is linear ");}
    
    for(ii=0;ii<3;ii++) curve_vector[ii] = endpt[1][ii] - endpt[0][ii]; 
    BSnorvec(&rc,curve_vector); 
    if ( rc != BSSUCC ) goto wrapup;
    dot_prod = BSdotp( &rc,axis_vector,curve_vector);
    if ( rc != BSSUCC ) goto wrapup;
    
    __DBGpr_dbl("dot_prod of [axis,mark]",dot_prod);
    
    // if axis_linear, mark_linear and dot_product is zero, donot trim
    if(axis_linear && mark_linear && (fabs(dot_prod) < bastol))
    {
      Isocs[0] = leftMarks[0];
      trimFlag = FALSE;
      goto delete_marks;
    }  
    sts2 = VLtrimMrkLine(markCrvBsp,axisendpt,&leftTrmMrk,PltInfo.thickness);
    if(!(sts2&1)) 
    {
      failFlag = TRUE;
      goto delete_marks;
    } 	
    /* 16 Oct 2000 - Added env */
    VDdrawCurve(leftTrmMrk,md_env,&leftMrkID);
    
    if(leftMrkID.objid == NULL_OBJID) 
    {
      failFlag = TRUE;
      goto delete_marks;
    } 
    
    if (leftTrmMrk != NULL) {
      _FREE(leftTrmMrk);
      leftTrmMrk = NULL;
    } 
    Isocs[0] = leftMrkID;
    
  delete_marks:
    iii = 0;
    if(!trimFlag) kk = 1;
    else kk = 0;
    for ( ii=kk; ii<numInters ; ++ii,++iii){
      if (leftMarks[ii].objid != NULL_OBJID ) {
	deleteList[iii].objid = leftMarks[ii].objid;
	deleteList[iii].osnum = leftMarks[ii].osnum;
      }
    }
    if(!trimFlag) numInters = numInters-1; // mark not trimmed
    vs$bulk_delete( count   = numInters,
		    grids   = deleteList,
		    theEnv  = md_env) ;
    // deleted the extended surface 
    vs$bulk_delete( count   = 1,
		    grids   = &resID,
		    theEnv  = &leftWebOE.mod_env) ;
    if(failFlag) goto wrapup;
  }
  
  {
    double          extend = 0.0;
    IGRboolean      extDirKnown = FALSE;
    IGRboolean      extDirFail  = FALSE;
    paruv1 = paruv2 = NULL;
    sfpt1  = sfpt2  = NULL;
    num_dists       = 0;
    numInters       = 0;
    nb_iter         = 0;
    trimFlag = TRUE;
    
  try_again2:
    
    extend += PltInfo.thickness;
    nb_iter ++;
    
    // extend and intersect the rightweb surf with the plate surf
    webInfo.located_obj        =       rightWebOE.obj_id ;
    webInfo.module_info        =       rightWebOE.mod_env;
    
    // decide which direction to extend the stiffener surface : u or v
    
    if((!extDirKnown) && (!extDirFail))
    {
      sts2 = VSextendDir(plateSrfBsp,rightWebBsp,&extDir);
      if(!(sts2&1))
      {
	__DBGpr_com( "Attempt to determing extension direction failed" ) ;
	extDirKnown = FALSE;
	extDirFail  = TRUE; 
      }
      else
      {
	extDirKnown = TRUE;
      }
    }
    
    extDirKnown = 0; 
    if(extDirKnown)
    {
      if(extDir == U_EXTEND)
      {
	__DBGpr_com(" U_EXTEND for rightWeb ");
	u_extension = extend;
	v_extension = 0.0;
      }
      else
      {
	__DBGpr_com(" V_EXTEND for rightWeb ");
	u_extension = 0.0;
	v_extension = extend;
      }      
    }
    else
    {
      u_extension = v_extension = extend; // extend in both directions      
    }
    
    _FREESF(&rc, extSurf); extSurf = NULL;
    
    __DBGpr_dbl(" u_extension for right web ",u_extension);
    __DBGpr_dbl(" v_extension for right web ",v_extension);
    
    sts2 = uv_extent_surface_geom(rightWebBsp,u_extension,v_extension, &extSurf);
    
    if(!(sts2&1) || (extSurf == NULL))
    {
      __DBGpr_com( "Attempt to extend right web surface failed" ) ;
      failFlag = TRUE;
      goto delete_marks1;
    }
    else{     
      //VDdumpSurface(NULL,extSurf,"rightExt");
      vg_cnst->geometry = NULL; 
      resID.osnum =  vg_cnst->env_info->md_id.osnum;
      vg_cnst->geometry = (char*)extSurf ;
      
      // got the extend geom, build the surface
      resID.objid = NULL_OBJID;
      
      sts = om$construct(     classid = OPP_EMSsubbs_class_id ,
			      osnum   = resID.osnum  ,
			      p_objid = &resID.objid);
      if(resID.objid == NULL_OBJID)
      {
	__DBGpr_com( "construct of OPP_EMSsubbs_class_id failed" ) ;
        failFlag = TRUE;
        goto delete_marks1;
      }
      sts = om$send( msg  =     message GRgraphics.GRconstruct( vg_cnst ),
                     senderid = NULL_OBJID,
                     targetid = resID.objid,
                     targetos = resID.osnum  );
      __DBGpr_obj("resID ",resID);
      
      if(!(sts&1))
      {
	__DBGpr_com( "GRgraphics.GRconstruct of extSurf failed" ) ;
	goto wrapup;
      }
      
      webInfo.located_obj = resID;
      webInfo.module_info = *md_env;
      
    }
    
    resOE.obj_id = resID;
    resOE.mod_env= *md_env;
    
    sts2 = VScsInt2Elements(&msg,&resOE,&surfOE,md_env,&markRight);
    if(!(sts2&msg&1) || (markRight.objid == NULL_OBJID)){
      if(nb_iter < MAX_ITER)
      {
        vs$bulk_delete( count   = 1,
		        grids   = &resID,
		        theEnv  = md_env) ;
        goto try_again2;
      }
      else
      { 
        __DBGpr_com ("failed in VScsInt2Elements ");
	failFlag = TRUE;
	goto delete_marks1;
      }
    } 
    markOE.obj_id.objid = NULL_OBJID;
    
    rightMarks = _MALLOC(1,struct GRid);
    __DBGpr_obj("markRight ",markRight); 
    rightMarks[0] = markRight;
    
    VDahGetObjectEnv(&rightMarks[0],&markOE);
    if(markOE.obj_id.objid == NULL_OBJID)
    {
      vs$bulk_delete( count   = 1,
		      grids   = &rightMarks[0],
		      theEnv  = md_env) ;
      goto wrapup;
    }
    _FREE(markCrvBsp);
    markCrvBsp = NULL; 
    vdgeom$Get2(objOE = &markOE, crv = &markCrvBsp);
    if (markCrvBsp == NULL)
    {
      vs$bulk_delete( count   = 1,
		      grids   = &markOE.obj_id,
		      theEnv  = md_env) ;
      goto wrapup;
    }
    
    BScvarrev0(&rc,markCrvBsp,&pars[0],1,endpt[0]);
    if ( rc != BSSUCC ) goto wrapup;
    BScvarrev0(&rc,markCrvBsp,&pars[1],1,endpt[1]);
    if ( rc != BSSUCC ) goto wrapup;
    
    mark_linear = vd_$is_curve_linear( msg = &msg,
				       curveGeom = markCrvBsp);

    __DBGpr_com(" The mark Curve linear");
    
    for(ii=0;ii<3;ii++) curve_vector[ii] = endpt[1][ii] - endpt[0][ii]; 
    BSnorvec(&rc,curve_vector); 
    if ( rc != BSSUCC ) goto wrapup;
    
    // if axis_linear, mark_linear and dot_product is zero, donot trim
    dot_prod = BSdotp( &rc,axis_vector,curve_vector);
    if ( rc != BSSUCC ) goto wrapup;
    
    __DBGpr_dbl("\n dot_prod of [axis,mark] ",dot_prod);
    
    // if axis_linear, mark_linear and dot_product is zero, donot trim
    if(axis_linear && mark_linear && (fabs(dot_prod) < bastol))
    {
      Isocs[1] = rightMarks[0];
      trimFlag = FALSE;
      goto delete_marks1;
    }  
    
    sts2 = VLtrimMrkLine(markCrvBsp,axisendpt,&rightTrmMrk,PltInfo.thickness);
    if(!(sts2&1))
    {
      failFlag = TRUE;
      goto delete_marks1;
    } 
    /* 16 Oct 2000 - Added env */
    VDdrawCurve(rightTrmMrk,md_env,&rightMrkID);
    
    if(rightMrkID.objid == NULL_OBJID)
    {
      failFlag = TRUE;
      goto delete_marks1;
    }
    
    if (rightTrmMrk != NULL) {
      _FREE(rightTrmMrk);
      rightTrmMrk = NULL;
    }
    Isocs[1] = rightMrkID;
  delete_marks1:
    
    if(failFlag){ // delete the leftMark which already exists
      if(leftMrkID.objid!=NULL_OBJID) {
	vs$bulk_delete( count   = 1,
			grids   = &leftMrkID,
			theEnv  = md_env) ; }
    }
    if(numInters>=1){
      iii = 0;
      if(!trimFlag) kk = 1;
      else kk = 0;
      for ( ii=kk; ii<numInters ; ++ii,++iii){
	if (rightMarks[ii].objid != NULL_OBJID ) {
	  deleteList[iii].objid = rightMarks[ii].objid;
	  deleteList[iii].osnum = rightMarks[ii].osnum;
	}
      }
    }
    if(numInters>=1){
      if(!trimFlag) numInters = numInters-1; // mark not trimmed
      vs$bulk_delete( count   = numInters,
		      grids   = deleteList,
		      theEnv  = md_env) ;
    }
    // deleted the extended surface
    if(resID.objid != NULL_OBJID) 
      vs$bulk_delete( count   = 1,
		      grids   = &resID,
		      theEnv  = &rightWebOE.mod_env) ;
    if(failFlag) goto wrapup;
  }
  
  retFlag = 1;
  
 wrapup:
  End
    
    // free the memory
    // delete the copy of the parent surface
    vs$bulk_delete( count   = 1,
                    grids   = &cp_obj.obj_id,
                    theEnv  = md_env) ;
  
  _FREE(markCrvBsp); markCrvBsp = NULL;
  
  _FREE(leftWebBsp); leftWebBsp = NULL;
  
  _FREE(rightWebBsp); rightWebBsp = NULL;
  
  _FREE(plateSrfBsp); plateSrfBsp = NULL;

  _FREESF(&rc, extSurf); extSurf = NULL;
  
  _FREE(leftTrmMrk); leftTrmMrk = NULL;
  
  _FREE(rightTrmMrk); rightTrmMrk = NULL;
  
  if(faceNames)
  {
    for(ii=0;ii<count;ii++)
    {
      _FREE(faceNames[ii]);
      faceNames[ii] = NULL;
    }
    _FREE(faceNames); faceNames = NULL;
  }
  
  _FREE(faceDescrs); faceDescrs = NULL;
  
  _FREE(leftMarks); leftMarks = NULL;
  
  _FREE(rightMarks); rightMarks = NULL;
  
  _FREE(paruv1); paruv1 = NULL;
  
  _FREE(paruv2); paruv2 = NULL; 
  
  _FREE(sfpt1); sfpt1 = NULL;
  
  _FREE(sfpt2); sfpt2 = NULL;
  
  return retFlag;
  
}

IGRint VLtrimMrkLine(struct IGRbsp_curve *markCrvBsp,IGRpoint endPoints[],struct IGRbsp_curve **trimmedMark,IGRdouble plt_thk)
{
  IGRint                i,retFlag  = 0;
  BSrc                  rc;
  struct IGRbsp_curve   *PartialCrv = NULL;
  IGRpoint              minDistpt[2];
  IGRdouble             minDistpm[2],min_dist = 0.0;
  IGRdouble             par_dir;
  double                bastol = 0.0,chtol = 0.0;
  double                arclen = 0.0,pars[2];
 
  BSxtractpar( &rc, BSTOLBASIS, &bastol );
  BSxtractpar( &rc, BSTOLCHRDHT, &chtol );
 
  
  for(i=0;i<2;i++)
  {
    BSmdstptcv(markCrvBsp,endPoints[i],&minDistpm[i],minDistpt[i],&min_dist,&rc);
    if ( rc != BSSUCC ) goto wrapup;
  }
  BSalloccv ( markCrvBsp->order, markCrvBsp->num_poles, markCrvBsp->rational,markCrvBsp->num_boundaries, &PartialCrv, &rc);
  if ( rc != BSSUCC ) goto wrapup;
  
  par_dir = 2.0/3.0 * minDistpm[0] + 1.0/3.0 * minDistpm[1];
  
  BSpartofcv ( &rc, markCrvBsp, minDistpm[0], par_dir, minDistpm[1], PartialCrv);
  if ( rc != BSSUCC ) goto wrapup;
  
  
  if ( (minDistpm[1] - minDistpm[0]) < 0.0 ) {
    BSrev_cv( &rc, PartialCrv );
    if ( rc != BSSUCC ) goto wrapup;
  }
  
  // check the length of the partial curve - TR179901034
  pars[0] = 0.0;
  pars[1] = 1.0;
  BSarclength(&rc,PartialCrv,&pars[0],&pars[1],&arclen);
  if ( rc != BSSUCC ) goto wrapup;
#ifdef DEBUG
  printf("\n Arclength of the trimmed mark : %g \n",arclen);
#endif
  if(arclen<(2*plt_thk)) goto wrapup; //for TR179901226

  *trimmedMark = PartialCrv; 
  retFlag = 1;
wrapup:
  return retFlag;
}


/* This function has been introduced to get the plate side information i.e., 
 * the side of the plate on which the stiffener lies. If the function fails at
 * any stage, it returns 0, hence defaulting to the base surface of plate 
 */

IGRint VLgetPlateSide(
		      struct GRobj_env  *	stiffObj,	//I: stiffener 
		      struct GRid       * plateID         //I: plate 
		      )
  
{
  struct GRobj_env      baseSrfOE,offsetSrfOE,plateObj;
  int                   ii;
  IGRlong	        msg	  = MSFAIL; 
  IGRlong               sts;
  IGRint		retFlag	  = 0;
  struct IGRbsp_surface *baseSrfBsp,*offsetSrfBsp;
  struct IGRbsp_curve   *axisBsp;
  BSrc                  rc;
  double                dist_base,dist_offset,pars[1];
  IGRpoint              endpt[2],mid_pt;       /* points of beam   */
  struct GRobj_env      axis;
  
  SetProc ( VLgetPlateSide ); Begin
				
  // argument check
  if ( !stiffObj || !plateID ) goto wrapup ;
  
  // init
  axisBsp     = NULL;
  baseSrfBsp  = offsetSrfBsp = NULL;
  baseSrfOE.obj_id.objid  = NULL_OBJID;
  offsetSrfOE.obj_id.objid  = NULL_OBJID;
  plateObj.obj_id.objid = NULL_OBJID;
  
  // get the base or offset surface geom of the plate
  VDahGetObjectEnv(plateID,&plateObj);
  if(plateObj.obj_id.objid == NULL_OBJID) goto wrapup;
  
  vdobj$GetFoot(objOE = &plateObj, footName = VS_K_plTopSfPath, footOE = &offsetSrfOE);
  if(offsetSrfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  vdobj$GetFoot(objOE = &plateObj, footName = VS_K_plBotSfPath, footOE = &baseSrfOE);
  if(baseSrfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  vdgeom$Get2(objOE = &baseSrfOE, srf = &baseSrfBsp);
  if (baseSrfBsp == NULL) goto wrapup;
  vdgeom$Get2(objOE = &offsetSrfOE, srf = &offsetSrfBsp);
  if (offsetSrfBsp == NULL) goto wrapup;
 
/* 
  sts = om$send(  msg     = message VSbeam.VSgetSegmentEnds(
							    &msg, &(stiffObj->mod_env), endpt),
                  senderid= NULL_OBJID,
                  targetid= stiffObj->obj_id.objid,
                  targetos= stiffObj->obj_id.osnum ) ;
  __CheckRC( sts, msg, "VSbeam.VSgetSegmentEnds", wrapup ) ;
  for(ii=0;ii<3;ii++)
    mid_pt[ii] = (endpt[0][ii]+endpt[1][ii])/2.0;
*/

// Get the mid_point of the curve
   sts = om$send( msg = message VSbeam.VSgetSupportAxis(
                                        &msg,
                                        &(stiffObj->mod_env),
                                        &axis ),
                        senderid = NULL_OBJID,
                        targetid = stiffObj->obj_id.objid,
                        targetos = stiffObj->obj_id.osnum  );
  __CheckRC( sts, msg, "VSbeam.VSgetSegmentEnds", wrapup ) ;
 
  vdgeom$Get2(objOE = &axis, crv = &axisBsp);
  if (axisBsp == NULL) goto wrapup;

  pars[0] = 0.5;
  BScvarrev0(&rc,axisBsp,pars,1,mid_pt);
  if ( rc != BSSUCC ) goto wrapup;
  
  {
    IGRdouble base[3];
    IGRdouble u, v ;
    dist_base = dist_offset = 0.0;
    BSmdistptsf(&rc, baseSrfBsp,mid_pt, &u,&v,base,&dist_base);
    if ( rc != BSSUCC ) goto wrapup;
    BSmdistptsf(&rc,offsetSrfBsp,mid_pt, &u,&v,base,&dist_offset);
    if ( rc != BSSUCC ) goto wrapup;
    
    if(dist_base<dist_offset) retFlag = 0;
    else retFlag = 1;    
  }
wrapup:
  End
    
    // free the memory
    if(baseSrfBsp)
    {
      _FREE(baseSrfBsp);
      baseSrfBsp = NULL;
    }
    if(axisBsp)
    {
      _FREE(axisBsp);
      axisBsp = NULL;
    }
  if(offsetSrfBsp)
  {
    _FREE(offsetSrfBsp);
    offsetSrfBsp = NULL;
  }
  
  return retFlag;
  
}
IGRint VSextendDir(struct IGRbsp_surface *plateSrfBsp,
		   struct IGRbsp_surface *leftWebBsp,
		   IGRint                *extDir)
{

  IGRint    retFlag = 0,index,i;
  IGRpoint  points[4],ptOnSf[4];
  IGRdouble dist[4],u,v,mdist[4],min_dist;
  BSrc      rc;

  if((plateSrfBsp == NULL) || (leftWebBsp == NULL)) goto wrapup; 

  // point at (u,v) = [0.0,0.5]
  BSsfeval(leftWebBsp,0.0,0.5,0,&points[0],&rc); 
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_vec("Point at [0.0,0.5] on stiff surface ",points[0]); 

  BSmdistptsf(&rc,plateSrfBsp,points[0],&u,&v,ptOnSf[0],&mdist[0]);
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_dbl("min_dist from plate surf ",mdist[0]); 
  if(mdist[0] == 0.0)
  {
    *extDir = U_EXTEND;
    retFlag = 1;
    goto wrapup;
  }

  // point at (u,v) = [1.0,0.5]
  BSsfeval(leftWebBsp,1.0,0.5,0,&points[1],&rc);  
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_vec("Point at [1.0,0.5] ",points[1]); 

  BSmdistptsf(&rc,plateSrfBsp,points[1],&u,&v,ptOnSf[1],&mdist[1]);
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_dbl("min_dist from plate surf ",mdist[1]); 

  if(mdist[1] == 0.0)
  {
    *extDir = U_EXTEND;
    retFlag = 1;
    goto wrapup;
  }

  // point at (u,v) = [0.5,0.0]
  BSsfeval(leftWebBsp,0.5,0.0,0,&points[2],&rc);  
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_vec("Point at [0.5,0.0] ",points[2]); 

  BSmdistptsf(&rc,plateSrfBsp,points[2],&u,&v,ptOnSf[2],&mdist[2]);
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_dbl("min_dist from plate surf ",mdist[2]); 

  if(mdist[2] == 0.0)
  {
    *extDir = V_EXTEND;
    retFlag = 1;
    goto wrapup;
  }
  // point at (u,v) = [0.5,1.0]
  BSsfeval(leftWebBsp,0.5,1.0,0,&points[3],&rc);  
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_vec("Point at [0.5,1.0] ",points[3]); 

  BSmdistptsf(&rc,plateSrfBsp,points[3],&u,&v,ptOnSf[3],&mdist[3]);
  if(rc != BSSUCC) goto wrapup;
  __DBGpr_dbl("min_dist from plate surf ",mdist[3]);
  if(mdist[3] == 0.0)
  {
    *extDir = V_EXTEND;
    retFlag = 1;
    goto wrapup;
  }

  min_dist = mdist[0];
  index    = 0;

  for(i=1;i<4; i++)
  {
    if(mdist[i] < min_dist)
    {
        min_dist = mdist[i];
	index = i;
    }
  }
  __DBGpr_int (" index ",index);
  if((index == 0) || (index == 1)) *extDir = U_EXTEND;
  else		                   *extDir = V_EXTEND;
 
  __DBGpr_int (" extDir ",*extDir);
  retFlag = 1;
wrapup:
return retFlag;
}
end implementation VLmrkLine  ;

