 /* $Id: VDct1Post.I,v 1.1 2001/01/12 14:42:54 art Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Post.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Post.I,v $
 *      Revision 1.1  2001/01/12 14:42:54  art
 *      sp merge
 *
# Revision 1.5  2000/07/07  11:17:36  pinnacle
# pn
#
# Revision 1.4  2000/06/23  16:48:44  pinnacle
# pn
#
# Revision 1.3  2000/05/09  19:25:40  pinnacle
# Replaced: vds/vdct1/post/VDct1Post.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/05  15:12:14  pinnacle
# pn
#
# Revision 1.1  2000/04/20  18:50:42  pinnacle
# Created: vds/vdct1/post/VDct1Post.I by pnoel for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/31/00  pn      Creation
 * 06/23/00  pn      fix PDU crash on no files
 *
 ***************************************************************************/

class implementation VDct1Base;
#include "VDtypedef.h"
#include "VDris.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDatMaster.h"
#include "VDvla.h"
#include "VDct1.h"
#include "VDct1Cmd.h"
#include "VDppl1.h"

static int traceFlag;
//#if 0
/* -----------------------------------------------
 * Holds info needed to post a set
 */
typedef struct {
  IGRchar name[ 24];
  IGRchar type[ 24];
  IGRchar desc[128];
  IGRkey  key;
  TGRid   id;
} TVDct1POSTSetInfo;

/* -------------------------------------------------
 * PPL wrapper for setting TVDatFld fld; values on exception to the 
 * absence or other conditions of the attribute to fill it in the NODE
 * I - *nodeID;   
 * I - *baseInfo;          of nodeID
 * I - *parentID;          of nodeID
 * I - *parentBaseInfo;    of parentID
 * I/O *fld;               of current data field  returns with data
 * works on exceptions not on every case
 * alters data in the *fld on exception otherwise data remains same
 */
IGRstat VDct1GetFldData(TGRid    *nodeID,
			TVDatFld flds[VDAT_FLD_MAX],
			IGRint   cnt)
{

  IGRstat retFlag = 0; // always return 0 only for no arguments
  TGRid   pplID, parentID;
  IGRint  pplRet;
  TVDctBaseInfo parentBaseInfo, baseInfo;
  IGRstat sts = 1;
  IGRint  traceFlag = 0;
  
  // say hi
  if (traceFlag) printf(">>> VDct1GetFldData\n");

  // args check
  if ((nodeID == NULL)   || (nodeID->objid == NULL_OBJID))   goto wrapup;
  if(flds == 0) goto wrapup;
  if (traceFlag) printf("passed args check\n");
  
  // get the parentID
  vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);  
  // Just call ppl

  if (parentID.osnum == 0) {
    parentID.osnum = nodeID->osnum;
    parentID.objid = nodeID->objid;
  }
  
  vdct1$GetBaseInfo(objID = &parentID, baseInfo = &parentBaseInfo);
  if (*parentBaseInfo.nodeType == 0) {
    goto wrapup;
  }
  
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) {
    goto wrapup;
  }
  
  // load the ppl
  vdppl$Load(name = parentBaseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup; 
  
  //set the data
  vdppl$SetData(pplID = &pplID,
		name = "BASE_INFO_PARENT",
		size = sizeof(TVDctBaseInfo),
		data = (IGRchar*)&parentBaseInfo);

  vdppl$SetData(pplID = &pplID,
	        name  = "NODE_PARENT_ID",
		size  = sizeof(TGRid),
		data  = (IGRchar*)&parentID);

  vdppl$SetData(pplID = &pplID,
		name = "BASE_INFO",
		size = sizeof(TVDctBaseInfo),
		data = (IGRchar*)&baseInfo);

  vdppl$SetData(pplID = &pplID,
	        name  = "NODE_ID",
		size  = sizeof(TGRid),
		data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
	        name  = "LIST_IND",
		size  = sizeof(IGRint),
		data  = (IGRchar*)&cnt);

  vdppl$SetData(pplID = &pplID,
	        name  = "FLDS",
		size  = sizeof(TVDatFld)*VDAT_FLD_MAX,
		data  = (IGRchar*)flds);  

  //run the ppl
  vdppl$Run(pplID = &pplID, name = "pdmFldsData", ret = &pplRet);
  if (traceFlag) printf("PPL RAN\n");
  
  if (pplRet == 0) goto wrapup;  
  
  vdppl$GetData(pplID = &pplID,
	        name  = "FLDS",
		size  = sizeof(TVDatFld)*VDAT_FLD_MAX,
		data  = (IGRchar*)flds);  

  // set status
  retFlag = pplRet;

wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1GetFldData(%d)\n",retFlag);
  return retFlag;
  
}
   // call ppl to get tableName
