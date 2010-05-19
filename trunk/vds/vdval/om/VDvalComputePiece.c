/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalComputePiece.c
 *
 * Description: Validation Compute Piece routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalComputePiece.c,v $
 *      Revision 1.11  2002/03/08 16:23:00  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/11/16 15:18:11  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/11/09 15:04:29  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/10/16 15:09:16  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/08/24 20:01:52  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/08/14 19:15:45  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/08/02 15:33:39  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/29 17:54:38  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/07/29 16:58:02  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/07/28 17:34:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/07/23 16:32:23  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDbuf.h"
#include "VDtest.h"
#include "VDgeomc.h"
#include "VDdraw.h"
#include "VDobj2.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDctx.h"
#include "VDss.h"


VDASSERT_FFN("VDvalComputePiece.c");

extern IGRstat VSimpose_boundaries __((IGRstat    *msg,
				       TGRobj_env *surface,
				       IGRint      bndryCount,
				       TGRobj_env  bndryList[],
				       IGRint      sfIsPlanar)) ;

static deleteOE(TGRobj_env *objOE)
{
  if (objOE->obj_id.objid != NULL_OBJID) {  
    VDobjDelete(objOE,NULL,NULL,NULL,1,NULL,NULL);
  }
}
static deleteID(TGRid *objID)
{
  if (objID->objid != NULL_OBJID) {  
    VDobjDelete(NULL,objID,NULL,NULL,1,NULL,NULL);
  }
}

static IGRstat getMaterialDirectionInfo(TGRid  *nodeID,
					IGRpoint srfPT,  /* Point on the surface */
					IGRpoint thkPT,  /* Thickness away from srfPT */
					IGRpoint norPT,  /* Normalized material direction */
					IGRpoint dirPT)  /* 10 times thickness away */
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar *txt;

  IGRdouble pts[6];
  IGRint i;
  
  BSrc rc;
  
  IGRdouble thickness;
  
  // Get and parse the attribute
  sts = VDctxGetTxtAtrPtr(nodeID,"mtl_points",&txt);
  if (!(sts & 1)) goto wrapup;
  VDvalConvertTextToPoints(txt,NULL,pts);
  
  // Copy over
  for(i = 0; i < 3; i++) {
    srfPT[i] = pts[i];
    thkPT[i] = pts[i+3];
  }

  // Make a normal
  BSmkvec (&rc,norPT,srfPT,thkPT);
  MAunitvc(&rc,norPT,norPT);

  // Push it back out
  VDgeom2GetDisPtPt(srfPT,thkPT,&thickness);
  thickness *= 10.0;
  for(i = 0; i < 3; i++) {
    dirPT[i] = srfPT[i] + (thickness * norPT[i]);
  }

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

