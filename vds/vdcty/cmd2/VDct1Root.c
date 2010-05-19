/* $Id: VDct1Root.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1Root.C
 *
 * Description: Default Implementations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Root.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.10  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.9  2000/11/16  19:48:34  pinnacle
 * pn
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDobj2.h"
#include "VDdom.h"
#include "VDctx.h"
#include "VDcty.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd2/VDct1Root.c");

/* -----------------------------------------------
 * Default dummy implementations
 */
static IGRstat init()       { return 1; }

static IGRstat delet(void *a_formInfo)     
{
  TVDct1CmdFormInfo *formInfo = a_formInfo;
  
  VDASSERT_FN("delete");

  VDASSERTW(formInfo);  

  VDfrmDeleteForm(formInfo->form,1);

 wrapup:
  return 1; 
}

static IGRstat wakeup()       { return 1; }
static IGRstat sleep()        { return 1; }
static IGRstat notifyForm()   { return 1; }
static IGRstat activateForm() { return 1; }

static IGRstat createdTree (TGRid *treeID) { return 1; }
static IGRstat deletedTree (TGRid *treeID) { return 1; }
static IGRstat renamedTree (TGRid *treeID) { return 1; }
static IGRstat createdNode (TGRid *nodeID) { return 1; }
static IGRstat renamedNode (TGRid *nodeID) { return 1; }
static IGRstat activateNode(TGRid *nodeID) { return 1; }
static IGRstat deletedNode (TGRid *nodeID, TGRid *parentID) { return 1; }

static IGRstat locatedObject(TGRobj_env *locObj) { return 1; }

/* -----------------------------------------------
 * Only one instance of the command can run at a time
 * Makes the rest of the code easier since the pointers
 * Don't have to run around
 */
static TVDct1CmdInfo *g_cmdInfo;
static IGRint         formLabel;

#define VDCT1_DEBUG_CRASH 0

/* -----------------------------------------------
 * Setup default pointers
 * And create the actual form if formName is not NULL
 */
IGRstat VDct1CmdInitRootFormInfo(TVDct1CmdFormInfo *formInfo, IGRchar *formName)
{
  VDASSERT_FN("VDct1CmdInitRootFormInfo");

  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(formInfo);
  
  // Say Hi
  traceFlag = VDCT1_DEBUG_CRASH;
  if (traceFlag) {
    if (formName) printf(">>> %s %s %s\n",ffn(),fn,formName);
    else          printf(">>> %s %s\n",   ffn(),fn);
  }
  
  // Clear
  memset(formInfo,0,sizeof(TVDct1CmdFormInfo));
  
  // Fill in
  formInfo->init   = init;
  formInfo->delet  = delet;
  formInfo->wakeup = wakeup;
  formInfo->sleep  = sleep;
  
  formInfo->createdTree  = createdTree;
  formInfo->deletedTree  = deletedTree;
  formInfo->renamedTree  = renamedTree;
  
  formInfo->createdNode  = createdNode;
  formInfo->deletedNode  = deletedNode;
  formInfo->renamedNode  = renamedNode;  
  formInfo->activateNode = activateNode;

  formInfo->notifyForm    = notifyForm;
  formInfo->activateForm  = activateForm;
  formInfo->locatedObject = locatedObject;

  // Create the form
  if (formName) {    
    VDfrmNewForm(formLabel,formName,VDct1CmdNotifyRootForm,1,&formInfo->form);
    VDASSERTW(formInfo->form);
    formLabel++;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Provide nth access to each form 
 */
TVDct1CmdFormInfo *VDct1CmdGetNthFormInfo(TVDct1CmdInfo *cmdInfo, IGRint nth)
{
  VDASSERT_FN("VDct1CmdGetNthFormInfo");

  // Arg check
  VDASSERTW(cmdInfo);
  
  switch(nth) {
    
  case  0: return &cmdInfo->mgr;
  case  1: return &cmdInfo->sets;
#if 0
  case  2: return &cmdInfo->node;
  case  3: return &cmdInfo->tree;
  case  4: return &cmdInfo->attr;
  case  5: return &cmdInfo->lib;
  case  6: return &cmdInfo->free;
  case  7: return &cmdInfo->part;
  case  8: return &cmdInfo->misc;
  case  9: return &cmdInfo->stru;
  case 10: return &cmdInfo->dbtbl;
#endif 
  }
  
wrapup:
  return NULL;
}

/* ------------------------------------------------------
 * Either an object was located or a form was manipulated
 *
 * Can also be called directly from a test routine
 */
IGRstat VDct1CmdNotifyRootLocate(Form        form,
				 IGRint      gadget,
				 TGRobj_env *locatedOE)
{
  VDASSERT_FN("VDct1CmdNotifyRootLocate");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRint  i,j;
  TVDct1CmdFormInfo *formInfo;

  TVDct1CmdInfo *cmdInfo = g_cmdInfo;

  TGRobj_env *locOEs;
  IGRint      locNum;
  
  // See which form caused message
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Needs to ber initialized
  VDASSERTW(cmdInfo);

  // Need to prevent multiple notification events
  if (cmdInfo->isNotify) {
    if (traceFlag) printf("Nested notification, ignoring\n");
    goto wrapup;
  }
    
  // processing an event
  cmdInfo->isNotify = 1;
  
  // Was it a form
  if (form) {

    // Store it
    cmdInfo->form = form;
    cmdInfo->gadget = gadget;
    
    // Pass it off
    for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
      if (form == formInfo->form) {
	formInfo->notifyForm();
      }
    }
  }
  
  // Was it an object
  if (locatedOE) {
    
    // Selection set?
    sts = VDobjIsAncestryValid(locatedOE,NULL,0,"GRgrset");
    if (!(sts & 1)) {

      //VDct1CmdNodeDupFlag(0); 
 
      // Just One
      cmdInfo->locatedOE = *locatedOE;
      for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
	formInfo->locatedObject(); 
      }
      retFlag = 1;
    }
    else {
      
      /* -----------------------------------------
       * Might not be a bad idea to just copy the set into
       * a local buffer here, locOEs ends up pointing to a 
       * static buffer and there is nothing really stopping
       * stuff from messing around with it
       */

      // Process the set
      VDstart_var_fence(locatedOE,&locNum,&locOEs);
      
      // Cycle through
      for(j = 0; j < locNum; j = j + 1) {

	// Pass it off
	cmdInfo->locatedOE = locOEs[j];
	for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
	  formInfo->locatedObject(); 
	}
      }

      // Which takes care of locOEs
      ASend_fence(); 
    }
  }

  // Notify is done
  cmdInfo->isNotify = 0;
    
  // Pause for effect
  // sleep(5);
  
