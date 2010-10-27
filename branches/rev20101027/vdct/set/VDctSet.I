/* $Id: VDctSet.I,v 1.1.1.1 2001/01/04 21:08:01 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/set/VDctSet.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctSet.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:01  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/30  14:27:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/29/99  ah      Creation
 ***************************************************************************/
class implementation VDctBase;

#include "VDct.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDppl1.h"

static int traceFlag;

/* ------------------------------------------------------
 * Creates a new set
 */
#argsused
IGRstat VDctCreateSet(TGRid   *mgrID,
                      IGRchar *setType,
                      IGRchar *setTypeRev,
                      IGRchar *setName,
                      TGRid   *setID)
{
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;

  TVDctSetTypeInfo setTypeInfo;
  TVDctBaseInfo    baseInfo;

  // Arg check
  if (setID == NULL) goto wrapup; 
  setID->objid = NULL_OBJID;
  if ((mgrID == NULL) || (mgrID->objid == NULL_OBJID)) goto wrapup;
  if ((setType == NULL) || (*setType == 0)) goto wrapup;
  if ((setName == NULL) || (*setName == 0)) goto wrapup;

  traceFlag = 1;
  if (traceFlag) {
    printf(">>> VDctCreateSet %s %s\n",setType,setName);
  }
 
  // Get some info, makes sure ppl is available
  vdct$GetSetTypeInfo(setType = setType, setTypeInfo = &setTypeInfo);
  if (*setTypeInfo.type == 0) goto wrapup;

  // Make the object
  vdct$CreateBaseObject(osnum     = mgrID->osnum,
                        classType = VDCT_CLASS_TYPE_SET,
                        objID     = setID);
  if (setID->objid == NULL_OBJID) goto wrapup;

  // Connect to manager
  vdct$ConnectMgrChild(mgrID   = mgrID,
		       childID = setID);
  if (traceFlag) vdobj$Print(objID = setID);

  // Set info
  memset(&baseInfo,0,sizeof(TVDctBaseInfo));
  strcpy(baseInfo.setName,   setName);
  strcpy(baseInfo.setType,   setType);

  if (setTypeRev) strcpy(baseInfo.setTypeRev,setTypeRev);
  else            strcpy(baseInfo.setTypeRev,setTypeInfo.rev);

  vdct$SetBaseInfo(objID = setID, baseInfo = &baseInfo);

  // Give the ppl a shot at it
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "SET_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)setID);
  
  vdppl$Run(pplID = &pplID, name = "createSet", ret = &pplRet);
  
  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< VDctCreateSet %d\n",retFlag);
  }
  return retFlag;
}

/* ---------------------------------------------------
 * Gets the set type information for a given set type
 */
IGRstat VDctGetSetTypeInfo(IGRchar *setType, TVDctSetTypeInfo *setTypeInfo)
{
  IGRstat retFlag = 0;

  TGRid  pplID;
  IGRint pplRet;

  // Arg check
  if (setTypeInfo == NULL) goto wrapup;
  memset(setTypeInfo,0,sizeof(TVDctSetTypeInfo));
  if ((setType == NULL) || (*setType == 0)) goto wrapup;

  // Open ppl
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // Do It
  vdppl$Run(pplID = &pplID, name = "getSetTypeInfo", ret = &pplRet);

  // Pull results
  vdppl$GetData(pplID = &pplID,
                name  = "SET_TYPE",
                size  = sizeof(TVDctSetType),
                data  = setTypeInfo->type);

  vdppl$GetData(pplID = &pplID,
                name  = "SET_TYPE_REV",
                size  = sizeof(TVDctSetTypeRev),
                data  = setTypeInfo->rev);

  vdppl$GetData(pplID = &pplID,
                name  = "SET_TYPE_DESC",
                size  = sizeof(TVDctSetTypeDesc),
                data  = setTypeInfo->desc);

  vdppl$GetData(pplID = &pplID,
                name  = "SET_TYPE_NODE_TABLE",
                size  = sizeof(TVDctSetTypeTable),
                data  = setTypeInfo->nodeTable);

  vdppl$GetData(pplID = &pplID,
                name  = "SET_TYPE_LEAF_TABLE",
                size  = sizeof(TVDctSetTypeTable),
                data  = setTypeInfo->leafTable);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDctBase;

















