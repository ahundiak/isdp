/* $Id: VDrrvTree.c,v 1.29 2002/06/12 18:28:54 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvTree.C
 *
 * Description: Tree Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvTree.c,v $
 *      Revision 1.29  2002/06/12 18:28:54  ahundiak
 *      ah
 *
 *      Revision 1.28  2002/05/17 15:22:33  ahundiak
 *      ah
 *
 *      Revision 1.27  2002/05/03 20:12:13  ahundiak
 *      ah
 *
 *      Revision 1.26  2002/04/18 18:22:30  ahundiak
 *      ah
 *
 *      Revision 1.25  2002/03/12 16:47:08  ylong
 *      *** empty log message ***
 *
 *      Revision 1.23  2002/03/05 15:28:05  ylong
 *      *** empty log message ***
 *
 *      Revision 1.22  2002/03/04 20:55:29  ylong
 *      CR5068 and CR5286
 *
 *      Revision 1.21  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *      Revision 1.20  2001/11/16 14:28:11  ahundiak
 *      ah
 *
 *      Revision 1.19  2001/11/09 14:53:17  ahundiak
 *      ah
 *
 *      Revision 1.18  2001/10/19 18:20:55  ahundiak
 *      ah
 *
 *      Revision 1.17  2001/07/28 17:37:46  ahundiak
 *      ah
 *
 *      Revision 1.16  2001/07/23 14:39:32  ahundiak
 *      ah
 *
 *      Revision 1.15  2001/06/03 14:50:57  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.14  2001/05/22 15:48:45  ahundiak
 *      ah
 *
 *      Revision 1.13  2001/04/13 19:48:52  ahundiak
 *      ah
 *
 *      Revision 1.12  2001/03/29 19:36:50  jdsauby
 *      Incorporation of Purpose Info
 *
 *      Revision 1.11  2001/03/22 18:46:23  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/03/19 22:06:22  jdsauby
 *      Added pdm_info and purp_info attributes to tree, moved post to create form
 *
 *      Revision 1.9  2001/03/16 16:50:23  ahundiak
 *      ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 * 07/23/01  ah      CR5450 Change web area warning to 500 from 1000
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDtest.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDss.h"

#include "VDsys.h"
#include "VDtag.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvTree.c");

/* -------------------------------------------------
 * Create a dom tree 
 */
void VDrrvCreateDomTree(IGRchar *treeType, IGRchar *treeName, TGRid *a_treeID)
{
  VDASSERT_FN("VDrrvCreateDomTree");
  
  TGRid   treeID;
  IGRchab buf;
  IGRchar *p;
  
  VDosnum osnum;
  
  // Arg check
  VDASSERTW(a_treeID); a_treeID->objid = NULL_OBJID;
  VDASSERTW(treeType && *treeType);
  VDASSERTW(treeName && *treeName);

  // Set a trace flag
  // p = getenv("ISDP_TRACE");
  // if (p && (*p == '1')) traceFlagx = 1;
  
  // Start by making the tree
  VDctxCreateXdomTree(treeType,treeName,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);

  // Attributes are added via VDrrvAddAttrsToDomTree located in
  // ./VDrrvAttr.c
  VDosGetCurrentOS(&osnum);
  VDrrvAddAttrsToDomTree(&treeID,osnum);

  // Done
  *a_treeID = treeID;
  
 wrapup:
  return;
}

static s_cnt;

/* -------------------------------------------------
 * Recursive routine for adding a staging tree
 * (VDat) node to a dom tree
 */
