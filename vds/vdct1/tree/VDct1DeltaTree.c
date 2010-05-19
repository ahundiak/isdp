 /* $Id: VDct1DeltaTree.c,v 1.2 2002/05/02 16:32:02 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1DeltaTree.c
 *
 * Description: Pallet Assembly Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1DeltaTree.c,v $
 *      Revision 1.2  2002/05/02 16:32:02  jdsauby
 *      TR 6326
 *
 *      Revision 1.1  2002/01/07 18:53:23  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/06/01  js      Creation
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

VDASSERT_FFN("vdct1/tree/VDct1DeltaTree.c");

#define MY_TREE VDCT1_TREE_TYPE_DELTA_TREE

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

#if 0
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
    if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_DELTA)) goto wrapup;

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
	
#endif
    

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
    if ( (strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_DELTA)) &&
	 (strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) )
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


/* ----------------------------------------------
 * check to see if creation of a tree is valid
 */
static IGRstat isCreateTreeValid(TVDct1JD *setJD,
				 IGRchar  *setType)
{
  VDASSERT_FN("isCreateTreeValid");
  
  IGRstat retFlag = 0;
#if 0
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
#endif
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
#if 0  
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
#endif
  retFlag = 1;
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

#if 0
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
#endif
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
#if 0
      // PAL_ASSYS (Tree) options
      if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_DELTA)) {
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
      // GROUP options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {
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
#endif
	switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");      break;
	default: retFlag = 0;
	}
      //}
      
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

