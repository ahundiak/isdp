/* $Id: VDrrvDooms.c,v 1.17 2002/06/07 20:14:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvCreate.C
 *
 * Description: Review Dooms Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvDooms.c,v $
 *      Revision 1.17  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.16  2002/06/04 14:04:25  ahundiak
 *      ah
 *
 *      Revision 1.15  2002/05/17 15:22:33  ahundiak
 *      ah
 *
 *      Revision 1.14  2002/05/06 20:52:51  ahundiak
 *      ah
 *
 *      Revision 1.13  2002/05/02 15:58:09  ahundiak
 *      ah
 *
 *      Revision 1.12  2002/03/14 22:16:05  ylong
 *      Check bevels, pens and pcgs
 *
 *      Revision 1.11  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/11/21 22:11:40  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/10/19 18:20:55  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/04/13 19:48:52  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/03/13 00:19:32  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/03/11 18:39:42  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/09 22:13:07  ahundiak
 *      *** empty log message ***
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDxml.h"

#include "VDctx.h"
#include "VDval.h"
#include "VDss.h"

#include "VDdoom.h"
#include "VDtest.h"
#include "VDtag.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvDooms.c");

/* ------------------------------------------------
 * Get the values of two attributes from two
 * different nodes with a bit of standard processing
 * thrown in
 */
IGRstat VDrrvGetTwoAttributes(TGRid   *node1ID,
                              TGRid   *node2ID,
                              IGRchar *name,
                              IGRint   len,
                              IGRchar *buf1,
                              IGRchar *buf2)
{
  VDASSERT_FN("VDrrvGetTwoAttributes");

  IGRstat retFlag = 0;
  IGRstat truncFlag = 0;
  IGRstat sts;
  IGRchar *p,*p1,*p2;

  // Arg check
  VDASSERTW(buf1); *buf1 = 0;
  VDASSERTW(buf2); *buf2 = 0;
  VDASSERTW(len);

  // Certain ones get ignored
  if (!strcmp(name,VDCTX_ATR_SS_BASE_INFO)) goto wrapup;
  //if (!strcmp(name,VDCTX_ATR_SS_COMP_PATH)) goto wrapup;
  if (!strcmp(name,VDCTX_ATR_SS_COMP_TAG))  goto wrapup;
  if (!strcmp(name,VDCTX_ATR_SS_SYMBOLOGY)) goto wrapup;

  // Get the values
  sts = VDctxGetTxtAtrBuf(node1ID,name,len,buf1);
  if (sts == 0) goto wrapup;
  if (sts == 3) truncFlag = 1;

  sts = VDctxGetTxtAtrBuf(node2ID,name,len,buf2);
  if (sts == 0) {
    *buf1 = 0;
    goto wrapup;
  }
  if (sts == 3) truncFlag = 1;

  // Little hack to take care of some format differences
  p = strrchr(buf1,'.');
  if (p && !strcmp(p,".0")) *p = 0;
  p = strrchr(buf2,'.');
  if (p && !strcmp(p,".0")) *p = 0;
  
  if (!strncmp(buf1,"0.",2)) strcpy(buf1,buf1+1);
  if (!strncmp(buf2,"0.",2)) strcpy(buf2,buf2+1);

  if (!strncmp(buf1,"-0.",3)) strcpy(buf1+1,buf1+2);
  if (!strncmp(buf2,"-0.",3)) strcpy(buf2+1,buf2+2);

  // Special case
  if (!strcmp(name,VDCTX_STD_PCMK_ATR_GEOM_KEY)) {

    // Ignore if either is blank
    if (*buf1 == 0) *buf2 = 0;
    if (*buf2 == 0) *buf1 = 0;
    if (*buf1 && *buf2) {

      // There are two different formats
      // The new one has a colon
      // Don't try to compare the two
      p1 = strchr(buf1,':');
      p2 = strchr(buf2,':');
      if ((p1 && !p2) || (!p1 && p2)) {
        *buf1 = 0;
        *buf2 = 0;
      }
    }
  }
  retFlag = 1;

wrapup:
  if (retFlag) {
    if (truncFlag) retFlag = 3;
  }
  return retFlag;
}
 