//VDct1GetTableName(&childID,tableName);
/* -----------------------------------------
 * PPL wrapper to get tableName
 */
IGRstat VDct1GetTableName(TGRid *nodeID, IGRchar table[128])
{
  IGRstat        traceFlag = 0;
  IGRstat        retFlag = 0;
  TGRid          pplID;
  IGRint         pplRet;
  TVDctBaseInfo  baseInfo;
  IGRstat sts = 1;  

  if (traceFlag) printf(">>> VDct1GetTableName\n");
  strcpy(table,"");
  
  // args check
  if ((nodeID == NULL)   || (nodeID->objid == NULL_OBJID))   goto wrapup;

  // get the baseinfo 
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  if (traceFlag) {
    printf("\nGetTable baseInfo.\n");
    printf("nodeType[%s] nodeName[%s] \nsetType[%s]  setName[%s]\n",
	   baseInfo.nodeType,baseInfo.nodeName,baseInfo.setType,baseInfo.setName);
    
  }
  
  // load the ppl
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup; 

  // send in the info
  vdppl$SetData(pplID = &pplID,
	        name  = "TABLE_NAME",
		size  = 128,
		data  = (IGRchar*)table); 

  //run the ppl
  vdppl$Run(pplID = &pplID, name = "pdmGetTableName", ret = &pplRet);
  if (pplRet == 0) goto wrapup;  

  vdppl$GetData(pplID = &pplID,
	        name  = "TABLE_NAME",
		size  = 128,
		data  = (IGRchar*)table); 
  if (traceFlag) printf("Table is [%s]\n",table);
  
  if (table == 0) goto wrapup;
  if (!strcmp(table,"")) goto wrapup;
  
  

  // success!
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1GetTableName(%d)\n",retFlag);
  return retFlag;
}


/* ------------------------------------------
 * Convert field list to an insert statement
 * [z1]
 */
IGRstar  VDct1POSTInsertFlds( 
  TVDatFld  *flds, 
  IGRint     cnt, 
  IGRchar   *tableName
)
{
  IGRstat    retFlag = 0;
  IGRstat    traceFlag = 0;
  IGRstat    sts;
  IGRint     i;
  IGRchar    fldName[128], fldType[128], fldValue[128], fldSQL[128];
  IGRchar    sql[16384];
  IGRchar   *pnt;
  TVDatFld  *fld;

  // say hi
  if (traceFlag) printf(">>> VDct1POSTInsertFlds\n");
  
  // Init
  sprintf(sql,"insert into  %s (",tableName);
  pnt = sql + strlen(sql);

  for(i = 0; i < cnt; i++){
    fld = &flds[i];
    sprintf(pnt,"%s,",fld->name);
    pnt = pnt + strlen(pnt);
  }

  // add the data lose the last comma
  sprintf(pnt-1,") values (");
  pnt = pnt + strlen(pnt);

  for(i = 0; i < cnt; i++) {

    fld = &flds[i];

    // sprintf(fldName,"fld  Name[%s] ",fld->name);
    // sprintf(fldType,"Type[%d] ",fld->type);
    
    switch(fld->type) {

    case VDAT_FLD_TYPE_CHAR: {
      sprintf(pnt,"'%s',",fld->valueTxt);
      // sprintf(fldSQL,"(S)->'%s',",fld->valueTxt);
      pnt = pnt + strlen(pnt);
      break;
    } 
    case VDAT_FLD_TYPE_SMALLINT:
    case VDAT_FLD_TYPE_INT: {
      sprintf(pnt,"%d,",fld->valueInt);
      // sprintf(fldSQL,"(D)->%d,",fld->valueInt);
      pnt = pnt + strlen(pnt);
      break;
    } 
    case VDAT_FLD_TYPE_REAL:
    case VDAT_FLD_TYPE_DOUBLE: {
      sprintf(pnt,"%f,",fld->valueDbl);
      // sprintf(fldSQL,"(F)->%f,",fld->valueDbl);
      pnt = pnt + strlen(pnt);
      break;
    } 
    default: {
      //printf("Unknown field type\n");
      goto wrapup;
    }}
  }

  // Ending paren, drop last comma
  sprintf(pnt-1,");");
  
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Update of pdm from node failed");
    goto wrapup;
  }
  else
  {
    if (traceFlag) printf("SQL VDSexecute[post] = [%s]\n",sql);
  }
  
  retFlag = 1;

