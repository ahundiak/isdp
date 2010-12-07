/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimGroup.c
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimGroup.c,v $
 *      Revision 1.1.2.2  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/06/06 20:44:19  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "VDobj2.h"

#include "VDdom2.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Attrs.h"

#include "VDctx.h"

VDASSERT_FFN("VDPaimGroup.c");

static void getGroupTree(TGRid *treeID);

static void addAttr(TGRid *groupID, domNode groupNode, char *name1, char *name2)
{
  char buf[128];

  if (name2 == NULL) name2 = name1;

  VDctxGetTxtAtr(groupID,name1,buf);

  domSetTextAttrNodeValue(groupNode,name2,buf);

  return;
}

/* ----------------------------------------------
 * Create an individual group node from
 * a group object
 */
domNode createGroupNode(domNode parentNode, TGRid *groupID)
{
  domNode groupNode;
  IGRchar buf[128];

  IGRchar comp_tagx[128];
  IGRchar comp_path[128];

  /* Make the node */
  groupNode = domCreateNode(parentNode,VDP_XML_NODE_ISDP_POST_OBJECT);

  /* Object id */
  sprintf(buf,"%d",groupID->objid);
  domSetTextAttrNodeValue(groupNode,VDP_XML_ATTR_OBJID,buf);

  /* Class names */
  domSetTextAttrNodeValue(groupNode,VDP_XML_ATTR_ISDP_CLASS_NAME,"VDct1Node");
  domSetTextAttrNodeValue(groupNode,VDP_XML_ATTR_ASIR_CLASS_NAME,VDP_SIR_GROUP_CLASS);

  /* Not sure */
  domSetTextAttrNodeValue(groupNode,VDP_XML_ATTR_ISDP_FSI,    "0");
  domSetTextAttrNodeValue(groupNode,VDP_XML_ATTR_ISDP_IS_EQP, "0");
  domSetTextAttrNodeValue(groupNode,VDP_XML_ATTR_ISDP_DB_TYPE,"123");

  /* Copies */
  addAttr(groupID,groupNode,VDP_XML_ATTR_SIRID,     NULL);
  addAttr(groupID,groupNode,VDP_XML_ATTR_SR_TAG_NUM,NULL);
  addAttr(groupID,groupNode,VDP_XML_ATTR_CAGE,      NULL);
  addAttr(groupID,groupNode,VDP_XML_ATTR_MINO,      NULL);

  addAttr(groupID,groupNode,VDP_XML_ATTR_UNIT_NUMBER,NULL);
  addAttr(groupID,groupNode,VDP_XML_ATTR_ZONE_NUMBER,NULL);

  addAttr(groupID,groupNode,VDCT1_ATTR_COMPARTMENT,VDP_XML_ATTR_COMPT_NUMBER);
  addAttr(groupID,groupNode,VDCT1_ATTR_QTY,        VDP_XML_ATTR_SR_QUANTITY);

  addAttr(groupID,groupNode,VDP_XML_ATTR_LOC_X,NULL);
  addAttr(groupID,groupNode,VDP_XML_ATTR_LOC_Y,NULL);
  addAttr(groupID,groupNode,VDP_XML_ATTR_LOC_Z,NULL);


  /* --------------------------------------------
   * Never go around to makeing these attributes
   */
  VDctxGetCompTagx(groupID,comp_tagx);
  VDctxGetCompPath(groupID,comp_path);
  domCreateTextAttrNode(groupNode,VDP_XML_ATTR_COMP_TAGX,comp_tagx);
  domCreateTextAttrNode(groupNode,VDP_XML_ATTR_COMP_PATH,comp_path);


  /* Some computes */
  VDPaimComputeSirTagNum(groupNode);
  VDPaimComputeLocation (groupNode);


wrapup:
  return groupNode;
}

/* ----------------------------------------------
 * Return a tree of group nodes
 */
domNode VDPaimGetGroups(VDosnum osnum, domNode groupsNode)
{
  TGRid treeID;
  TGRid groupID;

  TVDctxBaseInfo baseInfo;
  TVDctxNodeList nodeList;

  IGRint i;

  /* Init */
  VDctxInitNodeList(&nodeList);

  /* Get the tree */
  getGroupTree(&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  /* Get the group nodes */
  VDctxGetNodeListByType(&treeID,VDCT1_ENG_NODE_TYPE_GROUP,&nodeList);
  if (nodeList.cnt == 0) goto wrapup;

  /* The document if necessary */
  if (groupsNode == NULL) groupsNode = domCreateDoc("groups");

  /* Cycle through */
  for(i = 0; i < nodeList.cnt; i++)
  {
    groupID = nodeList.listIDs[i];
    createGroupNode(groupsNode,&groupID);
  }


wrapup:
  VDctxFreeNodeList(&nodeList);

  return groupsNode;
}
/* -----------------------------------------------
 * Little utility for getting the first group tree
 */
static void getGroupTree(TGRid *a_treeID)
{
  TVDctxTreeTypeWalk data;
  TVDctxBaseInfo     baseInfo;

  // Init
  memset(&data,0,sizeof(TVDctxTreeTypeWalk));
  data.firstID.objid = NULL_OBJID;
  strcpy(data.baseInfo.treeType,VDCT1_TREE_TYPE_GRP_PLACE);
  data.match.treeType = 1;
  
  // Do it
  VDctxWalkAllTrees(0,VDctxWalkProcessByTypeName,&data);
  if (data.firstID.objid != NULL_OBJID) VDctxGetBaseInfo(&data.firstID,&baseInfo);
  else                                  memset(&baseInfo,0,sizeof(TVDctxBaseInfo));
  

  if (a_treeID) *a_treeID = data.firstID;
  
  // Done
 wrapup:
  return;
}

