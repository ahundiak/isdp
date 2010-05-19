/* $Id: VDatPost.I,v 1.2 2001/04/24 20:40:02 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/post/VDatPost.I
 *
 * Description: Tree posting stuff
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPost.I,v $
 *      Revision 1.2  2001/04/24 20:40:02  jdsauby
 *      Post table timestamp  CR 4474
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.5  2000/01/10  16:40:10  pinnacle
# Posting Testing
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/10/00  ah      Added some ststus messages, keep posting even if errors
 *                   are encountered
 ***************************************************************************/
class implementation VDatBase;

#include "VDris.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDpdm.h"

static int traceFlag;

/* -----------------------------------------------
 * Holds info needed to post a set
 */
typedef struct {
  IGRchar name[ 24];
  IGRchar type[ 24];
  IGRchar desc[128];
  IGRkey  key;
  TGRid   id;
} TVDatPOSTSetInfo;

/* ------------------------------------------
 * Place a post_date timestamp for each table posted to
 * Added for JTS CR 4474 by jds
 */
static void VDatPOSTTimestamp()
{
  IGRstat sts;

  IGRint    tabNumCols = 1;
  IGRint    tabNumRows = 0;
  IGRint    tabRow;
  IGRchar **tabList = NULL;

  // Get list of postable tables
  tabNumCols = 1;
  sts = vdb$RisSelect( 
    select     = "table_name",
    table_name = VDAT_RDB_TBL_POSTABLE,
    order      = "table_name",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );

  // Timestamp each table
  for(tabRow = 0; tabRow < tabNumRows; tabRow++) {
    VDpdmPostTableTimestamp(tabList[(tabRow*tabNumCols)+0]);
  }
  
  // done

wrapup:
  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );
  return;
}

/* ------------------------------------------
 * Convert field list to an insert statement
 */
