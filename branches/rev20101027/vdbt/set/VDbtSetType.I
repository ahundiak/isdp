/* $Id: VDbtSetType.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDbtSetType.I
 *
 * Description: Set Type Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtSetType.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/08  21:37:42  pinnacle
# ah
#
# Revision 1.2  1998/04/07  14:36:18  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDbt.h"
#include "VDsaProto.h"

/* ---------------------------------------------
 * Called by master give struct
 * args will be valid
 */
#argsused
extern IGRstar VDbtGetStructSetType
(TGRid       *objID,
 TGRmd_env   *objENV,
 IGRchar     *name,
 Tret_struct *rs
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  i;
  
  TGRid   childID;

  TVDfld fld;
  
  // Set Type
  if (!strcmp(name,VDBT_PDM_SET_TYPE)) {

    vdbt$GetBase(objID = objID, name = rs->var.text_st.text_string);
    rs->type = text_type;
    retFlag = 1;
    goto wrapup;

  }

  // Set Desc
  if (!strcmp(name,VDBT_PDM_SET_DESC)) {

    vdbt$GetBase(objID = objID, fld = &fld);
    strcpy(rs->var.text_st.text_string,fld.val.txt);
    rs->type = text_type;
    retFlag = 1;
    goto wrapup;

  }

  if (!strcmp(name,VDBT_PDM_DYN_TABLE)) {

    // First child object will be the piece
    vdbt$GetObj(objID = objID, ind = 0, childID = &childID); 
    if (childID.objid == NULL_OBJID) goto wrapup;

    // Ask it for the table
    sts = vdsa$GetStruct(objID = &childID, 
                         name  = VDBT_PDM_DYN_TABLE, 
                         rs    = rs);
    
    if (sts & 1) retFlag = 1;
    goto wrapup;

  }

  if (!strcmp(name,VDBT_PDM_TREE_TABLE)) {

    // Last child object will be the piece
    for(i = 0;
	vdbt$GetObj(objID = objID, ind = i, childID = &childID);
	i++);
    if (i == 0) goto wrapup;

    vdbt$GetObj(objID = objID, ind = (i-1), childID = &childID); 
    if (childID.objid == NULL_OBJID) goto wrapup;
    
    // Ask it for the table
    sts = vdsa$GetStruct(objID = &childID, 
                         name  = VDBT_PDM_DYN_TABLE, 
                         rs    = rs);
    
    if (sts & 1) retFlag = 1;
    goto wrapup;

  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Interface for extracting set type information
 */
IGRstat VDbtGetSetType(
  IGRchar *a_setTypeName,
  IGRint   a_ind,
  TGRid   *a_setTypeID,
  TGRid   *a_setTypesID,
  IGRchar *a_tableName

)
{
  IGRstat retFlag = 0;

  TGRid setTypesID;
  TGRid setTypeID;

  IGRchar setTypeName[128];

  IGRint i;

  // Arg check
  if (a_setTypesID) a_setTypesID->objid = NULL_OBJID;
  if (a_setTypeID)  a_setTypeID->objid  = NULL_OBJID;
  if (a_tableName) *a_tableName = 0;

  // Need the set Types
  VDbtGetSetTypes(&setTypesID);
  if (setTypesID.objid == NULL_OBJID) goto wrapup;

  // Xfer value
  if (a_setTypesID) *a_setTypesID = setTypesID;
  retFlag = 1;

  // Want a particular type byname?
  if (a_setTypeName != NULL) {

    for(i = 0; 
        vdbt$GetObj(objID = &setTypesID, ind = i, childID = &setTypeID); 
        i++) {

      vdsa$GetStruct(objID = &setTypeID, 
                     name  = VDBT_PDM_SET_TYPE, 
                     txt   = setTypeName);

      if (!strcmp(a_setTypeName,setTypeName)) {

        if (a_setTypeID) *a_setTypeID = setTypeID;
        retFlag = 1;
        goto have_set_type;
      }
    }
    retFlag = 0;
    goto wrapup;
  }

  // Get by index
  if (a_ind >= 0) {

    vdbt$GetObj(objID = &setTypesID, ind = a_ind, childID = &setTypeID);
    if (setTypeID.objid != NULL_OBJID) {
      if (a_setTypeID) *a_setTypeID = setTypeID;
      retFlag = 1;
      goto have_set_type;
    }
    retFlag = 0;
    goto wrapup;  
  }
  goto wrapup;

  // Need more info about the set type
have_set_type:

  if (a_tableName) {
    vdsa$GetStruct(objID = &setTypeID, 
                   name  = VDBT_PDM_DYN_TABLE, 
                   txt   = a_tableName);
    if (*a_tableName == 0) retFlag = 0;
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Creates a set type object from the database
 */
IGRstar VDbtCreateSetType(TGRid   *setTypesID,
                          IGRchar *setType,
                          IGRchar *setTypeDesc)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar setTypeNodeName[128];
  TGRid   setTypeNodeID;
  TGRid   setTypeID;
  TGRid   tableID;
  TVDflds flds;

  IGRint    row,col;
  IGRint    cols;
  IGRint    rows = 0;
  IGRchar **buf  = NULL;
  IGRchar   sql[1024];

  IGRint    flag;

  // Verify Logeed in
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // Get the table template
  vdsa$GetTableObj(tableName = "vdat_set_nodes", tableID = &tableID);
  if (tableID.objid == NULL_OBJID) goto wrapup;

  // And it's attributes
  vdbt$GetAttrs(objID = &tableID, flds = &flds);
    
  // Do the query
  sprintf(sql,
	  "Select * from vdat_set_nodes "
	  "where set_type = '%s' "
          "order by node_level;",setType);

  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (!(sts & 1)) goto wrapup;

  if ((buf == NULL) || (rows <= 0) || (cols != flds.cnt))  goto wrapup;

  // Flag for tree
  if (rows == 1) flag = 0;
  else           flag = 1;

  // Create the set type
  vdbt$CreateBase(type     =  VDBT_TYPE_SET_TYPE, 
  		  name     =  setType,
                  desc     =  setTypeDesc, 
                  flag     =  flag,
 	          parentID =  setTypesID, 
		  objID    = &setTypeID);
  if (setTypeID.objid == NULL_OBJID) goto wrapup;

  // Each row becomes a node type
  for(row = 0; row < rows; row++) {

    // Fill up template
    for(col = 0; col < cols; col++) {

      vdfld$SetFrom(fld = &flds.fld[col], ris = buf[(row*cols)+col]);

    }

    // Pull the node type from the list
    vdfld$Get(flds = &flds, name = "node_type", txt = setTypeNodeName);

    // Create the node type
    vdbt$CreateBase(type     =  VDBT_TYPE_SET_TYPE_NODE, 
  		    name     =  setTypeNodeName,
		    parentID = &setTypeID, 
		    objID    = &setTypeNodeID);

    if (setTypeNodeID.objid == NULL_OBJID) goto wrapup;

    // Add it
    vdbt$SetAttrs(objID = &setTypeNodeID, flds = &flds);

    // vdbro$PrintObject(objID = &setTypeNodeID);

  }
 
  // Done
  retFlag = 1;

wrapup:

  if (buf) VdsRisFreeBuffer(buf, rows * cols);

  return retFlag;
}


/* --------------------------------------
 * Gets a list of set types
 * Loads from database if required
 */
IGRstar VDbtGetSetTypes(TGRid *a_setTypesID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid setsCacheID;
  TGRid setTypesID;

  IGRint    i;
  IGRint    cols;
  IGRint    rows = 0;
  IGRchar **buf  = NULL;
  IGRchar   sql[1024];

  // Arg check
  if (a_setTypesID) a_setTypesID->objid = NULL_OBJID;

  // Need the master cache
  vdsa$GetCache(setsID = &setsCacheID);
  if (setsCacheID.objid == NULL_OBJID) goto wrapup;

  // Get the set types
  vdbt$GetObj(
    objID   = &setsCacheID, 
    type    = VDBT_TYPE_SET_TYPES,
    childID = &setTypesID);

  if (setTypesID.objid != NULL_OBJID) {
    if (a_setTypesID) *a_setTypesID = setTypesID;
    retFlag = 1;
    goto wrapup;
  }

  // Create if logged in
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // Create the object
  vdbt$CreateBase(type     = VDBT_TYPE_SET_TYPES, 
		  name     = "VDsaSetTypes", 
		  parentID = &setsCacheID, 
		  objID    = &setTypesID);

  if (setTypesID.objid == NULL_OBJID) goto wrapup;
  if (a_setTypesID) *a_setTypesID = setTypesID;

  // Load the individual set types
  sprintf(sql,
	  "Select set_type,set_type_desc "
	  "from vdat_set_types order by set_type;");

  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (!(sts & 1)) goto wrapup;

  if ((buf == NULL) || (cols != 2))  goto wrapup;
  
  // Create Individual Set Type Objects
  for(i = 0; i < rows; i++) {

    VDbtCreateSetType(&setTypesID,buf[(i*cols)+0],buf[(i*cols)+1]);

  }
 
  // Done
  retFlag = 1;

wrapup:
  if (buf) VdsRisFreeBuffer(buf, rows * cols);
  return retFlag;
}

end implementation VDbtBase;
