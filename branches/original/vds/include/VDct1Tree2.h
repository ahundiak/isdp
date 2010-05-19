/* ---------------------------------------------------VDCT_FORM_FREE_G_REV_ACTIVE-
 * Macros to make calling tree functions a bit easier
 */

// Base interface 
#define VDjt1GetNodeAttrName(nodeJD,nodeType,nth,attrName) \
  _RTCJDB((nodeJD))->getNodeAttrName((nodeJD),(nodeType),(nth),(attrName))

#define VDjt1GetNodeAttrInfo(nodeJD,attrName,attrInfo) \
  _RTCJDB((nodeJD))->getNodeAttrInfo((nodeJD),(attrName),(attrInfo))

#define VDjt1GetNodeTypeInfo(nodeJD,nth,cnt,typeInfo) \
  _RTCJDB((nodeJD))->getNodeTypeInfo((nodeJD),(nth),(cnt),(typeInfo))

#define VDjt1GetBaseInfo(nodeJD,baseInfo) \
  _RTCJDB((nodeJD))->getBaseInfo((nodeJD),(baseInfo))

#define VDjt1SetBaseInfo(nodeJD,baseInfo) \
  _RTCJDB((nodeJD))->setBaseInfo((nodeJD),(baseInfo))

#define VDjt1GetTreeParent(childJD,parentJD) \
  _RTCJDB((childJD))->getTreeParent((childJD),(parentJD))

#define VDjt1GetTreeChild(parentJD,nth,childJD) \
  _RTCJDB((parentJD))->getTreeChild((parentJD),(nth),(childJD))

#define VDjt1GetRootForNode(nodeJD,rootJD) \
  _RTCJDB((nodeJD))->getRootForNode((nodeJD),(rootJD))

#define VDjt1GetFilter(nodeJD,classList) \
  _RTCJDB((nodeJD))->getFilter((nodeJD),(classList))

#define VDjt1GetAttr(nodeJD,name,value) \
  _RTCJDB((nodeJD))->getAttr((nodeJD),(name),(value))

#define VDjt1SetAttr(nodeJD,name,value) \
  _RTCJDB((nodeJD))->setAttr((nodeJD),(name),(value))

#define VDjt1GetPrivateAttr(nodeJD,name,value) \
  _RTCJDB((nodeJD))->getPrivateAttr((nodeJD),(name),(value))

#define VDjt1SetPrivateAttr(nodeJD,name,value) \
  _RTCJDB((nodeJD))->setPrivateAttr((nodeJD),(name),(value))

#define VDjt1CreateAttr(nodeJD,name,type,value) \
  _RTCJDB((nodeJD))->createAttr((nodeJD),(name),(type),(value))

#define VDjt1PullDownAttr(nodeJD,name) \
  _RTCJDB((nodeJD))->pullDownAttr((nodeJD),(name))

#define VDjt1ComputeDate(nodeJD,name) \
  _RTCJDB((nodeJD))->computeDate((nodeJD),(name))

#define VDjt1FindTreeByTypeName(nodeJD,isCaseSen,opt,setType,setName,foundJD) \
  _RTCJDB((nodeJD))->findTreeByTypeName((nodeJD),(isCaseSen),(opt),(setType),(setName),(foundJD))

#define VDjt1SetAttrTreeNum(nodeJD) \
  _RTCJDB((nodeJD))->setAttrTreeNum((nodeJD))

#define VDjt1SetAttrNodeNum(nodeJD) \
  _RTCJDB((nodeJD))->setAttrNodeNum((nodeJD))

#define VDjt1CreateNode(parentJD,nodeType,nodeName,nodeJD) \
  _RTCJDB((parentJD))->createNode((parentJD),(nodeType),(nodeName),(nodeJD))

#define VDjt1CreateBaseObject(baseJD,baseType) \
  _RTCJDB((baseJD))->createBaseObject((baseJD),(baseType))

/* -----------------------------------------------
 * Posting
 */
#define VDjt1PostNode(nodeJD,file) \
  _RTCJDB((nodeJD))->postNode((nodeJD),(file))

#define VDjt1PostTree(treeJD,file) \
  _RTCJDB((treeJD))->postTree((treeJD),(file))

#define VDjt1PostTreeBeg(treeJD,file) \
  _RTCJDB((treeJD))->postTreeBeg((treeJD),(file))

#define VDjt1PostTreeEnd(treeJD,file) \
  _RTCJDB((treeJD))->postTreeEnd((treeJD),(file))

