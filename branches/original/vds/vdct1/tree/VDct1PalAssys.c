 /* $Id: VDct1PalAssys.c,v 1.7 2002/01/07 18:53:39 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1PalAssys.I
 *
 * Description: Pallet Assembly Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1PalAssys.c,v $
 *      Revision 1.7  2002/01/07 18:53:39  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.6  2001/11/05 16:12:56  jdsauby
 *      JTS CR MP 5646 -jds
 *
 *      Revision 1.5  2001/10/29 17:06:25  jdsauby
 *      JTS TR 5677 -jds
 *
 *      Revision 1.4  2001/05/14 20:49:38  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.3  2001/03/09 19:31:38  jdsauby
 *      TR 4841, CRs 4847 (paint attribute), 4850 (Clean up node commands)
 *
 *      Revision 1.2  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.16  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * Revision 1.15  2000/10/24  14:04:42  pinnacle
 * js
 *
 * Revision 1.14  2000/10/11  20:29:26  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDobj2.h" 
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDos.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDctx.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"
#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/tree/VDct1PalAssys.C");

#define MY_TREE VDCT1_TREE_TYPE_PAL_ASSYS

/* ----------------------------------------------------
 * helper to computeProductionNode
 * searches all trees to find the tree with the given tree number
 * **/
static IGRstat getEngTreeForTreeNum(IGRchar  *a_tree_num,
	                            TVDct1JD *treeJD)
{
    VDASSERT_FN("getEngTreeForTreeNum");

    IGRstat retFlag = 0;
    IGRstat sts;
    VDosnum osnum;
    TGRid mgrID,setID;
    TVDct1JD nodeJD;
    IGRchar  tree_num[80];
  
    IGRint  i;

    // init
    mgrID.objid = NULL_OBJID;
    setID.objid = NULL_OBJID;
    nodeJD.cl   = NULL;

    // arg check
    VDASSERTW(a_tree_num && *a_tree_num);
    VDASSERTW(treeJD); treeJD->id.objid = NULL_OBJID;

    
    // loop through the valid osnum s
    for (osnum = 0; VDosValidate(osnum); osnum++)
    {

	retFlag = 1;

	// Get the manager
	VDct1GetManager(osnum,&mgrID);
	if (mgrID.objid != NULL_OBJID) 
	{

	    // Cycle Through
	    for(i = 0; VDctxGetNthMgrChild(&mgrID,i,&setID); i++) {
		
		// get some class
		nodeJD.cl = VDct1GetTreeClassForNode(&setID);
		if (nodeJD.cl == NULL) goto wrapup;
		nodeJD.id = setID;

		// what is the tree_num attribute
		VDjt1GetAttr(&nodeJD,VDCT1_ATTR_TREE_NUM,tree_num);
		if (!strcmp(a_tree_num,tree_num))
		{
		    *treeJD = nodeJD;
		    goto wrapup;
		}

	    }
	}
    }

wrapup:
  return retFlag;
}


/* -----------------------------------------------------
 * helper to reComputeNode, computes a palassy node by re-copying
 * attributes from the eng tree node, to the current node
 * **/
static IGRstat computeProductionNode(TVDct1JD *nodeJD)
{
    VDASSERT_FN("computeProductionNode");

    IGRstat retFlag = 1;
    IGRstat sts;

    TVDct1JD       engTreeJD;
    TVDct1JD       engNodeJD;
    TVDctBaseInfo  baseInfo;
    IGRchar        node_num[80];
    IGRchar        tree_num[80];

    // init
    engTreeJD.id.objid = NULL_OBJID;
    engNodeJD.id.objid = NULL_OBJID;
    *node_num          = 0;
    *tree_num          = 0;

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);

    // get the baseInfo of the current node
    VDjt1GetBaseInfo(nodeJD,&baseInfo);
    if (*baseInfo.nodeType == 0) goto wrapup;

    // if it is a PAL_GROUP or PALLET, or PALASSYS, no recomputing will be done
    if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALLET))     ) goto wrapup;

    // get tree_num and node_num attributes
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_TREE_NUM,tree_num);
    if (*tree_num == 0) goto wrapup;
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_NODE_NUM,node_num);
    if (*node_num == 0) goto wrapup;

    // find the engTree with the same tree_num
    getEngTreeForTreeNum(tree_num,&engTreeJD);
    if (engTreeJD.id.objid == NULL_OBJID) {
	retFlag = 0;
	printf("*** ERROR: Engineering Tree Not Found (Attached) ***\n");
	goto wrapup;
    }

    // find the eng node from the eng tree that was originally used.
    _RTCJDB(&engTreeJD)->findNodeByAttrValue(&engTreeJD,
	                                      VDCT1_ATTR_NODE_NUM,
					      node_num,
					     &engNodeJD);
    if (engNodeJD.id.objid == NULL_OBJID)
    {
	// mark nodeJD as deleted
	VDjt1SetAttr(nodeJD,VDCT1_ATTR_FROZEN,VDCT1_DEFAULT_FROZEN_D);
    }
    else
    {
	// copy the attributes
	_RTCJDC(nodeJD)->copyNodeAttributes(nodeJD,&engNodeJD);
    }

    // done

wrapup:
    return retFlag;
}

    

static IGRstat reComputeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("reComputeNode");

  IGRstat        retFlag = 0;
  TVDct1JD       childJD;
  IGRint         i;
  IGRstat        sts;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // compute the production node
  sts = computeProductionNode(nodeJD);
  if (!(sts & 1)) goto wrapup;

  // do the kids
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
      _RTCJDB(&childJD)->reComputeNode(&childJD);

  }

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}


/* ----------------------------------------------------
 * get the pallet code value from the parent PALLET node
 * **/
