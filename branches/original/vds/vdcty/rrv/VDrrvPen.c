/* $Id: VDrrvPen.c,v 1.3 2002/06/07 20:14:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvPen.c
 *
 * Description: Compare pen/pcg Trees
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvPen.c,v $
 *      Revision 1.3  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.2  2002/05/03 20:12:13  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/03/14 22:18:09  ylong
 *      Compare bevels, penetrations
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/10/02  ylong   Creation
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

VDASSERT_FFN("vdcty/rrv/VDrrvPen.c");

/* -------------------------------------------------------------------------
 * compare pcg's pen and reference plane, and create diff under pcg diff node
 */
static void compareTwoPcgParentNodes(TVDrrvDiffInfo *info,
			             TGRid          *parent1ID,
			             TGRid          *parent2ID,
                                     IGRchar        *desc)
{
  VDASSERT_FN("compareTwoPcgParentNodes");

  TVDtag tag1,tag2;

  // Flag if have new parent or if parent was updated
  VDctxGetCompTag(parent1ID,&tag1);
  VDctxGetCompTag(parent2ID,&tag2);
  if (tag1.num != tag2.num) {
    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,desc,"new parent");
    goto wrapup;
  }
  if (tag1.ver != tag2.ver) {
    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,desc,"parent was updated");
    goto wrapup;
  }

  // Done
 wrapup:
  return;
}

/* ------------------------------------------------
 * Compare two attributes
 */
static void compareTwoPenAttributes(TVDrrvDiffInfo *info,
                                    TGRid   *node1ID,
				    TGRid   *node2ID,
                                    IGRchar *name)
{
  VDASSERT_FN("compareTwoPenAttributes");

  IGRstat sts;

  IGRdouble dbl1,dbl2;
  IGRdouble del;
  
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
static void compareTwoPenNodesAttributes(TVDrrvDiffInfo *info,
				         TGRid *node1ID,
				         TGRid *node2ID)
{
  VDASSERT_FN("compareTwoPenNodesAttributes");

  IGRint  cnt,i;
  TVDfld  flds[64];
  
  // Bounce attributes
  VDctxGetFldAtrs(node1ID,&cnt,flds);
  for(i = 0; i < cnt; i++) {
    compareTwoPenAttributes(info,node1ID,node2ID,flds[i].name);
  }

 wrapup:
  return;
}

/* -----------------------------------------------
 * Got two nodes from two different trees whose component path
 * matches, do an in depth comparision
 */
void VDrrvCompareTwoPenNodes(TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvCompareTwoPenNodes");

  TGRid *node1ID,*node2ID;
  
  TGRid child1ID,child2ID;
  
  IGRint i;
  
  // Make sure have nodes
  VDASSERTW(info);
  node1ID = info->node1ID;
  node2ID = info->node2ID;
  
  // Main attributes
  compareTwoPenNodesAttributes(info,node1ID,node2ID);

  // Checkthe child collectors, assume they are in order for now
  for(i = 0; VDctxGetNthTreeChild(node1ID,i,&child1ID); i++) {

    if (VDctxIsNodeType(&child1ID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR)) {

      VDctxGetNthTreeChild(node2ID,i,&child2ID);
      if ((child2ID.objid != NULL_OBJID) && 
	  VDctxIsNodeType(&child2ID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR)) {

	compareTwoPenNodesAttributes(info,&child1ID,&child2ID);
      }
    }
  }
  
  // Check pcg's pen and reference plane
  if( VDctxIsNodeType( node1ID,VDCTX_NODE_TYPE_SS_OM_PCG )) {
    VDctxGetChildNodeByType(node1ID,VDCTX_NODE_TYPE_SS_OM_PCG_PEN,&child1ID);
    VDctxGetChildNodeByType(node2ID,VDCTX_NODE_TYPE_SS_OM_PCG_PEN,&child2ID);
    compareTwoPcgParentNodes(info,&child1ID,&child2ID,"pen_macro");

    VDctxGetChildNodeByType(node1ID,VDCTX_NODE_TYPE_SS_OM_PCG_RFPLN,&child1ID);
    VDctxGetChildNodeByType(node2ID,VDCTX_NODE_TYPE_SS_OM_PCG_RFPLN,&child2ID);
    compareTwoPcgParentNodes(info,&child1ID,&child2ID,"ref_plane");
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
 * Given two dom pen trees, compare them
 * Make the assumption that tree1 is the newer tree?
 */
void VDrrvCompareTwoPenTrees(TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvCompareTwoPenTrees");
  
  struct 
  {
    IGRint newCnt;
    IGRint delCnt;
    IGRint modCnt;
  } sum;
  
  TVDctxNodeList l1,l2;
  TVDctxBaseInfo baseInfo1,baseInfo2;
  
  // Init
  VDctxInitNodeList(&l1);
  VDctxInitNodeList(&l2);
  memset(&sum,0,sizeof(sum));
  
  // Arg check
  VDASSERTW(info);

  // For reporting
  VDctxGetBaseInfo(info->tree1ID,&baseInfo1);
  VDctxGetBaseInfo(info->tree2ID,&baseInfo2);
  VDASSERTW(baseInfo1.treeType);
  VDASSERTW(baseInfo1.treeType);
  
  // Grab the piecess
  VDctxGetNodeListByType(info->tree1ID,VDCTX_NODE_TYPE_SS_OM_PEN,&l1);
  VDctxGetNodeListByType(info->tree2ID,VDCTX_NODE_TYPE_SS_OM_PEN,&l2);
  
  // Ok if either has no pieces
  if (l1.cnt == 0) goto wrapup;
  if (l2.cnt == 0) goto wrapup;

  // Sort em
  VDctxSortNodeList(&l1,VDctxCompareNodeTypeCompPath);
  VDctxSortNodeList(&l2,VDctxCompareNodeTypeCompPath);
  
  // Report
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare PEN Tree 1 %s %s, Count %4d",
		baseInfo1.treeType,baseInfo1.treeName,l1.cnt);

  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"        PEN Tree 2 %s %s, Count %4d",
		baseInfo2.treeType,baseInfo2.treeName,l2.cnt);
  
  // Check for items in 1 but not in 2
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {
    info->node1ID = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareNodeTypeCompPath);
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
      VDrrvInitDiffNode(0,info);     
      sum.delCnt++;
    }    
  }

  // Check for items in both
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {
    info->node1ID = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareNodeTypeCompPath);
    if (info->node2ID) {
      VDrrvInitDiffNode(0,info);
      VDrrvCompareTwoPenNodes(info);
      if (info->diffID.objid != NULL_OBJID) sum.modCnt++;
    }
  }

  // Done
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Summary, New PEN %d, Deleted PEN %d, 'Modified' PEN %d",
		sum.newCnt,sum.delCnt,sum.modCnt);      
  
 wrapup:

  VDctxFreeNodeList(&l1);
  VDctxFreeNodeList(&l2);
  
  return;
}

