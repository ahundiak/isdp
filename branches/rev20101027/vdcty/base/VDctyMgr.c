/* $Id: VDctyMgr.c,v 1.3 2001/03/11 18:38:03 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctyMgr.c
 *
 * Description: Context Classes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctyMgr.c,v $
 *      Revision 1.3  2001/03/11 18:38:03  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/17 14:24:12  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:00:47  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 * 03/11/01  ah      VDgbl base initializaton
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDcty.h"

VDASSERT_FFN("vdcty/base/VDctyMgr.c");
#if 0
/* -----------------------------------------------
 * Predefined tree classes
 */
static TVDctyTP *tps[32];

/* -----------------------------------------------
 * Get the nth tree class
 */
TVDctyTP *VDctyGetNthTP(IGRint nth)
{
  
  VDASSERT_FN("VDctxGetNthTP");
  
  TVDctyTP *tp  = NULL;
  TVDctyTP *tpb = NULL;
  
  // Be careful
  VDASSERTW((nth >= 0) && (nth <= 32));
  
  // Get the class
  tp = tps[nth];
  if (tp) goto wrapup;

  // Allocate room for it
  tp = calloc(1,sizeof(TVDctyTP));
  VDASSERTW(tp);
  
  // Custom init system
  switch(nth) {

    case VDCTY_CLASSI_BASE_TREE:
      VDctyInitBaseTP(tp);
      break;

    case VDCTY_CLASSI_STAGING_TREE:
      tpb = VDctyGetNthTP(VDCTY_CLASSI_BASE_TREE);
      VDASSERTW(tpb);
      // VDctyInitStagingTP(tpb,tp);
      break;

    case VDCTY_CLASSI_PROD_TREE:
      tpb = VDctyGetNthTP(VDCTY_CLASSI_BASE_TREE);
      VDASSERTW(tpb);
      VDctyInitProdTP(tpb,tp);
      break;

    case VDCTY_CLASSI_STD_PARTS_TREE:
      tpb = VDctyGetNthTP(VDCTY_CLASSI_PROD_TREE);
      VDASSERTW(tpb);
      VDctyInitStdPartsTP(tpb,tp);
      break;

    case VDCTY_CLASSI_PLOT_TREE:
      tpb = VDctyGetNthTP(VDCTY_CLASSI_BASE_TREE);
      VDASSERTW(tpb);
      VDctyInitPlotTP(tpb,tp);
      break;

    default:
      VDASSERTW(0);
      
  }
  
  // Store it
  tps[nth] = tp;
    
  // Done
wrapup:
  return tp;
}
#endif

/* -----------------------------------------------
 * Get the tp for a given tree type
 */
TVDctyTP *VDctyGetTreeTypeTP(IGRchar *treeName)
{
  VDASSERT_FN("VDctyGetTreeTypeTP");

  TVDctyTP *tp = NULL;

  // Arg check
  VDASSERTW(treeName && *treeName);

  // Go through all possibilities
  if (!strcmp(treeName,VDCTY_CLASSN_BASE_TREE)) {
    tp = VDctyGetNthTP(VDCTY_CLASSI_BASE_TREE);
    goto wrapup;
  }
  if (!strcmp(treeName,VDCTY_CLASSN_PLOT_TREE)) {
    tp = VDctyGetNthTP(VDCTY_CLASSI_PLOT_TREE);
    goto wrapup;
  }
  if (!strcmp(treeName,VDCTY_CLASSN_PROD_TREE)) {
    tp = VDctyGetNthTP(VDCTY_CLASSI_PROD_TREE);
    goto wrapup;
  }
  if (!strcmp(treeName,VDCTY_CLASSN_STD_PARTS_TREE)) {
    tp = VDctyGetNthTP(VDCTY_CLASSI_STD_PARTS_TREE);
    goto wrapup;
  }
  
  // Done
  VDASSERTW(tp);
  
 wrapup:
  return tp;
}

/* -----------------------------------------------
 * Main tree pointer wrapper
 * Return base pointer for NULL_OBJID
 */
