/* $Id: VDct1RootTreeC.c,v 1.4.2.1 2003/06/06 20:58:15 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1RootTreeC.I
 *
 * Description: Command level implementations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1RootTreeC.c,v $
 *      Revision 1.4.2.1  2003/06/06 20:58:15  ahundiak
 *      ah
 *
 *      Revision 1.4  2002/05/16 21:22:29  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.3  2002/01/07 18:53:40  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.2  2001/11/05 16:12:58  jdsauby
 *      JTS CR MP 5646 -jds
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.18  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * Revision 1.17  2000/10/24  14:04:42  pinnacle
 * js
 *
 * Revision 1.16  2000/10/11  20:29:26  pinnacle
 * js
 *
 * Revision 1.15  2000/09/25  20:43:02  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/19/00  js      Creation
 ***************************************************************************/

#include "VDtypedefc.h" 
#include "VDobj2.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Forms.h"
#include "VDct1Attrs.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/tree/VDct1RootTreeC.C");

#define MY_TREE VDCT1_TREE_TYPE_ROOT_TREE
/* --------------------------------------------------
 * check if Deleted mark is ok
 * should this be split classes?
 */

static IGRstat isMarkDeletedOK(TVDct1JD *nodeJD)
{
  return 0;
}

/* --------------------------------------------------
 * check if unMarkDeleted is ok
 * should this be split classes?
 */
static IGRstat isUnmarkDeletedValid(TVDct1JD *nodeJD)
{
  return 0;
}
 

/* ------------------------------------------------
 * For auto paste and create node, this is a filter for
 * weeding out any type of node in nodeInfo
 */
static IGRstat isNodeInfoForPasteValid(TVDct1JD       *parentJD,
				       TVDct1NodeInfo *nodeInfo)
{
  VDASSERT_FN("isNodeInfoForPasteValid");
  
  // want this to be specific, by default, the entire list is invalid
  return 0;
}

/* -------------------------------------------------------
 * Find / Create a parent depending on information on
 * the pasted node
 */
static IGRstat getNewParentForPastedNode(TVDct1JD *parentJD,    // I - needed for class
					 TVDct1JD *copiedJD,    // I - the node beind pasted
					 TVDct1JD *newParentJD) // 0 - the new Parent
{
  VDASSERT_FN("getNewParentForPastedNode");
  
  // by default, make newParent = parent
  newParentJD = parentJD;
  
  // done
  return 1;
}

  
/* --------------------------------------------------------
 * Set user information at creation of node
 */
static IGRstat setNodeUserInfo(TVDct1JD       *nodeJD,
			       TVDct1UserInfo *info)
{
  return 1;
}

/* ---------------------------------------------------------
 * Check to see if attribute can be updated
 */
static IGRstat isAttrUpdateValid(TVDct1JD  *nodeJD,
				 IGRchar   *attrName)
{
  VDASSERT_FN("isAttrUpdateValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD  parentJD;

  IGRchar   attrValue[240];
  
  
  VDASSERTW(attrName != NULL);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->cl != NULL);
  
  // say hi
  if (traceFlag) printf (">>> %s %s %s\n",ffn(),fn,attrName);
  
  // attributes that just can't be updated
  if (!strcmp(attrName,VDCT1_ATTR_ASSY_REV))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_ASSY_DATE))   goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_FROZEN))      goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_TREE_NUM))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_NODE_NUM))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_NUM_NEXT))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_MODEL_ID))    goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_LOC_X))       goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_LOC_Y))       goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_LOC_Z))       goto wrapup;
     
  // if attribute is propagatable, and parent has a value, then
  // the attribute cannot be updated.
  if ( _RTCJDC(nodeJD)->isAttrPropagateValid(nodeJD,attrName) ) {
    
    // Get the attrValue of the parent
    *attrValue = NULL;
    _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
    
    _RTCJDB(&parentJD)->getAttr(&parentJD,attrName,attrValue);
    if (*attrValue != NULL) goto wrapup;
  }
  
  // some computed attributes cannot be updated
  if (!strcmp(attrName,VDCT1_ATTR_CAGE))       goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_MINO))       goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_PCT_MINO))   goto wrapup;
  if (!strcmp(attrName,VDCT1_ATTR_COPICS_NUM)) goto wrapup;
  
  // done, all other attributes can be updated
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ----------------------------------------------------
 * Updates attribute value for children
 */
