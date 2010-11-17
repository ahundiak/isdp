/* $Id: VDct1RootTree.c,v 1.10.2.1 2002/11/22 17:07:58 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1RootTree.I
 *
 * Description: Base Tree Class
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1RootTree.c,v $
 *      Revision 1.10.2.1  2002/11/22 17:07:58  ahundiak
 *      ah TR7049
 *
 *      Revision 1.10  2002/05/16 21:22:27  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.9  2002/02/22 15:09:25  jdsauby
 *      JTSMP TR 6042
 *
 *      Revision 1.8  2002/02/11 17:30:43  jdsauby
 *      JTSMP CR 6012
 *
 *      Revision 1.7  2002/01/07 18:52:49  jdsauby
 *      JTSMP CR 5832 and CRs 4045,4048,4053,4054
 *
 *      Revision 1.6  2001/12/03 16:47:01  jdsauby
 *      JTS MP CR 5832
 *
 *      Revision 1.5  2001/06/05 20:08:48  jdsauby
 *      CR5180, additional fix, to take into account a node deleting itself.  jds
 *
 *      Revision 1.4  2001/05/14 20:49:42  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.3  2001/02/17 14:48:11  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/12 16:16:03  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/12 15:14:10  art
 *      sp merge
 *
 * Revision 1.2  2000/12/15  18:18:14  pinnacle
 * js
 *
 * Revision 1.1  2000/12/08  15:49:42  pinnacle
 * ah
 *
 * Revision 1.10  2000/09/25  20:42:48  pinnacle
 * js
 *
 * Revision 1.9  2000/09/07  18:02:38  pinnacle
 * js
 *
 * Revision 1.8  2000/09/04  14:43:42  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h" 
#include "VDos.h"
#include "VDassert.h"
#include "VDrisc.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"
#include "VDct1Ris.h"



VDASSERT_FFN("vdct1/tree/VDct1RootTree.C");

#define MY_TREE VDCT1_TREE_TYPE_ROOT_TREE



/* -----------------------------------------------
 * Delete Nodes which are marked as deleted
 * **/
static IGRstat deleteMarkedNodes(TVDct1JD *nodeJD)
{
    VDASSERT_FN("deleteMarkedNodes");

    IGRstat  retFlag = 0;
    TVDct1JD childJD;
    TVDct1JD childJDx;
    IGRint   i;
    IGRchar  buf[80];
    TVDctBaseInfo baseInfo;

    // arg check
    VDASSERTW(nodeJD && nodeJD->id.objid != NULL_OBJID);

    // get the baseInfo
    VDjt1GetBaseInfo(nodeJD,&baseInfo);
    if (*baseInfo.nodeType == 0) goto wrapup;

    // if it is a EA2, then don't delete, no matter what
    if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;

    // mark the node as deleted
    *buf = 0;
    VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,buf);
    if (*buf != 0) {

	if (!strcmp(buf,VDCT1_DEFAULT_FROZEN_D) ) {
	    _RTCJDB(nodeJD)->deleteNode(nodeJD);
	}
    }

    // now do the kids
    for (i = 0;_RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++ ) {
    
	_RTCJDB(&childJD)->deleteMarkedNodes(&childJD);

	// if a child was deleted, need to continue with the next child
	_RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJDx);
	if (childJD.id.objid != childJDx.id.objid) i--;

    }

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ------------------------------------------------
 * Verify that the attributes on the model object still
 * match what is in the tree.
 * */
static IGRstat verifyModelAttrs(TVDct1JD *nodeJD)
{
  VDASSERT_FN("verifyModelAttrs");

  // they are all good at the root level.  overrides will be done at 
  // engineering tree level.
  return 1;
}

/* -----------------------------------------------
 * Helper function to recomputestdassy
 * */
static void getNewNodeTypeFromDB(TVDctBaseInfo *baseInfo,
	                         char          *nodeType)
{
    VDASSERT_FN("getNewNodeTypeFromDB");

    TVDrisInfo ris;
    char       type[80];

    // init
    VDrisInitInfo( &ris );

    // arg check
    VDASSERTW(baseInfo && *baseInfo->nodeName);
    VDASSERTW(nodeType); *nodeType = 0;

    // say hi
    //traceFlag = 1;
    if (traceFlag) printf(">>> %s %s <%s><%s>\n",
	                   ffn(),fn,baseInfo->nodeType,baseInfo->nodeName);

    // get the type from the database
    sprintf(ris.sql,
	    "Select item_type from tm_items where item_cage_num='%s';",
	    baseInfo->nodeName);
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) {
	strcpy(nodeType,baseInfo->nodeType);
	goto wrapup;
    }

    strcpy(type,ris.buf[0]);
    if (traceFlag) printf("### type num <%s>\n",type);

    switch (*type)
    {
      case '2':
	  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2);
	  goto wrapup;

      case '4':
	  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);
	  goto wrapup;

      case '6':
	  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ASSY6);
	  goto wrapup;

      default:
	  strcpy(nodeType,baseInfo->nodeType);
	  goto wrapup;
    }

    // done
wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s nodeType <%s>\n",ffn(),fn,nodeType);
    return;
}

/* ------------------------------------------------
 * determine if the node is a std assy that has changed in configuration
 * **/