#if 0
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
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_DELTA)) {
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
#endif
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
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_DELTA)) {
    
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
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {

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
/* ----------------------------------------------
 * copy node routine called from this file only
 */
static IGRstat nodeCopyNode(TVDct1JD *parentJD,
			    TVDct1JD *copiedJD,
			    TVDct1JD *rootJD)
{
  VDASSERT_FN("nodeCopyNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo      parentBaseInfo;
  TVDctBaseInfo      copiedBaseInfo;
  TVDctBaseInfo      rootBaseInfo;
  TVDctNodeTypeInfo  nodeTypeInfo;
  IGRint             i;
    
  TVDct1JD           nodeJD;
  TVDct1JD           childJD;
  
  TGRobj_env modelOE;
  
  // Arg check
  VDASSERTW(parentJD);
  VDASSERTW(copiedJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Grab the info
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (*parentBaseInfo.setType  == 0) goto wrapup;
  _RTCJDB(copiedJD)->getBaseInfo(copiedJD,&copiedBaseInfo);
  if (*copiedBaseInfo.nodeType   == 0) goto wrapup;

  /* ---------------------------------------------
   * Determines what type of node to create when
   * Pasting a node from one tree to another
   */
  _RTCJDC(parentJD)->getPasteNodeType(parentJD,copiedJD,&nodeTypeInfo);
  if (*nodeTypeInfo.type == 0) goto wrapup;
  strcpy(copiedBaseInfo.nodeType,nodeTypeInfo.type);

  // Create the object
  _RTCJDB(parentJD)->createNode(parentJD,
				copiedBaseInfo.nodeType,
				copiedBaseInfo.nodeName,
				&nodeJD);
  if (nodeJD.id.objid == NULL_OBJID) goto wrapup;
  
  // Transfer attributes
  _RTCJDC(&nodeJD)->copyNodeAttributes(&nodeJD,copiedJD);
  
  // recompute node
  _RTCJDC(parentJD)->computeMoveCopyNode(parentJD,&nodeJD);
  
  // Link model object
  _RTCJDB(copiedJD)->getModelObject(copiedJD,&modelOE);
    
  // connect it up
  if (modelOE.obj_id.objid != NULL_OBJID) { 
    _RTCJDB(&nodeJD)->connectModelObject(&nodeJD,&modelOE);
  }
    
  // Save first one in rootID
  if ((rootJD) && (rootJD->id.objid == NULL_OBJID)) *rootJD = nodeJD;
  
  // Now do the kids
  for(i = 0; _RTCJDB(copiedJD)->getTreeChild(copiedJD,i,&childJD) ;i++) {
    nodeCopyNode(&nodeJD,&childJD,NULL);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ------------------------------------------------
 * Compare attributes from pallet tree to those of eng tree
 * **/
static IGRstat isAttrsFromPalEqualToEngr(TVDct1JD *palJD,
	                                 TVDct1JD *engJD)
{
    VDASSERT_FN("isAttrsFromPalEqualToEngr");
    IGRstat retFlag = 1;
    IGRstat sts;
    TVDfldS  flds;
    IGRint  i;
    IGRchar buf[80];

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get attrs from palJD
    VDctxGetAttrs(&palJD->id,&flds.cnt,flds.fld);
    if (flds.cnt < 1) goto wrapup;

    // compare to same attr in engJD
    for (i = 0; i < flds.cnt; i++)
    {
	*buf = 0;
	_RTCJDB(engJD)->getAttr(engJD,flds.fld[i].name,buf);
	if (*buf != 0)
	{
	    if (strcmp(flds.fld[i].val.txt,buf))
	    {
		retFlag = 0;
		goto wrapup;
	    }
	}
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
/* ------------------------------------------------
 * check to see if the node still exists in it's parent
 * Engineering Tree.
 * */
static IGRstat isNodeModifiedFromParentTree(TVDct1JD *nodeJD)
{
    VDASSERT_FN("isNodeModifiedFromParentTree");
    IGRstat retFlag = 0;  // by default, it has not
    IGRstat sts;

    IGRchar  tree_num[80];
    IGRchar  node_num[80];
    IGRchar  status  [80];
    TVDct1JD engTreeJD,engNodeJD;

    // init
    engTreeJD.id.objid = NULL_OBJID;
    engNodeJD.id.objid = NULL_OBJID;
    *tree_num = 0;
    *node_num = 0;
    *status   = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get tree_num and node_num attributes
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_TREE_NUM,tree_num);
    if (*tree_num == 0) goto wrapup;
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_NODE_NUM,node_num);
    if (*node_num == 0) goto wrapup;

    // find the engTree with the same tree_num
    getEngTreeForTreeNum(tree_num,&engTreeJD);
    if (engTreeJD.id.objid == NULL_OBJID) {
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
	goto wrapup;
    }

    // is the node marked as deleted
    _RTCJDB(&engNodeJD)->getAttr(&engNodeJD,VDCT1_ATTR_FROZEN,status);
    if (*status == 0) goto wrapup;
    if (!strcmp(status,VDCT1_DEFAULT_FROZEN_D)) {
	goto wrapup;
    }

    // compare the attributes from the pallet tree to those of the engineering tree
    if (!isAttrsFromPalEqualToEngr(nodeJD,&engNodeJD)) {
	retFlag = 1;
	goto wrapup;
    }
    
    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
static IGRstat isNodeInTree(TVDct1JD *treeJD,
	                    TVDct1JD *nodeJD)
{
    VDASSERT_FN("isNodeInPalAssysTree");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar nodeTreeNum[80];
    IGRchar nodeNodeNum[80];
    IGRchar treeTreeNum[80];
    IGRchar treeNodeNum[80];

    IGRint  i;
    TVDct1JD childJD;

    // init
    *nodeTreeNum = 0;
    *nodeNodeNum = 0;
    *treeTreeNum = 0;
    *treeNodeNum = 0;

    if (traceFlag) {
	TVDctBaseInfo baseInfo;
	VDjt1GetBaseInfo(nodeJD,&baseInfo);
	printf(">>> %s %s %s %s\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
    }
    
    // first, get attributes
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_TREE_NUM,nodeTreeNum);
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_NODE_NUM,nodeNodeNum);

    _RTCJDB(treeJD)->getAttr(treeJD,VDCT1_ATTR_TREE_NUM,treeTreeNum);
    _RTCJDB(treeJD)->getAttr(treeJD,VDCT1_ATTR_NODE_NUM,treeNodeNum);

    // if they all have values, and are equal, then we have it
    if ( (*nodeTreeNum != 0) && (*nodeNodeNum != 0) &&
	 (*treeTreeNum != 0) && (*treeNodeNum != 0) )
	if ( (!strcmp(nodeTreeNum,treeTreeNum)) &&
             (!strcmp(nodeNodeNum,treeNodeNum)) )
	{
	    retFlag = 1;
	    goto wrapup;
	}

    // check the kids
    for (i = 0; _RTCJDB(treeJD)->getTreeChild(treeJD,i,&childJD); i++) {
	sts = isNodeInTree(&childJD,nodeJD);
	if (sts & 1) {
	    retFlag = 1;
	    goto wrapup;
	}

    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/*-------------------------------------------------
 * Check to see if parent node is already in Delta Tree
 * **/
static IGRstat isNodeInDeltaTree(TVDct1JD *deltaJD,
	                         TVDct1JD *nodeJD)
{
    VDASSERT_FN("isNodeInDeltaTree");
    IGRstat retFlag = 0;   // by default, it is not in tree
    IGRstat sts;

    TVDct1JD wrkJD;

    IGRchar tree_num[80];
    IGRchar buf     [80];
    IGRchar node_num[80];

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the tree_num and node_num attributes
    *tree_num = 0;
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_TREE_NUM,tree_num);
    if (*tree_num == 0) goto wrapup;
    *node_num = 0;
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_NODE_NUM,node_num);
    if (*node_num == 0) goto wrapup;

    // get a node from delta tree with same node_num
    wrkJD.id.objid = NULL_OBJID;
    if (traceFlag) printf("### search node_num <%s>\n",node_num);
    _RTCJDB(deltaJD)->findNodeByAttrValue(deltaJD,
	                                  VDCT1_ATTR_NODE_NUM,
		 			  node_num,
					  &wrkJD);
    if (wrkJD.id.objid == NULL_OBJID) goto wrapup;
    if (traceFlag) 
    {
	TVDctBaseInfo baseInfo;
	VDjt1GetBaseInfo(&wrkJD,&baseInfo);
	printf("### wrk BaseInfo <%s,%s>\n",baseInfo.nodeType,baseInfo.nodeName);
    }
    
    // found a node with same node num, check tree num to verify
    *buf = 0;
    _RTCJDB(&wrkJD)->getAttr(&wrkJD,VDCT1_ATTR_TREE_NUM,buf);
    if (*buf == 0) goto wrapup;
    if (traceFlag) printf("### tree_num1 <%s> tree_num2 <%s>\n",tree_num,buf);

    // compare the tree_num values
    if (!strcmp(tree_num,buf)) {
	retFlag = 1;
	goto wrapup;
    }

    // done, it is not in the tree

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* ------------------------------------------------
 * check to see if the node still exists in it's parent
 * Engineering Tree.
 * */
static IGRstat isNodeDeletedFromParentTree(TVDct1JD *nodeJD)
{
    VDASSERT_FN("isNodeDeletedFromParentTree");
    IGRstat retFlag = 0;  // by default, it is there
    IGRstat sts;

    IGRchar  tree_num[80];
    IGRchar  node_num[80];
    IGRchar  status  [80];
    TVDct1JD engTreeJD,engNodeJD;

    // init
    engTreeJD.id.objid = NULL_OBJID;
    engNodeJD.id.objid = NULL_OBJID;
    *tree_num = 0;
    *node_num = 0;
    *status   = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get tree_num and node_num attributes
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_TREE_NUM,tree_num);
    if (*tree_num == 0) goto wrapup;
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_NODE_NUM,node_num);
    if (*node_num == 0) goto wrapup;

    // find the engTree with the same tree_num
    getEngTreeForTreeNum(tree_num,&engTreeJD);
    if (engTreeJD.id.objid == NULL_OBJID) {
	retFlag = 1;
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
	retFlag = 1;
	goto wrapup;
    }

    // is the node marked as deleted
    _RTCJDB(&engNodeJD)->getAttr(&engNodeJD,VDCT1_ATTR_FROZEN,status);
    if (*status == 0) goto wrapup;
    if (!strcmp(status,VDCT1_DEFAULT_FROZEN_D)) {
	retFlag = 1;
	goto wrapup;
    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


    
/* ------------------------------------------------
 * Check the current node type, and parent node type
 * to determine create deleted node validity
 * **/
static IGRstat isCreateDeletedModifiedNodeTypeValid(TVDct1JD *nodeJD)
{
    VDASSERT_FN("isCreateDeletedModifiedNodeTypeValid");
    IGRstat retFlag = 0;
    IGRstat sts;

    TVDctBaseInfo baseInfo;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // if it is a group, a tree, or a pallet, don't worry about it
    VDjt1GetBaseInfo(nodeJD,&baseInfo);
    if (*baseInfo.nodeType == 0) goto wrapup;

    if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALGROUP)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALLET))   )
    {
	goto wrapup;
    }
    
    // done, ok to create the node from this end
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    

/* --------------------------------------------------
 * Create one deleted node
 * */
static IGRstat createDeltaDeletedModifiedNode(TVDct1JD *deltaJD,
	                                      TVDct1JD *nodeJD)
{
    VDASSERT_FN("createDeltaDeletedModifiedNode");
    IGRstat retFlag = 1;

    TVDct1JD grpJD;
    TVDct1JD wrkJD;
    TVDctBaseInfo baseInfo;

    IGRchar  status[80];

    // say hi
    if (traceFlag) {
	VDjt1GetBaseInfo(nodeJD,&baseInfo);
	printf(">>> %s %s %s %s\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
    }
   
    // if the node is not an active node within PalAssys tree, don't worry about it
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_FROZEN,status);
    if (strcmp(status,VDCT1_DEFAULT_FROZEN_A)) goto wrapup;

    // verify that this node should be created by nodetype
    if (!isCreateDeletedModifiedNodeTypeValid(nodeJD)) goto wrapup;

    // check to see if parent is already in delta tree
    if (isNodeInTree(deltaJD,nodeJD)) goto wrapup;

    // see if this node has actually been deleted
    if (isNodeDeletedFromParentTree(nodeJD)) {

	// get the deleted node group
	grpJD.id.objid = NULL_OBJID;
	_RTCJDB(deltaJD)->findNodeByTypeName(deltaJD,0,VDCT1_FIND_NODE_OPT_NODE_DOWN,
		VDCT1_ENG_NODE_TYPE_GROUP,"DELETED",&grpJD);
	if (grpJD.id.objid == NULL_OBJID) goto wrapup;

	// nodeCopyNode
	nodeCopyNode(&grpJD,nodeJD,&wrkJD);
	goto wrapup;
    }

    // see if this node has actually been modified
    if (isNodeModifiedFromParentTree(nodeJD)) {

	// get the modified node group
	grpJD.id.objid = NULL_OBJID;
	_RTCJDB(deltaJD)->findNodeByTypeName(deltaJD,0,VDCT1_FIND_NODE_OPT_NODE_DOWN,
		VDCT1_ENG_NODE_TYPE_GROUP,"MODIFIED",&grpJD);
	if (grpJD.id.objid == NULL_OBJID) goto wrapup;


	// nodeCopyNode
	nodeCopyNode(&grpJD,nodeJD,&wrkJD);

	goto wrapup;
    }


    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------------------
 * Create The Deleted Modified nodes
 * This will scan the palAssys Tree, and compare each node
 * to that same node in the original Engr Tree.  If the node
 * no longer exists in the engineering tree, it will be created
 * as a deleted node, if some attributes have changed, it will
 * be created as a modified node.
 * **/

static void createDeltaDeletedModifiedNodes(TVDct1JD *deltaJD,
	                                    TVDct1JD *palJD)
{
    VDASSERT_FN("createDeltaDeletedModifiedNodes");
    IGRstat sts;

    TVDct1JD childJD;
    IGRint         i;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Create the Delta Tree Deleted Node
    sts = createDeltaDeletedModifiedNode(deltaJD,palJD);
    if (!(sts & 1)) goto wrapup;

    // do the kids
    for (i = 0; _RTCJDB(palJD)->getTreeChild(palJD,i,&childJD); i++) {
	createDeltaDeletedModifiedNodes(deltaJD,&childJD);

    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}


/* ---------------------------------------------------
 * Create one added node
 * **/
static IGRstat createAddedNodeFromEngrTree(TVDct1JD *deltaJD,
	                                   TVDct1JD *palJD,
					   TVDct1JD *engJD)
{
    VDASSERT_FN("createAddedNodeFromEngrTree");
    IGRstat retFlag = 1;

    TVDctBaseInfo baseInfo;
    TVDct1JD      grpJD;
    TVDct1JD      wrkJD;
    IGRchar       status[80];

    // if it is the tree, group, EA6 or SA6 don't worry about it
    VDjt1GetBaseInfo(engJD,&baseInfo);
    if (baseInfo.nodeType == NULL) goto wrapup;

    if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_OUTFIT)) ||
         (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_WWAYTREE)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_HVACTREE)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_CABLETREE)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)) ||
	 (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) )     goto wrapup;

    // make sure it is active
    _RTCJDB(engJD)->getAttr(engJD,VDCT1_ATTR_FROZEN,status);
    if (strcmp(status,VDCT1_DEFAULT_FROZEN_A)) goto wrapup;

    // if it is already in the delta tree, don't worry about it
    if (isNodeInTree(deltaJD,engJD)) goto wrapup;

    // if it is in the palAssys tree, don't worry about it
    if (isNodeInTree(palJD,engJD)) goto wrapup;

    // create it
    // find the ADDED node
    grpJD.id.objid = NULL_OBJID;
    _RTCJDB(deltaJD)->findNodeByTypeName(deltaJD,0,VDCT1_FIND_NODE_OPT_NODE_DOWN,
	    VDCT1_ENG_NODE_TYPE_GROUP,"ADDED",&grpJD);
    if (grpJD.id.objid == NULL_OBJID) goto wrapup;


    // nodeCopyNode
    nodeCopyNode(&grpJD,engJD,&wrkJD);

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

    
/* ----------------------------------------------------
 * Given the delta treeJD, the PalAssys JD, and an ENGR treeJD,
 * Create the added nodes in the deltaJD, that do not exist
 * in the palAssysJD
 * **/