static IGRstat updateChildAttrValue(TVDct1JD *nodeJD,
				    IGRchar  *attrName,
				    IGRchar  *attrValue)
{
  VDASSERT_FN("updateChildAttrValue");
  
  IGRstat retFlag = 0;
  
  IGRint i;
  
  TVDct1JD  childJD;
  
  VDASSERTW(nodeJD);
  VDASSERTW(attrName);
  VDASSERTW(attrValue);
  
  // say hi
  if (traceFlag) printf(">>> %s %s %s %s\n",ffn(),fn,attrName,attrValue);
  
  // do it
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
    
    if (childJD.id.objid != NULL_OBJID) 
      _RTCJDB(&childJD)->setAttr(&childJD,attrName,attrValue);
  }

  // recurse through to get all the children
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
    
    if (childJD.id.objid != NULL_OBJID) 
      _RTCJDC(&childJD)->updateChildAttrValue(&childJD,attrName,attrValue);
  }
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}
    
/* -----------------------------------------------------
 * Determines which attributes will be propagated down
 * when they are updated
 */
static IGRstat isAttrPropagateValid(TVDct1JD *nodeJD,
				    IGRchar  *attrName)
{
  // none will propagate by default
  return 0;
}

/* ------------------------------------------------------
 * Validates, and cleans attribute values
 */
static IGRstat validateAttrValue(TVDct1JD *nodeJD,
				 IGRchar  *attrName,
				 IGRchar  *attrValue,
				 IGRchar  *attrValuex,
				 IGRchar  *msg)
{
  VDASSERT_FN("validateAttrValue");
  
  strcpy(attrValuex,attrValue);
  VDstrupr(attrValuex);
  
  return 1;
}

  
/* -------------------------------------------------------
 * chance to recompute anything when a node is updated
 */
static IGRstat updateNodeAttributes(TVDct1JD *nodeJD)
{
  VDASSERT_FN("updateNodeAttributes");
  
  return 1;
}

/* ----------------------------------------------------------------------
 * Transfer same name name attributes
 */ 
static IGRstat copyNodeAttributes(TVDct1JD *desJD, TVDct1JD *srcJD)
{
  VDASSERT_FN("copyNodeAttributes");
  
  IGRstat retFlag = 0;
  
  IGRint  desI,srcI;
  TVDfldS  desFlds,srcFlds;
  TVDfld  *desFld,*srcFld;
  
  TGRid  desID;
  TGRid  srcID;
  
  // Arg check
  VDASSERTW(desJD->id.objid != NULL_OBJID);
  desID = desJD->id;
  
  VDASSERTW(srcJD->id.objid != NULL_OBJID);
  srcID = srcJD->id;
  
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    VDobjPrint2(NULL,&desID);
    VDobjPrint2(NULL,&srcID);
  }
  
  // Get the attributes
  VDctxGetAttrs(&desID,&desFlds.cnt,desFlds.fld);
  VDctxGetAttrs(&srcID,&srcFlds.cnt,srcFlds.fld);

  // Cycle through destination
  for(desI = 0; desI < desFlds.cnt; desI++) {
    
    desFld = &desFlds.fld[desI];
    
    // Find source
    for(srcI = 0; srcI < srcFlds.cnt; srcI++) {

      srcFld = &srcFlds.fld[srcI];
      
      if (!strcmp(desFld->name,srcFld->name)) {
        strcpy(desFld->val.txt,srcFld->val.txt);
	srcI = srcFlds.cnt;
      }
    }
  }

  // Update the destination
  VDctxUpdAttrs(&desID,desFlds.cnt,desFlds.fld);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* ------------------------------------------
 * recomputer for moving or copying(pasting) 
 * nodes.  Option to pull down attributes
 * of new parent
 */