static IGRstat isStdAssyChanged(TVDct1JD      *nodeJD,
	                        TVDctBaseInfo *baseInfo)
{
    VDASSERT_FN("isStdAssyChanged");

    IGRstat       retFlag = 0;  //default to not changed
    TVDrisInfo    ris;
    IGRchar     **at_buf;   // buffer to store attributes from child nodes
    IGRint        numChild; // number of children
    IGRint        i,j;
    TVDct1JD      childJD;
    TVDctBaseInfo childInfo;
    IGRchar       childQty[80];

    // init
    VDrisInitInfo( &ris );

    // arg check
    VDASSERTW(baseInfo);
    VDASSERTW(nodeJD && nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(*baseInfo->nodeName && *baseInfo->nodeType);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // is it a std assy
    if ( strcmp(baseInfo->nodeType,VDCT1_ENG_NODE_TYPE_ASSY2) &&
	 strcmp(baseInfo->nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)   )
    {
	goto wrapup;
    }

    // get the assembly part information from table tm_ps
    VDct1QryPS(&ris, baseInfo->nodeName);
    if (ris.rows < 1) {
	// assembly must have changed
	retFlag = 1;
	goto wrapup;
    }

    // get the number of children under the stdassy from the tree
    numChild = 0;
    for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
	numChild++;
    }

    // if the number of parts in assy do not match, then it has changed
    if (ris.rows != numChild) {
	retFlag = 1;
	goto wrapup;
    }

    //note: nodes are created under a STDASSY in the sort order (ps_sort), if
    //that has changed, and nothing else has, then it will still be flagged as
    //a changed assembly.  But, Why would you change the sort order w/o
    //actually changing something else??  this should be an OK assumption.
    //
    //For each child, compare its nodeName, and qty to the same from the db

    for (i = 0;  _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {

	if (childJD.id.objid == NULL_OBJID) goto wrapup;
	j = i * ris.cols;

	// get child node base info
	VDjt1GetBaseInfo(&childJD,&childInfo);
	if (*childInfo.nodeName == 0) goto wrapup;

	// get child node qty
	*childQty = 0;
	VDjt1GetAttr(&childJD,VDCT1_ATTR_QTY,childQty);
	if (*childQty == 0) goto wrapup;

	if (traceFlag) {
	printf("###################\n%s %s\n%s %s\n",
		ris.buf[j+VDCT1_RIS_COLI_PS_CHILD_CAGE_NUM],childInfo.nodeName,
		ris.buf[j+VDCT1_RIS_COLI_PS_QTY],childQty);
	}

	// compare child cage num to db
	if (strcmp(ris.buf[j+VDCT1_RIS_COLI_PS_CHILD_CAGE_NUM],childInfo.nodeName))
	{
	    // part has changed, assy has changed
	    retFlag = 1;
	    goto wrapup;
	}

	// compare child qty to db
	if (strcmp(ris.buf[j+VDCT1_RIS_COLI_PS_QTY],childQty))
	{
	    // diff qty, assy has changed
	    retFlag = 1;
	    goto wrapup;
	}
    }

	

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    VDrisFreeInfo( &ris );
    return retFlag;
}

/* ------------------------------------------------
 * Recompute from current node down.  Just like creating a new
 * node.
 * */
static IGRstat reComputeStdAssy(TVDct1JD *nodeJD)
{
  VDASSERT_FN("reComputeStdAssy");

  IGRstat        retFlag = 0;
  TVDct1JD       childJD,childJDx;
  TVDctBaseInfo  baseInfo;
  IGRint         i;
  IGRstat        sts;
  IGRchar        op[3];
  IGRchar        newNodeType[80];
  IGRint         reExpand;
  IGRchar        buf[80];

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // Get the baseinfo
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  VDASSERTW(*baseInfo.nodeType != 0);

  // say hi
  if (traceFlag) printf(">>> %s %s [%s %s]\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
  
  // by default, do not re-expand
  reExpand = 0;

  // if the node is marked as deleted, no need to recompute
  strcpy(buf,"");
  VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,buf);
  if (!strcmp(buf,VDCT1_DEFAULT_FROZEN_D)) goto wrapup;

  /***************************************************************
   * Has the Assembly configuration changed within database, if so
   * delete the children, then re-expand it.
   * ****************************************/
  
  // if it was a std assy that has changed, delete the children
  if ( isStdAssyChanged(nodeJD,&baseInfo) )
  {
      if (traceFlag) printf("### StdAssy has changed [%s]\n",baseInfo.nodeName);
      // delete the children
      VDjt1DeleteAllChildNodes(nodeJD);

      // set flag to re-expand
      reExpand = 1;
  }


  /***************************************************************
   * Has the nodeType changed.  If so, convert the nodetype, delete
   * the children, then re-expand it.
   * *****************************************/
  
  // get the new nodetype
  getNewNodeTypeFromDB(&baseInfo, newNodeType);

  // convert if needed
  if (strcmp(baseInfo.nodeType,newNodeType))
  {
      if (traceFlag) printf("### nodeType has changed [%s->%s]\n",
	                     baseInfo.nodeType,newNodeType);

      // delete the kids
      VDjt1DeleteAllChildNodes(nodeJD);

      // convert the node
      strcpy(baseInfo.nodeType,newNodeType);
      _RTCJDB(nodeJD)->setBaseInfo(nodeJD,&baseInfo);

      // set the re-expand flag
      reExpand = 1;
  }

  // re-expand if it is a std assy
  if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)) )
  {
      // re-expand
      strcpy(op," ");
      _RTCJDB(nodeJD)->preExpandContractNode(nodeJD,op);
  }

  // do the kids
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
  
      _RTCJDB(&childJD)->reComputeStdAssy(&childJD);

  }

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Mark current node, and the children as active
 * **/
static IGRstat markNodeAsActive(TVDct1JD *nodeJD)
{
    VDASSERT_FN("markNodeAsActive");

    IGRstat  retFlag = 0;
    TVDct1JD childJD;
    IGRint   i;
    IGRchar  buf[80];

    // arg check
    VDASSERTW(nodeJD && nodeJD->id.objid != NULL_OBJID);

    // mark the node as deleted
    *buf = 0;
    VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,buf);
    if (*buf != 0) {

	if (!strcmp(buf,VDCT1_DEFAULT_FROZEN_D) ) {
	    VDjt1SetAttr(nodeJD,VDCT1_ATTR_FROZEN,VDCT1_DEFAULT_FROZEN_A);
	}
    }

    // now do the kids
    for (i = 0;_RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++ ) {
    
	_RTCJDB(&childJD)->markNodeAsActive(&childJD);
    }

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}


/* -----------------------------------------------
 * Mark current node, and the children as deleted
 * **/
static IGRstat markNodeAsDeleted(TVDct1JD *nodeJD)
{
    VDASSERT_FN("markNodeAsDeleted");

    IGRstat  retFlag = 0;
    TVDct1JD childJD;
    IGRint   i;

    // arg check
    VDASSERTW(nodeJD && nodeJD->id.objid != NULL_OBJID);

    // mark the node as deleted
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_FROZEN,VDCT1_DEFAULT_FROZEN_D);

    // now do the kids
    for (i = 0;_RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++ ) {
    
	_RTCJDB(&childJD)->markNodeAsDeleted(&childJD);
    }

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}
 

/* ------------------------------------------------
 * Recompute from current node down.  Just like creating a new
 * node.
 * */