IGRstar  VDatPOSTInsertFlds(
  TVDatFld *flds, 
  IGRint    cnt, 
  IGRchar  *tableName
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;

  IGRchar  sql[16384];
  IGRchar *pnt;
  TVDatFld *fld;

  // Init
  sprintf(sql,"insert into %s values (",tableName);
  pnt = sql + strlen(sql);

  for(i = 0; i < cnt; i++) {

    fld = &flds[i];
    switch(fld->type) {

    case VDAT_FLD_TYPE_CHAR: {
      sprintf(pnt,"'%s',",fld->valueTxt);
      pnt = pnt + strlen(pnt);
      break;
    } 
    case VDAT_FLD_TYPE_SMALLINT:
    case VDAT_FLD_TYPE_INT: {
      sprintf(pnt,"%d,",fld->valueInt);
      pnt = pnt + strlen(pnt);
      break;
    } 
    case VDAT_FLD_TYPE_REAL:
    case VDAT_FLD_TYPE_DOUBLE: {
      sprintf(pnt,"%f,",fld->valueDbl);
      pnt = pnt + strlen(pnt);
      break;
    } 
    default: {
      printf("Unknown field type\n");
      goto wrapup;
    }}
  }

  // Ending paren, drop last comma
  sprintf(pnt-1,");");
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Update of leaf row failed");
    goto wrapup;
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Posts a given node
 */
IGRstar VDatPOSTNode(
  TVDatPDMInfo     *pdm, 
  TVDatPOSTSetInfo *set, 
  TGRid            *nodeID
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid    tableID;
  IGRchar  tableName[128];
  IGRchar  itemPath[DI_PATH_MAX];

  TVDatFld flds[VDAT_FLD_MAX];
  IGRint   cnt;

  TVDatFld fldsx[VDAT_FLD_MAX];
  IGRint   cntx;

  IGRint i;
  TGRid parentID,childID;

  // Get rdb table template
  VDatRDBGetPost(nodeID,&tableID);
  if (tableID.objid == NULL_OBJID) goto wrapup;
  VDatRDBGetTableName(&tableID,tableName);

  // Copy of attributes to post
  sts = VDatFldGetPostAttrs(tableName,flds, &cnt);
  if (!(sts & 1)) goto wrapup;
  
  VDatFldGetAllAttrs( nodeID, fldsx,&cntx);

  // Xfer any node attributes
  for(i = 0; i < cntx; i++) {
    VDatFldCopy(flds,cnt,&fldsx[i]);
  }

  // Fill them up
  VDatFldSetIntByName(flds,cnt,"file_key",pdm->key);

  VDatFldSetIntByName(flds,cnt,"node_seqno",nodeID->objid);
  VDatFldSetTxtByName(flds,cnt,"node_cat",pdm->cat);
  VDatFldSetTxtByName(flds,cnt,"node_nam",pdm->part);
  VDatFldSetTxtByName(flds,cnt,"node_ver",pdm->rev);

  VDatFldSetIntByName(flds,cnt,"set_key", set->key);
  VDatFldSetTxtByName(flds,cnt,"set_name",set->name);
  VDatFldSetTxtByName(flds,cnt,"set_type",set->type);

  // Node information
  *itemPath = 0;
  VDatGetNodePath(nodeID,itemPath);
  VDatFldSetTxtByName(flds,cnt,"node_path", itemPath);

  *itemPath = 0;
  VDatRDBGetNodeType(nodeID,itemPath);
  VDatFldSetTxtByName(flds,cnt,"node_type", itemPath);

  // Get the parent
  VDatGetParentNode(nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) {
  
    // Insert it
    VDatPOSTInsertFlds(flds,cnt,tableName);

    retFlag = 1;
    goto wrapup;
  }

  // Parent information
  VDatFldSetIntByName(flds,cnt,"parent_seqno",parentID.objid);
  *itemPath = 0;
  VDatGetNodePath(&parentID,itemPath);
  VDatFldSetTxtByName(flds,cnt,"parent_path", itemPath);

  // Order
  for(i = 0; VDatGetChildObject(&parentID,i,&childID); i++) {
    if (childID.objid == nodeID->objid) {
      VDatFldSetIntByName(flds,cnt,"node_order",i);
    }
  }

  // Insert it
  VDatPOSTInsertFlds(flds,cnt,tableName);

  retFlag = 1;

wrapup:
  return retFlag;

}

  
/* -----------------------------------------------
 * Posts a given leaf
 */
IGRstar VDatPOSTLeaf(
  TVDatPDMInfo     *pdm, 
  TVDatPOSTSetInfo *set, 
  TGRid            *leafID,
  TGRobj_env       *itemOE
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid    tableID;
  IGRchar  tableName[128];
  IGRchar  className[128];
  IGRchar  itemPath[DI_PATH_MAX];

  IGRchar  buf[128];

  TVDatFld flds[VDAT_FLD_MAX];
  IGRint   cnt;

  TVDatFld fldsx[VDAT_FLD_MAX];
  IGRint   cntx;

  IGRint i;
  TVDatPDMInfo ref; 

  TGRid parentID,childID;

  // Say hi
  if (traceFlag) {
    printf("----------------\n");
    printf(">>> VDatPOSTLeaf\n");
    vdobj$Print(objID = leafID);
    vdobj$Print(objOE = itemOE);
  }
  
  // Get rdb table template
  VDatRDBGetPost(leafID,&tableID);
  if (tableID.objid == NULL_OBJID) goto wrapup;
  VDatRDBGetTableName(&tableID,tableName);

  // Copy of attributes to post
  sts = VDatFldGetPostAttrs(tableName,flds,&cnt);
  if (!(sts & 1)) {
    if (traceFlag) {
      printf("VDatFldGetPostAttrs failed\n");
    }
    goto wrapup;
  }
  
  // Attributes in leaf itself
  VDatFldGetAllAttrs( leafID, fldsx,&cntx);

  // Xfer any leaf attributes
  for(i = 0; i < cntx; i++) {
    VDatFldCopy(flds,cnt,&fldsx[i]);
  }

  // Fill them up
  VDatFldSetIntByName(flds,cnt,"file_key",pdm->key);

  VDatFldSetIntByName(flds,cnt,"leaf_seqno",leafID->objid);
  VDatFldSetTxtByName(flds,cnt,"leaf_cat",pdm->cat);
  VDatFldSetTxtByName(flds,cnt,"leaf_nam",pdm->part);
  VDatFldSetTxtByName(flds,cnt,"leaf_ver",pdm->rev);

  VDatFldSetIntByName(flds,cnt,"set_key", set->key);
  VDatFldSetTxtByName(flds,cnt,"set_name",set->name);
  VDatFldSetTxtByName(flds,cnt,"set_type",set->type);

  // Get the model object
  VDatPOSTGetPDMInfo(itemOE->obj_id.osnum,&ref);

  VDatFldSetIntByName(flds,cnt,"comp_seqno",  itemOE->obj_id.objid);
  VDatFldSetIntByName(flds,cnt,"assembly_key",ref.key);
  VDatFldSetTxtByName(flds,cnt,"assembly_cat",ref.cat);
  VDatFldSetTxtByName(flds,cnt,"assembly_nam",ref.part);
  VDatFldSetTxtByName(flds,cnt,"assembly_ver",ref.rev);

  // comp_name is a virtual attribute for debugging
  vdsa$GetStruct(objID = leafID, name = VDAT_ATTR_COMP_NAME, txt = buf);
  VDatFldSetTxtByName(flds,cnt,VDAT_ATTR_COMP_NAME,buf);
  
  // Might help in future reconstructs
  *className = 0;
  om$get_classname(
    objid = leafID->objid,
    osnum = leafID->osnum,
    classname = className
  );
  VDatFldSetTxtByName(flds,cnt,"leaf_class",className);

  // Done if not in a tree
  VDatGetParentNode(leafID,&parentID);
  if (parentID.objid == NULL_OBJID) {
  
    // Insert it
    VDatPOSTInsertFlds(flds,cnt,tableName);

    retFlag = 1;
    goto wrapup;
  }

  // Parent information
  VDatFldSetIntByName(flds,cnt,"parent_seqno",parentID.objid);
  *itemPath = 0;
  VDatGetNodePath(&parentID,itemPath);
  VDatFldSetTxtByName(flds,cnt,"parent_path", itemPath);

  // Node information
  *itemPath = 0;
  VDatGetNodePath(leafID,itemPath);
  VDatFldSetTxtByName(flds,cnt,"node_path", itemPath);

  for(i = 0; VDatGetChildObject(&parentID,i,&childID); i++) {
    if (childID.objid == leafID->objid) {
      VDatFldSetIntByName(flds,cnt,"node_order",i);
    }
  }

  // Insert it
  VDatPOSTInsertFlds(flds,cnt,tableName);

  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< VDatPOSTLeaf\n");
  }
  
  return retFlag;

}