void VDrrvAddDomStagingTreeNode(TGRid          *domTreeID, 
				TVDctxBaseInfo *domBaseInfo,
				TVDctxNodeList *nodeList,
				TGRid          *domFindID,
				IGRint         *domNodeCnt,
				TGRid          *stagingID)
{
  VDASSERT_FN("VDrrvAddDomStagingTreeNode");

  TVDctxBaseInfo baseInfo;
  
  TGRid  domNodeID;
  TGRid  childID;
  IGRint i,cnt;

  TVDfld  flds[128];
  TVDfld *fld;
  
  TGRid  *foundID;
  IGRchab foundType;
  IGRchab path;

  TGRobj_env modelOE;
  
  IGRint errCnt = 0;
  
  // Grab the info from the tree
  VDctxGetBaseInfo(stagingID,&baseInfo);

  /* ---------------------------------------------
   * Bit of a hack here, the actual top node of
   * a staging tree has type UNIT but I really want it
   * to be of type "StagingTree".  
   *
   * Not sure if this will cause other problems.  A some point,
   * The assembly manager tree code itself might get changed
   * But for now, let's see ehat happens
   *
   * Also the possibility of adding StagingTree_ onto all node types
   * StagingTree_UNIT
   * StagingTree_PSU
   * Thats not bad.  Maybe thats what I really want.  But it's too long
   * so really mess things up and use ST
   * 
   * Probably want to stick with lower case as well?
   */
  strlwr (baseInfo.nodeType);
  sprintf(domBaseInfo->nodeType,"ss_st_%s",baseInfo.nodeType);
  strcpy (domBaseInfo->nodeName,baseInfo.nodeName);
  
  /* ---------------------------------------------
   * See what happens if the piece node is broken
   * into plate and beam nodes
   */
  if ((!strcmp(baseInfo.nodeType,VDCTX_NODE_TYPE_AT_ST_PIECE)) && (nodeList->listIDs)) {

    /* -------------------------------------------
     * This search seems pretty slow
     * try creating a fake dom later and see
     * if it speeds up
     *
     * Speeds it up some but not as much as expected,
     * something else is slowing things up, research later
     */
    VDctxGetCompPath(stagingID,path);
    VDctxSetTxtAtr(domFindID,VDCTX_ATR_SS_COMP_PATH,path);
    
    foundID = bsearch(domFindID,
		      nodeList->listIDs,
		      nodeList->cnt,
		      nodeList->size,VDctxCompareCompPath);

    strcpy(domBaseInfo->nodeType,VDCTX_NODE_TYPE_SS_ST_PIECE);

    if (foundID) {
      VDctxGetNodeType(foundID,foundType);
      if (!strcmp(foundType,VDCTX_NODE_TYPE_SS_OM_BEAM)) {
	strcpy(domBaseInfo->nodeType,VDCTX_NODE_TYPE_SS_ST_BEAM);
      }
      if (!strcmp(foundType,VDCTX_NODE_TYPE_SS_OM_PLATE)) {
	strcpy(domBaseInfo->nodeType,VDCTX_NODE_TYPE_SS_ST_PLATE);
      }      
    }
    else {

      /* -----------------------------------------
       * Indicates it's not in the model anymore?
       * If we assume the om snapshot was just done then it's
       * futile to try and find the actual object unless it had no name
       */
      if ((s_cnt == 0) || 1) {
	
	VDlogPrintFmt(VDLOG_ERROR,0,"*** Staged piece no longer in model %s",baseInfo.nodeName);
	VDlogPrintFmt(VDLOG_ERROR,0,"    %s",path);
	
	s_cnt++;
      }
      
    }
  }
  
  // Create the dom node
  VDctxCreateNode(domTreeID,
		  domBaseInfo->nodeType,
		  domBaseInfo->nodeName,
		  &domNodeID);
  VDASSERTW(domNodeID.objid != NULL_OBJID);
  VDctxSetBaseInfo(&domNodeID,domBaseInfo);
  *domNodeCnt = *domNodeCnt + 1;

  /* ---------------------------------------------
   * If it has an attached model object then store
   * some piece attributes to allow for later checking
   *
   * Something a bit strange, psu are retruing a model object?
   */
  if (!strcmp(baseInfo.nodeType,VDCTX_NODE_TYPE_AT_ST_PIECE)) {    
    VDctxGetModelObject(stagingID,&modelOE);
    if (modelOE.obj_id.objid != NULL_OBJID) {
      VDvalAddPieceAttributes(&modelOE,&domNodeID,&errCnt,VDVAL_DOM_WANT_MED);
    }
  }
  
  // Grab the attributes, skip node_type and node_stage
  VDctxGetFldAtrs(stagingID,&cnt,flds);
  for(i = 0; i < cnt; i++) {
    fld = &flds[i];
    if (strcmp(fld->name,VDCTX_ATR_AT_ST_STAGE) && 
	strcmp(fld->name,VDCTX_ATR_AT_ST_NAME)  &&
	strcmp(fld->name,VDCTX_ATR_SS_COMP_PATH)) { 
      VDctxAppTxtAtr(&domNodeID,fld->name,fld->val.txt);
    }
  }
  
  // Cycle through kids
  for(i = 0; VDctxGetNthTreeChild(stagingID,i,&childID); i++) {
    VDrrvAddDomStagingTreeNode(&domNodeID,domBaseInfo,nodeList,domFindID,domNodeCnt,&childID);  
  }
  
  // Done
 wrapup:
  return;
}

