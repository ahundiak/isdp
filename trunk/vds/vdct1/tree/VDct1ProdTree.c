/* $Id: VDct1ProdTree.c,v 1.3 2001/05/14 20:49:40 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1ProdTree.I
 *
 * Description: Abstract Prodction Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1ProdTree.c,v $
 *      Revision 1.3  2001/05/14 20:49:40  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.2  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
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
#include "VDobj2.h"
#include "VDrisc.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Ris.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Attrs.h"
#include "VDct1Trace.h"


VDASSERT_FFN("vdct1/tree/VDct1ProdTree.C");

#define MY_TREE VDCT1_TREE_TYPE_PROD_TREE

#define VDCT1_FEET_PER_METER 3.28084


/* --------------------------------------------------
 * Get highest revision
 * Still in progress
 */
static IGRstat getHighestRev(TVDct1JD *nodeJD,IGRint *highestRev)
{  
  VDASSERT_FN("getHighestRev");
  IGRstat        retFlag = 0;
  IGRint         sts,loopStatus,i,testRevNum,childRevNum;
  IGRchar        buf[128],nType[128],nName[128],nodeType[128],nodeName[128];
  IGRchar        assyRev[128],parRev[128],childRev[128];
  TVDct1JD       parentJD,testJD,childJD;
  TVDctBaseInfo  testBaseInfo,baseInfo;

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  //args check
  VDASSERTW(nodeJD); 
  VDASSERTW(highestRev); 

  // inits
  testJD.cl = nodeJD->cl;
  testJD.id = nodeJD->id;
  *highestRev = 0;

  // start get the assyRev from the part or the assy
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_ASSY_REV,assyRev);
  if(!(sts & 1)) {
    // it might be a part
    sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_PART_REV,assyRev); 
  }
  
  // we don't have either attribute so go home
  if(!(sts & 1)) {
    *highestRev = 0;
    goto wrapup;
  }
  loopStatus = 1;
  // loop around to get the first parent without the assyRev attribute
  while(loopStatus) {
    loopStatus = 0;
    // get the parentJD
    sts = VDjt1GetTreeParent(&testJD,&parentJD);
    if(!(sts & 1)) {
      goto wrapup;
    }
    // get the attribute
    sts = VDjt1GetAttr(&parentJD,VDCT1_ATTR_ASSY_REV,parRev);
    // we did not hit a node without attribute
    if(sts & 1) loopStatus = 1;
  }
  // get the baseInfo for testJD
  sts = VDjt1GetBaseInfo(&testJD,&testBaseInfo); 
  // copy it up
  strcpy(nType,testBaseInfo.nodeType);
  strcpy(nName,testBaseInfo.nodeName);
  // set the testRevNum
  testRevNum = 0;
  childRevNum = 0;
  // be extra careful
  if(sts & 1) {
    testRevNum = atoi(assyRev);
  }
  // loop down through the kids of the parentJD 
  for(i = 0; VDjt1GetTreeChild(&parentJD,i,&childJD);i++) {
    // get the child's baseInfo
    sts = VDjt1GetBaseInfo(&childJD,&baseInfo); 
    if((!strcmp(baseInfo.nodeType,nType)) &&
       (!strcmp(baseInfo.nodeName,nName))){
      // the same nodeName and nodeType get its attribute
      sts = VDjt1GetAttr(&childJD,VDCT1_ATTR_ASSY_REV,childRev); 
      if(sts & 1) {
	childRevNum = atoi(childRev);
	if(childRevNum > testRevNum) testRevNum = childRevNum;
      }     
    }
  }
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Specifically for computing nodes with attached model object
 */
