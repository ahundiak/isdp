/* $Id: VDsaDynTbl.I,v 1.3 2001/02/11 17:58:04 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDsaDynTbl.I
 *
 * Description: Dynamic table interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaDynTbl.I,v $
 *      Revision 1.3  2001/02/11 17:58:04  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/01/22 15:27:06  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/10  21:37:36  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/98  ah      Creation
 * 00/25/00  ah      Rewrote VDsaGetTableObj to use vdris routines
 *                   and to store column length
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDchn.h"

#include "VDbt.h"
#include "VDsaProto.h"
#include "VDScheckin.h"

#include "PDUerror.h"
#include "v_risproto.h"
#include "VDSris_def.h"
#include "vdbmacros.h"

#include "VDrisc.h"

from ACdb_info import ACget_db_info;

/* ------------------------------------------------------
 * Give Struct SET Interface
 */
IGRstar VDsaGiveStructureSET(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar setType  [128];
  IGRchar tableName[128];
  IGRchar attrNamex[128];
  IGRchar *p;
  
  // Get the set type
  *setType = 0;
  strcpy(attrNamex,attrName);
  p = strchr(attrNamex,':');
  if (p) strcpy(attrNamex,p+1);
  
  p = strchr(attrNamex,':');
  if (p) {
    *p = 0;
    strcpy(setType,attrNamex);
    strcpy(attrNamex,p+1);
  }
  if (*setType == 0) goto wrapup;

  // Get the table for the set
  *tableName = 0;
  vdbt$GetSetType(setType = setType, tableName = tableName);
  if (*tableName == 0) goto wrapup;

  // Get the value
  sts = vdsa$GetTableAttr(objOE     = objOE,
			  tableName = tableName,
			  attrName  = attrNamex,
			  attrData  = attrData);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = OM_S_SUCCESS;
  
wrapup:

  if (retFlag != OM_S_SUCCESS) {
    printf("Problem getting '%s' for\n",attrName);
    vdbro$PrintObject(objOE = objOE);
  }
  
  return retFlag;
  
}

/* ------------------------------------------------------
 * Give Struct TBL Interface
 */
IGRstar VDsaGiveStructureTBL(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar tableName[128];
  IGRchar attrNamex[128];
  IGRchar *p;
  
  // Get the table name
  *tableName = 0;
  strcpy(attrNamex,attrName);
  p = strchr(attrNamex,':');
  if (p) strcpy(attrNamex,p+1);
  
  p = strchr(attrNamex,':');
  if (p) {
    *p = 0;
    strcpy(tableName,attrNamex);
    strcpy(attrNamex,p+1);
  }
  if (*tableName == 0) goto wrapup;

  // Get the value
  sts = vdsa$GetTableAttr(objOE     = objOE,
			  tableName = tableName,
			  attrName  = attrNamex,
			  attrData  = attrData);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = OM_S_SUCCESS;
  
wrapup:

  if (retFlag != OM_S_SUCCESS) {
    printf("Problem getting '%s' for\n",attrName);
    vdbro$PrintObject(objOE = objOE);
  }
  
  return retFlag;
  
}

/* ------------------------------------------------------
 * Give Struct DYN Interface
 */
IGRstar VDsaGiveStructureDYN(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar tableName[128];
  IGRchar attrNamex[128];
  IGRchar *p;
  
  // Get the table name
  vdsa$GetDynTable(objOE = objOE,tableName = tableName);
  if (*tableName == 0) goto wrapup;
  
  // Parse the attribute
  strcpy(attrNamex,attrName);
  p = strchr(attrNamex,':');
  if (p) strcpy(attrNamex,p+1);
  
  // Get the value
  sts = vdsa$GetTableAttr(objOE     = objOE,
			  tableName = tableName,
			  attrName  = attrNamex,
			  attrData  = attrData);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = OM_S_SUCCESS;
  
wrapup:

  if (retFlag != OM_S_SUCCESS) {
    printf("Problem getting '%s' for\n",attrName);
    vdbro$PrintObject(objOE = objOE);
  }
  
  return retFlag;
  
}

/* -------------------------------------------------------
 * Get The attribute from the table
 */
