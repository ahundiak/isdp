/* $Id: VDatSet.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatSet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatSet.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/03/31  17:09:12  pinnacle
# ah
#
# Revision 1.2  1998/11/07  14:04:16  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 03/28/00  ah      Added VDat.h,VDatGetSetByTypeName
 ***************************************************************************/

class implementation VDatBase;

#include "VDat.h"
#include "VDos.h"

/* -----------------------------------------------
 * Search through all os's to find particular set
 */
IGRstat VDatGetSetByTypeName(IGRchar *setType, IGRchar *setName, TGRid *setID)
{
  IGRstat retFlag = 0;
  VDosnum osnum;
  
  TGRid mgrID;
  
  // Arg check
  if (setID == NULL) goto wrapup;
  setID->objid = NULL_OBJID;
  if (setType == NULL) goto wrapup;
  if (setName == NULL) goto wrapup;

  // Cycle through each os
  for(osnum = 0; VDosValidate(osnum); osnum++) {
    VDatGetSetMgr(osnum,&mgrID);
    if (mgrID.objid != NULL_OBJID) {
      VDatGetSetByName(&mgrID,setType,setName,setID);
      if (setID->objid != NULL_OBJID) {
	retFlag = 1;
	goto wrapup;
      }
    }
  }
  
wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Gets the set
 * for a leaf or node
 */
IGRstat VDatGetSet(TGRid *objID, TGRid *setID)
{
  IGRstat retFlag = 0;

  IGRint  type;

  TGRid  nodeID;
  TGRid treesID;
  TGRid  listID;

  // Init
  setID->objid = NULL_OBJID;

  // Different objects handled
  VDatGetBaseType(objID,&type);

  switch(type) {

  case VDAT_CLASSI_SET: {

    *setID  = *objID;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_SETS: {

    VDatGetChildByType(objID,VDAT_CLASSI_SET,setID);
    if (setID->objid == NULL_OBJID) goto wrapup;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREES: {

    VDatGetParentByType(objID,VDAT_CLASSI_SET,setID);
    if (setID->objid == NULL_OBJID) goto wrapup;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: {

    VDatGetParentByType(objID,VDAT_CLASSI_TREES,&treesID);
    if (treesID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatGetSet(&treesID,setID);
    goto wrapup;
  }

  case VDAT_CLASSI_NODE: { 

    // Parent could be either node or tree
    VDatGetParentByType(objID,VDAT_CLASSI_NODE,&nodeID);
    if (nodeID.objid == NULL_OBJID) {
      VDatGetParentByType(objID,VDAT_CLASSI_TREE,&nodeID);
    }
    if (nodeID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatGetSet(&nodeID,setID);
    goto wrapup;
  }

  case VDAT_CLASSI_PIECES :
  case VDAT_CLASSI_PLATES :
  case VDAT_CLASSI_BEAMS  :
  case VDAT_CLASSI_OTHERS :
  case VDAT_CLASSI_LEAFS  :
  case VDAT_CLASSI_LEAF:  { 

    // Can belong to different lists, need better way
    VDatGetParentByType(objID,VDAT_CLASSI_SET,&listID);

    if (listID.objid == NULL_OBJID) {
      VDatGetParentByType(objID,VDAT_CLASSI_LEAFS, &listID);
    }
    if (listID.objid == NULL_OBJID) {
      VDatGetParentByType(objID,VDAT_CLASSI_PIECES,&listID);
    }
    if (listID.objid == NULL_OBJID) {
      VDatGetParentByType(objID,VDAT_CLASSI_PLATES,&listID);
    }
    if (listID.objid == NULL_OBJID) {
      VDatGetParentByType(objID,VDAT_CLASSI_BEAMS, &listID);
    }
    if (listID.objid == NULL_OBJID) {
      VDatGetParentByType(objID,VDAT_CLASSI_OTHERS,&listID);
    }
    if (listID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatGetSet(&listID,setID);
    goto wrapup;
  }
  }
wrapup:
  return retFlag;
}

/* -----------------------------------
 * Gets set of given name
 */
IGRstat VDatGetSetByName(
  TGRid   *a_mgrID, 
  IGRchar *a_setType, 
  IGRchar *a_setName, 
  TGRid   *a_setID
)
{
  IGRstat retFlag = 0;
  TGRid   setsID,setID;

  IGRchar setType[128];
  IGRchar setName[128];

  IGRint  i;

  // Init
  a_setID->objid = NULL_OBJID;

  // Get list of sets
  VDatGetSets(a_mgrID,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Cycle through
  for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {

    VDatRDBGetSetType(&setID,setType);    
    VDatGetBaseName  (&setID,setName);

    if ((!strcmp(a_setType,setType)) && (!strcmp(a_setName,setName))) {
      *a_setID = setID;
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Given an object, find set name
 */
IGRstat VDatGetSetName(TGRid *objID, IGRchar  *setName)
{
  IGRstat retFlag = 0;

  TGRid   setID;

  // Init
  *setName = 0;

  // Find the set
  VDatGetSet(objID,&setID);
  if (setID.objid == NULL_OBJID) goto wrapup;

  VDatGetBaseName(&setID,setName);

  retFlag = 1;

wrapup:
  return retFlag;
}
/* ------------------------------------------------------------
 * Thin wrapper for set type
 */
IGRstat VDatGetSetType(TGRid *objID, IGRchar *setType)
{
  return VDatRDBGetSetType(objID,setType);
}

/* -----------------------------------
 * Fills in vla with all setid's
 */
IGRstat VDatGetSetsVLA(TGRid *objID, TVDvlaID *setVLA)
{
  IGRstat retFlag = 0;
  TGRid   setsID,setID;
  IGRint  i;

  // Get list of sets
  VDatGetSets(objID,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Cycle through
  for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {
    VDvlaID_Append(setVLA,&setID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Returns the list of set objects
 */
IGRstat VDatGetSets(TGRid *a_objID, TGRid *setsID)
{
  IGRstat retFlag = 0;

  TGRid   objID;

  IGRint  type;

  // Init
  setsID->objid = NULL_OBJID;
  
  // NULL Is OK
  if (a_objID != NULL) objID = *a_objID;
  else                 vdat$GetSetMgr(mgrID = &objID);
  
  // Switch on type
  VDatGetBaseType(&objID,&type);
  switch(type) {

  case VDAT_CLASSI_SET_MGR: {

    VDatGetChildByType(&objID,VDAT_CLASSI_SETS,setsID);
    if (setsID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_SETS: {

    *setsID = objID;
    retFlag = 1;
    goto wrapup;
  }

  }

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Create a set
 */
IGRstat VDatCreateSet(
  TGRid   *mgrID, 
  TGRid   *rdbSetID, 
  IGRchar *setName, 
  TGRid   *setID
)
{
  IGRstat retFlag = 0;

  TGRid   setsID;
  TGRid   leafsID;

  // Clear
  setID->objid = NULL_OBJID;

  // Get list of sets
  VDatGetSets(mgrID, &setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Create It
  vdat$CreateBase(
    name     = VDAT_CLASSN_SET,
    type     = VDAT_CLASSI_SET,
    parentID = &setsID,
    baseID   = setID
  );
  if (setID->objid == NULL_OBJID) goto wrapup;

  // Set the name
  VDatSetBaseName(setID,setName);

  // Add template as parent
  VDatAddParent(setID,rdbSetID);

  // Add Leaf Storage
  VDatCreateLeafs(setID,&leafsID);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Given a manager, create list of sets
 */
IGRstat VDatCreateSets(TGRid *mgrID, TGRid *setsID)
{
  IGRstat retFlag = 0;

  vdat$CreateBase(
    name     = VDAT_CLASSN_SETS,
    type     = VDAT_CLASSI_SETS,
    parentID = mgrID,
    baseID   = setsID
  );
  if (setsID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