static IGRstat getPalletFromParentPallet(TVDct1JD *nodeJD,
	                                 IGRchar  *value)
{
    VDASSERT_FN("getPalletFromParentPallet");
    IGRstat retFlag = 0;

    IGRstat        sts;
    TVDct1JD       parentJD;
    TVDctBaseInfo  baseInfo;
    TGRid          nodeID,parentID;
    TVDfld         palFld;

    // arg check
    VDASSERTW(nodeJD && nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(value); *value = 0;

    // init
    nodeID.osnum = nodeJD->id.osnum;
    nodeID.objid = nodeJD->id.objid;
    parentJD.cl = nodeJD->cl;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the parent
    VDctxGetTreeParent(&nodeID,&parentID);
    if (parentID.objid == NULL_OBJID) goto wrapup;

    parentJD.id.osnum = parentID.osnum;
    parentJD.id.objid = parentID.objid;

    // get the baseInfo of the parent
    VDjt1GetBaseInfo(&parentJD,&baseInfo);
    if (*baseInfo.nodeType == 0) goto wrapup;


    // if it is the PAL_ASSYS tree, get out of here
    if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) goto wrapup;

    // if it is a PALLET, get the attribute and be done
    if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALLET))
    {
	// get the attribute
	VDctxGetAttr(&parentID,VDCT1_ATTR_PALLET,&palFld);
	if(*palFld.name != 0) {
	    strcpy(value,palFld.val.txt);
	    retFlag = 1;
	    goto wrapup;
	}
    }
    else {
	// call this again.
	getPalletFromParentPallet(&parentJD,value);
    }

    // done
wrapup:
    return retFlag;
}
	

    

/* --------------------------------------------------
 * Default treeIndex 
 * set tree_index = "000000-000000-000"
 */
static IGRstat getTreeIndex(TVDct1JD *nodeJD, IGRchar *treeIndex)
{
  VDASSERT_FN("getTreeIndex");
  IGRstat retFlag = 0;
  IGRstat sts;
  TVDfld  treeFld,nodeFld,revFld;
  IGRchar treeNum[128],nodeNum[128],revNum[128];
  TGRid   nodeID,parentID,treeID;
  
  
    // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  /* args check */
  VDASSERTW(nodeJD);
  VDASSERTW(treeIndex);

  /* inits */
  strcpy(treeNum,"000000");
  strcpy(nodeNum,"000000");
  strcpy(revNum,"000");
  treeIndex[0] = '\0';
  
  /* get the attributes */
  VDctxGetAttr(&nodeJD->id,VDCT1_ATTR_TREE_NUM,&treeFld);
  if(*treeFld.name != 0) {
    strcpy(treeNum,treeFld.val.txt);
  }
  

  VDctxGetAttr(&nodeJD->id,VDCT1_ATTR_NODE_NUM,&nodeFld);
  if(*nodeFld.name != 0) {
    strcpy(nodeNum,nodeFld.val.txt);
  }
  
  
  VDctxGetAttr(&nodeJD->id,VDCT1_ATTR_ASSY_REV,&revFld);
  if(*revFld.name == 0) {
    /* go up and get the parentID and etc */
    nodeID.osnum = nodeJD->id.osnum;
    nodeID.objid = nodeJD->id.objid;
    VDctxGetTree(&nodeID,&treeID);
    while (nodeID.objid != treeID.objid) {
      VDctxGetTreeParent(&nodeID,&parentID);
      if(parentID.objid == NULL_OBJID) break;
      VDctxGetAttr(&parentID,VDCT1_ATTR_ASSY_REV,&revFld);
      if(*revFld.name != 0) break;
      nodeID = parentID;
    }
  }
  
  if(*revFld.name != 0) {
    strcpy(revNum,revFld.val.txt);
   }

  /* copy out the results */
  sprintf(treeIndex,"%s-%s-%s",treeNum,nodeNum,revNum);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}




/* -----------------------------------------------
 * Utility routine to get value of one attribute
 * Returns false if not found 
 */
static IGRstat getAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
    VDASSERT_FN("getAttr"); 
    IGRstat retFlag = 0;
    
    TVDfld         fld;
    TGRid          parentID,nodeID;
    TVDct1JD       parentJD;
    TVDctBaseInfo  baseInfo;
   
    VDASSERTW(nodeJD);
    if(nodeJD->id.objid == NULL_OBJID) goto wrapup;
    nodeID.osnum = nodeJD->id.osnum;
    nodeID.objid = nodeJD->id.objid;
    parentJD.cl = nodeJD->cl;

    // need the baseInfo of the nodeJD
    VDjt1GetBaseInfo(nodeJD,&baseInfo);
    if (*baseInfo.nodeType == 0) goto wrapup;
    
    // treat special attributes for nodetypes not equal to
    // PALLET, PAL_GROUP, or PAL_ASSYS
    if ( (strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) &&
	 (strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) &&
	 (strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALLET)) )
    {

	// Get it for tree index
	if(!strcmp(name,VDCT1_ATTR_TREE_INDEX)) {
	    retFlag = getTreeIndex(nodeJD,value);
	    goto wrapup;
	}

	// get it for parent tree index
	if(!strcmp(name,VDCT1_ATTR_PARENT_INDEX)) {
	    VDctxGetTreeParent(&nodeID,&parentID);
	    if(parentID.objid != NULL_OBJID) {
		parentJD.id.osnum = parentID.osnum;
		parentJD.id.objid = parentID.objid;
		if(value) {
		    retFlag = getTreeIndex(&parentJD,value);
		    goto wrapup;
		}
	    }
	}

	// get it for pallet code
	if(!strcmp(name,VDCT1_ATTR_PALLET)) {
	    retFlag = getPalletFromParentPallet(nodeJD,value);
	    goto wrapup;
	}
	    
    }

    // Just get it then
    VDctxGetAttr(&nodeJD->id,name,&fld);
    if (*fld.name == 0) goto wrapup;
    
    // Update
    if (value) strcpy(value,fld.val.txt);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}