wrapup:
   // say bye
  if (traceFlag) printf("<<< VDct1POSTInsertFlds(%d)\n",retFlag); 
  return retFlag;
}

/* -----------------------------------------------
 * Post the sets for TM
 */
IGRstat VDct1PostNodesPdm(TVDatPDMInfo *info, TGRid *parentID, TVDct1POSTSetInfo *set)
{
  //#if 0
  IGRstat           retFlag = 0;
  IGRstat           traceFlag = 0;
  IGRstat           sts, i;
  TGRid             childID, tableID;
  IGRchar           tableName[128];
  TVDatFld          flds[VDAT_FLD_MAX], fldsx[VDAT_FLD_MAX];
  IGRint            cnt, cntx;
  IGRchar          *pnt;
  TVDatFld         *fld;
  TVDctBaseInfo     baseInfo;  

  // get the baseinfo 
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &baseInfo);

  //#if 0
  if (traceFlag) {
    printf(">>> VDct1PostNodesPdm\n");
    printf("parentID->osnum [%d] ->objid [%d]\n",parentID->osnum,parentID->objid);
    printf("baseInfo.nodeType [%s] .nodeName [%s]\n",baseInfo.nodeType,baseInfo.nodeName);
    
  }
  
  //#endif
  // args check 
  if ((parentID->objid == NULL_OBJID) || (parentID == NULL))  goto wrapup;
  if (info == 0) goto wrapup;

   // Verify logged in
  if (!VDatVerifyLogin()) goto wrapup;
  //#if 0

  // load up the node fields
    // call ppl to get tableName
  sts = VDct1GetTableName(parentID,tableName);
  if (!(sts & 1)) {
    if (traceFlag) {
      printf("VDct1GetTableName failed\n");
    }
    goto wrapup;
  }   

  // Copy of attributes to post
  sts = VDatFldGetPostAttrs(tableName,flds, &cnt);
  if (!(sts & 1)) goto wrapup;

  
  VDatFldGetAllAttrs( parentID, fldsx,&cntx);

  // Xfer any node attributes
  for(i = 0; i < cntx; i++) {
    VDatFldCopy(flds,cnt,&fldsx[i]);
  }

  // load up the fields with attribute data
  if(traceFlag) printf("setting the field data by name\n");
  VDatFldSetIntByName(flds,cnt,"file_key",info->key);
  VDatFldSetTxtByName(flds,cnt,"pdm_catalog",info->cat);
  VDatFldSetTxtByName(flds,cnt,"pdm_part",info->part);
  VDatFldSetTxtByName(flds,cnt,"pdm_rev",info->rev);
  //for (i = 0; 
  //vdcol$GetAttr(objID = &NODE_ID, name = VDCT1_ATTR_MINO, fld = &FLD); 


  // check the fields with the ppl 
  sts = VDct1GetFldData(parentID,flds,cnt);

  // post the fields to the database if OK
  if (sts & 1) {
    if (traceFlag) printf("we posted sts was 1!\n");
    VDct1POSTInsertFlds(flds,cnt,tableName);
  }
  

  // cycle down through the kids
  for(i = 0; vdct1$GetTree1Child(objID = parentID, nth = i, outID = &childID); i++) {
    if (childID.objid == NULL_OBJID) {
      if (traceFlag) {
	printf("childID was NULL\n");
	}
      goto wrapup;
    }

    // call self
    VDct1PostNodesPdm(info, &childID, set);
  }
  //#endif   
  
  retFlag = 1;
  //#endif  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< VDct1PostNodesPdm(%d)\n",retFlag);   
  }
  return retFlag;
}
//#endif
/* -----------------------------------------------
 * Posts a given set
 * [z4]
 */
