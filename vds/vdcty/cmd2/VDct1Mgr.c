/* $Id: VDct1Mgr.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

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
 *      $Log: VDct1Mgr.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.10  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.9  2000/11/16  19:48:34  pinnacle
 * pn
 *
 * Revision 1.8  2000/09/07  18:04:04  pinnacle
 * js
 *
 * Revision 1.7  2000/08/25  19:59:44  pinnacle
 * ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDdom.h"
#include "VDctx.h"
#include "VDcty.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd/VDct1Mgr.c");

#define VDCT_FORM_MGR_B_STRU 25

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */
static TVDct1CmdInfo *cmdInfo;

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
static IGRstat notifyForm()
{
  VDASSERT_FN("notifyForm");
  
  IGRstat retFlag = 1;
  IGRstat msg;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);

  // Reset Status (needed for testing)
  VDfrmSetSts(cmdInfo->mgr.form,"");
  
  // Process It
  switch(cmdInfo->gadget) {

  case VDCT_FORM_MGR_B_SETS:
    cmdInfo->sets.activateForm();
    break;
    
  case VDCT_FORM_MGR_B_POST:
    cmdInfo->sets.activateForm();
    VDfrmSetgText(cmdInfo->sets.form,VDCT_FORM_SET_G_DOIT,"5 Post   Tree");    
    break;
    
  case VDCT_FORM_MGR_B_TREES:
    cmdInfo->tree.activateForm();
    break;
    
  case VDCT_FORM_MGR_B_LIBS:
    cmdInfo->lib.activateForm();
    break;
    
  case VDCT_FORM_MGR_B_ATTRS:
    cmdInfo->attr.activateForm();
    break;
    
  case VDCT_FORM_MGR_B_PART:
    cmdInfo->part.activateForm();
    break;
    
  case VDCT_FORM_MGR_B_NODES:
    cmdInfo->node.activateForm();
    break;

  case VDCT_FORM_MGR_B_STRU:    
    cmdInfo->stru.activateForm();
    break;
    
  case VDCT_FORM_MGR_B_DBTBL:
    cmdInfo->dbtbl.activateForm();
    break;

    case VDCT_FORM_MGR_B_FREE:
     cmdInfo->free.activateForm();
     break;
     

    case FI_CANCEL:
      cmdInfo->shutDown = 1;
      break;
  }
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Activate a node
 */
static IGRstat activateNode(TGRid *nodeID)
{
  VDASSERT_FN("activateNode");
  IGRstat retFlag = 0;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;

  TVDct1JD nodeJD;
  TVDctyTP *tp;
  
    // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Arg check
  VDASSERTW(nodeID);
#if 0 
  // Set the filter, call default if necessary
  nodeJD.id = *nodeID;
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);

  // Use default if no node is active
  if (nodeJD.cl == NULL) {
    nodeJD.cl = VDct1GetRootTreeClass();
  }
#endif
  VDctyGetFilter(NULL,NULL,nodeID,&cmdInfo->classList);

  // Pass it on
  for(i = 1; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->activateNode(nodeID);
  }

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Created a node
 */
