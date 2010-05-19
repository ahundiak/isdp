/* $Id: VDatSet.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/VDatSet.I
 *
 * Description: Set Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatSet.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1998/10/25  12:03:50  pinnacle
# ah
#
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

IGRstar VDatVerifyLogin()
{
  IGRstat sts;

  sts = VDSverify_login();
  if (sts & 1) return sts;

  UI_status("Not Logged Into PDM");

  return 0;
}

IGRstar VDatRDBGetSetByType(
  TGRid   *objID, 
  IGRchar *a_rdbSetType, 
  TGRid   *a_rdbSetID)
{
  IGRstat retFlag = 0;

  TGRid   rdbSetsID;
  TGRid   rdbSetID;

  IGRchar rdbSetType[128];

  IGRint i;

  // Init
  a_rdbSetID->objid = NULL_OBJID;

  // Get list of sets
  VDatRDBGetSets(objID,&rdbSetsID);
  if (rdbSetsID.objid == NULL_OBJID) goto wrapup;

  for(i = 0; VDatGetChildObject(&rdbSetsID,i,&rdbSetID); i++) {

    VDatGetBaseName(&rdbSetID,rdbSetType);
    if (strcmp(a_rdbSetType,rdbSetType) == 0) {
      *a_rdbSetID = rdbSetID;
      retFlag = 1;
      goto wrapup;
    }
  }  

wrapup:
  return retFlag;

}

/* -----------------------------------------
 * Gets the RDB Set Object
 * For various objects
 */