static void createAddedNodesFromEngrTree(TVDct1JD *deltaJD,
	                                 TVDct1JD *palJD,
					 TVDct1JD *engJD)
{
    VDASSERT_FN("createAddedNodesFromEngrTree");
    IGRstat sts;

    IGRint i;
    TVDct1JD childJD;

    VDASSERTW(deltaJD && deltaJD->id.objid != NULL_OBJID);
    VDASSERTW(palJD && palJD->id.objid != NULL_OBJID);
    VDASSERTW(engJD && engJD->id.objid != NULL_OBJID);

    // create one added node
    sts = createAddedNodeFromEngrTree(deltaJD,palJD,engJD);
    if (!(sts & 1)) goto wrapup;

    // do the kids
    for (i = 0; _RTCJDB(engJD)->getTreeChild(engJD,i,&childJD); i++) {
	createAddedNodesFromEngrTree(deltaJD,palJD,&childJD);

    }

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

    

static void createDeltaAddedNodes(TVDct1JD *deltaJD,
	                          TVDct1JD *palJD)
{
    VDASSERT_FN("createDeltaAddedNodes");
    IGRstat sts;

    VDosnum  osnum;
    TGRid    mgrID,setID;
    TVDct1JD nodeJD;

    TVDctBaseInfo baseInfo;
  
    IGRint  i;

    // init
    mgrID.objid = NULL_OBJID;
    setID.objid = NULL_OBJID;
    nodeJD.cl   = NULL;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // loop through the valid osnum s
    for (osnum = 0; VDosValidate(osnum); osnum++)
    {

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

		// get baseInfo of node
		VDjt1GetBaseInfo(&nodeJD,&baseInfo);
		if ( (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_OUTFIT)) ||
		     (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_WWAYTREE)) ||
		     (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_HVACTREE)) ||
		     (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_CABLETREE)) )
		     
		{
		    createAddedNodesFromEngrTree(deltaJD,palJD,&nodeJD);
		}

	    }
	}
    }