static IGRstat createdNode(TGRid *nodeID)
{
  VDASSERT_FN("createdNode");
  IGRstat retFlag = 0;

  IGRint i;
  TVDct1CmdFormInfo *formInfo; 
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Arg check
  VDASSERTW(nodeID);
  
  // Pass it on
  for(i = 1; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->createdNode(nodeID);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Renamed a node
 */
static IGRstat renamedNode(TGRid *nodeID)
{
  VDASSERT_FN("renamedNode");
  IGRstat retFlag = 0;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(nodeID);
  
  // Pass it on
  for(i = 1; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->renamedNode(nodeID);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Deleted a node
 */
static IGRstat deletedNode(TGRid *nodeID, TGRid *parentID)
{
  VDASSERT_FN("deletedNode");
  IGRstat retFlag = 0;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(nodeID);
  VDASSERTW(parentID);
  
  // Pass it on
  for(i = 1; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->deletedNode(nodeID,parentID);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Created a tree
 */
static IGRstat createdTree(TGRid *nodeID)
{
  VDASSERT_FN("createdTree");
  IGRstat retFlag = 0;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(nodeID);
  
  // Pass it on
  for(i = 1; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->createdTree(nodeID);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Renamed a tree
 */
static IGRstat renamedTree(TGRid *nodeID)
{
  VDASSERT_FN("renamedTree");
  IGRstat retFlag = 0;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(nodeID);
  
  // Pass it on
  for(i = 1; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->renamedTree(nodeID);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Deleted a tree
 */
static IGRstat deletedTree(TGRid *nodeID)
{
  VDASSERT_FN("deletedTree");
  IGRstat retFlag = 0;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(nodeID);
  
  // Pass it on
  for(i = 1; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->deletedTree(nodeID);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitMgrCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitMgrCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;

  TVDct1JD mgrJD;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_MGR);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo  = a_cmdInfo;
  formInfo =  &cmdInfo->mgr;
  
  // Make sure manager is available
#if 0
  mgrJD.cl = VDct1GetRootTreeClass();
  VDASSERTW(mgrJD.cl);
  EX_findmod(NULL,&mgrJD.id.osnum);
  mgrJD.id.objid = NULL_OBJID;
  
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  if (mgrJD.id.objid == NULL_OBJID) {
    _RTCJDB(&mgrJD)->createManager(&mgrJD);
  }
  VDASSERTW(mgrJD.id.objid != NULL_OBJID);
#endif
  
  // Default init
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_MGR_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->notifyForm  = notifyForm;

  formInfo->createdTree = createdTree;
  formInfo->renamedTree = renamedTree;
  formInfo->deletedTree = deletedTree;

  formInfo->createdNode = createdNode;
  formInfo->renamedNode = renamedNode;
  formInfo->deletedNode = deletedNode;

  formInfo->activateNode = activateNode;
  
  // Pop it up
  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Reset Gadget List using a call to a custom routine
 *
 * Deisgned to make it easier to use getGadgetText when
 * filling in a gadget with a pick list.
 */
IGRstat VDct1CmdResetGadgetList(TGRid *nodeID, 
				Form   form, 
				IGRint gadget,
				IGRint keepDefault)
{
  VDASSERT_FN("VDct1CmdResetGadgetList");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDctxCP *nodeCP;
  TVDctyTP *nodeTP;
  
  IGRchar bufFirst  [128];
  IGRchar bufCurrent[128];
  IGRchar bufDefault[128];
  
  IGRchar buf[128];
  IGRchar formName[64];
  
  IGRint i;
  
  // Get the class pointer
  VDASSERTW(nodeID);
  nodeCP = VDctxGetNodeCP(nodeID);
  nodeTP = VDctyGetNodeTP(nodeCP,nodeID);
  
  // Get the form name
  VDfrmGetFormName(form,formName);  
  if (*formName == 0) goto wrapup;
  
  // Get the first value
  sts = VDctyGetGadgetText(nodeTP,nodeCP,nodeID,formName,gadget,0,bufFirst);
  if (!(sts & 1)) goto wrapup;
  
  // Save the existing selection (if any)
  VDfrmGetgText(form,gadget,bufCurrent);
  
  // if default is not set the first entry is always default
  if (keepDefault == 0) strcpy(bufCurrent,bufFirst);
  strcpy(bufDefault,bufFirst);
  
  // Reset list rows
  VDfrmSetgListNumRows(form,gadget,0);
  
  // Cycle through
  for(i = 0; VDctyGetGadgetText(nodeTP,nodeCP,nodeID,formName,gadget,i,buf); i++) {

    VDfrmSetgListText(form,gadget,i,buf);

    if (keepDefault) {

      // Ensure previous value is in the list of options
      if (!strcmp(bufCurrent,buf)) strcpy(bufDefault,bufCurrent);
    }
  }
  
  // Fill in actual value
  VDfrmSetgText(form,gadget,bufDefault);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
