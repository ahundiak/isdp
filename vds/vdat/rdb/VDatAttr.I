/* $Id: VDatAttr.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/VDatAttr.I
 *
 * Description: Attribute Values
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatAttr.I,v $
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
 * 01/07/98  ah      creation
 *
 ***************************************************************************/
class implementation VDatBase;

#include "VDris.h"

#define VDAT_TRACE_CREATEx

IGRstar VDatRDBGetAttrsVLA(TGRid *objID, TVDvlaID *attrVLA)
{
  IGRstat retFlag = 0;

  TGRid rdbAttrsID;
  TGRid rdbAttrID;

  IGRint i;

  // Get list of attrs
  VDatRDBGetAttrs(objID,&rdbAttrsID);
  if (rdbAttrsID.objid == NULL_OBJID) goto wrapup;

  // Transfer
  for(i = 0; VDatGetChildObject(&rdbAttrsID,i,&rdbAttrID); i++) {
    VDvlaID_Append(attrVLA,&rdbAttrID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Get attr object by name
 * Works with manager, cache or attrs
 */
IGRstar VDatRDBGetAttrByName(
  TGRid   *objID, 
  IGRchar *a_rdbAttrName, 
  TGRid   *a_rdbAttrID
)
{
  IGRstat retFlag = 0;

  TGRid   rdbAttrsID;
  TGRid   rdbAttrID;

  IGRchar rdbAttrName[128];

  IGRint i;

  // Init
  a_rdbAttrID->objid = NULL_OBJID;

  // Get list of attrs
  VDatRDBGetAttrs(objID,&rdbAttrsID);
  if (rdbAttrsID.objid == NULL_OBJID) goto wrapup;

  for(i = 0; VDatGetChildObject(&rdbAttrsID,i,&rdbAttrID); i++) {

    VDatGetBaseName(&rdbAttrID,rdbAttrName);
    if (strcmp(a_rdbAttrName,rdbAttrName) == 0) {
      *a_rdbAttrID = rdbAttrID;
      retFlag = 1;
      goto wrapup;
    }
  }  

wrapup:
  return retFlag;

}

/* --------------------------------------
 * Returns the list of attr objects
 * Works on either manager or cache
 * Attrs, Leaf, Nodes, Trees
 */
IGRstar VDatRDBGetAttrs(TGRid *a_objID, TGRid *rdbAttrsID)
{
  IGRstat retFlag = 0;

  TGRid   objID;
  TGRid   rdbCacheID;

  IGRint  type;

  // Init
  rdbAttrsID->objid = NULL_OBJID;
  
  // NULL Is OK
  if (a_objID != NULL) objID = *a_objID;
  else                 vdat$GetSetMgr(mgrID = &objID);
  
  // Switch on type
  VDatGetBaseType(&objID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF:
  case VDAT_CLASSI_NODE:
  case VDAT_CLASSI_TREE: {

    vdat$GetSetMgr(osnum = objID.osnum, mgrID = &objID);
    if (objID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetAttrs(&objID,rdbAttrsID);
    goto wrapup;
  }

  case VDAT_CLASSI_SET_MGR: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_CACHE,&rdbCacheID);
    if (rdbCacheID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetAttrs(&rdbCacheID,rdbAttrsID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_CACHE: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_ATTRS,rdbAttrsID);
    if (rdbAttrsID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_ATTRS: {

    *rdbAttrsID = objID;
    retFlag = 1;
    goto wrapup;

  }

  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Create Attr Object
 */
IGRstar VDatRDBCreateAttr(
  TGRid            *attrsID, 
  TVDatRDBAttrInfo *info, 
  TGRid            *attrID
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint    tabNumCols = 0;
  IGRint    tabNumRows = 0;
  IGRchar **tabList = NULL;
  
  IGRchar   attrWhere[128];

  IGRint    cnt,i;
  TVDatFld  flds[VDAT_FLD_MAX];
  TVDatFld *fld;

#ifdef VDAT_TRACE_CREATE
printf("Entered VDatRDBCreateAttr %s\n",attrName);
#endif

  // Create Attr Object
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_ATTR,
    type     = VDAT_CLASSI_RDB_ATTR,
    parentID = attrsID,
    baseID   = attrID
  );
  if (attrID->objid == NULL_OBJID) goto wrapup;

  // Name it for quicker searching
  VDatSetBaseName(attrID,info->attrName);

  // Set predefined information
  VDatRDBSetAttrInfo(attrID,info);

  // Get the rest of the attr info from the attr value table
  sprintf(attrWhere,"attr_name = '%s'",info->attrName);
  tabNumCols = 6;

  sts = vdb$RisSelect( 
    select     = "attr_name,attr_sort,attr_int,attr_dbl,attr_txt,attr_desc",
    table_name = VDAT_RDB_TBL_ATTR_VALUES,
    where      =  attrWhere,
    order      = "attr_name",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );

  // Append values
  cnt = 0;
  memset(flds,0,sizeof(flds));
  sts = VDatFldGetAllAttrs(attrID,flds,&cnt);
  if (!(sts & 1)) goto wrapup;

  // Store the info
  for(i = 0; i < tabNumRows; i++) {

    // First the actual value
    fld = &flds[cnt];
    
    fld->type  = info->attrType;
    fld->flag  = 1;
    fld->index = 0;

    sprintf(fld->name,"sort %-2s",tabList[(i*tabNumCols)+1]);

    fld->valueInt = atoi(tabList[(i*tabNumCols)+2]);
    fld->valueDbl = atof(tabList[(i*tabNumCols)+3]);
    strcpy(fld->valueTxt,tabList[(i*tabNumCols)+4]);

    cnt++;

    // Then any description
    fld = &flds[cnt];
    
    fld->type  = VDAT_FLD_TYPE_CHAR;
    fld->flag  = 2;
    fld->index = 0;

    sprintf(fld->name,"desc %-2s",tabList[(i*tabNumCols)+1]);
    strcpy (fld->valueTxt,tabList[(i*tabNumCols)+5]);

    cnt++;

  }

  VDatFldSetAllAttrs(attrID,flds,cnt);

  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    UI_status("Problem Loading Attr Values");
  }

  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );

#ifdef VDAT_TRACE_CREATE
printf("Exited  VDatRDBCreateAttr %s\n",attrName);
#endif
  return retFlag;
}

/* -----------------------------------------------
 * Loads in all attr objects
 */
IGRstar VDatRDBCreateAttrs(TGRid *cacheID, TGRid *attrsID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid attrID;
  TVDatRDBAttrInfo info;

  IGRint    tabNumCols = 0;
  IGRint    tabNumRows = 0;
  IGRint    i;
  IGRchar **tabList = NULL;

#ifdef VDAT_TRACE_CREATE
printf("Entered VDatRDBCreateAttrs\n");
#endif

  // Create the attr manager
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_ATTRS,
    type     = VDAT_CLASSI_RDB_ATTRS,
    parentID = cacheID,
    baseID   = attrsID
  );
  if (attrsID->objid == NULL_OBJID) goto wrapup;

  // Verify Logged in 
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Get the setup information
  tabNumCols = 5;
  sts = vdb$RisSelect( 
    select     = "attr_name,attr_prompt,attr_desc,attr_type,attr_ppl",
    table_name = VDAT_RDB_TBL_ATTRS,
    order      = "attr_name",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );

  // Cycle through
  for(i = 0; i < tabNumRows; i++) {

    memset(&info,0,sizeof(info));
    strcpy(info.attrName,  tabList[(i*tabNumCols)+0]);
    strcpy(info.attrPrompt,tabList[(i*tabNumCols)+1]);
    strcpy(info.attrDesc,  tabList[(i*tabNumCols)+2]);
    info.attrType   = atoi(tabList[(i*tabNumCols)+3]);
    strcpy(info.attrPPL,   tabList[(i*tabNumCols)+4]);

    VDatRDBCreateAttr(attrsID,&info,&attrID);
  }

  retFlag = 1;

wrapup:

  if (retFlag != 1) {
    UI_status("Problem Creating List of Attribute Values");
  }

  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );

#ifdef VDAT_TRACE_CREATE
printf("Exited  VDatRDBCreateAttrs\n");
#endif

  return retFlag;
}

/* ---------------------------------------------------------
 * Stores info into object
 */
IGRstar VDatRDBSetAttrInfo(TGRid *attrID, TVDatRDBAttrInfo *info)
{
  IGRstat  sts;
  IGRint   cnt;
  TVDatFld flds[10];

  // Store Attributes
  cnt = 0;
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,1,info->attrName);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,2,info->attrPrompt);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,3,info->attrDesc);
  VDatFldSetIntByIndex(&flds[cnt],&cnt,4,info->attrType);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,5,info->attrPPL);
  
  sts = VDatFldSetAllAttrs(attrID,flds,cnt);

  return sts;
}

/* ---------------------------------------------------------
 * Gets info from object
 */
IGRstar VDatRDBGetAttrInfo(TGRid *attrID, TVDatRDBAttrInfo *info)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  IGRint   cnt;
  TVDatFld flds[VDAT_FLD_MAX];

  // Clear
  memset(info,0,sizeof(TVDatRDBAttrInfo));

  // Get all attributes
  cnt = 0;
  sts = VDatFldGetAllAttrs(attrID,flds,&cnt);
  if (!(sts & 1)) goto wrapup;

  // Unpack
  VDatFldGetTxtByIndex(flds,cnt,1, info->attrName);
  VDatFldGetTxtByIndex(flds,cnt,2, info->attrPrompt);
  VDatFldGetTxtByIndex(flds,cnt,3, info->attrDesc);
  VDatFldGetIntByIndex(flds,cnt,4,&info->attrType);
  VDatFldGetTxtByIndex(flds,cnt,5, info->attrPPL);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