wrapup:
    if (traceFlag) printf("<<< %s %s %s %s\n",
	                   ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
    return;
}

/* ----------------------------------------------------
 * Create the DELETED, ADDED, and MODIFIED nodes
 * **/
static IGRstat createDeltaTreeNodes(TVDct1JD *deltaJD,
	                            TVDct1JD *palJD)
{
    VDASSERT_FN("createDeltaTreeNodes");

    IGRstat retFlag = 0;
    IGRstat sts;

    // arg check
    VDASSERTW(deltaJD && deltaJD->id.objid != NULL_OBJID);
    VDASSERTW(palJD   && palJD->id.objid   != NULL_OBJID);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // tell the user a little something
    UI_status("Creating Delta Tree");

    // Create the DELETED,MODIFIED NODES
    createDeltaDeletedModifiedNodes(deltaJD,palJD);


    // Create the ADDED NODES
    createDeltaAddedNodes(deltaJD,palJD);


    // done
    retFlag = 1;

    UI_status("Delta Tree Created");

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------
 * Get The Pallet Assys tree to use for the delta tree
 * **/
static IGRstat getPalAssyTree(TVDct1JD *treeJD)
{
    VDASSERT_FN("getPalAssyTree");

    IGRstat  retFlag = 0;
    IGRstat  sts;
    VDosnum  osnum;
    TGRid    mgrID,setID;
    TVDct1JD nodeJD;

    TVDctBaseInfo baseInfo;
  
    IGRint  i;

    // init
    mgrID.objid = NULL_OBJID;
    setID.objid = NULL_OBJID;
    nodeJD.cl   = NULL;

    // arg check
    VDASSERTW(treeJD); treeJD->id.objid = NULL_OBJID;
    
    // loop through the valid osnum s
    for (osnum = 0; VDosValidate(osnum); osnum++)
    {

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

		// get baseInfo of node
		VDjt1GetBaseInfo(&nodeJD,&baseInfo);
		if (!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PALASSYS))
		{
		    *treeJD = nodeJD;
		    retFlag = 1;
		    goto wrapup;
		}

	    }
	}
    }