IGRstar VDsaGetTableAttr(TGRobj_env  *objOE,
			 TGRid       *objID,
			 IGRchar     *tableName,
			 IGRchar     *attrName,
			 Tret_struct *attrData
			 )
{
  IGRstat retFlag = 0;
  TGRid   recID;
  TVDfld  fld;
  
  // Arg check
  if (attrData == NULL) goto wrapup;
  
  if  (objOE) objID = &objOE->obj_id;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  if ((tableName == NULL) || (*tableName == 0)) goto wrapup;
  if ((attrName  == NULL) || (*attrName  == 0)) goto wrapup;
  
  // Get the record
  vdsa$GetTableRec(objID = objID, tableName = tableName, recID = &recID);
  if (recID.objid == NULL_OBJID) goto wrapup;
  
  // Get the attribute
  vdbt$GetAttr(objID = &recID, name = attrName, fld = &fld);
  if (*fld.name == 0) goto wrapup;
  
  // Translate
  switch(fld.type) {

  case VDFLD_TYPE_TXT:

    attrData->type =  text_type;   
    strcpy(attrData->var.text_st.text_string,fld.val.txt);    
    break;

  case VDFLD_TYPE_SMALLINT:
  case VDFLD_TYPE_INT:

    attrData->type = double_type;
    attrData->var.root_pm_st.value = (IGRdouble)fld.val.jnt;  
    break;
     
  case VDFLD_TYPE_REAL:
  case VDFLD_TYPE_DOUBLE:

    attrData->type = double_type;
    attrData->var.root_pm_st.value = fld.val.dbl;
    break;
    
  default: 
      goto wrapup;
  }

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Get The record object
 */
IGRstat VDsaGetTableRec(TGRobj_env  *objOE,
			TGRid       *objID,
			IGRchar     *tableName,
			TGRid       *recID
			)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   tableID;
  IGRchar cat[64];
  IGRchar nam[64];
  IGRchar ver[64];
  IGRchar seq[64];
  IGRchar all[128];
  
  IGRchar sql[1024];
  
  IGRint  rows,cols,i;
  IGRchar **buf = NULL;

  TVDflds  flds;
//TVDfld  *fld;
  
  TGRid recsID;

  TVDvlaID notifyVLA;
  TGRid    notifyID;
  
  IGRint   type;
  IGRchar  name[128];
  IGRchar *p;
  
  // Init
  VDvlaID_Construct(&notifyVLA);
  
  // Arg checking
  if (recID == NULL) goto wrapup;
  recID->objid = NULL_OBJID;
  
  if  (objOE) objID = &objOE->obj_id;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  if ((tableName == NULL) || (*tableName == 0)) goto wrapup;

  // See what's on the notification channel
  vdchn$Get(il_objID = objID,
	    ic_IDX   = VDCHN_IDX_NOTIFICATION,
	    or_vlaID = &notifyVLA);

  for(i = 0; VDvlaID_GetAt(&notifyVLA, &notifyID, i); i++) {
  
    vdbt$GetBase(objID = &notifyID, type = &type, name = name);

    if (type == VDBT_TYPE_CACHE_REC) {
      p = strchr(name,':');
      if (p) *p = 0;
      if (!strcmp(name,tableName)) {
	*recID = notifyID;
	retFlag = 1;
	goto wrapup;
      }
    }
  }
  
  // Get the records cache
  vdsa$GetCache(recsID = &recsID);
  if (recsID.objid == NULL_OBJID) goto wrapup;
  
  // Get the table object
  vdsa$GetTableObj(tableName = tableName, tableID = &tableID);
  if (tableID.objid == NULL_OBJID) goto wrapup;
  
  // And it's attributes
  vdbt$GetAttrs(objID = &tableID, flds = &flds);
  
  // Get pdm info
  vdsa$GetPDM(objID = objID, 
	      assembly_cat = cat, 
	      assembly_nam = nam, 
	      assembly_ver = ver,
	      seqno        = seq,
	      all          = all);
  if ((*cat == 0) || (*nam == 0)) goto wrapup;
  
  // Do the query
  sprintf(sql,
	  "Select * from %s where "
	  "assembly_cat = '%s' and assembly_nam = '%s' and "
	  "assembly_ver = '%s' and comp_seqno = %s;",
    tableName,cat,nam,ver,seq);

  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (!(sts & 1)) goto wrapup;

  if ((buf == NULL) || (rows <= 0) || (cols <= 0))  goto wrapup;
  if (flds.cnt != cols) goto wrapup;
    
  for(i = 0; i < cols; i++) {

    vdfld$SetFrom(fld = &flds.fld[i], ris = buf[i]);
#if 0
    fld = &flds.fld[i];
    switch(fld->type) {

    case VDFLD_TYPE_CHAR: {
      strcpy(fld->val.txt,buf[i]);
      break;
    } 
    case VDFLD_TYPE_SMALLINT:
    case VDFLD_TYPE_INT: {
      fld->val.jnt = atoi(buf[i]);
      break;
    } 
    case VDFLD_TYPE_REAL:
    case VDFLD_TYPE_DOUBLE: {
      fld->val.dbl = atof(buf[i]);
      break;
    } 
    default: {
      printf("Unknown field type when getting data from dynamic table: '%s'\n",buf[i]);
      strcpy(fld->val.txt,buf[i]);
      goto wrapup;
    }}
#endif

  }

  // Create the object
  sprintf(sql,"%s:%s",tableName,all);
  *(sql + VDFLD_MAX_TXT - 1) = 0;
  
  vdbt$CreateBase(type     = VDBT_TYPE_CACHE_REC, 
		  name     = sql, 
		  parentID = &recsID, 
		  objID    =  recID);
  
  if (recID->objid == NULL_OBJID) goto wrapup;

  // Add in the attributes
  vdbt$SetAttrs(objID = recID, flds = &flds);

  // Attach it
  vdbt$Connect(objID = objID, listenerID = recID);
  
  retFlag = 1;
  
wrapup:
  VDvlaID_Delete(&notifyVLA);
  if (buf) VdsRisFreeBuffer(buf, rows * cols);
  return retFlag;
}

