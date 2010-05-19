/* $Id: VDefpEdge.I,v 1.8 2002/05/06 14:51:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpEdge.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpEdge.I,v $
 *      Revision 1.8  2002/05/06 14:51:46  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/07/08 16:34:21  ramarao
 *      Used old as well as new NeatPlate Algorithms.
 *
 *      Revision 1.6  2001/06/22 18:21:17  ramarao
 *      Removed the previous fix.
 *
 *      Revision 1.5  2001/06/16 17:27:35  ramarao
 *      Fixed TR# 5288.
 *
 *      Revision 1.4  2001/03/03 21:26:26  ramarao
 *      Handled Neat Plate Recompute Process. Added a dummy function.
 *
 *      Revision 1.3  2001/03/03 19:19:06  ramarao
 *      Added a function to update neat plates.
 *
 *      Revision 1.2  2001/01/11 19:04:49  art
 *      sp merge
 *
# Revision 1.4  2000/10/16  17:21:46  pinnacle
# ah
#
# Revision 1.3  2000/04/25  17:35:22  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:13:32  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:15:46  pinnacle
# ah
#
# Revision 1.11  2000/03/28  17:18:08  pinnacle
# ah
#
# Revision 1.10  2000/03/27  21:27:02  pinnacle
# ah
#
# Revision 1.9  2000/03/24  17:19:42  pinnacle
# ah
#
# Revision 1.8  2000/03/13  16:09:32  pinnacle
# Replaced VDefpEdge.I by jpulapar
#
# Revision 1.7  2000/03/10  22:55:00  pinnacle
# Replaced VDefpEdge.I by jpulapar
#
# Revision 1.6  2000/02/25  13:42:32  pinnacle
# tr179901141
#
# Revision 1.3  1999/10/26  19:20:46  pinnacle
# ah
#
# Revision 1.2  1999/05/24  18:13:42  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/24/00  ah      Added header
 * 02/24/00  ah      TR179901141 5 Sided plates are bowed, direct fit problem
 * 03/10/00  Jayadev changed VDefpGetSurfaceEdgeBsps(); calling
 *		     VDefpProcLineString() to process the linestring edges 
 * 04/11/00  ah      TR179901283 Warning
 * 05/06/02  ah      TR5463 neat_plate failing using new algo
 ***************************************************************************/
/* ------------------------------------
 * Surface Edge Processing
 *
 * 19 July 1999 Aded direct fit for surface edges
 * 12 Jan  2000 Skip internal holes in the surface
 * for production work
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"
#include "v_dbgmacros.h"
#include "VDdbgProto.h"

#include "EMSopt.h"
#include "EMSlcdef.h"
#include "ndmacros.h"
#include "grdpbmacros.h"
#include "acdef.h"
#include "acmacros.h"

#include "asmacros.h"
#include "macro.h"
#include "bssfevaln.h"
#include "bsdirfitcv.h"
#include "bsalloccv.h"
#include "bsdistptpt.h"

from EMSsurface   import EMmk_nat_bdry;
from EMSsurface   import EMgetedges;
from EMSsubbs     import EMget_edges;
from EMSedge      import EMgetxyzobj;
from NDnode       import ASreturn_go, NDchange_connect;
from NDmacro      import ACtest_consumed;
from ACrg_collect import ACset_list_attribute;

from ci_macro     import init;

from GRvg         import GRchgdp;
from GRvg         import GRchglevel;
from GRvg         import GRgetsymb;
from GRvg         import GRputsymb;
from GRvg         import GRcenter;
from GRvg         import GRgeomprops;

from GRgraphics   import GRchgname;
from GRgraphics   import GRputname;
from GRgraphics   import GRcopy;
from GRgraphics   import GRgetrang;
from ACncpx       import ACmplace, ACget_STATE, ACchg_STATE;
from GRconnector  import GRrigidconn;
from GRgraphics   import GRaltconstruct;

extern VDclassid OPP_nci_macro_class_id;
extern VDclassid OPP_ACrg_collect_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_ACpretend_class_id;

static IGRint traceFlag;
//#define DEBUG 1
/* -----------------------------------
 * Debug trace flag
 */
