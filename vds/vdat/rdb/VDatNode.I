/* $Id: VDatNode.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/VDatNode.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatNode.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

#include "VDris.h"

/* -----------------------------------------
 * Gets the rdb node
 * for a set,leaf or node
 */
IGRstar VDatRDBGetNode(TGRid *objID, TGRid *rdbNodeID)
{
  IGRstat retFlag = 0;

  IGRint  type;

  TGRid rdbNodesID;
  TGRid rdbSetID;
  TGRid setID;

  // Init
  rdbNodeID->objid = NULL_OBJID;

  // Different objects handled
  VDatGetBaseType(objID,&type);

  switch(type) {

  case VDAT_CLASSI_SET: {

    // Get the node
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_SET,&rdbSetID);
    if (rdbSetID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetNode(&rdbSetID,rdbNodeID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_SET: {

    // Get the rdb node list
    VDatGetChildByType(objID,VDAT_CLASSI_RDB_NODES,&rdbNodesID);
    if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetNode(&rdbNodesID,rdbNodeID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_NODES: {

    // Get the first rdb node in list
    VDatGetChildByType(objID,VDAT_CLASSI_RDB_NODE,rdbNodeID);
    if (rdbNodeID->objid == NULL_OBJID) goto wrapup;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_NODE: {

    *rdbNodeID = *objID;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE: { // Should have a parent directly linked

    // Get the first rdb node in list
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_NODE,rdbNodeID);
    if (rdbNodeID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_LEAF: { 

    // May have a parent
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_NODE,rdbNodeID);
    if (rdbNodeID->objid != NULL_OBJID) {
      retFlag = 1;
      goto wrapup;
    }

    // Use the set
    VDatGetSet(objID,&setID);
    if (setID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetNode(&setID,rdbNodeID);
    goto wrapup;
  }

  }
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Given an object, find rdb node type
 */
IGRstar VDatRDBGetNodeType(TGRid *objID, IGRchar  *nodeType)
{
  IGRstat retFlag = 0;

  TGRid   rdbNodeID;

  // Init
  *nodeType = 0;

  // Find the node
  VDatRDBGetNode(objID,&rdbNodeID);
  if (rdbNodeID.objid == NULL_OBJID) goto wrapup;

  VDatGetBaseName(&rdbNodeID,nodeType);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Looks up particular node in a set
 */
IGRstar VDatRDBGetNodeByType(
  TGRid   *objID,  
  IGRchar *a_nodeType, 
  TGRid   *a_nodeID
)
{
  IGRstat retFlag = 0;

  TGRid   nodesID;
  TGRid   nodeID;

  IGRchar nodeType[128];
//IGRchar *pnt;

  IGRint  i;

  // Init
  a_nodeID->objid = NULL_OBJID;

  // Get list of nodes
  VDatRDBGetNodes(objID,&nodesID);
  if (nodesID.objid == NULL_OBJID) goto wrapup;

  // Find by type
  for(i = 0; VDatGetChildObject(&nodesID,i,&nodeID); i++) {

    VDatGetBaseName(&nodeID,nodeType);

    // Type is usally setType.nodeType
//  pnt = strchr(nodeType,'.');
//  if (pnt) strcpy(nodeType,pnt+1);

    if (strcmp(a_nodeType,nodeType) == 0) {
      *a_nodeID = nodeID;
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Packs rdb nodes into vla
 */
IGRstar VDatRDBGetNodesVLA(TGRid *objID, TVDvlaID *nodeVLA)
{
  IGRstat retFlag = 0;

  TGRid rdbNodesID;
  TGRid rdbNodeID;

  IGRint i;

  // Get list of nodes
  VDatRDBGetNodes(objID,&rdbNodesID);
  if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

  // Transfer
  for(i = 0; VDatGetChildObject(&rdbNodesID,i,&rdbNodeID); i++) {
    VDvlaID_Append(nodeVLA,&rdbNodeID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Returns the list of rdb node objects
 */
IGRstar VDatRDBGetNodes(TGRid *objID, TGRid *rdbNodesID)
{
  IGRstat retFlag = 0;

  TGRid   rdbSetID;

  // Init
  rdbNodesID->objid = NULL_OBJID;
  
  // Get RDB Set
  VDatRDBGetSet(objID,&rdbSetID);
  if (rdbSetID.objid == NULL_OBJID) goto wrapup;

  VDatGetChildByType(&rdbSetID,VDAT_CLASSI_RDB_NODES,rdbNodesID);
  if (rdbNodesID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Creates a node to hold the info
 */
IGRstar VDatRDBCreateNode(
  TGRid            *nodesID, 
  TVDatRDBNodeInfo *info, 
  TGRid            *nodeID
)
{
  IGRstat retFlag = 0;

  TGRid postID;

  // Create the object
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_NODE,
    type     = VDAT_CLASSI_RDB_NODE,
    parentID = nodesID,
    baseID   = nodeID
  );
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  // Set the attributes
  VDatRDBSetNodeInfo(nodeID,info);

  // Link the table
  VDatRDBGetPostByName(NULL,info->nodeTableName,&postID);
  if (postID.objid == NULL_OBJID) goto wrapup;
  VDatAddParent(nodeID,&postID);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Creates nodes releated to a set and links them in
 */
IGRstar VDatRDBCreateNodes(TGRid *setID, TGRid *nodesID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint    tabNumCols = 11;
  IGRint    tabNumRows = 0;
  IGRchar   tabWhere[128];
  IGRint    i;
  IGRchar **tabList = NULL;

  TVDatRDBNodeInfo info;

  TGRid  nodeID;

  IGRchar setType[128];

  // Init
  *setType = 0;

  // Holds a list 
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_NODES,
    type     = VDAT_CLASSI_RDB_NODES,
    parentID = setID,
    baseID   = nodesID
  );
  if (nodesID->objid == NULL_OBJID) goto wrapup;

  // Verify Logged in 
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // get the set type
  VDatGetBaseName(setID,setType);
  if (*setType == 0) goto wrapup;
  sprintf(tabWhere,"set_type='%s'",setType);

  // Get the node information
  sts = vdb$RisSelect( 
    select = 
      "set_type,node_type,node_level,node_desc,node_table_name,"
      "node_syntax,node_name_cons,"
      "node_path_desc,node_path_sep,node_path_swap,node_path_prefix",

    table_name = VDAT_RDB_TBL_SET_NODES,
    where      =  tabWhere,
    order      = "node_level",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );
  if (tabNumRows == 0) goto wrapup;

  // Create Setup Database
  for(i = 0; i < tabNumRows; i++) {

    // Fill structure
    memset(&info,0,sizeof(info));

    strcpy(info.setType,       tabList[(i*tabNumCols)+ 0]);
    strcpy(info.nodeType,      tabList[(i*tabNumCols)+ 1]);
    info.nodeLevel      = atoi(tabList[(i*tabNumCols)+ 2]);
    strcpy(info.nodeDesc,      tabList[(i*tabNumCols)+ 3]);
    strcpy(info.nodeTableName, tabList[(i*tabNumCols)+ 4]);

    strcpy(info.nodeSyntax,    tabList[(i*tabNumCols)+ 5]);
    strcpy(info.nodeNameCons,  tabList[(i*tabNumCols)+ 6]);
    strcpy(info.nodePathDesc,  tabList[(i*tabNumCols)+ 7]);
    strcpy(info.nodePathSep,   tabList[(i*tabNumCols)+ 8]);
    info.nodePathSwap   = atoi(tabList[(i*tabNumCols)+ 9]);
    strcpy(info.nodePathPrefix,tabList[(i*tabNumCols)+10]);

    VDatRDBCreateNode(nodesID,&info,&nodeID);
  }

  retFlag = 1;

wrapup:

  if (retFlag != 1) {
    UI_status("Problem creating nodes");
  }

  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );

  return retFlag;
}

/* ---------------------------------------------
 * Gets the rdb node info in the object
 */
IGRstar VDatRDBGetNodeInfo(TGRid *nodeID, TVDatRDBNodeInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint   cnt;
  TVDatFld flds[VDAT_FLD_MAX];

  TGRid rdbNodeID;

  // Clear
  memset(info,0,sizeof(TVDatRDBNodeInfo));

  // Chain to actual node
  VDatRDBGetNode(nodeID,&rdbNodeID);
  if (rdbNodeID.objid == NULL_OBJID) goto wrapup;

  // Get all attributes
  cnt = 0;
  sts = VDatFldGetAllAttrs(&rdbNodeID,flds,&cnt);
  if (!(sts & 1)) goto wrapup;

  // Unpack
  VDatFldGetTxtByIndex(flds,cnt, 1, info->setType);
  VDatFldGetTxtByIndex(flds,cnt, 2, info->nodeType);
  VDatFldGetIntByIndex(flds,cnt, 3,&info->nodeLevel);
  VDatFldGetTxtByIndex(flds,cnt, 4, info->nodeDesc);
  VDatFldGetTxtByIndex(flds,cnt, 5, info->nodeTableName);

  VDatFldGetTxtByIndex(flds,cnt, 6, info->nodeSyntax);
  VDatFldGetTxtByIndex(flds,cnt, 7, info->nodeNameCons);
  VDatFldGetTxtByIndex(flds,cnt, 8, info->nodePathDesc);
  VDatFldGetTxtByIndex(flds,cnt, 9, info->nodePathSep);
  VDatFldGetIntByIndex(flds,cnt,10,&info->nodePathSwap);
  VDatFldGetTxtByIndex(flds,cnt,11, info->nodePathPrefix);
 
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Sets the rdb node info in the object
 */
IGRstar VDatRDBSetNodeInfo(TGRid *nodeID, TVDatRDBNodeInfo *info)
{
  IGRstat retFlag = 0;

  TVDatFld flds[VDAT_FLD_MAX];
  IGRint   cnt;

  // IGRchar  nodeName[128];

  // Add the Data
  cnt = 0;
  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 1,info->setType);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 2,info->nodeType);
  VDatFldSetIntByIndex(&flds[cnt],&cnt, 3,info->nodeLevel);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 4,info->nodeDesc);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 5,info->nodeTableName);

  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 6,info->nodeSyntax);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 7,info->nodeNameCons);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 8,info->nodePathDesc);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt, 9,info->nodePathSep);
  VDatFldSetIntByIndex(&flds[cnt],&cnt,10,info->nodePathSwap);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,11,info->nodePathPrefix);
 
  VDatFldSetAllAttrs(nodeID,flds,cnt);

//sprintf(nodeName,"%s.%s",info->setType,info->nodeType);
//VDatSetBaseName(nodeID,nodeName);

  VDatSetBaseName(nodeID,info->nodeType);

  retFlag = 1;

//wrapup:
  return retFlag;
}

end implementation VDatBase;