IGRstar VDct1POSTSet(TVDatPDMInfo *info, TGRid *setID,TGRid *postID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRstat sts;

  TVDct1POSTSetInfo set;

  IGRchar sql[1024], buf[128];

  TGRid      nodeID;
  TGRid      treeID;
  TGRid       refID;
  TVDatPDMInfo refINFO;

  IGRint nodeCnt = 0;
  IGRint leafCnt = 0;
 
  *set.name = 0;

   if (traceFlag) printf(">>> VDct1POSTSet\n");
  // Arg Check
  if (info->key == 0)             goto wrapup;
  if (setID->objid == NULL_OBJID) goto wrapup;
  set.id = *setID;
#if 0
  // if we sent in postID
  if (postID != NULL) {
    //printf("are we having fun yet?");
    // if it is not the same goto wrapup
    if((setID->objid != postID->objid) || (setID->osnum != postID->osnum)) goto wrapup;
  }
  //printf("we must be having fun now?");
#endif 
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

  /*|Open the RIS schema */
  if (VdsRisAttach() != SUCCESS) {
    strcpy (buf,"VdsRisSelect Cannot open Ris Schema");
    UI_status(buf);
    sts = FAILURE;
    goto wrapup;
  }
  // Update new key
  sprintf(sql,
    "insert into %s values ("
    "%d,%d,%d, '%s','%s','%s', '%s','%s','%s');",
     VDAT_RDB_TBL_SET_KEYS,
     info->key,set.key,set.id.objid,
     info->cat,info->part,info->rev,
     set.name,set.type,set.desc
  );
  if (traceFlag) printf("SQL VDSexecute[2] = [%s]\n",sql);
  sts = VDSexecute_sql_stmt(sql);

  if (!(sts & 1)) {
    UI_status("Update of set key failed");
    goto wrapup;
  }

  // Get the pdm info
  VDatPOSTGetPDMInfo(setID->osnum,&refINFO);
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
  if (traceFlag) printf("SQL VDSexecute[3] = [%s]\n",sql);
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Update of set to file failed");
    goto wrapup;
  }
  vdct1$GetMgrChild(objID = setID, nth = 0, outID = &treeID);

  // And post it
  VDct1PostNodesPdm(info,&treeID,&set);

  retFlag = 1;

wrapup:

  UI_status(sql);
  if (traceFlag) {
    printf("<<< VDct1POSTSet(%d)\n",retFlag);
  }
  
  return retFlag;
}
//#if 0
/* -----------------------------------------------
 * Deletes all "file_key" entries from a table
 * [z5]
 */
IGRstar VDct1POSTDeleteFileKey(IGRchar *tblName, IGRkey fileKEY)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  IGRchar sql[1024];


  if (traceFlag) printf(">>> VDct1POSTDeleteFileKey\n");
  
  // Easy Enough
  sprintf(sql,
    "delete from %s where file_key = %d;",
    tblName,fileKEY
  );
    if (traceFlag) printf("SQL VDSexecute[1] = [%s]\n",sql);
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Deletion of table failed");
    goto wrapup;
  }

  retFlag = 1;

