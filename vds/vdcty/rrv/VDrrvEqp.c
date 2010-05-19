/* $Id: VDrrvEqp.c,v 1.4 2002/06/07 20:14:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvEqp.c
 *
 * Description: Compare Equipment Trees
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvEqp.c,v $
 *      Revision 1.4  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.3  2002/06/04 14:04:25  ahundiak
 *      ah
 *
 *      Revision 1.2  2002/05/17 15:22:33  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/27/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDxml.h"

#include "VDctx.h"
#include "VDss.h"

#include "VDdoom.h"
#include "VDtest.h"
#include "VDtag.h"

#include "VDgeomc.h"
#include "VDval.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvEqp.c");

/* ------------------------------------------------
 * Compare two attributes
 */
static void compareTwoEqpAttributes(TVDrrvDiffInfo *info,
                                    TGRid   *node1ID,
                                    TGRid   *node2ID,
                                    IGRchar *name)
{
  VDASSERT_FN("compareTwoEqpAttributes");

  IGRstat sts;

  IGRdouble dbl1,dbl2;
  IGRdouble delta;
  
  IGRchar buf[256];
  IGRchab buf1,buf2;
  IGRchar *p;

  // Get the attributes
  sts = VDrrvGetTwoAttributes(node1ID,node2ID,name,sizeof(buf1),buf1,buf2);
  if (sts == 0) goto wrapup;
  
  // Generic processor
  if (strcmp(buf1,buf2)) {
  
    // If needed
    if ((strlen(buf1) > 20) || (strlen(buf2) > 20)) 
    {
      snprintf(buf,sizeof(buf),"Changed\nfrom %s\nto   %s\n",buf2,buf1);
    }
    else 
    {
      snprintf(buf,sizeof(buf),"Changed from %s to %s\n",buf2,buf1);
    }
    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,name,buf);
  }
   
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Compare the attributes of the two nodes
 */
static void compareTwoEqpNodesAttributes(TVDrrvDiffInfo *info,
                                         TGRid *node1ID,
                                         TGRid *node2ID)
{
  VDASSERT_FN("compareTwoEqpNodesAttributes");

  IGRint  cnt,i;
  TVDfld  flds[64];
  
  // Get the attribute names
  VDctxGetFldAtrs(node1ID,&cnt,flds);

  // Bounce em
  for(i = 0; i < cnt; i++) {
    compareTwoEqpAttributes(info,node1ID,node2ID,flds[i].name);
  }

 wrapup:
  return;
}

/* -----------------------------------------------
 * Compare two cs
 * Actually, they don't have to be real cs nodes
 * It operates on nodes with an attribute called "matrix"
 */
void VDrrvCompareTwoCsNodes(TVDrrvDiffInfo *info,
                            TGRid *node1ID,
                            TGRid *node2ID)
{
  VDASSERT_FN("VDrrvCompareTwoCsNodes");

  IGRdouble mat1[16];
  IGRdouble mat2[16];
  IGRint cnt;
  IGRchar *p;
  
  IGRdouble tol;
  IGRdouble dis;
  
  IGRpoint pt1,pt2;
  
  IGRchar buf[256];

  // Verify we have cs's
  if (node1ID->objid == NULL_OBJID) goto wrapup;
  if (node2ID->objid == NULL_OBJID) goto wrapup;

  // Translate the matrix
  VDctxGetTxtAtrPtr(node1ID,"matrix",&p);
  if (p == NULL) goto wrapup;
  VDvalConvertTextToDoubles(p,&cnt,mat1);
  if (cnt != 16) goto wrapup;

  VDctxGetTxtAtrPtr(node2ID,"matrix",&p);
  if (p == NULL) goto wrapup;
  VDvalConvertTextToDoubles(p,&cnt,mat2);
  if (cnt != 16) goto wrapup;

  // Check for translation
  pt1[0] = mat1[ 3]; pt2[0] = mat2[ 3];
  pt1[1] = mat1[ 7]; pt2[1] = mat2[ 7];
  pt1[2] = mat1[11]; pt2[2] = mat2[11];
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_MIN_ORG_CHANGED,&tol);
  if (dis > tol) {

    sprintf(buf,"Moved %.1f mm\'s",dis);

    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,"origin",buf);
  }

  // Rotation has it's own tolerance
  VDvalGetTolerance(VDTOL_MIN_ROT_CHANGED,&tol);
   
  // X - Rotation
  pt1[0] = mat1[ 0]; pt2[0] = mat2[ 0];
  pt1[1] = mat1[ 1]; pt2[1] = mat2[ 1];
  pt1[2] = mat1[ 2]; pt2[2] = mat2[ 2];
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  if (dis > tol) {

    sprintf(buf,"X Rotation Changed");

    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,"rot_x",buf);
  }
  // Y - Rotation
  pt1[0] = mat1[ 4]; pt2[0] = mat2[ 4];
  pt1[1] = mat1[ 5]; pt2[1] = mat2[ 5];
  pt1[2] = mat1[ 6]; pt2[2] = mat2[ 6];
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  if (dis > tol) {

    sprintf(buf,"Y Rotation Changed");

    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,"rot_y",buf);
  }
  // Z - Rotation
  pt1[0] = mat1[ 8]; pt2[0] = mat2[ 8];
  pt1[1] = mat1[ 9]; pt2[1] = mat2[ 9];
  pt1[2] = mat1[10]; pt2[2] = mat2[10];
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  if (dis > tol) {

    sprintf(buf,"Z Rotation Changed");

    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,"rot_z",buf);
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Got two nodes from two different trees whose component path
 * matches, do an in depth comparision
 */
