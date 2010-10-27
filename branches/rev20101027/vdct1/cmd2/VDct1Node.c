/* $Id: VDct1Node.c,v 1.8 2002/05/24 17:46:58 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/Vct1Node.C
 *
 * Description: Node Forms Manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Node.c,v $
 *      Revision 1.8  2002/05/24 17:46:58  jdsauby
 *      Added isConnectModelObjectValid per CR6383, JDS
 *
 *      Revision 1.7  2002/05/16 21:22:48  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.6  2002/01/07 18:55:23  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.5  2001/05/14 20:49:08  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.4  2001/04/30 12:31:05  jdsauby
 *      CR 5097, Cable crash when cable is bad, plus get rid of "No GetBaseInfo errors"  - jds
 *
 *      Revision 1.3  2001/03/09 19:28:54  jdsauby
 *      TR 4841, connect and disconnect model node
 *
 *      Revision 1.2  2001/01/25 16:04:54  jdsauby
 *      SP beta merge, wway tree was crashing
 *
 *      Revision 1.1  2001/01/14 16:21:13  art
 *      sp merge
 *
 * Revision 1.16  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.15  2000/10/24  14:05:06  pinnacle
 * js
 *
 * Revision 1.14  2000/10/11  20:29:04  pinnacle
 * js
 *
 * Revision 1.13  2000/09/25  20:42:06  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDobj2.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Part.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd/VDct1Node.c");

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */
static TVDct1CmdInfo  *cmdInfo;
static TVDct1UserInfo userInfo;

static TGRid activeNodeID;
static TGRid parentNodeID;
static TGRid pastedNodeID;

/* ------------------------------------------
 * fill in the TVDct1UserInfo struct
 */
static IGRstat getUserInfo()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // set userInfo.objOE
  userInfo.objOE = cmdInfo->locatedOE;
  if (userInfo.objOE.obj_id.objid == NULL_OBJID) goto wrapup;
    
  // set the windowID
  userInfo.windowID = cmdInfo->windowID;

  // get objInfo, desc, objName, objPath, disName, symb
  VDobjGetSymbology(&userInfo.objOE,NULL,&userInfo.symb);

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Post Node
 */
static IGRstat notifyPostNode()
{
  IGRstat retFlag;
  
  TVDct1JD workJD;
  
  // Fill In work information
  workJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (workJD.cl == NULL) goto wrapup;
  workJD.id = activeNodeID;

  // Post it
  VDjt1PostNode(&workJD,NULL);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Create a node and hook to a model object
 */
static IGRstat createModelNode(TGRobj_env *modelOE)
{
  VDASSERT_FN("createModelNode");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  
  IGRchar buf[128], buff1[128], buff2[128];
  IGRchar blank[128] = "";
  TVDctBaseInfo baseInfo, parentBaseInfo, baseInfo1;
  TVDct1JD nodeJD;
  TVDct1JD parentNodeJD;
    
  IGRint desFlag = 1;
  TVDctNodeType a_NodeType;
  TGRid         a_treeID;
  TVDfld        a_fld;
  IGRchar       msg[128]; 
  IGRchar       msg2[128];
  IGRchar       location[128];
  
  
  TVDct1_part_fld_part_cage_num part_cage_num;
  TVDct1_part_fld_part_id       part_id;
  

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // Arg check
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  
  // set the form status
  VDfrmSetSts(formInfo->form,"Create Model Node");
 
  parentNodeJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentNodeJD.cl == NULL) goto wrapup;
  parentNodeJD.id = parentNodeID;
 
  // get the node type  
  _RTCJDB(&parentNodeJD)->
    getTypeForModelObject(&parentNodeJD,modelOE,baseInfo.nodeType);
  if (*baseInfo.nodeType == 0) goto wrapup;
   
  // check for valid child type
  sts = _RTCJDB(&parentNodeJD)->isChildTypeValid(&parentNodeJD,baseInfo.nodeType);
  if (!(sts & 1)) {
    VDfrmSetSts(formInfo->form,"Invalid Child Type for Model Object");
    goto wrapup;
  }

  /* ----------------------------------------
   * isModelObjectValid
   * should prevent a CS from being in tree
   * should verify if it is in OPS
   * should verify that it is not already connected to a tree
   */
  sts = _RTCJDB(&parentNodeJD)->
    isModelObjectValid(&parentNodeJD,modelOE);
  if (!(sts & 1)) {
    VDfrmSetSts(formInfo->form,"Invalid Model Object");
    goto wrapup;
  }

  // get the node name
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_NAME,baseInfo.nodeName);

  _RTCJDB(&parentNodeJD)->
    getNodeNameForModelObject(&parentNodeJD,modelOE,baseInfo.nodeName);
  if (*baseInfo.nodeName == 0) goto wrapup;
  
  // Create the Node in the Tree
  _RTCJDB(&parentNodeJD)->
    createNode(&parentNodeJD,baseInfo.nodeType,baseInfo.nodeName,&nodeJD);
   
  if (nodeJD.id.objid == NULL_OBJID) {
    sprintf(buf,"Node Creation Failed For '%s', '%s'",
	    baseInfo.nodeType,
	    baseInfo.nodeName);
    VDfrmSetSts(formInfo->form,buf);  
    goto wrapup;
  }

  // Connect it up
  sts = _RTCJDB(&nodeJD)->connectModelObject(&nodeJD, modelOE);
  if (!(sts & 1)) {
    VDfrmSetSts(formInfo->form,"Model Connection Failed");
    goto wrapup;
  }

  // Allows filling in some display type attributes
  sts = _RTCJDC(&nodeJD)->setNodeUserInfo(&nodeJD,&userInfo);
  if (!(sts & 1)) {
    VDfrmSetSts(formInfo->form,"Set User Info failed");
    goto wrapup;
  }
  
  // Transfer some attributes
  //_RTCJDB(&nodeJD)->
  //  copyAttributesFromModelToNode(&nodeJD,modelOE);

  
  // Generic recomputer
  sts = _RTCJDB(&nodeJD)->computeNode(&nodeJD);
  if (!(sts & 1)) {
      VDfrmSetSts(formInfo->form,"Compute Node Failed");
      goto wrapup;
  }

  // summary of node totals up tree
  //  VDct1SummaryNode (&parentNodeID);

  // Need to tell the world (which activates the node and updates the forms)
  cmdInfo->mgr.createdNode(&nodeJD.id);

  // update the summary (why, CreatedNode should handle this)
  // VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  // VDct1FormUpdateVRTree(cmdInfo->lib.form,  VDCT_FORM_LIB_G_TREE);

  // Done
  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}


/* -------------------------------------------
 * Takes a modelObject, finds/creates a proper
 * parent node, the creates a model node under
 * appropriate parent node.
 */
