/* $Id: VDatTree.c,v 1.11 2002/02/26 17:44:24 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatTree.c
 *
 * Description: Tree Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatTree.c,v $
 *      Revision 1.11  2002/02/26 17:44:24  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/11/16 14:29:25  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/09/06 14:23:28  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/04/12 19:12:27  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/04/05 14:16:25  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/04/04 14:16:31  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/04/03 16:51:04  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 14:42:19  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:50:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
 * 02/26/02  ah      Moved VDctxGetCompTagInfo to vdctx/c
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDctx.h"
#include "VDdoom.h"
#include "VDss.h"
#include "VDat.h"
#include "VDat2Pcmk.h"

VDASSERT_FFN("vdat/pcmk2/VDatTree.c");


/* -----------------------------------------------
 * Initial attributes
 * Mainly to check for component path errors
 */
static void addPieceAttributes(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt)
{
  VDASSERT_FN("addPieceAttributes");
  
  IGRchab buf;
  IGRchar *p;
    
  // Component path is one way to access the object
  VDctxGetCompPath(&modelOE->obj_id, buf);
  if (*buf == 0) {
    VDlogPrintFmt   (VDLOG_ERROR,1,"*** Cannot get component path for model object");
    VDlogPrintObject(VDLOG_ERROR,1,NULL,modelOE,NULL);
    strcpy(buf,":UNKNOWN:");
    *errCnt = *errCnt + 1;
  }
  VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_COMP_PATH,buf);

  // Done
 wrapup:
  return;
}

/* -------------------------------------------------
 * Kick off the process by scanning the model space
 * and creating a quick tree
 *
 * Actually, just scan the staging tree for now, assume it's in sync
 * with any model spaces before it get's here
 */
