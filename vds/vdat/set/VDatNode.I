/* $Id: VDatNode.I,v 1.2 2002/02/26 17:37:00 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatNode.I
 *
 * Description: Node Processing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatNode.I,v $
 *      Revision 1.2  2002/02/26 17:37:00  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1998/10/25  12:03:50  pinnacle
# ah
#
# Revision 1.2  1998/09/29  21:15:06  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.8  1998/03/24  16:35:52  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

#include "VDobj.h"
#include "VDppl1.h"

/* ----------------------------------------------------
 * Deletes one node, leaves the leafs in set
 */
IGRstat VDatDeleteNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRint  type;
  TGRid   parentID,childID;
  IGRint  i;

  // Verify Node
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Different types handled
  VDatGetBaseType(nodeID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF: {

    // Must have a parent to remove
    VDatGetParentNode(nodeID,&parentID);
    if (parentID.objid != NULL_OBJID) VDatDelParent(nodeID,&parentID);
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_NODE: {

    VDatDelAllParents(nodeID);  // Regular node

    // Delete all kids
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
      VDatDeleteNode(&childID);
    }

    // Delete myself
    om$send(
      msg = message Root.delete(0),
      senderid = NULL_OBJID,
      targetid = nodeID->objid,
      targetos = nodeID->osnum
    );
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: {

    // Just Delete all kids
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
      VDatDeleteNode(&childID);
    }
    retFlag = 3; // A tree is only partially deleted
    goto wrapup;
  }

  } // Switch

wrapup:
  return retFlag;
}
#if 0
/* ----------------------------------------------------
 * Calculates the node path
 * Sets up call to VDatNode.getNodePath()
 * 26 Feb 2002 - ah
 * Moved to vdctx/c, no more ppl interface
 */
IGRstat VDatGetNodePath(TGRid *objID, IGRchar *nodePath)
{
  IGRstat retFlag = 0;

  IGRchar  nodePathx[128];
 
  TGRid  pplID;
  IGRint pplRET;

  IGRchar setType[64];
  
  // Arg check
  if (nodePath == NULL) goto wrapup;
  if (objID    == NULL) goto wrapup;
  if (objID->objid == NULL_OBJID) {
    *nodePath = 0;
    goto wrapup;
  }
  
  // set type determines ppl
  VDatRDBGetSetType(objID,setType);
  //vdobj$Print(objID = objID);
  
  // Hand off to ppl
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    printf("Unable to load %s.e in VDatGetNodePath\n",setType);
    goto wrapup;
  }
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)objID);

  vdppl$Run(pplID = &pplID, name = "getNodePath", ret = &pplRET);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_PATH",
                size  = 128,
                data  = nodePathx);

  vdppl$Delete(pplID = &pplID);

  strcpy(nodePath,nodePathx);
  
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif
/* -----------------------------------
 * Gets the parent node (which could be a tree)
 */
IGRstat VDatGetParentNode(TGRid *objID, TGRid *parentID)
{
  IGRstat retFlag = 0;
  TGRid   nodeID;
  IGRint type;

  // Init
  parentID->objid = NULL_OBJID;

  // Check the type
  VDatGetBaseType(objID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF:
  case VDAT_CLASSI_NODE: {

    VDatGetParentByType(objID,VDAT_CLASSI_NODE,&nodeID);
    if (nodeID.objid != NULL_OBJID) {
      *parentID = nodeID;
      retFlag = 1;
      goto wrapup;
    }
    VDatGetParentByType(objID,VDAT_CLASSI_TREE,&nodeID);
    if (nodeID.objid != NULL_OBJID) {
      *parentID = nodeID;
      retFlag = 1;
      goto wrapup;
    }
  }
  } // Switch

wrapup:
  return retFlag;
}
    
/* -----------------------------------
 * Fills in vla with all parent id's up to tree node
 * Recursive routine
 */