wrapup:
    if (traceFlag) printf("<<< %s %s %s %s\n",
	                   ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
    return retFlag;
}

/* -------------------------------------------------
 * Create the default DELETED, ADDED, and MODIFIED group nodes
 * **/
static IGRstat createDeltaDefNodes(TVDct1JD *treeJD)
{
    VDASSERT_FN("createDeltaDefNodes");

    IGRstat retFlag = 0;
    IGRstat sts;

    TVDct1JD nodeJD;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // DELETED
    sts = VDjt1CreateNode(treeJD,
	                  VDCT1_ENG_NODE_TYPE_GROUP,
			  "DELETED",
			  &nodeJD);
    if (!(sts & 1)) goto wrapup;

    // ADDED
    sts = VDjt1CreateNode(treeJD,
	                  VDCT1_ENG_NODE_TYPE_GROUP,
			  "ADDED",
			  &nodeJD);
    if (!(sts & 1)) goto wrapup;

    // MODIFIED
    sts = VDjt1CreateNode(treeJD,
	                  VDCT1_ENG_NODE_TYPE_GROUP,
			  "MODIFIED",
			  &nodeJD);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------------
 * Create the Delta Tree nodes
 * */
static IGRstat createDeltaTree(TVDct1JD *treeJD)
{
    VDASSERT_FN("createDeltaTree");

    IGRstat retFlag = 0;
    IGRstat sts;
    TVDctBaseInfo baseInfo;

    TVDct1JD setJD;
    TVDct1JD palJD;

    // arg check
    VDASSERTW(treeJD && treeJD->id.objid != NULL_OBJID);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // find a PalAssys Tree
    palJD.id.objid == NULL_OBJID;
    getPalAssyTree(&palJD);
    if (palJD.id.objid == NULL_OBJID) 
    {
	printf("*** No PalAssys Tree Found, Delta Tree Cannot be Created\n");
	// Delete the tree JD
	_RTCJDB(treeJD)->getMgrParent(treeJD,&setJD);
	_RTCJDB(&setJD)->deleteNode(&setJD);
	goto wrapup;
    }

    // Create the default group nodes
    sts = createDeltaDefNodes(treeJD);
    if (!(sts & 1)) goto wrapup;

    // Create The Delta Tree nodes
    sts = createDeltaTreeNodes(treeJD, &palJD);
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
  IGRstat sts;

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
  
  // 
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_DELTA)) {

      sts = createDeltaTree(nodeJD);
      if (!(sts & 1)) goto wrapup;
       
  }  //end of pallet pull down
  
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
    strcpy(info->table,"vdct1_deltatree");
    return 1;

  case 1:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_GROUP);
    strcpy(info->desc, "GROUP");
    strcpy(info->level,"U01");
    strcpy(info->table,"vdct1_deltatree");
    return 1;

  case 2:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    strcpy(info->desc, "ENGASSY2");
    strcpy(info->level,"U02");
    strcpy(info->table,"vdct1_deltatree");
    return 1;

  case 3:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    strcpy(info->desc, "STD_ASSY2");
    strcpy(info->level,"U03");
    strcpy(info->table,"vdct1_deltatree");
    return 1;

  case 4:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_DELTA);
    strcpy(info->desc, "DELTA TREE");
    strcpy(info->level,"S05");
    strcpy(info->table,"vdct1_deltatree");
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
  
  strcpy(table_name,"tm_delta_dynamic");
  //strcpy(table_name,"tm_test_dynamic");

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitDeltaTreeClass(TVDct1ProdTreeClass     *prodCL, 
			        TVDct1DeltaTreeClass *cl)
{
  VDASSERT_FN("VDct1InitDeltaTreeClass");
  
  IGRstat retFlag = 0;

  //traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_ASSY);
  traceFlagx = traceFlag = 0;
  
  // Transfer
  VDct1CopyRootImps(prodCL,cl);
  cl->prod = prodCL->prod;
  
  // Data
  strcpy(cl->base.info.type,VDCT1_TREE_TYPE_DELTA_TREE);
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Delta Tree");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;   //Done
  cl->base.getNodeAttrName  = getNodeAttrName;   //Done migration
  cl->base.getFilter        = getFilter;
  cl->base.getAttr          = getAttr;

  cl->base.createNode       = createNode;        
  //cl->base.computeNode      = computeNode;        
  //cl->base.isChildTypeValid = isChildTypeValid;  //Done migration

  cl->base.isTreePostable   = isTreePostable;
  cl->base.getTreePostTable = getTreePostTable;

  //cl->base.updateNodesOnTree = updateNodesOnTree;
  cl->base.reComputeNode     = reComputeNode;

  //Command Pointers
  cl->cmd.getGadgetText     = getGadgetText;
  //cl->cmd.createNodeByQuery = createNodeByQuery;
  //cl->cmd.getPasteNodeType  = getPasteNodeType;
  cl->cmd.isDeleteTreeValid = isDeleteTreeValid;
  cl->cmd.isCreateTreeValid = isCreateTreeValid;

  //cl->cmd.getNewParentForPastedNode = getNewParentForPastedNode;
  //cl->cmd.isNodeInfoForPasteValid   = isNodeInfoForPasteValid;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}






