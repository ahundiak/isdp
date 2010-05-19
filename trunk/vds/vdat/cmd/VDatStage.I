/* $Id: VDatStage.I,v 1.2 2001/01/11 20:23:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatStage.I
 *
 * Description: Stage Manupilation Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatStage.I,v $
 *      Revision 1.2  2001/01/11 20:23:18  art
 *      sp merge
 *
# Revision 1.1  2000/06/09  18:55:26  pinnacle
# ah
#
# Revision 1.4  1998/10/25  12:03:50  pinnacle
# ah
#
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/29  21:15:06  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 06/09/00  ah      TR179901616 Prevent Duplicate Nodes Across Entire Tree
 ***************************************************************************/
class implementation VDatBase;

#include "VDatCmd.h"
#include "VDsa.h"
#include "VDobj.h"
#include "VDppl1.h"

#define VDAT_FORM_STAGE_B_WORK_STAGE 13
#define VDAT_FORM_STAGE_G_WORK_STAGE 38
#define VDAT_FORM_STAGE_G_STAGES     14
#define VDAT_FORM_STAGE_G_STAGE_NAME 40

#define VDAT_FORM_STAGE_B_CREATE_STAGE 39
#define VDAT_FORM_STAGE_B_DELETE_STAGE 15
#define VDAT_FORM_STAGE_B_RENAME_STAGE 18
#define VDAT_FORM_STAGE_B_ADD_TO_STAGE 20

#define VDAT_FORM_STAGE_B_ADD_LEAFS    12
#define VDAT_FORM_STAGE_B_REMOVE_LEAFS 17
#define VDAT_FORM_STAGE_T_LOCK         19
#define VDAT_FORM_STAGE_T_CREATE       11

IGRstat VDatCMDStageNotifyForm  (TVDatFrmList *fl);
IGRstat VDatCMDStageActivateForm(TVDatFrmList *fl);
IGRstat VDatCMDStageActivateSet (TVDatFrmList *fl);

IGRstat VDatCMDStageNotifySetWorkStage(TVDatFrmList *fl);
IGRstat VDatCMDStageNotifyStages      (TVDatFrmList *fl, IGRint gadget);

IGRstat VDatCMDStageNotifyCreateStage (TVDatFrmList *fl);
IGRstat VDatCMDStageNotifyDeleteStage (TVDatFrmList *fl);
IGRstat VDatCMDStageNotifyRenameStage (TVDatFrmList *fl);
IGRstat VDatCMDStageNotifyAddToStage  (TVDatFrmList *fl);

IGRstat VDatCMDStageNotifyAddLeafs    (TVDatFrmList *fl);
IGRstat VDatCMDStageNotifyRemoveLeafs (TVDatFrmList *fl);

IGRstat VDatFormFillStages(Form form, IGRint gadget, TGRid *setID);

IGRstat VDatCMDStageGetWorkStage(Form form, TGRid *workID);

IGRstat VDatCMDStatus(Form form, IGRchar *buf)
{
  if (form) VIg_set_text(form,10,buf);
  UI_status(buf);
  return 1;
}

/* ----------------------------------------------------
 * Add items to stage
 */