static IGRstat computeMoveCopyNode(TVDct1JD  *parentJD,
				   TVDct1JD  *nodeJD)
{
  return 1;
}

static IGRstat isDeleteNodeValid(TVDct1JD *activeJD,
				 TVDct1JD *parentJD)
{
  return 1;
}
#if 0
/*
 * Check if the node attribute is marked "deleted"
 */
static IGRstat isActivateNodeValid(TVDct1JD *activeJD,
                                   TVDct1JD *parentJD)
{
  VDASSERT_FN("isActivateNodeValid");
  TVDctBaseInfo  baseInfo;
  IGRstat        retFlag = 0;
  IGRstat        sts;
  IGRchar        attrFrozen[128];

  VDASSERTW(activeJD->id.objid != NULL_OBJID);
  VDASSERTW(parentJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Need to be in the same set
  VDjt1GetBaseInfo(activeJD,&baseInfo);
  if (baseInfo.setType == NULL) goto wrapup;

  // get the node attribute
  sts = VDjt1GetAttr(activeJD,VDCT1_ATTR_FROZEN,attrFrozen);
 
  strupr(attrFrozen);
  
  // if first letter is "D" then we are ok
  if(*attrFrozen == 'D') retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}
#endif

static IGRstat isCreateTreeValid(TVDct1JD *setJD,
				 IGRchar  *setType)
{
  return 1;
}

static IGRstat isDeleteTreeValid(TVDct1JD *treeJD)
{
  return 1;
}

static IGRstat isRenameTreeValid(TVDct1JD *treeJD)
{
  return 1;
}

    
/* ------------------------------------------
 * check to see if move node is OK
 * OK if it passes through
 */
static IGRstat isMoveNodeValid(TVDct1JD  *parentJD,
			       TVDct1JD  *movedJD)
{
  VDASSERT_FN("isMoveNodeValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo  parentBaseInfo;
  TVDctBaseInfo  movedBaseInfo;
  

  VDASSERTW(parentJD->id.objid != NULL_OBJID);
  VDASSERTW( movedJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Need to be in the same set
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (parentBaseInfo.setType == NULL) goto wrapup;
  
  _RTCJDB(movedJD)->getBaseInfo(movedJD,&movedBaseInfo);
  if (movedBaseInfo.setType  == NULL) goto wrapup;
  if (movedBaseInfo.nodeType == NULL) goto wrapup;
  
  if ( strcmp(movedBaseInfo.setType,VDCT1_TREE_TYPE_DELTA_TREE))
  if ( strcmp(parentBaseInfo.setType,movedBaseInfo.setType) ||
       strcmp(parentBaseInfo.setName,movedBaseInfo.setName) ) {
    goto wrapup;
  }
  
  // Validate child type
  sts = _RTCJDB(parentJD)->
    isChildTypeValid(parentJD,movedBaseInfo.nodeType);
  if (!(sts & 1)) goto wrapup;
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

    
/* -------------------------------------------
 * check to see if paste node is OK
 * default is OK if it passes through
 */
static IGRstat isPasteNodeValid(TVDct1JD  *parentJD,
				TVDct1JD  *copiedJD)
{
  VDASSERT_FN("isPasteNodeValid");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  IGRint   i;

  IGRchar copiedNodeNumAttr[64];
  IGRchar copiedTreeNumAttr[64];
  IGRchar copiedRevAttr[64];

  IGRchar parentNodeNumAttr[64];
  IGRchar parentTreeNumAttr[64];
  IGRchar parentRevAttr[64];
  
  IGRchar attrStatus[64];
  
  TVDctBaseInfo parentBaseInfo;
  TVDctBaseInfo copiedBaseInfo;
  
  TVDctNodeTypeInfo nodeTypeInfo;
  
  TVDct1JD  workJD;
  TVDct1JD  workParentJD;
  TVDct1JD  treeJD;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Arg check
  VDASSERTW(parentJD);
  VDASSERTW(copiedJD);
  
  // Can't let it be pasted onto itself
  if (parentJD->id.objid == copiedJD->id.objid) goto wrapup;
  
  // if parent is other than active, can't paste to it
  *attrStatus = 0;
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_FROZEN,attrStatus);
  if (attrStatus) {
    if (!strcmp(attrStatus,VDCT1_DEFAULT_FROZEN_F) ||
	!strcmp(attrStatus,VDCT1_DEFAULT_FROZEN_D)) goto wrapup;
  }
  
  // Need to convert to correct paste node type
  _RTCJDC(parentJD)->getPasteNodeType(parentJD,copiedJD,&nodeTypeInfo);
  if (*nodeTypeInfo.type == 0) goto wrapup;

  // check for valid child type
  sts = _RTCJDB(parentJD)->isChildTypeValid(parentJD,nodeTypeInfo.type);
  if (!(sts & 1)) goto wrapup;

  // make sure the copiedJD is not already a child of parentJD
  i = 0;
  while(_RTCJDB(parentJD)->getTreeChild(parentJD,i,&workJD)){
    //check it
    if (workJD.id.objid == copiedJD->id.objid) goto wrapup;
    i++;
  }
  
  // make sure the copiedJD is not already a parent of parentJD
  workParentJD = *parentJD;
  while(_RTCJDB(&workParentJD)->getTreeParent(&workParentJD,&workJD)) {
    if (workJD.id.objid == copiedJD->id.objid) goto wrapup;
    workParentJD = workJD;
  }
  
  /* make sure the copiedJD does not already exist in the new tree
   * this has to be done by the treenum-nodenum-rev index #
   * treenum-nodenum are only assigned in engineering trees.
   * if this attribute does not exist on the copiedJD, then let it
   * be pasted.
   */
    
  // get the attribute nodenumVDCT1_ATTR_TREE_NUMVDCT1_ATTR_ASSY_REV
  sts = _RTCJDB(copiedJD)->getAttr(copiedJD,VDCT1_ATTR_NODE_NUM,copiedNodeNumAttr);
  if (!(sts & 1)) {
    retFlag = 1;     // it can be pasted
    goto wrapup;
  }
    
  // does a node exist in parent tree with same attribute value
  sts = _RTCJDB(parentJD)->getRootForNode(parentJD,&treeJD);
  if (!(sts & 1)) {
    treeJD = *parentJD;
  }
  
  sts = _RTCJDB(&treeJD)->
    findNodeByAttrValue(&treeJD,VDCT1_ATTR_NODE_NUM,copiedNodeNumAttr,&workJD);
  if (!(sts & 1)) {
    if (traceFlag) printf ("### none found...\n");
    retFlag = 1;    // it can be pasted
    goto wrapup;
  }
  
  // now compare tree num and assy rev attributes

  // get the attributes first
  //retFlag = 1;   // just saving some typing

  if (traceFlag) {
    VDobjPrint2(NULL,&workJD.id); 
  }
  
  sts = _RTCJDB(copiedJD)->getAttr(copiedJD,VDCT1_ATTR_TREE_NUM,copiedTreeNumAttr);
  //if (!(sts & 1)) goto wrapup;
  if (traceFlag) printf ("### tree num 1 = %s\n",copiedTreeNumAttr);
     
  
  //sts = _RTCJDB(copiedJD)->getAttr(copiedJD,VDCT1_ATTR_ASSY_REV,copiedRevAttr);
  //if (!(sts & 1)) goto wrapup;
  //if (traceFlag) printf ("### assy rev 1 = %s\n",copiedRevAttr);

  sts = _RTCJDB(&workJD)->getAttr(&workJD,VDCT1_ATTR_TREE_NUM,parentTreeNumAttr);
  //if (!(sts & 1)) goto wrapup;
  if (traceFlag) printf ("### tree num 2 = %s\n",parentTreeNumAttr);

  //sts = _RTCJDB(&workJD)->getAttr(&workJD,VDCT1_ATTR_ASSY_REV,parentRevAttr);
  //if (!(sts & 1)) goto wrapup;
  //if (traceFlag) printf ("### assy rev 2 = %s\n",parentRevAttr);
  // retFlag = 0;
  
  // do the comparison, if they are equal, then cannot paste it
  if (!strcmp(copiedTreeNumAttr,parentTreeNumAttr)) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------------
 * check to see if rename node is OK
 * default is OK, provided none of these
 * conditions are met
 */
static IGRstat isRenameNodeValid(TVDct1JD  *nodeJD,
				 IGRchar   *nodeType)
{
  VDASSERT_FN("isRenameNodeValid");
  
  IGRstat   retFlag = 0;
  IGRstat   sts;
  TVDct1JD  parentJD;
  TVDct1JD  workJD;
  
  // Arg check
  VDASSERTW(nodeJD);
  VDASSERTW(nodeType);
  
  // Init 
  workJD = *nodeJD;
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // cannot rename the tree
  while (_RTCJDB(&workJD)->getTreeParent(&workJD,&parentJD)) 
    workJD = parentJD;
  
  // check to make sure we have tree top, and compare
  if (parentJD.id.objid == NULL_OBJID) {  // then workJD = tree top
    if (workJD.id.objid == nodeJD->id.objid)
      goto wrapup;
  }
  
  // cannot rename std assemblies, parts or an ENGR_ASSY[2]
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY6))    goto wrapup;
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_PART))     goto wrapup;
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_PART4))    goto wrapup;
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSY))     goto wrapup;
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSY2))    goto wrapup;
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSY6))    goto wrapup;

  // Done, everything else can be renamed
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

  

