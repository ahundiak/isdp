/* $Id: VDctyProd.c,v 1.4 2002/02/26 18:19:08 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/base/VDctyProd.c
 *
 * Description: Abstract Prodction Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctyProd.c,v $
 *      Revision 1.4  2002/02/26 18:19:08  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/17 14:24:12  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/11 17:50:07  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/14 16:00:48  art
 *      sp merge
 *
 * Revision 1.10  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * Revision 1.9  2000/09/07  18:02:38  pinnacle
 * js
 *
 * Revision 1.8  2000/08/25  16:58:30  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h" 
#include "VDos.h"
#include "VDobj2.h"
#include "VDrisc.h"
#include "VDassert.h"

#if 0
#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"
#endif

#include "VDctx.h"
#include "VDcty.h"

#include "VDct1Ris.h"
#include "VDct1Attrs.h"

VDASSERT_FFN("vdcty/base/VDctyProd.c");

#define MY_TREE VDCTY_TREE_TYPE_PROD_TREE

#define VDCT1_FEET_PER_METER 3.28084

/* --------------------------------------------------
 * Get highest revision
 * Still in progress
 *
 * ah - This did not make much sense, need to test
 */
static void getHighestRev(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRint *highestRev)
{  
  VDASSERT_FN("prodGetHighestRev");
  IGRstat sts;
  
  IGRint         loopStatus,i,testRevNum,childRevNum;
  IGRchar        buf[128],nType[128],nName[128],nodeType[128],nodeName[128];
  IGRchar        assyRev[128],parRev[128],childRev[128];

  TGRid          parentID,testID,childID;
  TVDctxBaseInfo testBaseInfo,baseInfo;

  // say hi
  if (traceFlag) printf(">>> %s\n",fn);
  
  // start get the assyRev from the part or the assy
  sts = VDctxGetTxtAtr(nodeID,VDCT1_ATTR_ASSY_REV,assyRev);
  if(!(sts & 1)) {
    // it might be a part
    sts = VDctxGetTxtAtr(nodeID,VDCT1_ATTR_PART_REV,assyRev); 
  }
  
  // we don't have either attribute so go home
  if(!(sts & 1)) goto wrapup;
  
  loopStatus = 1;
  testID = *nodeID;
  
  // loop around to get the first parent without the assyRev attribute
  while(loopStatus) {

    loopStatus = 0;

    // get the parentJD
    VDctxGetTreeParentCP(cp,&testID,&parentID);
    if (parentID.objid == NULL_OBJID) goto wrapup;
    
    // get the attribute
    sts = VDctxGetTxtAtr(&parentID,VDCT1_ATTR_ASSY_REV,parRev);

    // we did not hit a node without attribute
    if(sts & 1) {
      loopStatus = 1;
      testID =parentID;
    }
  }

  // get the baseInfo for testJD
  VDctxGetBaseInfoCP(cp,&testID,&testBaseInfo);

  // copy it up
  strcpy(nType,testBaseInfo.nodeType);
  strcpy(nName,testBaseInfo.nodeName);

  // set the testRevNum
  testRevNum  = 0;
  childRevNum = 0;

  // be extra careful
  testRevNum = atoi(assyRev);

  // loop down through the kids of the parentJD 
  for(i = 0; VDctxGetNthTreeChildCP(cp,&parentID,i,&childID); i++) {

    // get the child's baseInfo
    VDctxGetBaseInfoCP(cp,&childID,&baseInfo);

    // wtf
    if((!strcmp(baseInfo.nodeType,nType)) &&
       (!strcmp(baseInfo.nodeName,nName))){

      // the same nodeName and nodeType get its attribute
      VDctxGetTxtAtr(&childID,VDCT1_ATTR_ASSY_REV,childRev); 
      childRevNum = atoi(childRev);
      if(childRevNum > testRevNum) testRevNum = childRevNum;   
    }
  }

  // Done??? what about the results
  *highestRev = testRevNum;
  
wrapup:
  if (traceFlag) printf(">>> %s\n",fn);
  return;
}