TVDctyTP *VDctyGetNodeTP(TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("VDctyGetNodeTP");
  
  TVDctxBaseInfo baseInfo;
  TVDctyTP *tp = NULL;

  // Arg check
  VDASSERTW(nodeID);
  
  // Is it NULL_OBJID
  if (nodeID->objid == NULL_OBJID) {
    tp = VDctyGetNthTP(VDCTY_CLASSI_BASE_TREE);
    goto wrapup;
  }
  
  // Need set type
  VDctxGetBaseInfoCP(cp,nodeID,&baseInfo);
  VDASSERTW(*baseInfo.setType);
  
  tp = VDctyGetTreeTypeTP(baseInfo.setType);
  
 wrapup:
  return tp;
}

/* -----------------------------------------------
 * Returns tree pointers for a given application
 * use to cycle through list of available tree types
 */
TVDctyTP *VDctyGetNthTP_ForApp(IGRint app, IGRint nth)
{
  TVDctyTP *tp = NULL;
  
  switch(nth) {
  case 0: 
    tp = VDctyGetNthTP(VDCTY_CLASSI_PLOT_TREE);
    break;
  case 1:
    tp = VDctyGetNthTP(VDCTY_CLASSI_STD_PARTS_TREE);
    break;
  }
  
wrapup:
  return tp;
}

/* -----------------------------------------------
 * VDctyGetNodeTypeInfo
 */
IGRstat VDctyGetNodeTypeInfo(TVDctyTP *tp,  TVDctxCP *cp, TGRid *nodeID, 
			     IGRint nth, IGRint *cnt, TVDctyNodeTypeInfo *info)
{
  VDASSERT_FN("VDctyGetNodeTypeInfo");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(info);
  memset(info,0,sizeof(TVDctyNodeTypeInfo));
  if (cnt) *cnt = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getNodeTypeInfo);

  // Doit
  retFlag = tp->getNodeTypeInfo(tp,cp,nodeID,nth,cnt,info);
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyGetNodeAttrName
 */
IGRstat VDctyGetNodeAttrName(TVDctyTP *tp,  TVDctxCP *cp, TGRid *nodeID, 
			     IGRchar *nodeType, IGRint nth, IGRchar *attrName)
{
  VDASSERT_FN("VDctyGetNodeAttrInfo");
  IGRstat retFlag = 0;
  
  TVDctxBaseInfo baseInfo;
  
  // Arg check
  VDASSERTW(attrName); *attrName = 0;
  
  // Get the node type
  if (nodeType) strcpy(baseInfo.nodeType,nodeType);
  else          VDctxGetBaseInfoCP(cp,nodeID,&baseInfo);
  VDASSERTW(*baseInfo.nodeType);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getNodeAttrName);

  // Doit
  retFlag = tp->getNodeAttrName(tp,cp,nodeID,baseInfo.nodeType,nth,attrName);
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyGetNodeAttrInfo
 */
void VDctyGetNodeAttrInfo(TVDctyTP *tp,  TVDctxCP *cp, TGRid *nodeID, 
			  IGRchar *name, TVDctyAttrInfo *attrInfo)
{
  VDASSERT_FN("VDctyGetNodeAttrInfo");
  
  // Arg check
  VDASSERTW(attrInfo);
  memset(attrInfo,0,sizeof(TVDctyAttrInfo));
  VDASSERTW(name && *name);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getNodeAttrInfo);

  // Doit
  tp->getNodeAttrInfo(tp,cp,nodeID,name,attrInfo);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * VDcty
 */
IGRstat VDctyValidateAttrValue(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			       IGRchar  *attrName,
			       IGRchar  *attrValue,
			       IGRchar  *attrValuex,
			       IGRchar  *msg)
{
  VDASSERT_FN("VDctyValidateAttrValue");
  IGRstat retFlag = 1;

  // Arg check
  VDASSERTW(attrValuex); *attrValuex = 0;
  VDASSERTW(attrValue);
  VDASSERTW(attrName);
  if (msg) *msg = 0;

  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->validateAttrValue);
  
  // Do it
  retFlag = tp->validateAttrValue(tp,cp,nodeID,attrName,attrValue,attrValuex,msg);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDcty
 */
IGRstat VDctySetNodeUserInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			     TVDctyUserInfo *info)
{
  VDASSERT_FN("VDctySetNodeUserInfo");
  IGRstat retFlag = 1;
  
  // Arg check
  VDASSERTW(info);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->setNodeUserInfo);
  
  // Do it
  retFlag = tp->setNodeUserInfo(tp,cp,nodeID,info);


 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDcty
 */