static IGRstat computeNodeModel(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNodeModel");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env modelOE;
  TGRobj_env   srfOE;

  IGRdouble  cut_len;
  IGRdouble  area;
  
  IGRchar buf[128];
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  retFlag = 1;
  
  // Does it have an attached model
  VDjt1GetModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // It is a beam
  sts = VDobjIsAncestryValid(&modelOE,NULL,NULL_CLASSID,"VSbeam");
  if (sts & 1) {
    cut_len = 0.0;
    VDobjGetDblAtr(&modelOE,NULL,VDCT1_ISDP_ATTR_CUT_LENGTH,&cut_len);
    cut_len /= 1000.0;
    
    sprintf(buf,"%.3fLM,%.3fLF",cut_len, cut_len * VDCT1_FEET_PER_METER);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_ITEM_QTY,buf);
    goto wrapup;
  }

  // It is a plate
  sts = VDobjIsAncestryValid(&modelOE,NULL,NULL_CLASSID,"VSplate");
  if (sts & 1) {

    // Cheat and use low level surface area to avoid
    // The big mass properties delay and processing
    
    // Work from base surface
    VDobjGetFoot(&modelOE,NULL,"plate:base",&srfOE);
    VDASSERTW(srfOE.obj_id.objid != NULL_OBJID);
    area = 0.0;

    VDgeomGetSurfaceAreaProps(&srfOE,&area,NULL,NULL);
    area /= 1000000.0;
    
    sprintf(buf,"%.3fSM,%.3fSF",area,area * VDCT1_FEET_PER_METER * VDCT1_FEET_PER_METER);
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_ITEM_QTY,buf);
    goto wrapup;
  }

  // Assume it's 1EA
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_ITEM_QTY,"1EA");
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Used to compute or update internal attributes
 * Probably needs to be moved to production tree
 */
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNode");
  IGRstat retFlag = 0;

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);

  // Does it have an attached model
  computeNodeModel(nodeJD);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * check if REVISE is ok
 * probably should be in a higher class implementation!
 * only applies to the first node with the attribute
 * all issues with the kids must be done elsewhere
 */

static IGRstat isReviseOK(TVDct1JD *nodeJD)
{  
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        nodeAttrTxt[256],buf[128],parAttrTxt[128];
  TVDct1JD       parentJD;

  VDASSERT_FN("isReviseOK");

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  //args check
  VDASSERTW(nodeJD); 

  // get the attribute
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,nodeAttrTxt);
  if(!(sts & 1))                                                     goto wrapup;
  // it is frozen?
  if(!strcmp(nodeAttrTxt,VDCT1_DEFAULT_FROZEN_F)) {
      // get the parentJD
    sts = VDjt1GetTreeParent(nodeJD,&parentJD); 
    if(!(sts & 1))                                                   goto wrapup;
    // get the attribute
    sts = VDjt1GetAttr(&parentJD,VDCT1_ATTR_FROZEN,parAttrTxt);
    // if the parent has no attribute it is ok to Revise
    if(!(sts & 1)) {
      retFlag = 1;
                                                                     goto wrapup;
    }
  }
  

wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * check if FREEZE is ok
 * probably should be in a higher class implementation!
 * only applies to the first node with the attribute
 * all issues with the kids must be done elsewhere
 */

static IGRstat isFreezeOK(TVDct1JD *nodeJD)
{  
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRchar        nodeAttrTxt[256],buf[128],parAttrTxt[128];
  TVDct1JD       parentJD;

  VDASSERT_FN("isFreezeOK");

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  //args check
  VDASSERTW(nodeJD); 

  // get the attribute
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,nodeAttrTxt);
  
  if(!(sts & 1)) goto wrapup;
  // if it is active
  if(!strcmp(nodeAttrTxt,VDCT1_DEFAULT_FROZEN_A)) {
    // get the parentJD
    sts = VDjt1GetTreeParent(nodeJD,&parentJD);  
    if(!(sts & 1)) goto wrapup;
    // get the attribute
    sts = VDjt1GetAttr(&parentJD,VDCT1_ATTR_FROZEN,parAttrTxt);
    if(!(sts & 1)) {
      // if the parent has no attribute it is ok to freeze
      retFlag = 1;
      goto wrapup;
    }
  }
  
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -------------------------------------------------
 * Set the attribute "FROZEN" to status 
 * sets the remark fields to dates 
 */ 
static IGRstat setStatus(TVDct1JD *nodeJD, IGRchar *value)
{
  IGRstat          retFlag = 0;
  IGRint           sts;
  IGRchar          attrTxt[128];

  VDASSERT_FN("setStatus");

  //args check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(value);
  retFlag = 1;
  
   // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s\n",ffn(),fn,value);
  }
  
  // check if the attribute exists
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,attrTxt);

  // no node attribute go home it does not need to be set
  if (!(sts & 1)) goto wrapup;
  
  // set the attribute to status
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_FROZEN,value);

  // get the remarks set to the date if other than active
  if (strcmp(value,VDCT1_DEFAULT_FROZEN_A)) {
    
    VDjt1ComputeDate(nodeJD,VDCT1_ATTR_PART_REMARKS);
    VDjt1ComputeDate(nodeJD,VDCT1_ATTR_ASSY_REMARKS);
  }
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

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

/* --------------------------------------------------
 * set the Count
 */
static IGRstat setAttrNodeCount(TVDct1JD *nodeJD, IGRchar *value)
{
  VDASSERT_FN("setAttrNodeCount");
  IGRstat  retFlag = 0;
  IGRint   sts;

  IGRchar  buf[128];

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  
  // if no node go home
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_COUNT,buf);
  if(!(sts & 1)) {
    retFlag = 1;
    goto wrapup;
  }

  // Adjust value
  if (value) strcpy(buf,value);
  else       strcpy(buf,"001");
  
  // set the attribute 
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_COUNT,buf);
  
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * set the ASSY_REV 
 * set the PART_REV as well if it is there
 */