/* -------------------------------------------------
 * Add the staging tree to the snapshot tree
 */
void VDrrvAddDomStagingTree(TGRid *treeID)
{
  VDASSERT_FN("VDrrvAddDomStagingTree");
  
  TGRid stagingID;
  
  TVDctxBaseInfo baseInfo;
  IGRint cnt,i;

  TVDctxNodeList nodeListOM;
  TVDctxNodeList nodeListST;
  
  TGRid *findID,*foundID;
  
  TGRid domFindID;
  
  // Init
  VDctxInitNodeList(&nodeListOM);
  VDctxInitNodeList(&nodeListST);
  domFindID.objid = NULL_OBJID;
  
  s_cnt = 0;
  
  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Get the actual staging tree
  VDctxGetStagingTree(&stagingID,&baseInfo,&cnt);
  if (cnt == 0) goto wrapup;
  VDASSERTW(cnt == 1);
  VDASSERTW(stagingID.objid != NULL_OBJID);
  
  // Say HI
  VDlogPrintFmt(VDLOG_INFO,0,"Adding Staging Tree ...");

  // Grab a list of pieces from the tree
  VDrrvGetListOM_Pieces(treeID,2,&nodeListOM);
  qsort(nodeListOM.listIDs,nodeListOM.cnt,nodeListOM.size,VDctxCompareCompPath);
#if 0
  for(i = 0; i < nodeList.cnt; i++ ) {
    VDctxGetBaseInfo(&nodeList.listIDs[i],&baseInfo);
    printf("OM %4d %s %s\n",i,baseInfo.nodeType,baseInfo.nodeName);
  }
#endif
  
  // Speeds up validation
  VDctxCreateXdomTree("find",NULL,&domFindID);
  VDctxAppTxtAtr (&domFindID,VDCTX_ATR_SS_COMP_PATH,"fake");
  
  // The real work
  cnt = 0;
  VDctxGetBaseInfo(treeID,&baseInfo);
  VDrrvAddDomStagingTreeNode(treeID,&baseInfo,&nodeListOM,&domFindID,&cnt,&stagingID);

  VDlogPrintFmt(VDLOG_INFO,0,"Added  Staging Tree, %d nodes",cnt);
  
  // Now bounce the model pieces against the st pieces
  VDlogPrintFmt(VDLOG_INFO,0,"Bouncing model against staged pieces ...");
  VDrrvGetListST_Pieces(treeID,2,&nodeListST);
  qsort(nodeListST.listIDs,nodeListST.cnt,nodeListST.size,VDctxCompareCompPath);

  for(i = 0; i < nodeListOM.cnt; i++) {
    findID = &nodeListOM.listIDs[i];
    foundID = bsearch(findID,nodeListST.listIDs,nodeListST.cnt,nodeListST.size,VDctxCompareCompPath);
    if (foundID == NULL) {
      VDctxGetBaseInfo(findID,&baseInfo);
      VDlogPrintFmt(VDLOG_ERROR,0,"Piece Not Staged %-12s %s",baseInfo.nodeType,baseInfo.nodeName);
    }
  }
  VDlogPrintFmt(VDLOG_INFO,0,"Verified model against staged pieces");
  
  // Done
 wrapup:
  VDctxFreeNodeList(&nodeListST);
  VDctxFreeNodeList(&nodeListOM);

  VDctxDeleteNode(&domFindID);
  
  return;
}
/* -----------------------------------------------------------
 * Compare macro names for sorting
 */
