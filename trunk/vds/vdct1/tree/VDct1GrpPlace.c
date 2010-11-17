/* $Id: VDct1GrpPlace.c,v 1.1.2.5 2003/06/13 23:35:21 ylong Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1GrpPlace.I
 *
 * Description: Group Place Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1GrpPlace.c,v $
 *      Revision 1.1.2.5  2003/06/13 23:35:21  ylong
 *      TR7799
 *
 *      Revision 1.1.2.4  2003/06/06 20:58:15  ahundiak
 *      ah
 *
 *      Revision 1.1.2.3  2003/06/03 15:54:09  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1.2.2  2003/05/28 21:47:35  ylong
 *      refined a lot
 *
 *      Revision 1.1.2.1  2003/05/23 23:59:06  ylong
 *      Created for Placement Group Tree - yl
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/08/03  ylong   Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDobj2.h"
#include "VDrisc.h"
#include "VDos.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"
#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

#include "VDctx.h"
#include "VDct1SirGrp.h"

VDASSERT_FFN("vdct1/tree/VDct1GrpPlace.c");

#define MY_TREE		VDCT1_TREE_TYPE_GRP_PLACE
#define MY_TREE_TYPE	VDCT1_ENG_NODE_TYPE_PLGRPTREE
static int traceFlag = 0;

/*--------------------------------------------------------------
 * Check if set exists
 * This is not a overriden function
 */
static IGRstat getMyTree( TVDct1JD *treeJD )
{
  VDASSERT_FN("getMyTree");

  IGRstat	retFlag = 0;
  IGRstat	sts;
  TGRid		mgrID,setID,objID;
  TVDct1JD	setJD;
  IGRint	i,flag;
  IGRchar	type[128];
  VDosnum	osnum;
  TVDctBaseInfo baseInfo;

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,osnum);
  }

  // Only show active os trees
  EX_findmod(NULL, &osnum);

  // Validate os
  sts = VDosValidate(osnum);
  if (!(sts & 1)) goto wrapup;

  // Get the manager
  VDct1GetManager(osnum,&mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // JTSMP TR 5937.
  // The scan can cause a crash if a corrupted node exists.
  // Need ability to turn scan off via environment variable.
  flag = 0;
  if ( getenv("VDCT1_SCAN_TREE_OFF") )
      flag = atoi(getenv("VDCT1_SCAN_TREE_OFF"));

  // Cycle Through
  for(i = 0; VDctxGetNthMgrChild(&mgrID,i,&setID); i++) {

      if (flag != 1) VDct1ScanTree(&setID);  // scan entire tree for node update

      setJD.cl = VDct1GetTreeClassForNode(&setID);
      if (setJD.cl == NULL) goto wrapup;
      setJD.id = setID;

      _RTCJDB(&setJD)->getBaseInfo(&setJD, &baseInfo); 
      if( !strcmp( baseInfo.setType, MY_TREE ) ) {
          if( treeJD ) *treeJD = setJD; 
	  retFlag = 1;
	  goto wrapup;
      }
  }
 
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d %d\n",ffn(),fn,osnum,retFlag);
  }
 
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

  retFlag = 1;

 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* ------------------------------------------------------------------
 * Check is a model object is valid in a GROUP
 * This is not a overriden function
 */