IGRstat VDatCMDStageNotifyDeleteStage(TVDatFrmList *fl)
{
  IGRstat  retFlag = 0;

  Form form = fl->stage;

  TGRid    workID;
  TGRid    nodeID;
  TGRid    parentID;

  IGRint   cnt;
  IGRchar  buf[128];

  // Init
  cnt = 0;

  // Work stage
  VDatCMDStageGetWorkStage(form,&workID);
//if (workID.objid == NULL_OBJID) goto wrapup;

  // Get list of highlited rows from tree
  while(VDatCMDTreeGetFirstSelectedRow(fl,&nodeID)) {

    VDatGetParentNode(&nodeID,&parentID);

    VDatDeleteNode(&nodeID);
    VDatSummarizeNode(&parentID);

    VDatCMDTreeRemoveRow(fl,&nodeID); // Tree node is protected
    cnt++;
  }

  if (cnt != 0) {
    VDatCMDLeafFillLists(fl);
  }
  sprintf(buf,"Deleted %d item(s)",cnt);
  VDatCMDStatus(form,buf);

  retFlag = 1;
//wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Checks to see if the potiental parent object could become
 * a parent of the child object
 * Guards against circular links
 */
IGRstat VDatCanAdopt(TGRid *parentID, TGRid *childID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  i;
  TGRid   parentIDx;
  
  // A NULL parent is a recursive terminating condition for now
  if (parentID->objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Cannot adopt itself
  if (parentID->objid == childID->objid) goto wrapup;
  
  // Cannot adopt across os's
  if (parentID->osnum != childID->osnum) goto wrapup;
  
  // Repeat for each parent
  for(i = 0; VDatGetParentObject(parentID,i,&parentIDx); i++) {
  
    sts = VDatCanAdopt(&parentIDx,childID);
    if (!(sts & 1)) goto wrapup;
    
  }
  
  // Should be ok
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
 * See if the child stage can fit under the parent stage
 */
IGRstat VDatCMDStageCanAdopt(TGRid *parentID, TGRid *childID)
{
  IGRstat retFlag = 0;

  TVDatRDBNodeInfo parentINFO, childINFO;
  
  VDatRDBGetNodeInfo(parentID, &parentINFO);
  VDatRDBGetNodeInfo(childID,  &childINFO);
  
  if (childINFO.nodeLevel >= parentINFO.nodeLevel) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}
  
/* ----------------------------------------------------
 * Add items to stage
 */
IGRstat VDatCMDStageNotifyAddToStage(TVDatFrmList *fl)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;
  
  Form form = fl->stage;

  TGRid    workID;
  TGRid    nodeID,parentID;
  TVDvlaID nodeVLA;

  IGRint   i,cnt;
  IGRchar  buf[256];
  IGRchar  nodeName[128];
  
  // Init
  VDvlaID_Construct(&nodeVLA);
  cnt = 0;

  // Stage to add to
  VDatCMDStageGetWorkStage(form,&workID);
  if (workID.objid == NULL_OBJID) goto wrapup;

  // Get list of highlited rows from tree
  VDatCMDTreeGetSelectedRows(fl,&nodeVLA);

  // Cycle once to verify all nodes can be adopted
  for(i = 0; VDvlaID_GetAt(&nodeVLA,&nodeID,i); i++) {

    // Makes sure stage types are compatible
    sts = VDatCMDStageCanAdopt(&workID,&nodeID);

    if (!(sts &1)) {
      *nodeName = 0;
      VDatGetNodePath(&nodeID,nodeName);
      sprintf(buf,"Cannot move: %s",nodeName);
      VDatCMDStatus(form,buf);
      goto wrapup;
    }    

    // Checks for object recursion
    // This should never fails as the above test will
    // should filter any invalid moves
    sts = VDatCanAdopt(&workID,&nodeID);

    if (!(sts &1)) {
      *nodeName = 0;
      VDatGetNodePath(&nodeID,nodeName);
      sprintf(buf,"Cannot Move: %s",nodeName);
      VDatCMDStatus(form,buf);
      goto wrapup;
    }    

  }
  
  // Do the actual transfer
  for(i = 0; VDvlaID_GetAt(&nodeVLA,&nodeID,i); i++) {
    
    // Drop it's current parent
    VDatGetParentNode(&nodeID,&parentID);
    if (parentID.objid != NULL_OBJID) {
      VDatDelParent(&nodeID,&parentID);
      VDatSummarizeNode(&parentID);
    }

    // Move it
    VDatAddParent(&nodeID,&workID);
    VDatSummarizeNode(&workID);

    VDatCMDTreeRemoveRow(fl,&nodeID);
    cnt++;

  }
  if (cnt != 0) {
    VDatCMDTreeUpdateNode(fl,&workID);
  }
  sprintf(buf,"Moved %d item(s)",cnt);
  VDatCMDStatus(form,buf);

  retFlag = 1;
wrapup:
  VDvlaID_Delete(&nodeVLA);
  return retFlag;
}

/* ----------------------------------------------------
 * Remove leafs from tree
 */
IGRstat VDatCMDStageNotifyRemoveLeafs(TVDatFrmList *fl)
{
  IGRstat  retFlag = 0;

  Form form = fl->stage;

  TGRid    workID;
  TGRid    leafID,nodeID;
  TVDvlaID leafVLA;

  IGRint   i,cnt;
  IGRchar  buf[128];

  // Init
  VDvlaID_Construct(&leafVLA);
  cnt = 0;

  // Stage to add to
  VDatCMDStageGetWorkStage(form,&workID);
//if (workID.objid == NULL_OBJID) goto wrapup;

  // Get list of highlited leafs from leaf form
  VDatCMDTreeGetSelectedLeafs(fl,&leafVLA);

  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {

    // Get current node
    VDatGetParentNode(&leafID,&nodeID);
    if (nodeID.objid != NULL_OBJID) {

      // Delete from tree
      VDatDelParent(&leafID,&nodeID);
      VDatSummarizeNode(&nodeID);

      VDatCMDTreeRemoveRow(fl,&leafID);
      cnt++;
    }
  }
  if (cnt != 0) {
    VDatCMDLeafFillLists (fl);
  }
  sprintf(buf,"Removed %d leafs",cnt);
  VDatCMDStatus(form,buf);
  
  retFlag = 1;
//wrapup:
  VDvlaID_Delete(&leafVLA);
  return retFlag;
}

/* ----------------------------------------------------
 * Add leafs to a stage
 */
IGRstar VDatCMDStageNotifyAddLeafs(TVDatFrmList *fl)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  Form form = fl->stage;

  TGRid    workID;
  TGRid    leafID,nodeID;
  TVDvlaID leafVLA;

  IGRint   i,cnt;
  IGRchar  buf[128];

  // Init
  VDvlaID_Construct(&leafVLA);
  cnt = 0;

  // Stage to add to
  VDatCMDStageGetWorkStage(form,&workID);
  if (workID.objid == NULL_OBJID) goto wrapup;

  // Get list of highlited leafs from leaf form
  VDatCMDLeafGetSelectedLeafs(fl,&leafVLA);

  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {

    // Get current node
    VDatGetParentNode(&leafID,&nodeID);
    if (nodeID.objid == NULL_OBJID) {

      // If not already summarized, get leaf summary
      sts = VDatHasSummary(&leafID);
      if (!(sts & 1)) {
        VDatSummarizeLeaf(&leafID);
      }

      // Add to work stage
      VDatAddParent(&leafID,&workID);
      VDatSummarizeNode(&workID);
      cnt++;
    }
  }
  if (cnt != 0) {
    VDatCMDTreeUpdateNode(fl,&workID);
    VDatCMDLeafFillLists (fl);
  }
  sprintf(buf,"Added %d leafs",cnt);
  VDatCMDStatus(form,buf);

  retFlag = 1;
wrapup:
  VDvlaID_Delete(&leafVLA);
  return retFlag;
}

/* ----------------------------------------------------
 * Recursive search for node
 */
IGRstat VDatSearchForNodeByTypeName(
  TGRid   *treeID,
  IGRchar *nodeType,
  IGRchar *nodeName,
  TGRid   *nodeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar l_nodeType[128];
  IGRchar l_nodeName[128];

  IGRint i;
  TGRid  childID;
  
  // Arg check
  if (nodeID == NULL) goto wrapup;
  nodeID->objid = NULL_OBJID;
  if ((nodeType == NULL) || (nodeName == NULL)) goto wrapup;
  if ((treeID == NULL) || (treeID->objid == NULL_OBJID)) goto wrapup;
  
  // Check the current object
  VDatRDBGetNodeType(treeID,l_nodeType);
  if (!strcmp(nodeType,l_nodeType)) {
    VDatGetNodeName(treeID,l_nodeName);
    if (!strcmp(nodeName,l_nodeName)) {
      *nodeID = *treeID;
      retFlag = 1;

      // printf("Found %s %s\n",l_nodeType,l_nodeName);
      
      goto wrapup;
    }
  }
  
  // Try the kids
  for(i = 0; VDatGetChildObject(treeID,i,&childID); i++) {
    sts = VDatSearchForNodeByTypeName(&childID,nodeType,nodeName,nodeID);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // No match
 wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Returns true if the node name is valid
 * message in buffer if not
 */
#argsused
IGRstat VDatValidateNodeName(
  TGRid   *setID,
  TGRid   *workID,
  IGRchar *nodeType, 
  IGRchar *nodeName,
  IGRchar *errMsg
) 
{
  IGRstat retFlag = 0;
  TGRid   nodeID;
  TGRid   treeID;
  
  IGRint  i;
  
  IGRchar l_nodeType[128];
  IGRchar l_nodeName[128];

  IGRchar setType[64];
  
  TGRid  pplID;
  IGRint pplRET;

  // Use set type for the ppl
  VDatRDBGetSetType(setID,setType);
  
  // See if node name is valid for node type
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    sprintf(errMsg,"Could not load %s.e for validation",setType);
    goto wrapup;
  }
  // printf("Validate: "); vdobj$Print(objID = &pplID);

  vdppl$SetData(pplID=&pplID,name="NODE_TYPE",size=128,data=nodeType);
  vdppl$SetData(pplID=&pplID,name="NODE_NAME",size=128,data=nodeName);
  
  vdppl$Run(pplID = &pplID, name = "isNameValid", ret = &pplRET);

  if (pplRET != 1) {
    vdppl$GetData(pplID=&pplID,name="NODE_MSG",size=128,data=errMsg);
    goto wrapup;
  }
  vdppl$GetData(pplID=&pplID,name="NODE_NAME",size=128,data=nodeName);

  vdppl$Delete(pplID = &pplID);

  // Init message
  sprintf(errMsg,"INVALID NODE NAME %s %s, ",nodeType,nodeName);

  // Must be unique at least within parent node
  if ((workID == NULL) || (workID->objid == NULL_OBJID)) {
    strcat(errMsg,"NO PARENT STAGE");
    goto wrapup;
  }

  // Check entire tree for duplicate node
  VDatGetTree(workID, &treeID);
  VDatSearchForNodeByTypeName(&treeID,nodeType,nodeName,&nodeID);
  if (nodeID.objid != NULL_OBJID) {
    strcat(errMsg,"DUPLICATE");
    goto wrapup;
  }
  
  // Old way is to just check within current node
#if 0
  for(i = 0; VDatGetChildObject(workID,i,&nodeID); i++) {

    VDatRDBGetNodeType(&nodeID,l_nodeType);

    if (!strcmp(nodeType,l_nodeType)) {
      VDatGetNodeName(&nodeID,l_nodeName);
      if (!strcmp(nodeName,l_nodeName)) {
	strcat(errMsg,"DUPLICATE");
	goto wrapup;
      }
    }  
  }
#endif

  // Ok
  *errMsg = 0;
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* --------------------------------------------------
 * Changes type of node by hooking to different
 * rdb node
 * copied here for dload testing
 */
#if 0
IGRstar VDatChangeNodeType(TGRid *nodeID, TGRid *rdbNodeID)
{
  IGRstat retFlag = 0;

  // Arg check
  if ((   nodeID == NULL) || (   nodeID->objid == NULL_OBJID)) goto wrapup;
  if ((rdbNodeID == NULL) || (rdbNodeID->objid == NULL_OBJID)) goto wrapup;
  
  // Drop old node
  VDatDelParentByType(nodeID,VDAT_CLASSI_RDB_NODE);
  
  // Add new one
  VDatAddParent(nodeID,rdbNodeID);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#endif

/* ----------------------------------------------------
 * Rename or modify a Stage
 */
IGRstat VDatCMDStageNotifyRenameStage(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form    form = fl->stage;

  TGRid   nodeID,parentID,setID,rdbNodeID,childID;

  IGRchar nodeType[128];
  IGRchar nodeName[128];
  IGRchar nodePath[128];
  IGRchar buf[1024];

  IGRchar newType[128];
  IGRint  i;
  
  // Init
  VDatCMDStatus(form,"Renaming Stage");
  rdbNodeID.objid = NULL_OBJID;
  
  // Get active set
  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) {
    VDatCMDStatus(form,"No Active Set");
    goto wrapup;
  } 
   
  // Get the work stage
  VDatCMDStageGetWorkStage(form,&nodeID);
  if (nodeID.objid == NULL_OBJID) {
    VDatCMDStatus(form,"Specify Work Stage");
    goto wrapup;
  }

  // Get it's type
  *nodeType = 0;
  VDatRDBGetNodeType(&nodeID,nodeType);
  if (*nodeType == 0) {
    VDatCMDStatus(form,"Work Stage is not a node???");
    goto wrapup;
  }
  
  // Get it's parent
  VDatGetParentNode(&nodeID,&parentID);
 
  // Not allowing changing the top node name
  if (parentID.objid == NULL_OBJID) {
    VDatCMDStatus(form,"Cannot rename the top node");
    goto wrapup;
  }
    
  // See if type has changed
  VIg_get_text(form,VDAT_FORM_STAGE_G_STAGES,newType);
  if (strcmp(nodeType,newType)) {

    // RDB Node Information
    VDatRDBGetNodeByType(&setID,newType,&rdbNodeID);
    if (rdbNodeID.objid == NULL_OBJID) {
      VDatCMDStatus(form,"Invalid Stage Type");
      goto wrapup;
    }
 
    // Check if parent is ok with it
    sts = VDatCMDStageCanAdopt(&parentID,&rdbNodeID);
    if (!(sts & 1)) {
      VDatCMDStatus(form,"Parent will not allow this stage type");
      goto wrapup;
    }

    // Check each child
    for(i = 0; VDatGetChildObject(&nodeID,i,&childID); i++) {

      sts = VDatCMDStageCanAdopt(&rdbNodeID,&childID);
      if (!(sts & 1)) {
	VDatCMDStatus(form,"Child will not allow this stage type");
	goto wrapup;
      } 
    }
  }
   
  // Get the new name
  *nodeName = 0;
  VIg_get_text(form,VDAT_FORM_STAGE_G_STAGE_NAME,nodeName);
  
  // Check for valid names
  sts = VDatValidateNodeName(&setID,&parentID,newType,nodeName,buf);
  if (!(sts & 1)) {
    VDatCMDStatus(form,buf);
    goto wrapup;
  }

  // Change type
  if (strcmp(nodeType,newType)){

    VDatChangeNodeType(&nodeID,&rdbNodeID);
    
  }
  
  // Rename
  VDatSetNodeName(&nodeID,nodeName);
  
  // Tell the manager
  VDatCMDAllSetActiveNode(fl,&nodeID);
  VDatCMDTreeUpdateNode  (fl,&nodeID);

  // Update work stage
  *nodePath = 0;
  VDatGetNodePath(&nodeID,nodePath);
  VDahFrmSetTextRC(form,VDAT_FORM_STAGE_G_WORK_STAGE,0,0, nodePath);

  retFlag = 1;

wrapup:
  if (retFlag != 1) UI_status("Stage Rename Failed");
  else              VDatCMDStatus(form,"Stage Renamed");
  
  return retFlag;
}
  
/* ----------------------------------------------------
 * Create a Stage
 */
IGRstat VDatCMDStageNotifyCreateStage(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form    form = fl->stage;

  IGRchar rdbNodeType[128];
  TGRid   workID,setID,rdbNodeID,nodeID;
  IGRchar nodeName[128];

  IGRchar buf[1024];
  IGRint  state;
  
  // If in modify mode, branch to old rename routine
  VIg_get_state(form,VDAT_FORM_STAGE_T_CREATE,&state);
  if (state) {
    return VDatCMDStageNotifyRenameStage(fl);
  }
  
  // Init
  VDatCMDStatus(form,"Creating Stage");

  // Get active set
  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) {
    VDatCMDStatus(form,"No Active Set");
    goto wrapup;
  }    

  // Determine type of node
  *rdbNodeType = 0;
  VIg_get_text(form,VDAT_FORM_STAGE_G_STAGES,rdbNodeType);
  if (*rdbNodeType == 0) {
    VDatCMDStatus(form,"Specify Stage Type");
    goto wrapup;
  }

  VDatRDBGetNodeByType(&setID,rdbNodeType,&rdbNodeID);
  if (rdbNodeID.objid == NULL_OBJID) {
    VDatCMDStatus(form,"Invalid Stage Type");
    goto wrapup;
  }

  // Node name
  *nodeName = 0;
  VIg_get_text(form,VDAT_FORM_STAGE_G_STAGE_NAME,nodeName);
  
  // Need the parent
  VDatCMDStageGetWorkStage(form,&workID);
  if (workID.objid == NULL_OBJID) {
    VDatCMDStatus(form,"Specify Work Stage");    
    goto wrapup;
  }

  // While the UI should prevent this, do a final check
  // To make sure the stage is valid for the work stage
  sts = VDatCMDStageCanAdopt(&workID, &rdbNodeID);
  if (!(sts & 1)) { 
    VDatCMDStatus(form,"Cannot put this stage type under the work stage");
    goto wrapup;
  }

  // Check for valid names
  sts = VDatValidateNodeName(&setID,&workID,rdbNodeType,nodeName,buf);
  if (!(sts & 1)) {
    VDatCMDStatus(form,buf);
    goto wrapup;
  }
  
  // Create It
  VDatCreateNode(&workID,&rdbNodeID,nodeName,&nodeID);
  if (nodeID.objid == NULL_OBJID) {
    VDatCMDStatus(form,"Stage Creation Failed");
    goto wrapup;
  }

  // Lock current work stage
  VIg_get_state(form,VDAT_FORM_STAGE_T_LOCK,&state);
  VIg_set_state(form,VDAT_FORM_STAGE_T_LOCK,1);

  // Tell the manager
  VDatCMDAllSetActiveNode(fl,&nodeID);
  VDatCMDTreeUpdateNode  (fl,&nodeID);

  VIg_set_state(form,VDAT_FORM_STAGE_T_LOCK,state);

  retFlag = 1;
wrapup:
  if (retFlag != 1) UI_status("Stage Creation Failed");
  else              VDatCMDStatus(form,"Stage Created");
  
  return retFlag;
}

/* ----------------------------------
 * Stage type was picked
 */
IGRstat VDatCMDStageNotifyStages(TVDatFrmList *fl, IGRint gadget)
{
  IGRstat retFlag = 0;
  Form    form = fl->stage;
  IGRchar stageType[128];

  TVDatRDBNodeInfo info;
  TGRid setID,stageID;

  // Get the type
  *stageType = 0;
  VIg_set_text(form,10,"");
  VIg_get_text(form,gadget,stageType);
  if (*stageType == 0) goto wrapup;

  // Need the set
  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Grab the node
  VDatRDBGetNodeByType(&setID,stageType,&stageID);
  if (stageID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"No Stage Found");
    goto wrapup;
  }

  // Display desc
  VDatRDBGetNodeInfo(&stageID,&info);
  VIg_set_text(form,10,info.nodeDesc);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fill in list of stages for set
 */
IGRstat VDatFormFillStages(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat retFlag = 0;

  TGRid stagesID;
  TGRid  stageID;

  TVDatRDBNodeInfo info;

  IGRint i,row;

  // Clear Field
  VIg_set_text(form,gadget,"");
  VIfld_set_list_num_rows(form,gadget,0,0);

  // Arg check
  if ((setID == NULL) || (setID->objid == NULL_OBJID)) goto wrapup;

  // List of stage objects
  VDatRDBGetNodes(setID,&stagesID);
  if (stagesID.objid == NULL_OBJID) goto wrapup;

  row = 0;
  for(i = 1; VDatGetChildObject(&stagesID,i,&stageID); i++) {

    VDatRDBGetNodeInfo(&stageID,&info);

    VIfld_set_list_text(form,gadget,row,0,info.nodeType,0);
    row++;

  }
  // Drop off highest node
  // if (row > 1) VIfld_set_list_num_rows(form,gadget,0,row-1);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Initializes the form with a new active node
 */
IGRstat VDatCMDStageActivateNode(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   nodeID,setID,stagesID,stageID;
  IGRint  i;
  
  Form    form = fl->stage;
  IGRint  gadget = VDAT_FORM_STAGE_G_STAGES;
  IGRint  row;
  
  TVDatRDBNodeInfo stageINFO,nodeINFO;

  IGRchar nodePath[128];
  IGRint  state = 0;
  IGRint  modifyMode = 0;
  
  IGRchar buf[128];
  
  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Ignore if locked
  state = 0;
  VIg_get_state(form,VDAT_FORM_STAGE_T_LOCK,&state);
  if (state != 0) goto wrapup;

  // Get active node
  VDatCMDAllGetActiveNode(fl,&nodeID);

  // Heading
  *nodePath = 0;
  VDatGetNodePath(&nodeID,nodePath);
  VDahFrmSetTextRC(form,VDAT_FORM_STAGE_G_WORK_STAGE,0,0, nodePath);
  VDahFrmSetGRid  (form,VDAT_FORM_STAGE_G_WORK_STAGE,0,1,&nodeID);

  // Modify or create
  VIg_get_state(form,VDAT_FORM_STAGE_T_CREATE,&modifyMode);
  
  // Fill in pick list
  VIg_set_text(form,gadget,"");
  VIfld_set_list_num_rows(form,gadget,0,0);
  if (nodeID.objid == NULL_OBJID) goto wrapup;
  VDatRDBGetNodeInfo(&nodeID,&nodeINFO);

  // printf("Node %s\n",nodeINFO.nodeType);
  
  // Need the set
  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) goto wrapup;
  
  // List of stage objects
  VDatRDBGetNodes(&setID,&stagesID);
  if (stagesID.objid == NULL_OBJID) goto wrapup;

  // Fill select list
  row = 0;
  for(i = 1; VDatGetChildObject(&stagesID,i,&stageID); i++) {

    // In modify, show all stages else filter
    if (modifyMode) sts = 1;
    else            sts = VDatCMDStageCanAdopt(&nodeID,&stageID);

    if (sts & 1) {
      
      VDatRDBGetNodeInfo(&stageID,&stageINFO);
      VIfld_set_list_text(form,gadget,row,0,stageINFO.nodeType,0);
      row++;
    }
    
  }
  // In modify, fill in type and name
  if (modifyMode) {
    vdsa$GetStruct(objID = &nodeID, name = "node_type", txt = buf);
    VIg_set_text(form,VDAT_FORM_STAGE_G_STAGES,buf);
    vdsa$GetStruct(objID = &nodeID, name = "node_name", txt = buf);
    VIg_set_text(form,VDAT_FORM_STAGE_G_STAGE_NAME,buf);
  }

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Sets the work stage
 */
IGRstat VDatCMDStageNotifySetWorkStage(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  
  Form   form   = fl->stage;
  IGRint gadget = VDAT_FORM_STAGE_G_WORK_STAGE;
 
  TGRid   nodeID;
  IGRchar nodeName[128];
  IGRchar buf[128];

  // Reset
  VIfld_set_num_rows(form,gadget,0);

  // Get the active node
  VDatCMDAllGetActiveNode(fl,&nodeID);  
  if (nodeID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"Need to pick a stage first");
    goto wrapup;
  }

  // Update form
  *nodeName = 0;
  VDatGetNodePath(&nodeID,nodeName);
  VDahFrmSetTextRC(form,gadget,0,0, nodeName);
  VDahFrmSetGRid  (form,gadget,0,1,&nodeID);

  sprintf(buf,"Work Stage: %s",nodeName);
  VIg_set_text(form,10,buf);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstat VDatCMDStageActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  Form    form = fl->stage;

  TGRid   setID;
  IGRchar setName[128];

  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // get the active set, if none just clear gadgets
  *setName = 0;
  VDatCMDAllGetActiveSet(fl,&setID,setName);

  // Update form
  VIg_set_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);
  VIfld_set_num_rows(form,VDAT_FORM_STAGE_G_WORK_STAGE,0);

  VDatFormFillStages(form,VDAT_FORM_STAGE_G_STAGES,&setID);

  // Disable some gadgets
  if (VDatIsSetInActiveOS(&setID) && VDatIsSetATree(&setID)) {    
    VIg_enable(form,VDAT_FORM_STAGE_B_CREATE_STAGE);
    VIg_enable(form,VDAT_FORM_STAGE_B_DELETE_STAGE);
    VIg_enable(form,VDAT_FORM_STAGE_B_RENAME_STAGE);
    VIg_enable(form,VDAT_FORM_STAGE_B_ADD_TO_STAGE);
    VIg_enable(form,VDAT_FORM_STAGE_B_ADD_LEAFS);
    VIg_enable(form,VDAT_FORM_STAGE_B_REMOVE_LEAFS);
  }
  else {
    VIg_disable(form,VDAT_FORM_STAGE_B_CREATE_STAGE);
    VIg_disable(form,VDAT_FORM_STAGE_B_DELETE_STAGE);
    VIg_disable(form,VDAT_FORM_STAGE_B_RENAME_STAGE);
    VIg_disable(form,VDAT_FORM_STAGE_B_ADD_TO_STAGE);
    VIg_disable(form,VDAT_FORM_STAGE_B_ADD_LEAFS);
    VIg_disable(form,VDAT_FORM_STAGE_B_REMOVE_LEAFS);
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Switches form between create and modify
 */
IGRstat VDatCMDStageNotifyCreateToggle(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->stage;

  IGRint  state = 0;
  
  VIg_get_state(form,VDAT_FORM_STAGE_T_CREATE,&state);
  if (state) {    
    VIg_set_text(form,VDAT_FORM_STAGE_B_CREATE_STAGE,"Modify Stage");
  }
  else {
    VIg_set_text(form,VDAT_FORM_STAGE_B_CREATE_STAGE,"Create Stage");
  }
  VIf_erase  (form);
  VIf_display(form);
    
  retFlag = 1;
  
  return retFlag;
}


/* -------------------------------------------
 * The notification routine
 */
IGRstat VDatCMDStageNotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form;
  IGRint  gadget;

  // Form has all global data
  form   = fl->form;
  gadget = fl->gadget;

  switch(gadget) {

  case VDAT_FORM_STAGE_B_REMOVE_LEAFS: {
    retFlag = VDatCMDStageNotifyRemoveLeafs(fl);
    goto wrapup;
  }
  case VDAT_FORM_STAGE_B_ADD_LEAFS: {
    retFlag = VDatCMDStageNotifyAddLeafs(fl);
    goto wrapup;
  }
  case VDAT_FORM_STAGE_B_ADD_TO_STAGE: {
    retFlag = VDatCMDStageNotifyAddToStage(fl);
    goto wrapup;
  }
  case VDAT_FORM_STAGE_B_CREATE_STAGE: {
    retFlag = VDatCMDStageNotifyCreateStage(fl);
    goto wrapup;
  }
  case VDAT_FORM_STAGE_B_RENAME_STAGE: {
    retFlag = VDatCMDStageNotifyRenameStage(fl);
    goto wrapup;
  }
  case VDAT_FORM_STAGE_B_DELETE_STAGE: {
    retFlag = VDatCMDStageNotifyDeleteStage(fl);
    goto wrapup;
  }
  case VDAT_FORM_STAGE_G_STAGES: {
    retFlag = VDatCMDStageNotifyStages(fl,gadget);
    goto wrapup;
  }
  case VDAT_FORM_STAGE_B_WORK_STAGE: {
    retFlag = VDatCMDStageNotifySetWorkStage(fl);
    goto wrapup;
  }

  case VDAT_FORM_STAGE_T_CREATE: {
    retFlag = VDatCMDStageNotifyCreateToggle(fl);
    goto wrapup;
  }
      
  case FI_CANCEL: {
    VIf_erase(form);
    VDatFormSetActive(form,0);
    retFlag = 1;
    goto wrapup;
  }
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDatCMDStageActivateForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    form;

  // Arg check
  if ((fl == NULL) || (fl->stage == NULL)) goto wrapup;
  form = fl->stage;

  // Ignore if already active for now
  sts = VDatFormIsActive(form);
  if (sts == 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Just display
  VIf_display(form);
  VDatFormSetActive(form,1);

  VDatCMDStageActivateSet(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}
/* --------------------------------------
 * Gets work stage
 */
IGRstat VDatCMDStageGetWorkStage(Form form, TGRid *workID)
{
  IGRstat retFlag = 0;

  VDahFrmGetGRid(form,VDAT_FORM_STAGE_G_WORK_STAGE,0,1,workID);
  if (workID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;
wrapup:
  if (retFlag != 1) VIg_set_text(form,10,"No Work Stage Specified");
  return retFlag;
}

end implementation VDatBase;