#define VDjt1PostTreeNode(nodeJD,file) \
  _RTCJDB((nodeJD))->postTreeNode((nodeJD),(file))

#define VDjt1IsTreePostable(treeJD) \
  _RTCJDB((treeJD))->isTreePostable((treeJD))

#define VDjt1GetTreePostTable(treeJD,tableName) \
  _RTCJDB((treeJD))->getTreePostTable((treeJD),(tableName))

/* -----------------------------------------------
 * Model Stuff
 */
#define VDjt1GetModelObject(nodeJD,modelOE) \
  _RTCJDB((nodeJD))->getModelObject((nodeJD),(modelOE))

#define VDjt1IsModelObjectValid(nodeJD,modelOE) \
  _RTCJDB((nodeJD))->isModelObjectValid((nodeJD),(modelOE))

#define VDjt1ComputeNode(nodeJD) \
 _RTCJDB((nodeJD))->computeNode((nodeJD))

#define VDjt1CopyAttributeFromModelToNode(nodeJD,nodeAttrName,modelOE,modelAttrName) \
  _RTCJDB((nodeJD))->copyAttributeFromModelToNode((nodeJD),(nodeAttrName),(modelOE),(modelAttrName))

#define VDjt1CleanName(nodeJD,nodeName) \
  _RTCJDB((nodeJD))->cleanName((nodeJD),(nodeName))

#define VDjt1GetModelPartData(nodeJD,mp) \
  _RTCJDB((nodeJD))->getModelPartData((nodeJD),(mp))

#define VDjt1ConnectMgrChild(parentJD,childJD) \
  _RTCJDB((parentJD))->connectMgrChild((parentJD),(childJD))

#define VDjt1ConnectTreeChild(parentJD,childJD) \
  _RTCJDB((parentJD))->connectTreeChild((parentJD),(childJD))

// ------------------------------------------------------------------------
// Command Interface
#define VDjt1GetGadgetText(nodeJD,formName,gadget,i,buf) \
  _RTCJDC((nodeJD))->getGadgetText((nodeJD),(formName),(gadget),(i),(buf))

#define VDjt1MakeNodeName(parentJD,baseInfo) \
  _RTCJDC((parentJD))->makeNodeName((parentJD),(baseInfo))

// -------------------------------------------------------------------------
// Production Interface
#define VDjt1IsCommCodeValid(nodeJD,commCode) \
  _PTCJDP((nodeJD))->isCommCodeValid((nodeJD),(commCode))

#define VDjt1GetValidCommCode(parentJD,baseInfo,commCode) \
  _PTCJDP((parentJD))->getValidCommCode((parentJD),(baseInfo),(commCode))

#define VDjt1SetAttrRev(nodeJD,value) \
  _PTCJDP((nodeJD))->setAttrRev((nodeJD),(value))

#define VDjt1SetAttrNodeCount(nodeJD,value) \
  _PTCJDP((nodeJD))->setAttrNodeCount((nodeJD),(value))

#define VDjt1SetStatus(nodeJD,status) \
  _PTCJDP((nodeJD))->setStatus((nodeJD),(status))

#define VDjt1IsFreezeOK(nodeJD) \
  _PTCJDP((nodeJD))->isFreezeOK((nodeJD))

#define VDjt1IsReviseOK(nodeJD) \
  _PTCJDP((nodeJD))->isReviseOK((nodeJD))

#define VDjt1GetHighestRev(nodeJD,highestRev) \
  _PTCJDP((nodeJD))->getHighestRev((nodeJD),(highestRev))

// -------------------------------------------------------------------------
// Engineering Interface

#define VDjt1ComputeEngAssy2Name(parentJD,baseInfo) \
  _ETCJDE((parentJD))->computeEngAssy2Name((parentJD),(baseInfo))

#define VDjt1ComputeEngAssy6Name(parentJD,baseInfo) \
  _ETCJDE((parentJD))->computeEngAssy6Name((parentJD),(baseInfo))

#define VDjt1IsMarkDeletedOK(nodeJD) \
  _RTCJDC((nodeJD))->isMarkDeletedOK((nodeJD))

#define VDjt1IsUnmarkDeletedValid(nodeJD) \
  _RTCJDC((nodeJD))->isUnmarkDeletedValid((nodeJD))

#define VDjt1DeleteAllChildNodes(activeNodeJD) \
  _ETCJDE((activeNodeJD))->deleteAllChildNodes((activeNodeJD))