static IGRstat isModelObjectValidInGroup(TVDct1JD *nodeJD, TGRobj_env *modelOE)
{
  VDASSERT_FN("isModelObjectValidInGroup");
 
  IGRstat        retFlag = 0;
  IGRstat        sts;
  IGRchar        fileName[24];
  IGRchar        fileData[128];
  TVDct1JD       local_nodeJD;
  TGRobj_env     local_modelOE;
  TVDctBaseInfo  baseInfo;
  IGRchar        buf[80],*p;
  IGRchar	 nodeAttr[80];
  IGRchar	modelAttr[80];

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
 
  fileName[0] = '\0';
 
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // init (make some local copies)
  local_modelOE = *modelOE;
  local_nodeJD  = *nodeJD;

  // make a treeName
  // Get the info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  p = baseInfo.setType;
  sprintf(fileName,"%c%s.txt",*p,baseInfo.setName);

  // filter out unwanted objects
  // get the modelOE className
  VDobjGetClassName(&local_modelOE,NULL,buf);
  if (traceFlag) printf("modelOE className = %s\n",buf);
 
  // Check if compartment match
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ISDP_ATTR_COMPARTMENT, modelAttr);
  VDjt1GetAttr         (nodeJD, VDCT1_ATTR_COMPARTMENT,      nodeAttr);  
  if( strcmp(modelAttr, nodeAttr) )
  {
    sprintf(fileData,"Model Object: (%d,%d) compartment differnet(%s,%s)\n",
           modelOE->obj_id.osnum, modelOE->obj_id.objid, modelAttr, nodeAttr);
    printf(fileData);
    goto wrapup;
  }

  // Check if part type match
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ATTR_PART_TYPE, modelAttr);
  VDjt1GetAttr         (nodeJD, VDCT1_ATTR_PART_TYPE, nodeAttr);  
  if( strcmp(modelAttr, nodeAttr) )
  {
    sprintf(fileData,"Model Object: (%d,%d) PPART TYPE different(%s,%s)\n",
           modelOE->obj_id.osnum, modelOE->obj_id.objid, modelAttr, nodeAttr);
    printf(fileData);
    goto wrapup;
  }

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
 
  UI_status("Updating tree nodes ...");

  // get base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD, &baseInfo); 

  if (traceFlag && baseInfo.nodeType != NULL) 
      printf(">>> %s %s <%s,%s>\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
  // call the ancestor next
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->updateNodesOnTree(nodeJD);

  // recompute node
  _RTCJDB(nodeJD)->reComputeNode(nodeJD);

  // done
  retFlag = 1;

wrapup:
  UI_status("");
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ------------------------------------------------------------------
 * recompute node on my tree
 * **/
static IGRstat reComputeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("reComputeNode");

  IGRstat        retFlag = 0;
  TVDctBaseInfo  baseInfo;
  TVDctAttrInfo  attrInfo;
  TVDct1JD       parentClassJD;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
 
  // get base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD, &baseInfo); 

  if (traceFlag && baseInfo.nodeType != NULL) 
      printf(">>> %s %s <%s,%s>\n",ffn(),fn,baseInfo.nodeType,baseInfo.nodeName);
  // call the ancestor next
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->reComputeNode(nodeJD);

  // compute my node
  _RTCJDB(nodeJD)->computeNode(nodeJD);

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Disconnect tree child
 */
static IGRstat disconnectTreeChild(TVDct1JD *treeJD, TVDct1JD *childJD)
{
  VDASSERT_FN("disconnectTreeChild");

  IGRstat	retFlag = 0;
  IGRstat	sts;

  TVDct1JD      parentJD, parentClassJD;
  TVDctBaseInfo	baseInfo;

  _RTCJDB(childJD)->getBaseInfo(childJD,&baseInfo);

  parentJD.id.objid = NULL_OBJID;
  if( *baseInfo.nodeType && !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ITEM))
  {
    sts = _RTCJDB(childJD)->getTreeParent(childJD,&parentJD);
    if( !sts ) goto wrapup;
  }

  // Standard process
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDB(&parentClassJD)->disconnectTreeChild(treeJD,childJD);
  if( !sts ) goto wrapup;
 
  // to update qty
  if( parentJD.id.objid != NULL_OBJID ) _RTCJDB(&parentJD)->reComputeNode(&parentJD);

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* ------------------------------------------------------------------
 * generic recomputer, used to compute any misc attributes
 */
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctBaseInfo  baseInfo;
  
  TVDct1JD	childJD, parentJD, parentClassJD;
  TGRobj_env	modelOE;
  TGRobj_env    objOE;

  IGRchar	qty[128], attr[128];
  IGRchar	op[3];
  IGRchar	*p,*q;
  IGRint	i;
  
  IGRchar sirid[64];

  IGRdouble loc_x,loc_y,loc_z;
  IGRdouble loc;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  modelOE.obj_id.objid = NULL_OBJID;
  _RTCJDB(nodeJD)->getModelObject(nodeJD,&modelOE);
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  
  // copy attributes from model to node
  if (modelOE.obj_id.objid != NULL_OBJID)
  {
     _RTCJDB(nodeJD)->copyAttributesFromModelToNode(nodeJD,&modelOE);
  }

  // Set QTY for GROUP and NOT_IN_GROUP. During creation, ITEM created later then
  // NOT_IN_GROUP, so have to use frozen to check.
  if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP) ||
     !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP) )
  {
     i = 0;
     loc_x = 0.0;
     loc_y = 0.0;
     loc_z = 0.0;

     while(_RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD))
     {
       sts = VDjt1GetAttr(&childJD,VDCT1_ATTR_FROZEN,attr);
       if( !strcmp(attr, VDCT1_DEFAULT_FROZEN_D) )
       {
         _RTCJDB(&childJD)->deleteNode(&childJD);
       }
       else 
       {
         i++;
         VDjt1GetAttr(&childJD,VDCT1_ATTR_LOC_X,attr);
         loc = atof(attr);

         if (i == 1) loc_x = loc;
         else
         {
           if (loc > loc_x) loc_x = loc;
         }

         VDjt1GetAttr(&childJD,VDCT1_ATTR_LOC_Y,attr);
         loc_y += atof(attr);

         VDjt1GetAttr(&childJD,VDCT1_ATTR_LOC_Z,attr);
         loc_z += atof(attr);
       }
     }
     sprintf(qty, "%d", i);
     VDjt1SetAttr(nodeJD,VDCT1_ATTR_QTY,qty);

     /* Locations */
     if (i == 0) i = 1;
     VDcnvDblToTxt(loc_x,     attr); VDjt1SetAttr(nodeJD,VDCT1_ATTR_LOC_X,attr);
     VDcnvDblToTxt(loc_y / i, attr); VDjt1SetAttr(nodeJD,VDCT1_ATTR_LOC_Y,attr);
     VDcnvDblToTxt(loc_z / i, attr); VDjt1SetAttr(nodeJD,VDCT1_ATTR_LOC_Z,attr);

     /* And change the tag ver */
     som_change_tag_version(nodeJD->id.osnum,nodeJD->id.objid,NULL,1);

  }

  /* -----------------------------------------
   * Go ahead and assign sirid if connected
   */
  if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP))
  {
    VDjt1GetAttr(nodeJD,VDCT1_ATTR_SIR_ID,sirid);
    if (*sirid == 0)
    {
      objOE = modelOE;
      objOE.obj_id = nodeJD->id;
      VDct1SirGrpGetTxtValFromPPL(&objOE, "genSirID", sirid);
      VDjt1SetAttr(nodeJD,VDCT1_ATTR_SIR_ID,sirid);
    }
  }
  
  // Call the engtree compute node first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->computeNode(nodeJD);
  
  // pre-expand the modelobject
  if (modelOE.obj_id.objid != NULL_OBJID) {
  
    strcpy(op," ");
    _RTCJDB(nodeJD)->preExpandContractNode(nodeJD,op);
 
  }

#if 0
  // have to double check.
  if( !strcmp(baseInfo.nodeType, VDCT1_ENG_NODE_TYPE_ITEM) )
  {
    sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,attr);
    VDASSERTW(sts&1); 

    _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
    VDASSERTW(parentJD.id.objid != NULL_OBJID);
    if( !strcmp(attr, VDCT1_DEFAULT_FROZEN_D) )
    {
	_RTCJDB(nodeJD)->deleteNode(nodeJD);
    }
    _RTCJDB(&parentJD)->computeNode(&parentJD);
  }
#endif

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* ------------------------------------------------------------
 * recomputer for move and copy nodes
 */
static IGRstat computeMoveCopyNode(TVDct1JD *parentJD,
				   TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeMoveCopyNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDctBaseInfo  baseInfo;
  
  VDASSERTW(parentJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // pull down parent attributes
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_NODE_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_PART_TYPE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_MINO);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_CAGE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ITEM_DESC);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_SIR_ID);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_SIR_TAG);
 
  _RTCJDB(parentJD)->computeNode(parentJD);

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* --------------------------------------------------------------------
 * Copies attributes from model to node
 * This needs to call a ppl
 */