void VDrrvCompareTwoEqpNodes(TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvCompareTwoEqpNodes");
  
  TGRid child1ID,child2ID;
  
  IGRint i;
  
  TGRid *node1ID;
  TGRid *node2ID;

  // Make sure have nodes
  VDASSERTW(info);
  node1ID = info->node1ID;
  node2ID = info->node2ID;

  // Do the attributes
  compareTwoEqpNodesAttributes(info,node1ID,node2ID);

  // Checkthe child collectors, assume they are in order for now
  for(i = 0; VDctxGetNthTreeChild(node1ID,i,&child1ID); i++) {

    if (VDctxIsNodeType(&child1ID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR)) {

      VDctxGetNthTreeChild(node2ID,i,&child2ID);
      if ((child2ID.objid != NULL_OBJID) && 
	  VDctxIsNodeType(&child2ID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR)) {

	compareTwoEqpNodesAttributes(info,&child1ID,&child2ID);
      }
    }
  }

  // Check the cs
  VDctxGetChildNodeByType(node1ID,VDCTX_NODE_TYPE_SS_OM_CS,&child1ID);
  VDctxGetChildNodeByType(node2ID,VDCTX_NODE_TYPE_SS_OM_CS,&child2ID);
  VDrrvCompareTwoCsNodes(info,&child1ID,&child2ID);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given two dom eqp trees, compare them
 * Make the assumption that tree1 is the newer tree?
 */
void VDrrvCompareTwoEqpTrees(TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvCompareTwoEqpTrees");
  
  struct 
  {
    IGRint newCnt;
    IGRint delCnt;
    IGRint modCnt;
  } sum;
  
  TVDctxNodeList l1,l2;
  TVDctxNodeList t1,t2;
  TVDctxBaseInfo baseInfo1,baseInfo2;
  
  // Init
  VDctxInitNodeList(&l1);
  VDctxInitNodeList(&l2);
  VDctxInitNodeList(&t1);
  VDctxInitNodeList(&t2);
  memset(&sum,0,sizeof(sum));

  // Arg check
  VDASSERTW(info);

  // For reporting
  VDctxGetBaseInfo(info->tree1ID,&baseInfo1);
  VDctxGetBaseInfo(info->tree2ID,&baseInfo2);
  VDASSERTW(baseInfo1.treeType);
  VDASSERTW(baseInfo1.treeType);
  
  // Grab the piecess
  VDctxGetNodeListByType(info->tree1ID,VDCTX_NODE_TYPE_SS_OM_EQP,&l1);
  VDctxGetNodeListByType(info->tree2ID,VDCTX_NODE_TYPE_SS_OM_EQP,&l2);
  
  // Ok if either has no pieces
  if (l1.cnt == 0) goto wrapup;
  if (l2.cnt == 0) goto wrapup;

  // Sort em
  VDctxSortNodeList(&l1,VDctxCompareNodeTypeCompPath);
  VDctxSortNodeList(&l2,VDctxCompareNodeTypeCompPath);
  
  // Use tags if name has changed
  VDctxGetNodeListByType(info->tree1ID,VDCTX_NODE_TYPE_SS_OM_EQP,&t1);
  VDctxGetNodeListByType(info->tree2ID,VDCTX_NODE_TYPE_SS_OM_EQP,&t2);
  VDctxSortNodeList(&t1,VDctxCompareCompTag);
  VDctxSortNodeList(&t2,VDctxCompareCompTag);

  // Report
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Eqpt Tree 1 %s %s, Count %4d",
		baseInfo1.treeType,baseInfo1.treeName,l1.cnt);

  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"        Eqpt Tree 2 %s %s, Count %4d",
		baseInfo2.treeType,baseInfo2.treeName,l2.cnt);
  
  // Check for items in 1 but not in 2
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    info->node1ID = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareNodeTypeCompPath);
    if (!info->node2ID) {
      info->node2ID = VDctxSearchNodeList(info->node1ID,&t2,VDctxCompareCompTag);
    }
    if (!info->node2ID) {
      VDrrvInitDiffNode(0,info);
      sum.newCnt++;
    }
  }

  // Check for items in 2 but not in 1
  for(l2.i = 0; l2.i < l2.cnt; l2.i++) {

    info->node2ID = &l2.listIDs[l2.i];
    info->node1ID = VDctxSearchNodeList(info->node2ID,&l1,VDctxCompareNodeTypeCompPath);
    if (!info->node1ID) {
      info->node1ID = VDctxSearchNodeList(info->node2ID,&t1,VDctxCompareCompTag);
    }
    if (!info->node1ID) {
      VDrrvInitDiffNode(0,info);    
      sum.delCnt++;
    }    
  }

  // Check for items in both
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    info->node1ID = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareNodeTypeCompPath);
    if (!info->node2ID) {
      info->node2ID = VDctxSearchNodeList(info->node1ID,&t2,VDctxCompareCompTag);
    }
    if (info->node2ID) {
      VDrrvInitDiffNode(0,info);    
      VDrrvCompareTwoEqpNodes(info);
      if (info->diffID.objid != NULL_OBJID) sum.modCnt++;
    }
  }

  // Done
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Summary, New Eqpt %d, Deleted Eqpt %d, 'Modified' Eqpt %d",
		sum.newCnt,sum.delCnt,sum.modCnt);      
  
 wrapup:

  VDctxFreeNodeList(&l1);
  VDctxFreeNodeList(&l2);
  VDctxFreeNodeList(&t1);
  VDctxFreeNodeList(&t2);
   
  return;
}

