/* $Id: VDatTree.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatTree.I
 *
 * Description: Tree Processing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatTree.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/31  17:09:12  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 03/28/00  ah      Added VDat.h
 ***************************************************************************/

class implementation VDatBase;

#include "VDat.h"

/* -----------------------------------------
 * Gets the tree
 * for various objects
 */
IGRstat VDatGetTree(TGRid *objID, TGRid *treeID)
{
  IGRstat retFlag = 0;

  IGRint  type;

  TGRid  nodeID;
  TGRid treesID;

  // Init
  treeID->objid = NULL_OBJID;

  // Different objects handled
  VDatGetBaseType(objID,&type);

  switch(type) {

  case VDAT_CLASSI_SET: {

    VDatGetChildByType(objID,VDAT_CLASSI_TREES,&treesID);
    if (treesID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatGetTree(&treesID,treeID);
    goto wrapup;
  }

  case VDAT_CLASSI_TREES: {

    VDatGetChildByType(objID,VDAT_CLASSI_TREE,treeID);
    if (treeID->objid == NULL_OBJID) goto wrapup;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: {

    *treeID = *objID;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_LEAF:
  case VDAT_CLASSI_NODE: { 

    // Parent could be either node or tree
    VDatGetParentByType(objID,VDAT_CLASSI_NODE,&nodeID);
    if (nodeID.objid == NULL_OBJID) {
      VDatGetParentByType(objID,VDAT_CLASSI_TREE,&nodeID);
    }
    if (nodeID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatGetTree(&nodeID,treeID);
    goto wrapup;
  }

  }
wrapup:
  return retFlag;
}

/* -----------------------------------
 * Gets tree of given name
 */
IGRstat VDatGetTreeByName(TGRid *objID, IGRchar *a_treeName, TGRid *a_treeID)
{
  IGRstat retFlag = 0;
  TGRid   treesID,treeID;
  IGRchar treeName[128];
  IGRint  i;

  // Init
  a_treeID->objid = NULL_OBJID;

  // Get list of trees
  VDatGetTrees(objID,&treesID);
  if (treesID.objid == NULL_OBJID) goto wrapup;

  // Cycle through
  for(i = 0; VDatGetChildObject(&treesID,i,&treeID); i++) {

    VDatGetBaseName(&treeID,treeName);
    if (strcmp(a_treeName,treeName) == 0) {
      *a_treeID = treeID;
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Given an object, find tree name
 */
IGRstat VDatGetTreeName(TGRid *objID, IGRchar  *treeName)
{
  IGRstat retFlag = 0;

  TGRid   treeID;

  // Init
  *treeName = 0;

  // Find the tree
  VDatGetTree(objID,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  VDatGetBaseName(&treeID,treeName);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------
 * Fills in vla with all trees
 */
IGRstat VDatGetTreesVLA(TGRid *objID, TVDvlaID *treeVLA)
{
  IGRstat retFlag = 0;
  TGRid   treesID,treeID;
  IGRint  i;

  // Get list of sets
  VDatGetTrees(objID,&treesID);
  if (treesID.objid == NULL_OBJID) goto wrapup;

  // Cycle through
  for(i = 0; VDatGetChildObject(&treesID,i,&treeID); i++) {
    VDvlaID_Append(treeVLA,&treeID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Returns the list of tree objects
 */
IGRstat VDatGetTrees(TGRid *objID, TGRid *treesID)
{
  IGRstat retFlag = 0;
  IGRint  type;

  // Init
  treesID->objid = NULL_OBJID;
  
  // Switch on type
  VDatGetBaseType(objID,&type);
  switch(type) {

  case VDAT_CLASSI_SET: {

    VDatGetChildByType(objID,VDAT_CLASSI_TREES,treesID);
    if (treesID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREES: {

    *treesID = *objID;
    retFlag = 1;
    goto wrapup;
  }

  }

wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Create a new tree
 * For now, rdb node is passed, later
 * may find it automatically (last rdb node in set
 */
IGRstat VDatCreateTree(
  TGRid   *setID, 
  TGRid   *rdbNodeID, 
  IGRchar *treeName,
  TGRid   *treeID
)
{
  IGRstat retFlag = 0;
  TGRid   treesID;

  // Init
  treeID->objid = NULL_OBJID;

  // Create a tree list of necessary
  VDatCreateTrees(setID,&treesID);
  if (treesID.objid == NULL_OBJID) goto wrapup;
  
  // Create it
  vdat$CreateBase(
    name     = VDAT_CLASSN_TREE,
    type     = VDAT_CLASSI_TREE,
    parentID = &treesID,
    baseID   = treeID
  );
  if (treeID->objid == NULL_OBJID) goto wrapup;

  VDatSetBaseName(treeID,treeName);
  VDatAddParent  (treeID,rdbNodeID);

  // Xfer default attributes
  VDatSetDefaultAttrs(treeID);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Creates tre list object if one does not already
 * exist
 */
IGRstat VDatCreateTrees(TGRid *setID, TGRid *treesID)
{
  IGRstat retFlag = 0;

  // Init
  treesID->objid = NULL_OBJID;

  // See if exists
  VDatGetTrees(setID,treesID);
  if (treesID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  // Create It
  vdat$CreateBase(
    name     = VDAT_CLASSN_TREES,
    type     = VDAT_CLASSI_TREES,
    parentID = setID,
    baseID   = treesID
  );
  if (treesID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;
