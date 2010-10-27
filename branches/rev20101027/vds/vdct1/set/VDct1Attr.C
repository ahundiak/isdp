/* $Id: VDct1Attr.C,v 1.2 2001/03/12 20:36:33 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Attr.I
 *
 * Description: Low Level Attribute Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Attr.C,v $
 *      Revision 1.2  2001/03/12 20:36:33  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.1  2001/01/12 14:53:34  art
 *      sp merge
 *
 * Revision 1.1  2000/07/25  18:38:22  pinnacle
 * ah
 *
# Revision 1.4  2000/07/20  13:07:14  pinnacle
# ah
#
# Revision 1.3  2000/05/23  18:34:28  pinnacle
# Replaced: vds/vdct1/set/VDct1Attr.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/11  13:25:02  pinnacle
# Replaced: vds/vdct1/set/VDct1Attr.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:41:28  pinnacle
# Created: vds/vdct1/set/VDct1Attr.I by pnoel for Service Pack
#
# Revision 1.3  2000/01/11  22:26:02  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:28:52  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 12/17/99  pn      Update Prototypes in VDct1.h (up to date)
 * 05/16/00  pn      Added some alterations related to the development of
 *                   changes to the Attribute form to allow hiding of 
 *                   data from user changes
 * 07/19/00  ah      Tree Interface
 ***************************************************************************/

#include "VDobj.h"
#include "VDct1.h"
#include "VDct1Tree.h"

#include "VDppl1.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Attr.C");
#if 0
/* -------------------------------------------------------
 * Returns a value for number of protected attributes to display
 * on the Attribute Form
 * I - BASE_INFO   - baseInfo
 * 0 - ATTR_OFFSET - attrOffset
 * purpose to allow writing of node attributes to the two sections
 * on the attribute form without goofing up access to the attributes
 ************ ppl wrapper ********
 */
IGRstat VDct1GetAttrOffset(TGRid  *nodeID,
			   IGRint *attrOffset)
{
  VDASSERT_FN("VDct1GetAttrOffset");
  
  IGRstat retFlag = 0;
  TGRid   safeID;
  TGRid   pplID;
  IGRint  pplRet;
  TVDctBaseInfo baseInfo;
  // say hi
  pplRet = 0;
  if (traceFlag) printf(">>> VDct1GEtAttrOffset\n");

  // args check no data no action 
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  //if (*attrOffset == 0) goto wrapup; and a keepsafe
  safeID.osnum = nodeID->osnum;
  safeID.objid = nodeID->objid;
  
  // Need baseInfo
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.setType  == 0) goto wrapup;
  if (*baseInfo.nodeType == 0) goto wrapup;

  // Open the ppl
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
		name  = "BASE_INFO",
		size  = sizeof(TVDctBaseInfo),
		data  = (IGRchar*)&baseInfo);

  // Get it
  vdppl$Run(pplID = &pplID, name = "getAttrOffset", ret = &pplRet);

  *attrOffset = pplRet;
  
  // oh well
wrapup:
  // keep out trouble
  nodeID->osnum = safeID.osnum;
  nodeID->objid = safeID.objid;
  // say bye
  if (traceFlag) {
    printf("attrOffset is set to [%d]\n",*attrOffset);
    printf("<<< VDct1GEtAttrOffset(%d)\n",pplRet);
  }
  return pplRet;
  
}
#endif

/* -------------------------------------------------------
 * Returns detailed attribute information
 */
IGRstat VDct1GetAttrInfo(TGRid         *objID,
			 TVDctAttrName  attrName,
			 TVDctAttrInfo *attrInfo)
{
  VDASSERT_FN("VDct1GetAttrInfo");
  
  IGRstat retFlag = 0;
  
  TVDctBaseInfo baseInfo;
  TVDctAttrName attrNamex;
  
  TGRid  pplID;
  IGRint pplRet;

  TVDct1JD objJD;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> VDct1GetAttrInfo %s\n",attrName);
    vdobj$Print(objID = objID);
  }
  
  // Arg Check
  if (attrInfo == NULL) goto wrapup;
  memset(attrInfo,0,sizeof(TVDctAttrInfo));

  if (attrName == NULL) goto wrapup;
  if (objID    == NULL) goto wrapup;
  
  // Tree interface
  objJD.cl = VDct1GetTreeClassForNode(objID);
  if (objJD.cl) {
    objJD.id = *objID;
    objJD.id.objid = NULL_OBJID;
    _RTCJDB(&objJD)->getNodeAttrInfo(&objJD,attrName,attrInfo);
    return 1;
  }

  // Need set type
  vdct1$GetBaseInfo(objID = objID, baseInfo = &baseInfo);
  if (*baseInfo.setType  == 0) goto wrapup;
  if (*baseInfo.nodeType == 0) goto wrapup;

  if (traceFlag) {
    printf("SetType %s, Node Type %s\n",baseInfo.setType,baseInfo.nodeType);
  }
  
  // Open the ppl
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
		name  = "NODE_TYPE",
		size  = sizeof(TVDctNodeType),
		data  = baseInfo.nodeType);

  strcpy(attrNamex,attrName);
  vdppl$SetData(pplID = &pplID,
		name  = "ATTR_NAMEX",
		size  = sizeof(TVDctAttrName),
		data  = attrNamex);
  
  // Get it
  vdppl$Run(pplID = &pplID, name = "getAttrInfo", ret = &pplRet);

  vdppl$GetData(pplID = &pplID,
		name  = "ATTR_INFO",
		size  = sizeof(TVDctAttrInfo),
		data  = (IGRchar*)attrInfo);

  if (*attrInfo->name == 0) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< VDct1GetAttrInfo %d\n",retFlag);
  }
  
  return retFlag;
}

/* --------------------------------------------------------
 * Fills up the structure
 */
IGRstat VDct1SetAttrInfo(IGRchar *name,
			 IGRint   type,
			 IGRint   len,
			 IGRchar *base,
			 IGRchar *desc,
			 IGRchar *defaultValue,
			 IGRchar *pickList,
			 IGRchar *validate,
			 TVDctAttrInfo *attrInfo)
{
  IGRstat retFlag = 0;
  
  // Arg Check
  if (attrInfo == NULL) goto wrapup;
  memset(attrInfo,0,sizeof(TVDctAttrInfo));
  
  attrInfo->type = type;
  attrInfo->len  = len;

  if (name) strcpy(attrInfo->name,name);
  if (name) strcpy(attrInfo->base,name);
  if (base) strcpy(attrInfo->base,base);
  if (desc) strcpy(attrInfo->desc,desc);

  if (defaultValue) strcpy(attrInfo->defaultValue,defaultValue);
  if (pickList)     strcpy(attrInfo->pickList,    pickList);
  if (validate)     strcpy(attrInfo->validate,    validate);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}


















