/* $Id: VDrrvStaging.c,v 1.7 2002/06/12 18:49:20 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvStaging.c
 *
 * Description: Compare two staging trees
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvStaging.c,v $
 *      Revision 1.7  2002/06/12 18:49:20  ahundiak
 *      ah
 *
 *      Revision 1.6  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.5  2002/06/04 14:04:26  ahundiak
 *      ah
 *
 *      Revision 1.4  2002/05/09 17:46:52  ahundiak
 *      ah
 *
 *      Revision 1.3  2002/05/06 20:52:51  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/10/19 18:20:55  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/13 19:48:52  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDss.h"

#include "VDdoom.h"
#include "VDtest.h"
#include "VDgeomc.h"
#include "VDtag.h"
#include "VDval.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvStaging.c");

extern IGRint VDat2ComparePcmksName       __((const void *v1, const void *v2));

void VDat2ValidateStagingTreeStages(TVDctxNodeList *listST);

/* ----------------------------------------------
 * First time called prints a header
 * Always updates the counter
 */
static void printHdr(IGRchar *path, IGRint *diff)
{
  if (*diff == 0) {
    VDlogPrintFmt(VDLOG_INFO,0,"");
    VDlogPrintFmt(VDLOG_INFO,0,"%-7s Stage %s","CHANGED",path);
  }
  *diff = *diff + 1;
  return;
}

/* ----------------------------------------------
 * Process a 3d Point
 */