IGRstat VDefpEdgeGetTraceFlag()
{
  IGRstat retFlag = VDdbgGetTraceFlag(VDEFP_TRACE_COMPUTE_NEAT);
  return  retFlag;
}

/* ----------------------------------------------
 * The 3d coords of the 'center' of a surface
 * Based on range
 */
IGRstat VDefpGetSurfaceCenter(TGRobj_env *srfOE,
                              IGRdouble  *cenPT)
{
  IGRstat retFlag     = 0;
  IGRstat msg,sts;
  
  GRrange    range;
  IGRboolean world = TRUE;
  
  IGRint i;

  // Get the range
  memset(&range,0,sizeof(range));
  om$send(msg = message GRgraphics.
	  GRgetrang(&msg,
		    &srfOE->mod_env.md_env.matrix_type,
		     srfOE->mod_env.md_env.matrix,
		    &world,range),
	  senderid = NULL_OBJID,
	  targetid = srfOE->obj_id.objid,
	  targetos = srfOE->obj_id.osnum);

  // Use the mid point
  for(i = 0; i < 3; i++) {
    cenPT[i] = (range[i] + range[i+3]) * 0.5;
  }
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------
 * Compute function for the neat_edges
 * macros object
 */
IGRstar VDefpComputeNeatEdges(TGRobj_env *macOE,
                              IGRint      opFlag,
                              IGRint     *edgeCnt,
                              TGRid      *edgeIDs)
{
  IGRstat    retFlag = 0;
  IGRstat    sts;

  TGRobj_env parent1OE;
  
  TGRobj_env srfOE;
  TGRobj_env plateOE;

  IGRint     isPlate = 0, ACstate = 0, ACold_state = 0, ACmask = 0x1000,
	     old_algo=FALSE;

  IGRchar    plateSurfaceName[32];

  IGRchar    macObjType[128];
  IGRchar    macObjName[128];
  IGRchar    macObjDesc[128];
  IGRchar    buf[128];
  IGRint     i;

  IGRdouble  centerPT[3];
  TGRid      centerID;

  struct {
    IGRint cnt;
    IGRint max;
    TGRbsp_curve *bsps[VDEFP_NEAT_EDGES_MAX];
  } edge;

  IGRdouble tol;

  // Say hi
  traceFlag = VDefpEdgeGetTraceFlag();
  
  if (traceFlag) {
    printf(">>> Entering VDefpComputeNeatEdges\n");
    vdobj$Print(objOE = macOE);
  }
  vdobj$Get(objOE = macOE, objName = macObjName);
  sprintf(macObjDesc,"%d,%d %s",
          macOE->obj_id.osnum,
          macOE->obj_id.objid,
          macObjName);

  sprintf(buf,"Processing %s",macObjDesc);
  UI_status(buf);

  // Init
  *edgeCnt = 0;

  memset(&edge,0,sizeof(edge));
  edge.max = VDEFP_NEAT_EDGES_MAX;

  srfOE.obj_id.objid = NULL_OBJID;

  // Arg check
  if ((edgeCnt == NULL) || (edgeIDs == NULL)) goto wrapup2;

  // Get 1st parent, either the surface or a plate
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = 0,
                    templateOE = &parent1OE);

  if (parent1OE.obj_id.objid == NULL_OBJID) goto wrapup;

  sts = vdobj$IsAncestryValid(objOE          = &parent1OE, 
                              superClassName = "VSplate");

  if (!(sts & 1)) srfOE = parent1OE;
  else {

    isPlate = 1;
    plateOE = parent1OE;
    if (traceFlag) vdobj$Print(objOE = &plateOE);

    // Either base or offset based on macro name
    strcpy(plateSurfaceName,VDEFP_PLATE_BASE_SURF_NAME);

    vdobj$Get(objOE = macOE, macName = macObjType);
    
    if (!strcmp(macObjType,VDEFP_NEAT_PLATEO_MACRO_NAME)) {
      strcpy(plateSurfaceName,VDEFP_PLATE_OFFSET_SURF_NAME);
    }
    
    // Get the surface
    vdobj$GetFoot(objOE    = &plateOE, 
		  footName =  plateSurfaceName, 
		  footOE   = &srfOE);
  }
  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) vdobj$Print(objOE = &srfOE);

  /* -------------------------------------
   * Use 10 * basis tolerance
   * Actually, use chord height tolerance since basically want to know when a 
   * curve is straight or not
   */
  vdgeom$GetTolerance(cht = &tol);
  if (traceFlag) printf("Edge tolerance %.2f\n",tol);
  //tol *= 10.0;

  old_algo = FALSE;
  if( opFlag )
  {
      sts = om$send( msg      = message ACncpx.ACget_STATE( &ACstate ),
                     senderid = NULL_OBJID,
                     targetid = macOE->obj_id.objid,
                     targetos = macOE->obj_id.osnum  );
      if( ! ( ACstate & ACmask ) )   old_algo = TRUE;
  }

  if( old_algo )
  {
     // Get the edge geometry using Old Algorithm.
     sts = VDefpGetSurfaceEdgeBsps(&srfOE,edge.max,tol,&edge.cnt,edge.bsps);
     if (!(sts & 1)) goto wrapup;
  }
  else
  {
     sts = om$send( msg      = message ACncpx.ACchg_STATE( ACmask, ACmask ),
                    senderid = NULL_OBJID,
                    targetid = macOE->obj_id.objid,
                    targetos = macOE->obj_id.osnum  );

     // Get the edge geometry using new BSPmath Algorithm.
     sts = VDefpGetSurfaceEdgeBspsBS(&srfOE,edge.max,tol,&edge.cnt,edge.bsps);
     if (!(sts & 1)) {

       /* ---------------------------------------
        * 06 May 2002 - ah - TR5463 etl9491.cpio
        * In at least one (probably rare case) the new algo
        * was failing even though the old one worked.
        * So just retry with the old routine.
        */

       // printf("*** New routine failed\n");

       // Get the edge geometry using Old Algorithm.
       sts = VDefpGetSurfaceEdgeBsps(&srfOE,edge.max,tol,&edge.cnt,edge.bsps);
       if (!(sts & 1)) goto wrapup;
     }
  }

  // TR179901283 Warning
  if (sts == 3) {
    printf("*** The following plate may have invalid internal cutout geometry\n");
    if (isPlate) vdobj$Print(objOE = &plateOE);
    else         vdobj$Print(objOE = &srfOE);
  }
  
  // Center point is useful
  VDefpGetSurfaceCenter(&srfOE,centerPT);

  if (traceFlag ) {    
    printf("centerPT %.2f,%.2f,%.2f\n",
            centerPT[0],
	    centerPT[1],
	    centerPT[2]);
  }  
  VDdrawLinear(1,centerPT,&macOE->mod_env,&centerID);

  if (centerID.objid == NULL_OBJID) {
    printf("Problem making center point\n");
    goto wrapup;
  }
  edgeIDs[0] = centerID;
  *edgeCnt = 1;

  // Make objects
  for(i = 0; i < edge.cnt; i++ ) {

  //vdgeom$Print(crv = edge.bsps[i]);
    /* 15 Oc 2000 Add env */
    VDdrawCurve(edge.bsps[i],
		&macOE->mod_env,
		&edgeIDs[*edgeCnt]);

    if (edgeIDs[*edgeCnt].objid == NULL_OBJID) {
      printf("*** Problem creating edge object\n");
      if (edge.bsps[i] == NULL) printf("Edge is NULL\n");
      else                      printf("Edge Poles %d\n",edge.bsps[i]->num_knots);
      
      //vdgeom$Print(crv = edge.bsps[i]);
      
      //goto wrapup;
    }
    else *edgeCnt = *edgeCnt + 1;
  }

  // Check for lots of edges
  if (*edgeCnt > 80) {
    printf("--- Warning High Edge Count %2d For ---\n",*edgeCnt);
    vdobj$Print(objOE = &parent1OE);
  }
  
  // Done
  retFlag = 1;

