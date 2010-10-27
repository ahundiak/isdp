/* $Id: VDbtSet.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDbtSet.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtSet.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/08  21:37:22  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/08/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDbt.h"
#include "VDsaProto.h"

#if 0

/* --------------------------------------
 * Gets set info for a set
 */
IGRstar VDbtGetSet
(VDosnum  i_osnum,

 IGRint   i_setInd,
 IGRchar *i_setName,
 IGRchar *i_setType,
 IGRchar *i_setKey,
 TGRid   *i_setID,

 IGRchar *o_setName,
 IGRchar *o_setType,
 IGRchar *o_setKey,
 TGRid   *o_setID,
 IGRchar *o_setDesc
 )

{

  IGRstat retFlag = 0;

  TGRid   setsID;
  TGrid   setID;
  
  TVDfld  fld;

  IGRchar buf[128];
  IGRchar *p;

  // Arg Check
  if (o_setName) *o_setName = 0;
  if (o_setType) *o_setType = 0;
  if (o_setDesc) *o_setDesc = 0;
  if (o_setKey)  *o_setKey  = 0;
  if (o_setID)   *o_setID->objid = NULL_OBJID;

  // See if set was passed
  setID.objid = NULL_OBJID;
  if (a_setID) setID = *a_setID;
  if (setID.objid != NULL_OBJID) goto have_set;
  
  // Get the list of sets
  vdbt$GetSets(setsID =  &setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Find the nth one
  if (i_setInd >= ) {
    
    vdbt$GetAttr(objID = &setsID, ind = setInd, fld = &fld);
    if (*fld.name == 0) goto wrapup;

  if (setDesc) strcpy(setDesc,fld.val.txt);

  strcpy(buf,fld.name);
  p = strchr(buf,':');
  if (p) *p = 0;

  if (setType) strcpy(setType,buf);

  if ((setName) && (p)) strcpy(setName,p+1);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Checks to see if set exists
 */
IGRstat VDbtIsSet
 (VDosnum osnum,
  IGRchar *setName,
  IGRchar *setType
 )
{
  IGRstat retFlag = 0;

  TGRid   setsID;
  IGRchar buf[128];

  TVDfld fld;

  // Arg check
  if ((setName == NULL) || (setType == NULL)) goto wrapup;
  sprintf(buf,"%s:%s",setType,setName);

  // Get the list of sets
  VDbtGetSets(osnum,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Find it
  vdbt$GetAttr(objID = &setsID, name = buf, fld = &fld);
  if (*fld.name == 0) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

#endif

IGRstat VDbtCreateSet
(VDosnum osnum,
 IGRchar *setName,
 IGRchar *setType,
 IGRchar *setDesc,
 TGRid   *setID
)
{
  IGRstat retFlag;

  TGRid   setsID;
  TGRid   leafsID;
  TGRid   setTypeID;

  IGRint  flag;

  IGRchar name[128];
  IGRchar desc[128];

  // Arg check
  if (setID == NULL) goto wrapup;
  setID->objid == NULL_OBJID;

  // The id
  if ((setName == NULL) || (setType == NULL)) goto wrapup;
  sprintf(name,"%s:%s",setType,setName);

  // Optional description
  if (setDesc) strcpy(desc,setDesc);
  else          *desc = 0;

  // Get the set list
  vdbt$GetSets(setsID = &setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Get the type object
  vdbt$GetSetType(setType = setType, setTypeID = &setTypeID);
  if (setTypeID.objid == NULL_OBJID) goto wrapup;

  // Flag for tree
  vdsa$GetStruct(objID = &setTypeID, name = VDBT_PDM_SET_IS_TREE, jnt = &flag);

  // Create it
  vdbt$CreateBase(type     =  VDBT_TYPE_SET, 
  		  name     =  name,
                  desc     =  desc, 
                  flag     =  flag,
 	          parentID = &setsID, 
		  objID    =  setID);
  if (setID->objid == NULL_OBJID) goto wrapup;

  // Add Leafs holder
  vdbt$CreateBase(type     =  VDBT_TYPE_LEAFS, 
  		  name     =  "VDbtLeafs",
 	          parentID =  setID, 
		  objID    = &leafsID);
  if (leafsID.objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}


end implementation VDbtBase;