/* -----------------------------------------------
 * Posts a given set
 */
IGRstar VDatPOSTSet(TVDatPDMInfo *info, TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDatPOSTSetInfo set;

  IGRchar sql[1024];

  TVDvlaID   nodeVLA;
  TVDvlaID   leafVLA;
  TVDvlaID    refVLA;

  TGRid      nodeID;
  TGRid      leafID;
  TGRid       refID;
  TGRobj_env itemOE;

  IGRint leafI,refI,i;

  TVDatPDMInfo refINFO;

  IGRint nodeCnt = 0;
  IGRint leafCnt = 0;
  
  // Init
  VDvlaID_Empty(&nodeVLA);
  VDvlaID_Empty(&leafVLA);
  VDvlaID_Empty(&refVLA);

  *set.name = 0;
  
  // Arg Check
  if (info->key == 0)             goto wrapup;
  if (setID->objid == NULL_OBJID) goto wrapup;
  set.id = *setID;

  // Verify logged in
  if (!VDatVerifyLogin()) goto wrapup;

  // Get the new key
  VDatPOSTGetNextSetKey(&set.key);
  if (set.key == 0) goto wrapup;

  // Need set name, type and description
  VDatGetSetName(setID,set.name);
  VDatGetSetType(setID,set.type);
  *set.desc = 0;

  // Status
  sprintf(sql,"Posting %s ...",set.name);
  UI_status(sql);

  // Update new key
  sprintf(sql,
    "insert into %s values ("
    "%d,%d,%d, '%s','%s','%s', '%s','%s','%s');",
     VDAT_RDB_TBL_SET_KEYS,
     info->key,set.key,set.id.objid,
     info->cat,info->part,info->rev,
     set.name,set.type,set.desc
  );

  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Update of set key failed");
    goto wrapup;
  }
  retFlag = 1;

  /* Need to update the list of reference file used by the set
   * Kind of expensive but makes query's easier
   */
  VDatGetLeafsVLA(setID,&leafVLA);
  for(leafI = 0; VDvlaID_GetAt(&leafVLA,&leafID,leafI); leafI++) {

    VDatGetLeafObject(&leafID, &itemOE);
    if (itemOE.obj_id.objid == NULL_OBJID) {
      //UI_status("Problem getting item for a leaf");
      printf("*** Leaf will NOT be posted\n");
      //vdobj$Print(objID = &leafID);
      //goto wrapup;
    }
    else {
      
      for(refI = 0; 
	  VDvlaID_GetAt(&refVLA,&refID,refI) &&
	    itemOE.obj_id.osnum != refID.osnum; 
	  refI++);

      if (itemOE.obj_id.osnum != refID.osnum) {

	// Just a dummy id to hold the osnum
	refID.osnum = itemOE.obj_id.osnum;
	refID.objid = NULL_OBJID;

	// Get the pdm info
	VDatPOSTGetPDMInfo(refID.osnum,&refINFO);
	if (refINFO.key == 0) {
	  UI_status("Problem getting pdm info for ref file");
	  goto wrapup;
	}

	// Update new releation
	sprintf(sql,
		"insert into %s values(%d,%d,%d);",
		VDAT_RDB_TBL_SET_REF_KEYS,
		info->key,set.key,refINFO.key
		);
	//printf("SQL %s\n",sql);
      
	sts = VDSexecute_sql_stmt(sql);
	if (!(sts & 1)) {
	  UI_status("Update of set to file failed");
	  goto wrapup;
	}

	// Keep track of ones posted
	VDvlaID_Append(&refVLA,&refID);

      }
      // And post it
      VDatPOSTLeaf(info,&set,&leafID,&itemOE);
      leafCnt++;
    }
  }

  // Post any nodes
  VDatGetNodesVLA(setID,&nodeVLA);
  for(i = 0; VDvlaID_GetAt(&nodeVLA,&nodeID,i); i++) {
    VDatPOSTNode(info,&set,&nodeID);
    nodeCnt++;
  }