IGRstat VDctyGetGadgetText(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			   IGRchar  *formName,
			   IGRint    gadget,
			   IGRint    nth,
			   IGRchar  *txt)
{
  VDASSERT_FN("VDctyGetGadgetText");
  IGRstat retFlag = 1;
  
  // Arg check
  VDASSERTW(txt); *txt = 0;
  VDASSERTW(formName);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getGadgetText);
  
  // Do it
  retFlag = tp->getGadgetText(tp,cp,nodeID,formName,gadget,nth,txt);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDcty
 */
IGRstat VDctyGetNodeNameForModelObject(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				       TGRobj_env    *modelOE,
				       IGRchar       *nodeName)
{
  VDASSERT_FN("VDctyGetNodeNameForModelObject");
  IGRstat retFlag = 1;
  

  // Arg check
  VDASSERTW(nodeName); *nodeName = 0;
  VDASSERTW(modelOE);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getNodeNameForModelObject);
  
  // Do it
  retFlag = tp->getNodeNameForModelObject(tp,cp,nodeID,modelOE,nodeName);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDcty
 */
IGRstat VDctyGetNodeTypeForModelObject(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				       TGRobj_env    *modelOE,
				       IGRchar       *nodeType)
{
  VDASSERT_FN("VDctyGetNodeTypeForModelObject");
  IGRstat retFlag = 1;
  
  // Arg check
  VDASSERTW(nodeType); *nodeType = 0;
  VDASSERTW(modelOE);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getNodeTypeForModelObject);
  
  // Do it
  retFlag = tp->getNodeTypeForModelObject(tp,cp,nodeID,modelOE,nodeType);

 wrapup:
  return retFlag;
}
  
/* -----------------------------------------------
 * VDcty
 */
IGRstat VDctyIsModelObjectValid(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				TGRobj_env *modelOE)

{
  VDASSERT_FN("VDctyIsModelObjectValid");
  IGRstat retFlag = 1;
  
  // Arg check
  VDASSERTW(modelOE);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->isModelObjectValid);
  
  // Do it
  retFlag = tp->isModelObjectValid(tp,cp,nodeID,modelOE);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDcty
 */
IGRstat VDctyIsChildTypeValid(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			      IGRchar  *parentType,
			      IGRchar  *childType)
{
  VDASSERT_FN("VDctyIsChildTypeValid");
  IGRstat retFlag = 1;

  TVDctxBaseInfo baseInfo;
  
  // Arg check
  VDASSERTW( childType && *childType);

  // Get the parent type if necessary
  if ((parentType == NULL) || (*parentType == 0)) {
    VDctxGetBaseInfoCP(cp,nodeID,&baseInfo);
    VDASSERTW(*baseInfo.nodeType);
    parentType = baseInfo.nodeType;
  }
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->isChildTypeValid);
  
  // Do it
  retFlag = tp->isChildTypeValid(tp,cp,nodeID,parentType,childType);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyGetFilter
 */
void VDctyGetFilter(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
		    OM_S_CLASSLIST *classList)
{
  VDASSERT_FN("VDctyGetFilter");
  
  // Arg check
  VDASSERTW(classList);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getFilter);
  
  // Do it
  tp->getFilter(tp,cp,nodeID,classList);

 wrapup:
  return;
}

/* -----------------------------------------------
 * VDctyGetValidCommCode
 */
IGRstat VDctyGetValidCommCode(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			      TVDctxBaseInfo *baseInfo,
			      IGRchar        *commCode)
{
  
  VDASSERT_FN("VDctyGetValidCommCode");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(commCode); *commCode = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getValidCommCode);
  
  // Do it
  retFlag = tp->getValidCommCode(tp,cp,nodeID,baseInfo,commCode);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyIsCommCodeValid
 */
IGRstat VDctyIsCommCodeValid(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
			     IGRchar *commCode)
{
  VDASSERT_FN("VDctyIsCommCodeValid");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(commCode);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->isCommCodeValid);
  
  // Do it
  retFlag = tp->isCommCodeValid(tp,cp,nodeID,commCode);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyGetCommCode
 */
