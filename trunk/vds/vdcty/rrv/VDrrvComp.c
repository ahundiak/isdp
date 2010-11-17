/* $Id: VDrrvComp.c,v 1.1.2.1 2003/06/17 21:03:52 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvComp.c
 *
 * Description: Compare Component Trees
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvComp.c,v $
 *      Revision 1.1.2.1  2003/06/17 21:03:52  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/05/02  ah      Creation
 * 06/17/03  ah      CR7623 Show when user attributes are added or deleted
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

VDASSERT_FFN("vdcty/rrv/VDrrvComp.c");

/* ------------------------------------------------
 * Compare two attributes
 */
static void compareTwoCompAttributes(TVDrrvDiffInfo *info,
                                     TGRid   *node1ID,
			             TGRid   *node2ID,
                                     IGRchar *name)
{
  VDASSERT_FN("compareTwoCompAttributes");

  IGRstat sts;

  IGRdouble dbl1,dbl2;
  IGRdouble delta;
  
  IGRchar buf[256];
  IGRchab buf1,buf2;
  IGRchar *p;

  IGRint len;

  /* Init */
  len = sizeof(buf1);

  // Cooridinate matrixes get special handling
  if (!strcmp(name,"matrix")) goto wrapup;

  /* See if the second node even has the attribute */
  sts = VDctxGetTxtAtrBuf(node2ID,name,len,buf2);
  if (sts == 0)
  {
    VDctxGetTxtAtrBuf(node1ID,name,len,buf1);
    snprintf(buf,sizeof(buf),"Added new attribute %s=%s\n",name,buf1);
    VDrrvInitDiffNode(1,info);
    VDctxAppTxtAtr(&info->diffID,name,"Added Attribute");
    goto wrapup;
  }

  // Get the attributes
  sts = VDrrvGetTwoAttributes(node1ID,node2ID,name,len,buf1,buf2);
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
static void compareTwoCompNodesAttributes(TVDrrvDiffInfo *info,
			 	          TGRid *node1ID,
				          TGRid *node2ID)
{
  VDASSERT_FN("compareTwoCompNodesAttributes");

  IGRint  sts;

  IGRint  cnt,i;
  TVDfld  flds[64];

  IGRchab buf1,buf2;
   
  // Get the attribute names
  VDctxGetFldAtrs(node1ID,&cnt,flds);

  // Bounce em
  for(i = 0; i < cnt; i++) {
    compareTwoCompAttributes(info,
                             node1ID,node2ID,
                             flds[i].name);
  }

  /* Bounce the other way just to see if any are deleted */
  VDctxGetFldAtrs(node2ID,&cnt,flds);

  // Bounce em
  for(i = 0; i < cnt; i++) {
    sts = VDctxGetTxtAtrBuf(node1ID,flds[i].name,sizeof(buf1),buf1);
    if (sts == 0)
    {
      VDrrvInitDiffNode(1,info);
      VDctxAppTxtAtr(&info->diffID,flds[i].name,"Deleted Attribute");
    }
  }

 wrapup:
  return;
}

/* -----------------------------------------------
 * Compare two 3d points
 */
static void comparePoints(TVDrrvDiffInfo *info,
                          TGRid    *node1ID,
	                  TGRid    *node2ID,
                          IGRchar  *desc,
                          IGRchar  *name,
                          IGRdouble tol)
{
  VDASSERT_FN("comparePoints");
  
  IGRdouble dis;
  
  IGRpoint pt1,pt2;
  IGRchar *p1,*p2;

  IGRchar buf[256];
  IGRchar tag[32];

  // Grab them
  VDctxGetTxtAtrPtr(node1ID,name,&p1);
  VDctxGetTxtAtrPtr(node2ID,name,&p2);
  if (*p1 == 0) goto wrapup;
  if (*p2 == 0) goto wrapup;
  VDvalConvertTextToPoint(p1,pt1);
  VDvalConvertTextToPoint(p2,pt2);

  // Compare
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  if (dis < tol) goto wrapup;

  // Add to diff node
  snprintf(buf,sizeof(buf),
          "Changed\nfrom %s\nto   %s\nDistance %.1f mm\n",p2,p1,dis);

  snprintf(tag,sizeof(tag),"%s%s",desc,name);

  VDrrvInitDiffNode(1,info);
  VDctxAppTxtAtr(&info->diffID,tag,buf);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Compare control segment nodes
 */
static void compareTwoCompControlSegNodes(TVDrrvDiffInfo *info,
			                  TGRid *node1ID,
			                  TGRid *node2ID)
{
  VDASSERT_FN("compareTwoCompControlSegNodes");
  
  IGRdouble tol;

  // Really just a wrapper
  VDvalGetTolerance(VDTOL_MIN_ORG_CHANGED,&tol);
  comparePoints(info,node1ID,node2ID,"ctrl_seg_","pt1",tol);
  comparePoints(info,node1ID,node2ID,"ctrl_seg_","pt2",tol);
 
 wrapup:
  return;
}

/* -----------------------------------------------
 * Got two nodes from two different trees whose component path
 * matches, do an in depth comparision
 *
 * Note: if calling from outside this file, make sure info
 * is initialized the way you want it to be
 */
void VDrrvCompareTwoCompNodes(TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvCompareTwoCompNodes");
  
  TGRid child1ID,child2ID;
  
  IGRint i;
  
  TGRid *node1ID;
  TGRid *node2ID;

  // Make sure have nodes
  VDASSERTW(info);
  node1ID = info->node1ID;
  node2ID = info->node2ID;

  // Main attributes
  compareTwoCompNodesAttributes(info,node1ID,node2ID);

  // Could have a matrix
  VDrrvCompareTwoCsNodes(info,node1ID,node2ID);

  // Checkthe child collectors, assume they are in order for now
  for(i = 0; VDctxGetNthTreeChild(node1ID,i,&child1ID); i++) {

    if (VDctxIsNodeType(&child1ID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR)) {

      VDctxGetNthTreeChild(node2ID,i,&child2ID);
      if ((child2ID.objid != NULL_OBJID) && 
	  VDctxIsNodeType(&child2ID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR)) {

	compareTwoCompNodesAttributes(info,&child1ID,&child2ID);
      }
    }
    if (VDctxIsNodeType(&child1ID,VDCTX_NODE_TYPE_SS_OM_VRCNRLSEG)) {

      VDctxGetNthTreeChild(node2ID,i,&child2ID);
      if ((child2ID.objid != NULL_OBJID) && 
	  VDctxIsNodeType(&child2ID,VDCTX_NODE_TYPE_SS_OM_VRCNRLSEG)) {

	compareTwoCompControlSegNodes(info,&child1ID,&child2ID);
      }
    }
  }

  /* --------------------------------------------
   * Partly out of laziness and partly out of a
   * feeling that it might be redundant, skip checking
   * control points.  I really thing the matrix in the component
   * itself will reflect when a component has moved.
   *
   * Probably should have skipped the control segments as well
   * but hey they are implemented so leave for now.
   */	
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given two dom comp trees, compare them
 * Make the assumption that tree1 is the newer tree?
 */
void VDrrvCompareTwoCompTrees(TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvCompareTwoCompTrees");
  
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
  
  // Only have tags
  VDctxGetNodeListByType(info->tree1ID,VDCTX_NODE_TYPE_SS_OM_COMPONENT,&l1);
  VDctxGetNodeListByType(info->tree2ID,VDCTX_NODE_TYPE_SS_OM_COMPONENT,&l2);
  if (l1.cnt == 0) goto wrapup;
  if (l2.cnt == 0) goto wrapup;
  VDctxSortNodeList(&l1,VDctxCompareCompTag);
  VDctxSortNodeList(&l2,VDctxCompareCompTag);
  
  // Report
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Comp Tree 1 %s %s, Count %4d",
		baseInfo1.treeType,baseInfo1.treeName,l1.cnt);

  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"        Comp Tree 2 %s %s, Count %4d",
		baseInfo2.treeType,baseInfo2.treeName,l2.cnt);
  
  // Check for items in 1 but not in 2
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {
    info->node1ID = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareCompTag);
    if (!info->node2ID) {
      VDrrvInitDiffNode(0,info);      
      sum.newCnt++;
    }
  }

  // Check for items in 2 but not in 1
  for(l2.i = 0; l2.i < l2.cnt; l2.i++) {
    info->node2ID = &l2.listIDs[l2.i];
    info->node1ID = VDctxSearchNodeList(info->node2ID,&l1,VDctxCompareCompTag);
    if (!info->node1ID) {
      VDrrvInitDiffNode(0,info); 
      sum.delCnt++;
    }    
  }

  // Check for items in both
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {
    info->node1ID = &l1.listIDs[l1.i];
    info->node2ID = VDctxSearchNodeList(info->node1ID,&l2,VDctxCompareCompTag);
    if (info->node2ID) {
      VDrrvInitDiffNode(0,info);
      VDrrvCompareTwoCompNodes(info);
      if (info->diffID.objid != NULL_OBJID) sum.modCnt++;
    }
  }

  // Done
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Summary, New Comp %d, Deleted Comp %d, 'Modified' Comp %d",
		sum.newCnt,sum.delCnt,sum.modCnt);      
  
 wrapup:

  VDctxFreeNodeList(&l1);
  VDctxFreeNodeList(&l2);
   
  return;
}

