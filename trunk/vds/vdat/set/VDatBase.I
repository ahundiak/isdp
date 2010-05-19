/* $Id: VDatBase.I,v 1.5 2001/02/08 20:41:02 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatBase.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatBase.I,v $
 *      Revision 1.5  2001/02/08 20:41:02  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/01/23 13:58:24  ahundiak
 *      mixup
 *
 *      Revision 1.2  2001/01/11 21:12:34  art
 *      sp merge
 *
# Revision 1.2  2000/11/27  19:14:30  pinnacle
# ah
#
# Revision 1.2  2000/01/10  19:20:04  pinnacle
# ah
#
# Revision 1.1  1998/11/07  14:04:02  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1

 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/26/99  ah      creation
 * 01/10/00  ah      Added checks for nodes with < 2 kids
 * 10/30/00  ah      When checking the tree, deleting a leaf would cause next
 *                   leaf to be skipped
 * 11/09/00  ah      When checking a set, do leafs first then do the tree
 *                   Otherwise, end up skipping leafs not in tree
 * 02/08/01  ah      Added model part name to the deleting leaf message
 ***************************************************************************/

class implementation VDatBase;

#include "VDobj.h"

typedef IGRchar TVDatBaseTypez[64];
typedef IGRchar TVDatBaseNamez[64];

typedef IGRchar TVDatBaseInfoz[128];

typedef IGRchar TVDatBaseTablez[64];
typedef IGRchar TVDatBaseDescz [64];
typedef IGRint  TVDatBaseIntz;


IGRstar VDatCreateBaseInfo(TGRid *objID, TVDatBaseInfoz info);
IGRstar VDatVerifyMgr     (TGRid *mgrID);
IGRstar VDatVerifySet     (TGRid *setID);
IGRstar VDatVerifyBase    (TGRid *objID);

IGRstat VDatGetBaseSetType1 (TGRid *objID, TVDatBaseInfoz info);
IGRstat VDatGetBaseSetName1 (TGRid *objID, TVDatBaseInfoz info);
IGRstat VDatGetBaseNodeType1(TGRid *objID, TVDatBaseInfoz info);
IGRstat VDatGetBaseNodeName1(TGRid *objID, TVDatBaseInfoz info);

extern VDclassid OPP_VDatBase_class_id;

/* -----------------------------------
 * Check the base objects
 * 
 * Make sure the leaf is connected
 *
 * Make sure that nodes have at least two kids
 *
 * Recursive routine in which the objID can be different
 * objects (set,node or tree)
 */