void VDctyGetCommCode(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
		      IGRchar  *commCode)
{
  VDASSERT_FN("VDctyGetCommCode");
  
  // Arg check
  VDASSERTW(commCode); *commCode = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getCommCode);
  
  // Do it
  tp->getCommCode(tp,cp,nodeID,commCode);

 wrapup:
  return;
}

/* -----------------------------------------------
 * VDctyGetCageNum
 */
void VDctyGetCageNum(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
		     IGRchar  *cageNum)
{
  VDASSERT_FN("VDctyGetCageNum");
  
  // Arg check
  VDASSERTW(cageNum); *cageNum;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getCageNum);
  
  // Do it
  tp->getCageNum(tp,cp,nodeID,cageNum);

 wrapup:
  return;
}
/* -----------------------------------------------
 * VDctySetStatus
 */
void VDctySetStatus(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value)
{
  VDASSERT_FN("VDctySetStatus");
  
  // Arg check
  VDASSERTW(value);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->setStatus);
  
  // Do it
  tp->setStatus(tp,cp,nodeID,value);

 wrapup:
  return;
}

/* -----------------------------------------------
 * VDctySetAttrNodeCount
 */
void VDctySetAttrNodeCount(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value)
{
  VDASSERT_FN("VDctySetAttrNodeCount");
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->setAttrNodeCount);
  
  // Do it
  tp->setAttrNodeCount(tp,cp,nodeID,value);

 wrapup:
  return;
}

/* -----------------------------------------------
 * VDctySetAttrRev 
 */
void VDctySetAttrRev(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value)
{
  VDASSERT_FN("VDctySetAttrRev");

  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->setAttrRev);
  
  // Do it
  tp->setAttrRev(tp,cp,nodeID,value);

 wrapup:
  return;
}
/* -----------------------------------------------
 * VDctyGetHighestRev
 */
void VDctyGetHighestRev(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRint *highestRev)
{
  VDASSERT_FN("VDctyGetHighestRev");

  // Arg check
  VDASSERTW(highestRev); *highestRev = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getHighestRev);
  
  // Do it
  tp->getHighestRev(tp,cp,nodeID,highestRev);

 wrapup:
  return;
}

/* -----------------------------------------------
 * VDctyComputeNodeModel
 */
IGRstat VDctyComputeNodeModel(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("VDctyComputeNodeModel");
  IGRstat retFlag = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->computeNodeModel);
  
  // Do it
  retFlag = tp->computeNodeModel(tp,cp,nodeID);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyComputeNode
 */
IGRstat VDctyComputeNode(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("VDctyComputeNode");
  IGRstat retFlag = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->computeNode);
  
  // Do it
  retFlag = tp->computeNode(tp,cp,nodeID);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyIsReviseOK
 */
IGRstat VDctyIsReviseOK(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("VDctyIsReviseOK");
  IGRstat retFlag = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->isReviseOK);
  
  // Do it
  retFlag = tp->isReviseOK(tp,cp,nodeID);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VDctyIsFreezeOK
 */
IGRstat VDctyIsFreezeOK(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("VDctyIsFreezeOK");
  IGRstat retFlag = 0;
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->isFreezeOK);
  
  // Do it
  retFlag = tp->isFreezeOK(tp,cp,nodeID);

 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * VDctyPreExpandContractNode
 */
void VDctyPreExpandContractNode(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *op)
{
  VDASSERT_FN("VDctyPreExpandContractNode");

  // Arg check
  VDASSERTW(op);
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->preExpandContractNode);
  
  // Do it
  tp->preExpandContractNode(tp,cp,nodeID,op);

 wrapup:
  return;
}

/* -----------------------------------------------
 * VDctyGetSetTypeInfo
 */
void VDctyGetSetTypeInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, TVDctySetTypeInfo *info)
{
  VDASSERT_FN("VDctyGetSetTypeInfo");

  // Arg check
  VDASSERTW(info);
  memset(info,0,sizeof(TVDctySetTypeInfo));
  
  // Get tree pointer
  if (tp == NULL) tp = VDctyGetNodeTP(cp,nodeID);
  VDASSERTW(tp && tp->getSetTypeInfo);
  
  // Do it
  tp->getSetTypeInfo(tp,cp,nodeID,info);

 wrapup:
  return;
}