static IGRstat copyAttributesFromModelToNode(TVDct1JD   *nodeJD,
					     TGRobj_env *modelOE)
{
  VDASSERT_FN("copyAttributesFromModelToNode");
  
  IGRstat       retFlag = 0;
  IGRstat       sts;

  IGRchar       buf[256];
  IGRchar       isdp_name[128], isdp_path[128];
  IGRchar	cage[128],mino[128],desc[128],model_id[128];

  IGRchar       loc_x[128],loc_y[128],loc_z[128];

  TVDctBaseInfo	baseInfo;
  TGRid         objID;
  TVDct1JD      parentClassJD;
  
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  objID.objid = NULL_OBJID;
  if (nodeJD)  objID = nodeJD->id;
  if (modelOE) objID = modelOE->obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;

  VDobjGetClassName(modelOE,NULL,buf);
    
  if (traceFlag) printf("### className = %s\n",buf);

  // this routine is only for parts 
  sts = VDjt1GetBaseInfo(nodeJD,&baseInfo);
  if(strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ITEM)) goto wrapup;
 
// copyAttributesFromModelToNode in EngTree will change node type to PART !!!
// we may copy some code segment from there to here
  // Call the ancestor first to get unit/zone/compt_number
  // parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  // _RTCJDB(&parentClassJD)->copyAttributesFromModelToNode(nodeJD,modelOE);

  // get in the data
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ATTR_ISDP_NAME, isdp_name);
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ATTR_ISDP_PATH, isdp_path);
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ATTR_MINO,      mino);
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ATTR_CAGE,      cage);
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ATTR_ITEM_DESC, desc);
  VDct1SirGrpGetTxtAttr(modelOE,VDCT1_ATTR_MODEL_ID,  model_id);

  VDobjGetTxtAtr(modelOE,NULL,VDCT1_ATTR_LOC_X,loc_x);
  VDobjGetTxtAtr(modelOE,NULL,VDCT1_ATTR_LOC_Y,loc_y);
  VDobjGetTxtAtr(modelOE,NULL,VDCT1_ATTR_LOC_Z,loc_z);

  // set attrbute data
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_ISDP_NAME, isdp_name);
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_ISDP_PATH, isdp_path);  
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_MINO,      mino);  
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_CAGE,      cage);  
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_ITEM_DESC, desc);  
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_MODEL_ID,  model_id);

  VDjt1SetAttr(nodeJD,VDCT1_ATTR_LOC_X,loc_x);  
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_LOC_Y,loc_y);  
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_LOC_Z,loc_z);  

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
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
  IGRstat       retFlag = 0;
  TVDctBaseInfo baseInfo;

  TVDct1JD parentClassJD;
  
  // Arg check
  if (txt == NULL) goto wrapup;
  *txt = 0;
  if (formName == NULL) goto wrapup;
  
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

      // GROUP_TREE (Tree) options
      if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PLGRPTREE)) {
	switch(nth) {
	case 0: strcpy(txt,"1 Review    Node");      break;
	case 1: strcpy(txt,"2 Create    Node");      break;
	case 2: strcpy(txt,"3 Create Model Node");   break;
	case 3: strcpy(txt,"7 ReCompute Node");      break;
	case 4: strcpy(txt,"D Delete    Node");      break;
	case 5: strcpy(txt,"R Rename    Node");      break;
	case 6: strcpy(txt,"M Move      Node");      break;
	default: retFlag = 0;
	}
      }
      // PART_TYPE, COMPARTMENT
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART_TYPE) ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_COMPART) ) {
	switch(nth) {
	case  0: strcpy(txt,"1 Review  Node");       break;
	case  1: strcpy(txt,"2 Create  Node");       break;
	case  2: strcpy(txt,"7 ReCompute Node");     break;
	case  3: strcpy(txt,"C Convert Node");       break;
	case  4: strcpy(txt,"D Delete  Node");       break;
	case  5: strcpy(txt,"R Rename  Node");       break;
	case  6: strcpy(txt,"P Paste   Node(s)");    break;
	case  7: strcpy(txt,"M Move    Node");       break;
	default: retFlag = 0;
	}
      }
      // GROUP nad NOT_IN_GROUP options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP) ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP) ) { 
	switch(nth) {
	case  0: strcpy(txt,"1 Review  Node");       break;
	case  1: strcpy(txt,"2 Create  Node");       break;
	case  2: strcpy(txt,"3 Create  Model Node"); break;
	case  3: strcpy(txt,"7 ReCompute Node");     break;
	case  4: strcpy(txt,"C Convert Node");       break;
	case  5: strcpy(txt,"D Delete  Node");       break;
	case  6: strcpy(txt,"R Rename  Node");       break;
	case  7: strcpy(txt,"P Paste   Node(s)");    break;
	case  8: strcpy(txt,"M Move    Node");       break;
	default: retFlag = 0;
	}
      }

      // ALL OTHER  options
      else {
	switch(nth) {
	  case 0: strcpy(txt,"1 Review    Node");      break;
	  case 1: strcpy(txt,"7 ReCompute Node");      break;
	  case 2: strcpy(txt,"C Convert   Node");      break;
	  case 3: strcpy(txt,"D Delete    Node");      break;
	  case 4: strcpy(txt,"R Rename    Node");      break;
	  case 5: strcpy(txt,"P Paste     Node(s)");   break;
	  case 6: strcpy(txt,"M Move      Node");      break;
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
 * get the node type for the model object,
 */
static IGRstat getTypeForModelObject(TVDct1JD      *parentNodeJD,
                                     TGRobj_env    *modelOE,
                                     TVDctNodeType nodeType)
{
  VDASSERT_FN("getTypeForModelObject");
 
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;

  // Arg check
  VDASSERTW(parentNodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeType);

  // init
  *nodeType = 0;

  // just set it equal to a part
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_ITEM);

  // Done


wrapup:
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,nodeType);

  return retFlag;
}


/* ------------------------------------------
 * check to see if move node is OK
 * OK if it passes through
 */