static int compareMacroName( const void *b1,  const void *b2 )
{
  TGRid   *objID1 = (TGRid *) b1;
  TGRid   *objID2 = (TGRid *) b2;
  IGRchab name1, name2;
 
  VDobjGetMacroName( NULL, objID1, name1 );
  VDobjGetMacroName( NULL, objID2, name2 );

  return strcmp(name1, name2);
}

/* --------------------------------------------------
 * Add bevels to the snap shot tree
 */
void VDrrvAddDomBevels(VDosnum osnum, TGRid *treeID)
{
  VDASSERT_FN("VDrrvAddDomBevels");

  IGRlong	sts;
  IGRint	pieceCnt,bevelCnt,ej_bevelCnt,fab_stockCnt,va_bevelCnt;
  IGRint	i;
  IGRint	errCnt  = 0;
  IGRint	errCntx = 0;

  IGRint	wantFlag	= VDrrvCmdGetCreateQuickFlag();
  IGRint	pieceTraceFlag	= VDrrvCmdGetCreateTraceFlag();

  IGRchab	fileName, macName,path;
  TGRid		*listIDs = NULL;
  TGRid		bevelsID, nodeID;
  TGRid		modelID;
  TGRobj_env	modelOE;

  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Say HI
  //VDlogPrintFmt(VDLOG_INFO,0,"Adding bevels ...");

  VDobjGetBevels(       osnum,
                        &bevelCnt,      // Bevel count
                        &ej_bevelCnt,   // EJ_Bevel count
                        &fab_stockCnt,  // Fab_Stock count
                        &va_bevelCnt,   // VA_Bevel count
                        &listIDs);      // bevel list
  pieceCnt = bevelCnt + ej_bevelCnt + fab_stockCnt + va_bevelCnt;

  // Need to Handle no items found gracefully
  if (listIDs  == NULL) goto wrapup;
  if (pieceCnt == 0)    goto wrapup;
  
  // Validate the os by getting the fileName
  VDosGetFileName(osnum,fileName);
  VDASSERTW(*fileName);

  // Status
  VDlogPrintFmt (
        VDLOG_INFO,0,
        "File %s, Found %d Bevels, %d EJ_Bevels, %d Fab_Stocks, %d VA_Bevels, %d total.",
        fileName,bevelCnt,ej_bevelCnt,fab_stockCnt,va_bevelCnt,pieceCnt);

  // Make some nodes
  VDctxGetChildNodeByType(treeID,VDCTX_NODE_TYPE_SS_OM_BEVELS,&bevelsID);
  if (bevelsID.objid == NULL_OBJID) {
    VDctxCreateNode(treeID,VDCTX_NODE_TYPE_SS_OM_BEVELS,NULL,&bevelsID);
  }

  // Sort
  qsort(listIDs,pieceCnt,sizeof(TGRid),compareMacroName);

    // Cycle through
  for(i = 0; i < pieceCnt; i++) {

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Processing %d of %d",i+1,pieceCnt);
    }
 
    // Create the actual node
    modelID = listIDs[i];
    VDctxGetModelObject(&modelID,&modelOE);

    // Log it if in verbose mode
    if (traceFlag || pieceTraceFlag) {
      VDlogPrintObject(VDLOG_INFO,1,"Processing ",&modelOE,NULL);
    }

    // Check for a valid name, root bevels causes crashes
    VDctxGetCompPath(&modelID,path);
    if (*path == 0) {
      VDlogPrintFmt   (VDLOG_ERROR,1,"*** ROOT Bevel Object");
      VDlogPrintObject(VDLOG_ERROR,1,"   ",&modelOE,NULL);
      errCntx++;
    }
    else {

      // Reset error counter
      errCnt = 0;

      // Convert bevel to xdom
      VDvalConvertBevelToDom(&modelOE,&bevelsID,&nodeID,&errCnt,wantFlag);
      errCntx += errCnt;

      // Convert bevel 0th parent (plate 1) to xdom
      sts = VDvalConvertParentToDom (
                        &modelOE, 1, VDCTX_NODE_TYPE_SS_OM_BEVEL_PLATE,
                        &nodeID, NULL, &errCnt,wantFlag);
      if( !(sts&1) ) {
        VDlogPrintFmt   (VDLOG_ERROR,1,"*** Missing or Problem with plate 1 for bevel object");
        VDlogPrintObject(VDLOG_ERROR,1,"   ",&modelOE,NULL);
      }
      errCntx += errCnt;

      // Convert bevel 1th parent (plate 2 for Bevel)
      VDobjGetMacroName( &modelOE, NULL, macName);
      if( !strcmp( macName, "Bevel" ) ) {
        sts = VDvalConvertParentToDom (
                          &modelOE,2,VDCTX_NODE_TYPE_SS_OM_BEVEL_PLATE,
                          &nodeID,NULL,&errCnt,wantFlag);
        errCntx += errCnt;
        if( !(sts&1) ) {
          VDlogPrintFmt   (VDLOG_ERROR,1,"*** Missing or Problem plate 2 for bevel object");
          VDlogPrintObject(VDLOG_ERROR,1,"   ",&modelOE,NULL);
        }
      }
    }
  }
  VDlogPrintFmt(VDLOG_STAT,0,"");
  VDlogPrintFmt(VDLOG_INFO,0,"Done adding bevels, Error Count %d",errCntx);

 wrapup:
  if(listIDs) free(listIDs);
  return;
}