/* ------------------------------------------------------------------
 * Update the nodes on my tree
 * **/
static IGRstat updateNodesOnTree(TVDct1JD *nodeJD)
{
  VDASSERT_FN("updateNodesOnTree");

  IGRstat        retFlag = 0;
  TVDctBaseInfo  baseInfo;
  TVDctAttrInfo  attrInfo;
  TVDct1JD       parentClassJD;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // get base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD, &baseInfo); 


  // For all but group, need a model_id attribute
  if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART))    ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ||
       (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6))  )  {
      
      // Get the full info for model_id
      VDjt1GetNodeAttrInfo(nodeJD,VDCT1_ATTR_MODEL_ID,&attrInfo);
      VDASSERTW(*attrInfo.name);
    
      VDjt1CreateAttr(nodeJD,attrInfo.name,attrInfo.type,"");
  }

  // call the ancestor next
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->updateNodesOnTree(nodeJD);

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;

}

/* ------------------------------------------------
 * For auto paste and create node, this is a filter for
 * weeding out any type of node in nodeInfo
 */
static IGRstat isNodeInfoForPasteValid(TVDct1JD       *parentJD,
				       TVDct1NodeInfo *nodeInfo)
{
  VDASSERT_FN("isNodeInfoForPasteValid");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo  parentBaseInfo;
  
  VDASSERTW(parentJD);
  VDASSERTW(nodeInfo);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // if the node is not valid to go under a pallet, then it is not valid
  if ((strcmp(nodeInfo->info.nodeType,VDCT1_ENG_NODE_TYPE_PART)) &&
      (strcmp(nodeInfo->info.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) &&
      (strcmp(nodeInfo->info.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) )    goto wrapup;
  
  // if its parent is an EA2 or ASSY2, then the recursive copy will take care of it
  _RTCJDB(&nodeInfo->parentJD)->getBaseInfo(&nodeInfo->parentJD,&parentBaseInfo);
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
  
  // the rest are OK
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}


/* ------------------------------------------------------
 * helper function for getNewParentForPastedNode
 * it does it for outfit
 */
static IGRstat getNewParentForOutfitNode(TVDct1JD *parentJD,
					 TVDct1JD *copiedJD,
					 TVDct1JD *newParentJD)
{
  VDASSERT_FN("getNewParentForOutfitNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo baseInfo;
  
  VDASSERTW(parentJD->cl != NULL);
  VDASSERTW(copiedJD);
  VDASSERTW(newParentJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Not sure how to do this yet
  *newParentJD = *parentJD;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  return retFlag;
}

/* ------------------------------------------------------
 * helper function for getNewParentForPastedNode
 * it does it for electrical.  The pallet_code is set for 
 * all Electrical stuff, based on the setElecPalletCode routine
 * in VDct1EngTree.C.  Our goal in this routine is to create a group
 * based on the pallet group attribute, then create a pallet from the
 * pallet code attribute.  The end result of this function will
 * be a pallet as the parent.
 */
static IGRstat getNewParentForElecNode(TVDct1JD *parentJD,
				       TVDct1JD *copiedJD,
				       TVDct1JD *newParentJD)
{
  VDASSERT_FN("getNewParentForElecNode");
  
  // -------Variable Declaration-----------
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo baseInfo;

  IGRchar  palletCode [24];
  IGRchar  palletGroup[24];

  TVDct1JD workParentJD;
  TVDct1JD rootJD;
  
  IGRint   isCase = 0;
        
  // --------ASSERT-------------------------
  VDASSERTW(parentJD->cl != NULL);
  VDASSERTW(copiedJD);
  VDASSERTW(newParentJD);
  
  // --------say hi------------------------
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // --------init--------------------------
  *palletGroup          = 0;
  *palletCode           = 0;
  workParentJD.id.objid = NULL_OBJID;
  newParentJD->id.objid = NULL_OBJID;
    
  // We need pallet_code and pallet_group from the copiedJD
  if (traceFlag) {
    _RTCJDB(copiedJD)->getBaseInfo(copiedJD,&baseInfo);
    printf("### copied Node: %s %s\n",baseInfo.nodeType,baseInfo.nodeName);
  }
  
  _RTCJDB(copiedJD)->getAttr(copiedJD,VDCT1_ATTR_PALLET,palletCode);
  if (*palletCode == 0) strcpy(palletCode,"NOT COMPUTED");
  
  _RTCJDB(copiedJD)->getAttr(copiedJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
  if (*palletGroup == 0) strcpy(palletGroup,"NULL PAL GROUP");
  
  // Search entire tree for a PAL_GROUP with the name palletGroup
  _RTCJDB(parentJD)->findNodeByTypeName(parentJD,isCase,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
					VDCT1_ENG_NODE_TYPE_PALGROUP,palletGroup,&workParentJD);
  
  // if a PALGROUP node is not found, create it under tree top
  if (workParentJD.id.objid == NULL_OBJID) {
    
    // get root node
    _RTCJDB(parentJD)->getRootForNode(parentJD,&rootJD);
    if (rootJD.id.objid == NULL_OBJID) goto wrapup;

    // create the node
    _RTCJDB(&rootJD)->
      createNode(&rootJD,VDCT1_ENG_NODE_TYPE_PALGROUP,palletGroup,&workParentJD);

    // set the Pal_group attribute
    _RTCJDB(&workParentJD)->setAttr(&workParentJD,VDCT1_ATTR_PAL_GROUP,palletGroup);
    
  }
  // should have a PALGROUP node by now
  VDASSERTW(workParentJD.id.objid != NULL_OBJID);
  
  // Search from PALGROUP node down for a PALLET
  _RTCJDB(&workParentJD)->findNodeByTypeName(&workParentJD,isCase,VDCT1_FIND_NODE_OPT_NODE_DOWN,
					     VDCT1_ENG_NODE_TYPE_PALLET,palletCode,newParentJD);
  
  // if not found, create it
  if (newParentJD->id.objid == NULL_OBJID) {
    
    // create it
    _RTCJDB(&workParentJD)->
      createNode(&workParentJD,VDCT1_ENG_NODE_TYPE_PALLET,palletCode,newParentJD);

    // set the pallet_code attribute
    _RTCJDB(newParentJD)->setAttr(newParentJD,VDCT1_ATTR_PALLET,palletCode);
    
  }
  
  // should now have our newParentJD
  VDASSERTW(newParentJD->id.objid != NULL_OBJID);
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  return retFlag;
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
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo baseInfo;
  
  VDASSERTW(parentJD->cl != NULL);
  VDASSERTW(copiedJD);
  VDASSERTW(newParentJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // It all depends on the setType of the copiedJD
  _RTCJDB(copiedJD)->getBaseInfo(copiedJD,&baseInfo);
  if (baseInfo.setType == NULL) goto wrapup;
  
  // source setType = WWAY_TREE and CABLE_TREE
  if ( (!strcmp(baseInfo.setType,VDCT1_TREE_TYPE_CABLE_TREE)) ||
       (!strcmp(baseInfo.setType,VDCT1_TREE_TYPE_WWAY_TREE)) ) {
    return getNewParentForElecNode(parentJD,copiedJD,newParentJD);
  }
  
  if ( !strcmp(baseInfo.setType,VDCT1_TREE_TYPE_OUTFIT_TREE) ) {
    return getNewParentForOutfitNode(parentJD,copiedJD,newParentJD);
  }
  
  // anything else
  *newParentJD = *parentJD;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ----------------------------------------------
 * check to see if creation of a tree is valid
 */
static IGRstat isCreateTreeValid(TVDct1JD *setJD,
				 IGRchar  *setType)
{
  VDASSERT_FN("isCreateTreeValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar pdm_catalog[64];

  TVDpdmInfo pdmInfo;
  
  VDASSERTW(setJD);
  VDASSERTW(setType != NULL);
  
  // say hi
  if (traceFlag) printf(">>> %s %s %s\n",ffn(),fn,setType);
  
  // get pdm_catalog of active file
  *pdmInfo.catalog = 0;
  
  VDpdmGetPdmInfo(OM_K_NOT_AN_OS,&pdmInfo);
  if (*pdmInfo.catalog == 0) {
    // not a pdm managed file, so access is OK
    retFlag = 1;
    goto wrapup;
  }
  
  strcpy(pdm_catalog,pdmInfo.catalog);
  if (traceFlag) printf("### pdm_catalog = %s\n",pdm_catalog);
  
  
  // Check the access from file tm_access.tbl
  sts = VDct1IsCreateTreeAccessAllowed(setType,pdm_catalog);
  if (!(sts & 1)) goto wrapup;
  
  // done
  retFlag = 1;
    
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * check to see if deletion of a tree is valid
 */
static IGRstat isDeleteTreeValid(TVDct1JD *treeJD)
{
  VDASSERT_FN("isDeleteTreeValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD  rootJD;
  TVDct1JD  fakeJD;

  TVDctBaseInfo baseInfo;
      
  VDASSERTW(treeJD->id.objid != NULL_OBJID);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // make sure we have the top node of the tree
  _RTCJDB(treeJD)->getRootForNode(treeJD,&rootJD);
  if (rootJD.id.objid == NULL_OBJID) goto wrapup;
  
  // If access to create a tree is not allowed, then deleting a tree is
  // probably not allowed for the same reason.

  // need baseInfo.setType
  _RTCJDB(&rootJD)->getBaseInfo(&rootJD,&baseInfo);
  if (baseInfo.setType == NULL) goto wrapup;
  if (traceFlag) printf("BaseInfo.setType = %s\n",baseInfo.setType);
  
  
  sts = _RTCJDC(&rootJD)->isCreateTreeValid(&rootJD,baseInfo.setType);
  if (!(sts & 1)) goto wrapup;
  
  // need a fakeJD for delete node valid
  fakeJD = rootJD;
  
  // No actual rules for deleting a tree, but if the tree contains
  // nodes which cannot be deleted, then the tree should not be
  // deleted.
  retFlag = _RTCJDC(&rootJD)->isDeleteNodeValid(&rootJD,&fakeJD);
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------------
 * Determine type of node to create duing copy operation
 *
 * I - copyJD copyBaseInfo              Node being copied
 * I - parentJD parentBaseInfo          Parent where node is to be copied
 *
 * O - info - Node Type to create
 *
 * This is really only for transformations, calling routine will
 * ensure that if this fails then a valid node type does exists
 */
static IGRstat getPasteNodeType(TVDct1JD          *parentJD, 
				TVDct1JD          *copyJD,
				TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getPasteNodeType");
  
  IGRstat          retFlag = 0;
  TVDctBaseInfo    parentBaseInfo;
  TVDctBaseInfo    copyBaseInfo;
  IGRstat          sts;
    
  TVDct1JD         parentClassJD;

  //Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  //Arg check
  VDASSERTW(&parentJD);
  VDASSERTW(&copyJD);
  
  // Get base info of objects
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (*parentBaseInfo.nodeType == 0) goto wrapup;
  
  _RTCJDB(copyJD)->getBaseInfo(copyJD,&copyBaseInfo);
  if (*copyBaseInfo.nodeType == 0) goto wrapup;

  if (traceFlag) {
    printf ("parentBaseInfo.nodeType = %s\n",parentBaseInfo.nodeType);
    printf ("copyBaseInfo.nodeType   = %s\n",copyBaseInfo.nodeType);
  }
  
  //Do it
  // STD_ASSY and STD_ASSY[2] convert to ASSY_TYPE[2]
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    goto wrapup;
  }
   
  // STD_PART and STD_PART[4] convert to PART
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    goto wrapup;
  }
   
  // STD_ASSY[6] converts to ENGR_ASS[6]
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6)) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    goto wrapup;
  }

  // Everything else converts as is
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDC(&parentClassJD)->getPasteNodeType(parentJD,copyJD,info);
 
  //Done
 
  
wrapup:
  if (traceFlag) printf("<<< %s %s [%s]\n",ffn(),fn,info->type);
  return 1;
}


/* -----------------------------------------------
 * Creates node under parent based on DB query
 * creates pallets based on query from tm_pallet_codes table
 */

static IGRstat createNodeByQuery(TVDct1JD  *parentJD)
{
  VDASSERT_FN("createNodeByQuery");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDfld  AvHull, Zone, Unit, LaborCode, ComptNum, SpecialCode;

  IGRchar  sqlValue[30];
  IGRchar  sqlLaborValue[30];
  
  IGRchar  sqlString[256];
  IGRchar  sqlStringAdd[256];
  
  IGRchar  sqlFld[30];
  IGRchar  sqlLaborFld[30];
  
  IGRchar  nullTxt[2];

  IGRchar  nodeType[128];
  IGRchar  nodeName[128];
    
  IGRchar  **buf;
  IGRint   rows,cols,i;

  TVDct1JD  nodeJD;
  

  
  // Arg check
  VDASSERTW(&parentJD);
  

  //init 
  strcpy(nullTxt,"");

  strcpy(sqlFld,nullTxt);
  strcpy(sqlLaborFld,nullTxt);
  
  strcpy(sqlValue,nullTxt);
  strcpy(sqlLaborValue,nullTxt);
  
  strcpy(sqlString,nullTxt);
  strcpy(sqlStringAdd,nullTxt);
  rows = cols = 0; buf = NULL;

  

  //say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
 
  //get attributes of parent for query
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_AV_HULL,     AvHull.val.txt);
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_ZONE,        Zone.val.txt);
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_UNIT,        Unit.val.txt);
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_LABOR_CODE,  LaborCode.val.txt);
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_COMPARTMENT, ComptNum.val.txt);
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_SPECIAL_CODE,SpecialCode.val.txt);
  
  //build the query string

  //can't query without hull, pallets are based on hull
  if (!strcmp(AvHull.val.txt,nullTxt)) goto wrapup;
 
  //in order to prevent querying for all pallets, we need one additional attribute
  //to query on, check it.

  if (!strcmp(Zone.val.txt,nullTxt) &&
      !strcmp(Unit.val.txt,nullTxt) &&
      !strcmp(LaborCode.val.txt,nullTxt) &&
      !strcmp(ComptNum.val.txt,nullTxt) &&
      !strcmp(SpecialCode.val.txt,nullTxt)) goto wrapup;
  
  if (strcmp(Zone.val.txt,nullTxt)) {
    strcpy(sqlValue,Zone.val.txt);
    strcpy(sqlFld,"zone");
    sprintf(sqlStringAdd,
	    "and %s = %s ",
	    sqlFld, sqlValue);
  }
  
  if (strcmp(Unit.val.txt,nullTxt)) {
    strcpy(sqlValue,Unit.val.txt);
    strcpy(sqlFld,"unit");
    sprintf(sqlStringAdd,
	    "and %s = %s ",
	    sqlFld, sqlValue);
  }
  
  if (strcmp(ComptNum.val.txt,nullTxt)) {
    strcpy(sqlValue,ComptNum.val.txt);
    strcpy(sqlFld,"compt_num");
    sprintf(sqlStringAdd,
	    "and %s = %s ",
	    sqlFld, sqlValue);
  }
  
  if (strcmp(SpecialCode.val.txt,nullTxt)) {
    strcpy(sqlValue,SpecialCode.val.txt);
    strcpy(sqlFld,"special_code");
    sprintf(sqlStringAdd,
	    "and %s = %s ",
	    sqlFld, sqlValue);
  }

  //no labor_code
  if (!strcmp(LaborCode.val.txt,nullTxt)) {
    strcat(sqlStringAdd,";\n");
    sprintf(sqlString,
	    "Select pallet_code from tm_pallet_codes where avhull = '%s' %s ",
	    AvHull.val.txt, sqlStringAdd);
    retFlag = 1;
    
  }
  
  //have labor_code
  else {
    strcat(sqlStringAdd,";\n");
    strcpy(sqlLaborFld,"labor_code");
    strcpy(sqlLaborValue,LaborCode.val.txt);
    sprintf(sqlString,
	    "Select pallet_code from tm_pallet_codes where avhull = '%s' and %s = %s%s",
	    AvHull.val.txt, sqlLaborFld, sqlLaborValue, sqlStringAdd);
    retFlag = 1;  
  }
  

 
  
  // Make sure logged in
  sts = VDSverify_login();
  if (!(sts & 1)) {
    retFlag = 0;
    goto wrapup;
  }
  
  //do the query
  sts = VDSsql_query(sqlString, &cols, &rows, &buf);
  

  //did we get anything from the query
  if (!(sts & 1)) {
    retFlag = 0;
    goto wrapup;
  }
  
  //create the pallet nodes with names from query results
  
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PALLET);
  
  for (i = 0; i < rows; i = i + 1) {
    //printf("Pallet Code = %s\n",buf[i]);

    strcpy(nodeName,buf[i]);
    _RTCJDB(parentJD)->createNode(parentJD,
				  nodeType, 
				  nodeName,
				  &nodeJD);

  }

  //Done
  retFlag = 1;
  goto wrapup;
  

wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  //free up the query buffer
  if (buf) VdsRisFreeBuffer(buf, rows * cols);

  return retFlag;
  
}


/* -----------------------------------------------
 * Returns value for form gadget
 * Every time we get a new parent,
 * this will get called.
 */
static IGRstat getGadgetText(TVDct1JD *nodeJD,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
   VDASSERT_FN("getGadgetText");

  IGRstat       retFlag = 0;
  TVDctBaseInfo baseInfo;
  TVDct1JD parentClassJD;
  
  // Arg check
  VDASSERTW(txt != NULL);
  *txt = 0;
  VDASSERTW(formName != NULL);
  
  // Need baseInfo
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // Tree Form
  if (!strcmp(formName,VDCT_FORM_TREE_F_NAME)) {
    
    switch(gadget) {
      case VDCT_FORM_TREE_G_DISPLAY:

	retFlag = 1;
	
	switch(nth) {
	  case 0: strcpy(txt,"1 ALL     Nodes");  break;
	  case 1: strcpy(txt,"2 Active  Nodes");  break;
	  case 2: strcpy(txt,"3 Latest  Frozen"); break;
	  case 3: strcpy(txt,"4 Deleted NODES");  break;
	  default: retFlag = 0;
	}
	break;	
    }
    goto wrapup;
  }
  
  // Node Form
  if (!strcmp(formName,VDCT_FORM_NODE_F_NAME)) {
    
    switch(gadget) {
    case VDCT_FORM_NODE_G_DOIT:
      
      retFlag = 1;

      // PAL_ASSYS (Tree) options
      if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) {
	switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");      break;
	case 1: strcpy(txt,"2 Create  Node");      break;
	case 2: strcpy(txt,"7 ReCompute Node");         break;
	case 3: strcpy(txt,"8 Generate Pasted Node(s)");      break;
	case 4: strcpy(txt,"D Delete  Node");      break;
	case 5: strcpy(txt,"R Rename  Node");      break;
	case 6: strcpy(txt,"M Move    Node");      break;
	default: retFlag = 0;
	}
      }
      // PALGROUP options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) {
	switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");      break;
	case 1: strcpy(txt,"2 Create  Node");      break;
	case 2: strcpy(txt,"7 ReCompute Node");         break;
	case 3: strcpy(txt,"D Delete  Node");      break;
	case 4: strcpy(txt,"R Rename  Node");      break;
	case 5: strcpy(txt,"Q Query   Pallets");   break;
	case 6: strcpy(txt,"M Move    Node");      break;
	default: retFlag = 0;
	}
      }
      // PALLET options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALLET)) {
	switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");      break;
	case 1: strcpy(txt,"7 ReCompute Node");         break;
	case 2: strcpy(txt,"D Delete  Node");      break;
	case 3: strcpy(txt,"R Rename  Node");      break;
	case 4: strcpy(txt,"P Paste   Node(s)");   break;
	case 5: strcpy(txt,"M Move    Node");      break;
	default: retFlag = 0;
	}
      }
       // ALL OTHER  options
      else {
	switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");      break;
	default: retFlag = 0;
	}
      }
      
      break;	
           
    }
    goto wrapup;
  }

  // Try ancestor
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  retFlag = _RTCJDC(&parentClassJD)->getGadgetText(nodeJD,formName,gadget,nth,txt);
  
 wrapup:
  return retFlag;
}