/* ------------------------------------------------
 * Compare two attributes
 */
void VDrrvCompareTwoPieceAttributes(TGRid   *node1ID,
				    TGRid   *node2ID,
                                    IGRchar *name,
				    TGRid   *diffsID,
				    TGRid   *diffID)
{
  VDASSERT_FN("VDrrvCompareTwoPieceAttributes");

  IGRstat sts;

  IGRint i;

  IGRdouble pt1[3],pt2[3];
  IGRdouble dbl1,dbl2;
  IGRdouble delta,tol;
  
  IGRchar buf[256];

  IGRchab buf1,buf2;
  IGRchar *p;

  // Arg check
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);

  // Get the attributes
  sts = VDrrvGetTwoAttributes(node1ID,node2ID,name,sizeof(buf1),buf1,buf2);
  if (sts == 0) goto wrapup;

  // Does the center hold?
  if (!strcmp(name,VDCTX_ATR_SS_PLATE_CENTER) ||
      !strcmp(name,VDCTX_ATR_SS_BEAM_CENTER)) {

    // Check distance moved
    for(i = 0; i < 3; i++) {
      pt1[i] = atof(buf1);
      pt2[i] = atof(buf2);
      p = strchr(buf1,','); if (p) strcpy(buf1,p+1);
      p = strchr(buf2,','); if (p) strcpy(buf2,p+1);
    }
    VDgeom2GetDisPtPt(pt1,pt2,&delta);
    VDvalGetTolerance(VDTOL_MIN_COG_CHANGED,&tol);
    if (delta >= tol) {

      // If needed
      VDrrvCreateSpecialDiff(node1ID,node2ID,diffsID,diffID);

      snprintf(buf,sizeof(buf),
        "Changed from  %.1f,%.1f,%.1f\n"
        "        to    %.1f,%.1f,%.1f\n"
        "        delta %.1f mm",
	pt1[0],pt1[1],pt1[2],pt2[0],pt2[1],pt2[2],delta);

      VDctxAppTxtAtr(diffID,name,buf);
    }
    goto wrapup;
  }
  if (!strcmp(name,VDCTX_ATR_SS_PLATE_AREA) ||
      !strcmp(name,VDCTX_ATR_SS_BEAM_AREA)) {

    dbl1 = atof(buf1);
    dbl2 = atof(buf2);
    delta = fabs(dbl1 - dbl2);

    VDvalGetTolerance(VDTOL_MIN_AREA_CHANGED,&tol);
    if (fabs(delta) > tol) {

      // If needed
      VDrrvCreateSpecialDiff(node1ID,node2ID,diffsID,diffID);

      snprintf(buf,sizeof(buf),
              "Changed from %s to %s delta %.0f",
               buf1,buf2,delta);
      VDctxAppTxtAtr(diffID,name,buf);
    }
    
    goto wrapup;
  }
  if (!strcmp(name,VDCTX_ATR_SS_BEAM_CUT_LENGTH)) {

    dbl1 = atof(buf1);
    dbl2 = atof(buf2);
    delta = fabs(dbl1 - dbl2);

    VDvalGetTolerance(VDTOL_MIN_LEN_CHANGED,&tol);
    if (fabs(delta) > tol) {

      // If needed
      VDrrvCreateSpecialDiff(node1ID,node2ID,diffsID,diffID);

      snprintf(buf,sizeof(buf),
              "Changed from %s to %s delta %.0f",
               buf1,buf2,delta);
      VDctxAppTxtAtr(diffID,name,buf);
    }
    
    goto wrapup;
  }
   
  // Generic processor
  if (strcmp(buf1,buf2)) {

    
    // If needed
    VDrrvCreateSpecialDiff(node1ID,node2ID,diffsID,diffID);

    /* ------------------------------------------
     * This really needs some enhancements, the only
     * way the info is retrieved is through the fld processor
     * which limits things to 80 characters
     *
     * 06 May 2002 Think the length issues have now been delt with
     */
    if ((strlen(buf1) > 20) || (strlen(buf2) > 20)) 
    {
      snprintf(buf,sizeof(buf),"Changed\nfrom %s\nto   %s\n",buf2,buf1);
    }
    else 
    {
      snprintf(buf,sizeof(buf),"Changed from %s to %s\n",buf2,buf1);
    }
    VDctxAppTxtAtr(diffID,name,buf);
  }
   
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Got two nodes from two different trees whose component path
 * matches, do an in depth comparision
 */