static IGRstat isMoveNodeValid(TVDct1JD  *parentJD,
                               TVDct1JD  *movedJD)
{
  VDASSERT_FN("isMoveNodeValid");
 
  IGRstat	retFlag = 0;
  IGRstat	sts;
 
  IGRchar	movedComptNo[64];
  IGRchar	movedPartType[64];
  IGRchar	parentComptNo[64];
  IGRchar	parentPartType[64];
  TVDctBaseInfo	parentBaseInfo;
  TVDctBaseInfo	movedBaseInfo;
  TVDct1JD	parentClassJD;
 
  VDASSERTW(parentJD->id.objid != NULL_OBJID);
  VDASSERTW( movedJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
 
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if( *parentBaseInfo.nodeType == 0 || *parentBaseInfo.setType == 0) goto wrapup;

  _RTCJDB(movedJD)->getBaseInfo(movedJD,&movedBaseInfo);
  if( *movedBaseInfo.nodeType == 0 || *movedBaseInfo.setType == 0) goto wrapup;

  // have to be in the same tree
  if( strcmp(parentBaseInfo.setType,movedBaseInfo.setType) ) goto wrapup;

  // if compartment number different, can't move it
  *parentComptNo = 0;
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_COMPARTMENT,parentComptNo);
  if (*parentComptNo == 0) goto wrapup;

  *movedComptNo = 0;
  _RTCJDB(movedJD)->getAttr(movedJD,VDCT1_ATTR_COMPARTMENT,movedComptNo);
  if (*movedComptNo == 0) goto wrapup;

  // compare compartment
  if( strcmp( parentComptNo,movedComptNo) ) goto wrapup;

  // if part type different, can't move to it
  // only chech parent first, and parent class will control other cases
  *parentPartType = 0;
  *movedPartType = 0;
  if( strcmp( parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PLGRPTREE) &&
      strcmp( parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_COMPART    )  )
  {
     _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_PART_TYPE,parentPartType);
     if (*parentPartType == 0) goto wrapup;

     _RTCJDB(movedJD)->getAttr(movedJD,  VDCT1_ATTR_PART_TYPE,movedPartType);
     if (*movedPartType == 0) goto wrapup;

     if( strcmp(parentPartType,movedPartType) ) goto wrapup;
  }

  // Standard process
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDC(&parentClassJD)->isMoveNodeValid(parentJD,movedJD);
  if( !sts ) goto wrapup;
 
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
 
  IGRstat	retFlag = 0;
  IGRstat	sts;

  IGRchar	copiedComptNo[64];
  IGRchar	copiedPartType[64];
  IGRchar	parentComptNo[64];
  IGRchar	parentPartType[64];
  TVDctBaseInfo	parentBaseInfo;
  TVDctBaseInfo	copiedBaseInfo;
  TVDct1JD	parentClassJD;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
 
  // Arg check
  VDASSERTW(parentJD);
  VDASSERTW(copiedJD);
 
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if( *parentBaseInfo.nodeType == 0 || *parentBaseInfo.setType == 0) goto wrapup;

  _RTCJDB(copiedJD)->getBaseInfo(copiedJD,&copiedBaseInfo);
  if( *copiedBaseInfo.nodeType == 0 || *copiedBaseInfo.setType == 0) goto wrapup;

  // have to be the same tree
  if( strcmp(parentBaseInfo.setType,copiedBaseInfo.setType) ) goto wrapup;

  // if compartment number different, can't paste to it
  *parentComptNo = 0;
  _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_COMPARTMENT,parentComptNo);
  if (*parentComptNo == 0) goto wrapup;

  *copiedComptNo = 0;
  _RTCJDB(copiedJD)->getAttr(copiedJD,VDCT1_ATTR_COMPARTMENT,copiedComptNo);
  if (*copiedComptNo == 0) goto wrapup;

  // compare compartment
  if( strcmp( parentComptNo,copiedComptNo) ) goto wrapup;

  // if part type different, can't paste to it
  // only chech parent first, and parent class will control other cases
  *parentPartType = 0;
  *copiedPartType = 0;
  if( strcmp( parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PLGRPTREE) &&
      strcmp( parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_COMPART    )  )
  {
     _RTCJDB(parentJD)->getAttr(parentJD,VDCT1_ATTR_PART_TYPE,parentPartType);
     if (*parentPartType == 0) goto wrapup;

     _RTCJDB(copiedJD)->getAttr(copiedJD,VDCT1_ATTR_COMPARTMENT,copiedPartType);
     if (*copiedPartType == 0) goto wrapup;

     if( strcmp(parentPartType,copiedPartType) ) goto wrapup;
  }

  // Standard process
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDC(&parentClassJD)->isPasteNodeValid(parentJD,copiedJD);
  if( !sts ) goto wrapup;

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
 */
static IGRstat getPasteNodeType(TVDct1JD          *parentJD, 
				TVDct1JD          *copyJD,
				TVDctNodeTypeInfo *info)
{

  IGRstat          retFlag = 0;
  TVDctBaseInfo    parentBaseInfo;
  TVDctBaseInfo    copyBaseInfo;
  IGRstat          sts;
  TVDct1JD         parentClassJD;
      
 
  //Init
  retFlag = 1;
  //traceFlag = traceFlagx;
    
  //Say hi
  if (traceFlag) printf(">>> Entering getPasteNodeType\n");
  
  //Arg check
  if (&parentJD == NULL) goto wrapup;
  if (&copyJD   == NULL) goto wrapup;
  
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
  //if need to convert type {
  //  strcpy(info->type, type_wanted);
  //  goto wrapup;
  //}

  // Everything else converts as is, send it up to production implementation
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDC(&parentClassJD)->getPasteNodeType(parentJD,copyJD,info);

  //Done
 
  
wrapup:
  if (traceFlag) printf("<<< Leaving getPasteNodeType [%s]\n",info->type);
  return 1;
}

/* ---------------------------------------------
 * check that the model object is valid
 * - should be placeable
 * - should not already be connected to the tree
 */