static IGRstat autoCreateModelNodes(TGRobj_env *modelOE)
{
  VDASSERT_FN("autoCreateModelNodes");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  TVDct1JD parentNodeJD;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // Arg check
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  
  // set the form status
  VDfrmSetSts(formInfo->form,"Generate Model Node(s)");

  // need to start with something
  parentNodeJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentNodeJD.cl == NULL) goto wrapup;
  parentNodeJD.id = parentNodeID;
  
  // get parent Node for model object
  sts = _RTCJDB(&parentNodeJD)->
    getParentForModelObject(&parentNodeJD,modelOE);
  if (!(sts & 1)) goto wrapup;
  
  // set "global" parentNodeID = the new parentNodeJD.id
  parentNodeID = parentNodeJD.id;
  if (parentNodeID.objid == NULL_OBJID) goto wrapup;
  

  // call the createModelObject routine now that we have the correct parent
  sts = createModelNode(modelOE);
  if (!(sts & 1)) goto wrapup;
  
  // done
  //cmdInfo->mgr.createdNode(&parentNodeJD.id);
  
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}

/* -------------------------------------------
 * Connect Model node selected
 * **/
static IGRstat connectModelNode(TGRobj_env *modelOE)
{
  VDASSERT_FN("connectModelNode");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  IGRchar  msg[80],buf[80];

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  TVDct1JD      activeNodeJD;

  // Arg check
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  *buf = 0;

  // say hi
  if (traceFlag){
    printf(">>> %s %s\n",ffn(),fn);
  }

  // if activeNode on form is blank 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,buf);
 
  if(*buf == 0){
    sprintf(msg,"Must have Active Node to Connect");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // get some class
  activeNodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeNodeJD.cl == NULL) goto wrapup;
  activeNodeJD.id = activeNodeID;

  // for connecting and existing node to a model object
  // verify that a connection is valid.
  sts = _RTCJDB(&activeNodeJD)->
  		isConnectModelObjectValid(&activeNodeJD,modelOE);
  if (!(sts & 1)) {
      VDfrmSetSts(formInfo->form,"Cannot Connect Node to Object");
      goto wrapup;
  }
  
  // check that the model object is valid
  sts = _RTCJDB(&activeNodeJD)->
    isModelObjectValid(&activeNodeJD,modelOE);
  if (!(sts & 1)) {
    VDfrmSetSts(formInfo->form,"Invalid Model Object");
    goto wrapup;
  }

  // connect it up
  sts = _RTCJDB(&activeNodeJD)->connectModelObject(&activeNodeJD,modelOE);
  if (!(sts & 1)) {
    sprintf(msg,"%s Not Connected to Model Object",buf);
    VDfrmSetSts(formInfo->form,msg);
    goto wrapup;
  }

  // Generic recomputer
  _RTCJDB(&activeNodeJD)->computeNode(&activeNodeJD);

    // done
  retFlag = 1;

  // Need to tell the manager
  cmdInfo->mgr.createdNode(&activeNodeID);
  cmdInfo->mgr.activateNode(&activeNodeID);

  sprintf(msg,"Connected %s to Model Object",buf);
  VDfrmSetSts(formInfo->form,msg);


wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

static IGRstat disconnectModelNode(TGRobj_env *modelOE)
{
  VDASSERT_FN("disconnectModelNode");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  IGRchar  msg[80],buf[80];

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  TVDct1JD      activeNodeJD;

  // Arg check
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  *buf = 0;

  // say hi
  if (traceFlag){
    printf(">>> %s %s\n",ffn(),fn);
  }

  // if activeNode on form is blank 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,buf);
 
  if(*buf == 0){
    sprintf(msg,"Must have an Active Node");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // get some class
  activeNodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeNodeJD.cl == NULL) goto wrapup;
  activeNodeJD.id = activeNodeID;

  // disconnect it
  sts = _RTCJDB(&activeNodeJD)->disconnectModelObject(&activeNodeJD,modelOE);
  if (!(sts & 1)) {
    VDfrmSetSts(formInfo->form,"Node still connected");
    goto wrapup;
  }

  VDfrmSetSts(formInfo->form,"Model Object Disconnected");
  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * Traffic directory for handling located objects
 */
static IGRstat locatedObject()
{
  VDASSERT_FN("locatedObject");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  
  IGRchar buf[256];

  TGRobj_env modelOE;
  
  // init modelOE
  modelOE = cmdInfo->locatedOE;
  VDASSERTW((modelOE.obj_id.objid != 0) && (modelOE.obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag){
    printf(">>> %s %s (%d,%d)\n",
           ffn(),fn,modelOE.obj_id.osnum,modelOE.obj_id.objid); 
  }

  // get User Info
  getUserInfo();
  
  // Switch on doit
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_DOIT,buf);

  switch(*buf) {

  case '3': 
    createModelNode(&modelOE);
    retFlag = 1;
    break;

  case '4':
    autoCreateModelNodes(&modelOE);
    retFlag = 1;
    break;
    
  case '5': 
    sts = connectModelNode(&modelOE);
    retFlag = 1;
    break;

  case '6':
    // disconnects a modelpart from its modelOE
    disconnectModelNode(&modelOE);
    retFlag = 1;
    break;
  }
  
wrapup: 
  if (traceFlag){
    printf("<<< %s %s %d\n",ffn(),fn,retFlag); 
  }
  
  return retFlag;
}


/* -------------------------------------------
 * Move active node to parent node
 * Make sure they are in the same tree
 */
static IGRstat notifyMoveNode()
{
  VDASSERT_FN("notifyMoveNode");
  
  IGRstat retFlag = 0;
  IGRstat sts, failedSts = 0;
  IGRint  noFlag;
  
  IGRint  i;
  IGRchar failedList[1024];
  IGRchar failedMsg[128];
  IGRchar msg[128];
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  
  TVDctBaseInfo parentBaseInfo;
  TVDctBaseInfo baseInfo;
  
  TVDct1JD parentJD;
  TVDct1JD parentNodeJD;
  TVDct1JD movedJD;

  TGRid    movedID;
  
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

   sprintf(failedMsg,"All Nodes not moved\nReview the list?\n");

  // Need a destination
  parentNodeJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentNodeJD.cl == NULL) goto wrapup;
  parentNodeJD.id = parentNodeID;
  
  _RTCJDB(&parentNodeJD)->getBaseInfo(&parentNodeJD,&parentBaseInfo);
  if (*parentBaseInfo.nodeType == 0) {
    VDfrmSetSts(formInfo->form,"Need An Active Parent");
    goto wrapup;
  }
  
  // Need a source
   // Get the number of nodes in the buffer, tell the user
  i = 0;
  while(VDct1GetNthIDFromVLAID(i,&movedID)) i++;
  
  // ask if the user wants to paste these items
  sprintf(msg,"Move ClipBoard? (%d items)",i);
  VDct1CmdBoxYesOrNo(msg,&noFlag);
  if (noFlag) goto wrapup;

  // init movedJD
  memset(&movedJD,0,sizeof(TVDct1JD));

  // Get the buffer and handle them one node at a time
  i = 0;
  while(VDct1GetNthIDFromVLAID(i,&movedID)) {
    
    // Get the tree class for movedJD, be careful
    // copiedJD class may differ from parentJD class
    movedJD.cl = VDct1GetTreeClassForNode(&movedID);
    if (movedJD.cl == NULL) goto nextOne;
    movedJD.id = movedID;
    _RTCJDB(&movedJD)->getBaseInfo(&movedJD,&baseInfo);
  
    // Validate Move node
    sts = _RTCJDC(&parentNodeJD)->
      isMoveNodeValid(&parentNodeJD,&movedJD);
    if (!(sts & 1)) {
      failedSts = 1;
      sprintf(msg,"Move of %s %s Not Valid\n",
	      baseInfo.nodeType,baseInfo.nodeName);
      strcat(failedList,msg);
      goto nextOne;
    }
    
    // need the old parent
    _RTCJDB(&movedJD)->getTreeParent(&movedJD,&parentJD);
    if (parentJD.id.objid == NULL_OBJID) {
      VDfrmSetSts(formInfo->form,"Active node has no parent???");
      goto nextOne;
    }
    
    // disonnect, reconnect to new parent
    sts = _RTCJDB(&parentJD)->disconnectTreeChild(&parentJD,&movedJD);
    if (!(sts & 1)) {
      failedSts = 1;
      sprintf(msg,"Move of %s %s Failed\n",
	      baseInfo.nodeType,baseInfo.nodeName);
      strcat(failedList,msg);
      goto nextOne;
    }
   
    sts = _RTCJDB(&parentNodeJD)->connectTreeChild(&parentNodeJD,&movedJD);
    if (!(sts & 1)) {
      failedSts = 1;
      sprintf(msg,"Move of %s %s Failed\n",
	      baseInfo.nodeType,baseInfo.nodeName);
      strcat(failedList,msg);
      goto nextOne;
    }
    
    sts = _RTCJDC(&parentNodeJD)->
      computeMoveCopyNode(&parentNodeJD,&movedJD);
    
    // Tell the manager what happened
    if (movedJD.id.objid != NULL_OBJID) {
       cmdInfo->mgr.deletedNode(&movedJD.id,&parentJD.id);
      cmdInfo->mgr.createdNode(&movedJD.id);
      cmdInfo->mgr.activateNode(&movedJD.id);
      goto nextOne;
    }
  
  nextOne:
    i++;
        
  } //end of while(VDct1GetNthIDFromVLAID(i,&nodeID)

  // if any nodes did not move, ask if user wants to see a list
  if (failedSts) {
    VDct1CmdBoxYesOrNo(failedMsg,&noFlag);
    if (!(noFlag & 1)) {
      VDct1CmdBoxMsg("See Console Window\nFor Details");
      printf("%s\n",failedList);
    }
    
  }
  

  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag); 
  }

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