static void createPlane(TGRid     *nodeID,   
			TGRmd_env *env,
			TGRid     *crvID, 
			TGRid     *planeID)
{
  VDASSERT_FN("createPlane");
  
  IGRchab buf;
  
  TGRobj_env crvOE,macOE;
  TGRobj_env planeOE;

  // Init
  planeID->objid = NULL_OBJID;
  macOE.obj_id.objid = NULL_OBJID;
  
  // Use the vds macro
  crvOE.obj_id  = *crvID;
  crvOE.mod_env = *env;
  VDefpPlaceMacro(NULL,"pla_encomp",0,1,&crvOE,&macOE);
  if (macOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Pull out the foot
  VDobjGetFoot(&macOE,NULL,"res_surf",&planeOE);
  if (planeOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // And disconnect
  VDobjDisconnectFromOwner(&macOE.obj_id,&planeOE.obj_id);

  // Done
  *planeID = planeOE.obj_id;
  
 wrapup:

  // Clean up
  deleteOE(&macOE);
  
  return;
}

static void createSolid(TGRid      *nodeID,   
			TGRobj_env *xmlOE,
			TGRmd_env  *env,
			IGRint      createFlag,
			IGRpoint    pt,
			TGRid      *srfID, 
			TGRid      *solidID)
{
  VDASSERT_FN("createSolid");
  
  IGRchab buf;
  
  TGRobj_env srfOE,macOE,ptOE;
  TGRobj_env solidOE;

  TGRobj_env tplOEs[2];
  
  TGRid ptID;
  
  // Init
  solidID->objid = NULL_OBJID;
  macOE.obj_id.objid = NULL_OBJID;
  ptID.objid = NULL_OBJID;
  tplOEs[0].obj_id.objid = NULL_OBJID;
  
  if (createFlag == 0) goto wrapup;
  
  // Make a point
  VDdrawLinear(1,pt,env,&ptID);
  VDASSERTW(ptID.objid != NULL_OBJID);

  // Use the vds macro
  tplOEs[0].obj_id  =  ptID;
  tplOEs[0].mod_env = *env;
  tplOEs[1].obj_id  = *srfID;
  tplOEs[1].mod_env = *env;
  
  VDefpPlaceMacro(NULL,"sol_offset",0,2,tplOEs,&macOE);
  if (macOE.obj_id.objid == NULL_OBJID) {
    VDlogPrintObject(VDLOG_ERROR,1,"Problem creating sol_offset for ",xmlOE,NULL);
    goto wrapup;
  }
  
  // Pull out the foot
  VDobjGetFoot(&macOE,NULL,"ressur",&solidOE);
  if (solidOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // And disconnect
  VDobjDisconnectFromOwner(&macOE.obj_id,&solidOE.obj_id);

  // Done
  *solidID = solidOE.obj_id;

 wrapup:

  // Clean up
  deleteOE(&macOE);
  deleteOE(&tplOEs[0]);

  return;
}

/* -----------------------------------------------
 * Create a flange group and add graphics
 */
static void drawFlange(TGRid      *pieceID,
		       TGRobj_env *xmlOE,
		       TGRmd_env  *env,
		       IGRint      createSolidFlag,
		       IGRchar    *name, 
		       TGRid      *groupID)
{
  VDASSERT_FN("drawFlange");

  IGRstat sts;
  
  IGRchar *buf;
  
  TGRbsp_curve *crv = NULL;
  TGRid  crvID;
  TGRid  srfID;
  TGRid  solidID;
  TGRid  planeID;
  
  TGRbsp_surface *srf = NULL;
  
  TGRid flangeIDs;
  TGRid flangeID;
  IGRint i;
  
  IGRpoint srfPT,thkPT,norPT,dirPT;

  // Init
  groupID->objid = NULL_OBJID;

  // Get any bot flanges
  VDctxGetChildNodeByType(pieceID,name,&flangeIDs);
  if (flangeIDs.objid == NULL_OBJID) goto wrapup;
  
  // Make the group
  VDbufCreateGraphicGroup(env,groupID);
  VDASSERTW(groupID->objid != NULL_OBJID);

  // Material info
  getMaterialDirectionInfo(&flangeIDs,srfPT,thkPT,norPT,dirPT);

  // Is there a surface?
  srfID.objid = NULL_OBJID;
  sts = VDctxGetTxtAtrPtr(&flangeIDs,"surface",&buf);
  if (sts & 1) {
    VDvalConvertTextToBspSurface(buf,&srf);
    if (srf) {
      VDdrawSurface(srf,env,&srfID);
      VDvalFreeBspSurface(srf);
      srf = NULL;
    }
  }
  // Add the surface and solid
  if (srfID.objid != NULL_OBJID) {
    createSolid(&flangeIDs,xmlOE,env,createSolidFlag,thkPT,&srfID,&solidID);
    VDbufAddGeometryChild(groupID,&srfID);
    if (solidID.objid != NULL_OBJID) {
      VDbufAddGeometryChild(groupID,&solidID);
    }
  }
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&flangeIDs,i,&flangeID); i++) {
      
    // Create the contour
    sts = VDctxGetTxtAtrPtr(&flangeID,"contour",&buf);
    VDASSERTW(sts);
    VDvalConvertTextToBspCurve(buf,&crv);
    VDASSERTW(crv);
    VDgeom2CloseCurve(crv);

    VDdrawCurve(crv,env,&crvID);      
    if (crvID.objid != NULL_OBJID) {
      VDbufAddGeometryChild(groupID,&crvID);
    }
  
    // Try for a plane if no surface
    planeID.objid = NULL_OBJID;
    if ((srfID.objid == NULL_OBJID) && (crv->planar) && (crvID.objid != NULL_OBJID)) {
      createPlane(&flangeID,env,&crvID,&planeID);
    }
    free(crv); crv = NULL;

    // Add the solid
    if (planeID.objid != NULL_OBJID) {
      
      createSolid(&flangeID,xmlOE,env,createSolidFlag,thkPT,&planeID,&solidID);
      VDbufAddGeometryChild(groupID,&planeID);
      if (solidID.objid != NULL_OBJID) {
	VDbufAddGeometryChild(groupID,&solidID);
      }
    } 
  }

 wrapup:
  return;
}

/* -----------------------------------------------
 * Compute an xml piece
 */
IGRstat VDvalComputePiece(TGRobj_env *macOE,
			  IGRint      opFlag,
			  IGRint     *feetCntx,
			  TGRid      *feetIDs)
{
  VDASSERT_FN("VDvalComputePiece");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env pieceOE;
  TGRid      pieceID;
    
  IGRint     i;
  IGRint     feetCnt = 0;
  TGRmd_env *env;

  IGRchar *buf;
  
  TGRbsp_curve *crv = NULL;
  TGRid  crvID;
  TGRid  srfID;
  TGRid  solidID;
  TGRid  planeID;
  TGRid  vectorID;
  
  TGRbsp_surface *srf = NULL;
  
  TGRid nodeIDs,nodeID;

  TGRid outerGroupID;
  TGRid innerGroupID;
  TGRid flangeGroupID;
  
  IGRpoint srfPT,thkPT,norPT,dirPT;
  IGRdouble pts[6];
  
  IGRint flattenFlag;
  
  IGRint createSolidFlag = 0;
  IGRint rep;
  
  IGRint cutCnt;
  IGRint cutMax = 10;
  TGRobj_env  cutOEsx[10];
  TGRobj_env *cutOEs = NULL;
  TGRobj_env  planeOE;

  IGRstat (*fp)(IGRstat    *msg,
		TGRobj_env *surface,
		IGRint      bndryCount,
		TGRobj_env  bndryList[],
		IGRint      sfIsPlanar);
  
  // Init
  pieceID.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(feetCntx); *feetCntx = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  env = &macOE->mod_env;

  // Get the rep to create
  // Allow for future additions
  VDvalGetXmlPieceRep(&rep);
  switch(rep) {
    case 2:
      createSolidFlag = 1;
      break;
  }
  
  // Generate xml if a piece is attached
  VDobjGetTemplate(macOE,NULL,0,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) {

    // Grab the internal data
    VDbufGetDomTree(macOE,&pieceID);
    VDASSERTW(pieceID.objid != NULL_OBJID);

  }
  else {
    
    // Read from the piece
    VDvalConvertPieceToDom(&pieceOE,NULL,&pieceID,NULL,VDVAL_DOM_WANT_ALL);
    VDASSERTW(pieceID.objid != NULL_OBJID);

    // Save it
    VDbufSetDomTree(macOE,&pieceID);
    
    VDctxSaveTreeToXmlFile(&pieceID,"piece.xml");
  }

  // Make a group
  VDbufCreateGraphicGroup(env,&outerGroupID);
  VDASSERTW(outerGroupID.objid != NULL_OBJID);
  feetIDs[feetCnt] = outerGroupID;
  feetCnt++;

  // Material info
  getMaterialDirectionInfo(&pieceID,srfPT,thkPT,norPT,dirPT);

  // Get the outer contour
  sts = VDctxGetTxtAtrPtr(&pieceID,"outer_contour",&buf);
  VDASSERTW(sts);
  VDvalConvertTextToBspCurve(buf,&crv);
  VDASSERTW(crv);
  VDgeom2CloseCurve(crv);
  VDdrawCurve(crv,env,&crvID);
  if (crvID.objid != NULL_OBJID) {
    VDbufAddGeometryChild(&outerGroupID,&crvID);   
  }

  // Create surface if have one
  srfID.objid    = NULL_OBJID;
  planeID.objid  = NULL_OBJID;
  sts = VDctxGetTxtAtrPtr(&pieceID,"outer_surface",&buf);
  if (sts & 1) {
    VDvalConvertTextToBspSurface(buf,&srf);
    if (srf) {
      VDdrawSurface(srf,env,&srfID);
      VDvalFreeBspSurface(srf);
      srf = NULL;
    }
  }

  // Try for a plane of no surface
  if ((srfID.objid == NULL_OBJID) && (crv->planar) && (crvID.objid != NULL_OBJID)) {
    createPlane(&pieceID,env,&crvID,&planeID);
    srfID = planeID;
  }
    
  // Done with this
  free(crv); crv = NULL;
  
  // Material direction
  for(i = 0; i < 3; i++) {
    pts[i]   = srfPT[i];
    pts[i+3] = dirPT[i];
  }
  VDdrawLinear(2,pts,env,&vectorID);
  if (vectorID.objid != NULL_OBJID) {
    VDbufAddGeometryChild(&outerGroupID,&vectorID);
  }
 
  // Get any inner contours
  VDctxGetChildNodeByType(&pieceID,"inner_cutouts",&nodeIDs);
  if (nodeIDs.objid != NULL_OBJID) {
  
    // Make a group
    VDbufCreateGraphicGroup(env,&innerGroupID);
    VDASSERTW(innerGroupID.objid != NULL_OBJID);

    GRgrpGetDoNotFlatten(&flattenFlag);
    GRgrpSetDoNotFlatten(1);
    VDbufAddGeometryChild(&outerGroupID,&innerGroupID);
    GRgrpSetDoNotFlatten(flattenFlag);

    // Cycle once to get count
    for(i = 0; VDctxGetNthTreeChild(&nodeIDs,i,&nodeID); i++);
    cutCnt = i;
    if (cutCnt < cutMax) cutOEs = cutOEsx;
    else cutOEs = malloc(cutCnt * sizeof(TGRobj_env));
    VDASSERTW(cutOEs);
    
    // Cycle and create curves
    for(i = 0; VDctxGetNthTreeChild(&nodeIDs,i,&nodeID); i++) {

      sts = VDctxGetTxtAtrPtr(&nodeID,"contour",&buf);
      VDASSERTW(sts);
      VDvalConvertTextToBspCurve(buf,&crv);
      VDASSERTW(crv);
      VDgeom2CloseCurve(crv);

      VDdrawCurve(crv,env,&crvID);
      free(crv); crv = NULL;
      
      VDASSERTW(crvID.objid != NULL_OBJID);
      VDbufAddGeometryChild(&innerGroupID,&crvID);

      cutOEs[i].mod_env = macOE->mod_env;
      cutOEs[i].obj_id  = crvID;
      
    }

    // Impose any cutouts on planes
    if ((planeID.objid != NULL_OBJID) && cutCnt) {

      // Just in case no struct
      fp = (IGRstat (*)(IGRstat    *msg,
			TGRobj_env *surface,
			IGRint      bndryCount,
			TGRobj_env  bndryList[],
			IGRint      sfIsPlanar))
	dload_address_lookup("VSimpose_boundaries");

      if (fp) {
	planeOE.mod_env = macOE->mod_env;
	planeOE.obj_id  = planeID;
	sts = (*fp)(&msg,&planeOE,cutCnt,cutOEs,1);
	if (!(sts & msg & 1)) {
	  VDlogPrintFmt(VDLOG_ERROR,1,"*** Problem imposing planar inner cutouts");
	}
	// Don't think it will change but be safe
	srfID = planeID = planeOE.obj_id;
      }
      
    }
    // Free up list
    if (cutOEs && (cutOEs != cutOEsx)) free(cutOEs);
    cutOEs = NULL;
  }

  // Make a solid
  if (srfID.objid != NULL_OBJID) {

    createSolid(&pieceID,macOE,env,createSolidFlag,thkPT,&srfID,&solidID);

    VDbufAddGeometryChild(&outerGroupID,&srfID);

    if (solidID.objid != NULL_OBJID) {
      VDbufAddGeometryChild(&outerGroupID,&solidID);
    }
  }

  // Get any top flanges
  drawFlange(&pieceID,macOE,env,createSolidFlag,"top_flanges",&flangeGroupID);
  if (flangeGroupID.objid != NULL_OBJID) {
    feetIDs[feetCnt] = flangeGroupID;
    feetCnt++;
  }
  // Get any bot flanges
  drawFlange(&pieceID,macOE,env,createSolidFlag,"bot_flanges",&flangeGroupID);
  if (flangeGroupID.objid != NULL_OBJID) {
    feetIDs[feetCnt] = flangeGroupID;
    feetCnt++;
  }

  // Done
  *feetCntx = feetCnt;
  retFlag = 1;

 wrapup:
  
  VDctxDeleteNode(&pieceID);
  
  if (crv) free(crv);

  if (cutOEs && (cutOEs != cutOEsx)) free(cutOEs);
  
  return retFlag;
}

/* -----------------------------------------------
 * Create a tree full of possible standard pieces
 */
void VDvalCreateStdPieceTreeForOS(VDosnum osnum,TGRid *treeID)
{
  VDASSERT_FN("VDvalCreateStdPieceTree");
  
  IGRint  plateCnt,beamCnt,pieceCnt;
  IGRchab key;
  
  TGRid *listIDs = NULL;
  TGRid  pieceID;
  TGRobj_env pieceOE;
  IGRint i;
  
  TGRid nodeID;

  IGRdouble dbl;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(osnum != OM_K_NOT_AN_OS);
  
  // Get list of pieces
  VDobjGetPieces(osnum, &plateCnt, &beamCnt, &listIDs);
  pieceCnt = plateCnt + beamCnt;
  
  // Build the tree
  VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_PIECES,NULL,treeID);
  
  // Cycle through
  for(i = 0; i < pieceCnt; i++) {
    pieceID = listIDs[i];
    pieceOE.obj_id = pieceID;
    VDobjResetOE(&pieceOE);

    // Process standard
    VDvalGetStdPcmk1Key(&pieceOE,key);
    if (*key) {

      TGRid   infoID;
      TGRid   macID;
      IGRchab buf;

      TGRobj_env srfOE;
      TGRobj_env macOE;
      TGRobj_env parentOE;
      
      // Create the node
      VDvalConvertPieceToDom(&pieceOE,treeID,&nodeID,NULL,VDVAL_DOM_WANT_ALL);
      VDASSERTW(nodeID.objid != NULL_OBJID);

      // Add some info about the piece structure
      VDctxCreateNode(&nodeID,"std_info",NULL,&infoID);
      VDASSERTW(infoID.objid != NULL_OBJID);
      
      // Get the macro it is placed on
      VDobjGetParent(&pieceOE,NULL,0,&macID,NULL,NULL);
      VDobjGetMacroName(NULL,&macID,buf);
      VDctxAppTxtAtr(&infoID,"macro_name",buf);

      // Need the macro env
      VDobjGetTemplate(&pieceOE,NULL,0,&srfOE);
      if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;
      macOE.mod_env = srfOE.mod_env;
      macOE.obj_id  = macID;

      // First Parent
      VDobjGetTemplate(&macOE,NULL,0,&parentOE);
      VDctxGetTxtAtr(&parentOE.obj_id,"family_name",buf);
      VDctxAppTxtAtr(&infoID,"family_name1",buf);
      VDctxGetTxtAtr(&parentOE.obj_id,"part_num",buf);
      VDctxAppTxtAtr(&infoID,"part_num1",buf);
      VDctxGetTxtAtr(&parentOE.obj_id,"grade",buf);
      VDctxAppTxtAtr(&infoID,"grade1",buf);

      // Second Parent
      VDobjGetTemplate(&macOE,NULL,1,&parentOE);
      VDctxGetTxtAtr(&parentOE.obj_id,"family_name",buf);
      VDctxAppTxtAtr(&infoID,"family_name2",buf);
      VDctxGetTxtAtr(&parentOE.obj_id,"part_num",buf);
      VDctxAppTxtAtr(&infoID,"part_num2",buf);
      VDctxGetTxtAtr(&parentOE.obj_id,"grade",buf);
      VDctxAppTxtAtr(&infoID,"grade2",buf);

      // Add the key and actual piece mark if known
      VDctxAppTxtAtr(&infoID,"std_key",key);
      VDctxGetPieceMark(&pieceOE.obj_id,buf);
      VDctxAppTxtAtr(&infoID,"pcmk",buf);

      VDctxGetTxtAtr(&pieceOE.obj_id,"grade",buf);
      VDctxAppTxtAtr(&infoID,"grade",buf);

      VDctxGetDblAtr(&pieceOE.obj_id,"plate_thk",&dbl);
      sprintf(buf,"%.2f",dbl);
      VDctxAppTxtAtr(&infoID,"thickness",buf);
      
    }
  }
  
  // Done

 wrapup:
  if (listIDs) free(listIDs);
  
}