wrapup:

  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }
  // system("sleep 1");
  
  return retFlag;
}

/* ---------------------------------------------- 
 * Called when a form is manipulated
 * Used to break out of the main locate loop
 */
IGRint VDct1CmdNotifyRootForm(IGRint    formLabel,
			      IGRint    gadget,
			      IGRdouble value,
			      Form      form)
{
  VDASSERT_FN("VDct1CmdNotifyRootForm");
  IGRstat retFlag = 0;
  IGRstat msg;
  IGRint  response = RESET;
  
  // Make sure initialized
  VDASSERTW(g_cmdInfo);

  // Say Hi
  if (traceFlag) printf(">>> %s %s %d\n",ffn(),fn,gadget);
  
  // Store
  g_cmdInfo->form   = form;
  g_cmdInfo->gadget = gadget;

  // Break out of locate loop
  if (g_cmdInfo->isStandAlone) {

    // Process it
    VDct1CmdNotifyRootLocate(form,gadget,NULL);

    // See if done
    if (g_cmdInfo->shutDown) {

      /* ---------------------------------------------------
       * Need to see if there is a cleaner way to do this
       * Erase all forms to break out of notify loop
       */
      VDct1CmdDeleteRootCmdInfo();
      retFlag = 1;
      goto wrapup;
    }
  }  
  else {
    VDputResponse(response);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,gadget);
  }
  return retFlag;
}

/* ----------------------------------------------
 * To get things going
 */
IGRstat VDct1CmdInitRootCmdInfo(TVDct1CmdInfo *cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitRootCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    existingForm;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;

  TGRid fakeID;
  
  // Say Hi
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_ROOT);
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Make sure not running twice
  if (g_cmdInfo) {
    UI_status("Tree Already Running");
    if (traceFlag) {  
      printf("Tree Already runining\n");
    }
    // Dont go to wrapup
    return 0;
  }
  
  // Init
  VDASSERTW(cmdInfo);
  // memset(cmdInfo,0,sizeof(TVDct1CmdInfo));
  g_cmdInfo = cmdInfo;

  // Test the dom stuff
  // VDct1CmdTestLoadXml();
  
  // Reset label counter
  formLabel = 100;

  // Default filter
  cmdInfo->classList.p_classes = cmdInfo->classIDs;
  cmdInfo->classList.w_flags   = OM_CLST_subclass;

  fakeID.objid = NULL_OBJID;
  VDctyGetFilter(NULL,NULL,&fakeID,&cmdInfo->classList);
  
  //nodeJD.id.objid = NULL_OBJID;
  //nodeJD.cl = VDct1GetRootTreeClass();
  //VDjt1GetFilter(&nodeJD,&cmdInfo->classList);

  // Treat Root Special
  VDct1CmdInitRootFormInfo(&cmdInfo->root,NULL);

  // Cycle through and reset each available form structure
  for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    VDct1CmdInitRootFormInfo(formInfo,NULL);
  }
  
  // Each Form Has a Custom Init to override functions
  VDASSERTW(VDct1CmdInitTest        (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitMgrCmdInfo  (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitSetCmdInfo  (cmdInfo) & 1);
#if 0
  VDASSERTW(VDct1CmdInitTreeCmdInfo (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitPartCmdInfo (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitStruCmdInfo (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitLibCmdInfo  (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitAttrCmdInfo (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitNodeCmdInfo (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitDbTblCmdInfo(cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitFreeCmdInfo (cmdInfo) & 1);
  VDASSERTW(VDct1CmdInitBoxCmdInfo  (cmdInfo) & 1);
#endif

  // Fire off real init message
  for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->init();
  }
 
  // Done
  retFlag = 1;
  
wrapup:

  if (!(retFlag)) g_cmdInfo = NULL;

  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
  
}

/* -----------------------------------------------
 * Shutdown the command
 */
IGRstat VDct1CmdDeleteRootCmdInfo()
{
  IGRstat retFlag = 0;
  TVDct1CmdInfo *cmdInfo = g_cmdInfo;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;
  
  VDASSERT_FN("VDct1CmdDeleteRootCmdInfo");

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  /* ---------------------------------------------
   * This is ok since a problem in initilization
   * will still result in a delete message
   */
  if (cmdInfo == NULL) goto wrapup;
  
  // Free everything up
  for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    formInfo->delet(formInfo);
  }

  // Done
  retFlag = 1;
  
 wrapup:
  g_cmdInfo = NULL;
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