wrapup:

  sprintf(sql,"Posted %s, %u nodes, %u leafs",set.name,nodeCnt,leafCnt);
  UI_status(sql);

  VDvlaID_Delete(&nodeVLA);
  VDvlaID_Delete(&leafVLA);
  VDvlaID_Delete(&refVLA);

  return retFlag;
}

/* -----------------------------------------------
 * Deletes all "file_key" entries from a table
 */
IGRstar VDatPOSTDeleteFileKey(IGRchar *tblName, IGRkey fileKEY)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar sql[1024];

  // Easy Enough
  sprintf(sql,
    "delete from %s where file_key = %d;",
    tblName,fileKEY
  );
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Deletion of table failed");
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Deletes anything previously posted from this file
 */
IGRstar VDatPOSTDeleteAll(TVDatPDMInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint    tabNumCols = 1;
  IGRint    tabNumRows = 0;
  IGRint    tabRow;
  IGRchar **tabList = NULL;

  // Arg check
  if (info->key == 0) goto wrapup;

  // Some predefined tables
  VDatPOSTDeleteFileKey(VDAT_RDB_TBL_SET_KEYS,    info->key);
  VDatPOSTDeleteFileKey(VDAT_RDB_TBL_SET_REF_KEYS,info->key);

  // Get list of postable tables
  tabNumCols = 1;
  sts = vdb$RisSelect( 
    select     = "table_name",
    table_name = VDAT_RDB_TBL_POSTABLE,
    order      = "table_name",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );

  // Delete Each
  for(tabRow = 0; tabRow < tabNumRows; tabRow++) {
    VDatPOSTDeleteFileKey(tabList[(tabRow*tabNumCols)+0],info->key);
  }
  
  retFlag = 1;

wrapup:
  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );
  return retFlag;
}

/* -----------------------------------------------
 * This routine starts up the posting process
 * for the active file
 */
IGRstar VDatPOSTAll()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i = 0;

  TGRid   mgrID;
  TGRid   pdmID;
  TGRid   setID;

  TVDatPDMInfo info;

  TVDvlaID setVLA;

  IGRchar buf[128];
  
  // Do Nothing if no active manager
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    retFlag = 1;
    return retFlag;
  }

  // Init
  VDvlaID_Empty(&setVLA);
  UI_status("Posting Sets");
  //traceFlag = 1;
  if (traceFlag) {  
    printf("======= Posting Sets =========\n");
  }
  
  // Do nothing if not logged in
  sts = VDatVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // Make a list of files and cache their pdm info
  vdat$CreatePdmMgr(mgrID = &pdmID);
  if (pdmID.objid == NULL_OBJID) {
    printf("*** Unable to create pdm manager\n");
    goto wrapup;
  }
  
  // Get the file key to work with
  VDatPOSTGetPDMInfo(mgrID.osnum,&info);
  if (info.key == 0) {
    printf("*** Unable to get pdm info\n");
    goto wrapup;
  }
  
  // Delete any previously posted information
  // From this file
  sts = VDatPOSTDeleteAll(&info);
  if (!(sts & 1)) goto wrapup;

  // Get a list of sets to post
  VDatGetSetsVLA(&mgrID,&setVLA);

  for(i = 0; VDvlaID_GetAt(&setVLA,&setID,i); i++) {
    VDatPOSTSet(&info,&setID);
  }

  // Add a posted timestamp for each table.  (JTS CR 4474)
  VDatPOSTTimestamp();

  retFlag = 1;

wrapup:
  VDvlaID_Delete(&setVLA);
  if (retFlag == 0) UI_status("Set Posting Failed!");
  else {
    sprintf(buf,"Posted %d Set(s)",i);
    UI_status(buf);
  }
  
  return retFlag;
}

#if 0
  strcpy(sql,
    "Insert into vdat_post_sets "
    "(set_seqno,set_cat,set_nam,set_ver,"
    "set_id,set_name,set_type) "
    "values "
    "(1234,'cat','part','ver',"
    "12,'531','AssyTree');"
  );
#endif

end implementation VDatBase;