static IGRstat isModelObjectValid(TVDct1JD   *nodeJD,
                                  TGRobj_env *modelOE)
{
  VDASSERT_FN("isModelObjectValid");
 
  IGRstat        retFlag = 0;
  IGRstat        sts;
  IGRchar        fileName[24];
  IGRchar        fileData[128];
  TVDct1JD       local_nodeJD;
  TGRobj_env     local_modelOE;
  TVDctBaseInfo  baseInfo;
  IGRchar        buf[64],*p;
   
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
 
  fileName[0] = '\0';
 
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // init (make some local copies)
  local_modelOE = *modelOE;
  local_nodeJD  = *nodeJD;

  // make a treeName
  // Get the info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  p = baseInfo.setType;
  sprintf(fileName,"%c%s.txt",*p,baseInfo.setName);

  // filter out unwanted objects
  // get the modelOE className
  VDobjGetClassName(&local_modelOE,NULL,buf);
  if (traceFlag) printf("modelOE className = %s\n",buf);
 
  // is it groupable
  if (traceFlag) printf("### %s %s checking groupable\n",ffn(),fn);

  sts = VDct1SirGrpIsPlaceable( &local_modelOE);
  if (!(sts & 1)) {
    sprintf(fileData,"Invalid Model Object: (%d,%d) not groupable\n",
           modelOE->obj_id.osnum,
           modelOE->obj_id.objid);
    printf(fileData);

    VDio_append_named_file(fileName,
                           fileData);
    /* appends file per request to allow user a file to view messages */
    goto wrapup;
  }

  // is it already connected
  sts = _RTCJDB(&local_nodeJD)->
    getModelObjectNode(&local_nodeJD,&local_modelOE,NULL,NULL,NULL,NULL,&local_nodeJD);
  if (sts) {
    sprintf(fileData,"Invalid Model Object: (%d,%d) Already in Tree\n",
           modelOE->obj_id.osnum,
           modelOE->obj_id.objid);
    printf(fileData);

    goto wrapup;
  }

  // Allowed to create model node under GROUP_TREE temporarily
  if(strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PLGRPTREE)){
    sts = isModelObjectValidInGroup(nodeJD, modelOE);
    if( !sts ) goto wrapup;
  }

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * check that the model object is valid to connect
 * - should have same cage-mino (nodename = mat_id_key)
 */
static IGRstat isConnectModelObjectValid(TVDct1JD   *nodeJD,
                                         TGRobj_env *modelOE)
{
  VDASSERT_FN("isConnectModelObjectValid");
 
  IGRstat        retFlag = 0;
  IGRstat        sts;
  TVDctBaseInfo  baseInfo;
  IGRchar        buf[128];
   
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
 

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Get the info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeName == 0) {
      printf("### %s FAILED:  Could not get Node Name\n",fn);
      goto wrapup;
  }

  /*
  // get the mat_id_key of the object
  *buf = 0;
  VDobjGetTxtAtr(modelOE,NULL,"mat_id_key",buf);
  if (*buf == 0) {
      printf("### %s FAILED: Could not get mat_id_key\n",fn);
      goto wrapup;
  }

  // compare them
  if (strcmp(baseInfo.nodeName,buf)) {
      printf("### %s FAILED: Node Name <%s> Mat_id_key <%s>\n",
              fn,baseInfo.nodeName,buf);
      goto wrapup;
  }
  */

  sts = isModelObjectValidInGroup(nodeJD, modelOE);
  if( !sts ) goto wrapup;


  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}



/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");
  IGRstat	retFlag = 0;
  TVDctBaseInfo	baseInfo;
  TVDctNodeType	parentType;
  TVDct1JD	childJD;
  IGRint	i, not_in_grp_flag = 0;
  
  // Arg check
  if (childType == NULL) goto wrapup;

  // Need the parent info
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&baseInfo);
  strcpy(parentType,baseInfo.nodeType);
  if (*parentType == 0) goto wrapup;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",_RTCJDBC(parentJD),fn,parentType,childType);
  }
  
  // OK By default
  retFlag = 1;

  // GROUP_TREE can have COMPARTMENT
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PLGRPTREE)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_COMPART))   goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ITEM))      goto wrapup;
  }
  
  // COMPARTMENT can have PART_TYPE
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_COMPART)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART_TYPE)) goto wrapup;
  }
  
  // PART_TYPE can have GROUP and NOT_IN_GROUP
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PART_TYPE)){

    // GROUP
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))      goto wrapup;

    // NOT_IN_GROUP, only one allowed
    for(i = 0; _RTCJDB(parentJD)->getTreeChild(parentJD,i,&childJD); i++ )
    {
	_RTCJDB(&childJD)->getBaseInfo(&childJD,&baseInfo);
	if( !strcmp(baseInfo.nodeType, VDCT1_ENG_NODE_TYPE_NOT_IN_GRP) )
	{
	   not_in_grp_flag = 1;
	   break;
	}
    }
    if( !not_in_grp_flag && !strcmp(childType,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP)) goto wrapup;
  }
  
  // GROUP can have ITEM
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ITEM))     goto wrapup;
  }
  
  // GROUP can have ITEM
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_GROUP)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ITEM))     goto wrapup;
  }
  
  //ITEM nothing
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ITEM)){
  }
  
  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(parentJD),fn,retFlag);
  }

  return retFlag;
}


/* -------------------------------------------------
 * delete a node
 */
static IGRstat deleteNode(TVDct1JD *nodeJD)
{ 
  VDASSERT_FN("deleteNode");
  
  IGRstat	retFlag = 0;
  TVDct1JD	parentClassJD;
  TVDct1JD	parentJD;
  TVDctBaseInfo	baseInfo;

  // Arg Check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->cl != NULL);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  parentJD.id.objid = NULL_OBJID;
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD, &baseInfo); 
  if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ITEM))
  {
    _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
  }

  // Use standard node delete routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->deleteNode(nodeJD);
  
  // Compute GROUP and NOT_INGROUP
  if( parentJD.id.objid != NULL_OBJID ) _RTCJDB(&parentJD)->computeNode(&parentJD);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* --------------------------------------------------------------------
 * Connects a node to a model object
 */