void VDat2CreatePcmkTree(TGRid *atSetID, TGRid *domTreeID, TGRid *ssID, IGRint *a_errCnt)
{
  VDASSERT_FN("VDatInitPcmkTree");

  IGRstat sts;
  
  IGRint stopWalk = 0;
  IGRint pieceTraceFlag = 0;
  
  IGRint plateCnt = 0;
  IGRint beamCnt  = 0;
  IGRint errCnt   = 0;
  
  IGRint i;
  
  TVDctxBaseInfo baseInfo;

  TGRid piecesID,beamsID,platesID;
  TGRid nodeID;
  TGRid atLeafsID;

  TGRid     *leafID;
  TGRobj_env modelOE;
  
  TVDctxNodeList listPM;
  TVDctxNodeList listST;
  
  TGRid *findID,*foundID;

  IGRchab buf;

  // Init
  VDctxInitNodeList(&listPM);
  VDctxInitNodeList(&listST);
  
  // Arg check
  if (a_errCnt) *a_errCnt = 0;
  VDASSERTW(domTreeID); domTreeID->objid = NULL_OBJID;
  VDASSERTW(ssID);      ssID->objid      = NULL_OBJID;
  VDASSERTW(atSetID &&  atSetID->objid  != NULL_OBJID);

  // Get the set name
  VDctxGetBaseInfo(atSetID,&baseInfo);
  
  // Need the osnum for the model file
  VDatGetLeafs(atSetID,&atLeafsID);
  VDASSERTW(atLeafsID.objid != NULL_OBJID);
  
  // Get a list of pieces from the staging tree
  VDctxGetListPieces(&atLeafsID,&listST);
  VDlogPrintFmt(VDLOG_INFO,0,"Number of assembly tree pieces %d",listST.cnt);
  VDASSERTW(listST.cnt);
  VDctxSortNodeList(&listST,VDctxCompareCompPath);

  // Make the actual tree (with time stamp and purpose info)
  /* ---------------------------------------------
   * Remove this dependency and move to vdval stuff
   * later on.  Take the time to check out the whole
   * purpose info structure and make sure it all works as expected.
   */
  VDrrvCreateDomTree(VDCTX_TREE_TYPE_SS_UNIT_PCMK,baseInfo.treeName,domTreeID);
  VDASSERTW(domTreeID->objid != NULL_OBJID);
  VDctxGetBaseInfo(domTreeID,&baseInfo);

  // Add some organization
  VDctxCreateNode(domTreeID,VDCTX_NODE_TYPE_SS_OM_PIECES,"pieces",&piecesID);
  VDctxCreateNode(&piecesID,VDCTX_NODE_TYPE_SS_OM_BEAMS, "beams", &beamsID);
  VDctxCreateNode(&piecesID,VDCTX_NODE_TYPE_SS_OM_PLATES,"plates",&platesID);

  // Cycle through
  for(i = 0; i < listST.cnt; i++) {

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Processing %d of %d",i+1,listST.cnt);
    }
  
    // Create the actual node
    leafID = &listST.listIDs[i];
    VDctxGetModelObject(leafID,&modelOE);
    if (modelOE.obj_id.objid == NULL_OBJID) {
      errCnt++;
      VDctxGetCompPath(leafID,buf);
      VDlogPrintFmt(VDLOG_ERROR,1,"*** Staging tree piece not in model");
      VDlogPrintFmt(VDLOG_ERROR,1,"    %s",buf);
    }
    else {
      
      // Log it if in verbose mode
      if (traceFlag || pieceTraceFlag) {
	VDlogPrintObject(VDLOG_INFO,1,"Processing ",&modelOE,NULL);
      }

      VDctxGetNodeTypeSuffix(&modelOE.obj_id,baseInfo.nodeType);
      VDctxGetNodeName      (&modelOE.obj_id,baseInfo.nodeName);
    
      if (!strcmp(baseInfo.nodeType,VDCTX_NODE_TYPE_BEAM)) {
	VDctxCreateNode(&beamsID,VDCTX_NODE_TYPE_SS_OM_BEAM,baseInfo.nodeName,&nodeID);
	addPieceAttributes(&modelOE,&nodeID,&errCnt);
      }

      if (!strcmp(baseInfo.nodeType,VDCTX_NODE_TYPE_PLATE)) {
	VDctxCreateNode(&platesID,VDCTX_NODE_TYPE_SS_OM_PLATE,baseInfo.nodeName,&nodeID);
	addPieceAttributes(&modelOE,&nodeID,&errCnt);
      }

      // Xfer piece mark
      VDctxGetTxtAtr( leafID,VDCTX_ATR_AT_ST_PCMK,   buf);
      VDctxAppTxtAtr(&nodeID,VDCTX_ATR_SS_PIECE_PCMK,buf);
      
      // Xfer parent stage
      VDctxGetPieceStage( leafID,buf);
      VDctxSetPieceStage(&nodeID,buf);

    }
  }
  
  // See if have a snapshot tree, if so load it up
  VDdoomGetNthTS(baseInfo.treeType,
		 baseInfo.treeName,
		 0,NULL,NULL,ssID);
  
  // Done
 wrapup:

  VDctxFreeNodeList(&listPM);
  VDctxFreeNodeList(&listST);
  
  VDlogPrintFmt(VDLOG_INFO,0,"Done creating piece mark tree, Error Count %d",errCnt);

  if (a_errCnt) *a_errCnt = errCnt;
  
  return;
}

/* -------------------------------------------------
 * Update the actual staging tree piece marks
 * There should be a one to one match netween the two trees
 * Rely on comp_path for link
 */
