/* $Id: VDatType.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatType.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDatType.I,v $
 * Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/10/25  12:07:44  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/25/98  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

#include "VDppl1.h"

/* ----------------------------------------------------
 * Interfaces to ppl for set type node information 
 */
IGRstar VDatGetSetNodeInfo(

  IGRchar *i_setType,
  TGRid   *i_setID,

  IGRint   i_setNodeInd, 
  IGRchar *i_setNodeType,
  TGRid   *i_setNodeID,

  IGRchar *o_setNodeType,
  IGRchar *o_setNodeDesc,
  IGRchar *o_setNodeTable,
  IGRint  *o_setNodeLevel
 )
{
  IGRstat retFlag = 0;

  TGRid   pplID;
  IGRint  pplRET;

  IGRchar setType[64];
  IGRchar setNodeType[64];

  IGRchar data[64];
  IGRint  datai;

  /* Init */
  if (o_setNodeType)  *o_setNodeType  = 0;
  if (o_setNodeDesc)  *o_setNodeDesc  = 0;
  if (o_setNodeTable) *o_setNodeTable = 0;
  if (o_setNodeLevel) *o_setNodeLevel = 0;

  /* Get the set type */
  *setType = 0;
  if (i_setID)   VDatRDBGetSetType(i_setID,setType);
  if (i_setType) strcpy(setType,i_setType);
  if (*setType == 0) goto wrapup;

  /* Load the ppl */
  vdppl$Load(name = i_setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  /* If the index >= 0 then just get nth item */
  if (i_setNodeInd >= 0) {
    datai = i_setNodeInd;
    vdppl$SetData(
      pplID = &pplID,
      name  = "NODE_IND",
      size  = sizeof(IGRint),
      data  = (IGRchar*)&datai);

    vdppl$Run(pplID = &pplID, name = "getSetNodeInfo", ret = &pplRET);
    goto got_it;
  }

  /* Must want a specific type */
  *setNodeType = 0;
  if (i_setNodeID)   VDatRDBGetNodeType(i_setNodeID,setNodeType);
  if (i_setNodeType) strcpy(setNodeType,i_setNodeType);
  if ( *setNodeType == 0) goto wrapup;

  /* Cycle through and find it */
  *data = '1';
  for(datai = 0; *data; datai = datai + 1) {

    vdppl$SetData(
      pplID = &pplID,
      name  = "NODE_IND",
      size  = sizeof(IGRint),
      data  = (IGRchar*)&datai);

    vdppl$Run(pplID = &pplID, name = "getSetNodeInfo", ret = &pplRET);

    vdppl$GetData(
      pplID = &pplID,
      name  = "NODE_TYPE",
      size  = 64,
      data  = data);

    if (!strcmp(setNodeType,data)) goto got_it; 
  }

  /* Failed */
  vdppl$Delete(pplID =&pplID);
  goto wrapup;

  /* Now pull the data */
got_it:  
  if (o_setNodeType) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "NODE_TYPE",
      size  = 64,
      data  = data);
    strcpy(o_setNodeType,data);
  }

  if (o_setNodeDesc) {     
    vdppl$GetData(
      pplID = &pplID,
      name  = "NODE_DESC",
      size  = 64,
      data  = data);
    strcpy(o_setNodeDesc,data);
  }

  if (o_setNodeTable) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "NODE_TABLE",
      size  = 64,
      data  = data);
    strcpy(o_setNodeTable,data);
  }

  if (o_setNodeLevel) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "NODE_LEVEL",
      size  = sizeof(IGRint),
      data  = (IGRchar*)&datai);
    *o_setNodeLevel = datai;
  }
  vdppl$Delete(pplID = &pplID);

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Interfaces to ppl for set type information 
 */
IGRstar VDatGetSetTypeInfo(
  IGRint   i_setInd, 
  TGRid   *i_setID,
  IGRchar *i_setType,
  IGRchar *o_setType,
  IGRchar *o_setTypeDesc,
  IGRchar *o_setTypeLeafTable,
  IGRchar *o_setTypeTreeTable,
  IGRint  *o_setTypeIsTree,
  IGRint  *o_setTypeDoSum,
  IGRint  *o_setTypeRev
 )
{
  IGRstat retFlag = 0;
  IGRchar setType[64];

  TGRid   pplID;
  IGRint  pplRET;

  IGRchar data[64];
  IGRint  datai;

  /* Init */
  if (o_setType)          *o_setType          = 0;
  if (o_setTypeDesc)      *o_setTypeDesc      = 0;
  if (o_setTypeLeafTable) *o_setTypeLeafTable = 0;
  if (o_setTypeTreeTable) *o_setTypeTreeTable = 0;
  if (o_setTypeIsTree)    *o_setTypeIsTree    = 0;
  if (o_setTypeDoSum)     *o_setTypeDoSum     = 0;
  if (o_setTypeRev)       *o_setTypeRev       = 0;

  /* Get the set type */
  *setType = 0;

  /* Non-neg index means to use the nth set */
  if (i_setInd >= 0) {

    vdppl$Load(name = "VDatSets", pplID = &pplID);
    if (pplID.objid == NULL_OBJID) goto wrapup;

    datai = i_setInd;

    vdppl$SetData(
      pplID = &pplID,
      name  = "SET_TYPE_IND",
      size  = sizeof(IGRint),
      data  = (IGRchar *)&datai);

    vdppl$Run(pplID = &pplID, name = "getSetType", ret = &pplRET);

    vdppl$GetData(
      pplID = &pplID,
      name  = "SET_TYPE",
      size  = 64,
      data  = setType);

    vdppl$Delete(pplID = &pplID);
  }

  /* If an object was passed, get it's set */
  if (i_setID) {
    VDatRDBGetSetType(i_setID,setType);
  }

  /* If the actual name was passed user it */
  if (i_setType) {
    strcpy(setType,i_setType);
  }

  /* Store it */
  if (o_setType) strcpy(o_setType,setType);
  if (*setType == 0) goto wrapup;

  /* Get the info stuff */
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;
  vdppl$Run(pplID = &pplID, name = "getSetTypeInfo", ret = &pplRET);

  if (o_setTypeDesc) { 
    vdppl$GetData(
      pplID = &pplID,
      name  = "SET_TYPE_DESC",
      size  = 64,
      data  = data);
    strcpy(o_setTypeDesc,data);
  }

  if (o_setTypeLeafTable) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "SET_TYPE_LEAF_TABLE",
      size  = 64,
      data  = data);
      strcpy(o_setTypeLeafTable,data);
  }

  if (o_setTypeTreeTable) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "SET_TYPE_TREE_TABLE",
      size  = 64,
      data  = data);
      strcpy(o_setTypeTreeTable,data);
  }
  if (o_setTypeIsTree) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "SET_TYPE_IS_TREE",
      size  = sizeof(IGRint),
      data  = (IGRchar*)&datai);
      *o_setTypeIsTree = datai;
  }
  if (o_setTypeDoSum) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "SET_TYPE_DO_SUM",
      size  = sizeof(IGRint),
      data  = (IGRchar*)&datai);
      *o_setTypeDoSum = datai;
  }
  if (o_setTypeRev) {
    vdppl$GetData(
      pplID = &pplID,
      name  = "SET_TYPE_REV",
      size  = sizeof(IGRint),
      data  = (IGRchar*)&datai);
      *o_setTypeRev = datai;
  }
  vdppl$Delete(pplID = &pplID);

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