wrapup:
  
  // Free up bsp geometry
  for(i = 0; i < edge.cnt; i++) {
    _FREE(edge.bsps[i]);
  }

  // delete any objects which may have been created
  if ((!(retFlag & 1)) && (*edgeCnt > 0)) {

    vdobj$Delete(objCNT = *edgeCnt,
                 objID  =  edgeIDs,
                 objENV = &srfOE.mod_env);

    *edgeCnt = 0;
  }

wrapup2:

  if (traceFlag) {
    if (!(retFlag & 1)) printf("FAILED!!!\n");
    printf("@@@ VDefpComputeNeatEdges, Edges %d\n",edge.cnt);
  }
  sprintf(buf,"Processed %s, Edge Cnt %d",macObjDesc,edge.cnt);
  UI_status(buf);

  return retFlag;
}

/* ------------------------------------
 * 29 Nov 1999 Clone the original compute
 * function and break out the surface edge code thus allowing
 * other macros such as ext_bound to access it
 *
 * 16 Oct 2000 Add env as input
 */
IGRstar VDefpGenerateNeatEdges(TGRobj_env *srfOE,
			       TGRmd_env  *edgeEnv, 
			       IGRint     *edgeCnt,
			       TGRid      *edgeIDs)
{
  IGRstat    retFlag = 0;
  IGRstat    sts;

  IGRint     i;

  struct {
    IGRint cnt;
    IGRint max;
    TGRbsp_curve *bsps[VDEFP_NEAT_EDGES_MAX];
  } edge;

  IGRdouble tol;

  // Say hi
  traceFlag = VDefpEdgeGetTraceFlag();
  
  if (traceFlag) {
    printf(">>> Entering VDefpGenerateNeatEdges\n");
    vdobj$Print(objOE = srfOE);
  }

  // Init
  memset(&edge,0,sizeof(edge));
  edge.max = VDEFP_NEAT_EDGES_MAX;

  // Arg check
  if ((edgeCnt == NULL) || (edgeIDs == NULL)) goto wrapup2;
  *edgeCnt = 0;

  /* -------------------------------------
   * Use 10 * basis tolerance
   * Actually, use chord height tolerance since basically want to know when a 
   * curve is straight or not
   */
  vdgeom$GetTolerance(cht = &tol);
  if (traceFlag) printf("Edge tolerance %.2f\n",tol);
  //tol *= 10.0;

  // Get the edge geometry
  sts = VDefpGetSurfaceEdgeBsps(srfOE,edge.max,tol,&edge.cnt,edge.bsps);
  if (!(sts & 1)) goto wrapup;

  // TR179901283 Warning
  if (sts == 3) {
    printf("*** The following surface may have invalid internal cutout geometry\n");
    vdobj$Print(objOE = srfOE);
  }
  
  // Make objects
  for(i = 0; i < edge.cnt; i++ ) {

    vdgeom$Print(crv = edge.bsps[i]);

    /* -------------------------------------------
     * 15 Oct 2000 Added env
     */
    VDdrawCurve(edge.bsps[i],edgeEnv,&edgeIDs[*edgeCnt]);

    if (edgeIDs[*edgeCnt].objid == NULL_OBJID) {
      printf("Problem creating edge object\n");
      goto wrapup;
    }
    *edgeCnt = *edgeCnt + 1;
  }

  // Done
  retFlag = 1;

wrapup:
  
  // Free up bsp geometry
  for(i = 0; i < edge.cnt; i++) {
    _FREE(edge.bsps[i]);
  }

  // delete any objects which may have been created
  if ((!(retFlag & 1)) && (*edgeCnt > 0)) {

    vdobj$Delete(objCNT = *edgeCnt,
                 objID  =  edgeIDs,
                 objENV = &srfOE->mod_env);

    *edgeCnt = 0;
  }

wrapup2:

  if (traceFlag) {
    if (!(retFlag & 1)) printf("FAILED!!!\n");
    printf("<<< VDefpGenerateNeatEdges, Edges %d\n",edge.cnt);
  }

  return retFlag;
}