void VDat2UpdateStagingTreePcmks(TGRid *atSetID, TGRid *domTreeID, TGRid *ssID, 
				 IGRint saveSS, IGRint risNextPcmk, IGRint *a_errCnt)
{
  VDASSERT_FN("VDatUpdateStagingTreePcmks");

  IGRint errCnt = 0;  
  IGRint i;

  TGRid atLeafsID;

  TVDctxNodeList listPM;
  TVDctxNodeList listST;
  
  TGRid *findID,*foundID;
  TGRid  doomID;
  
  IGRchab pcmkPM,pcmkST;
  IGRchab buf;
  IGRchab unit;
  
  IGRint risNextPcmkx;
  IGRint nextPcmk = 0;
  IGRint pcmk = 0;
  
  // Init
  VDctxInitNodeList(&listPM);
  VDctxInitNodeList(&listST);
  
  // Arg check
  if (a_errCnt) *a_errCnt = 0;
  VDASSERTW(domTreeID); if (domTreeID->objid == NULL_OBJID) goto wrapup;
  VDASSERTW(atSetID);   if (  atSetID->objid == NULL_OBJID) goto wrapup;

  /* ----------------------------------------------------
   * The passed risNextPcmk reflects what was in the next_pcmk
   * table when the piece mark command started, 
   * if it has changed since then some kind of multiple users on one unit
   * is occusring and nextPcmk may be bad.
   *
   * So don't allow the users to save if this happens
   */
  VDctxGetNodeName(atSetID,unit);
  VDat2RisGetNextPcmk(unit,&risNextPcmkx);
  if (risNextPcmk != risNextPcmkx) {

    VDlogPrintFmt(VDLOG_ERROR,1,"*** The next_pcmk table has been updated since the ");
    VDlogPrintFmt(VDLOG_ERROR,1,"    piece mark command was started. this may invalidate ");
    VDlogPrintFmt(VDLOG_ERROR,1,"    Since this may invalidate the assigned piece marks, ");
    VDlogPrintFmt(VDLOG_ERROR,1,"    the piece marks will not be saved. ");
    VDlogPrintFmt(VDLOG_ERROR,1,"    X off the form and try again. ");
    goto wrapup;    
  }
    
  // Get the leafs
  VDatGetLeafs(atSetID,&atLeafsID);
  VDASSERTW(atLeafsID.objid != NULL_OBJID);
  
  // Need a list of pieces in the staging tree
  VDctxGetListPieces(&atLeafsID,&listST);
  VDlogPrintFmt(VDLOG_INFO,0,"Number of assembly tree pieces %d",listST.cnt);
  VDASSERTW(listST.cnt);
  VDctxSortNodeList(&listST,VDctxCompareCompPath);
  
  // Make a list from the dom tree
  VDctxGetListPieces(domTreeID,&listPM);
  VDASSERTW(listPM.cnt);
  VDctxSortNodeList(&listPM,VDctxCompareCompPath);
  
  // Bounce the dom tree  against the staging tree
  for(i = 0; i < listPM.cnt; i++) {
    findID = &listPM.listIDs[i];
    foundID = VDctxSearchNodeList(findID,&listST,VDctxCompareCompPath);
    if (foundID == NULL) {
      errCnt++;
      VDctxGetCompPath(findID,buf);
      VDlogPrintFmt(VDLOG_ERROR,1,"*** Piece not in staging tree ???");
      VDlogPrintFmt(VDLOG_ERROR,1,"    %s",buf);
    }
    else {
      
      // See if piece mark has changed
      VDctxGetTxtAtr( findID,VDCTX_ATR_SS_PIECE_PCMK,pcmkPM);
      VDctxGetTxtAtr(foundID,VDCTX_ATR_AT_ST_PCMK,   pcmkST);
      if (strcmp(pcmkPM,pcmkST)) {
	VDctxSetTxtAtr(foundID,VDCTX_ATR_AT_ST_PCMK,pcmkPM);
      }

      // Always go for the highest
      pcmk = atoi(pcmkPM);
      if ((pcmk < VDAT2_MIN_STD_PCMK) && (pcmk > nextPcmk)) nextPcmk = pcmk;
      pcmk = atoi(pcmkST);
      if ((pcmk < VDAT2_MIN_STD_PCMK) && (pcmk > nextPcmk)) nextPcmk = pcmk;
      
    }
  }

  // Update the piece mark table
  nextPcmk++;
  if (nextPcmk > risNextPcmk) {
    VDat2RisSetNextPcmk(unit,nextPcmk);
  }

  // Save the snapshot
  if (saveSS) {    
    VDdoomCreateFromTree(domTreeID,&doomID);
    VDASSERTW(doomID.objid != NULL_OBJID); 
  }
    
  // Done
 wrapup:

  VDctxFreeNodeList(&listPM);
  VDctxFreeNodeList(&listST);
  
  VDlogPrintFmt(VDLOG_INFO,0,"Done updating piece marks, Error Count %d",errCnt);

  if (a_errCnt) *a_errCnt = errCnt;
  
  return;
}
  