/* -----------------------------------------------
 * Create a tree full of possible standard pieces
 * Actually a wrapper to use standard way
 * to find the model os
 */
void VDvalCreateStdPieceTree(TGRid *treeID)
{
  VDASSERT_FN("VDvalCreateStdPieceTree");
  
  IGRchab unit,modelFileName;
  VDosnum modelOS;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  
  // Get list of pieces
  VDrrvGetDefaultUnitModel(unit,modelFileName);
  VDosGetFileNameOS(modelFileName,&modelOS);
  VDASSERTW(modelOS != OM_K_NOT_AN_OS);

  VDvalCreateStdPieceTreeForOS(modelOS,treeID);
  
 wrapup:
  return;
  
}
/* -----------------------------------------------
 * Create a tree of all pieces
 */
void VDvalCreatePieceTreeForOS(VDosnum osnum,TGRid *treeID)
{
  VDASSERT_FN("VDvalCreatePieceTree");
  
  IGRint  plateCnt,beamCnt,pieceCnt;
  IGRchab key;
  
  TGRid *listIDs = NULL;
  TGRid  pieceID;
  TGRobj_env pieceOE;
  IGRint i;
  
  TGRid nodeID;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(osnum != OM_K_NOT_AN_OS);
  
  // Get list of pieces
  VDobjGetPieces(osnum, &plateCnt, &beamCnt, &listIDs);
  pieceCnt = plateCnt + beamCnt;
  
  // Build the tree
  VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_PIECES,NULL,treeID);
  
  // Cycle through
  for(i = 0; i < pieceCnt; i++) {
    pieceID = listIDs[i];
    pieceOE.obj_id = pieceID;
    VDobjResetOE(&pieceOE);

    // Create the node
    VDvalConvertPieceToDom(&pieceOE,treeID,&nodeID,NULL,VDVAL_DOM_WANT_ALL);
    VDASSERTW(nodeID.objid != NULL_OBJID);

  }
  
  // Done

 wrapup:
  if (listIDs) free(listIDs);
  
}
/* -----------------------------------------------
 * Create a tree full of possible standard pieces
 * Actually a wrapper to use standard way
 * to find the model os
 */