/* ---------------------------------------------
 * Query Nodes button was pushed
 */
static IGRstat notifyQueryNode()
{
  VDASSERT_FN("notifyNodeQuery");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;

  TVDct1JD parentJD;
  
  // Arg check
  VDASSERTW(parentNodeID.objid != NULL_OBJID);

  //say hi
  if (traceFlag) printf("Calling VDct1CmdNodeQuery\n");

  // Do it
  parentJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentJD.cl == NULL) goto wrapup;
  parentJD.id = parentNodeID;

  sts = _RTCJDC(&parentJD)->createNodeByQuery(&parentJD);
  if (!(sts & 1)) goto wrapup;
  
  // tell the mgr what happened
  cmdInfo->mgr.createdNode(&parentJD.id);
  
  //VDct1FormUpdateTreeRow(cmdInfo->tree.form,VDCT_FORM_TREE_G_TREE,&parentNodeID);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* ------------------------------------------
 * helper function to notify paste node
 * function will paste children of node if the node itself
 * was not valid for pasting.
 */
static IGRstat pasteChildrenOfNode(TVDct1JD *parentJD,
				   TVDct1JD *copiedJD,
				   TVDct1JD *rootJD)
{
  VDASSERT_FN("pasteChildrenOfNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD  childJD;
    
  IGRint    i;
      
  VDASSERTW(parentJD->cl != NULL);
  VDASSERTW(copiedJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // get the children
  for (i = 0; _RTCJDB(copiedJD)->getTreeChild(copiedJD,i,&childJD) ; i++) {
        
    sts = _RTCJDC(parentJD)->
      isPasteNodeValid(parentJD,&childJD);
    if (sts & 1) {
      
      // do it
      sts = nodeCopyNode(parentJD,&childJD,rootJD);
      if (!(sts & 1)) goto wrapup;
    }
    
    else {
      // check the other kids
      sts = pasteChildrenOfNode(parentJD,&childJD,rootJD);
      if (!(sts & 1)) goto wrapup;
    }
  }

  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ------------------------------------------
 * Generate Pasted Nodes
 */
static IGRstat notifyAutoPasteNodes()
{
  VDASSERT_FN("notifyAutoPasteNodes");
  
  IGRstat retFlag = 0;
  IGRstat sts;
    
  TVDct1JD  parentJD,rootJD,copiedJD,newParentJD,nodeJD;
  TGRid     copiedID;
    
  TVDctBaseInfo baseInfo;
  
  IGRchar  failedMsg[256],msg[256];
  
  IGRint i,j;
  
  TVDct1NodeInfos  nodeInfos;
  TVDct1NodeInfo   nodeInfo;
  
  // say hi
  //traceFlag = 1;
  
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // check to make sure we have a parent selected, just for class
  if (parentNodeID.objid == NULL_OBJID) {
    sprintf(msg,"No parent selected");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  // Init
  parentJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentJD.cl == NULL) goto wrapup;
  parentJD.id = parentNodeID;
  memset(&baseInfo,0,sizeof(TVDctBaseInfo));
  
  sprintf(failedMsg,"All Nodes not pasted\nReview the list?\n");
  
  // Only tell the world about the first node created
  rootJD.id.objid = NULL_OBJID;
  
  // cycle through VLAID
  i = 0;
  while(VDct1GetNthIDFromVLAID(i,&copiedID)) {
    
    // Get the tree class for copiedJD, be careful
    // copiedJD class may differ from parentJD class
    copiedJD.cl = VDct1GetTreeClassForNode(&copiedID);
    if (copiedJD.cl == NULL) goto wrapup;
    copiedJD.id = copiedID;
    //  _RTCJDB(&copiedJD)->getBaseInfo(&copiedJD,&baseInfo);
   
    // Validate pasting is OK
    sts = _RTCJDC(&parentJD)->
      isPasteNodeValid(&parentJD,&copiedJD);
  
    // get list of nodes, and cycle through them
    if (!(sts & 1)) {

      // init nodeInfos
      VDct1InitNodeInfos(&nodeInfos);
      
      // set nodeInfos, current node down
      _RTCJDB(&copiedJD)->
	setNodeInfos(&copiedJD,VDCT1_SET_NODE_INFOS_NODE_DOWN,&nodeInfos);
      if (nodeInfos.cnt < 1) goto wrapup;
      if (traceFlag) printf("### number of nodes = %d\n",nodeInfos.cnt);
            
      // loop through nodeinfos
      for (j = 0; j < nodeInfos.cnt; j++) {
	
	_RTCJDB(&copiedJD)->getNthInfoFromNodeInfos(&copiedJD,&nodeInfos,j,&nodeInfo);
	if (nodeInfo.nodeJD.id.objid == NULL_OBJID) goto wrapup;
	
	if (traceFlag) printf ("### %s %s %s\n",ffn(),fn,nodeInfo.info.nodeName);
	
	
	// filter for nodevalidity
	if ( _RTCJDC(&parentJD)->isNodeInfoForPasteValid(&parentJD,&nodeInfo) ) {
	  
	  // if valid, find a newParent
	  _RTCJDC(&parentJD)->
	    getNewParentForPastedNode(&parentJD,&nodeInfo.nodeJD,&newParentJD);
	  
	  // double check
	  sts = _RTCJDC(&parentJD)->
	    isPasteNodeValid(&newParentJD,&nodeInfo.nodeJD);
	  // nodeCopy Node
	  if (sts & 1) nodeCopyNode(&newParentJD,&nodeInfo.nodeJD,&rootJD);
	 
	}
	
      }
      
      // free nodeInfos
      if (nodeInfos.cnt) VDct1FreeNodeInfos(&nodeInfos);
    }
   
    // do a recursive copy
    else nodeCopyNode(&parentJD,&copiedJD,&rootJD);
   
    i++;
        
  } //end of while(VDct1GetNthIDFromVLAID(i,&copiedID)
  
  if (rootJD.id.objid != NULL_OBJID) cmdInfo->mgr.createdNode(&rootJD.id);

  // done
  retFlag = 1;
  
 wrapup:
  if (nodeInfos.cnt) VDct1FreeNodeInfos(&nodeInfos);
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------
 * The Paste Node Button was pressed
 */
static IGRstat notifyPasteNode()
{
  VDASSERT_FN("notifyPasteNode");
  
  IGRstat retFlag = 0;
  IGRstat sts, failedSts = 0;
  IGRint  noFlag;
  
  IGRint  i;
  IGRchar failedList[1024];
  IGRchar failedMsg[128];
  IGRchar msg[128];
    
  TGRid     copiedID;
  
  TVDct1JD  parentJD;
  TVDct1JD  copiedJD;
  TVDct1JD  rootJD;
  
  TVDctBaseInfo  baseInfo;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // First of all, we need a parent
  if (parentNodeID.objid == NULL_OBJID) {
    sprintf(msg,"No parent selected");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  // Init
  parentJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentJD.cl == NULL) goto wrapup;
  parentJD.id = parentNodeID;
  memset(&baseInfo,0,sizeof(TVDctBaseInfo));
  
  sprintf(failedMsg,"All Nodes not pasted\nReview the list?\n");
  
  // Only tell the world about the first node created
  rootJD.id.objid = NULL_OBJID;
  
  // Get the number of nodes in the buffer, tell the user
  i = 0;
  while(VDct1GetNthIDFromVLAID(i,&copiedID)) i++;
  
  // ask if the user wants to paste these items
  sprintf(msg,"Paste ClipBoard? (%d items)",i);
  VDct1CmdBoxYesOrNo(msg,&noFlag);
  if (noFlag) goto wrapup;

  // init copiedJD
  memset(&copiedJD,0,sizeof(TVDct1JD));
  
  // Get the buffer and handle them one node at a time
  i = 0;
  while(VDct1GetNthIDFromVLAID(i,&copiedID)) {
    
    // Get the tree class for copiedJD, be careful
    // copiedJD class may differ from parentJD class
    copiedJD.cl = VDct1GetTreeClassForNode(&copiedID);
    if (copiedJD.cl == NULL) goto wrapup;
    copiedJD.id = copiedID;
    _RTCJDB(&copiedJD)->getBaseInfo(&copiedJD,&baseInfo);
   
    // Validate pasting is OK
    sts = _RTCJDC(&parentJD)->
      isPasteNodeValid(&parentJD,&copiedJD);
  
    // check to see if kids can be pasted, and recurse through children
    if (!(sts & 1)) {
      sts = pasteChildrenOfNode(&parentJD,&copiedJD,&rootJD);
      if (!(sts & 1)) {
	
	sprintf(msg,"Paste of %s %s Not Valid\n",
		baseInfo.nodeType,baseInfo.nodeName);
	strcat(failedList,msg);
	goto nextOne;
      }
      goto nextOne;
      
    }
   
    // do a recursive copy
    sts = nodeCopyNode(&parentJD,&copiedJD,&rootJD);
    if (!(sts & 1)) {
      failedSts = 1;
      sprintf(msg,"Paste of %s %s Failed\n",
	      baseInfo.nodeType,baseInfo.nodeName);
      strcat(failedList,msg);
      goto nextOne;
    }
    
    // Tell the manager a node has been created
    // if (rootJD.id.objid != NULL_OBJID) {
    //  cmdInfo->mgr.createdNode(&rootJD.id);
    //  goto nextOne;
    //}
  
  nextOne:
    i++;
        
  } //end of while(VDct1GetNthIDFromVLAID(i,&copiedID)
  
  // if any nodes did not paste, ask if user wants to see a list
  if (failedSts) {
    VDct1CmdBoxYesOrNo(failedMsg,&noFlag);
    if (!(noFlag & 1)) {
      VDct1CmdBoxMsg("See Console Window\nfor Details");
      printf ("%s\n",failedList);
    }
  }
  
  cmdInfo->mgr.createdNode(&rootJD.id);
  
  // Done
  retFlag = 1;

wrapup:

 // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/* -----------------------------------------------
 * Rename node was chosen
 */
static IGRstat notifyRenameNode()
{
  VDASSERT_FN("notifyRenameNode");
  
  IGRstat retFlag = 0;
  IGRchar newName[256];
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  
  TVDctBaseInfo activeBaseInfo;
  TVDctBaseInfo newBaseInfo;
  
  TGRid    nodeID;
  TGRid    treeID;
  TVDfld   fld;
  IGRchar  buf[128];
  IGRchar  location[128];
  IGRchar  msg[128];

  IGRstat  sts     = 0;
  IGRint   desFlag = 1;
  IGRint   yesFlag;
  
  TVDct1JD activeNodeJD;
  
  
  // say hi
  if (traceFlag){
    printf(">>> %s %s\n",ffn(),fn);
  }

  // if activeNode on form is blank 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,buf);
 
  if(!*buf){
    sprintf(msg,"Must have Active Node to rename");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // get base info of active node
  activeNodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeNodeJD.cl == NULL) goto wrapup;
  activeNodeJD.id = activeNodeID;
  
  _RTCJDB(&activeNodeJD)->getBaseInfo(&activeNodeJD,&activeBaseInfo);
  if (activeBaseInfo.nodeName == NULL) goto wrapup;

  newBaseInfo = activeBaseInfo;

  // Check to see that node can be renamed
  sts = _RTCJDC(&activeNodeJD)->
    isRenameNodeValid(&activeNodeJD,newBaseInfo.nodeType);
  if ((!sts & 1)) {
    sprintf(msg,"Rename of %s %s not permitted",
	    activeBaseInfo.nodeType,activeBaseInfo.nodeName);
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  
  // pull the new node name from the "Node" form 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_NAME,newBaseInfo.nodeName);

  // Set to a good node name
  sts = _RTCJDC(&activeNodeJD)->
    makeNodeName(&activeNodeJD,&newBaseInfo);
  if (!(sts & 1)) {
    sprintf(msg,"Could not make node name");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // check to see if new name = old name
  if (!strcmp(newBaseInfo.nodeName,activeBaseInfo.nodeName)) {
    sprintf(msg,"Node names are equal?");
    VDfrmSetSts(formInfo->form,msg);
    goto wrapup;
  }
  
  // Is new node name valid?
  sts = _RTCJDB(&activeNodeJD)->
    isNodeNameValid(&activeNodeJD,newBaseInfo.nodeType,newBaseInfo.nodeName,msg);
  if (!(sts & 1)) {  
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  } 
  
 
  // Confirm if Rename is to be done if no goto wrapup
  sprintf(msg,"%s Rename to %s?",
	  activeBaseInfo.nodeName,newBaseInfo.nodeName);
  VDct1CmdBoxYesOrNo(msg,&yesFlag);
  if (yesFlag & 1) goto wrapup;
 
  // Do it
  sts = _RTCJDB(&activeNodeJD)->
    setBaseInfo(&activeNodeJD,&newBaseInfo);
  if (!(sts & 1)) {
    sprintf(msg,"Rename Node Failed");
    VDfrmSetSts(formInfo->form,msg);
    goto wrapup;
  }
  
  // Need to tell the manager
  cmdInfo->mgr.renamedNode(&activeNodeID);
  
  // Done
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag){
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
  
}

/* ------------------------------------------------
 * Delete Node was chosen
 */
static IGRstat notifyDeleteNode()
{
  VDASSERT_FN("nodtifyDeleteNode");
  
  IGRstat retFlag   = 0;
  IGRstat sts;
  IGRint  noFlag;
  
  TVDct1JD parentJD;
  TVDct1JD activeJD;
  
  IGRchar nodeName[64];
  IGRchar msg[64];
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  // need an active node to delete
  VDASSERTW(activeNodeID.objid != NULL_OBJID);
    
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // need class
  activeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeJD.cl == NULL) goto wrapup;
  activeJD.id = activeNodeID;
  
  // get the active nodeName
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,nodeName);

  // need a parent
  _RTCJDB(&activeJD)->getTreeParent(&activeJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) {
    sprintf(msg,"Delete Failed\nNo Parent for %s",nodeName);
    goto wrapup;
  }
  
  // check the rules
  sts = _RTCJDC(&activeJD)->isDeleteNodeValid(&activeJD,&parentJD);
  if (!(sts & 1)) {
    sprintf(msg,"Deletion of %s\nNot Valid",nodeName);
    goto wrapup; 
  }

  // Confirm Deletion
  sprintf(msg,"Delete %s?",nodeName);
  VDct1CmdBoxYesOrNo(msg,&noFlag);
  if (noFlag) goto wrapup;
  
  // Delete the copied nodes from the original tree
  sts = _RTCJDB(&activeJD)->deleteNode(&activeJD);
  if (!(sts & 1)) {
    sprintf(msg,"Delete of %s Failed",nodeName);
    goto wrapup;
  }
  
  // Clear up the Node form Msg box
  sprintf(msg,"Deleted Node: %s",nodeName);
  VDfrmSetSts(formInfo->form,msg);
  
  // Clear up the Active Node  on the form
  VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,"");

  // Tell the world
  cmdInfo->mgr.deletedNode(&activeJD.id,&parentJD.id);
  
  // recalculate the parentID (node) etc.
  // summary of node totals up tree
  //VDct1SummaryNode (&parentID);

  // update the summary
  //VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  //VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  
  // Done
  retFlag = 1;
 
wrapup:
  if (!retFlag) VDct1CmdBoxMsg(msg);
 
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------------
 * Converter for TYPE and NAME of a node
 * converts the active node type and name to
 * the edit node type and name
 */
static IGRstat notifyConvertNode()
{
  VDASSERT_FN("notifyConvertNode");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  TVDctBaseInfo   activeBaseInfo, newBaseInfo;
  
  TVDct1JD  activeNodeJD;
  TVDct1JD  nodeJD;
  TVDct1JD  parentJD;
  
  IGRchar   msg[128];
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // args check
  VDASSERTW(activeNodeID.objid != NULL_OBJID);
    
  // set the nodeJD stuff
  activeNodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeNodeJD.cl == NULL) goto wrapup;
  activeNodeJD.id = activeNodeID;
    
  // get the activeBaseInfo
  _RTCJDB(&activeNodeJD)->getBaseInfo(&activeNodeJD,&activeBaseInfo);  
  if (activeBaseInfo.nodeType == NULL) goto wrapup;

  // set the new base info
  newBaseInfo = activeBaseInfo;
  
  // get newNodeName and Type from form
  // Pull the node type 
  VDfrmGetgText(formInfo->form,
		VDCT_FORM_NODE_G_EDIT_NODE_TYPE,
		newBaseInfo.nodeType);

  // Pull the node name
  VDfrmGetgText(formInfo->form,
		VDCT_FORM_NODE_G_EDIT_NODE_NAME,
		newBaseInfo.nodeName);

  // Make a node name here, default will simply uppercase nodeName and nodeType
  sts = _RTCJDC(&activeNodeJD)->makeNodeName(&activeNodeJD,&newBaseInfo);
  if (!(sts & 1)) {
    sprintf(msg,"Could not make node name");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
    
  // reset the form
  VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_NAME,newBaseInfo.nodeName);
 
  // Check to make sure type conversion is OK
  sts = _RTCJDC(&activeNodeJD)->
    isConvertNodeValid(&activeNodeJD,activeBaseInfo.nodeType,newBaseInfo.nodeType);
  if (!(sts & 1)) {
    sprintf(msg,"Cannot convert %s to %s",
	    activeBaseInfo.nodeType,newBaseInfo.nodeType);
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  // Validate node name, tree interface
  sts = _RTCJDB(&activeNodeJD)->
    isNodeNameValid(&activeNodeJD,newBaseInfo.nodeType,newBaseInfo.nodeName,msg);
  if (!(sts & 1)) { 
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // validate the node type for creation
  sts = _RTCJDB(&activeNodeJD)->
    getTreeParent(&activeNodeJD,&parentJD);
  if (!(sts & 1)) goto wrapup;
  
  sts = _RTCJDB(&parentJD)->
    isChildTypeValid(&parentJD,newBaseInfo.nodeType);
  if (!(sts & 1)) {
    sprintf(msg,
	    "Node Type %s not valid",newBaseInfo.nodeType);
    // tell the form
    VDfrmSetSts(formInfo->form,msg);  
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  /* ------------------------------------------------
   * Information on form is validated.  Convert it
   */
  sts = _RTCJDC(&activeNodeJD)->
    convertNode(&activeNodeJD,newBaseInfo.nodeType,newBaseInfo.nodeName);
  if (!(sts & 1)) {
    sprintf(msg,"Convert %s to %s Failed",
	    activeBaseInfo.nodeType,newBaseInfo.nodeType);
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  // update the summary
  //VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  //VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  
  cmdInfo->mgr.createdNode (&activeNodeID);
  cmdInfo->mgr.activateNode(&activeNodeID);
  

  // put the notice of what happened on the form
  sprintf(msg,"Converted: %s %s",newBaseInfo.nodeType,newBaseInfo.nodeName);
  VDfrmSetSts(formInfo->form,msg);

  // success
  retFlag = 1;


wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
  
}

/* ------------------------------------------
 * The re-compute stdassy button was pushed
 * **/
static IGRstat notifyReComputeStdAssy()
{
  VDASSERT_FN("notifyReComputeStdAssy");

  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  TVDctBaseInfo baseInfo;
  
  IGRchar buf[128];
  IGRchar msg[128];
  
  TVDct1JD nodeJD;
  TVDct1JD parentNodeJD;

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // if activeNode on form is blank 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,buf);
 
  if(!*buf){
    sprintf(msg,"Must have Active Node to recompute");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // get active node
  nodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (nodeJD.cl == NULL) goto wrapup;
  nodeJD.id = activeNodeID;

  if (nodeJD.id.objid == NULL_OBJID) goto wrapup;

  // tell the user it is working
  VDfrmSetSts(formInfo->form,"Computing StdAssy(s) ...");

  // do it
  _RTCJDB(&nodeJD)->reComputeStdAssy(&nodeJD);

  // done
  retFlag = 1;
  
  // Need to tell the manager
  cmdInfo->mgr.renamedNode(&activeNodeID);

  VDfrmSetSts(formInfo->form,"ReCompute of StdAssy(s) complete");
 
wrapup:
  return retFlag;
}


/* ------------------------------------------
 * The re-compute Node button was pushed
 * **/
static IGRstat notifyReComputeNode()
{
  VDASSERT_FN("notifyReComputeNode");

  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  TVDctBaseInfo baseInfo;
  
  IGRchar buf[128];
  IGRchar msg[128];
  
  TVDct1JD nodeJD;
  TVDct1JD parentNodeJD;

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // if activeNode on form is blank 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,buf);
 
  if(!*buf){
    sprintf(msg,"Must have Active Node to recompute");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // get active node
  nodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (nodeJD.cl == NULL) goto wrapup;
  nodeJD.id = activeNodeID;

  if (nodeJD.id.objid == NULL_OBJID) goto wrapup;

  // tell the user it is working
  VDfrmSetSts(formInfo->form,"Computing Node(s) ...");

  // do it
  _RTCJDB(&nodeJD)->reComputeNode(&nodeJD);

  // done
  retFlag = 1;
  

  // Need to tell the manager
  //cmdInfo->mgr.createdNode(&activeNodeID);
  cmdInfo->mgr.renamedNode(&activeNodeID);

  VDfrmSetSts(formInfo->form,"ReCompute of Node(s) complete");
  
wrapup:
  return retFlag;
}


static void notifyDeleteMarkedNodes()
{
    VDASSERT_FN("notifyDeleteMarkedNodes");
    IGRstat sts;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  TVDctBaseInfo baseInfo;
  
  IGRchar buf[128];
  IGRchar msg[128];
  
  TVDct1JD nodeJD;
  TVDct1JD parentNodeJD;

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // if activeNode on form is blank 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,buf);
 
  if(!*buf){
    sprintf(msg,"Must have Active Node");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // get active node
  nodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (nodeJD.cl == NULL) goto wrapup;
  nodeJD.id = activeNodeID;

  if (nodeJD.id.objid == NULL_OBJID) goto wrapup;

  // tell the user it is working
  VDfrmSetSts(formInfo->form,"Deleting Node(s) ...");

  // do it
  _RTCJDB(&nodeJD)->deleteMarkedNodes(&nodeJD);


  // Need to tell the manager
  cmdInfo->mgr.renamedNode(&activeNodeID);

  VDfrmSetSts(formInfo->form,"Marked for Delete Nodes Deleted");
  
wrapup:
  return;
}



/* -------------------------------------------
 * The Create Node Button Was Pushed
 */

static IGRstat notifyCreateNode()
{
  VDASSERT_FN("notifyCreateNode");
  
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
    
  TVDctBaseInfo baseInfo;
  
  IGRchar buf[128];
  IGRchar msg[128];
  
  TVDct1JD nodeJD;
  TVDct1JD parentNodeJD;
  
  // say hi
  if (traceFlag){
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Validate that parent has been selected 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_PARENT_NODE,buf);
  
  if (!*buf) {
    sprintf(msg,
	    "No Parent Selected");
    VDct1CmdBoxMsg(msg); 
    goto wrapup;    
  }
  
  // Pull the node type,name 
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_TYPE,baseInfo.nodeType);
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_NAME,baseInfo.nodeName);

  /* ------------------------------------------------
   * Need to do some checks and balances before 
   * node creation can continue
   */
  parentNodeJD.id = parentNodeID;
  parentNodeJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentNodeJD.cl == NULL) goto wrapup;
  
  // Make a node name here, default will simply uppercase nodeName and nodeType
  sts = _RTCJDC(&parentNodeJD)->makeNodeName(&parentNodeJD,&baseInfo);
  if (!(sts & 1)) {
    sprintf(msg,"Could not make node name");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
    
  // reset the form
  VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_NAME,baseInfo.nodeName);

  // Validate node name, tree interface
  sts = _RTCJDB(&parentNodeJD)->
    isNodeNameValid(&parentNodeJD,baseInfo.nodeType,baseInfo.nodeName,msg);
  if (!(sts & 1)) {  
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  // validate the node type for creation
  sts = _RTCJDB(&parentNodeJD)->
    isChildTypeValid(&parentNodeJD,baseInfo.nodeType);
  if (!(sts & 1)) {
    sprintf(msg,"Node Type %s not valid",baseInfo.nodeType);
    // tell the form
    VDfrmSetSts(formInfo->form,msg);  
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  /* ------------------------------------------------
   * Information on form is validated.  Create it
   */
    
  _RTCJDB(&parentNodeJD)->
    createNode(&parentNodeJD,baseInfo.nodeType,baseInfo.nodeName,&nodeJD);

  if (nodeJD.id.objid == NULL_OBJID) {
     sprintf(msg,"Node Creation Failed For '%s', '%s'",
	     baseInfo.nodeType,
	     baseInfo.nodeName);
 
     VDfrmSetSts(formInfo->form,msg);
     VDct1CmdBoxMsg(msg);
     goto wrapup;
  }

  // Need to tell the world (which activates the node and updates the forms)
   cmdInfo->mgr.createdNode (&nodeJD.id);
   cmdInfo->mgr.activateNode(&nodeJD.id);
   
  // update the summary
  //  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  //  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);

  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag){
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------------------
 * Doit processor
 */
static IGRstat notifyDoit()
{  
  VDASSERT_FN("notifyDoit");
  
  IGRstat retFlag;
  
  IGRchar cmd;
  IGRchar buf[128];

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  // say hi
  if (traceFlag){
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the command string
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_DOIT,buf);
  cmd = *buf;
  
  // Switch it
  switch(cmd) {
  
  case '2':
    notifyCreateNode();
    break;
    
  case '3':
    // VDct1CmdNodeNotifyCreateModelNode(); Actually a switch
    // see locatedObject
    break;
    
  case '4':
    //see locatedObject
    break;
    
  case '5':
    // see locatedObject
    break;
    
  case '6':
    // see locatedObject
    break;

  case '7': 
    notifyReComputeNode();
    break;

  case '8': 
    // Auto generate for pasted nodes
    notifyAutoPasteNodes();
    break;

  case '9': 
    notifyPostNode();
    break;

  case 'C':
    notifyConvertNode();
    break;

  case 'D':
    notifyDeleteNode();
    break;

  case 'R':
    notifyRenameNode();
    break;
    
  case 'P':
    notifyPasteNode();
    break;

  case 'Q':
    notifyQueryNode();
    break;
  
  case 'M':
    notifyMoveNode();
    break;

  case 'S':
    notifyReComputeStdAssy();
    break;

  case 'X':
    notifyDeleteMarkedNodes();
    break;
    
  case 'B':
    //notifyBOMNode();
    break;

  }  // end of switch
  
  // Done
  retFlag = 1;
  
wrapup:      

  // say bye
  if (traceFlag){
    printf("<<< %s %s cmd = %c\n",ffn(),fn,cmd);
  }

  return retFlag;
}

/* -------------------------------------------
 * The Parent Node Button was pushed
 */
static IGRstat notifyParentNode()
{
  VDASSERT_FN("notifyParentNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  TVDct1JD      parentNodeJD;
  TVDctBaseInfo parentNodeBaseInfo;

  IGRchar buf[80];
  IGRint  i;
  IGRint  row;
  
  TVDctNodeTypeInfo nodeTypeInfo;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Make it the parent
  parentNodeID = activeNodeID;
  parentNodeJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentNodeJD.cl == NULL) goto wrapup;
  parentNodeJD.id = parentNodeID;
  
  VDjt1GetBaseInfo(&parentNodeJD,&parentNodeBaseInfo);
  
  VDfrmSetgText(formInfo->form, 
		VDCT_FORM_NODE_G_PARENT_NODE,
		parentNodeBaseInfo.baseName);

  // Make sure have an object
  if (*parentNodeBaseInfo.nodeType == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Update the node type list
  VDfrmSetgListNumRows(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_TYPE,0);

  VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_TYPE,"");
  row = 0;
  for(i = 0; _RTCJDB(&parentNodeJD)->
	getNodeTypeInfo(&parentNodeJD,i,NULL,&nodeTypeInfo); i++)
  {
    
    // Is it a valid child type?
    sts = _RTCJDB(&parentNodeJD)->
      isChildTypeValid(&parentNodeJD,nodeTypeInfo.type);
   
    if (sts & 1) {
      
      // Make first one the default
      if (row == 0)  {
	VDfrmSetgText(formInfo->form, 
		      VDCT_FORM_NODE_G_EDIT_NODE_TYPE,
		      nodeTypeInfo.type);

      }
      // Add it to pull down list
      sprintf(buf,"%-8s %s",nodeTypeInfo.type,nodeTypeInfo.desc);
      VDfrmSetgListText(formInfo->form, 
			VDCT_FORM_NODE_G_EDIT_NODE_TYPE,row,buf);
      row++;
    }
  }
  
  // Reset pick list, Done during activate node?
  // Sometimes, both make sense
  VDct1CmdResetGadgetList(&parentNodeID,formInfo->form,VDCT_FORM_NODE_G_DOIT,1);

  // Done
  retFlag = 1;
  
wrapup:  

  // say bye
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}

/* -------------------------------------------
 * A node type was selected
 */
static IGRstat notifyNodeType()
{
  VDASSERT_FN("notifyNodeType");
  
  IGRstat retFlag = 0;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  
  IGRchar buf[128],*p;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Read it
  VDfrmGetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_TYPE,buf);
  VDfrmSetSts  (formInfo->form,"");
  
  // Break type and desc
  p = strchr(buf,' ');
  if (p == NULL) goto wrapup;
  *p = 0;
  VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_TYPE,buf);
  
  // Parse and move
  for(p++; (*p == ' '); p++);
  if (*p) {
    VDfrmSetSts(formInfo->form,p);
  }
  
  // done
  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -------------------------------------------
 * Node was deleted  
 */
static IGRstat deletedNode(TGRid *nodeID, TGRid *parentID)
{
  VDASSERT_FN("deletedNode");
  
  IGRstat retFlag = 0;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  VDASSERTW(nodeID);
  VDASSERTW(parentID);
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);  
  }
  
  // Its possible the parent was deleted
  if ((parentNodeID.objid == nodeID->objid) && 
      (parentNodeID.osnum == nodeID->osnum)) {

    parentNodeID.objid = NULL_OBJID;  
    VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_PARENT_NODE,"");
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);  
  }  

  return retFlag;
}

/* -----------------------------------------------------
 * A Node was renamed
 */
static IGRstat renamedNode(TGRid *nodeID)
{ 
  VDASSERT_FN("renamedNode");
  
  IGRstat retFlag = 0;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
     
  IGRchar  buf[128];
  
  TVDct1JD workJD;
  TVDctBaseInfo baseInfo;
  
  // Arg check
  VDASSERTW(nodeID);
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  workJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (workJD.cl == NULL) goto wrapup;
  workJD.id = *nodeID;
  
  _RTCJDB(&workJD)->getBaseInfo(&workJD,&baseInfo);
  
  // Update status
  sprintf(buf,"Renamed Node %s %s",baseInfo.nodeType,baseInfo.nodeName);
  VDfrmSetSts(formInfo->form,buf);

  // update the activeNodeID to the form
  if ((nodeID->objid == activeNodeID.objid) && (nodeID->osnum == activeNodeID.osnum)){
    sprintf(buf,"%s %s",baseInfo.nodeType,baseInfo.nodeName);
    VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,buf);
  }

  // update the parentNodeID to the form
  if ((nodeID->objid == parentNodeID.objid) && (nodeID->osnum == parentNodeID.osnum)){
 
    // get the parentNodeID data!
    workJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
    if (workJD.cl == NULL) goto wrapup;
    workJD.id = parentNodeID;
    _RTCJDB(&workJD)->getBaseInfo(&workJD,&baseInfo);
      
    // Copy the parentNodeID data to the form
    sprintf(buf,"%s %s",baseInfo.nodeType,baseInfo.nodeName);
    VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_PARENT_NODE,buf);
  }

  // success! 
  retFlag = 1;

  // Oh well
wrapup:

  // say bye
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* -------------------------------------------
 * Node was created
 */
static IGRstat createdNode(TGRid *nodeID)
{
  VDASSERT_FN("createdNode");
  
  IGRstat retFlag = 0;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
   
  IGRchar  buf[128];
  TVDct1JD  workJD;
  TVDctBaseInfo baseInfo;

  VDASSERTW(nodeID);
   
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get it
  workJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (workJD.cl == NULL) goto wrapup;
  workJD.id = *nodeID;
  _RTCJDB(&workJD)->getBaseInfo(&workJD,&baseInfo);
   
  // Update status
  sprintf(buf,"Created Node '%s'",baseInfo.baseName);
  VDfrmSetSts(formInfo->form,buf);
  
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}


/* -------------------------------------------
 * Node was activated
 */
static IGRstat activateNode(TGRid *nodeID)
{
  VDASSERT_FN("activateNode");
  
  IGRstat retFlag = 0;
 
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;
  
  IGRint  state;
  
  TVDctBaseInfo     baseInfo;
  TVDctNodeTypeInfo nodeTypeInfo;
  
  IGRint  i,row;  
  IGRchar buf[128];

  TVDct1JD  workJD;
  
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Arg Check
  VDASSERTW(nodeID);
  
  // Make it active
  activeNodeID = *nodeID;

  // Fill In work information
  workJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (workJD.cl == NULL) goto wrapup;
  workJD.id = *nodeID;
  VDjt1GetBaseInfo(&workJD,&baseInfo);
  
  VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_TYPE,baseInfo.nodeType);

  VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_EDIT_NODE_NAME,baseInfo.nodeName);

//  VDct1CmdResetGadgetList(nodeID,formInfo->form,VDCT_FORM_NODE_G_DOIT,1);
  
  // Make it active based on toggle
  // This makes no sense, activateNode is always set at the beginning
  // Need to rethink
  VDfrmGetState(formInfo->form,VDCT_FORM_NODE_T_ACTIVE_NODE,&state);

  if (state == 0) {
    activeNodeID = *nodeID;
    VDfrmSetgText(formInfo->form,VDCT_FORM_NODE_G_ACTIVE_NODE,baseInfo.baseName);

    // Reset doit pick list
    //printf("Resetting doit pick list\n");
    //VDct1CmdResetGadgetList(&workJD,formInfo->form,VDCT_FORM_NODE_G_DOIT,1);

  }
 
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
   
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
static IGRstat notifyForm()
{
  VDASSERT_FN("notifyForm");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->node;

  // say hi
  if (traceFlag){
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Reset Status (needed for testing)
  VDfrmSetSts(cmdInfo->node.form,"");
  
  // Process it
  switch(cmdInfo->gadget) {

  case VDCT_FORM_NODE_G_EDIT_NODE_TYPE:
    notifyNodeType();
    break;

  case VDCT_FORM_NODE_B_PARENT_NODE:
    notifyParentNode();
    break;

  case FI_EXECUTE:
    sts = notifyDoit();
    break;
    
  case FI_ACCEPT:
    sts = notifyDoit();
    if (sts & 1) {
      VDfrmDisplayForm(formInfo->form,0,&formInfo->displayed);
    }
    
    break;
    
  case FI_CANCEL:
    VDfrmDisplayForm(formInfo->form,0,&formInfo->displayed);
    break;
  }
  

wrapup:
  
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");
  
  IGRstat retFlag = 0;

  // say hi
  if (traceFlag){
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Display
  VDfrmDisplayForm(cmdInfo->node.form,1,&cmdInfo->node.displayed);

  // Done
  retFlag = 1;

wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Regular Init
 */
static IGRstat init()
{
  VDASSERT_FN("init");
  IGRstat retFlag = 0;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Clear
  activeNodeID.objid = NULL_OBJID;
  parentNodeID.objid = NULL_OBJID;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitNodeCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitNodeCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Say Hi
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_NODE);
   
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;

  parentNodeID.objid  = NULL_OBJID;
  activeNodeID.objid = NULL_OBJID;
  
  // Default init
  formInfo = &cmdInfo->node;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_NODE_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->activateNode  = activateNode;
  formInfo->activateForm  = activateForm;
  formInfo->notifyForm    = notifyForm;

  formInfo->renamedNode   = renamedNode;
  formInfo->deletedNode   = deletedNode;
  formInfo->createdNode   = createdNode;

  formInfo->init          = init;
  formInfo->locatedObject = locatedObject;
  

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