/* -----------------------------------------------
 * Create a tree of all equipment
 */
void VDrrvAddEqps(VDosnum osnum,TGRid *treeID)
{
  VDASSERT_FN("VDrrvAddEqps");
  
  IGRint  cnt;
  IGRchab key;
  IGRchab fileName;

  TGRid    *listIDs = NULL;
  TGRid      eqpID;
  TGRobj_env eqpOE;
  IGRint i;
  
  TGRid nodeID;
  TGRid rootID;

  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Validate the os by getting the fileName
  VDosGetFileName(osnum,fileName);
  VDASSERTW(*fileName);
  
  // Get list of pieces
  VDobjGetEqps(osnum,&cnt,&listIDs);
  if (cnt) VDASSERTW(listIDs);

  VDlogPrintFmt(VDLOG_INFO,0,
		"File %s, Found %d equipment.",
		fileName,cnt);
   
  // Build the tree
  VDctxCreateNode(treeID,VDCTX_NODE_TYPE_SS_OM_EQPS,NULL,&rootID);
  VDASSERTW(rootID.objid != NULL_OBJID);
  
  // Cycle through
  for(i = 0; i < cnt; i++) {
    eqpID = listIDs[i];
    eqpOE.obj_id = eqpID;
    VDobjResetOE(&eqpOE);

    // Create the node
    VDvalConvertEqpToDom(&eqpOE,&rootID,&nodeID);
    VDASSERTW(nodeID.objid != NULL_OBJID);

  }
  
  // Done
  VDlogPrintFmt(VDLOG_STAT,0,"");
  VDlogPrintFmt(VDLOG_INFO,0,"Done adding equipment, Error Count %d",0);

 wrapup:
  if (listIDs) free(listIDs);
  
}