IGRstat VDatCheckBase(TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   leafsID,listID,leafID,treeID;
  IGRint  i,j;

  TGRid  leafIDx;
  TGRid  childID;
  TGRid  childIDx;
  
  IGRint type;

  IGRchar nodeType[128],nodeName[128];

  TVDatFld fld;
  
  IGRint traceFlag = 0;
  
  VDatGetBaseType(objID,&type);

  if (traceFlag) {
    printf(">>> VDatCheckBase %d,%d Type %d\n",objID->osnum,objID->objid,type);
  }
  
  switch(type) {

  case VDAT_CLASSI_LEAF: {
    sts = VDatLeafVerifyPiece(objID);
    if (!(sts & 1)) {

      // Indicate what it used to hook to
      VDatFldGetAttrByName(objID,VDAT_ATTR_COMP_PATH,&fld);

      // If the model can't be found, delete it
      printf("*** Deleting leaf node %d,%d\n",objID->osnum,objID->objid);
      printf("    Model Object Path '%s'\n",fld.valueTxt);
      
      VDatDeleteBase(objID);

    }    
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_SET: {
    
    // Check just the leafs first
    VDatGetLeafs(objID,&leafsID);
    for(i = 0; VDatGetChildObject(&leafsID,i,&listID); i++) {
      for(j = 0; VDatGetChildObject(&listID,j,&leafID); j++) {
        VDatCheckBase(&leafID);

	// Check to see if leaf was deleted
	VDatGetChildObject(&listID,j,&leafIDx);
	if ((leafID.objid != leafIDx.objid) ||
	    (leafID.osnum != leafIDx.osnum)) {
	  j--;
	}
      }
    }
    // Check any tree
    VDatGetTree(objID,&treeID);
    if (treeID.objid != NULL_OBJID) {
      VDatCheckBase(&treeID);
    }
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE: {

    // Recursive Loop
    for(i = 0; VDatGetChildObject(objID,i,&childID); i++) {
      VDatCheckBase(&childID);

      // Check to see if leaf was deleted
      VDatGetChildObject(objID,i,&childIDx);
      if ((childID.objid != childIDx.objid) ||
	  (childID.osnum != childIDx.osnum)) {
	i--;
      }
    }
    retFlag = 1;
    if (i < 2) {

      VDatGetNodeType(objID,nodeType);
      VDatGetNodeName(objID,nodeName);

      // This should really be in a ppl
      if (!strcmp(nodeType,"UNIT")) goto wrapup;
      if (!strcmp(nodeType,"SAF"))  goto wrapup;
      if (!strcmp(nodeType,"SAB"))  goto wrapup;
      if (!strcmp(nodeType,"SAE"))  goto wrapup;
      
      // Warn the user
      printf("*** Warning: Node %s %s has less than two children\n",nodeType,nodeName);
    }
    goto wrapup;
  }

  }

  // Unusual object, just return

wrapup:
  if (traceFlag) {
    printf("<<< VDatCheckBase %d,%d Type %d\n",objID->osnum,objID->objid,type);
  }
  return retFlag;
}

/* ------------------------------------------------
 * Recursive routine to verify a base object
 */
IGRstar VDatVerifyBase(TGRid *objID)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  TVDatFld fld;
  TVDatBaseInfoz info;
  IGRint   i;
  TGRid    childID;

  // Arg check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Only VDatBase objects need apply
  sts = vdobj$IsAncestryValid(
    objID = objID, 
    superClassID = OPP_VDatBase_class_id);

  if (!(sts & 1)) {
    retFlag = 1;
    goto wrapup;
  }

  // Get the key
  VDatCreateBaseInfo(objID,info);

  // Add to object
  VDatFldSetTxt(&fld,VDAT_ATTR_BASE_INFO,info);
  VDatFldUpdAllAttrs(objID,&fld,1);

  // Do the same for the kids
  for(i = 0; 
      vdat$GetObj(objID = objID, nth = i, childID = &childID);
      i++) {
    VDatVerifyBase(&childID);
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Verifes a set, mainly used to upgrade set to
 * latest revision
 */
IGRstar VDatVerifySet(TGRid *setID)
{
  IGRstat  retFlag = 0;
  TVDatFld fld;

  // Arg check
  if ((setID == NULL) || (setID->objid == NULL_OBJID)) goto wrapup;

  // For now, the presence of base_info is enough
  VDatFldGetAttrByName(setID,VDAT_ATTR_BASE_INFO,&fld);
  if (*fld.name) {
    retFlag = 1;
//  printf("Got it\n");
    goto wrapup;
  }

  // Kick off recursive check of all base'es in the set
  VDatVerifyBase(setID);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Each time the manager is requested, this
 * function is called to verify it
 * 
 * This is a good reason not get the mgr unless needed
 */
IGRstar VDatVerifyMgr(TGRid *mgrID)
{
  IGRstat retFlag = 0;

  TGRid setsID;
  TGRid setID;
  IGRint i;

  VDosnum osnum;

  // printf("=============================\n");

  // Arg check
  if ((mgrID == NULL) || (mgrID->objid == NULL_OBJID)) goto wrapup;

  // Only verify sets in the current os
  ex$get_cur_mod(osnum = &osnum);
  if (mgrID->osnum != osnum) {
    retFlag = 1;
    goto wrapup;
  }

  // Get the list of sets
  VDatGetSets(mgrID,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Cycle through
  for(i = 0; 
      vdat$GetObj(objID = &setsID, nth = i, childID = &setID); 
      i++) {

    VDatVerifySet(&setID);

  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

#define VDAT_BASE_SEP '@'

/* ------------------------------------------------
 * Pull general information from base info attr
 */
IGRstar VDatGetBaseInfo(
  TGRid   *objID, 

  TVDatBaseInfoz info,
  TVDatBaseTypez setType,
  TVDatBaseIntz *setRev,
  TVDatBaseNamez setName,
  TVDatBaseTypez nodeType,
  TVDatBaseNamez nodeName)
{
  IGRstat retFlag = 0;

  TVDatFld fld;

  IGRchar *p1,*p2;

  // Init
  if (info)     *info     = 0;
  if (setType)  *setType  = 0;
  if (setRev )  *setRev   = 0;
  if (setName)  *setName  = 0;
  if (nodeType) *nodeType = 0;
  if (nodeName) *nodeName = 0;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  VDatFldGetAttrByName(objID,VDAT_ATTR_BASE_INFO,&fld);
  if (*fld.name == 0) goto wrapup;

  // Entire string
  p1 = fld.valueTxt;
  if (info) strcpy(info,p1);

  // Set type
  p2 = strchr(p1,VDAT_BASE_SEP);
  if (p2 == NULL) goto wrapup; 
  *p2 = 0;
  if (setType) strcpy(setType,p1);
  p1 = p2 + 1;

  // Set rev
  p2 = strchr(p1,VDAT_BASE_SEP);
  if (p2 == NULL) goto wrapup;
  *p2 = 0;
  if (setRev) *setRev = atoi(p1);
  p1 = p2 + 1;

  // Set name
  p2 = strchr(p1,VDAT_BASE_SEP);
  if (p2 == NULL) goto wrapup;
  *p2 = 0;
  if (setName) strcpy(setName,p1);
  p1 = p2 + 1;

  // Node Type
  p2 = strchr(p1,VDAT_BASE_SEP);
  if (p2 == NULL) goto wrapup;
  *p2 = 0;
  if (nodeType) strcpy(nodeType,p1);
  p1 = p2 + 1;

  // Node Name
  p2 = strchr(p1,VDAT_BASE_SEP);
  if (p2 == NULL) goto wrapup;
  *p2 = 0;
  if (nodeName) strcpy(nodeName,p1);
  p1 = p2 + 1;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * For converting older classes, make a base_key
 * using channels and whatnot
 */
IGRstar VDatCreateBaseInfo(TGRid *objID, TVDatBaseInfoz info)
{
  IGRstat retFlag = 0;

  IGRchar setType [64];
  IGRchar setName [64];
  IGRchar nodeType[64];
  IGRchar nodeName[64];

  // Arg Check
  if (info == NULL) goto wrapup;
  *info = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Init
  *setType  = 0;
  *setName  = 0;
  *nodeType = 0;
  *nodeName = 0;

  VDatGetBaseSetType1 (objID,setType);
  VDatGetBaseSetName1 (objID,setName);
  VDatGetBaseNodeType1(objID,nodeType);
  VDatGetBaseNodeName1(objID,nodeName);

  sprintf(info,"%s%c%02d%c%s%c%s%c%s%c",
    setType, VDAT_BASE_SEP,
    0,       VDAT_BASE_SEP,
    setName, VDAT_BASE_SEP,
    nodeType,VDAT_BASE_SEP,
    nodeName,VDAT_BASE_SEP);
/*
  printf("%-20s ",info);
  vdobj$Print(objID = objID);
*/
  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Special routines for extracting old information
 * from nodes to convert to new format
 */
IGRstar VDatGetBaseNodeType1(TGRid *objID, TVDatBaseInfoz info)
{
  IGRstat retFlag = 1;
  IGRint  type;

  TGRid   rdbID;

  // Arg check
  if (info == NULL) goto wrapup;
  *info = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Process differently based on type of object
  VDatGetBaseType(objID,&type);

  switch(type) {

    case VDAT_CLASSI_TREE:
    case VDAT_CLASSI_NODE:
    case VDAT_CLASSI_LEAF:

      // Should have a link to the rdb node
      vdat$GetObj(objID    = objID, 
                  type     = VDAT_CLASSI_RDB_NODE, 
                  parentID = &rdbID);
      if (rdbID.objid == NULL_OBJID) goto wrapup;

      VDatGetBaseName(&rdbID,info);

      retFlag = 1;
      goto wrapup;
#if 0
    case VDAT_CLASSI_RDB_NODE:

      VDatGetBaseName(objID,info);
      retFlag = 1;
      goto wrapup;
#endif
  }

  // Other items have none
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Special routines for extracting old information
 * from nodes to convert to new format
 */
IGRstar VDatGetBaseNodeName1(TGRid *objID, TVDatBaseInfoz info)
{
  IGRstat retFlag = 1;
  IGRint  type;

  // Arg check
  if (info == NULL) goto wrapup;
  *info = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Process differently based on type of object
  VDatGetBaseType(objID,&type);

  switch(type) {

    case VDAT_CLASSI_TREE:
    case VDAT_CLASSI_NODE:
    case VDAT_CLASSI_LEAF:

      VDatGetBaseName(objID,info);
      retFlag = 1;
      goto wrapup;
  }

  // Other items have none
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Special routines for extracting old information
 * from nodes to convert to new format
 */
IGRstar VDatGetBaseSetName1(TGRid *objID, TVDatBaseInfoz info)
{
  IGRstat retFlag = 1;
  TGRid   setID;

  // Arg check
  if (info == NULL) goto wrapup;
  *info = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Multiple parents make finding set a bit difficult
  VDatGetSet(objID,&setID);
  if (setID.objid == NULL_OBJID) goto wrapup;

  VDatGetBaseName(&setID,info);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Special routines for extracting old information
 * from nodes to convert to new format
 */
IGRstar VDatGetBaseSetType1(TGRid *objID, TVDatBaseInfoz info)
{
  IGRstat retFlag = 1;
  TGRid   setID;

  // Arg check
  if (info == NULL) goto wrapup;
  *info = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Multiple parents make finding set a bit difficult
  VDatGetSet(objID,&setID);
  if (setID.objid == NULL_OBJID) goto wrapup;

  VDatRDBGetSetType(&setID,info);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;



