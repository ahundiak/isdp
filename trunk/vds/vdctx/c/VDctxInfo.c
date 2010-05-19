/* $Id: VDctxInfo.c,v 1.3 2001/03/13 00:17:58 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxInfo.c
 *
 * Description: Base information functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxInfo.c,v $
 *      Revision 1.3  2001/03/13 00:17:58  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/26 15:46:10  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/22 22:47:18  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/22/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDlog.h"

VDASSERT_FFN("vdctx/c/VDctxInfo.c");

/* -----------------------------------------------
 * Validate the base information for all items
 * If the flag is set then silently fix ':'
 * Let the calling routine take care of notifying the users
 */

IGRstat VDctxValidateBaseInfo(IGRint flag, TVDctxBaseInfo *baseInfo)
{
  VDASSERT_FN("VDctxValidateBaseInfo");
  IGRstat retFlag = 0;
  IGRchar *p;
  
  // Arg checks
  VDASSERTW(baseInfo);

  // Catch some possible overflows
  VDASSERTW(strlen(baseInfo->setType)    < VDCTX_MAX_TYPE_LEN);
  VDASSERTW(strlen(baseInfo->setTypeRev) < VDCTX_MAX_TYPE_REV_LEN);
  VDASSERTW(strlen(baseInfo->setName)    < VDCTX_MAX_NAME_LEN);
  VDASSERTW(strlen(baseInfo->nodeType)   < VDCTX_MAX_TYPE_LEN);
  VDASSERTW(strlen(baseInfo->nodeName)   < VDCTX_MAX_NAME_LEN);

  // Might also want to protect against setting without names and types
  VDASSERTW(*baseInfo->setType);
  VDASSERTW(*baseInfo->setName);
  VDASSERTW(*baseInfo->nodeType);
  // VDASSERTW(*baseInfo->nodeName);

  // Check for or fix ':'
  if (flag == 0) {
    p = strchr(baseInfo->setType,':');    VDASSERTW(!p);
    p = strchr(baseInfo->setTypeRev,':'); VDASSERTW(!p);
    p = strchr(baseInfo->setName,':');    VDASSERTW(!p);
    p = strchr(baseInfo->nodeType,':');   VDASSERTW(!p);
    p = strchr(baseInfo->nodeName,':');   VDASSERTW(!p);
  }
  else {
    for(p = baseInfo->setType;    *p; p++) { if (*p == ':') *p = '_'; }
    for(p = baseInfo->setTypeRev; *p; p++) { if (*p == ':') *p = '_'; }
    for(p = baseInfo->setName;    *p; p++) { if (*p == ':') *p = '_'; }
    for(p = baseInfo->nodeType;   *p; p++) { if (*p == ':') *p = '_'; }
    for(p = baseInfo->nodeName;   *p; p++) { if (*p == ':') *p = '_'; }
  }

  // Until set stuff goes away
  if (*baseInfo->treeType == 0) strcpy(baseInfo->treeType,baseInfo->setType);
  if (*baseInfo->treeTRev == 0) strcpy(baseInfo->treeTRev,baseInfo->setTypeRev);
  if (*baseInfo->treeName == 0) strcpy(baseInfo->treeName,baseInfo->setName);

  // Ok
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Compare two baseInfos
 */
IGRint VDctxCompareBaseInfo(TVDctxBaseInfo *info1, TVDctxBaseInfo *info2)
{
  VDASSERT_FN("TVDctxCompareBaseInfo");
  
  IGRint sts = 0;
  
  VDASSERTW(info1);
  VDASSERTW(info1);

  // Simple compares
  sts = strcmp(info1->treeType,info2->treeType);
  if (sts) goto wrapup;
  sts = strcmp(info1->treeName,info2->treeName);
  if (sts) goto wrapup;
  sts = strcmp(info1->nodeType,info2->nodeType);
  if (sts) goto wrapup;
  sts = strcmp(info1->nodeName,info2->nodeName);
  if (sts) goto wrapup;
  
 wrapup:
  return sts;
}

/* -----------------------------------------------
 * Gets the suffix from node types
 * Useful for dropping prefixes from plates and beams
 */
void VDctxGetNodeTypeSuffix(TGRid *nodeID, IGRchar *nodeType)
{
  VDASSERT_FN("VDctxGetNodeTypeSuffix");
  
  IGRchar *p;
  
  VDASSERTW(nodeType); *nodeType = 0;
  
  VDctxGetNodeType(nodeID,nodeType);
  p = strrchr(nodeType,'_');
  if (p) strcpy(nodeType,p+1);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Compare two node names
 */
IGRint VDctxCompareNodeName(const void *void1, const void *void2)
{
  TGRid *node1ID = (TGRid *) void1;
  TGRid *node2ID = (TGRid *) void2;

  IGRchar buf1[128];
  IGRchar buf2[128];

  VDctxGetNodeName(node1ID,buf1);
  VDctxGetNodeName(node2ID,buf2);
    
  return strcmp(buf1,buf2);
}

/* -----------------------------------------------
 * Compare two node types and names
 */
IGRint VDctxCompareNodeTypeName(const void *void1, const void *void2)
{
  TGRid *node1ID = (TGRid *) void1;
  TGRid *node2ID = (TGRid *) void2;

  IGRint sts;
  
  IGRchar buf1[128];
  IGRchar buf2[128];

  // The type
  VDctxGetNodeType(node1ID,buf1);
  VDctxGetNodeType(node2ID,buf2);
  sts = strcmp(buf1,buf2);
  if (sts) return sts;

  // The name
  VDctxGetNodeName(node1ID,buf1);
  VDctxGetNodeName(node2ID,buf2);    
  return strcmp(buf1,buf2);
}