/* --------------------------------------------------------
 * 22 Jan 2001 - ah - new version
 * Given a table name, return the table object
 */
IGRstat VDsaGetTableObj(IGRchar *tableName,
		        TGRid   *tableID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i;

  TVDflds  flds;
  TVDfld  *fld;
  
  TGRid tablesID;
  TGRid childID;

  IGRchar childName[128];

  TVDrisInfo ris;
  
  // Arg check
  if (tableID == NULL) goto wrapup;
  tableID->objid = NULL_OBJID;
  
  if ((tableName == NULL) || (*tableName == 0)) goto wrapup;

  // Get the manager
  vdsa$GetCache(tblsID = &tablesID);
  if (tablesID.objid == NULL_OBJID) goto wrapup;

  // See if on the channel
  for(i = 0; vdbt$GetObj(objID = &tablesID, ind = i, childID = &childID); i++) {

    vdbt$GetBase(objID = &childID, name = childName);
    if (!strcmp(tableName,childName)) {
      *tableID = childID;
      retFlag = 1;
      goto wrapup;
    }
  }

  // Get the table columns
  vdris$InitInfo(info = &ris);
  VDrisQryTableColumns(&ris,tableName);
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {

    ris.j = ris.i * ris.cols;

    fld = &flds.fld[ris.i];
    memset(fld,0,sizeof(TVDfld));
    fld->type = atoi(ris.buf[ris.j+VDRIS_COLI_COLUMNS_TYPE]);
    strcpy(fld->name,ris.buf[ris.j+VDRIS_COLI_COLUMNS_NAME]);
    sprintf(fld->val.txt,"%s %s",
	    ris.buf[ris.j+VDRIS_COLI_COLUMNS_TYPES],
	    ris.buf[ris.j+VDRIS_COLI_COLUMNS_LEN]);    
  }
  flds.cnt = ris.rows;
  vdris$FreeInfo(info = &ris);
  
  // Create a table object
  vdbt$CreateBase(type     = VDBT_TYPE_CACHE_TBL, 
		  name     =  tableName, 
		  parentID = &tablesID, 
		  objID    =  tableID);

  if (tableID->objid == NULL_OBJID) goto wrapup;

  vdbt$SetAttrs(objID = tableID, flds = &flds);
  retFlag = 1;

wrapup:

  return retFlag;
}

#if 0
/* --------------------------------------------------------
 * Given a table name, return the table object
 * 22 Jan 2001 ah
 * Keep the older version for review
 */