static IGRstat process3D(TGRid   *node1ID,
                         TGRid   *node2ID,
                         IGRchar *path,
                         IGRchar *name,
                         IGRchar *prefix,
                         IGRint  *diff,
                         IGRchar *tolName,
                         IGRchar *units)
{
  IGRstat retFlag = 0;

  IGRdouble pt1[3],pt2[3];
  IGRdouble tol,delta;

  IGRchar namex[32],namey[32],namez[32];

  // Quick filter
  if (strncmp(name,prefix,strlen(prefix))) goto wrapup;

  // Build the names
  sprintf(namex,"%s_x",prefix);
  sprintf(namey,"%s_y",prefix);
  sprintf(namez,"%s_z",prefix);

  // Skip y and z
  if (!strcmp(name,namey)) {
    retFlag = 1;
    goto wrapup;
  }
  if (!strcmp(name,namez)) {
    retFlag = 1;
    goto wrapup;
  }
  if (strcmp(name,namex)) goto wrapup;
  retFlag = 1;

  // Center of gravity processing  
  VDctxGetDblAtr(node1ID,namex,&pt1[0]);
  VDctxGetDblAtr(node1ID,namey,&pt1[1]);
  VDctxGetDblAtr(node1ID,namez,&pt1[2]);
  VDctxGetDblAtr(node2ID,namex,&pt2[0]);
  VDctxGetDblAtr(node2ID,namey,&pt2[1]);
  VDctxGetDblAtr(node2ID,namez,&pt2[2]);

  VDgeom2GetDisPtPt(pt1,pt2,&delta);
  
  VDvalGetTolerance(tolName,&tol);
  if (delta < tol) goto wrapup;

  printHdr(path,diff);
  VDlogPrintFmt(VDLOG_INFO,0,
                "%7s %-11s %10.2f %10.2f %10.2f",
                "NEW",prefix,pt1[0],pt1[1],pt1[2]);

  VDlogPrintFmt(VDLOG_INFO,0,
                "%7s %-11s %10.2f %10.2f %10.2f",
                "OLD","",pt2[0],pt2[1],pt2[2]);
  VDlogPrintFmt(VDLOG_INFO,0,
                "%7s %-11s %10.2f %s",
                "DELTA","",delta,units);

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Try for a custom routine for comparing two attributes
 */
static void compareAttributes(TGRid   *node1ID,
                              TGRid   *node2ID,
                              IGRchar *path,
                              IGRchar *name,
                              IGRint  *diff)
{
  VDASSERT_FN("compareAttributes");

  IGRstat sts;

  IGRchar buf1[256];
  IGRchar buf2[256];
  IGRchar *p;

  IGRdouble pt1[3];
  IGRdouble pt2[3];
  IGRdouble dbl1,dbl2,delta;
  IGRdouble tol;

  // Filter a bit by name
  if (!strcmp(name,VDCTX_ATR_SS_BASE_INFO)) goto wrapup;
  //if (!strcmp(name,VDCTX_ATR_SS_COMP_PATH)) goto wrapup;
  if (!strcmp(name,VDCTX_ATR_SS_COMP_TAG))  goto wrapup;
  if (!strcmp(name,VDCTX_ATR_SS_SYMBOLOGY)) goto wrapup;

  // Center of gravity processing 
  sts = process3D(node1ID,node2ID,path,name,"cog",diff,VDTOL_MIN_COG_CHANGED,"mm");
  if (sts & 1) goto wrapup;

  // Reference processing 
  sts = process3D(node1ID,node2ID,path,name,"ref",diff,VDTOL_MIN_REF_CHANGED,"mm");
  if (sts & 1) goto wrapup;

  // Size processing 
  sts = process3D(node1ID,node2ID,path,name,"size",diff,VDTOL_MIN_SIZE_CHANGED,"mm3");
  if (sts & 1) goto wrapup;

  // Mass processing
  if (!strcmp(name,"mass")) {
    VDctxGetDblAtr(node1ID,"mass",&dbl1);
    VDctxGetDblAtr(node2ID,"mass",&dbl2);
    delta = fabs(dbl1 - dbl2);
    VDvalGetTolerance(VDTOL_MIN_MASS_CHANGED,&tol);
    if (delta < tol) goto wrapup;

    printHdr(path,diff);
    VDlogPrintFmt(VDLOG_INFO,0,
                  "%7s %-11s %10.2f",
                  "NEW","mass",dbl1);
    VDlogPrintFmt(VDLOG_INFO,0,
                  "%7s %-11s %10.2f",
                  "OLD","",    dbl2);
    VDlogPrintFmt(VDLOG_INFO,0,
                  "%7s %-11s %10.2f kgs",
                  "DELTA","",delta);
    goto wrapup;
  }
  
  // Need the values, don't care about truncation
  sts = VDctxGetTxtAtrBuf(node1ID,name,sizeof(buf1),buf1);
  if (!(sts & 1)) goto wrapup;
  sts = VDctxGetTxtAtrBuf(node2ID,name,sizeof(buf2),buf2);
  if (!(sts & 1)) goto wrapup;
 
  // Clean some number stuff
  p = strrchr(buf1,'.');
  if (p && !strcmp(p,".0")) *p = 0;
  p = strrchr(buf2,'.');
  if (p && !strcmp(p,".0")) *p = 0;
  
  if (!strncmp(buf1,"0.",2)) strcpy(buf1,buf1+1);
  if (!strncmp(buf2,"0.",2)) strcpy(buf2,buf2+1);

  if (!strncmp(buf1,"-0.",3)) strcpy(buf1+1,buf1+2);
  if (!strncmp(buf2,"-0.",3)) strcpy(buf2+1,buf2+2);

 // Simple string compare
  if (strcmp(buf1,buf2)) {
    printHdr(path,diff);
    VDlogPrintFmt(VDLOG_INFO,0,"%7s %-11s %s","NEW",name,buf1);
    VDlogPrintFmt(VDLOG_INFO,0,"%7s %-11s %s","OLD","",  buf2);
  }

wrapup:
  return;
}

/* ----------------------------------------------
 * This is what shows up in the report
 * Use the staging part and component name
 */
static void getReportPath(TGRid *nodeID, IGRchar *path)
{
  IGRchab name;

  // Start with staging path
  VDctxGetStagePath(nodeID,path);
 
  // Add any comp name
  VDctxGetCompName(nodeID,name);
  if (*name == 0) goto wrapup;

  strcat(path," ");
  strcat(path,name);

wrapup:
  return;
}

/* -------------------------------------------------
 * Report any difference between the two stages
 * node type and name already match
 */
void VDat2ReportStageChanges(TGRid *nodeNewID, TGRid *nodeOldID)
{
  VDASSERT_FN("VDat2ReportStageChanges");

  IGRstat sts;

  IGRint i,j,cnt;
  TVDfld *fld;
  TVDfld flds[64];
  
  IGRchab txt,path,pathx,type;
  
  IGRint diff = 0;
  IGRint typex;
  IGRint cmp;
  
  TGRid childOldID,childNewID;

  IGRchar buf1[256],buf2[256];

  // Arg check
  VDASSERTW(nodeNewID && nodeNewID->objid != NULL_OBJID);
  VDASSERTW(nodeOldID && nodeOldID->objid != NULL_OBJID);

  // List of attributes
  VDctxGetFldAtrs(  nodeNewID,&cnt,flds);
  getReportPath(nodeNewID,path);
  
  // Compare them
  for(i = 0; i < cnt; i++) {
    compareAttributes(nodeNewID,nodeOldID,path,flds[i].name,&diff);
  }
  
  // Cycle through and check for new kids
  for(i = 0; VDctxGetNthTreeChild(nodeNewID,i,&childNewID); i++) {
    
    // Ignore pieces
    VDctxGetStagingTreeNodeType(&childNewID,type,&typex);
    if (typex < 10) {

      // Find it
      cmp = 1;
      for(j = 0; (cmp) && (VDctxGetNthTreeChild(nodeOldID,j,&childOldID)); j++) {
	cmp = VDctxCompareStagingTreeNodeTypeName(&childNewID,&childOldID);
      }
      if (cmp) {

	// Not found
        printHdr(path,&diff);
	getReportPath(&childNewID,pathx);
	VDlogPrintFmt(VDLOG_INFO,0,"%7s Stage %s","ADD",pathx);
      } 
    }
  }
  
  // Cycle through and check for deleted kids
  for(i = 0; VDctxGetNthTreeChild(nodeOldID,i,&childOldID); i++) {
    
    // Ignore pieces
    VDctxGetStagingTreeNodeType(&childOldID,type,&typex);
    if (typex < 10) {

      // Find it
      cmp = 1;
      for(j = 0; (cmp) && (VDctxGetNthTreeChild(nodeNewID,j,&childNewID)); j++) {
	cmp = VDctxCompareStagingTreeNodeTypeName(&childOldID,&childNewID);
      }
      if (cmp) {

	// Not found
        printHdr(path,&diff);
	getReportPath(&childOldID,pathx);
	VDlogPrintFmt(VDLOG_INFO,0,"%7s Stage %s","DEL",pathx);
      } 
    }
  }
  
  // Done

 wrapup:
  return;
}

/* -------------------------------------------------
 * This was cloned from the original routine in vdat/pcmk2
 * Probably need to put it back in there and tweak the routine there to call
 * This guy?
 *
 * The input argument can control if the staging differences should be explored or not
 *
 * Question:  Do we check unstaged pieces here?  I suppose the flag could control
 * but I think we are really only inerested in staged items at this point
 */
void VDat2CompareStagingTrees(TGRid *treeNewID, TGRid *treeOldID, IGRint doStages)
{
  VDASSERT_FN("VDat2CompareStagingTrees");

  IGRint i;
  IGRint bs = 0;
 
  TVDctxNodeList listNew;
  TVDctxNodeList listOld;
  TVDctxNodeList listNewt; // Tags
  TVDctxNodeList listOldt; // Tags
   
  TGRid  *nodeNewID,*nodeOldID;
  TGRid   rootNewID, rootOldID;

  IGRchab pcmkNew,pcmkOld;
  IGRchab pathNew,pathOld;  
  IGRchab nameNew,nameOld;
  IGRchab unit,ts;
  
  TVDtagInfo tagInfo;
  
  // Init
  VDctxInitNodeList(&listNew);
  VDctxInitNodeList(&listOld);
  VDctxInitNodeList(&listNewt);
  VDctxInitNodeList(&listOldt);


  // First need to verify have staging trees at all
  VDctxGetStagingTreeRootNode(treeNewID,&rootNewID);
  VDASSERTW(rootNewID.objid != NULL_OBJID);
  VDctxGetStagingTreeRootNode(treeOldID,&rootOldID);
  VDASSERTW(rootOldID.objid != NULL_OBJID);

  // Get the pieces
  VDctxGetListPieces(&rootOldID,&listOld);
  if (listOld.cnt == 0) goto wrapup;
  VDctxGetListPieces(&rootNewID,&listNew);
  if (listNew.cnt == 0) goto wrapup;

  // Get the tags
  VDctxGetListPieces(&rootOldID,&listOldt);
  VDctxGetListPieces(&rootNewID,&listNewt);
  VDctxSortNodeList(&listOldt,VDctxCompareCompTag);  
  VDctxSortNodeList(&listNewt,VDctxCompareCompTag);  


  // Logs
  VDsysGetTimeStamp(ts);
  VDctxGetNodeName(&rootNewID,unit);
  VDlogPrintFmt(VDLOG_INFO,bs,"Comparision Report for Staging Tree Unit %s, %s",unit,ts);
  VDlogPrintFmt(VDLOG_INFO,bs,
		"The following parts have been modified and their pcmk's updated as follows:");

  // Keep these two fmts in sync
#define FMT1 "%-26s %-8d %-16s %-16s %4s %4s"
#define FMT2 "%-26s %-8s %-16s %-16s %4s %4s"

  VDlogPrintFmt(VDLOG_INFO,bs,FMT2,"","","","","Old","New");
  VDlogPrintFmt(VDLOG_INFO,bs,FMT2,"Part Name","Obj ID","Old Stage","New Stage","PCMK","PCMK");
  
  // Check for new items
  VDctxSortNodeList(&listOld,VDctxCompareCompPath);
  VDctxSortNodeList(&listNew,VDat2ComparePcmksName);
  for(i = 0; i < listNew.cnt; i++) {

    // Get em
    nodeNewID = &listNew.listIDs[i];
    nodeOldID = VDctxSearchNodeList(nodeNewID,&listOld,VDctxCompareCompPath);
    if (nodeOldID == NULL) {
      nodeOldID = VDctxSearchNodeList(nodeNewID,&listOldt,VDctxCompareCompTag);
    }
    // Is it new
    if (nodeOldID == NULL) {

	// Report it
	VDctxGetCompName   (nodeNewID, nameNew);
	VDctxGetCompTagInfo(nodeNewID,&tagInfo);
	VDctxGetPieceStage (nodeNewID, pathNew);	
	if (*pathNew == 0) strcpy(pathNew,"NOT STAGED");
	strcpy(pathOld,"NEW PIECE");
	
	VDctxGetPieceMark(nodeNewID,pcmkNew);

	VDlogPrintFmt(VDLOG_INFO,bs,FMT1,nameNew,tagInfo.id.objid,
		      pathOld,pathNew,"NEW",pcmkNew);		
    }
  }
  // Got here ok

  // Check for deleted snapshot items
  VDctxSortNodeList(&listOld,VDat2ComparePcmksName);
  VDctxSortNodeList(&listNew,VDctxCompareCompPath);
 
  // Cycle through
  for(i = 0; i < listOld.cnt; i++) {

    // Get em
    nodeOldID = &listOld.listIDs[i];
    nodeNewID = VDctxSearchNodeList(nodeOldID,&listNew,VDctxCompareCompPath);
    if (nodeNewID == NULL) {
      nodeNewID = VDctxSearchNodeList(nodeOldID,&listNewt,VDctxCompareCompTag);
    }
    if (nodeNewID == NULL) {
  
      // Report it
      VDctxGetCompName  (nodeOldID,nameOld);
      VDctxGetPieceStage(nodeOldID,pathOld);
      VDctxGetPieceMark (nodeOldID,pcmkOld);

      VDlogPrintFmt(VDLOG_INFO,bs,FMT2,nameOld,"DELETED",
		    pathOld,"DELETED",pcmkOld,"DEL");	

    }
  }
  // Got here ok
  
  // Check for modified items
  VDctxSortNodeList(&listOld,VDctxCompareCompPath);
  VDctxSortNodeList(&listNew,VDat2ComparePcmksName);
  for(i = 0; i < listNew.cnt; i++) {

    // Get em
    nodeNewID = &listNew.listIDs[i];
    nodeOldID = VDctxSearchNodeList(nodeNewID,&listOld,VDctxCompareCompPath);
    if (nodeOldID == NULL) {
      nodeOldID = VDctxSearchNodeList(nodeNewID,&listOldt,VDctxCompareCompTag);
    }

    // Is it new
    if (nodeOldID) {

      // See if piece mark has changed
      VDctxGetPieceMark(nodeNewID,pcmkNew);
      VDctxGetPieceMark(nodeOldID,pcmkOld);
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
  
  // Want to do stages as well?
  if (doStages == 0) goto wrapup;
  VDlogPrintFmt(VDLOG_INFO,bs,"");	

  // Grab lists of stages
  VDctxFreeNodeList(&listOld);
  VDctxFreeNodeList(&listNew);

  VDctxGetListStages(&rootOldID,&listOld);
  VDctxGetListStages(&rootNewID,&listNew);

  VDASSERTW(listOld.cnt);
  VDASSERTW(listNew.cnt);

  VDctxSortNodeList(&listOld,VDctxCompareStagingTreeNodeTypeName);
  VDctxSortNodeList(&listNew,VDctxCompareStagingTreeNodeTypeName);
  
  // Validate em
  VDat2ValidateStagingTreeStages(&listOld);
  VDat2ValidateStagingTreeStages(&listNew);

  // Check for new nodes
  for(i = 0; i < listNew.cnt; i++) {

    nodeNewID = &listNew.listIDs[i];
    nodeOldID = VDctxSearchNodeList(nodeNewID,&listOld,VDctxCompareStagingTreeNodeTypeName);

    if (nodeOldID == NULL) {
  
      // Report it
      getReportPath(nodeNewID,pathNew);      
      VDlogPrintFmt(VDLOG_INFO,bs,"%-7s Stage %s","ADDED",pathNew);
      
    }
  }

  // Check for deleted nodes
  for(i = 0; i < listOld.cnt; i++) {

    nodeOldID = &listOld.listIDs[i];
    nodeNewID = VDctxSearchNodeList(nodeOldID,&listNew,VDctxCompareStagingTreeNodeTypeName);

    if (nodeNewID == NULL) {
  
      // Report it
      getReportPath(nodeOldID,pathOld);      
      VDlogPrintFmt(VDLOG_INFO,bs,"%-7s Stage %s","DELETED",pathOld);
      
    }
  }

  // Check attributes of both stages and pieces
  VDctxFreeNodeList(&listOld);
  VDctxFreeNodeList(&listNew);

  VDctxGetNodeListByType(&rootOldID,"*",&listOld);
  VDctxGetNodeListByType(&rootNewID,"*",&listNew);

  VDASSERTW(listOld.cnt);
  VDASSERTW(listNew.cnt);

  VDctxSortNodeList(&listOld,VDctxCompareStagingTreeNodeTypeName);
  VDctxSortNodeList(&listNew,VDctxCompareStagingTreeNodeTypeName);
 
  // Check for modified nodes
  for(i = 0; i < listNew.cnt; i++) {

    nodeNewID = &listNew.listIDs[i];
    nodeOldID = VDctxSearchNodeList(nodeNewID,&listOld,VDctxCompareStagingTreeNodeTypeName);
    if (!nodeOldID) {
      nodeOldID = VDctxSearchNodeList(nodeNewID,&listOldt,VDctxCompareCompTag);
    }
    if (nodeOldID) {
  
      // Report it
      VDat2ReportStageChanges(nodeNewID,nodeOldID);      
    }
  }
    
  // Done
 wrapup:

  VDctxFreeNodeList(&listOld);
  VDctxFreeNodeList(&listNew);
  VDctxFreeNodeList(&listOldt);
  VDctxFreeNodeList(&listNewt);
   
  return;
}

/* -----------------------------------------------
 * Validate a sorted list of stages from a staging tree
 */
void VDat2ValidateStagingTreeStages(TVDctxNodeList *listST)
{
  VDASSERT_FN("VDat2ValidateStagingTreeStages");
  
  IGRint i;
  TGRid *node1ID;
  TGRid *node2ID;
  
  TVDctxBaseInfo baseInfo;

  IGRint cmp;
  
  // Arg check
  VDASSERTW(listST && listST->cnt);

  // Cycle through for dups
  node1ID = &listST->listIDs[0];    
  for(i = 1; i < listST->cnt; i++) {

    node2ID = &listST->listIDs[i];    

    // Look for dups
    cmp = VDctxCompareStagingTreeNodeTypeName(node1ID,node2ID);
    if (cmp == 0) {
      VDctxGetBaseInfo(node1ID,&baseInfo);
      VDlogPrintFmt(VDLOG_ERROR,1,
		    "*** Duplicate staging tree nodes %s %s",
		    baseInfo.nodeType,baseInfo.nodeName);
    }
    node1ID = node2ID;
  }

  // Cycle through for kids
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Wrapper for comparing two trees from review command
 */
void VDrrvCompareStagingTrees(TGRid *treeNewID, TGRid *treeOldID)
{
  VDASSERT_FN("VDrrvCompareStagingTrees");
  
  IGRint logging = 0;
  
  TGRid rootNewID,rootOldID;
  
  // Ok if we dont have trees
  VDctxGetStagingTreeRootNode(treeNewID,&rootNewID);
  if (rootNewID.objid == NULL_OBJID) goto wrapup;  
  VDctxGetStagingTreeRootNode(treeOldID,&rootOldID);
  if (rootOldID.objid == NULL_OBJID) goto wrapup;
  
  // Logging
  logging = 1;
  VDlogOpenCat("staging_tree.rpt");
  

  // Do it
  VDat2CompareStagingTrees(&rootNewID,&rootOldID,1);
  
 wrapup:
  if (logging) {  
    VDlogCloseCat("staging_tree.rpt");
    VDlogShowCat ("staging_tree.rpt");
  }

  return;
}