void VDrrvCompareTwoPieceNodes(TGRid *diffsID,
			       TGRid *node1ID,
			       TGRid *node2ID,
			       TGRid *diffID)
{
  VDASSERT_FN("VDrrvCompareTwoPieceNodes");

  struct 
  {
    IGRchab path;
    TVDtag  tag;
    IGRint  cnt;
    TVDfld  flds[64];
  } info1,info2;
  
  IGRint i;
  
  // Make sure have nodes
  VDASSERTW(diffID); diffID->objid = NULL_OBJID;
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);

  // Just for grins, make sure comp_path matches
#if 0
  VDctxGetCompPath(node1ID,info1.path);
  VDctxGetCompPath(node2ID,info2.path);
  VDASSERTW(*info1.path && *info2.path && !strcmp(info1.path,info2.path));
#endif

  // Get the tags
  VDctxGetCompTag(node1ID,&info1.tag);
  VDctxGetCompTag(node2ID,&info2.tag);
  if (info1.tag.num != info2.tag.num) {

    VDrrvCreateDiffNode(diffsID,node1ID,node2ID,3,"Tag number changed",diffID);
    VDASSERTW(diffID->objid != NULL_OBJID);
    
  }
  else {  
    if (info1.tag.ver != info2.tag.ver) {

      VDrrvCreateDiffNode(diffsID,node1ID,node2ID,4,"Same tag number, different version",diffID);      
      VDASSERTW(diffID->objid != NULL_OBJID);

    }
  }
  
  // Get the attributes
  VDctxGetFldAtrs(node1ID,&info1.cnt,info1.flds);
  VDctxGetFldAtrs(node2ID,&info2.cnt,info2.flds);

  // Bounce em
  for(i = 0; i < info1.cnt; i++) {
    VDrrvCompareTwoPieceAttributes(node1ID,node2ID,
				   info1.flds[i].name,
				   diffsID,diffID);
  }
  
  // Done
 wrapup:
  return;
}


/* -----------------------------------------------
 * Given two dom trees, compare them
 * Make the assumption that tree1 is the newer tree?
 */