/* -------------------------------------------------
 * Report piece mark changes between the dom and either
 * the snapshot if it exists or the actual current staging tree
 */
void VDat2ReportChangedPcmks(TGRid *atSetID, TGRid *domTreeID, TGRid *ssID)
{
  VDASSERT_FN("VDatReportChangedPcmks");

  IGRint logging = 0;
  
  IGRint i;
  IGRint bs = 0;
  IGRint haveSS = 0;
  
  TGRid atLeafsID;

  TVDctxNodeList listNew;
  TVDctxNodeList listOld;
  
  TGRid  *nodeNewID,*nodeOldID;

  IGRchab pcmkNew,pcmkOld;
  IGRchab pathNew,pathOld;  
  IGRchab nameNew,nameOld;

  TVDtagInfo tagInfo;
  
  // Init
  VDctxInitNodeList(&listNew);
  VDctxInitNodeList(&listOld);
  
  // Arg check
  VDASSERTW(domTreeID); if (domTreeID->objid == NULL_OBJID) goto wrapup;

  // Have a snapshot?
  if ((ssID) && (ssID->objid != NULL_OBJID)) {
    VDctxGetListPieces(ssID,&listOld);
    VDASSERTW(listOld.cnt);
    haveSS = 1;
  }
  else {
    
    // Otherwise use the actual tree
    VDASSERTW(atSetID);
    if (atSetID->objid == NULL_OBJID) goto wrapup;

    VDatGetLeafs(atSetID,&atLeafsID);
    VDASSERTW(atLeafsID.objid != NULL_OBJID);

    VDctxGetListPieces(&atLeafsID,&listOld);
    VDASSERTW(listOld.cnt);
  }

  // Use component path for linking
  VDctxSortNodeList(&listOld,VDctxCompareCompPath);
  
  VDatGetLeafs(atSetID,&atLeafsID);
  VDASSERTW(atLeafsID.objid != NULL_OBJID);

  // Make a list from the dom tree, order by piece marsk
  VDctxGetListPieces(domTreeID,&listNew);
  VDASSERTW(listNew.cnt);
  VDctxSortNodeList(&listNew,VDat2ComparePcmksName);

  // Logs
  logging = 1;
  VDlogOpenCat("pcmk_change.rpt");
  VDlogPrintFmt(VDLOG_INFO,bs,"Verification is done.");
  VDlogPrintFmt(VDLOG_INFO,bs,
		"The following parts have been modified and their pcmk's updated as follows:");

  // Keep these two fmts in sync
#define FMT1 "%-26s %-8d %-16s %-16s %4s %4s"
#define FMT2 "%-26s %-8s %-16s %-16s %4s %4s"

  VDlogPrintFmt(VDLOG_INFO,bs,FMT2,"","","","","Old","New");
  VDlogPrintFmt(VDLOG_INFO,bs,FMT2,"Part Name","Obj ID","Old Stage","New Stage","PCMK","PCMK");
  
  // Cycle through new list
  for(i = 0; i < listNew.cnt; i++) {

    // Get em
    nodeNewID = &listNew.listIDs[i];
    nodeOldID = VDctxSearchNodeList(nodeNewID,&listOld,VDctxCompareCompPath);

    // Is it new
    if (nodeOldID == NULL) {

	// Report it
	VDctxGetCompName   (nodeNewID, nameNew);
	VDctxGetCompTagInfo(nodeNewID,&tagInfo);
	VDctxGetPieceStage (nodeNewID, pathNew);	
	if (*pathNew == 0) strcpy(pathNew,"NOT STAGED");
	strcpy(pathOld,"NEW PIECE");
	
	VDctxGetTxtAtr(nodeNewID,VDCTX_ATR_SS_PIECE_PCMK,pcmkNew);

	VDlogPrintFmt(VDLOG_INFO,bs,FMT1,nameNew,tagInfo.id.objid,
		      pathOld,pathNew,"NEW",pcmkNew);		
    }
    else {

      // See if piece mark has changed
      VDctxGetTxtAtr(nodeNewID,VDCTX_ATR_SS_PIECE_PCMK,pcmkNew);
      VDctxGetTxtAtr(nodeOldID,VDCTX_ATR_SS_PIECE_PCMK,pcmkOld);
      if (*pcmkOld == 0) {
	VDctxGetTxtAtr(nodeOldID,VDCTX_ATR_AT_ST_PCMK, pcmkOld);
      }
      if (strcmp(pcmkNew,pcmkOld)) {

	// Report it
	VDctxGetCompName   (nodeNewID,nameNew);
	VDctxGetCompTagInfo(nodeNewID,&tagInfo);
	VDctxGetPieceStage (nodeNewID, pathNew);	
	VDctxGetPieceStage (nodeOldID, pathOld);	

	// Flag if not staged
	if (*pathNew == 0) strcpy(pathNew,"NOT STAGED");

	// Only show if the path actually changed
	if (!strcmp(pathNew,pathOld)) strcpy(pathOld,"NO CHANGE");
	
	VDlogPrintFmt(VDLOG_INFO,bs,FMT1,nameNew,tagInfo.id.objid,
		      pathOld,pathNew,pcmkOld,pcmkNew);
      }

      else {
	
	// Report when stage has changed but not pcmk
	VDctxGetPieceStage(nodeNewID, pathNew);	
	VDctxGetPieceStage(nodeOldID, pathOld);

	// Flag if not staged
	if (*pathNew == 0) strcpy(pathNew,"NOT STAGED");
	if (strcmp(pathNew,pathOld)) {

	  // Report it
	  VDctxGetCompName   (nodeNewID,nameNew);
	  VDctxGetCompTagInfo(nodeNewID,&tagInfo);
	
	  VDlogPrintFmt(VDLOG_INFO,bs,FMT1,nameNew,tagInfo.id.objid,
			pathOld,pathNew,pcmkOld,pcmkNew);
	}
      }
    }
  }

  // Check for deleted snapshot items
  if (haveSS == 0) goto wrapup;
  VDctxSortNodeList(&listOld,VDat2ComparePcmksName);
  VDctxSortNodeList(&listNew,VDctxCompareCompPath);
 
  // Cycle through
  for(i = 0; i < listOld.cnt; i++) {

    // Get em
    nodeOldID = &listOld.listIDs[i];
    nodeNewID = VDctxSearchNodeList(nodeOldID,&listNew,VDctxCompareCompPath);

    if (nodeNewID == NULL) {
  
      // Report it
      VDctxGetCompName  (nodeOldID,nameOld);
      VDctxGetPieceStage(nodeOldID,pathOld);
      VDctxGetTxtAtr(nodeOldID,VDCTX_ATR_SS_PIECE_PCMK,pcmkOld);

      VDlogPrintFmt(VDLOG_INFO,bs,FMT2,nameOld,"DELETED",
		    pathOld,"DELETED",pcmkOld,"DEL");	

    }
  }
  
  
  // Done
 wrapup:

  VDctxFreeNodeList(&listOld);
  VDctxFreeNodeList(&listNew);

  if (logging) {  
    VDlogCloseCat("pcmk_change.rpt");
    VDlogShowCat ("pcmk_change.rpt");
  }
  
  return;
}