IGRint VDupdateLocalNeatPlates()
{
  IGRint                retFlag = 0,j,count,cn_type;
  IGRlong               msg, sts, isConsumed ;
  IGRint                i, nb_class, loc_cnt,consmdCnt;
  IGRint                status;
  IGRchar		msg_str[1024],cr_flag[2];
  GRclassid	        classid[1];
  OM_S_OBJID            *loc_list;
  struct GRid           *consumedList, objectID;
  struct GRmd_env       cur_env;
  struct GRobj_env      footOE,parOE,*consumingChild;
  TVDvlaID              childVla;
  IGRchar               macName[128];
  
  cn_type       = ND_COMP;
  loc_cnt       = 0;
  consmdCnt     = 0;
  nb_class      = 1;
  loc_list      = NULL;
  consumedList  = NULL;
  sts           = MSSUCC;
  msg           = MSSUCC;
  
  // check if struct is loaded
  sts = om$get_classid(classname = "VSplate",
		       p_classid = &classid[0]);
  if(!(sts&1)) goto wrapup;
  
  gr$get_module_env( buffer = &cur_env );
  
  loc_cnt = 0;
  VDpms_findall_ancestryobjects( cur_env.md_id.osnum, nb_class, 
				 classid, &loc_cnt, NULL );
  if(loc_cnt == 0 ) goto wrapup;
  
  loc_list        = _MALLOC ( loc_cnt, OM_S_OBJID );
  consumedList    = _MALLOC ( loc_cnt, struct GRid );
  consumingChild  = _MALLOC ( loc_cnt, struct GRobj_env);
  
  VDpms_findall_ancestryobjects(  cur_env.md_id.osnum, nb_class,
				  classid, &loc_cnt, loc_list );
  
  for( i=0; i<loc_cnt; i=i++ )
  {
    consumedList[i].objid   = NULL_OBJID;
    consumedList[i].osnum   = 2;
    consumingChild[i].obj_id.objid = NULL_OBJID;
    consumingChild[i].obj_id.osnum = 2;
  }
  __DBGpr_int(" No. of plates ",loc_cnt);
  
  for( i=0; i<loc_cnt; i=i++ )
  {
    isConsumed = 0;
    
    sts = om$send( msg      = message NDmacro.ACtest_consumed( &isConsumed ),
		   senderid = NULL_OBJID,
		   targetid = loc_list[i],
		   targetos = cur_env.md_id.osnum );
    if(isConsumed)
    {
      consumedList[consmdCnt].objid = loc_list[i];
      consumedList[consmdCnt].osnum = cur_env.md_id.osnum;
      consmdCnt                     = consmdCnt + 1;
      
    }
  }
  if(consmdCnt == 0) goto wrapup;
  __DBGpr_int("No. of consumed plates ",consmdCnt);
  
  for(i = 0; i<consmdCnt; i++)
  {
    parOE.obj_id = consumedList[i];
    parOE.mod_env= cur_env;
    
    VDatGetConsumingChild( &parOE, &consumingChild[i]);
    if(consumingChild[i].obj_id.objid == NULL_OBJID)
    { 
      __DBGpr_obj("VDatGetConsumingChild failed for ",parOE.obj_id);
    }
    else 
    {
      __DBGpr_obj("Consumed parent ",parOE.obj_id);
      __DBGpr_obj("Consuming child ",consumingChild[i].obj_id);
    }    
  }
  // try to find the neat_plates from the consumed parent list
  // and connect them to the consuming child
  for(i=0; i<consmdCnt; i++)
  {
    __DBGpr_obj("***prints for consumed plate******",consumedList[i]);
    vdvla_id$Construct(vla = &childVla);
    vdchn$GetChildrenByClass(objID     = &consumedList[i],
			     classID   = OPP_nci_macro_class_id,
                             vla       = &childVla);
    count = 0;
    
    count = vdvla_id$GetCnt (vla = &childVla);
    if(count == 0) continue;
    
    __DBGpr_obj("consumed plate ",consumedList[i]);
    __DBGpr_int(" No. of nci_macros connected to plate ",count);    
    for(j=0; j<count; j++)
    {  
      objectID.objid = NULL_OBJID;
      
      vdvla_id$GetAt(vla = &childVla ,nth = j,objID = &objectID);
      if(objectID.objid == NULL_OBJID) continue;
      
      vdobj$Get(objID   = &objectID,
		macName = macName);
      
      if(strcmp(macName,"neat_plate") &&
         strcmp(macName,"EJ_Bevel") &&
	 strcmp(macName,"Bevel"))continue;
      
      if(!strcmp(macName,"neat_plate"))
      {
	__DBGpr_obj(" neat plate",objectID);
      }
      if(!strcmp(macName,"EJ_Bevel"))
      {
	__DBGpr_obj(" EJ_Bevel",objectID);
      }
      if(!strcmp(macName,"Bevel"))
      {
	__DBGpr_obj(" Bevel ",objectID);
      }
            
      sts = om$send(  msg      = message NDnode.NDchange_connect(1,&consumedList[i],
								 &consumingChild[i].obj_id ),
		      senderid = NULL_OBJID,
		      targetid = objectID.objid,
		      targetos = objectID.osnum ) ;
      if(!(sts&1))
      {
	__DBGpr_obj("NDnode.NDchange_connect failed", objectID);
	continue;
      }
      /* Put the modified occurence in the batch for neat_plates only */
      if(!strcmp(macName,"neat_plate"))
	nd$wait_batch ( type       = GR_GEOM_POSTED,
			nb_obj     = 1,
			l_object   = &objectID,
			l_obj_info = &cn_type );
      
    }
    vdvla_id$Delete(vla = &childVla);   
    __DBGpr_com("***********************************************");
  }
  /* recompute the batch*/
  nd$exec_batch();
  
  retFlag = 1;
 wrapup:
  _FREE( loc_list      ); 
  _FREE( consumedList  );  
  _FREE( consumingChild);
  
  return retFlag;
}

