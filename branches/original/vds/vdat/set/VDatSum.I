/* $Id: VDatSum.I,v 1.2 2001/01/11 21:12:34 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatSum.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatSum.I,v $
 *      Revision 1.2  2001/01/11 21:12:34  art
 *      sp merge
 *
# Revision 1.2  2000/11/27  19:14:30  pinnacle
# ah
#
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/30/00  ah      Header 
 *                   VDatSumStagingTreeNode was incorrectly summing parents
 *           ah      Removed ppl interface for speed
 ***************************************************************************/
class implementation VDatBase;

#include "VDppl1.h"

from VDSroot import VDprocAttr;

IGRstat VDatSumStagingTreeNode(TGRid *nodeID);
IGRstat VDatSumStagingTreeLeaf(TGRid *leafID);

/* ----------------------------------------
 * Generic processor for summing a leaf
 */
IGRstat VDatSummarizeLeaf(TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRint  sts;

  TGRobj_env pieceOE;
  TGRid      parentID;

  IGRchar buf     [256];
  IGRchar leafName[128];
  IGRchar setType  [64];

  TGRid   pplID;
  IGRint  pplRET;
  
  IGRint traceFlag = 0;
  
  // Verify leaf
  if ((leafID == NULL) || (leafID->objid == NULL_OBJID)) goto wrapup;

  // See if summarizable
  sts = VDatIsSummarizable(leafID);
  if (!(sts & 1)) goto wrapup;

  if (traceFlag) {
    printf(">>> VDatSummarizeLeaf %d,%d\n",leafID->osnum,leafID->objid);
  }
  
  // Get the object
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Status
  VDatGetLeafName(leafID,leafName);
  sprintf(buf,"Summarizing %s",leafName);
  UI_status(buf);
  if (traceFlag || 0) printf("Summarizing %s\n",leafName);

  /* ---------------------------------------------
   * 31 Oct 2000 - Take out the ppl link
   * Getting core dumps
   */
  VDatSumStagingTreeLeaf(leafID);

#if 0

  // Hand off to ppl
  VDatRDBGetSetType(leafID,setType);
  if (*setType == 0) goto wrapup;

  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(
    pplID = &pplID,
    name  = "NODE_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar*)leafID);

  vdppl$SetData(
    pplID = &pplID,
    name  = "PIECE_OE",
    size  = sizeof(TGRobj_env),
    data  = (IGRchar*)&pieceOE);

  vdppl$Run(pplID = &pplID, name = "summarizeLeaf", ret = &pplRET);
  vdppl$Delete(pplID = &pplID);
#endif

  // Indicate it's been done at least once
  VDatSetBaseFlagBit(leafID,VDAT_FLAG_SUM);

  // Tell the form system about it
  VDatCMDAttrUpdateLeaf(leafID);
  
  // And summarize parent chain
  VDatGetParentNode(leafID,&parentID);
  if (parentID.objid != NULL_OBJID) {
    VDatSummarizeNode(&parentID);
  }
  
  // Done
  retFlag = 1;

wrapup:
  UI_status("");
  if (traceFlag) {
    printf("<<< VDatSummarizeLeaf %d,%d\n",leafID->osnum,leafID->objid);
  }
  return retFlag;
}

/* ----------------------------------------------------
 * Summarize node based on it's child values
 */
IGRstar VDatSummarizeNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid    parentID;

  IGRchar setType[64];

  TGRid   pplID;
  IGRint  pplRET;

  IGRint  traceFlag = 0;
  
  // Verify Node
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Make sure it's a candidate
  sts = VDatIsSummarizable(nodeID);
  if (!(sts & 1)) goto wrapup;

  if (traceFlag) {
    printf(">>> VDatSummarizeNode %d,%d\n",nodeID->osnum,nodeID->objid);
  }
  
  /* ---------------------------------------------
   * 31 Oct 2000 - Take out the ppl link
   * Getting core dumps
   */
  VDatSumStagingTreeNode(nodeID);
  
#if 0
  // Hand off to ppl
  VDatRDBGetSetType(nodeID,setType);
  if (*setType == 0) goto wrapup;

  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(
    pplID = &pplID,
    name  = "NODE_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar*)nodeID);

  vdppl$Run(pplID = &pplID, name = "summarizeNode", ret = &pplRET);
  vdppl$Delete(pplID = &pplID);
#endif

  // Tell the form system about it
  VDatCMDAttrUpdateNode(nodeID);
  
  // And summarize parent chain
  VDatGetParentNode(nodeID,&parentID);
  if (parentID.objid != NULL_OBJID) {
    VDatSummarizeNode(&parentID);
  }

wrapup:
  if (traceFlag) {
    printf("<<< VDatSummarizeNode %d,%d\n",nodeID->osnum,nodeID->objid);
  }
  return retFlag;
}

/* ----------------------------------------
 * Special routine for StagingTree
 * Evaluates mass properties or a leaf
 * Use VDSroot.VDprcAttrs on the connected object
 */
IGRstar VDatSumStagingTreeLeaf(TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRint  sts,flag;
  IGRlong suc;

  TGRobj_env pieceOE;

  TVDatSum  sum;
  
  // Get the object
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Pull props from piece
  flag = 0xFF;
  memset(&sum,0,sizeof(TVDatSum));
  sts = om$send(
    msg = message VDSroot.VDprocAttr(&suc,&pieceOE.mod_env,flag,&sum),
    senderid = NULL_OBJID,
    targetid = pieceOE.obj_id.objid,
    targetos = pieceOE.obj_id.osnum
  );
  UI_status("");
  if (!(sts & suc & 1)) goto wrapup;

  // And set it
  VDatSetNodeSummary(leafID,&sum);
  
  // Done
  retFlag = 1;

wrapup:
  UI_status("");
  return retFlag;
}

/* ----------------------------------------------------
 * Special Routine for StagingTree
 * Summarize node based on it's child values
 */
IGRstar VDatSumStagingTreeNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid    childID;
  TGRid    parentID;

  IGRint   i;
  IGRint   j;

  IGRdouble mass;

  TVDatSum nodeSum,childSum;

  // Verify Node
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Make sure it's a candidate
  sts = VDatIsSummarizable(nodeID);
  if (!(sts & 1)) goto wrapup;

  // Reset node mass props
  memset(&nodeSum,0,sizeof(TVDatSum));

  // Pull data from each child
  for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {

    // See if child has data ready
    sts = VDatHasSummary(&childID);
    if (sts & 1) {

      // Get the child info
      VDatGetNodeSummary(&childID,&childSum);

      // Range is just an expansion
      for(j = 0; j < 3; j++) {
        if (childSum.range[j] < nodeSum.range[j]) { 
          nodeSum.range[j] = childSum.range[j];
        }
        if (childSum.range[j+3] > nodeSum.range[j+3]) { 
          nodeSum.range[j+3] = childSum.range[j+3];
        }
      }

      // Need to calc volume from range box???

      // COG expand and average
      mass = nodeSum.mass + childSum.mass;
      if (mass < .0001) mass = 1.0;

      for(j = 0; j < 3; j++) {
        nodeSum.cog[j] = 
          (( nodeSum.cog[j] *  nodeSum.mass) + 
           (childSum.cog[j] * childSum.mass)) / mass;
      }

      // Mass is easy
      nodeSum.mass   += childSum.mass;
      nodeSum.volume += childSum.volume;

    }
  }

  // And update
  VDatSetNodeSummary(nodeID,&nodeSum);

  /* ---------------------------------------------
   * 30 Oct 2000 - Done in VDatSummarizeNode
   */
#if 0
  // Tell the form system about it
  VDatCMDAttrUpdateNode(nodeID);
  
  // And summarize parent chain
  VDatGetParentNode(nodeID,&parentID);
  if (parentID.objid != NULL_OBJID) {
    VDatSummarizeNode(&parentID);
  }
#endif

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Returns true if object has summary data
 * Maybe should check for is summarizable here
 * but this really should only be called after determining
 * the node is summarizable
 */
IGRstar VDatHasSummary(TGRid *nodeID)
{
  IGRstat sts;
  IGRint  type;

  VDatGetBaseType(nodeID,&type);

  switch(type) {
  
  // Nodes are always assumed to have a summary
  case VDAT_CLASSI_NODE:
  case VDAT_CLASSI_TREE:
    return 1;

  // Leafs use a flag 
  case VDAT_CLASSI_LEAF:
    sts = VDatIsBaseFlag(nodeID,VDAT_FLAG_SUM);
    return sts;
  }

  return 0;
}

/* ----------------------------------------
 * Returns true is object is summarizable
 */
IGRstar VDatIsSummarizable(TGRid *nodeID)
{
  IGRint type;
  IGRint doSum;

  // Only nodes and leafs are summarizable at all
  VDatGetBaseType(nodeID,&type);

  switch(type) {
  case VDAT_CLASSI_NODE:
  case VDAT_CLASSI_TREE:
  case VDAT_CLASSI_LEAF:
    break;

  default:
    return 0;
  }

  // Ask the set type
  vdat$GetSetTypeInfo(setID = nodeID, setTypeDoSum = &doSum);
  if (doSum == 0) return 0;

  return 1;
}

/* ----------------------------------------------------
 * Get the node's summary properties
 */
IGRstar VDatGetNodeSummary(TGRid *nodeID, TVDatSum *sum)
{
  IGRstat retFlag = 0;

  TVDatFld  flds[VDAT_FLD_MAX];
  IGRint    cnt;

  TVDatFld  fld;

  // Init  
  if (sum == NULL) goto wrapup;
  memset(sum,0,sizeof(TVDatSum));

  // Could put a check here to see if summary is available

  // Grab all attributes
  VDatFldGetAllAttrs(nodeID,flds,&cnt);

  // Mass or weight?
  VDatFldGetAttrByName(nodeID,"mass",&fld);
  if (*fld.name) {
    VDatFldGetDblByName(flds,cnt,"mass",  &sum->mass);
  }
  else {
    VDatFldGetDblByName(flds,cnt,"weight",&sum->mass);
  }

  // Rest are easy
  VDatFldGetDblByName(flds,cnt,"volume",&sum->volume);

  VDatFldGetDblByName(flds,cnt,"cog_x" ,&sum->cog[0]);
  VDatFldGetDblByName(flds,cnt,"cog_y" ,&sum->cog[1]);
  VDatFldGetDblByName(flds,cnt,"cog_z" ,&sum->cog[2]);

  VDatFldGetDblByName(flds,cnt,"ref_x" ,&sum->range[0]);
  VDatFldGetDblByName(flds,cnt,"ref_y" ,&sum->range[1]);
  VDatFldGetDblByName(flds,cnt,"ref_z" ,&sum->range[2]);

  VDatFldGetDblByName(flds,cnt,"size_x",&sum->range[3]);
  VDatFldGetDblByName(flds,cnt,"size_y",&sum->range[4]);
  VDatFldGetDblByName(flds,cnt,"size_z",&sum->range[5]);

  sum->range[3] += sum->range[0];
  sum->range[4] += sum->range[1];
  sum->range[5] += sum->range[2];

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Set the node's summary properties
 */
IGRstar VDatSetNodeSummary(TGRid *nodeID, TVDatSum *sum)
{
  IGRstat retFlag = 0;

  TVDatFld  flds[VDAT_FLD_MAX];
  IGRint    cnt;

  TVDatSum  sumx;

  // Init  
  if (sum == NULL) {
    memset(&sumx,0,sizeof(TVDatSum));
    sum  = &sumx;
  }

  VDatFldGetAllAttrs(nodeID,flds,&cnt);

  // Mass or weight?
  VDatFldSetDblByName(flds,cnt,"mass",  sum->mass);
  VDatFldSetDblByName(flds,cnt,"weight",sum->mass);

  // Rest are easy
  VDatFldSetDblByName(flds,cnt,"volume",sum->volume);

  VDatFldSetDblByName(flds,cnt,"cog_x" ,sum->cog[0]);
  VDatFldSetDblByName(flds,cnt,"cog_y" ,sum->cog[1]);
  VDatFldSetDblByName(flds,cnt,"cog_z" ,sum->cog[2]);

  VDatFldSetDblByName(flds,cnt,"ref_x" ,sum->range[0]);
  VDatFldSetDblByName(flds,cnt,"ref_y" ,sum->range[1]);
  VDatFldSetDblByName(flds,cnt,"ref_z" ,sum->range[2]);

  VDatFldSetDblByName(flds,cnt,"size_x",sum->range[3] - sum->range[0]);
  VDatFldSetDblByName(flds,cnt,"size_y",sum->range[4] - sum->range[1]);
  VDatFldSetDblByName(flds,cnt,"size_z",sum->range[5] - sum->range[2]);

  VDatFldSetAllAttrs(nodeID,flds,cnt);

  retFlag = 1;

//wrapup:
  return retFlag;
}

end implementation VDatBase;

