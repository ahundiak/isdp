/* $Id: VDct1Set.c,v 1.3 2001/02/11 17:19:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1Mgr.C
 *
 * Description: Main Forms Manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Set.c,v $
 *      Revision 1.3  2001/02/11 17:19:50  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/02/01 21:25:31  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/14 16:21:13  art
 *      sp merge
 *
 * Revision 1.8  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.7  2000/09/14  20:34:00  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDrisc.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd/VDct1Set.c");

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */
static TVDct1CmdInfo *cmdInfo;

static TGRid activeTreeID;
static TGRid activeNodeID;

/* -------------------------------------------
 * change set name for all nodes in tree
 */
static IGRstat changeNodeSetName(TVDct1JD *nodeJD,
				 IGRchar  *setName)
{
  VDASSERT_FN("changeNodeSetName");
  
  IGRstat  retFlag = 0;
  IGRint   i;
  
  TVDctBaseInfo    baseInfo;
  TVDct1JD         childJD;

  // arg check
  VDASSERTW(setName != NULL);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Get the baseInfo 
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (baseInfo.setName == NULL) goto wrapup;
  
  //rename the Node
  strcpy(baseInfo.setName,setName);
  _RTCJDB(nodeJD)->setBaseInfo(nodeJD,&baseInfo); 

  // Now do the kids
  for(i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
    changeNodeSetName(&childJD,setName);
    if (traceFlag) printf("child ID  setName = %s\n",setName);
  }

  // done
  retFlag = 1;

wrapup:

  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);  
  return retFlag;
}

/* ---------------------------------------------
 * Post a tree
 */