/* -----------------------------------------------
 * Create a tree of all equipment
 */
void VDrrvAddComps(VDosnum osnum,TGRid *treeID)
{
  VDASSERT_FN("VDrrvAddComps");
  
  IGRint  cnt;
  IGRchab key;
  IGRchab fileName;

  TGRid    *listIDs = NULL;
  TGRid      compID;
  TGRobj_env compOE;
  IGRint i;
  
  TGRid nodeID;
  TGRid rootID;

  IGRint compTrace = VDrrvCmdGetCreateTraceFlag();

  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Validate the os by getting the fileName
  VDosGetFileName(osnum,fileName);
  VDASSERTW(*fileName);
  
  // Get list of pieces
  VDobjGetRouteComponents(osnum,&cnt,&listIDs);
  if (cnt) VDASSERTW(listIDs);

  VDlogPrintFmt(VDLOG_INFO,0,
		"File %s, Found %d components.",
		fileName,cnt);
   
  // Build the tree
  VDctxCreateNode(treeID,VDCTX_NODE_TYPE_SS_OM_COMPONENTS,NULL,&rootID);
  VDASSERTW(rootID.objid != NULL_OBJID);
  
  // Cycle through
  for(i = 0; i < cnt; i++) {
    compID = listIDs[i];
    compOE.obj_id = compID;
    VDobjResetOE(&compOE);

    if (compTrace) {
      VDlogPrintObject(VDLOG_INFO,1,"Processing ",&compOE,NULL);
    }

    // Create the node
    VDvalConvertComponentToDom(&compOE,&rootID,&nodeID);
    VDASSERTW(nodeID.objid != NULL_OBJID);

  }
  
  // Done
  VDlogPrintFmt(VDLOG_STAT,0,"");
  VDlogPrintFmt(VDLOG_INFO,0,"Done adding components, Error Count %d",0);

 wrapup:
  if (listIDs) free(listIDs);
  
}