static IGRstat connectModelObject(TVDct1JD *nodeJD, TGRobj_env *modelOE)
{
  VDASSERT_FN("connectModelObject");
 
  IGRstat       retFlag = 0;
  IGRstat       sts,msg;
  IGRboolean    tagFlag = 0;
  TGRobj_env	objOE;
  TVDct1JD	parentClassJD;
  TVDct1JD	parentJD, cmpJD, ptJD, ntgpJD;
  IGRchar	comptNo[80], partType[80], grpName[80], itemName[80];
  TVDctBaseInfo	nodeBaseInfo, parentBaseInfo;

  TGRid  nodeID;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Use standard routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDB(&parentClassJD)->connectModelObject(nodeJD,modelOE);
  VDASSERTW(sts);

  // Get baseInfo
  _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
  VDASSERTW(parentJD.id.objid != NULL_OBJID);
  _RTCJDB(nodeJD   )->getBaseInfo(nodeJD,   &nodeBaseInfo); 
  _RTCJDB(&parentJD)->getBaseInfo(&parentJD,&parentBaseInfo); 

  // Validate position
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PLGRPTREE) &&
      !strcmp(nodeBaseInfo.nodeType,  VDCT1_ENG_NODE_TYPE_ITEM))
  {
    VDct1SirGrpGetTxtAttr(modelOE, VDCT1_ISDP_ATTR_COMPARTMENT, comptNo);
    VDct1SirGrpGetTxtAttr(modelOE, VDCT1_ATTR_PART_TYPE,   partType);
    VDct1SirGrpGetTxtAttr(modelOE, VDCT1_ATTR_GROUP_NAME,  grpName);
    VDct1SirGrpGetTxtAttr(modelOE, VDCT1_ATTR_ITEM_NAME,   itemName);

    // check COMPARTMENT 
    _RTCJDB(&parentJD)->findNodeByTypeName (	&parentJD,
						0,
						VDCT1_FIND_NODE_OPT_NODE_KIDS,
						VDCT1_ENG_NODE_TYPE_COMPART,
						comptNo,
						&cmpJD);
    if( cmpJD.id.objid == NULL_OBJID )
    {
       _RTCJDB(&parentJD)->createNode(&parentJD,VDCT1_ENG_NODE_TYPE_COMPART,comptNo,&cmpJD);
       VDASSERTW(cmpJD.id.objid != NULL_OBJID);
    }

    // check PART_TYPE 
    _RTCJDB(&cmpJD)->findNodeByTypeName (	&cmpJD,				// curr
						0,				// case
						VDCT1_FIND_NODE_OPT_NODE_KIDS,	// opt
						VDCT1_ENG_NODE_TYPE_PART_TYPE,	// type
						partType,			// name
						&ptJD);
    if(ptJD.id.objid == NULL_OBJID )
    {
       _RTCJDB(&cmpJD)->createNode(&cmpJD,VDCT1_ENG_NODE_TYPE_PART_TYPE,partType,&ptJD);
       VDASSERTW(ptJD.id.objid != NULL_OBJID);
    }

    // check NOT_IN_GROUP
    _RTCJDB(&ptJD)->findNodeByTypeName (	&ptJD,				// curr
						0,				// case
						VDCT1_FIND_NODE_OPT_NODE_KIDS,	// opt
						VDCT1_ENG_NODE_TYPE_NOT_IN_GRP,	// type
						partType,			// name
						&ntgpJD);
    if( ntgpJD.id.objid == NULL_OBJID )
    {
       _RTCJDB(&ptJD)->createNode(&ptJD,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP,partType,&ntgpJD);
       VDASSERTW(ntgpJD.id.objid != NULL_OBJID);
    }

    // disconnect ITEM node from GROUP_TREE
    sts = _RTCJDB(&parentJD)->disconnectTreeChild(&parentJD, nodeJD);
    VDASSERTW(sts&1);

    // connect ITEM node to NOT_IN_GROUP
    sts = _RTCJDB(&ntgpJD)->connectTreeChild(&ntgpJD, nodeJD);
    VDASSERTW(sts&1);

    // Pull down some values
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_NODE_NUM);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_PART_TYPE);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_MINO);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_CAGE);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ITEM_DESC);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_SIR_ID);
    VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_SIR_TAG);

    sts = _RTCJDB(&ntgpJD)->computeNode(&ntgpJD);

    objOE.obj_id = nodeJD->id;
    sts = VDct1SirGrpGetTxtAttr(&objOE, "getItemNodeName", itemName); 
    if( sts ) 
    {
       strcpy( nodeBaseInfo.nodeName, itemName);
       _RTCJDB(nodeJD)->setBaseInfo(nodeJD, &nodeBaseInfo);
    }
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
 * Create a node
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{ 
  VDASSERT_FN("createNode");
  
  IGRstat	retFlag = 0;
  TVDct1JD	parentClassJD;
  IGRchar	op[3];
  TVDrisInfo	ris;
    
  // Arg check
  VDASSERTW((parentJD->id.objid != NULL_OBJID) && (parentJD->cl != NULL));
  VDASSERTW(nodeType != NULL);
  VDASSERTW(nodeName != NULL);
  VDASSERTW(nodeJD);
  
  // init
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;

   // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),fn,_RTCJDBC(parentJD),nodeType,nodeName);
  }

  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // Init the date
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_ASSY_DATE);
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_PART_DATE);

  // Pull down some values and set them
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_NODE_NUM);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_PART_TYPE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_MINO);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_CAGE);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_ITEM_DESC);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_SIR_ID);
  VDjt1PullDownAttr(nodeJD,VDCT1_ATTR_SIR_TAG);
 
  //default attribute set
  // Only set defaults for tree tops, the rest will pull down.
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PLGRPTREE)) {
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_FROZEN,   VDCT1_DEFAULT_FROZEN);
  }

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------------------
 * Create a set, override for check if only one tree
 */