wrapup:

  if (traceFlag) printf("<<< VDct1POSTDeleteFileKey()\n",retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * Deletes anything previously posted from this file
 * [z6]
 */
IGRstar VDct1POSTDeleteAll(TVDatPDMInfo *info,TGRid *postID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint    tabNumCols = 1;
  IGRint    tabNumRows = 0;
  IGRint    tabRow;
  IGRchar **tabList = NULL;
  IGRstat   traceFlag = 0;
  IGRchar   tab_name[128], buf[128];

  // say hi
  if (traceFlag) printf(">>> VDct1POSTDeleteAll\n");
  
  
  // Arg check
  if (info->key == 0) goto wrapup;

  // Some predefined tables
  VDct1POSTDeleteFileKey(VDAT_RDB_TBL_SET_KEYS,    info->key); //p5
  VDct1POSTDeleteFileKey(VDAT_RDB_TBL_SET_REF_KEYS,info->key); //p5

  /*|Open the RIS schema */
  if (VdsRisAttach() != SUCCESS) {
    strcpy (buf,"VdsRisSelect Cannot open Ris Schema");
    UI_status(buf);
    sts = FAILURE;
    goto wrapup;
  }

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

  if (traceFlag) printf("Going to delete the files with the file key!\n");
  
  // Delete Each
  if (postID == NULL) {
    if (traceFlag) printf("It was NULL!\n");
    
    for(tabRow = 0; tabRow < tabNumRows; tabRow++) {
      VDct1POSTDeleteFileKey(tabList[(tabRow*tabNumCols)+0],info->key);//p5
    }
  }
  else {
 
    VDct1GetTableName(postID,tab_name);
    for(tabRow = 0; tabRow < tabNumRows; tabRow++) {
      strcpy(buf,tabList[(tabRow*tabNumCols)+0]);
      if(!strcmp(buf,tab_name)){
	VDct1POSTDeleteFileKey(tabList[(tabRow*tabNumCols)+0],info->key);//p5
      }
    }
  }
  retFlag = 1;

wrapup:
  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );
  if (traceFlag) printf("<<< VDct1POSTDeleteAll(%d)\n",retFlag);
  
  return retFlag;
}
//#if 0
/* -----------------------------------------------
 * This routine starts up the posting process
 * for the active file
 * [z7]
 */
IGRstar VDct1POSTAll(TGRid *postID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i = 0;
  IGRint  objnum;

  TGRid   mgrID;
  TGRid   pdmID;
  TGRid   setID;
  TVDctBaseInfo postBaseInfo;
  TVDatPDMInfo info;

  IGRchar buf[128];
  IGRstat traceFlag = 0;
  

 // Init
  UI_status("Posting Sets");
  
  if (traceFlag) {  
    printf("\n\n\n======= Posting Sets =========\n");
  }
  // args check
  if (postID == NULL) goto wrapup;
  if (postID->osnum == 0) goto wrapup;
  objnum = postID->objid;
  if (objnum < 1) goto wrapup;
  
  //Do nothing if not logged in
  sts = VDatVerifyLogin();
  if (!(sts & 1)) goto wrapup;
  // Do Nothing if no active manager
  vdct1$GetManager(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    retFlag = 0;
    goto wrapup;
  }
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
  sts = VDct1POSTDeleteAll(&info,postID);  //p6
  if (traceFlag) printf("Everything is deleted\n");
  if (!(sts & 1)) goto wrapup;

      
  // Cycle through each set
  for(i = 0; vdct1$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {
    if (traceFlag) printf("POSTING\n");
    VDct1POSTSet(&info,&setID,postID); //p4
  }
  
  
  retFlag = 1;
  //#endif  
wrapup:
  if (retFlag == 0) UI_status("Tree Posting Failed!");
  else {
    vdct1$GetBaseInfo(objID = postID, baseInfo = &postBaseInfo);
    sprintf(buf,"Posted [%s] Tree(s)",postBaseInfo.nodeType);
    UI_status(buf);
  }
  if (traceFlag) printf("<<< VDct1POSTAll(%d)\n",retFlag);
  
  return retFlag;
}
//#endif
end implementation VDct1Base;