IGRstat VDatGetParentsVLA(TGRid *objID, TVDvlaID *parentVLA)
{
  IGRstat retFlag = 1;
  TGRid   parentID;
  
  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID) || (parentVLA == NULL)) goto wrapup;
  
  // Add it
  VDvlaID_Append(parentVLA,objID);

  // Get the parent
  VDatGetParentNode(objID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  
  VDatGetParentsVLA(&parentID,parentVLA);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------
 * Fills in vla with all node id's
 * Recursive routine
 * If objID is a set then all trees in the set are processed
 */
IGRstat VDatGetNodesVLA(TGRid *objID, TVDvlaID *nodeVLA)
{
  IGRstat retFlag = 0;
  TGRid   treesID,treeID,nodeID;
  IGRint  i;

  IGRint type;

  VDatGetBaseType(objID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF: { // Normal termination
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE: { // Add itself then do all kids

    // Recursive Loop, add itself
    VDvlaID_Append(nodeVLA,objID);
    for(i = 0; VDatGetChildObject(objID,i,&nodeID); i++) {
      VDatGetNodesVLA(&nodeID,nodeVLA);
    }
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_SET: {

    // Get list of trees
    VDatGetTrees(objID,&treesID);
    if (treesID.objid == NULL_OBJID) goto wrapup;

    // Cycle through
    for(i = 0; VDatGetChildObject(&treesID,i,&treeID); i++) {
      VDatGetNodesVLA(&treeID,nodeVLA);
    }
    retFlag = 1;
    goto wrapup;
  }

  }

  // Unusual object, just return

wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Changes type of node by hooking to different
 * rdb node
 */
IGRstar VDatChangeNodeType(TGRid *nodeID, TGRid *rdbNodeID)
{
  IGRstat retFlag = 0;

  // Arg check
  if ((   nodeID == NULL) || (   nodeID->objid == NULL_OBJID)) goto wrapup;
  if ((rdbNodeID == NULL) || (rdbNodeID->objid == NULL_OBJID)) goto wrapup;
  
  // Drop old node
  VDatDelParentByType(nodeID,VDAT_CLASSI_RDB_NODE);
  
  // Add new one
  VDatAddParent(nodeID,rdbNodeID);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Create a new node
 */
IGRstat VDatCreateNode(
  TGRid   *parentID, 
  TGRid   *rdbNodeID, 
  IGRchar *nodeName,
  TGRid   *nodeID
)
{
  IGRstat retFlag = 0;

  // Init
  UI_status("Creating node...");
  nodeID->objid = NULL_OBJID;

  // Create it
  vdat$CreateBase(
    name     = VDAT_CLASSN_NODE,
    type     = VDAT_CLASSI_NODE,
    parentID = parentID,
    baseID   = nodeID
  );
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  VDatSetBaseName(nodeID,nodeName);
  VDatAddParent  (nodeID,rdbNodeID);

  // Xfer default attributes
  VDatSetDefaultAttrs(nodeID);

  retFlag = 1;

wrapup:
  UI_status("");
  return retFlag;
}

/* ------------------------------------------------------
 * Hide exactly how node name is stored
 */
IGRstat VDatSetNodeName(TGRid *nodeID, IGRchar *nodeName)
{
  IGRstat retFlag = 0;
  TVDatFld fld;
  
  // Arg Check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID) || (nodeName == NULL)) goto wrapup;

  // Change the object name
  VDatSetBaseName(nodeID,nodeName);

  // Also update internal node_name attribute
  VDatFldSetTxt(&fld,"node_name",nodeName);
  VDatFldUpdAllAttrs(nodeID,&fld,1);

  // Done
  retFlag = 1;
 
wrapup:
  return retFlag;
}

IGRstat VDatGetNodeName(TGRid *nodeID, IGRchar *nodeName)
{
  IGRstat retFlag = 0;
  
  // Arg Check
  if (nodeName == NULL) goto wrapup;
  *nodeName = 0;

  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Wrapper
  retFlag = VDatGetBaseName(nodeID,nodeName);
  
wrapup:
  return retFlag;
}

IGRstat VDatGetNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  IGRstat retFlag = 0;

  // Arg Check
  if (nodeType == NULL) goto wrapup;
  *nodeType = 0;
  
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Wrapper
  retFlag = VDatRDBGetNodeType(nodeID,nodeType);
  
wrapup:
  return retFlag;
}

end implementation VDatBase;