static IGRstat createSet(TVDct1JD *mgrJD,
                         IGRchar  *setType,
                         IGRchar  *setTypeRev,
                         IGRchar  *setName,
                         TVDct1JD *setJD)
{
  VDASSERT_FN("createSet");
  IGRstat	retFlag = 0;

  IGRchar	msgStr[128], buf[256];
  IGRchar	compt[80], ptype[80], notGrp[80], mino[80], cage[80], desc[128];
  IGRchar	zone[80], unit[80];
  IGRint	i, j, k;
  IGRint	itemCnt   = 0;
  TVDSirGrpInfo	*itemInfo = NULL;
  TVDct1JD	parentClassJD;
  TVDct1JD	rootJD, comptJD, ptypeJD, notGrpJD, itemJD;

  // Arg Check
  VDASSERTW(setJD);
  VDASSERTW(mgrJD);
  VDASSERTW(setType);
  VDASSERTW(setName);
 
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }

  if( getMyTree(NULL) ) {
     sprintf(msgStr,"More than one %s tree NOT allowed !", MY_TREE);
     UI_status(msgStr);
     goto wrapup;
  }
  
  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createSet(mgrJD,setType,setTypeRev,setName,setJD);
  if (setJD->id.objid == NULL_OBJID) goto wrapup;

  // Create COMPARTMENT->PART_TYPE->NOT_IN_GROUP
  VDct1SirGrpGetItemInfo(&itemCnt, &itemInfo);
  VDASSERTW(itemCnt);
  VDASSERTW(itemInfo);

  VDASSERTW(getMyTree(&rootJD) && rootJD.id.objid != NULL_OBJID);

  compt[0] = '\0';
  for( i = 0; i < itemCnt;  )
  {
     // Create COMPARTMRNT under root
     strcpy(compt, itemInfo[i].comptNo);
     _RTCJDB(&rootJD)->createNode(&rootJD,VDCT1_ENG_NODE_TYPE_COMPART,compt,&comptJD);
     VDASSERTW(comptJD.id.objid != NULL_OBJID);

     VDct1SirGrpGetTxtAttr(&itemInfo[i].objOE,VDCT1_ATTR_ZONE,zone);
     VDct1SirGrpGetTxtAttr(&itemInfo[i].objOE,VDCT1_ATTR_UNIT,unit);
     VDjt1SetAttr(&comptJD,VDCT1_ATTR_ZONE,zone);
     VDjt1SetAttr(&comptJD,VDCT1_ATTR_UNIT,unit);
     VDjt1SetAttr(&comptJD,VDCT1_ATTR_COMPARTMENT,compt);
     

     for( j = i; j < itemCnt && !strcmp( compt,itemInfo[j].comptNo);  )
     {
	// Create PART_TYPE under COMPARTMENT
	strcpy( ptype, itemInfo[j].partType );
        _RTCJDB(&comptJD)->createNode(&comptJD,VDCT1_ENG_NODE_TYPE_PART_TYPE,ptype,&ptypeJD);
        VDASSERTW(ptypeJD.id.objid != NULL_OBJID); 
	VDct1SirGrpGetTxtAttr(&itemInfo[j].objOE,VDCT1_ATTR_MINO,      mino);
	VDct1SirGrpGetTxtAttr(&itemInfo[j].objOE,VDCT1_ATTR_CAGE,      cage);
	VDct1SirGrpGetTxtAttr(&itemInfo[j].objOE,VDCT1_ATTR_ITEM_DESC, desc);
        VDjt1SetAttr(&ptypeJD,VDCT1_ATTR_PART_TYPE, ptype);
        VDjt1SetAttr(&ptypeJD,VDCT1_ATTR_MINO,      mino);
        VDjt1SetAttr(&ptypeJD,VDCT1_ATTR_CAGE,      cage);
        VDjt1SetAttr(&ptypeJD,VDCT1_ATTR_ITEM_DESC, desc);

	// Create NOT_IN_GROUP under PART_TYPE
	sprintf( notGrp, "%s", ptype );
        _RTCJDB(&ptypeJD)->createNode(&ptypeJD,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP,notGrp,&notGrpJD);
        VDASSERTW(notGrpJD.id.objid != NULL_OBJID); 

	for( k = j; k < itemCnt				&& 
		    !strcmp(compt,itemInfo[k].comptNo)	&& 
		    !strcmp(ptype,itemInfo[k].partType);	k++ )
	{
	   // Create ITEM under NOT_IN_GROUP
	   createNode(&notGrpJD,VDCT1_ENG_NODE_TYPE_ITEM,itemInfo[k].itemName,&itemJD);
           VDASSERTW(itemJD.id.objid != NULL_OBJID); 
	   _RTCJDB(&itemJD)->connectModelObject(&itemJD, &itemInfo[k].objOE);
	   _RTCJDB(&itemJD)->copyAttributesFromModelToNode(&itemJD,&itemInfo[k].objOE);
	   /*
	   printf("i,j,k = (%d,%d,%d), model: %d,%d, itemNode: %d,%d\n",i,j,k,
		itemInfo[k].objOE.obj_id.objid,itemInfo[k].objOE.obj_id.osnum,
		itemJD.id.objid,itemJD.id.osnum);
	   */
	}
	j = k;
     }
     i = j;
  }

  // Done
  retFlag = 1;

wrapup:
  if( itemInfo ) free(itemInfo);
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

/* --------------------------------------------------
 * For a given set wide attribute name, fill in the info
 */
static IGRstat getNodeAttrInfo(TVDct1JD		*nodeJD,
                               IGRchar		*name,
                               TVDctAttrInfo	*info)
{
  IGRstat retFlag = 1;
  IGRstat sts;
 
  // Arg check
  if (info == NULL) goto wrapup;
  if (name == NULL) goto wrapup;

  // Have one standlone routine for the engineering stuff
  sts = VDct1EngTreeGetAttrInfo(name,info);
  if (sts & 1) {
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SIR_ID)) {
    VDctxSetAttrInfo(name,48,"SIRID","SIRID",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SIR_TAG)) {
    VDctxSetAttrInfo(name,48,"SR_TAG_NUM","SR_TAG_NUM",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_GROUP_NAME)) {
    VDctxSetAttrInfo(name,48,"GROUP_NAME","GROUP_NAME",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_NAME)) {
    VDctxSetAttrInfo(name,48,"ITEM_NAME","ITEM_NAME",info);
    goto wrapup;
  }