/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");
  
  IGRstat retFlag = 0;
    
  TVDctBaseInfo baseInfo;
  TVDctNodeType parentType;
  
  // Arg check
  VDASSERTW((parentJD->cl != NULL) && (parentJD->id.objid != NULL_OBJID));
  VDASSERTW(childType != NULL);

  // Need the parent info
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&baseInfo);
  strcpy(parentType,baseInfo.nodeType);
  if (*parentType == 0) goto wrapup;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",ffn(),fn,_RTCJDBC(parentJD),parentType,childType);
  }
  
  // OK By default
  retFlag = 1;

  // PAL_ASSYS can have PALGROUP or PALLET
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PALASSYS)) {
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PALGROUP))  goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PALLET))    goto wrapup;
  }
  
  // PALGROUP can have PALGROUP or PALLET
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PALGROUP)) {
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PALGROUP))  goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PALLET))    goto wrapup;
  }
  
  // PALLET can have ASSY_TYPE[2], ENG_ASSY[2], or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PALLET)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))      goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY2))  goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))     goto wrapup;
  }
  
  // ENG_ASSY[2] can have ASSY_TYPE[2] or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ENGASSY2)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))      goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))     goto wrapup;
  }

  // ASSY_TYPE[2] can have PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ASSY2)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))      goto wrapup;
  }

  // PART nothing
  if(!strcmp(parentType,VDCT1_ENG_NODE_TYPE_PART)) {
  }

  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %s %d\n",ffn(),fn,_RTCJDBC(parentJD),retFlag);
  }

  return retFlag;
}