/*
 * Dummy Function. Actual Function is in I/STRUCT.
 */
IGRlong VDcheckNeatPlateForBevels( struct GRid          neat_plate,
                                   struct GRmd_env      cur_env         )
{
   return 1;
}

IGRint VDupdateNeatPlates(struct GRid *consumedParent,
		          struct GRid *pretends,
                          IGRint       consumedCount)
{
  IGRint           retFlag = 0,i,j,status,count,cn_type,mode;
  IGRlong          msg, sts ;
  struct GRobj_env *consumingChild = NULL, *consumedOE = NULL;
  IGRshort         mat_type;
  IGRmatrix        mat;
  IGRchar          macName[128];
  struct GRid      goId,objectID, pretendID;
  struct GRmd_env  modEnv;
  TVDvlaID         childVla;

  extern IGRboolean     ASbroadcast_in_progress ;
  IGRboolean            saveBroad;

  // just update the neat_plate macros for plates in the active file  
  if (consumedCount == 0)
  {
    VDupdateLocalNeatPlates();
    retFlag = 1;
    goto wrapup;
  }
  
  if(consumedParent == NULL) goto wrapup;
  if(pretends == NULL)  goto wrapup;

  cn_type        = ND_COMP;
  consumingChild = _MALLOC(consumedCount, struct GRobj_env);
  consumedOE     = _MALLOC(consumedCount, struct GRobj_env);
  
  for(i=0; i<consumedCount; i++)
  { 
    consumingChild[i].obj_id.objid = NULL_OBJID;
    consumingChild[i].obj_id.osnum = 2;
  }
 
  // get all the consuming children of the consumed parents
  for(i=0; i<consumedCount; i++)
  {
    MAidmx( &msg,modEnv.md_env.matrix) ;
    MAtypemx( &msg, mat, &modEnv.md_env.matrix_type);
    
    goId.objid = NULL_OBJID;
    goId.osnum = -1;
    
    status = om$send(  msg = message NDnode.ASreturn_go
		       (&goId,&modEnv.md_env.matrix_type,
			modEnv.md_env.matrix),
		       senderid = NULL_OBJID,
		       targetid = pretends[i].objid,
		       targetos = pretends[i].osnum);
    
    if(!(status&1) || (goId.objid == NULL_OBJID)) 
    { __DBGpr_obj("NDnode.ASreturn_go failed for",pretends[i]);}
    
    __DBGpr_obj("pretendID ",pretends[i]);
    __DBGpr_obj("graphic object ",goId);
    
    modEnv.md_id.osnum = consumedParent[i].osnum;
    sts = ex$get_modid(mod_osnum = modEnv.md_id.osnum,
		       mod_id    = &modEnv.md_id.objid );
    
    consumedOE[i].obj_id  = consumedParent[i];
    consumedOE[i].mod_env = modEnv;
    
    VDatGetConsumingChild( &consumedOE[i], &consumingChild[i] );
    if(consumingChild[i].obj_id.objid == NULL_OBJID)
    { 
      __DBGpr_obj("VDatGetConsumingChild failed for ",consumedOE[i].obj_id);
    }
    else 
    {
      __DBGpr_obj("Consumed parent ",consumedOE[i].obj_id);
      __DBGpr_obj("Consuming child ",consumingChild[i].obj_id);
    }
    
  }
  __DBGpr_com("Neat Plate Identification and migration to new parents");
  
  // try to find the neat_plates from the consumed parent list
  // and connect them to the consuming child
  for(i=0; i<consumedCount; i++)
  {
    __DBGpr_obj("***prints for pretend******",pretends[i]);
    vdvla_id$Construct(vla = &childVla);
    vdchn$GetChildrenByClass(objID     = &pretends[i],
			     classID   = OPP_nci_macro_class_id,
                             vla       = &childVla);
    count = 0;
        
    count = vdvla_id$GetCnt (vla = &childVla);
    if(count == 0) continue;

    __DBGpr_obj("Pretend ID ",pretends[i]);
    __DBGpr_int(" No. of nci_macros connected to pretend ",count);    
    for(j=0; j<count; j++)
    {  
      objectID.objid = NULL_OBJID;
      pretendID.objid = NULL_OBJID;
      
      vdvla_id$GetAt(vla = &childVla ,nth = j,objID = &objectID);
      if(objectID.objid == NULL_OBJID) continue;
      
      vdobj$Get(objID   = &objectID,
		macName = macName);
      if(strcmp(macName,"neat_plate") &&
         strcmp(macName,"EJ_Bevel") &&
	 strcmp(macName,"Bevel"))continue;
      
      if(!strcmp(macName,"neat_plate"))
      {
	__DBGpr_obj(" neat plate",objectID)		                    ;
      }
      if(!strcmp(macName,"EJ_Bevel"))
      {
	__DBGpr_obj(" EJ_Bevel",objectID)		                    ;
      }
      if(!strcmp(macName,"Bevel"))
      {
	__DBGpr_obj(" Bevel ",objectID)		                    ;
      }      
      as$make_source( go_grid         = consumingChild[i].obj_id,
		      mod_env         = &consumingChild[i].mod_env,
		      as_grid         = &pretendID) ;
      
      if(pretendID.objid == NULL_OBJID)
      {
	__DBGpr_obj("make_source failed on",consumingChild[i].obj_id);
	continue;
      }
      __DBGpr_obj(" new pretend for neat plate ",pretendID);
      __DBGpr_obj("Consuming child ",consumingChild[i].obj_id);

      sts = om$send(  msg      = message NDnode.NDchange_connect(1,&pretends[i],
								 &pretendID ),
		      senderid = NULL_OBJID,
		      targetid = objectID.objid,
		      targetos = objectID.osnum ) ;
      if(!(sts&1))
      {
	__DBGpr_obj("NDnode.NDchange_connect failed", objectID);
	continue;
      }

      /* Put the modified occurence in the batch for neat_plates only */
      if(!strcmp(macName,"neat_plate"))
	nd$wait_batch ( type       = GR_GEOM_POSTED,
			nb_obj     = 1,
			l_object   = &objectID,
			l_obj_info = &cn_type );
      
    }
    vdvla_id$Delete(vla = &childVla);   
    __DBGpr_com("***********************************************");
  }

  saveBroad = ASbroadcast_in_progress ;
  ASbroadcast_in_progress = FALSE ;

  nd$mod_batch( request = ND_INQ, p_ret_mode = &mode );
  if( mode != ND_DEFER ) nd$exec_batch();

  ASbroadcast_in_progress = saveBroad ;

  /* recompute the macros*/
  nd$exec_batch();
  
  retFlag = 1;
  
 wrapup:
  _FREE(consumedOE);
  _FREE(consumingChild);
  return retFlag;
}
end implementation Root;