wrapup:
  if (retFlag == 0) {
    if (info) memset(info,0,sizeof(TVDctAttrInfo));
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
  //IGRstat traceFlag = traceFlagx;
  
  // Say hi
  //traceFlag = 0;
  if (traceFlag) {
    printf(">>> %s %s %s %2d\n",_RTCJDBC(nodeJD),fn,nodeType,nth);
  }
  
  // Init 
  if (attrName == NULL) goto wrapup;
  *attrName = 0;
  if (nodeType == NULL) goto wrapup;
  retFlag = 1;
  
  // tree GROUP_TREE
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PLGRPTREE)) {
    
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_NUM_NEXT);     goto wrapup;
    }
  }

  // COMPARTMENT
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_COMPART)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  2: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 

    }    
  }

  // PART_TYPE
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PART_TYPE)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  2: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  5: strcpy(attrName,VDCT1_ATTR_PART_TYPE);    goto wrapup; 
    case  6: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);    goto wrapup; 

    }    
  }

  // NOT_IN_GROUP
  if  (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP)) {
 
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  2: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  5: strcpy(attrName,VDCT1_ATTR_PART_TYPE);    goto wrapup; 
    case  6: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);    goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_LOC_X);        goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_LOC_Y);        goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_LOC_Z);        goto wrapup;
    }    
  }
  
  // GROUP
  if  (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {
    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
    case  2: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
    case  5: strcpy(attrName,VDCT1_ATTR_PART_TYPE);    goto wrapup; 
    case  6: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup; 
    case  7: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);    goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
    case 10: strcpy(attrName,VDCT1_ATTR_SIR_ID);       goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_SIR_TAG);      goto wrapup;
    case 12: strcpy(attrName,VDCT1_ATTR_LOC_X);        goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_LOC_Y);        goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_LOC_Z);        goto wrapup;
    }    
  }
  
  // ITEM
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ITEM)) {

    switch(nth) {
    case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);         goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_PART_NO);        goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_PART_REV);       goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_ISDP_PATH);      goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_ISDP_NAME);      goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_TREE_NUM);       goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_NODE_NUM);       goto wrapup;
    case  7: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);    goto wrapup; 
    case  8: strcpy(attrName,VDCT1_ATTR_PART_TYPE);      goto wrapup; 
    case  9: strcpy(attrName,VDCT1_ATTR_MINO);           goto wrapup;
    case 10: strcpy(attrName,VDCT1_ATTR_CAGE);           goto wrapup;
    case 11: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);      goto wrapup; 
    case 12: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);     goto wrapup;
    case 13: strcpy(attrName,VDCT1_ATTR_MODEL_ID);       goto wrapup;
    case 14: strcpy(attrName,VDCT1_ATTR_LOC_X);        goto wrapup;
    case 15: strcpy(attrName,VDCT1_ATTR_LOC_Y);        goto wrapup;
    case 16: strcpy(attrName,VDCT1_ATTR_LOC_Z);        goto wrapup;
     }
  }

  // Not found
  retFlag = 0;
    
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
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 5;  // Set this to total number of nodes
  if (info == NULL) goto wrapup;

  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_COMPART);
    strcpy(info->desc,"COMPARTMENT");
    strcpy(info->level,"U00");
    strcpy(info->table,"vdct1_placegroup");
    return 1;

  case 1:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART_TYPE);
    strcpy(info->desc,"PART_TYPE");
    strcpy(info->level,"U01");
    strcpy(info->table,"vdct1_placegroup");
    return 1;

  case 2:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_NOT_IN_GRP);
    strcpy(info->desc, "NOT_IN_GROUP");
    strcpy(info->level,"U02");
    strcpy(info->table,"vdct1_placegroup");
    return 1;

  case 3:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_GROUP);
    strcpy(info->desc, "GROUP");
    strcpy(info->level,"U03");
    strcpy(info->table,"vdct1_placegroup");
    return 1;

  case 4:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ITEM);
    strcpy(info->desc, "ITEM");
    strcpy(info->level,"U04");
    strcpy(info->table,"vdct1_placegroup");
    return 1;

  case 5:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PLGRPTREE);
    strcpy(info->desc, "GROUP_TREE");
    strcpy(info->level,"S05");
    strcpy(info->table,"vdct1_outfit");
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
  printf("@@@ Hello from %s\n",
	 _RTCJDB(nodeJD)->info.type);
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
  
  strcpy(table_name,"tm_grpplace_dynamic"); // ??? "tm_outfit_dynamic");

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitGrpPlaceTreeClass(TVDct1EngTreeClass   *engCL, 
				   TVDct1GrpPlaceTreeClass *cl)
{
  VDASSERT_FN("VDct1InitGrpPlaceTreeClass");

  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag("Placement Group Tree");
  
  // Copy the root
  VDct1CopyRootImps(engCL,cl);
  cl->prod = engCL->prod;
  cl->eng  = engCL->eng;
  
  // Data
  strcpy(cl->base.info.type,MY_TREE);
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"SIR Group Placement");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;  
  cl->base.getNodeAttrName  = getNodeAttrName;  
  cl->base.getNodeAttrInfo  = getNodeAttrInfo;  
  cl->base.getFilter        = getFilter;

  cl->base.createSet        = createSet;  
  cl->base.createNode       = createNode; 
 
  cl->base.computeNode      = computeNode;
  cl->base.reComputeNode    = reComputeNode;

  cl->base.deleteNode       = deleteNode;
  cl->base.disconnectTreeChild       = disconnectTreeChild;
  cl->base.isChildTypeValid          = isChildTypeValid; 
  cl->base.isModelObjectValid        = isModelObjectValid;
  cl->base.isConnectModelObjectValid = isConnectModelObjectValid;
  cl->base.connectModelObject        = connectModelObject;
  cl->base.getTreePostTable          = getTreePostTable;
  
  cl->base.copyAttributesFromModelToNode = copyAttributesFromModelToNode;
  cl->base.updateNodesOnTree             = updateNodesOnTree;
  cl->base.getTypeForModelObject         = getTypeForModelObject;

  cl->cmd.isDeleteTreeValid = isDeleteTreeValid;
  cl->cmd.isCreateTreeValid = isCreateTreeValid;

  //Command Pointers
  cl->cmd.getGadgetText        = getGadgetText;
  cl->cmd.getPasteNodeType     = getPasteNodeType;
  cl->cmd.isPasteNodeValid     = isPasteNodeValid; 
  cl->cmd.isMoveNodeValid      = isMoveNodeValid; 
  cl->cmd.computeMoveCopyNode  = computeMoveCopyNode;

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}