/* ----------------------------------------------
 * convert node type and give it a new name
 * Just do it
 */
static IGRstat convertNode(TVDct1JD  *activeNodeJD,
			   IGRchar   *newNodeType,
			   IGRchar   *newNodeName)
{
  VDASSERT_FN("convertNode");
  IGRstat        retFlag = 0;
  IGRstat        sts;
  TVDctBaseInfo  baseInfo;
  
  // Arg Check
  VDASSERTW(activeNodeJD);
  VDASSERTW(newNodeType);
  VDASSERTW(newNodeName);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // get base info of activenode
  _RTCJDB(activeNodeJD)->
    getBaseInfo(activeNodeJD,&baseInfo);
  if (baseInfo.nodeType == NULL) goto wrapup;
  
  // set new values
  strcpy(baseInfo.nodeType,newNodeType);
  strcpy(baseInfo.nodeName,newNodeName);
  
  // set base info
  sts = _RTCJDB(activeNodeJD)->
          setBaseInfo(activeNodeJD,&baseInfo);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

  

/* --------------------------------------------------
 * Validate convert node type
 * do not allow anything
 */
static IGRstat isConvertNodeValid(TVDct1JD *nodeJD,
				  IGRchar  *activeNodeType,
				  IGRchar  *newNodeType)
{
  VDASSERT_FN("isConvertNodeValid");
  IGRstat retFlag = 0;

  // Say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
 
  // Arg check
  VDASSERTW(activeNodeType);
  VDASSERTW(newNodeType);

wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}



/* ---------------------------------------------
 * makeNodeName:  I - parentJD
 *              I/O - baseInfo
 * default implementation will simply convert
 * baseInfo.nodeName and .nodeType to upper case
 * may also be used to generate node names as desired.
 */
static IGRstat makeNodeName(TVDct1JD      *parentJD,   
			    TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("makeNodeName");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  
  VDASSERTW(baseInfo);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Upper Case
  strupr(baseInfo->nodeType);
  strupr(baseInfo->nodeName);

  // Clean it
  sts = _RTCJDB(parentJD)->cleanName(parentJD,baseInfo->nodeName);
  if (!(sts & 1)) goto wrapup;
 
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* -----------------------------------------------
 * Creates node under parent based on DB query
 * default implementation is to do nothing
 */

static IGRstat createNodeByQuery(TVDct1JD  *parentJD)
{
  VDASSERT_FN("createNodeByQuery");

  IGRstat retFlag = 0;
  
  //say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  //Done
  retFlag = 1;
    
wrapup:
  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }  
  return retFlag;
}

/* -----------------------------------------------
 * Returns value for form gadget
 */
static IGRstat getGadgetText(TVDct1JD *nodeJD,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
  VDASSERT_FN("getGadgetText");
  IGRstat retFlag = 0;
  IGRchar status[80];
  TVDctBaseInfo baseInfo;
  
  
  //say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // Arg check
  VDASSERTW(txt); *txt = 0;
  VDASSERTW(formName && *formName);
  VDASSERTW(nodeJD);
  
  // get the baseInfo stuff
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  
  // Status Form
  if (!strcmp(formName,VDCT_FORM_FREE_F_NAME)) {
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_FROZEN,status);
    
    switch(gadget) {
      case VDCT_FORM_FREE_G_DOIT:

        // the exceptions that have no action
        if((strcmp(status,VDCT1_DEFAULT_FROZEN_A)) &&
           (strcmp(status,VDCT1_DEFAULT_FROZEN_D))) {
          retFlag = 1;
          switch(nth) {
            case 0: strcpy(txt,"Review Node");  break;
            default: retFlag = 0;
          }
          break;
        }

        if(!strcmp(status,VDCT1_DEFAULT_FROZEN_A)) {
          retFlag = 1;
          if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {
            // if it is a EA2
            switch(nth) {
              case 0: strcpy(txt,"1 Mark Node Deleted");  break;
              default: retFlag = 0;
            }
            break;
          }
          else {
            switch(nth) {
              case 0: strcpy(txt,"Review Node");  break;
              default: retFlag = 0;
            }
            break;
          }
        }

        if(!strcmp(status,VDCT1_DEFAULT_FROZEN_D)) {
          retFlag = 1;
          if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {
            // if it is a EA2
            switch(nth) {
              case 0: strcpy(txt,"2 Set Node Active");  break;
              default: retFlag = 0;
            }
            break;
          }
          else {
             switch(nth) {
               case 0: strcpy(txt,"Review Node");  break;
               default: retFlag = 0;
             }
             break;
           }
        }
        break;
    }
     
    goto wrapup;
  }
  
  // Tree Form
  if (!strcmp(formName,VDCT_FORM_TREE_F_NAME)) {
    
    switch(gadget) {
      
      case VDCT_FORM_TREE_G_DISPLAY:
        
        retFlag = 1;
	
        switch(nth) {
          case 0: strcpy(txt,"1 All     Nodes");  break;
          case 1: strcpy(txt,"2 Active  Nodes");  break;
          case 2: strcpy(txt,"3 Latest  Frozen"); break;
          case 3: strcpy(txt,"4 Deleted NODES");  break;
          default: retFlag = 0;
        }
        break;	
    }
    goto wrapup;
  }
  
  // Set Form
  if (!strcmp(formName,VDCT_FORM_SET_F_NAME)) {
    
    switch(gadget) {
      case VDCT_FORM_SET_G_DOIT:
        
        retFlag = 1;
	
        switch(nth) {
          case 0: strcpy(txt,"1 Review Tree"); break;
          case 1: strcpy(txt,"2 Create Tree"); break;
          case 2: strcpy(txt,"3 Delete Tree"); break;
          case 3: strcpy(txt,"4 Rename Tree"); break;
          case 4: strcpy(txt,"5 Post   Tree"); break;
          default: retFlag = 0;
        }
        break;	
    }
    goto wrapup;
  }
  
  // Done (return 0 indicating form/gadget was not processed)
  
 wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------------
 * Determine type of node to create during copy operation
 *
 * I - copyJD copyBaseInfo              Node being copied
 * I - parentJD parentBaseInfo          Parent where node is to be copied
 *
 * O - info - Node Type to create
 *
 * This is really only for transformations, calling routine will
 * ensure that if this fails then a valid node type does exists
 *
 * Default Implementation sets info to copyBaseInfo.nodeType
 */
static IGRstat getPasteNodeType(TVDct1JD          *parentJD, 
				TVDct1JD          *copyJD,
				TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getPasteNodeType");
  
  IGRstat          retFlag;
  TVDctBaseInfo    parentBaseInfo;
  TVDctBaseInfo    copyBaseInfo;
  IGRstat          sts;
   
  //Init
  retFlag = 0;
      
  //Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  //Arg check
  VDASSERTW(&parentJD != NULL);
  VDASSERTW(&copyJD   != NULL);
  
  // Get base info of objects
  sts = _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (!sts) goto wrapup;
  
  sts = _RTCJDB(copyJD)->getBaseInfo(copyJD,&copyBaseInfo);
  if (!sts) goto wrapup;

  //Do it
  strcpy(info->type,copyBaseInfo.nodeType);

  //Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Inits these pointers
 */
IGRstat VDct1InitRootTreeClassC(TVDct1RootTreeClass *cl)
{
  VDASSERT_FN("VDct1InitRootTreeClassC");
  
  IGRstat retFlag = 0;
  
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_COM);
  
  // Fill up pointers
  cl->cmd.getGadgetText      = getGadgetText;
  cl->cmd.getPasteNodeType   = getPasteNodeType;
  cl->cmd.createNodeByQuery  = createNodeByQuery;
  cl->cmd.makeNodeName       = makeNodeName;
  cl->cmd.isConvertNodeValid = isConvertNodeValid;
  cl->cmd.convertNode        = convertNode;
  cl->cmd.isRenameNodeValid  = isRenameNodeValid;
  cl->cmd.isPasteNodeValid   = isPasteNodeValid;
  cl->cmd.isMoveNodeValid    = isMoveNodeValid;
  cl->cmd.isDeleteNodeValid  = isDeleteNodeValid;
  cl->cmd.isDeleteTreeValid  = isDeleteTreeValid;
  cl->cmd.isCreateTreeValid  = isCreateTreeValid;
  cl->cmd.isRenameTreeValid  = isRenameTreeValid;
  cl->cmd.isAttrUpdateValid  = isAttrUpdateValid;
  cl->cmd.validateAttrValue  = validateAttrValue;

  cl->cmd.updateChildAttrValue = updateChildAttrValue;
  cl->cmd.isAttrPropagateValid = isAttrPropagateValid;
  cl->cmd.computeMoveCopyNode  = computeMoveCopyNode;
  cl->cmd.copyNodeAttributes   = copyNodeAttributes;
  cl->cmd.updateNodeAttributes = updateNodeAttributes;
  cl->cmd.setNodeUserInfo      = setNodeUserInfo;

  cl->cmd.getNewParentForPastedNode = getNewParentForPastedNode;
  cl->cmd.isNodeInfoForPasteValid   = isNodeInfoForPasteValid;

  cl->cmd.isMarkDeletedOK      = isMarkDeletedOK;
  cl->cmd.isUnmarkDeletedValid = isUnmarkDeletedValid;

  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}











