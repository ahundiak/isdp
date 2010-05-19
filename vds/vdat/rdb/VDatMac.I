/* $Id: VDatMac.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/VDatMac.I
 *
 * Description: Detail Macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatMac.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/03/06  21:24:12  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      03/01/98  ah      Creation
 *
 ***************************************************************************/
class implementation VDatBase;

#include "VDris.h"

#define VDAT_TRACE_CREATEx

IGRstar VDatRDBGetMacsVLA(TGRid *objID, TVDvlaID *macVLA)
{
  IGRstat retFlag = 0;

  TGRid rdbMacsID;
  TGRid rdbMacID;

  IGRint i;

  // Get list of attrs
  VDatRDBGetMacs(objID,&rdbMacsID);
  if (rdbMacsID.objid == NULL_OBJID) goto wrapup;

  // Transfer
  for(i = 0; VDatGetChildObject(&rdbMacsID,i,&rdbMacID); i++) {
    VDvlaID_Append(macVLA,&rdbMacID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Get mac object by name
 * Works with manager, cache or macs
 */
IGRstar VDatRDBGetMacByName(
  TGRid   *objID, 
  IGRchar *a_rdbMacName, 
  TGRid   *a_rdbMacID
)
{
  IGRstat retFlag = 0;

  TGRid   rdbMacsID;
  TGRid   rdbMacID;

  IGRchar rdbMacName[128];

  IGRint i;

  // Init
  a_rdbMacID->objid = NULL_OBJID;

  // Get list of attrs
  VDatRDBGetMacs(objID,&rdbMacsID);
  if (rdbMacsID.objid == NULL_OBJID) goto wrapup;

  for(i = 0; VDatGetChildObject(&rdbMacsID,i,&rdbMacID); i++) {

    VDatGetBaseName(&rdbMacID,rdbMacName);
    if (strcmp(a_rdbMacName,rdbMacName) == 0) {
      *a_rdbMacID = rdbMacID;
      retFlag = 1;
      goto wrapup;
    }
  }  

wrapup:
  return retFlag;

}

/* --------------------------------------
 * Returns the list of mac objects
 * Works on either manager or cache
 * Attrs, Leaf, Nodes, Trees
 */
IGRstar VDatRDBGetMacs(TGRid *a_objID, TGRid *rdbMacsID)
{
  IGRstat retFlag = 0;

  TGRid   objID;
  TGRid   rdbCacheID;

  IGRint  type;

  // Init
  rdbMacsID->objid = NULL_OBJID;
  
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

    retFlag = VDatRDBGetMacs(&objID,rdbMacsID);
    goto wrapup;
  }

  case VDAT_CLASSI_SET_MGR: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_CACHE,&rdbCacheID);
    if (rdbCacheID.objid == NULL_OBJID) goto wrapup;

    retFlag = VDatRDBGetMacs(&rdbCacheID,rdbMacsID);
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_CACHE: {

    VDatGetChildByType(&objID,VDAT_CLASSI_RDB_MACS,rdbMacsID);
    if (rdbMacsID->objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_RDB_MACS: {

    *rdbMacsID = objID;
    retFlag = 1;
    goto wrapup;

  }

  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Create Mac Object
 */
IGRstar VDatRDBCreateMac(
  TGRid           *macsID, 
  TVDatRDBMacInfo *info, 
  TGRid           *macID
)
{
  IGRstat retFlag = 0;
  
  // Create Attr Object
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_MAC,
    type     = VDAT_CLASSI_RDB_MAC,
    parentID = macsID,
    baseID   = macID
  );
  if (macID->objid == NULL_OBJID) goto wrapup;

  // Name it for quicker searching
  VDatSetBaseName(macID,info->macName);

  // Set predefined information
  VDatRDBSetMacInfo(macID,info);

  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    UI_status("Problem Loading Macro Information");
  }

#ifdef VDAT_TRACE_CREATE
printf("Exited  VDatRDBCreateAttr %s\n",attrName);
#endif
  return retFlag;
}

/* -----------------------------------------------
 * Loads in all attr objects
 */
IGRstar VDatRDBCreateMacs(TGRid *cacheID, TGRid *macsID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid           macID;
  TVDatRDBMacInfo info;

  IGRint    tabNumCols = 0;
  IGRint    tabNumRows = 0;
  IGRint    i;
  IGRchar **tabList = NULL;

#ifdef VDAT_TRACE_CREATE
printf("Entered VDatRDBCreateMacs\n");
#endif

  // Create the macro manager
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_MACS,
    type     = VDAT_CLASSI_RDB_MACS,
    parentID = cacheID,
    baseID   = macsID
  );
  if (macsID->objid == NULL_OBJID) goto wrapup;

  // Verify Logged in 
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Get the setup information
  tabNumCols = 3;
  sts = vdb$RisSelect( 
    select     = "macro_name,macro_use,macro_ppl",
    table_name = VDAT_RDB_TBL_MACROS,
    order      = "macro_name",
    numselect  =  tabNumCols,
    p_numrows  = &tabNumRows,
    p_buffer   = &tabList
  );

  // Cycle through
  for(i = 0; i < tabNumRows; i++) {

    memset(&info,0,sizeof(info));
    strcpy(info.macName,  tabList[(i*tabNumCols)+0]);
    strcpy(info.macUse,   tabList[(i*tabNumCols)+0]);
    strcpy(info.macPPL,   tabList[(i*tabNumCols)+0]);

    VDatRDBCreateMac(macsID,&info,&macID);
  }

  retFlag = 1;

wrapup:

  if (retFlag != 1) {
    UI_status("Problem Creating List of Macros");
  }

  vdb$RisFreeBuffer(
    buffer = tabList,
    size   = tabNumRows * tabNumCols
  );

#ifdef VDAT_TRACE_CREATE
printf("Exited  VDatRDBCreateMacs\n");
#endif

  return retFlag;
}

/* ---------------------------------------------------------
 * Stores info into object
 */
IGRstar VDatRDBSetMacInfo(TGRid *macID, TVDatRDBMacInfo *info)
{
  IGRstat  sts;
  IGRint   cnt;
  TVDatFld flds[10];

  // Store Attributes
  cnt = 0;
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,1,info->macName);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,2,info->macUse);
  VDatFldSetTxtByIndex(&flds[cnt],&cnt,3,info->macPPL);
  
  sts = VDatFldSetAllAttrs(macID,flds,cnt);

  return sts;
}

/* ---------------------------------------------------------
 * Gets info from object
 */
IGRstar VDatRDBGetMacInfo(TGRid *macID, TVDatRDBMacInfo *info)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  IGRint   cnt;
  TVDatFld flds[VDAT_FLD_MAX];

  // Clear
  memset(info,0,sizeof(TVDatRDBMacInfo));

  // Get all attributes
  cnt = 0;
  sts = VDatFldGetAllAttrs(macID,flds,&cnt);
  if (!(sts & 1)) goto wrapup;

  // Unpack
  VDatFldGetTxtByIndex(flds,cnt,1, info->macName);
  VDatFldGetTxtByIndex(flds,cnt,2, info->macUse);
  VDatFldGetTxtByIndex(flds,cnt,3, info->macPPL);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;