static IGRstat setAttrRev(TVDct1JD *nodeJD, IGRchar *value)
{
  VDASSERT_FN("setAttrRev");
  IGRstat  retFlag = 0;
  IGRint   sts;
  IGRchar  buf[128];

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  //args check
  VDASSERTW(nodeJD && nodeJD->cl);
  
  // if no node go home
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_ASSY_REV,buf);
  if (sts & 1) {
    if (value) strcpy(buf,value);
    if (*buf == 0) strcpy(buf,"000");
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_ASSY_REV,buf);
  }
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_PART_REV,buf);
  if (sts & 1) {    
    if (value) strcpy(buf,value);
    if (*buf == 0) strcpy(buf,"000");
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_PART_REV,buf);
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * Compute Valid Commodity Code
 */
static IGRstat getValidCommCode(TVDct1JD      *parentJD,
				TVDctBaseInfo *baseInfo,
				IGRchar       *comm_code)
{
  VDASSERT_FN("getValidCommCode");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar comm_codex[128];

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Args check
  VDASSERTW(comm_code);
  *comm_code = 0;
  VDASSERTW(parentJD && parentJD->cl);

  // Is baseinfo set to a valid comm code
  if (baseInfo) {    
    sts = VDjt1IsCommCodeValid(parentJD,baseInfo->nodeName);
    if (sts & 1) {
      strcpy(comm_code,baseInfo->nodeName);
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // get it from the parent's comm_code attribute
  VDjt1GetAttr(parentJD,VDCT1_ATTR_COMM_CODE,comm_codex);
  if (*comm_codex) {
    sts = VDjt1IsCommCodeValid(parentJD,comm_codex);
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
static IGRstat isCommCodeValid(TVDct1JD *nodeJD, IGRchar *comm_code)
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
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(comm_code);  

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
static IGRstat getCageNum(TVDct1JD *nodeJD,
			  IGRchar  *cage_num)
{
  IGRstat retFlag = 0;
  TGRid  *nodeID = &nodeJD->id;
  TVDfld  fld;
  
  // Arg check
  if (cage_num == NULL) goto wrapup;
  *cage_num = 0;
  
  // Ask it
  VDctxGetAttr(nodeID,VDCT1_ATTR_ITEM_CAGE_NUM,&fld);
  if (*fld.name) {
    strcpy(cage_num,fld.val.txt);
    retFlag = 1;
    goto wrapup;
  }
  
  // Another tre

 wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * For a given set wide attribute name, fill in the info
 */
static IGRstat getNodeAttrInfo(TVDct1JD *nodeJD,
			       IGRchar  *name, 
			       TVDctAttrInfo *info)
{ 
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg check
  if (info == NULL) goto wrapup;
  if (name == NULL) goto wrapup;

  // Have one standlone routine for the engineering stuff
  sts = VDct1EngTreeGetAttrInfo(name,info);
  if (sts & 1) retFlag = 1;
  
wrapup:
  if (retFlag == 0) {  
    if (info) memset(info,0,sizeof(TVDctAttrInfo));
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Hello routine for testing
 */
static IGRstat hello(TVDct1JD *nodeJD)
{ 
  printf("@@@ Hello from %s\n",
	 _RTCJDB(nodeJD)->info.type);
  return 1;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitProdTreeClass(TVDct1RootTreeClass *rootCL, 
			       TVDct1ProdTreeClass *cl)
{
  VDASSERT_FN("VDct1InitProdTreeClass");

  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_PROD);
  
  // Transfer
  VDct1CopyRootImps(rootCL,cl);
  
  // Data
  strcpy(cl->base.info.type,"ProdTree");
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Production Tree");
  
  // Fill up pointers
  cl->base.hello             = hello;
  cl->base.getNodeAttrInfo   = getNodeAttrInfo;
  cl->base.createNode        = createNode;
  cl->base.computeNode       = computeNode;

  // Production methods
  cl->prod.getCageNum       = getCageNum;
  cl->prod.isCommCodeValid  = isCommCodeValid;
  cl->prod.getValidCommCode = getValidCommCode;
  cl->prod.setAttrRev       = setAttrRev;
  cl->prod.setAttrNodeCount = setAttrNodeCount;
  cl->prod.setStatus        = setStatus;
  cl->prod.isFreezeOK       = isFreezeOK;
  cl->prod.isReviseOK       = isReviseOK;

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}