/* -----------------------------------------------
 * Specifically for computing nodes with attached model object
 */
static IGRstat computeNodeModel(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("prodComputeNodeModel");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TGRobj_env modelOE;
  TGRobj_env   srfOE;

  IGRdouble  cut_len;
  IGRdouble  area;
  
  IGRchar buf[128];
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Does it have an attached model
  VDctxGetModelObjectCP(cp,nodeID,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // It is a beam
  sts = VDobjIsAncestryValid(&modelOE,NULL,NULL_CLASSID,"VSbeam");
  if (sts & 1) {
    cut_len = 0.0;
    VDobjGetDblAtr(&modelOE,NULL,VDCT1_ISDP_ATTR_CUT_LENGTH,&cut_len);
    cut_len /= 1000.0;
    
    sprintf(buf,"%.3fLM,%.3fLF",cut_len, cut_len * VDCT1_FEET_PER_METER);
    VDctxSetTxtAtr(nodeID,VDCT1_ATTR_ITEM_QTY,buf);
    goto wrapup;
  }

  // It is a plate
  sts = VDobjIsAncestryValid(&modelOE,NULL,NULL_CLASSID,"VSplate");
  if (sts & 1) {

    // Cheat and use low level surface area to avoid
    // The big mass properties delay and processing
    
    // Work from base surface
    //VDobjGetFoot(&modelOE,NULL,"plate:base",&srfOE);
    //VDASSERTW(srfOE.obj_id.objid != NULL_OBJID);
    area = 0.0;

    //VDgeomGetSurfaceAreaProps(&srfOE,&area,NULL,NULL);
    area /= 1000000.0;
    
    sprintf(buf,"%.3fSM,%.3fSF",area,area * VDCT1_FEET_PER_METER * VDCT1_FEET_PER_METER);
    VDctxSetTxtAtr(nodeID,VDCT1_ATTR_ITEM_QTY,buf);
    goto wrapup;
  }

  // Assume it's 1EA
  VDctxSetTxtAtr(nodeID,VDCT1_ATTR_ITEM_QTY,"1EA");
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * Used to compute or update internal attributes
 * Probably needs to be moved to production tree
 */
static IGRstat computeNode(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("prodComputeNode");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Does it have an attached model
  sts = VDctyComputeNodeModel(tp,cp,nodeID);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* --------------------------------------------------
 * check if REVISE is ok
 * probably should be in a higher class implementation!
 * only applies to the first node with the attribute
 * all issues with the kids must be done elsewhere
 */

static IGRstat isReviseOK(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{  
  VDASSERT_FN("prodIsReviseOK");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar buf[128];
  TGRid   parentID;

  // say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // get the attribute
  sts = VDctxGetTxtAtr(nodeID,VDCT1_ATTR_FROZEN,buf);
  if(!(sts & 1)) goto wrapup;

  // it is frozen?
  if(strcmp(buf,VDCT1_DEFAULT_FROZEN_F)) goto wrapup;
  
  // get the parentJD
  VDctxGetTreeParentCP(cp,nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;

  // get the attribute
  sts = VDctxGetTxtAtr(&parentID,VDCT1_ATTR_FROZEN,buf);
  if (sts & 1) goto wrapup;
  
  // if the parent has no attribute it is ok to Revise
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * check if FREEZE is ok
 * probably should be in a higher class implementation!
 * only applies to the first node with the attribute
 * all issues with the kids must be done elsewhere
 */

static IGRstat isFreezeOK(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID)
{  
  VDASSERT_FN("prodIsFreezeOK");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar buf[128];
  TGRid   parentID;

  // say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // get the attribute
  sts = VDctxGetTxtAtr(nodeID,VDCT1_ATTR_FROZEN,buf);  
  if(!(sts & 1)) goto wrapup;

  // if it is active
  if(strcmp(buf,VDCT1_DEFAULT_FROZEN_A)) goto wrapup;
  
  // get the parentJD
  VDctxGetTreeParentCP(cp,nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;

  // get the attribute
  sts = VDctxGetTxtAtr(&parentID,VDCT1_ATTR_FROZEN,buf);
  if (sts & 1) goto wrapup;
  
  // if the parent has no attribute it is ok to freeze
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

/* -------------------------------------------------
 * Set the attribute "FROZEN" to status 
 * sets the remark fields to dates 
 */ 
static void setStatus(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value)
{
  IGRint   sts;
  IGRchar  buf[128];

  VDASSERT_FN("setStatus");
  
   // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s\n",ffn(),fn,value);
  }
  
  // check if the attribute exists
  sts = VDctxGetTxtAtr(nodeID,VDCT1_ATTR_FROZEN,buf);

  // no node attribute go home it does not need to be set
  if (!(sts & 1)) goto wrapup;
  
  // set the attribute to status
  VDctxSetTxtAtr(nodeID,VDCT1_ATTR_FROZEN,value);

  // get the remarks set to the date if other than active
  if (strcmp(value,VDCT1_DEFAULT_FROZEN_A)) {
    
    VDctxComputeDateCP(cp,nodeID,VDCT1_ATTR_PART_REMARKS);
    VDctxComputeDateCP(cp,nodeID,VDCT1_ATTR_ASSY_REMARKS);
  }
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  return;
}

#if 0
/* -----------------------------------------------
 * Override create node here for consistent production tree behaviour
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{
  VDASSERT_FN("createNode");
  IGRstat retFlag = 0;

  TVDct1JD parentClassJD;
  
  // Arg check
  VDASSERTW(parentJD);
  VDASSERTW(nodeType);
  VDASSERTW(nodeName);
  VDASSERTW(nodeJD);
  
  // Init
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;

   // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),fn,_RTCJDBC(parentJD),nodeType,nodeName);
  }

  // Kick off ancestor routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;

  // Set the Rev Attribute

  VDjt1SetAttrRev(nodeJD,NULL);

  // Status
  VDjt1SetStatus(nodeJD,VDCT1_DEFAULT_FROZEN_A);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
#endif

/* --------------------------------------------------
 * set the Count
 */
static void setAttrNodeCount(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value)
{
  VDASSERT_FN("setAttrNodeCount");
  IGRchar  buf[128];

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Adjust value
  if (value && *value) strcpy(buf,value);
  else                 strcpy(buf,"001");
  
  // set the attribute 
  VDctxSetTxtAtr(nodeID,VDCT1_ATTR_COUNT,buf);

wrapup:
  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }
  return;
}

/* --------------------------------------------------
 * set the ASSY_REV 
 * set the PART_REV as well if it is there
 */
static void setAttrRev(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value)
{
  VDASSERT_FN("setAttrRev");
  IGRchar  buf[128];

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Just do it
  if (value && *value) strcpy(buf,value);
  else                 strcpy(buf,"000");
  
  VDctxSetTxtAtr(nodeID,VDCT1_ATTR_ASSY_REV,buf);
  VDctxSetTxtAtr(nodeID,VDCT1_ATTR_PART_REV,buf);

wrapup:
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  return;
}

/* --------------------------------------------------
 * Compute Valid Commodity Code
 */
static IGRstat getValidCommCode(TVDctyTP *tp, TVDctxCP *cp, TGRid *parentID,
				TVDctxBaseInfo *baseInfo,
				IGRchar        *comm_code)
{
  VDASSERT_FN("getValidCommCode");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar comm_codex[128];

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Is baseinfo set to a valid comm code
  if (baseInfo) {    
    sts = VDctyIsCommCodeValid(tp,cp,parentID,baseInfo->nodeName);
    if (sts & 1) {
      strcpy(comm_code,baseInfo->nodeName);
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // get it from the parent's comm_code attribute
  VDctyGetCommCode(tp,cp,parentID,comm_codex);  
  if (*comm_codex) {
    sts = VDctyIsCommCodeValid(tp,cp,parentID,comm_codex);
    if (sts & 1) {
      strcpy(comm_code,comm_codex);
      retFlag = 1;
      goto wrapup;
    }
  }

  // Done
  retFlag = 0;

wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * check Valid Commodity Code
 */
static IGRstat isCommCodeValid(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
			       IGRchar *comm_code)
{
  VDASSERT_FN("isCommCodeValid");

  IGRstat    retFlag = 0;
  TVDrisInfo ris;

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }

  // Init
  VDrisInitInfo(&ris);
  
  // Look it up
  VDct1QryCodesForCommCode(&ris,comm_code);
  if (ris.rows < 1) goto wrapup;

  // Done
  retFlag = 1;

wrapup:
  VDrisFreeInfo(&ris);
  
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * Returns the items cage_num for the node
 */
static void getCommCode(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
		       IGRchar  *cage_num)
{
  VDctxGetTxtAtr(nodeID,VDCT1_ATTR_COMM_CODE,cage_num);

 wrapup:
  return;
}
/* --------------------------------------------------
 * Returns the items cage_num for the node
 */
static void getCageNum(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
		       IGRchar  *cage_num)
{
  VDctxGetTxtAtr(nodeID,VDCT1_ATTR_ITEM_CAGE_NUM,cage_num);

 wrapup:
  return;
}

/* --------------------------------------------------
 * For a given set wide attribute name, fill in the info
 */
static void getNodeAttrInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			    IGRchar        *name, 
			    TVDctyAttrInfo *info)
{ 
  // Have one standlone routine for the engineering stuff
  VDctyEngTreeGetAttrInfo(name,info);
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Set type information
 */
static void getSetTypeInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			    TVDctySetTypeInfo *info)
{
  VDASSERT_FN("getSetTypeInfo");

  info->flag = 0;
  info->nth  = VDCTY_CLASSI_PROD_TREE;
  strcpy(info->type,VDCTY_CLASSN_PROD_TREE);
  strcpy(info->rev, "000");
  strcpy(info->desc,"Abstract Production Tree");
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Link the base methods
 */
IGRstat VDctyInitProdTP(TVDctyTP *tpb, TVDctyTP *tp)
{
  VDASSERT_FN("VDctyInitProdTP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(tp);

  // Copy Base
  memcpy(tp,tpb,sizeof(TVDctyTP));
  tp->parentTP = tpb;

  tp->getSetTypeInfo   = getSetTypeInfo;
  tp->getNodeAttrInfo  = getNodeAttrInfo;

  tp->getValidCommCode = getValidCommCode;
  tp->isCommCodeValid  = isCommCodeValid;

  tp->getCommCode = getCommCode;
  tp->getCageNum  = getCageNum;

  tp->setStatus        = setStatus;
  tp->setAttrRev       = setAttrRev;
  tp->setAttrNodeCount = setAttrNodeCount;

  tp->getHighestRev    = getHighestRev;
  tp->computeNodeModel = computeNodeModel;
  tp->computeNode = computeNode;
  tp->isReviseOK  = isReviseOK;
  tp->isFreezeOK  = isFreezeOK;
  
 #if 0  
  // Xfer functions
  tp-> = ;
  
  tp->getNodeTypeInfo   = getNodeTypeInfo;
  tp->getNodeAttrInfo   = getNodeAttrInfo;
  tp->getNodeAttrName   = getNodeAttrName;
  tp->validateAttrValue = validateAttrValue;
  tp->setNodeUserInfo   = setNodeUserInfo;
  tp->getGadgetText     = getGadgetText;
  tp->isChildTypeValid  = isChildTypeValid;
  tp->getFilter         = getFilter;

  tp->getNodeNameForModelObject = getNodeNameForModelObject;
  tp->getNodeTypeForModelObject = getNodeTypeForModelObject;
  tp->isModelObjectValid        = isModelObjectValid;
#endif    
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
