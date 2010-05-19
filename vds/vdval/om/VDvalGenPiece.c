/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalGenPiece.c
 *
 * Description: Generate Piece XML
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalGenPiece.c,v $
 *      Revision 1.10  2002/06/12 18:27:56  ahundiak
 *      ah
 *
 *      Revision 1.9  2002/06/07 14:48:09  ahundiak
 *      ah
 *
 *      Revision 1.8  2002/05/03 20:12:33  ahundiak
 *      ah
 *
 *      Revision 1.7  2002/03/21 23:04:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2002/03/04 20:53:23  ylong
 *      CR5068 and CR5286
 *
 *      Revision 1.5  2001/11/09 15:04:29  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/08/24 20:01:52  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/02 15:33:39  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/07/29 16:58:02  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/07/28 17:43:48  ahundiak
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
#include "VDobj2.h"
#include "VDgeomc.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDxdom.h"
#include "VDctx.h"
#include "VDss.h"

VDASSERT_FFN("VDvalGenPiece.c");

extern IGRstat VDgeom2GetSurfaceNaturalContourGeometry __((TGRobj_env     *i_srfOE,
							   IGRint          i_bspMax,
							   TGRbsp_curve  **i_bsps,
							   IGRint         *o_bspCnt,
							   TGRbsp_curve ***o_bsps));

extern IGRstat VDgeom2MergeNaturalEdges __((TGRbsp_curve **bsps, 
					    IGRint         bspCnt, 
					    IGRdouble      tol));

extern IGRstat VDgeomoGetSurfaceNormal __((TGRobj_env *srfOE, IGRpoint pt, IGRvector normal));

/* -----------------------------------------------
 * add a normal and some reference points
 */
static void addSurfaceNormals(TGRid *nodeID, TGRobj_env *srfOE, IGRdouble thickness)
{
  IGRstat sts;

  IGRdouble pts[9];
  
  IGRint  i;
  
  IGRchar *p = NULL;
  
  if (thickness < 1.0) thickness = 1.0;
  
  sts = VDgeomoGetSurfaceNormal(srfOE,&pts[0],&pts[3]);
  if (sts != 1) {
    VDlogPrintFmt(VDLOG_ERROR,1,"Problem getting normal from surface");
    goto wrapup;
  }
  
  for(i = 0; i < 3; i++) {
    pts[i+3] = pts[i] + (pts[i+3] * thickness);
  }
  VDvalConvertPointsToText(2,pts,&p);
  if (p) {  
    VDctxAppTxtAtr(nodeID,"mtl_points",p);
    free(p);
  }

 wrapup:
  return;
  
}


/* -----------------------------------------------
 * Convert a piece into a xdom node
 */