void VDrrvCompareTwoPieceTrees(TGRid *tree1ID, TGRid *tree2ID, TGRid *diffsID)
{
  VDASSERT_FN("VDrrvCompareTwoPieceTrees");

  IGRint stopWalk = 0;

  TGRid  *findID;
  TGRid *foundID;

  TGRid diffID;
  
  struct 
  {
    IGRint newCnt;
    IGRint delCnt;
    IGRint modCnt;
  } sum;
  
  TVDctxNodeList l1,l2;
  TVDctxNodeList t1,t2; // Tag lists
  TVDctxBaseInfo baseInfo1,baseInfo2;
  
  // Init
  VDctxInitNodeList(&l1);
  VDctxInitNodeList(&l2);
  VDctxInitNodeList(&t1);
  VDctxInitNodeList(&t2);
  memset(&sum,0,sizeof(sum));
  
  // Arg check
  VDASSERTW(diffsID && diffsID->objid != NULL_OBJID);
  VDASSERTW(tree1ID && tree1ID->objid != NULL_OBJID);
  VDASSERTW(tree2ID && tree2ID->objid != NULL_OBJID);

  // For reporting
  VDctxGetBaseInfo(tree1ID,&baseInfo1);
  VDctxGetBaseInfo(tree2ID,&baseInfo2);
  VDASSERTW(baseInfo1.treeType);
  VDASSERTW(baseInfo2.treeType);
  
  // Grab the piecess
  VDrrvGetListOM_Pieces(tree1ID,1,&l1);
  VDrrvGetListOM_Pieces(tree2ID,1,&l2);

  // Ok if either has no pieces
  if (l1.cnt == 0) goto wrapup;
  if (l2.cnt == 0) goto wrapup;

  // Grab the tags
  VDrrvGetListOM_Pieces(tree1ID,1,&t1);
  VDrrvGetListOM_Pieces(tree2ID,1,&t2);
  VDctxSortNodeList(&t1,VDctxCompareCompTag);
  VDctxSortNodeList(&t2,VDctxCompareCompTag);
   
  // Report
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Piece Tree 1 %s %s, Count %4d",
		baseInfo1.treeType,baseInfo1.treeName,l1.cnt);

  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"        Piece Tree 2 %s %s, Count %4d",
		baseInfo2.treeType,baseInfo2.treeName,l2.cnt);
  
  // Check for items in 1 but not in 2
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    findID  = &l1.listIDs[l1.i];
    foundID = VDctxSearchNodeList(findID,&l2,VDctxCompareNodeTypeCompPath);
    if (foundID == NULL) {
      foundID = VDctxSearchNodeList(findID,&t2,VDctxCompareCompTag);
      if (foundID == NULL) {
        VDrrvCreateDiffNode(diffsID,findID,NULL,1,"New Piece",&diffID);      
        //VDlogPrintObject(VDLOG_INFO,traceFlag,"New Piece ",NULL,findID);
        sum.newCnt++;
      }
    }
  }

  // Check for items in 2 but not in 1
  for(l2.i = 0; l2.i < l2.cnt; l2.i++) {

    findID  = &l2.listIDs[l2.i];
    foundID = VDctxSearchNodeList(findID,&l1,VDctxCompareNodeTypeCompPath);
    if (foundID == NULL) {
      foundID = VDctxSearchNodeList(findID,&t1,VDctxCompareCompTag);
      if (foundID == NULL) {
        VDrrvCreateDiffNode(diffsID,NULL,findID,2,"Deleted Piece",&diffID);
        //VDlogPrintObject(VDLOG_INFO,traceFlag,"Deleted Piece ",NULL,findID);      
        sum.delCnt++;
      }
    }    
  }

  // Check for items in both
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    findID  = &l1.listIDs[l1.i];
    foundID = VDctxSearchNodeList(findID,&l2,VDctxCompareNodeTypeCompPath);
    if (foundID == NULL) {
      foundID = VDctxSearchNodeList(findID,&t2,VDctxCompareCompTag);
    }      
    if (foundID) {
      VDrrvCompareTwoPieceNodes(diffsID,findID,foundID,&diffID);
      if (diffID.objid != NULL_OBJID) sum.modCnt++;
    }
  }

  // Done
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Summary, New Pieces %d, Deleted Pieces %d, 'Modified' Pieces %d",
		sum.newCnt,sum.delCnt,sum.modCnt);      

  // Stand alone for staging tree
  VDrrvCompareStagingTrees(tree1ID,tree2ID);
  
 wrapup:

  VDctxFreeNodeList(&l1);
  VDctxFreeNodeList(&l2);
  VDctxFreeNodeList(&t1);
  VDctxFreeNodeList(&t2);
   
  return;
}

/* -----------------------------------------------
 * Given two dom trees, compare them
 * Make the assumption that tree1 is the newer tree?
 */
void VDrrvCompareTwoTrees(TGRid *tree1ID, TGRid *tree2ID, TGRid *diffsID)
{
  VDASSERT_FN("VDrrvCompareTwoTrees");
  
  TVDrrvDiffInfo info;

  // Arg check
  VDASSERTW(diffsID);  diffsID->objid  = NULL_OBJID;
  VDASSERTW(tree1ID && tree1ID->objid != NULL_OBJID);
  VDASSERTW(tree2ID && tree2ID->objid != NULL_OBJID);

  // init and create diff tree
  VDrrvInitDiffInfo(tree1ID,tree2ID,&info);
  *diffsID = info.diffIDs;

  // Check pieces
  VDrrvCompareTwoPieceTrees(tree1ID,tree2ID,diffsID);
  
  // Check Equipment
  VDrrvCompareTwoEqpTrees(&info);
  
  // Check Components
  VDrrvCompareTwoCompTrees(&info);
  
  // Check bevel
  VDrrvCompareTwoBevelTrees(tree1ID,tree2ID,diffsID);

  // Check penetration (pen)
  VDrrvCompareTwoPenTrees(&info);
  
  // Check penetration control (pcg)
  VDrrvCompareTwoPcgTrees(&info);
  
 wrapup:
  
  return;
}