/* -----------------------------------------------
 * Nth attribute of a given node
 */
static IGRstat getNodeAttrName(TVDct1JD *nodeJD,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{ 
  VDASSERT_FN("getNodeAttrName");
    
  IGRstat retFlag = 0;
  
  traceFlag = 0;
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %2d\n",ffn(),fn,_RTCJDBC(nodeJD),nodeType,nth);
  }
  
  // Init 
  VDASSERTW(attrName != NULL);
  VDASSERTW(nodeType != NULL);
  *attrName = 0;
  retFlag = 1;
  
  // tree PAL_ASSYS
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) {
    
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  2: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  6: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  7: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case  9: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup; 
    case 10: strcpy(attrName,VDCT1_ATTR_SPECIAL_CODE); goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 13: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_PAL_STAGE);    goto wrapup;
    }
  }

  // PALGROUP
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  2: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  4: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  6: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case  7: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case  9: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup; 
    case 10: strcpy(attrName,VDCT1_ATTR_SPECIAL_CODE); goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 13: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_PAL_STAGE);    goto wrapup;
    }    
  }

  // PALLET
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PALLET)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_TREE_INDEX);   goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_IN_COPICS);    goto wrapup;
    case  7: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  9: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case 10: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 12: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup; 
    case 16: strcpy(attrName,VDCT1_ATTR_SPECIAL_CODE); goto wrapup;
    case 17: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 18: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 19: strcpy(attrName,VDCT1_ATTR_DWG_CODE);     goto wrapup;
    case 20: strcpy(attrName,VDCT1_ATTR_PAL_GROUP);    goto wrapup;
    case 21: strcpy(attrName,VDCT1_ATTR_PAL_STAGE);    goto wrapup;
    case 22: strcpy(attrName,VDCT1_ATTR_PALLET);       goto wrapup; 
    case 23: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 24: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 25: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 26: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 27: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup; 
    }    
  }

  // ENG_ASSY[2]
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 16: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 17: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 18: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 19: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 20: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 21: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 22: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
    case 23: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
    case 24: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;
    case 25: strcpy(attrName,VDCT1_ATTR_PAINT_REF);    goto wrapup;
    case 26: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
    }    
  }

  // ASSY[2]
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
    case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  5: strcpy(attrName,VDCT1_ATTR_COUNT);        goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
    case  8: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case 11: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;   
    case 16: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;  
    case 17: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup; 
    case 18: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
    case 19: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
    case 20: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
    case 21: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
    case 22: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
    case 23: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
    case 24: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;
    case 25: strcpy(attrName,VDCT1_ATTR_PAINT_REF);    goto wrapup;
    case 26: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
    }    
  }

  // PART
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PART)) {
    
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);         goto wrapup; 
    case  1: strcpy(attrName,VDCT1_ATTR_PART_NO);        goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_PART_REV);       goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_ISDP_PATH);      goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_ISDP_NAME);      goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_TREE_NUM);       goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_NODE_NUM);       goto wrapup;
    case  7: strcpy(attrName,VDCT1_ATTR_COUNT);          goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_AV_HULL);        goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_CONT_HULL);      goto wrapup;   
    case 10: strcpy(attrName,VDCT1_ATTR_ZONE);           goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_UNIT);           goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);    goto wrapup; 
    case 13: strcpy(attrName,VDCT1_ATTR_COM_CODE);       goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_COMMODITY);      goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_COST_CODE);      goto wrapup;
    case 16: strcpy(attrName,VDCT1_ATTR_DWG_NUM);        goto wrapup;
    case 17: strcpy(attrName,VDCT1_ATTR_DWG_REV);        goto wrapup;   
    case 18: strcpy(attrName,VDCT1_ATTR_WEIGHT);         goto wrapup; 
    case 19: strcpy(attrName,VDCT1_ATTR_QTY);            goto wrapup;  
    case 20: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE);   goto wrapup;  
    case 21: strcpy(attrName,VDCT1_ATTR_SIZE);           goto wrapup; 
    case 22: strcpy(attrName,VDCT1_ATTR_MATERIAL);       goto wrapup;     
    case 23: strcpy(attrName,VDCT1_ISDP_ATTR_GRADE);     goto wrapup;
    case 24: strcpy(attrName,VDCT1_ISDP_ATTR_PLATE_THK); goto wrapup;
    case 25: strcpy(attrName,VDCT1_ISDP_ATTR_TREATMENT); goto wrapup;
    case 26: strcpy(attrName,VDCT1_ATTR_PAINT_REF);      goto wrapup;
    case 27: strcpy(attrName,VDCT1_ATTR_STOCK);          goto wrapup;
    case 28: strcpy(attrName,VDCT1_ATTR_PCT_MINO);       goto wrapup;
    case 29: strcpy(attrName,VDCT1_ATTR_MINO);           goto wrapup;
    case 30: strcpy(attrName,VDCT1_ATTR_CAGE);           goto wrapup;
    case 31: strcpy(attrName,VDCT1_ATTR_FIAN);           goto wrapup; 
    case 32: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);     goto wrapup;   
    case 33: strcpy(attrName,VDCT1_ATTR_NOMENCLATURE);   goto wrapup;
    case 34: strcpy(attrName,VDCT1_ATTR_PART_DESCR);     goto wrapup;  
    case 35: strcpy(attrName,VDCT1_ATTR_PART_REMARKS);   goto wrapup;
    case 36: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);     goto wrapup;
    case 37: strcpy(attrName,VDCT1_ATTR_PAINT_REF);      goto wrapup;
    case 38: strcpy(attrName,VDCT1_ATTR_MODEL_ID);       goto wrapup;
    }
  }

  // Not found
  retFlag = 0;
    
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* ------------------------------------------------
 * Generic Re-computer
 * **/
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNode");

  IGRstat retFlag = 0;
  IGRstat sts;

  
  // should get the node from the parent tree and re-do the attributes
  // and stuff associated with it.  Or, delete from pallet tree if the
  // node no-longer exists in the parent tree.
  
  // done
  retFlag = 1;

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

  TVDctBaseInfo baseInfo;

  TVDct1JD parentClassJD;

  TVDrisInfo ris;
  
  // Arg check
  VDASSERTW((parentJD->id.objid != NULL_OBJID) && (parentJD->cl != NULL));
  VDASSERTW(nodeType != NULL);
  VDASSERTW(nodeName != NULL);
  VDASSERTW(nodeJD);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),_RTCJDBC(parentJD),fn,nodeType,nodeName);
  }
 
  //init 
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;
  
  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->
    createNode(parentJD,nodeType,nodeName,nodeJD);
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;

  // Init the date
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_ASSY_DATE);

  // Init the UM
  //_RTCJDB(nodeJD)->computeUM(nodeJD,VDCT1_ATTR_ITEM_UM);
  
 //PALLET pull down
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PALLET)) {
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COM_CODE);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LABOR_CODE);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_SPECIAL_CODE);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_REV);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_FROZEN);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PALLET);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LINE_IDENT);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_MINO);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_FIAN);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ISDP_NAME);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_STOCK);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT_WT);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_DESCR);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_REMARKS);
    _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_DATE);
   
    //computePallet();
    //setAttributeInCopics();  fix this later
    
  }  //end of pallet pull down
  
  //GROUP pull down
   if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) {
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COM_CODE);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LABOR_CODE);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_SPECIAL_CODE);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_REV);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_FROZEN);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PALLET);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LINE_IDENT);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_MINO);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_FIAN);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ISDP_NAME);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_STOCK);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT_WT);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_DESCR);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_REMARKS);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ASSY_DATE);
   
   }  //end of group pull down

   // part pull down
   if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) {
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
     _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PALLET);
   }
   
   //default attribute set
   // Only set defaults for tree tops, the rest will pull down.
   if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) {
      _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_AV_HULL,  VDCT1_DEFAULT_PAL_AV_HULL);
      _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_CONT_HULL,VDCT1_DEFAULT_CONT_HULL);
      _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_FROZEN,   VDCT1_DEFAULT_FROZEN);
      _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ASSY_REV, VDCT1_DEFAULT_ASSY_REV);
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
 * Class filter
 */