/* -----------------------------------------------
 * Given two dom pen trees, compare them
 * Make the assumption that tree1 is the newer tree?
 */
void VDrrvCompareTwoPcgTrees(TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvCompareTwoPcgTrees");
  
  struct 
  {
    IGRint newCnt;
    IGRint delCnt;
    IGRint modCnt;
  } sum;
  
  TVDctxNodeList l1,l2;
  TVDctxBaseInfo baseInfo1,baseInfo2;
  
  // Init
  VDctxInitNodeList(&l1);
  VDctxInitNodeList(&l2);
  memset(&sum,0,sizeof(sum));
  
  // Arg check
  VDASSERTW(info);

  // For reporting
  VDctxGetBaseInfo(info->tree1ID,&baseInfo1);
  VDctxGetBaseInfo(info->tree2ID,&baseInfo2);
  VDASSERTW(baseInfo1.treeType);
  VDASSERTW(baseInfo1.treeType);
  
  // Grab the piecess
  VDctxGetNodeListByType(info->tree1ID,VDCTX_NODE_TYPE_SS_OM_PCG,&l1);
  VDctxGetNodeListByType(info->tree2ID,VDCTX_NODE_TYPE_SS_OM_PCG,&l2);
  
  // Ok if either has no pieces
  if (l1.cnt == 0) goto wrapup;
  if (l2.cnt == 0) goto wrapup;

  // Sort em
  VDctxSortNodeList(&l1,VDctxCompareNodeTypeCompPath);
  VDctxSortNodeList(&l2,VDctxCompareNodeTypeCompPath);
  
  // Report
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare PCG Tree 1 %s %s, Count %4d",
		baseInfo1.treeType,baseInfo1.treeName,l1.cnt);

  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"        PCG Tree 2 %s %s, Count %4d",
		baseInfo2.treeType,baseInfo2.treeName,l2.cnt);
  
  // Check for items in 1 but not in 2
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    info->node1ID  = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareNodeTypeCompPath);
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
      VDrrvInitDiffNode(0,info);    
      sum.delCnt++;
    }    
  }

  // Check for items in both
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    info->node1ID  = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareNodeTypeCompPath);
    if (info->node2ID) {
      VDrrvInitDiffNode(0,info);    
      VDrrvCompareTwoPenNodes(info);
      if (info->diffID.objid != NULL_OBJID) sum.modCnt++;
    }
  }

  // Done
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Summary, New PCG %d, Deleted PCG %d, 'Modified' PCG %d",
		sum.newCnt,sum.delCnt,sum.modCnt);      
  
 wrapup:

  VDctxFreeNodeList(&l1);
  VDctxFreeNodeList(&l2);
  
  return;
}