/* -----------------------------------------------
 * Automated testing
 * Compare the first two snapshots
 */
void VDtestCompareSnapshots(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestCompareSnapshots");

  TGRid doom1ID;
  TGRid doom2ID;
  TGRid tree1ID;
  TGRid tree2ID;
  TGRid diffsID;
  
  IGRint doomCnt;
  
  // Init
  tree1ID.objid == NULL_OBJID;
  tree2ID.objid == NULL_OBJID;
  diffsID.objid == NULL_OBJID;
#if 0
  // Init Test
  memset(&testData,0,sizeof(TtestData));
  testInfo->data = &testData;
  s_testData     = &testData;
  
  switch(testInfo->testNum) {
    case 1:
      testData.doomCnt   = 2;
      testData.pieceCnt1 = 4;
      testData.pieceCnt2 = 6;
      break;      
  }
  
  // Get the dooms and the trees
  VDdoomGetCnt(&doomCnt);
  VDASSERTW(doomCnt == testData.doomCnt);

  VDdoomGetNthObject(0,&doom1ID);
  VDASSERTW(doom1ID.objid != NULL_OBJID);

  VDdoomGetNthObject(1,&doom2ID);
  VDASSERTW(doom2ID.objid != NULL_OBJID);

  VDdoomCreateTree(&doom1ID, 0, &tree1ID);
  VDASSERTW(tree1ID.objid != NULL_OBJID);

  VDdoomCreateTree(&doom2ID, 0, &tree2ID);
  VDASSERTW(tree2ID.objid != NULL_OBJID);

  // Compare
  VDrrvCompareTwoTrees(&tree1ID,&tree2ID,&diffsID);
  VDASSERTW(diffsID.objid != NULL_OBJID);
  VDctxPrintLog(&diffsID,VDLOG_ERROR,1);
#endif

  // Done
  testInfo->worked = 1;
  
 wrapup:
  
  VDctxDeleteNode(&tree1ID);
  VDctxDeleteNode(&tree2ID);
  VDctxDeleteNode(&diffsID);
  return;
}

/* -----------------------------------------------
 * Automated testing
 */
void VDtestListSnapshots(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestListSnapshots");
  IGRstat retFlag = 0;

  TGRid  doomID;
  IGRint i;
  
  TGRid treeID;
  TGRid rootID;
  
  TVDctxBaseInfo baseInfo;

  IGRchab buf;
  IGRchab ts;
  IGRchab purpose;
  
  // Cycle through
  for(i = 0; VDdoomGetNthObject(i,&doomID); i++) {

    // Get the root node
    VDdoomCreateTree(&doomID, 1, &rootID);
    VDASSERTW(rootID.objid != NULL_OBJID);
  
    // Grab some info
    VDctxGetBaseInfo(&rootID,&baseInfo);
    VDASSERTW(*baseInfo.treeType);

    VDctxGetTxtAtr(&rootID,VDCTX_ATR_CREATION_TIMESTAMP,ts);
    VDctxGetTxtAtr(&rootID,VDCTX_ATR_SS_PURPOSE,        purpose);
    
    // Display it
    printf("%2u %s %s %s %s\n",i,baseInfo.treeType,baseInfo.treeName,ts,purpose);

    // Get the full tree
    VDdoomCreateTree(&doomID, 0, &treeID);
    VDASSERTW(treeID.objid != NULL_OBJID);
    if (testInfo->testNum == 2) {  
      VDctxPrintLog(&treeID,VDLOG_ERROR,1);
    }
    
    // Free
    VDctxDeleteNode(&rootID);
    VDctxDeleteNode(&treeID);
    
  }
  
  // Done
  testInfo->worked = 1;
    
 wrapup:
  
  return;
}


