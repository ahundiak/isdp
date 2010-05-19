/* $Id: VDatPost.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/VDatPost.I
 *
 * Description: Postable Tables
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPost.I,v $
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

#define VDAT_TRACE_CREATEx

IGRstar VDatRDBGetPostsVLA(TGRid *objID, TVDvlaID *postVLA)
{
  IGRstat retFlag = 0;

  TGRid rdbPostsID;
  TGRid rdbPostID;

  IGRint i;

  // Get list of posts
  VDatRDBGetPosts(objID,&rdbPostsID);
  if (rdbPostsID.objid == NULL_OBJID) goto wrapup;

  // Transfer
  for(i = 0; VDatGetChildObject(&rdbPostsID,i,&rdbPostID); i++) {
    VDvlaID_Append(postVLA,&rdbPostID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Gets the postable object
 * for a set,leaf or node
 */
IGRstar VDatRDBGetPost(TGRid *objID, TGRid *rdbPostID)
{
  IGRstat retFlag = 0;

  IGRint  type;

  TGRid rdbNodeID;
  TGRid rdbNodesID;
  TGRid rdbSetID;
  TGRid setID;

  // Init
  rdbPostID->objid = NULL_OBJID;

  // Different objects handled
  VDatGetBaseType(objID,&type);

  switch(type) {

  case VDAT_CLASSI_SET: {

    // Get the node
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_SET,&rdbSetID);
    if (rdbSetID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetPost(&rdbSetID,rdbPostID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_SET: {

    // Get the rdb node list
    VDatGetChildByType(objID,VDAT_CLASSI_RDB_NODES,&rdbNodesID);
    if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetPost(&rdbNodesID,rdbPostID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_NODES: {

    // Get the first rdb node in list
    VDatGetChildByType(objID,VDAT_CLASSI_RDB_NODE,&rdbNodeID);
    if (rdbNodeID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetPost(&rdbNodeID,rdbPostID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_NODE: {

    // Should have one post as child
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_POST,rdbPostID);
    if (rdbPostID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE: { // Should have a parent directly linked

    // Get the first rdb node in list
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_NODE,&rdbNodeID);
    if (rdbNodeID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetPost(&rdbNodeID,rdbPostID);
    goto wrapup;
  }

  case VDAT_CLASSI_LEAF: { 

    // May have a parent
    VDatGetParentByType(objID,VDAT_CLASSI_RDB_NODE,&rdbNodeID);
    if (rdbNodeID.objid != NULL_OBJID) {
      retFlag = VDatRDBGetPost(&rdbNodeID,rdbPostID);
      goto wrapup;
    }

    // Use the set
    VDatGetSet(objID,&setID);
    if (setID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetPost(&setID,rdbPostID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_POST: { // Just return itself
    
    *rdbPostID = *objID;
    retFlag = 1;
    goto wrapup;

  }
  }
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Given an object, find postable table name
 */
IGRstar VDatRDBGetTableName(TGRid *objID, IGRchar  *tableName)
{
  IGRstat retFlag = 0;

  TGRid   rdbPostID;

  // Init
  *tableName = 0;

  // Get the post object
  VDatRDBGetPost(objID,&rdbPostID);
  if (rdbPostID.objid == NULL_OBJID) goto wrapup;

  VDatGetBaseName(&rdbPostID,tableName);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Get post object by name
 * Works with manager, cache or posts
 */
IGRstar VDatRDBGetPostByName(
  TGRid   *objID, 
  IGRchar *a_rdbPostName, 
  TGRid   *a_rdbPostID
)
{
  IGRstat retFlag = 0;

  TGRid   rdbPostsID;
  TGRid   rdbPostID;

  IGRchar rdbPostName[128];

  IGRint i;

  // Init
  a_rdbPostID->objid = NULL_OBJID;

  // Get list of posts
  VDatRDBGetPosts(objID,&rdbPostsID);
  if (rdbPostsID.objid == NULL_OBJID) goto wrapup;

  for(i = 0; VDatGetChildObject(&rdbPostsID,i,&rdbPostID); i++) {

    VDatGetBaseName(&rdbPostID,rdbPostName);
    if (strcmp(a_rdbPostName,rdbPostName) == 0) {
      *a_rdbPostID = rdbPostID;
      retFlag = 1;
      goto wrapup;
    }
  }  

wrapup:
  return retFlag;

}

/* --------------------------------------
 * Returns the list of post objects
 * Works on either manager or cache
 */
IGRstar VDatRDBGetPosts(TGRid *a_objID, TGRid *rdbPostsID)
{
  IGRstat retFlag = 0;

  TGRid   objID;
  TGRid   rdbCacheID;

  IGRint  type;

  // Init
  rdbPostsID->objid = NULL_OBJID;
  
  // NULL Is OK
  if (a_objID != NULL) objID = *a_objID;
  else                 vdat$GetSetMgr(mgrID = &objID);
  
  // Switch on type
  VDatGetBaseType(&objID,&type);
  switch(type) {

  case VDAT_CLASSI_SET_MGR: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_CACHE,&rdbCacheID);
    if (rdbCacheID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetPosts(&rdbCacheID,rdbPostsID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_CACHE: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_POSTS,rdbPostsID);
    if (rdbPostsID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_POSTS: {

    *rdbPostsID = objID;
    retFlag = 1;
    goto wrapup;

  }

  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Create Post Table
 */
IGRstar VDatRDBCreatePost(VDosnum osnum, TGRid *postsID, IGRchar *tableName, TGRid *postID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint    attrNum  = 0;
  IGRchar **attrName = NULL;
  IGRchar **attrType = NULL;
  
  IGRint i;

  TVDatFld  flds[VDAT_FLD_MAX];

#ifdef VDAT_TRACE_CREATE
printf("Entered VDatRDBCreatePost %s\n",tableName);
#endif

  // Create Post Object
  vdat$CreateBase(
    osnum    = osnum,
    name     = VDAT_CLASSN_RDB_POST,
    type     = VDAT_CLASSI_RDB_POST,
    parentID = postsID,
    baseID   = postID
  );
  if (postID->objid == NULL_OBJID) goto wrapup;

  VDatSetBaseName(postID,tableName);

  sts = vdb$RetrieveAttributes ( 
    table_name = tableName,
    p_num      = &attrNum,
    p_attr     = &attrName,
    p_type     = &attrType
  );
  if (!(sts & 1)) goto wrapup;

  memset(flds,0,sizeof(flds));

  for(i = 0; i < attrNum; i++) {
    flds[i].type = atoi(attrType[i]);
    strcpy(flds[i].name,attrName[i]);
  }

  VDatFldSetAllAttrs(postID,flds,attrNum);

  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    UI_status("Problem Loading Post Table");
  }

  vdb$RisFreeBuffer(buffer = attrName, size = attrNum);
  vdb$RisFreeBuffer(buffer = attrType, size = attrNum);

#ifdef VDAT_TRACE_CREATE
printf("Exited  VDatRDBCreatePost %s\n",tableName);
#endif
  return retFlag;
}

/* -----------------------------------------------
 * Loads in all postable objects
 */
IGRstar VDatRDBCreatePosts(TGRid *cacheID, TGRid *postsID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid postID;

  IGRint    tabNumCols = 1;
  IGRint    tabNumRows = 0;
  IGRint    tabRow;
  IGRchar **tabList = NULL;

#ifdef VDAT_TRACE_CREATE
printf("Entered VDatRDBCreatePosts\n");
#endif

  // Create the postable table manager
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_POSTS,
    type     = VDAT_CLASSI_RDB_POSTS,
    parentID = cacheID,
    baseID   = postsID
  );
  if (postsID->objid == NULL_OBJID) goto wrapup;

  // Verify Logged in 
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Get the setup information
  sts = vdb$RisSelect( 
    select     = "table_name",
    table_name = VDAT_RDB_TBL_POSTABLE,
    order      = "table_name",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );
  if (tabNumRows == 0) goto wrapup;

  for(tabRow = 0; tabRow < tabNumRows; tabRow++) {
    vdat$RDBCreatePost(postsID   = postsID,
		       tableNAME = tabList[(tabRow*tabNumCols)+0],
		       postID    = &postID);
  }

  retFlag = 1;

wrapup:

  if (retFlag != 1) {
    UI_status("No Postable Tables");
  }

  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );

#ifdef VDAT_TRACE_CREATE
printf("Exited  VDatRDBCreatePosts\n");
#endif

  return retFlag;
}

end implementation VDatBase;