static IGRstat reComputeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("reComputeNode");

  IGRstat        retFlag = 0;
  TVDct1JD       childJD,childJDx;
  TVDctBaseInfo  baseInfo;
  TGRobj_env     modelOE;
  IGRint         i;
  IGRchar        buf[128];
  IGRstat        sts;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // if the node is marked as deleted, no need to recompute
  strcpy(buf,"");
  VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,buf);
  if (!strcmp(buf,VDCT1_DEFAULT_FROZEN_D)) goto wrapup;

  // verify model Attributes, such as unit to see if they have changed
  if ( !(_RTCJDB(nodeJD)->verifyModelAttrs(nodeJD)) ) {
      sts = VDjt1GetBaseInfo(nodeJD,&baseInfo);
      if (sts) 
	  printf("Deleted Node <%s %s>\n",baseInfo.nodeType,baseInfo.nodeName);
      _RTCJDB(nodeJD)->deleteNode(nodeJD);
      goto kids_loop;
  }

  // compute the node
  VDjt1ComputeNode(nodeJD);

  // does it have a modelOE
  modelOE.obj_id.objid = NULL_OBJID;
  VDjt1GetModelObject(nodeJD,&modelOE);

  // this should have been done in the verify model attributes, but
  // older trees may not have had the modelID attribute, hence, the
  // compute node must come before this to attempt to get a modelID attr
  // first.

  if (modelOE.obj_id.objid == NULL_OBJID) {
      // check model_id attribute to see if one did exist
      strcpy(buf,"");
      VDjt1GetAttr(nodeJD,VDCT1_ATTR_MODEL_ID,buf);

      if (strcmp(buf,"")) {
	      // it did have a model_object attached, delete it
	      // CR 6359, mark as deleted.
	      sts = VDjt1GetBaseInfo(nodeJD,&baseInfo);
	      if (sts) 
		  printf("Node <%s %s> [%s] Marked Deleted\n",
			  baseInfo.nodeType,baseInfo.nodeName,buf);
	      //_RTCJDB(nodeJD)->deleteNode(nodeJD); 
	      // CR6359
	      _RTCJDB(nodeJD)->markNodeAsDeleted(nodeJD);
	      
      }
  }
    
kids_loop:
  // do the kids
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
      _RTCJDB(&childJD)->reComputeNode(&childJD);

      // if the child was deleted, we need to continue with the other children.
      _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJDx);
      if (childJD.id.objid != childJDx.id.objid) i--;
  }

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Update node information for existing tree nodes
 * **/
static IGRstat updateNodesOnTree(TVDct1JD *nodeJD)
{
  VDASSERT_FN("updateNodesOnTree");

  IGRstat retFlag = 0;
  TVDctBaseInfo  baseInfo;
  TVDct1JD childJD;
  IGRint   i;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  
  // get base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD, &baseInfo);
  if (traceFlag && baseInfo.nodeType != NULL) 
      printf(">>> %s %s <%s,%s>\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);

  // compare and change
  // ENGASSY6
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_EA6_OLD)) {
      strcpy(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
      goto kids;
  }

  // ENGASSY2
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_EA2_OLD)) {
      strcpy(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
      goto kids;
  }

  // ASSY2
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2_OLD)) {
      strcpy(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2);
      goto kids;
  }

  // ASSY6
  if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6_OLD)) {
      strcpy(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6);
      goto kids;
  }

  // STD_ASSY2
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2_OLD)) {
      strcpy(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2);
      goto kids;
  }

  // STD_ASSY6
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6_OLD)) {
      strcpy(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6);
      goto kids;
  }

  // STD_PART4
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4_OLD)) {
      strcpy(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4);
      goto kids;
  }


kids:
  // set the baseInfo
  _RTCJDB(nodeJD)->setBaseInfo(nodeJD, &baseInfo);
  
  // do the kids
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
      _RTCJDB(&childJD)->updateNodesOnTree(&childJD);
  }

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* -------------------------------------------------
 * Set nodeInfo for a given node
 */