IGRstat VDvalConvertPieceToDom(TGRobj_env *pieceOE, TGRid *parentID, TGRid *domID,
			       IGRint *errCnt,
			       IGRint wantFlag)
{
  VDASSERT_FN("VDvalConvertPieceToDom");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint isPlate = 0;
  IGRint errCntx;
  
  IGRchar *txt = NULL;
  IGRchar  key[128];

  TGRobj_env srfOE;
  TGRbsp_surface *srf = NULL; // Note: Do not free
  
  TGRbsp_curve **bsps = NULL;
  IGRint i,cnt,cntx;
  
  TGRid nodeIDs;
  TGRid nodeID;
  
  IGRdouble thickness = 1.0;
  IGRchar *type;
  IGRchab  buf;

  // Arg check
  if (errCnt == NULL) errCnt = &errCntx;
  *errCnt = 0;
  VDASSERTW(domID); domID->objid = NULL_OBJID;
  VDASSERTW(pieceOE && pieceOE->obj_id.objid != NULL_OBJID);
  
  // Plate or beam
  sts = VDobjIsAncestryValid(pieceOE,NULL,OM_K_NOTUSING_CLASSID,"VSplate");
  if (sts) isPlate = 1;
  else {
    sts = VDobjIsAncestryValid(pieceOE,NULL,OM_K_NOTUSING_CLASSID,"VSbeam");
    VDASSERTW(sts);
  }
  
  // Make the basic node
  if (isPlate) type = VDCTX_NODE_TYPE_SS_OM_PLATE;
  else         type = VDCTX_NODE_TYPE_SS_OM_BEAM;
  
  if (parentID) VDctxCreateNode(parentID,type,NULL,domID);
  else          VDctxCreateXdomTree(type,NULL,domID);

  // Piece attributes
  VDvalAddPieceAttributes(pieceOE,domID,errCnt,wantFlag);

  // Piece marks are very handy when available
  VDobjGetTxtAtr(pieceOE,NULL,"SA_AST:StagingTree:0:pcmk",buf);
  VDctxAppTxtAtr(domID,VDCTX_ATR_SS_PIECE_PCMK,buf);

  // Just for kicks
  if (isPlate) {
    VDctxAppTxtAtr(domID,VDCTX_ATR_SS_PIECE_TYPE,VDCTX_ATR_SS_PIECE_TYPE_PLATE);
    VDvalAddPlateAttributes(pieceOE,domID,errCnt,wantFlag);
    VDobjGetDblAtr(pieceOE,NULL,"plate_thk",&thickness);
  }
  else {
    VDctxAppTxtAtr(domID,VDCTX_ATR_SS_PIECE_TYPE,VDCTX_ATR_SS_PIECE_TYPE_BEAM);
    VDvalAddBeamAttributes(pieceOE,domID,errCnt,wantFlag);
    VDobjGetDblAtr(pieceOE,NULL,"x_Web_Thickness",&thickness);
  }
  if (wantFlag < VDVAL_DOM_WANT_GEOM) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Main surface
  if (isPlate) VDobjGetFoot(pieceOE,NULL,"plate:base",&srfOE);
  else         VDobjGetFoot(pieceOE,NULL,"beam:body:web_____l",&srfOE);
  VDASSERTW(srfOE.obj_id.objid != NULL_OBJID);

  // Get the edges
  VDgeom2GetSurfaceNaturalContourGeometry(&srfOE,0,NULL,&cnt,&bsps);
  VDASSERTW(cnt && bsps);

  // Reduce
  VDgeom2MergeNaturalEdges(bsps,cnt,.1);
  VDASSERTW(bsps[0]);

  // First one is the contour
  VDvalConvertBspCurveToText(bsps[0],&txt);
  VDASSERTW(txt);
  VDctxAppTxtAtr(domID,"outer_contour",txt);
  free(txt); txt = NULL;

  // Material direction info
  addSurfaceNormals(domID,&srfOE,thickness);
  
  // Next come inner cutouts
  nodeIDs.objid = NULL_OBJID;
  for(i = 1; i < cnt; i++) {
    if (bsps[i]) {
      if (nodeIDs.objid == NULL_OBJID) {
	VDctxCreateNode(domID,"inner_cutouts",NULL,&nodeIDs);
	VDASSERTW(nodeIDs.objid != NULL_OBJID);
      }
      VDctxCreateNode(&nodeIDs,"inner_cutout",NULL,&nodeID);
      VDvalConvertBspCurveToText(bsps[i],&txt);
      VDASSERTW(txt);
      VDASSERTW(nodeID.objid != NULL_OBJID);
      VDctxAppTxtAtr(&nodeID,"contour",txt);
      free(txt); txt = NULL;      
    }
  }
  free(bsps); bsps = NULL;

  // Generate surface if non-planar
  VDgeomoGetSurfaceBoundaryGeometry(&srfOE,&srf);
  if (srf && srf->planar == 0) {
    VDvalConvertBspSurfaceToText(srf,&txt);
    VDASSERTW(txt);
    VDctxAppTxtAtr(domID,"outer_surface",txt);
    free(txt); txt = NULL;
  }
  if (srf) VDgeomoFreeSurfaceBoundaryGeometry(srf);
  srf = NULL;
  
  // Done for plates
  if (isPlate) {
    retFlag = 1;
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * For the flanges, first see if the left flange surface exists
   * This indicates if we have a flange at all
   */

  // Top flange if we have one
  VDobjGetFoot(pieceOE,NULL,"beam:body:flg_sup_l",&srfOE);
  if (srfOE.obj_id.objid != NULL_OBJID) {

    VDobjGetFoot(pieceOE,NULL,"beam:body:flg_sup_e",&srfOE);
    if (srfOE.obj_id.objid != NULL_OBJID) {

      // Get the edges
      VDgeom2GetSurfaceNaturalContourGeometry(&srfOE,0,NULL,&cnt,&bsps);
      VDASSERTW(cnt && bsps);

      // Reduce
      VDgeom2MergeNaturalEdges(bsps,cnt,.1);
      VDASSERTW(bsps[0]);

      VDctxCreateNode(domID,"top_flanges",NULL,&nodeIDs);
      VDASSERTW(nodeIDs.objid != NULL_OBJID);
    
      // Cycle through
      cntx = 0;
      for(i = 0; i < cnt; i++) {
	if (bsps[i]) {
	  VDctxCreateNode(&nodeIDs,"top_flange",NULL,&nodeID);
	  VDvalConvertBspCurveToText(bsps[i],&txt);
	  VDASSERTW(txt);
	  VDASSERTW(nodeID.objid != NULL_OBJID);
	  VDctxAppTxtAtr(&nodeID,"contour",txt);
	  free(txt); txt = NULL;
	  cntx++;
	}
      }
      free(bsps); bsps = NULL;

      // Need material direction information
      VDobjGetDblAtr(pieceOE,NULL,"x_Flg_Thickness",&thickness);
      addSurfaceNormals(&nodeIDs,&srfOE,thickness);
      
      // Generate surface if non-planar
      VDgeomoGetSurfaceBoundaryGeometry(&srfOE,&srf);
      if (srf && ((srf->planar == 0) || (cntx > 1))) {
	VDvalConvertBspSurfaceToText(srf,&txt);
	VDASSERTW(txt);
	VDctxAppTxtAtr(&nodeIDs,"surface",txt);
	free(txt); txt = NULL;
      }
      if (srf) VDgeomoFreeSurfaceBoundaryGeometry(srf);
      srf = NULL;

    }
  }
  
  // Bot flange if we have one
  VDobjGetFoot(pieceOE,NULL,"beam:body:flg_inf_l",&srfOE);
  if (srfOE.obj_id.objid != NULL_OBJID) {

    VDobjGetFoot(pieceOE,NULL,"beam:body:flg_inf_e",&srfOE);
    if (srfOE.obj_id.objid != NULL_OBJID) {

      // Get the edges
      VDgeom2GetSurfaceNaturalContourGeometry(&srfOE,0,NULL,&cnt,&bsps);
      VDASSERTW(cnt && bsps);

      // Reduce
      VDgeom2MergeNaturalEdges(bsps,cnt,.1);
      VDASSERTW(bsps[0]);

      VDctxCreateNode(domID,"bot_flanges",NULL,&nodeIDs);
      VDASSERTW(nodeIDs.objid != NULL_OBJID);
    
      // Cycle through
      cntx = 0;
      for(i = 0; i < cnt; i++) {
	if (bsps[i]) {
	  VDctxCreateNode(&nodeIDs,"bot_flange",NULL,&nodeID);
	  VDvalConvertBspCurveToText(bsps[i],&txt);
	  VDASSERTW(txt);
	  VDASSERTW(nodeID.objid != NULL_OBJID);
	  VDctxAppTxtAtr(&nodeID,"contour",txt);
	  free(txt); txt = NULL;
	  cntx++;
	}
      }
      free(bsps); bsps = NULL;

      // Material direction info
      VDobjGetDblAtr(pieceOE,NULL,"x_Flg_Thickness",&thickness);
      addSurfaceNormals(&nodeIDs,&srfOE,thickness);

      // Generate surface if non-planar
      VDgeomoGetSurfaceBoundaryGeometry(&srfOE,&srf);
      if (srf && ((srf->planar == 0) || (cntx > 1))) {
	VDvalConvertBspSurfaceToText(srf,&txt);
	VDASSERTW(txt);
	VDctxAppTxtAtr(&nodeIDs,"surface",txt);
	free(txt); txt = NULL;
      }
      if (srf) VDgeomoFreeSurfaceBoundaryGeometry(srf);
      srf = NULL;
    }
  }
  
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (bsps) free(bsps);
  return retFlag;
}

/* -----------------------------------------------
 * Simnple check for plates or beams
 */
IGRstat VDobjIsPiece(TGRobj_env *modelOE, TGRid *modelID)
{
  IGRstat retFlag = 0;
  TGRid   theID;

  // Object to process
  VDobjGetID(modelOE,modelID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;

  if (VDobjIsAncestryValid(NULL,&theID,NULL_CLASSID,"VSplate")) {
    retFlag = 1;
    goto wrapup;
  }
  if (VDobjIsAncestryValid(NULL,&theID,NULL_CLASSID,"VSbeam")) {
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Convert a parent into sub xdom nodes
 */
IGRstat VDvalConvertParentToDom(	TGRobj_env	*pieceOE, 
					IGRint		nth,
					IGRchar		*type,
					TGRid		*parentID,
					TGRid		*domID,
					IGRint		*errCnt,
					IGRint		wantFlag)
{
  VDASSERT_FN("VDvalConvertParentToDom");
  
  IGRstat	retFlag = 0;
  IGRstat	sts;
  IGRint	errCntx, i;
  IGRchar	*txt = NULL;
  TGRid		nodeID;
  TGRobj_env	parentOE;
  IGRchab       buf;

  // Arg check
  if (errCnt == NULL) errCnt = &errCntx;
  *errCnt = 0;
  VDASSERTW(parentID);
  VDASSERTW(pieceOE && pieceOE->obj_id.objid != NULL_OBJID);
  if(domID) domID->objid = NULL_OBJID;
  
  // Make the basic node
  if (parentID) VDctxCreateNode(parentID,type,NULL,&nodeID);
  else          VDctxCreateXdomTree(type,NULL,&nodeID);
  VDASSERTW( nodeID.objid != NULL_OBJID );

  // Get nth parent of pieceOE
  VDobjGetParent(pieceOE,NULL,nth,&parentOE.obj_id,NULL,NULL);
  if(parentOE.obj_id.objid == NULL_OBJID ) {
    *errCnt = *errCnt + 1;
    goto wrapup;
  }
 
  sts = VDvalAddModelCompPathAttribute(&parentOE,&nodeID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;

  sts = VDvalAddModelTagAttribute(&parentOE,&nodeID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;

  // Some special handling for pieces
  if (VDobjIsPiece(&parentOE,NULL)) {
    VDctxGetPieceMark(&parentOE.obj_id,buf);
    if (*buf) VDctxAppTxtAtr(&nodeID,"piece_mark",buf);

    // This would be nice but does not work
    // VDctxGetPieceStage(&parentOE.obj_id,buf);
    // if (*buf) VDctxAppTxtAtr(&nodeID,"piece_stage",buf);
   }

  if(domID) {
    *domID = nodeID;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Convert a bevel into a xdom node
 */
IGRstat VDvalConvertBevelToDom(	TGRobj_env	*pieceOE, 
				TGRid		*parentID,
				TGRid		*domID,
				IGRint		*errCnt,
				IGRint		wantFlag)
{
  VDASSERT_FN("VDvalConvertBevelToDom");
  
  IGRstat	retFlag = 0;
  IGRstat	sts;
  IGRint	errCntx;
  IGRchar	*txt = NULL;
  TGRobj_env	crvOE;
  TGRbsp_curve	*crv = NULL;
  IGRint	i,cnt,cntx;
  
  IGRchar *type;
  
  // Arg check
  if (errCnt == NULL) errCnt = &errCntx;
  *errCnt = 0;
  VDASSERTW(domID); domID->objid = NULL_OBJID;
  VDASSERTW(pieceOE && pieceOE->obj_id.objid != NULL_OBJID);
  
  // Make the basic node
  type = VDCTX_NODE_TYPE_SS_OM_BEVEL;
  
  if (parentID) VDctxCreateNode(parentID,type,NULL,domID);
  else          VDctxCreateXdomTree(type,NULL,domID);

  // Just for kicks
  VDctxAppTxtAtr(domID,VDCTX_ATR_SS_PIECE_TYPE,VDCTX_ATR_SS_PIECE_TYPE_BEVEL);
  
  // Piece attributes
  VDvalAddBevelAttributes(pieceOE,domID,errCnt,wantFlag);

  // bevel geom
  VDobjGetFoot(pieceOE,NULL,"curve",&crvOE);
  if (crvOE.obj_id.objid == NULL_OBJID) {
    VDlogPrintFmt   (VDLOG_ERROR,1,"*** Missing curve foot for bevel object");
    VDlogPrintObject(VDLOG_ERROR,1,"   ",pieceOE,NULL);
    goto wrapup;
  }
  sts = VDobjIsAncestryValid(&crvOE,NULL,OM_K_NOTUSING_CLASSID,"GRcurve");
  if (!(sts & 1)) {
    VDlogPrintFmt   (VDLOG_ERROR,1,"*** Curve foot is not a curve for bevel object");
    VDlogPrintObject(VDLOG_ERROR,1,"   ",pieceOE,NULL);
    goto wrapup;
  }
  VDgeomGet2(&crvOE,NULL,NULL,&crv,NULL);
  if (crv == NULL) {
    VDlogPrintFmt   (VDLOG_ERROR,1,"*** Cannot get curve foot geometry for bevel object");
    VDlogPrintObject(VDLOG_ERROR,1,"   ",pieceOE,NULL);
    goto wrapup;
  }

  // contour
  VDvalConvertBspCurveToText(crv,&txt);
  VDASSERTW(txt);
  VDctxAppTxtAtr(domID,"curve",txt);
  free(txt); txt = NULL;

  // Done
  retFlag = 1;
  
 wrapup:
  if (crv) free(crv);
  if (retFlag == 0) *errCnt = 1;
  return retFlag;
}

/* ------------------------------------------------
 * Convert coordinate system into xdom
 */
IGRstat VDvalConvertCoordToDom(	TGRobj_env	*csOE, 
				TGRid		*parentID,
				TGRid		*domID,
				IGRint		*errCnt,
				IGRint		wantFlag)
{
  VDASSERT_FN("VDvalConvertPenCSToDom");
  IGRstat	retFlag = 0;
  IGRlong	sts;
  IGRchar	*type;
  TGRid		nodeID;
  IGRint	errCntx;
  
  if( domID ) domID->objid = NULL_OBJID;

  if (errCnt == NULL) errCnt = &errCntx;
  *errCnt = 0;

  type = VDCTX_NODE_TYPE_SS_OM_CS;
  if (parentID) VDctxCreateNode(parentID,type,NULL,&nodeID);
  else          VDctxCreateXdomTree(type,NULL,&nodeID);

  VDASSERTW(csOE && csOE->obj_id.objid != NULL_OBJID);

  /* There is no path definition for the cs of pen and pcg
  sts = VDvalAddModelCompPathAttribute(csOE,&nodeID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
  */

  sts = VDvalAddModelTagAttribute(csOE,&nodeID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;

  sts = VDvalAddCoordMatrixAttribute(csOE,&nodeID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;

  if( domID ) *domID = nodeID;

  retFlag = 1;
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Convert a pen or pcg into a xdom node
 */
IGRstat VDvalConvertPenToDom(	TGRobj_env	*pieceOE, 
				TGRid		*parentID,
				TGRid		*domID,
				IGRint		*errCnt,
				IGRint		wantFlag)
{
  VDASSERT_FN("VDvalConvertPenToDom");
  
  IGRstat	retFlag = 0;
  IGRstat	sts;
  
  IGRint	isPen = 0;
  IGRint	errCntx;
  
  IGRchar	macName[40];

  IGRint	i,cnt,cntx;
  
  IGRchar	*type;
  
  // Arg check
  if (errCnt == NULL) errCnt = &errCntx;
  *errCnt = 0;
  VDASSERTW(domID); domID->objid = NULL_OBJID;
  VDASSERTW(pieceOE && pieceOE->obj_id.objid != NULL_OBJID);
  
  // Make the basic node
  VDobjGetMacroName(pieceOE, NULL, macName);
  isPen = !strcmp(macName, "penMacro");
  if( isPen ) type = VDCTX_NODE_TYPE_SS_OM_PEN;
  else        type = VDCTX_NODE_TYPE_SS_OM_PCG;
  
  if (parentID) VDctxCreateNode(parentID,type,NULL,domID);
  else          VDctxCreateXdomTree(type,NULL,domID);

  // Just for kicks
  if( isPen ) {
    VDctxAppTxtAtr(domID,VDCTX_ATR_SS_PIECE_TYPE,VDCTX_ATR_SS_PIECE_TYPE_PEN);
  }
  else {
    VDctxAppTxtAtr(domID,VDCTX_ATR_SS_PIECE_TYPE,VDCTX_ATR_SS_PIECE_TYPE_PCG);
  }

  // Piece attributes
  VDvalAddPenAttributes(pieceOE,domID,errCnt,wantFlag);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