IGRstar VDatRDBGetSet(TGRid *objID, TGRid *rdbSetID)
{
  IGRstat retFlag = 0;

  IGRint  type;

  TGRid   rdbNodesID;
  TGRid   setID;
  
  // Init
  rdbSetID->objid = NULL_OBJID;

  // Different objects handled
  VDatGetBaseType(objID,&type);

  switch(type) {

  case VDAT_CLASSI_LEAF:
  case VDAT_CLASSI_NODE:
  case VDAT_CLASSI_TREE: {
    VDatGetSet(objID,&setID);
    if (setID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetSet(&setID,rdbSetID);
    goto wrapup;
  }
  
  case VDAT_CLASSI_SET: {

    // Get the node
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_SET,rdbSetID);
    if (rdbSetID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_SET: {

    *rdbSetID = *objID;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_NODES: {
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_SET,rdbSetID);
    if (rdbSetID->objid == NULL_OBJID) goto wrapup;
  }

  case VDAT_CLASSI_RDB_NODE: {
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_NODES,&rdbNodesID);
    if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetSet(&rdbNodesID,rdbSetID);
    goto wrapup;

  }


  }
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Given an object, find postable table name
 */
IGRstar VDatRDBGetSetType(TGRid *objID, IGRchar  *setType)
{
  IGRstat retFlag = 0;

  TGRid   rdbSetID;

  // Init
  *setType = 0;

  // Find the set
  VDatRDBGetSet(objID,&rdbSetID);
  if (rdbSetID.objid == NULL_OBJID) goto wrapup;

  VDatGetBaseName(&rdbSetID,setType);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Packs rdb sets into vla
 */
IGRstar VDatRDBGetSetsVLA(TGRid *objID, TVDvlaID *setVLA)
{
  IGRstat retFlag = 0;

  TGRid rdbSetsID;
  TGRid rdbSetID;

  IGRint i;

  // Get list of posts
  VDatRDBGetSets(objID,&rdbSetsID);
  if (rdbSetsID.objid == NULL_OBJID) goto wrapup;

  // Transfer
  for(i = 0; VDatGetChildObject(&rdbSetsID,i,&rdbSetID); i++) {
    VDvlaID_Append(setVLA,&rdbSetID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Returns the list of rdb set objects
 * Works on either manager or cache
 */
IGRstar VDatRDBGetSets(TGRid *a_objID, TGRid *rdbSetsID)
{
  IGRstat retFlag = 0;

  TGRid   objID;
  TGRid   rdbCacheID;

  IGRint  type;

  // Init
  rdbSetsID->objid = NULL_OBJID;
  
  // NULL Is OK
  if (a_objID != NULL) objID = *a_objID;
  else                 vdat$GetSetMgr(mgrID = &objID);
  
  // Switch on type
  VDatGetBaseType(&objID,&type);
  switch(type) {

  case VDAT_CLASSI_SET_MGR: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_CACHE,&rdbCacheID);
    if (rdbCacheID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetSets(&rdbCacheID,rdbSetsID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_CACHE: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_SETS,rdbSetsID);
    if (rdbSetsID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_SETS: {

    *rdbSetsID = objID;
    retFlag = 1;
    goto wrapup;

  }

  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Add a set to the list
 */
IGRstar VDatRDBCreateSet(TGRid *setsID, TVDatRDBSetInfo *info, TGRid *setID)
{
  IGRstat retFlag = 0;
  TGRid   nodesID;

  // Create Set Object
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_SET,
    type     = VDAT_CLASSI_RDB_SET,
    parentID = setsID,
    baseID   = setID
  );
  if (setID->objid == NULL_OBJID) goto wrapup;

  VDatSetBaseName  (setID,info->setType);
  VDatRDBSetSetInfo(setID,info);

  // Add in Node objects
  VDatRDBCreateNodes(setID,&nodesID);

  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    UI_status("Problem Loading Set Type");
  }

  return retFlag;
}

/* ----------------------------------------
 * Find all sets defined in rdb
 */
IGRstar VDatRDBCreateSets(TGRid *cacheID, TGRid *setsID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint    tabNumCols = 2;
  IGRint    tabNumRows = 0;
  IGRint    tabRow;
  IGRchar **tabList = NULL;

  TGRid setID;
  TVDatRDBSetInfo setINFO;

  // Create the set manager
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_SETS,
    type     = VDAT_CLASSI_RDB_SETS,
    parentID = cacheID,
    baseID   = setsID
  );
  if (setsID->objid == NULL_OBJID) goto wrapup;

  // Verify Logged in 
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Get the set information
  sts = vdb$RisSelect( 
    select     = "set_type,set_type_desc",
    table_name = VDAT_RDB_TBL_SET_TYPES,
    order      = "set_type",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );
  if (tabNumRows == 0) goto wrapup;

  for(tabRow = 0; tabRow < tabNumRows; tabRow++) {

    strcpy(setINFO.setType,tabList[(tabRow*tabNumCols)+0]);
    strcpy(setINFO.setDesc,tabList[(tabRow*tabNumCols)+1]);

    sts = VDatRDBCreateSet(setsID,&setINFO,&setID);
    if (!(sts & 1)) goto wrapup;

  }

  retFlag = 1;

wrapup:

  if (retFlag != 1) {
    printf("Problem Creating List of Set Types");
  }

  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );
  return retFlag;
}

/* ---------------------------------------------------------
 * Stores info into object
 */
IGRstar VDatRDBSetSetInfo(TGRid *setID, TVDatRDBSetInfo *info)
{
  IGRstat  sts;
  IGRint   cnt;
  TVDatFld flds[4];

  // Store Attributes
  cnt = 0;
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,1,info->setType);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,2,info->setDesc);
  
  sts = VDatFldSetAllAttrs(setID,flds,cnt);

  return sts;
}

/* ---------------------------------------------------------
 * Gets info from object
 */
IGRstar VDatRDBGetSetInfo(TGRid *setID, TVDatRDBSetInfo *info)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  IGRint   cnt;
  TVDatFld flds[4];

  // Clear
  memset(info,0,sizeof(TVDatRDBSetInfo));

  // Get all attributes
  cnt = 0;
  sts = VDatFldGetAllAttrs(setID,flds,&cnt);
  if (!(sts & 1)) goto wrapup;

  // Unpack
  VDatFldGetTxtByIndex(flds,cnt,1,info->setType);
  VDatFldGetTxtByIndex(flds,cnt,2,info->setDesc);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;