static IGRstat setNodeInfo(TVDct1JD *nodeJD, TVDct1NodeInfo *info)
{
  VDASSERT_FN("setNodeInfo");
  
  IGRstat retFlag = 0;
  TVDctBaseInfo  baseInfo;
  
  // Arg check
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;
    
  // init
  //  traceFlag = 1;
  
  memset(info,0,sizeof(TVDct1NodeInfo));
  
  // parentJD
  _RTCJDB(nodeJD)->getTreeParent(nodeJD,&info->parentJD);
  if (info->parentJD.id.objid == NULL_OBJID) {
    info->parentJD = *nodeJD;  // just so it is not null
  }
    
  // nodeJD
  info->nodeJD = *nodeJD;
  
  // baseInfo of nodeJD
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (baseInfo.nodeType == NULL) goto wrapup;
  
  if (traceFlag) printf("### %s %s %s %s\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
  
  info->info = baseInfo;
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Get the nodeInfo for a given node, same as setNodeInfo
 */
static IGRstat getNodeInfo(TVDct1JD *nodeJD, TVDct1NodeInfo *info)
{
  return _RTCJDB(nodeJD)->setNodeInfo(nodeJD,info);
}

/* -----------------------------------------------
 * add nodes to nodeinfos
 */
static IGRstat addNodesToNodeInfos(TVDct1JD *nodeJD, TVDct1NodeInfos *infos)
{
  IGRstat retFlag = 0;
  
  TVDct1JD       childJD;
  TVDct1NodeInfo nodeInfo;
  TVDct1NodeInfo *nodes;
  
  IGRint i;
      
  // Arg check
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;
  if (infos == NULL)                  goto wrapup;
  if (infos->nodes == NULL)           goto wrapup;
  
  // expand nodeInfos if necessary
  if (infos->cnt == infos->max) {
  
    nodes = realloc(infos->nodes,(infos->max + infos->inc) * sizeof(TVDct1NodeInfo));
    
    if (nodes == NULL) {
      printf("*** Problem allocating VDct1NodeInfos list\n");
      goto wrapup;
    }
    infos->nodes = nodes;
    infos->max  += infos->inc;
  }
  
  // get node info of node
  _RTCJDB(nodeJD)->getNodeInfo(nodeJD,&nodeInfo);
  if (*nodeInfo.info.nodeType == 0) goto wrapup;
  
  // Add it
  infos->nodes[infos->cnt] = nodeInfo;
  infos->cnt++;
  
  // now do the kids
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
    
    if (childJD.id.objid != NULL_OBJID) addNodesToNodeInfos(&childJD,infos);
  }
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Fills up the nodeInfos list, this will be a list of
 * all nodes in a tree.
 */
static IGRstat setNodeInfos(TVDct1JD *nodeJD, IGRint opt, TVDct1NodeInfos *infos)
{
  IGRstat retFlag = 0;

  TVDct1JD  rootJD;
  
  // Arg check
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;
  if (opt == NULL) goto wrapup;
  
  // just switch
  switch (opt) {
    
    case VDCT1_SET_NODE_INFOS_ENTIRE_TREE:
      // Get the root node for the tree
      _RTCJDB(nodeJD)->getRootForNode(nodeJD,&rootJD);
      if (rootJD.id.objid == NULL_OBJID) goto wrapup;
      
      // add node to nodeInfos
      addNodesToNodeInfos(&rootJD,infos);
  
      // done
      retFlag = 1;
      goto wrapup;
      
    case VDCT1_SET_NODE_INFOS_NODE_DOWN:
      addNodesToNodeInfos(nodeJD,infos);
      retFlag = 1;
      goto wrapup;
  }
  
  // none found
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * just like the name, get an info from an infos
 */
static IGRstat getNthInfoFromNodeInfos(TVDct1JD        *nodeJD,
				       TVDct1NodeInfos *nodeInfos,
				       IGRint           nth,
				       TVDct1NodeInfo  *nodeInfo)
{
  IGRstat retFlag = 0;
  
  if (nth > nodeInfos->cnt) goto wrapup;
  
  *nodeInfo = nodeInfos->nodes[nth];
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* --------------------------------------------------
 * Called when user tries to expand or contract
 * A tree row
 */
static IGRstat preExpandContractNode(TVDct1JD *nodeJD, IGRchar *op)
{
  VDASSERT_FN("preExpandContractNode");  
  IGRstat retFlag = 1;

  // Arg check
  VDASSERTW(nodeJD);

wrapup:  
  return retFlag;
}

/* --------------------------------------------------
 * Validate child type
 * Allow everything
 */
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");
  IGRstat retFlag = 1;

  // Arg check
  VDASSERTW(parentJD);
  VDASSERTW(childType);

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Create a node
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{
  VDASSERT_FN("createNode");
  IGRstat retFlag = 0;
  
  // Actual id's
  TGRid *parentID;
  TGRid *nodeID;
  
  TVDfld  fld;

  TVDctBaseInfo baseInfo;
  TVDctAttrInfo attrInfo;
  IGRchar       attrName[64];
  
  IGRint i;
  
  IGRint parentIsSet = 0;
  
  // Arg check
  VDASSERTW(nodeJD);   
  // nodeID = &nodeJD->id;
  //nodeID->objid = NULL_OBJID;

  VDASSERTW(parentJD); 
  // parentID      = &parentJD->id;
  nodeJD->cl    =  parentJD->cl;
  //  nodeID->osnum =  parentID->osnum;
  
  nodeJD->id.osnum = parentJD->id.osnum;
  
  VDASSERTW(nodeName);
  VDASSERTW(nodeType);
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",ffn(),fn,nodeType,nodeName);
  }
  
  // Grab the parents (either node or set) info
  VDjt1GetBaseInfo(parentJD, &baseInfo);
  VDASSERTW(*baseInfo.setType);

  // Set or regular node flag
  if (*baseInfo.nodeType == 0) parentIsSet = 1;
  
  // Make the set object
  VDjt1CreateBaseObject(nodeJD,VDCT1_CLASS_TYPE_NODE);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // Connect to parent or the set
  if (parentIsSet) VDjt1ConnectMgrChild (parentJD,nodeJD);
  else             VDjt1ConnectTreeChild(parentJD,nodeJD);
  
  // Set info
  strcpy(baseInfo.nodeName,nodeName);
  strcpy(baseInfo.nodeType,nodeType);
  VDjt1SetBaseInfo(nodeJD, &baseInfo);

  // Add attributes
  for(i = 0; 
      VDjt1GetNodeAttrName(nodeJD,nodeType,i,attrName); 
      i++) {
    
    // Get the full info
    VDjt1GetNodeAttrInfo(nodeJD,attrName,&attrInfo);
    VDASSERTW(*attrInfo.name);
    
    // printf("Adding Attribute %s\n",attrName);
    VDjt1CreateAttr(nodeJD,attrInfo.name,attrInfo.type,"");
  }

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}

/* -------------------------------------------------
 * Gets the default node type to use when creating a set
 * Note: In order to have gotten this far, mgrJD.cl
 * must have been correctly set
 */
static IGRstat getRootNodeTypeForSet(TVDct1JD *mgrJD,
				     IGRchar  *setType,
				     IGRchar  *setName,
				     IGRchar  *nodeType)
{
  VDASSERT_FN("getRootNodeTypeForSet");
  IGRstat retFlag;
  
  IGRint i;
  TVDctNodeTypeInfo info;
  TVDct1JD setJD;
  
  // Arg check
  VDASSERTW(nodeType); *nodeType = 0;
  VDASSERTW(mgrJD);
  VDASSERTW(setType);
  VDASSERTW(setName);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }
  
  // Cycle through
  for(i = 0; VDjt1GetNodeTypeInfo(mgrJD,i,NULL,&info); i++) {
    
    if (*info.level == 'S') {
      strcpy(nodeType,info.type);
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // None!

 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %s %s %s\n",ffn(),fn,setType,setName,nodeType);
  }
  return retFlag;
}

/* -------------------------------------------------
 * Create a set
 */
static IGRstat createSet(TVDct1JD *mgrJD,
			 IGRchar  *setType,
			 IGRchar  *setTypeRev,
			 IGRchar  *setName,
			 TVDct1JD *setJD)
{
  VDASSERT_FN("createSet");
  IGRstat retFlag = 0;

  // The real id's
  TGRid *mgrID;
  TGRid *setID;
  
  TVDctBaseInfo baseInfo;
  TVDctNodeType nodeType;
  
  TVDct1JD nodeJD;
  
  // Arg Check
  VDASSERTW(setJD);
  setID =  &setJD->id;
  setID->objid = NULL_OBJID;

  VDASSERTW(mgrJD);
  mgrID   =  &mgrJD->id;
  setJD->cl = mgrJD->cl;
  
  VDASSERTW(setType);
  VDASSERTW(setName);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }
  
  // Make the set object
  VDct1CreateBaseObject(VDCT1_CLASS_TYPE_SET,mgrID->osnum,setID);  
  VDASSERTW(setID->objid != NULL_OBJID);

  /* ---------------------------------------------
   * The VDctx routine is not yet implemented
   * Just use the low level call for now
   */
  // Connect to manager
  // VDctxConnectMgrChild(mgrID,setID);
  VDlnkConnect(VDCT_CHN_MGR,mgrID,setID);
  
  // Set info
  memset(&baseInfo,0,sizeof(TVDctBaseInfo));
  strcpy( baseInfo.setName,setName);
  strcpy( baseInfo.setType,setType);
  
  // Allow overrideing set rev
  strcpy(baseInfo.setTypeRev,_RTCJDB(mgrJD)->info.rev);
  if ((setTypeRev) && (*setTypeRev)) {
    strcpy(baseInfo.setTypeRev,setTypeRev);
  }
  VDct1SetBaseInfo(NULL,setID,&baseInfo);
  
  // Get default node type
  _RTCJDB(setJD)->getRootNodeTypeForSet(setJD,setType,setName,nodeType);
  if (*nodeType == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  // Create Node
  _RTCJDB(setJD)->createNode(setJD,nodeType,setName,&nodeJD);
  if (nodeJD.id.objid == NULL_OBJID) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;  
}

/* -------------------------------------------------
 * Class filter
 */
static IGRstat getFilter(TVDct1JD *setJD, OM_S_CLASSLIST *classList)
{
  VDASSERT_FN("getFilter");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(setJD);
  VDASSERTW(classList);
  
  // Fill it
  VDomGetClassIdForClassName("VDSroot",&classList->p_classes[0]);
  classList->w_count = 1;

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Individual stage info
 */
static IGRstat getNodeTypeInfo(TVDct1JD *nodeJD,
			       IGRint    nth, 
			       IGRint   *cnt, 
			       TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getNodeTypeInfo");
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 0;  // Set this to total number of nodes
  VDASSERTW(nodeJD);
  VDASSERTW(info);
  
  // No More
  memset(info,0,sizeof(TVDctNodeTypeInfo));

 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Assorted information about the set type
 * Not usualy overridden
 */
static IGRstat getSetTypeInfo(TVDct1JD         *setJD,
			      TVDctSetTypeInfo *info)
{
  VDASSERT_FN("getSetTypeInfo");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(setJD);
  VDASSERTW(info);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Copy
  *info = _RTCJDB(setJD)->info;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* --------------------------------------------------
 * For a given set wide attribute name, fill in the info
 */
static IGRstat getNodeAttrInfo(TVDct1JD      *nodeJD,
			       IGRchar       *name, 
			       TVDctAttrInfo *info)
{ 
  VDASSERT_FN("getNodeAttrInfo");
  IGRstat retFlag = 0;

  // Arg Check
  VDASSERTW(nodeJD);
  VDASSERTW(name);
  VDASSERTW(info);
  
  // Just a clear
  memset(info,0,sizeof(TVDctAttrInfo));
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * get the nth attribute name
 */
static IGRstat getNodeAttrName(TVDct1JD *nodeJD,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{
  VDASSERT_FN("getNodeAttrName");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(nodeJD);
  VDASSERTW(nodeType);
  VDASSERTW(attrName); *attrName = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Hello routine for testing
 */
static IGRstat hello(TVDct1JD *nodeJD)
{ 
  VDASSERT_FN("hello");
  VDASSERTW(nodeJD);
  
  printf("@@@ Hello from %s\n",_RTCJDB(nodeJD)->info.type);

 wrapup:
  return 1;
}

/* -----------------------------------------------
 * Search current tree for a node
 */

/* -----------------------------------------------
 * Need a central processor to catch and clean
 * any errors in a proposed node name
 *
 * return 0 If cannnot fix
 * return 1 If no changes required
 * return 3 If something was done
 */
static IGRstat cleanName(TVDct1JD *nodeJD,
			 IGRchar  *nodeName)
{
  VDASSERT_FN("cleanName");
  IGRstat retFlag = 0;
  
  IGRchar *p;

  // Arg check
  VDASSERTW(nodeJD);
  VDASSERTW(nodeName);
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s '%s'\n",ffn(),fn,nodeName);
  }
  
  // Need something
  if (*nodeName == 0) goto wrapup;
  
  // Ok
  retFlag = 1;
  
  // Scan Through
  for(p = nodeName; *p; p++) {
    if (*p == ':') {
      *p = '_';
      retFlag = 3;
    }
    if (*p < ' ') {
      *p = '_';
      retFlag = 3;
    }
  }
  
  // Done
 wrapup:

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Utility routine to check first letter
 */
static IGRstat isFirstCharOK(TVDct1JD *parentJD, IGRchar *name)
{
  VDASSERT_FN("isFirstLetterOK");
  
  VDASSERTW(name);
  
  if ((*name >= 'A') && (*name <= 'Z')) return 1;
  if ((*name >= 'a') && (*name <= 'z')) return 1;
  if ((*name >= '0') && (*name <= '9')) return 1;

 wrapup:
  return 0;
}

/* -----------------------------------------------
 * Usually called before creating a node
 * to verify valid names
 */
static IGRstat isNodeNameValid(TVDct1JD *parentJD,
			       IGRchar  *nodeType,
			       IGRchar  *nodeName,
			       IGRchar  *results)
{
  VDASSERT_FN("isNodeNameValid");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar *p;
  TVDct1JD findJD;
  
  // Arg check
  VDASSERTW(results); strcpy(results,"Invalid Node Name ");
  VDASSERTW(parentJD && parentJD->cl);
  VDASSERTW(nodeType && *nodeType);
  VDASSERTW(nodeName && *nodeName);
  sprintf(results,"Invalid Node Name %s %s",nodeType,nodeName);
  
  // Say Hi
  if (traceFlag) {  
    printf(">>> %s %s %s %s\n",ffn(),fn,nodeType,nodeName);
  }

  // First character should be a letter or number
  sts = _RTCJDB(parentJD)->isFirstCharOK(parentJD,nodeName);
  if (!(sts & 1)) {
    sprintf(results,"First Character is Invalid %s %s",nodeType,nodeName);
    goto wrapup;
  }
  
  // If don't have an actual parent object then done
  if (parentJD->id.objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  /* ---------------------------------------------
   * Look for dups, by default none are allowed in
   * the entire tree
   */
  sts = _RTCJDB(parentJD)->
    findNodeByTypeName(parentJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       nodeType,nodeName,&findJD);
  if (findJD.id.objid != NULL_OBJID) {
    sprintf(results,"Duplicate  Name %s %s",nodeType,nodeName);
    goto wrapup;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  if (retFlag == 1) *results = 0;
  
  return retFlag;
}

/* -----------------------------------------------
 * Basically checks to see if the to be created node
 * is valid
 *
 * Also checks to see if another set of the same name exists
 *
 * Need a validator for dup options (or maybe use an enum)
 */
static IGRstat isSetNameValid(TVDct1JD *setJD,
			      IGRchar  *setType,
			      IGRchar  *setName,
			      IGRchar  *results)
{
  VDASSERT_FN("isSetNameValid");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctNodeType nodeType;
  TVDct1JD setJDl;
  
  // Arg check
  VDASSERTW(results); 
  strcpy(results,"Invalid Set Name ");
  VDASSERTW(setJD && setJD->cl);
  VDASSERTW(setType);
  VDASSERTW(setName);
  sprintf(results,"Invalid Set Name %s %s",setType,setName);
  
  // Validate setType
  setJDl.cl = VDct1GetTreeClassForSetType(setType);
  VDASSERTW(setJDl.cl);
  
  // Say Hi
  if (traceFlag) {  
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }
  
  // Upper case it
  VDstrupr(setName);
    
  // Clean it
  sts = _RTCJDB(setJD)->cleanName(setJD,setName);
  if (!(sts & 1)) {
    sprintf(results,"Clean Set Name Failed %s",setName);
    goto wrapup;
  }
 
  // First character should be a letter or number
  sts = _RTCJDB(setJD)->isFirstCharOK(setJD,setName);
  if (!(sts & 1)) {
    sprintf(results,"First Character is Invalid %s %s",setType,setName);
    goto wrapup;
  }
  
  // Check for existing sets
  if (traceFlag) {
    printf("Searching for existing set\n");
  }
  sts = _RTCJDB(setJD)->
    findSetByTypeName(setJD,0,VDCT1_FIND_SET_OPT_CUR_FILE,setType,setName,&setJDl);
  if (setJDl.id.objid != NULL_OBJID) {
    sprintf(results,"Duplicate Set Name %s %s",setType,setName);
    goto wrapup;
  }

  /* ---------------------------------------------
   * Actually, this does not work since the set itself
   * does not exist yet and the node name validitor
   * requires an existing set?
   *
   * This will work if you want to check either posted info
   * Or existing sets
   */
  if (traceFlag) {
    printf("Validating node name\n");
  }
  _RTCJDB(setJD)->getRootNodeTypeForSet(setJD,setType,setName,nodeType);
  sts = _RTCJDB(setJD)->isNodeNameValid(setJD,nodeType,setName,results);
  if (!(sts & 1)) goto wrapup;

  // Done
  retFlag  = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  if (retFlag == 1) *results = 0;
  
  return retFlag;
}

/* -----------------------------------------------
 * Compares pairs of name,type
 * based on case flag
 *
 * Return 0 if the same
 */
IGRint sortTypeName(TVDct1JD *nodeJD,
		    IGRint    isCaseSensitive,
		    IGRchar  *type1,
		    IGRchar  *type2,
		    IGRchar  *name1,
		    IGRchar  *name2)
{
  VDASSERT_FN("compareTypeName");
  IGRint retFlag = 0;
  IGRint sts;
  
  IGRchar buf1[64],buf2[64];
  
  // Arg check
  VDASSERTW(nodeJD);
  VDASSERTW(type1);
  VDASSERTW(type2);
  VDASSERTW(name1);
  VDASSERTW(name2);

  // Quick compare if case sensitive
  if (isCaseSensitive) {
    sts = strcmp(type1,type2);
    if (sts) return sts;
    sts = strcmp(name1,name2);
    if (sts) return sts;
    return 0;
  }
  
  // Type
  strcpy  (buf1,type1);
  strcpy  (buf2,type2);
  VDstrupr(buf1);
  VDstrupr(buf2);
  sts = strcmp(buf1,buf2);
  if (sts) return sts;
  
  // Name
  strcpy  (buf1,name1);
  strcpy  (buf2,name2);
  VDstrupr(buf1);
  VDstrupr(buf2);
  sts = strcmp(buf1,buf2);
  if (sts) return sts;

 wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Search for a node by attribute value from
 * current node down
 */
IGRstat findNodeByAttrValue(TVDct1JD *nodeJD,
			    IGRchar  *attrName,
			    IGRchar  *attrValue,
			    TVDct1JD *foundJD)
{
  VDASSERT_FN("findNodeByAttrValue");
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint i;
    
  TVDct1JD childJD;
  
  IGRchar workAttrValue[64];
  
  
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(attrName && *attrName);
  VDASSERTW(attrValue && *attrValue);
  VDASSERTW(foundJD);
  foundJD->id.objid = NULL_OBJID;
  foundJD->cl = nodeJD->cl;
  
  // say hi
  if (traceFlag) printf(">>> %s %s %s %s\n",ffn(),fn,attrName,attrValue);
  
  // check the current node
  *workAttrValue = 0;
  sts = _RTCJDB(nodeJD)->getAttr(nodeJD,attrName,workAttrValue);
  //if (!(sts & 1)) goto wrapup;
  if (*workAttrValue != 0) {
      if (!strcmp(attrValue,workAttrValue)) {
	  *foundJD = *nodeJD;
	  retFlag = 1;
	  goto wrapup;
      }
  }
  // now do the kids
  for (i = 0 ; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD) ; i++) {

   sts =  _RTCJDB(&childJD)->
     findNodeByAttrValue(&childJD,attrName,attrValue,foundJD);
   
   if (foundJD->id.objid != NULL_OBJID) {
     retFlag = 1;
     goto wrapup;
   }

  }
  
  // done
      
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Search for a node by type and name
 */
IGRstat findNodeByTypeName(TVDct1JD *nodeJD,
			   IGRint    isCaseSensitive,
			   IGRint    opt,
			   IGRchar  *nodeType,
			   IGRchar  *nodeName,
			   TVDct1JD *foundJD)
{
  VDASSERT_FN("findNodeByTypeName");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo baseInfo;
  TVDct1JD      workJD;
  IGRint        i;
  
  // Arg check
  VDASSERTW(foundJD);
  foundJD->id.objid = NULL_OBJID;
  VDASSERTW(nodeJD && nodeJD->cl);
  foundJD->cl = nodeJD->cl;
  VDASSERTW(nodeType && *nodeType);
  VDASSERTW(nodeName && *nodeName);
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s %d %d %s %s\n",
	   ffn(),fn,isCaseSensitive,opt,nodeType,nodeName);
  }
  
  // Checkout the args
  switch(opt) {

    /* -----------------------------------------
     * Says no match at all
     */
    case VDCT1_FIND_NODE_OPT_NONE:
      goto wrapup;
      
    /* ----------------------------------------
     * Start at the top and work down
     */
    case VDCT1_FIND_NODE_OPT_ENTIRE_TREE:

      // Get the tree
      VDASSERTW(nodeJD->id.objid != NULL_OBJID);
      _RTCJDB(nodeJD)->getRootForNode(nodeJD,&workJD);
      VDASSERTW(workJD.id.objid != NULL_OBJID);
      
      // Recurse using entire tree
      _RTCJDB(&workJD)->findNodeByTypeName(&workJD,isCaseSensitive,
					   VDCT1_FIND_NODE_OPT_NODE_DOWN,
					   nodeType,nodeName,foundJD);
      if (foundJD->id.objid == NULL_OBJID) goto wrapup;
      retFlag = 1;
      goto wrapup;

    /* ----------------------------------------
     * Just check the current node
     */
    case VDCT1_FIND_NODE_OPT_NODE_CUR:

      // Just check against my self
      VDASSERTW(nodeJD->id.objid != NULL_OBJID);
      _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
      sts = _RTCJDB(nodeJD)->sortTypeName(nodeJD,isCaseSensitive,
					  baseInfo.nodeType,nodeType,
					  baseInfo.nodeName,nodeName);
      // 0 Means matched
      if (!sts) {
	*foundJD = *nodeJD;
	retFlag  = 1;
	goto wrapup;
      }
      goto wrapup;
      
    /* ----------------------------------------
     * Check everything from this node down
     */
    case VDCT1_FIND_NODE_OPT_NODE_DOWN:

      // Check current node
      VDASSERTW(nodeJD->id.objid != NULL_OBJID);
      _RTCJDB(nodeJD)->findNodeByTypeName(nodeJD,isCaseSensitive,
					  VDCT1_FIND_NODE_OPT_NODE_CUR,
					  nodeType,nodeName,foundJD);
      if (foundJD->id.objid != NULL_OBJID) {
	retFlag = 1;
	goto wrapup;
      }

      // Cycle through kids
      for(i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&workJD); i++) {
	_RTCJDB(&workJD)->findNodeByTypeName(&workJD,isCaseSensitive,
					     VDCT1_FIND_NODE_OPT_NODE_DOWN,
					     nodeType,nodeName,foundJD);
	if (foundJD->id.objid != NULL_OBJID) {
	  retFlag = 1;
	  goto wrapup;
	}
      }
      goto wrapup;
        
    /* ----------------------------------------
     * Current node and immediate kids
     */
    case VDCT1_FIND_NODE_OPT_NODE_KIDS:

      VDASSERTW(nodeJD->id.objid != NULL_OBJID);
      _RTCJDB(nodeJD)->findNodeByTypeName(nodeJD,isCaseSensitive,
					  VDCT1_FIND_NODE_OPT_NODE_CUR,
					  nodeType,nodeName,foundJD);
      if (foundJD->id.objid != NULL_OBJID) {
	retFlag = 1;
	goto wrapup;
      }

      // Cycle through kids
      for(i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&workJD); i++) {
	_RTCJDB(&workJD)->findNodeByTypeName(&workJD,isCaseSensitive,
					     VDCT1_FIND_NODE_OPT_NODE_CUR,
					     nodeType,nodeName,foundJD);
	if (foundJD->id.objid != NULL_OBJID) {
	  retFlag = 1;
	  goto wrapup;
	}
      }
      goto wrapup;
      
    /* ----------------------------------------
     * Not currently supported
     */
   default: 
      VDASSERTW(NULL);
  }
  
  // Nothing should drop out of above switch
  VDASSERTW(NULL);
  
  // Done
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Search for a set by type and name
 * Mainly for checking for dup sets for now
 */
IGRstat findSetByTypeName(TVDct1JD *nodeJD,
			  IGRint    isCaseSensitive,
			  IGRint    opt,
			  IGRchar  *setType,
			  IGRchar  *setName,
			  TVDct1JD *foundJD)
{
  VDASSERT_FN("findSetByTypeName");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo baseInfo;
  TVDct1JD searchJD;
  TVDct1JD mgrJD;
  IGRint   i;
  
  // Arg check
  VDASSERTW(foundJD);
  foundJD->id.objid = NULL_OBJID;
  VDASSERTW(nodeJD && nodeJD->cl);
  foundJD->cl = nodeJD->cl;
  VDASSERTW(setType && *setType);
  VDASSERTW(setName && *setName);
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s %d %d %s %s\n",
	   ffn(),fn,isCaseSensitive,opt,setType,setName);
  }
  
  // Checkout the args
  switch(opt) {
    case VDCT1_FIND_SET_OPT_CUR_SET:

      /* This asks if nodeJD belongs to the set being searched */
      _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
      sts = 
	_RTCJDB(nodeJD)->sortTypeName(nodeJD,
				      isCaseSensitive,
				      baseInfo.setType,setType,
				      baseInfo.setName,setName);
      if (sts) goto wrapup;
      
      // Get the actual set id
      _RTCJDB(nodeJD)->getSetForNode(nodeJD,foundJD);
      VDASSERTW(foundJD->id.objid != NULL_OBJID);
      retFlag = 1;
      goto wrapup;
      
    case VDCT1_FIND_SET_OPT_ALL_FILES:
      /* Recurse all os's */
      searchJD = *nodeJD;
      for(searchJD.id.osnum = 0; VDosValidate(searchJD.id.osnum); searchJD.id.osnum++) {

	sts = _RTCJDB(&searchJD)->
	  findSetByTypeName(&searchJD,
			    isCaseSensitive,
			    VDCT1_FIND_SET_OPT_CUR_FILE,
			    setType,setName,foundJD);
	if (sts & 1) {
	  retFlag = 1;
	  goto wrapup;
	}
      }
      // Not Found
      goto wrapup;
      
  case VDCT1_FIND_SET_OPT_CUR_FILE:
      /* Search Current File */
    break;
    
  case VDCT1_FIND_SET_OPT_NONE:
    goto wrapup;
    
   default: 
      /* Invalid search option */
      VDASSERTW(NULL);
  }
  
  // The only thing that drops out of the switch is cur file
  VDASSERTW(opt == VDCT1_FIND_SET_OPT_CUR_FILE);
  if (traceFlag) {
    printf("Searching os %d\n",nodeJD->id.osnum);
  }
  
  // Search set in specified os
  mgrJD = *nodeJD;
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  if (mgrJD.id.objid == NULL_OBJID) goto wrapup;
  
  // Cycle through each set
  for(i = 0; 
      _RTCJDB(&mgrJD)->getMgrChild(&mgrJD,i,&searchJD);
      i++) {
	
    // Filter by set type
    _RTCJDB(&searchJD)->getBaseInfo(&searchJD,&baseInfo);
    if (traceFlag) {  
      printf("Compare %s %s\n",baseInfo.setType,baseInfo.setName);
    }
    sts = _RTCJDB(&searchJD)->sortTypeName(&searchJD,
					   isCaseSensitive,
					   baseInfo.setType,setType,
					   baseInfo.setName,setName);
    // 0 Means matched
    if (!sts) {
      *foundJD = searchJD;
      retFlag  = 1;
      goto wrapup;
    }
  }
  
  // Done
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Thin wrapper tofindSet, pull the top node
 * from the set
 */
IGRstat findTreeByTypeName(TVDct1JD *nodeJD,
			   IGRint    isCaseSensitive,
			   IGRint    opt,
			   IGRchar  *setType,
			   IGRchar  *setName,
			   TVDct1JD *foundJD)
{
  VDASSERT_FN("findTreeByTypeName");
  IGRstat retFlag = 0;
  IGRstat sts;
  TVDct1JD setJD;
  
  // Arg check
  VDASSERTW(nodeJD);
  sts = _RTCJDB(nodeJD)->findSetByTypeName(nodeJD,
					   isCaseSensitive,
					   opt,
					   setType,
					   setName,
					   foundJD);
  if (!(sts & 1)) goto wrapup;

  // The tree is just the first child
  setJD = *foundJD;
  _RTCJDB(&setJD)->getNodeForSet(&setJD,foundJD);
  
  // Just to be sure
  VDASSERTW(foundJD->id.objid != NULL_OBJID);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}



/* -----------------------------------------------
 * Inits the root
 * mainly to default function pointers
 */
IGRstat VDct1InitRootTreeClass(TVDct1RootTreeClass *cl)
{
  VDASSERT_FN("VDct1InitRootTreeClass");
  
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cl);
  
  // Turn tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_BASE);
  
  // Clear it
  memset(cl,0,sizeof(TVDct1RootTreeClass));

  // Class info
  strcpy(cl->base.className,VDCT1_CLASSN_ROOT_TREE);
  cl->base.classID        = VDCT1_CLASSI_ROOT_TREE;
  
  // Init the info
  strcpy(cl->base.info.type,"RootTree");
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Root Tree");

  // Fill up pointers
  cl->base.hello           = hello;
  cl->base.getFilter       = getFilter;

  cl->base.getSetTypeInfo  = getSetTypeInfo;
  cl->base.getNodeTypeInfo = getNodeTypeInfo;
  cl->base.getNodeAttrName = getNodeAttrName;
  cl->base.getNodeAttrInfo = getNodeAttrInfo;

  cl->base.setNodeInfo             = setNodeInfo;
  cl->base.getNodeInfo             = getNodeInfo;
  cl->base.setNodeInfos            = setNodeInfos;
  cl->base.getNthInfoFromNodeInfos = getNthInfoFromNodeInfos;
    
  cl->base.createSet       = createSet;
  cl->base.createNode      = createNode;
  
  cl->base.isChildTypeValid = isChildTypeValid;

  cl->base.preExpandContractNode = preExpandContractNode;

  cl->base.isSetNameValid  = isSetNameValid;
  cl->base.isNodeNameValid = isNodeNameValid;
  cl->base.cleanName       = cleanName;
  cl->base.isFirstCharOK   = isFirstCharOK;

  cl->base.getRootNodeTypeForSet = getRootNodeTypeForSet;

  cl->base.findSetByTypeName     = findSetByTypeName;
  cl->base.findTreeByTypeName    = findTreeByTypeName;
  cl->base.findNodeByTypeName    = findNodeByTypeName;
  cl->base.sortTypeName          = sortTypeName;
  cl->base.findNodeByAttrValue   = findNodeByAttrValue;
  cl->base.updateNodesOnTree     = updateNodesOnTree;
  cl->base.reComputeNode         = reComputeNode;
  cl->base.reComputeStdAssy      = reComputeStdAssy;
  cl->base.verifyModelAttrs      = verifyModelAttrs;
  cl->base.markNodeAsDeleted     = markNodeAsDeleted;
  cl->base.markNodeAsActive      = markNodeAsActive;
  cl->base.deleteMarkedNodes     = deleteMarkedNodes;
  
  // More in other file
  VDct1InitRootTreeClass2(cl);
  VDct1InitRootTreeClassC(cl);
  VDct1InitRootTreeClassX(cl);
  VDct1InitModel(cl);
  VDct1InitRootTreeClassP(cl);
  VDct1InitRootTreeClassM(cl);
    

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Copies the various root implementations
 * down to a derived class, makes it easier to add
 * new implementations
 */
IGRstat VDct1CopyRootImps(void *a_parent, void *a_child)
{
  VDASSERT_FN("VDct1CopyRootImps");
  
  IGRstat retFlag = 0;
  
  TVDct1RootTreeClass *parent = a_parent;
  TVDct1RootTreeClass *child  = a_child;
  
  // Arg check
  VDASSERTW(parent);
  VDASSERTW(child);
  
  // Mostly just a copy
  child->base = parent->base;
  child->cmd  = parent->cmd;
  child->xml  = parent->xml;
  
  // Adjust parent class pointer
  child->base.parentCL = parent;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