void VDvalCreatePieceTree(TGRid *treeID)
{
  VDASSERT_FN("VDvalCreatePieceTree");
  
  IGRchab unit,modelFileName;
  VDosnum modelOS;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  
  // Get list of pieces
  VDrrvGetDefaultUnitModel(unit,modelFileName);
  VDosGetFileNameOS(modelFileName,&modelOS);
  VDASSERTW(modelOS != OM_K_NOT_AN_OS);

  VDvalCreatePieceTreeForOS(modelOS,treeID);
  
 wrapup:
  return;
  
}

void VDvalCreateStdPieceTreeTest(TVDtestTestInfo *info)
{
  TGRid treeID;

  IGRchab unit,buf;
  
  // Init
  treeID.objid = NULL_OBJID;

  // Make the tree
  VDvalCreateStdPieceTree(&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Save it
  VDrrvGetDefaultUnitModel(unit,buf);
  sprintf(buf,"spm%s.xml",unit);
  VDctxSaveTreeToXmlFile(&treeID,buf);
  
  // Done
  info->worked = 1;
  
 wrapup:
  VDctxDeleteNode(&treeID);
  
  return;
}

/* -----------------------------------------------
 * Create a tree full of standard piece items
 * With someting unusual about them
 */
void VDvalScanStdPieceTreeForOS(VDosnum osnum,TGRid *treeID)
{
  VDASSERT_FN("VDvalScanStdPieceTree");
  IGRstat sts;
  
  IGRint  plateCnt,beamCnt,pieceCnt;
  IGRchab key;
  
  TGRid *listIDs = NULL;
  TGRid  pieceID;
  TGRobj_env pieceOE;
  IGRint i;
  
  TGRid nodeID;

  IGRdouble dbl;

  TGRid geomID;
  IGRchab geom_key,grade,thick;
  
  IGRchar *data;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(osnum != OM_K_NOT_AN_OS);
  
  // Get list of pieces
  VDobjGetPieces(osnum, &plateCnt, &beamCnt, &listIDs);
  pieceCnt = plateCnt + beamCnt;
  
  // Build the tree
  VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_PIECES,NULL,treeID);
  
  // Cycle through
  for(i = 0; i < pieceCnt; i++) {
    pieceID = listIDs[i];
    pieceOE.obj_id = pieceID;
    VDobjResetOE(&pieceOE);

    // Process standard
    VDvalTestStdPcmk2Info(&pieceOE,key);
    if (*key && strstr(key,"SIM")) {
      
      // Get the geom info, might fail if the parents are not available
      VDvalGetStdPcmk2Info(&pieceOE,geom_key,grade,thick);
      if (*geom_key) {
	
	VDvalQryStdGeom2(geom_key,&geomID);
	if (geomID.objid != NULL_OBJID) {

	  // Create the node
	  VDvalConvertPieceToDom(&pieceOE,NULL,&nodeID,NULL,VDVAL_DOM_WANT_ALL);
	  VDASSERTW(nodeID.objid != NULL_OBJID);

	  // Compare the geometry
	  sts = VDvalCompareNodeGeometry(&geomID,&nodeID,3.0,NULL);
	  if (sts & 1) {
	    printf("*** SIM piece is really like\n");
	  }
	  else {
	    printf("    SIM piece is not like\n");
	  }
	  VDctxDeleteNode(&nodeID);
	}
	else {
	  printf("*** %s\n",geom_key);
	}
      }
    }
  }
  
  // Done

 wrapup:
  if (listIDs) free(listIDs);
  
}

void VDvalScanStdPieceTreeTest(TVDtestTestInfo *info)
{
  VDASSERT_FN("VDvalScanStdPieceTreeTest");
  
  TGRid   treeID;

  IGRchab buf,unit,modelFileName;
  
  VDosnum modelOS;
  
  // Init
  treeID.objid = NULL_OBJID;

  // The os number
  VDrrvGetDefaultUnitModel(unit,modelFileName);
  VDosGetFileNameOS(modelFileName,&modelOS);
  VDASSERTW(modelOS != OM_K_NOT_AN_OS);

  // Make the tree
  VDvalScanStdPieceTreeForOS(modelOS,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Save it
  sprintf(buf,"spx%s.xml",unit);
  VDctxSaveTreeToXmlFile(&treeID,buf);
  
  // Done
  info->worked = 1;
  
 wrapup:
  VDctxDeleteNode(&treeID);
  
  return;
}