IGRstat VDsaGetTableObj(IGRchar *tableName,
		        TGRid   *tableID
		       )
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint    attrNum  = 0;
  IGRchar **attrName = NULL;
  IGRchar **attrType = NULL;
  
  IGRint i;

  TVDflds  flds;

  TGRid tablesID;
  TGRid childID;

  IGRchar childName[128];
  
  // Arg check
  if (tableID == NULL) goto wrapup;
  tableID->objid = NULL_OBJID;
  
  if ((tableName == NULL) || (*tableName == 0)) goto wrapup;

  // Get the manager
  vdsa$GetCache(tblsID = &tablesID);
  if (tablesID.objid == NULL_OBJID) goto wrapup;

  // See if on the channel
  for(i = 0; vdbt$GetObj(objID = &tablesID, ind = i, childID = &childID); i++) {

    vdbt$GetBase(objID = &childID, name = childName);
    if (!strcmp(tableName,childName)) {
      *tableID = childID;
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Make sure logged in
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) goto wrapup;
  
  // Query for the attributes
  sts = vdb$RetrieveAttributes ( 
    table_name = tableName,
    p_num      = &attrNum,
    p_attr     = &attrName,
    p_type     = &attrType
  );
  if (!(sts & 1)) goto wrapup;

  // Xfer the info
  memset(&flds,0,sizeof(flds));
  flds.cnt = attrNum;
  
  for(i = 0; i < attrNum; i++) {
    flds.fld[i].type = atoi(attrType[i]);
    strcpy(flds.fld[i].name,attrName[i]);
  }

  // Create a table object
  vdbt$CreateBase(type     = VDBT_TYPE_CACHE_TBL, 
		  name     =  tableName, 
		  parentID = &tablesID, 
		  objID    =  tableID);

  if (tableID->objid == NULL_OBJID) goto wrapup;

  vdbt$SetAttrs(objID = tableID, flds = &flds);

  retFlag = 1;

wrapup:

  if (attrName) vdb$RisFreeBuffer(buffer = attrName, size = attrNum);
  if (attrType) vdb$RisFreeBuffer(buffer = attrType, size = attrNum);

  return retFlag;
}
#endif

/* --------------------------------------------------------
 * Return table name for family
 * Either input a family or it determines it from
 * the object itself
 */
IGRstar VDsaGetDynTable(TGRobj_env *objOE,
			TGRid      *objID,
			IGRchar    *i_family,
			IGRchar    *o_tableName,
			IGRchar    *o_family
			)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid  catsID;
  TVDfld fld;
  
  IGRchar family[128];
  IGRchar data  [128];
  IGRchar *p;

  struct ACdb_info dbInfo;
  
  // Set the id
  if (objOE) objID = &objOE->obj_id;
  
  // Arg check
  if (o_tableName != NULL) *o_tableName = 0;
  if (o_family    != NULL) *o_family    = 0;
  
  // Check the family
  *family = 0;
  if (i_family != NULL) strcpy(family,i_family);

  else {

    // Need the object
    if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
    
    vdsa$GetStruct(objID = objID, name = "family_name", txt = family);

    // Little hack for equipment for now
    if (*family == 0) {
      vdsa$GetStruct(objID = objID, name = "eqp_family", txt = family);
    }
    
  }
  if (o_family) strcpy(o_family,family);
  if (o_tableName == NULL) {
    retFlag = 1;
    goto wrapup;
  }
  
  if (*family == 0) goto try_quantity; // Try quantity
    
  // Need the cats object
  vdsa$GetCache(catsID = &catsID);
  if (catsID.objid == NULL_OBJID) goto wrapup;
  
  // Get the attribute
  vdbt$GetAttr(objID = &catsID, name = family, fld = &fld);

  // See if found
  if (*fld.name != 0) {
    
    // Parse out the table name
    strcpy(data,fld.val.txt);
    p = strchr(data,':');
    if (p) *p = 0;
  
    if (o_tableName) strcpy(o_tableName,data);
    
    retFlag = 1;
    goto wrapup;
  }
  
  // Try the quantity
try_quantity:

  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  memset(&dbInfo,0,sizeof(dbInfo));

  sts = om$send(msg = message
		ACdb_info.ACget_db_info(&msg,&dbInfo),
		senderid = NULL_OBJID,
		targetid = objID->objid,
		targetos = objID->osnum);

  if (!(sts & msg & 1)) goto wrapup;
  
  *data = 0;
  VDGetDyntblNamebyQuantity(dbInfo.quantity, REG_CHECKIN, data);
  
  if (*data != 0) {
    if (o_tableName) strcpy(o_tableName,data);
    retFlag = 1;
    goto wrapup;
  }
  
wrapup:
  return retFlag;
}

end implementation VDbtBase;