static IGRstat getFilter(TVDct1JD       *nodeJD,
			 OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;
  
  if (classList == NULL) goto wrapup;
  
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
  if (cnt) *cnt = 6;  // Set this to total number of nodes
  VDASSERTW(info);

  // Just a switch
  switch(nth) {

   case 0:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    strcpy(info->desc, "PART");
    strcpy(info->level,"U00");
    strcpy(info->table,"vdct1_palassy");
    return 1;

  case 1:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PALGROUP);
    strcpy(info->desc, "GROUP");
    strcpy(info->level,"U01");
    strcpy(info->table,"vdct1_palassy");
    return 1;

  case 2:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PALLET);
    strcpy(info->desc, "PALLET");
    strcpy(info->level,"U02");
    strcpy(info->table,"vdct1_palassy");
    return 1;

  case 3:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    strcpy(info->desc, "ENGASSY2");
    strcpy(info->level,"U03");
    strcpy(info->table,"vdct1_palassy");
    return 1;

  case 4:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    strcpy(info->desc, "STD_ASSY2");
    strcpy(info->level,"U04");
    strcpy(info->table,"vdct1_palassy");
    return 1;

  case 5:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PALASSYS);
    strcpy(info->desc, "PALLET ASSEMBLIES");
    strcpy(info->level,"S05");
    strcpy(info->table,"vdct1_palassy");
    return 1;
  }
  
  // No More
  memset(info,0,sizeof(TVDctNodeTypeInfo));

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Hello routine for testing
 */