/* --------------------------------------------------
 * Add penerations and controls to the snap shot tree
 */
void VDrrvAddDomPens(VDosnum osnum, TGRid *treeID)
{
  VDASSERT_FN("VDrrvAddDomPens");

  IGRlong	sts;
  IGRint	pieceCnt,penCnt,pcgCnt;
  IGRint	i, isPen = 0;
  IGRint	errCnt  = 0;
  IGRint	errCntx = 0;

  IGRint	wantFlag	= VDrrvCmdGetCreateQuickFlag();
  IGRint	pieceTraceFlag	= VDrrvCmdGetCreateTraceFlag();

  IGRchab	fileName, macName;
  IGRchar	errMsg[128];
  TGRid		*listIDs = NULL;
  TGRid		pensID, pcgsID, nodeID;
  TGRid		modelID;
  TGRobj_env	modelOE, csOE;

  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Say HI
  //VDlogPrintFmt(VDLOG_INFO,0,"Adding penetrations and controls ...");

  // Get a list of the pieces
  VDobjGetPenPcg( osnum, &penCnt, &pcgCnt, &listIDs);
  pieceCnt = penCnt + pcgCnt;

  // Need to Handle no items found gracefully
  if (listIDs  == NULL) goto wrapup;
  if (pieceCnt == 0)    goto wrapup;
  
  // Validate the os by getting the fileName
  VDosGetFileName(osnum,fileName);
  VDASSERTW(*fileName);

  // Status
  VDlogPrintFmt (
        VDLOG_INFO,0,
        "File %s, Found %d penetrations, %d controls, %d total.",
        fileName,penCnt,pcgCnt,pieceCnt);

  // Make some nodes
  VDctxGetChildNodeByType(treeID,VDCTX_NODE_TYPE_SS_OM_PENS,&pensID);
  if (pensID.objid == NULL_OBJID) {
    VDctxCreateNode(treeID,VDCTX_NODE_TYPE_SS_OM_PENS,NULL,&pensID);
  }
  VDctxGetChildNodeByType(treeID,VDCTX_NODE_TYPE_SS_OM_PCGS,&pcgsID);
  if (pcgsID.objid == NULL_OBJID) {
    VDctxCreateNode(treeID,VDCTX_NODE_TYPE_SS_OM_PCGS,NULL,&pcgsID);
  }

  // Sort
  qsort(listIDs,pieceCnt,sizeof(TGRid),compareMacroName);

  // Cycle through
  for(i = 0; i < pieceCnt; i++) {

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Processing %d of %d",i+1,pieceCnt);
    }
 
    // Create the actual node
    modelID = listIDs[i];
    VDctxGetModelObject(&modelID,&modelOE);

    // Log it if in verbose mode
    if (traceFlag || pieceTraceFlag) {
      VDlogPrintObject(VDLOG_INFO,1,"Processing ",&modelOE,NULL);
    }

    // Get macro name
    VDobjGetMacroName( &modelOE, NULL, macName);
    isPen = !strcmp(macName,"penMacro");

    errCnt = 0;

    // Convert penetration or control to xdom
    if( isPen ) {
      VDvalConvertPenToDom(&modelOE,&pensID,&nodeID,&errCnt,wantFlag);
      errCntx += errCnt;
    }
    else {
      VDvalConvertPenToDom(&modelOE,&pcgsID,&nodeID,&errCnt,wantFlag);
      errCntx += errCnt;

      sts = VDvalConvertParentToDom (
                                &modelOE,0,VDCTX_NODE_TYPE_SS_OM_PCG_PEN,
                                &nodeID,NULL,&errCnt,wantFlag);

      /* --------------------------------------
       * Mor often then not, the penMacro file is
       * not even attached so don't flag errors
       * if the parent macro cannot be found
       */
#if 0
      errCntx += errCnt;
      if( !(sts&1) ) {
	strcpy(errMsg,"*** Missing or Problem with penetration for pcg object");
        VDlogPrintFmt   (VDLOG_ERROR,1,errMsg);
        VDlogPrintObject(VDLOG_ERROR,1,"   ",&modelOE,NULL);
      }
#endif

      sts = VDvalConvertParentToDom (
                                &modelOE,2,VDCTX_NODE_TYPE_SS_OM_PCG_RFPLN,
                                &nodeID,NULL,&errCnt,wantFlag);
      if( !(sts&1) ) {
	strcpy(errMsg,"*** Missing or Problem with reference plane for pcg object");
        VDlogPrintFmt   (VDLOG_ERROR,1,errMsg);
        VDlogPrintObject(VDLOG_ERROR,1,"   ",&modelOE,NULL);
      }
      errCntx += errCnt;
    }

    // sub node for coordinate system, including matrix
    VDobjGetFoot(&modelOE,NULL,"cs",&csOE);
    VDASSERTW( csOE.obj_id.objid != NULL_OBJID );
    sts = VDvalConvertCoordToDom(&csOE,&nodeID,NULL,&errCnt,wantFlag);
    errCntx += errCnt;
    if( !(sts&1) ) {
      strcpy( errMsg, "*** Missing or Problem with coordinate system ");
      if( isPen ) {
        strcat( errMsg, "for pen object");
      }
      else {
	strcat( errMsg, "for pcg object");
      }
      VDlogPrintFmt   (VDLOG_ERROR,1,errMsg);
      VDlogPrintObject(VDLOG_ERROR,1,NULL,&modelOE,NULL);
    }
  }
  VDlogPrintFmt(VDLOG_STAT,0,"");
  VDlogPrintFmt(VDLOG_INFO,0,"Done adding penetrations and controls, Error Count %d",errCntx);

 wrapup:
  if(listIDs) free(listIDs);
  return;
}