static IGRstat notifyPostTree()
{
  VDASSERT_FN("notifyPostTree");
  
  IGRstat      retFlag = 0;
  IGRstat      sts;
    
  Form     form = cmdInfo->sets.form;
  TVDct1JD treeJD;
  TVDct1JD activeJD;
  IGRchar  msg[128];

  //say hi
  if (traceFlag) printf(">>> %s %s \n",ffn(),fn);

  // Get the tree node
  activeJD.cl = VDct1GetTreeClassForNode(&activeTreeID);
  if (activeJD.cl == NULL) {
    VDfrmSetSts(form,"Pick tree before posting");
    goto wrapup;
  }
  activeJD.id = activeTreeID;
  VDjt1GetRootForNode(&activeJD,&treeJD);
  if (treeJD.id.objid == NULL_OBJID) {
    VDfrmSetSts(form,"Pick tree before posting");
    goto wrapup;
  }
  
  // Do a quick check here just to make sure it could be posted
  sts = VDjt1IsTreePostable(&treeJD);
  if (!(sts & 1)) {
    VDfrmSetSts(form,"Tree is not postable");
    goto wrapup;
  }
    
  // Make sure logged in
  sts = VDrisIsSchemaOpen();
  if (!(sts & 1)) {
    VDfrmSetSts(form,"Not logged into pdm");
    goto wrapup;
  }
    
  // Doit
  sts = VDjt1PostTree(&treeJD,stdout);
  if (!(sts & 1)) {
    VDfrmSetSts(form,"Posting failed");
    goto wrapup;
  }
  VDfrmSetSts(form,"Posting complete");

  // done
  retFlag = 1;

wrapup:

  // say bye
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Rename a Tree
 */
static IGRstat notifyRenameTree()
{
  VDASSERT_FN("notifyRenameTree");
  
  IGRstat      retFlag = 0;
  IGRstat      sts;
    
  Form    form = cmdInfo->sets.form;
  
  TVDctBaseInfo    baseInfo;

  TVDct1JD   mgrJD;
  TVDct1JD   setJD;
  TVDct1JD   activeJD;
  
  TVDctSetName     setName;
  TVDctSetType     setType;

  IGRchar          msg[128];

  //say hi
  if (traceFlag) printf(">>> %s %s \n",ffn(),fn);

  // get the setID of the Mgr
  activeJD.cl = VDct1GetTreeClassForNode(&activeTreeID);
  if (activeJD.cl == NULL) goto wrapup;
  activeJD.id = activeTreeID;
  _RTCJDB(&activeJD)->getMgrParent(&activeJD,&setJD);
  
  // args check
  if (activeTreeID.objid == NULL_OBJID){
    sprintf(msg,"No Active Tree \n\nRename Not Done\n\n");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  // Get The Type/Name
  VDfrmGetgText(form,VDCT_FORM_SET_G_TREE_TYPE,setType);
  VDfrmGetgText(form,VDCT_FORM_SET_G_TREE_NAME,setName);
 

  // Get the manager
  mgrJD.cl = activeJD.cl;
  mgrJD.id = activeJD.id;
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  if (mgrJD.id.objid == NULL_OBJID) {
    VDfrmSetSts(form,"No Manager!!!");
    goto wrapup;
  }

  sts = _RTCJDB(&activeJD)->isSetNameValid(&activeJD,setType,setName,msg);
  if (!(sts & 1)) {
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }

  sts = _RTCJDC(&activeJD)->isRenameTreeValid(&activeJD);
  if (!(sts & 1)) {
    sprintf(msg,"Rename of %s Not Valid",setName);
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
    
  // Get the baseInfo 
  _RTCJDB(&activeJD)->getBaseInfo(&activeJD,&baseInfo);

  // verify if top of tree
  if (strcmp(baseInfo.setName,baseInfo.nodeName)) {
    sprintf(msg,"Select a Tree \n\nRename Not Done");
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  //rename the Tree Top Node
  strcpy(baseInfo.setName,setName);
  strcpy(baseInfo.nodeName,setName);
  _RTCJDB(&activeJD)->setBaseInfo(&activeJD,&baseInfo); 
     
  // Clear up the Tree form Msg box
  sprintf(msg,"Renamed Tree: %s.%s",setType,setName);
  VDfrmSetSts(form,msg);

  // Get the Mgr baseInfo 
  _RTCJDB(&setJD)->getBaseInfo(&setJD,&baseInfo);  

  // rename the Mgr object  
  strcpy(baseInfo.setName,setName);
  strcpy(baseInfo.nodeName,setName);
  _RTCJDB(&setJD)->setBaseInfo(&setJD,&baseInfo);  

  // Go out and change the name of the children
  changeNodeSetName(&activeJD,setName);

  // Tell the boss
  cmdInfo->mgr.renamedTree(&activeJD.id);  
  cmdInfo->mgr.activateNode(&activeJD.id);
  
  // done
  retFlag = 1;

wrapup:

  // say bye
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Delete a tree 
 */
static IGRstat notifyDeleteTree()
{
  VDASSERT_FN("notifyDeleteTree");
  
  IGRstat sts;
  IGRstat retFlag = 0;
  IGRchar treeName[64];
  IGRchar msg[80];
  IGRint  noFlag;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->sets;

  TVDct1JD   setJD;
  TVDct1JD   activeJD;
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Need the actual set parent
  activeJD.cl = VDct1GetTreeClassForNode(&activeTreeID);
  if (activeJD.cl == NULL) goto wrapup;
  activeJD.id = activeTreeID;

  _RTCJDB(&activeJD)->getMgrParent(&activeJD,&setJD);
  if (setJD.id.objid == NULL_OBJID) {
    // notify of problem
    VDfrmSetSts(formInfo->form,"No Active Tree Selected");
    goto wrapup;
  }

  // get the active tree data
  VDfrmGetgText(formInfo->form,VDCT_FORM_SET_G_TREE_ACTIVE,treeName);
  strcat(msg,treeName);

  // check the rules
  sts = _RTCJDC(&activeJD)->isDeleteTreeValid(&activeJD);
  if (!(sts & 1)) {
    sprintf(msg,"Deletion of %s is Not Valid",treeName);
    goto wrapup;
  }
  
  // Confirm Deletion
  sprintf(msg,"Delete %s?",treeName);
  VDct1CmdBoxYesOrNo(msg,&noFlag);
  if (noFlag) goto wrapup;

  // Delete it
  sts = _RTCJDB(&setJD)->deleteNode(&setJD);
  if (!(sts & 1)) {
    sprintf(msg,"Delete of %s Failed",treeName);
    goto wrapup;
  }
  
  // Clear up the Tree form Msg box
  sprintf(msg,"Deleted Tree: %s",treeName);
  VDfrmSetSts(formInfo->form,msg);

  // Tell the MGR
  cmdInfo->mgr.deletedTree(&activeJD.id);
  
  // Just to make sure
  activeTreeID.objid = NULL_OBJID;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (!retFlag) VDct1CmdBoxMsg(msg);
 
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * Create a Tree
 */
static IGRstat notifyCreateTree()
{
  VDASSERT_FN("notifyCreateTree");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->sets;
  Form form = formInfo->form;

  IGRchar setName[64];
  IGRchar setType[64];
  IGRchar msg[128];
  
  TVDct1JD setJD;
  TVDct1JD mgrJD;
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get The Type
  VDfrmGetgText(form,VDCT_FORM_SET_G_TREE_TYPE,setType);  
  if (*setType == 0) {
    sprintf(msg,"Enter Tree Type");
    VDfrmSetSts(form,msg);
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  // Get the class pointer
  setJD.cl = VDct1GetTreeClassForSetType(setType);
  VDASSERTW(setJD.cl);
  setJD.id.objid = NULL_OBJID;
  EX_findmod(NULL,&setJD.id.osnum);
 
  // Get the name
  VDfrmGetgText(form,VDCT_FORM_SET_G_TREE_NAME,setName);
  if (*setName == 0) {
    sprintf(msg,"Enter Tree Name");
    VDfrmSetSts(form,msg);
    VDct1CmdBoxMsg(msg);   
    goto wrapup;
  }

  // Validate the name
  sts = _RTCJDB(&setJD)->
    isSetNameValid(&setJD,setType,setName,msg);

  if (!(sts & 1)) {
    VDfrmSetSts(form,msg);
    VDct1CmdBoxMsg(msg);
    goto wrapup;
  }
  
  // Validate access to create tree
  sts = _RTCJDC(&setJD)->
    isCreateTreeValid(&setJD,setType);
  if (!(sts & 1)) {
    VDfrmSetSts(form,"Access Denied");
    goto wrapup;
  }
  
  // Get the manager
  mgrJD = setJD;
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  VDASSERTW(mgrJD.id.objid != NULL_OBJID);
  
  // Create it
  _RTCJDB(&mgrJD)->createSet(&mgrJD,setType,NULL,setName,&setJD);
  if (setJD.id.objid == NULL_OBJID) {
    VDfrmSetSts(form,"Tree Creation Failed");
    goto wrapup;
  }

  // Status
  sprintf(msg,"Created Tree %s.%s",setType,setName);
  VDfrmSetSts  (form,msg);
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_TYPE,setType);  
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_NAME,setName);  

  // Tell the manager
  cmdInfo->mgr.createdTree(&setJD.id);

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -------------------------------------------
 * doit
 */
static IGRstat notifyDoit()
{
  VDASSERT_FN("notifyDoit");
  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->sets;

  IGRchar buf[128];
  IGRchar cmd;
    
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the command string
  VDfrmGetgText(formInfo->form,VDCT_FORM_SET_G_DOIT,buf);
  cmd = *buf;
  
  // Switch it
  switch(cmd) {

  case '2':
    notifyCreateTree();
    break;

  case '3':
    notifyDeleteTree();
    break;

  case '4':
    notifyRenameTree();
    break;

  case '5':
    notifyPostTree();
    break;

  }

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------
 * User changed set type
 */
static IGRstat notifySetType()
{
  IGRstat retFlag = 0;
  IGRchar buf[128],*p;

  Form form = cmdInfo->sets.form;
 
  // Get type and desc
  VDfrmGetgText(form,VDCT_FORM_SET_G_TREE_TYPE,buf);

  // Clean up type
  p = strchr(buf,' ');
  if (p) *p = NULL;
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_TYPE,buf);

  // Clean desc
  if (p == NULL) *buf = 0;
  else {
    for(p++; *p == ' '; p++);
    strcpy(buf,p);
  }
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_DESC,buf);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
static IGRstat notifyForm()
{
  VDASSERT_FN("notifyForm");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->sets;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Reset Status (needed for testing)
  VDfrmSetSts(cmdInfo->sets.form,"");
  
  // Process It
  switch(cmdInfo->gadget) {

    case VDCT_FORM_SET_G_TREE_TYPE:
    notifySetType();
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
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }
  return retFlag;
}

/* ----------------------------------------
 * Initialize form based on a new active node 
 */
static IGRstat activateNode(TGRid *nodeID)
{
  VDASSERT_FN("activateNode");
  
  IGRstat retFlag = 0;
  
  Form    form  = cmdInfo->sets.form;
  
  TVDctBaseInfo    baseInfo;
  TVDctSetTypeInfo setTypeInfo;
  
  TVDct1JD activeJD;
  TVDct1JD activeTreeJD;
    
  IGRchar buf[128];
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Store it
  if (nodeID == NULL) goto wrapup;
  activeNodeID = *nodeID;
  
  activeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeJD.cl == NULL) goto wrapup;
  activeJD.id = activeNodeID;
    
  // Get the tree to which it belongs
  _RTCJDB(&activeJD)->getRootForNode(&activeJD,&activeTreeJD);
  if (activeTreeJD.id.objid == NULL_OBJID) goto wrapup;
  activeTreeID = activeTreeJD.id;
  
  // Get the info
  _RTCJDB(&activeTreeJD)->getBaseInfo(&activeTreeJD,&baseInfo);
  if (baseInfo.setType == NULL) goto wrapup;
  
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_TYPE,baseInfo.setType);
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_NAME,baseInfo.setName);

  sprintf(buf,"%s %s",baseInfo.setType,baseInfo.setName);
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_ACTIVE,buf);
  
  // For the description
  _RTCJDB(&activeTreeJD)->getSetTypeInfo(&activeTreeJD,&setTypeInfo);
  VDfrmSetgText(form,VDCT_FORM_SET_G_TREE_DESC,setTypeInfo.desc);

  // Adjust the doit gadget here
  VDct1CmdResetGadgetList(&activeTreeID,form,VDCT_FORM_SET_G_DOIT,1);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------
 * Called to activate the form
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");
  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->sets;
  Form   form   = formInfo->form;
  IGRint gadget = VDCT_FORM_SET_G_TREE_TYPE;

  TVDctSetTypeInfo setTypeInfo;
  TVDct1JD         setJD;
  IGRchar          buf[128];
  IGRint           i,row;
  
  // Display It
  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);

  // Fill in list of available sets
  VDfrmSetgListNumRows(form,gadget,0);
  VDfrmSetgText       (form,gadget,"");

  // Might actually be a good spot to show only valid set types

  // Tree interface
  row = 0;
  setJD.id.objid = NULL_OBJID;
  for(i = 0; setJD.cl = VDct1GetTreeClassForNth(i); i++) {

    _RTCJDB(&setJD)->getSetTypeInfo(&setJD,&setTypeInfo);

    // Validate the set type here
    // sts = _RTCJDB(&setJD)->allowedToCreateSetType(&setJD,setTypeInfo.setType);
    
    sprintf(buf,"%-10s %s",setTypeInfo.type,setTypeInfo.desc);
    VDfrmSetgListText(form,gadget,row,buf);
    row++;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitSetCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitSetCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_SET);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;
  
  // Default init
  formInfo = &cmdInfo->sets;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_SET_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->notifyForm   = notifyForm;
  formInfo->activateForm = activateForm;
  formInfo->activateNode = activateNode;

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

    