static IGRstat hello(TVDct1JD *nodeJD)
{ 
  printf("@@@ Hello from %s\n",_RTCJDBC(nodeJD));
  return 1;
}

/* -----------------------------------------------
 * Eng Trees can be posted
 */
static IGRstat isTreePostable(TVDct1JD *treeJD)
{
  return 1;
}

/* -------------------------------------------------------------------
 * PDM Table
 */
static IGRstat getTreePostTable(TVDct1JD *nodeJD, IGRchar *table_name)
{
  VDASSERT_FN("getTreePostTable");
  IGRstat retFlag = 0;
  
  VDASSERTW(table_name);
  
  strcpy(table_name,"tm_pallet_dynamic");
  //strcpy(table_name,"tm_test_dynamic");

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitPalAssysTreeClass(TVDct1ProdTreeClass     *prodCL, 
				   TVDct1PalAssysTreeClass *cl)
{
  VDASSERT_FN("VDct1InitPalAssysTreeClass");
  
  IGRstat retFlag = 0;

  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_ASSY);
  //traceFlagx = traceFlag = 1;
  
  // Transfer
  VDct1CopyRootImps(prodCL,cl);
  cl->prod = prodCL->prod;
  
  // Data
  strcpy(cl->base.info.type,VDCT1_TREE_TYPE_PAL_ASSYS);
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Pallets");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;   //Done
  cl->base.getNodeAttrName  = getNodeAttrName;   //Done migration
  cl->base.getFilter        = getFilter;
  cl->base.getAttr          = getAttr;

  cl->base.createNode       = createNode;        
  //cl->base.computeNode      = computeNode;        
  cl->base.isChildTypeValid = isChildTypeValid;  //Done migration

  cl->base.isTreePostable   = isTreePostable;
  cl->base.getTreePostTable = getTreePostTable;

  cl->base.updateNodesOnTree = updateNodesOnTree;
  cl->base.reComputeNode     = reComputeNode;

  //Command Pointers
  cl->cmd.getGadgetText     = getGadgetText;
  cl->cmd.createNodeByQuery = createNodeByQuery;
  cl->cmd.getPasteNodeType  = getPasteNodeType;
  cl->cmd.isDeleteTreeValid = isDeleteTreeValid;
  cl->cmd.isCreateTreeValid = isCreateTreeValid;

  cl->cmd.getNewParentForPastedNode = getNewParentForPastedNode;
  cl->cmd.isNodeInfoForPasteValid   = isNodeInfoForPasteValid;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}






