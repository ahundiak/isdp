/* $Id: VDct1Root.c,v 1.7 2002/02/22 15:08:58 jdsauby Exp $  */

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
 *      Revision 1.7  2002/02/22 15:08:58  jdsauby
 *      JTSMP TR 6042
 *
 *      Revision 1.6  2002/01/10 19:10:32  jdsauby
 *      JTSMP CR 5679, added event gadgets to LIB and TREE forms.
 *
 *      Revision 1.5  2001/10/18 20:43:29  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/05/08 19:45:56  jdsauby
 *      CR 5097.  For this, filtered possible duplicate object IDs  -jds
 *
 *      Revision 1.3  2001/04/30 12:31:07  jdsauby
 *      CR 5097, Cable crash when cable is bad, plus get rid of "No GetBaseInfo errors"  - jds
 *
 *      Revision 1.2  2001/04/03 17:09:36  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/14 16:21:13  art
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
 * Revision 1.6  2000/08/17  11:31:40  pinnacle
 * js
 *
 * Revision 1.5  2000/08/09  13:07:24  pinnacle
 * ah
 *
 * Revision 1.4  2000/08/08  16:35:14  pinnacle
 * ah
 *
 * Revision 1.2  2000/08/04  19:26:08  pinnacle
 * js
 *
 * Revision 1.1  2000/07/27  15:13:14  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 * 04/03/01  ah      Reinit tree pointers during each startup for service packs
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDobj2.h"
#include "VDctx.h"
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

extern IGRint ci_notification(IGRint    f_label,
			      IGRint    gadget,
			      IGRdouble value,
			      Form      form);

void VDct1CmdGetNavEventID(TGRid *objID)
{
  VDASSERT_FN("VDct1GetNavEventID");
  
  VDASSERTW(objID); objID->objid = NULL_OBJID;
  VDASSERTW(g_cmdInfo);
  
  *objID = g_cmdInfo->eventID;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Setup default pointers
 * And create the actual form if formName is not NULL
 */
IGRstat VDct1CmdInitRootFormInfo(TVDct1CmdFormInfo *formInfo, IGRchar *formName)
{
  VDASSERT_FN("VDct1CmdInitRootFormInfo");

  IGRstat retFlag = 0;
  IGRstat sts;
  
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

  //printf("###cmdID.objid = %d\n",g_cmdInfo->cmdID.objid);

  // Create the form
  if (formName) {   
      if (g_cmdInfo->cmdID.objid != NULL_OBJID)
      {
	  sts = VDfrmCreateForm(formLabel,
			    formName,
			    ci_notification,
			    g_cmdInfo->cmdID.objid,
			    g_cmdInfo->cmdID.osnum,
			    &formInfo->form,1);

      }
      else {
	
	  sts = VDfrmNewForm(formLabel,
	  		     formName,
			     VDct1CmdNotifyRootForm,1,&formInfo->form);
      }  
      VDASSERTW(sts);
      VDASSERTW(formInfo->form);

      //VDfrmNewForm(formLabel,formName,VDct1CmdNotifyRootForm,1,&formInfo->form);
      //VDASSERTW(formInfo->form);
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
  case  2: return &cmdInfo->node;
  case  3: return &cmdInfo->tree;
  case  4: return &cmdInfo->attr;
  case  5: return &cmdInfo->lib;
  case  6: return &cmdInfo->free;
  case  7: return &cmdInfo->part;
  case  8: return &cmdInfo->misc;
  case  9: return &cmdInfo->stru;
  case 10: return &cmdInfo->dbtbl;
      
  }
  
wrapup:
  return NULL;
}

/* -----------------------------------------------------
 * compare to object ids
 * **/
static IGRint compareLocatedOE(const void *id1,
                               const void *id2)
{
  VDASSERT_FN("compareLocatedOE");

  TGRobj_env *objOE1 = (TGRobj_env *)id1;
  TGRobj_env *objOE2 = (TGRobj_env *)id2;

  if (objOE1->obj_id.osnum < objOE2->obj_id.osnum) return -1;
  if (objOE1->obj_id.osnum > objOE2->obj_id.osnum) return 1;

  if (objOE1->obj_id.osnum == objOE2->obj_id.osnum) {
      if (objOE1->obj_id.objid < objOE2->obj_id.objid) return -1;
      if (objOE1->obj_id.objid > objOE2->obj_id.objid) return 1;
  }
  
  // The two are equal
  return 0;
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
  //traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
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

      // sort the list of objects
      qsort(locOEs,locNum,sizeof(TGRobj_env),compareLocatedOE);

      // Cycle through, set duplicates to NULL_OBJID
      for(j = 1; j < locNum; j = j + 1) {

	  if (!compareLocatedOE(&locOEs[j-1],&locOEs[j])) {
	      // set it equal to NULL_OBJID
	      locOEs[j-1].obj_id.objid = NULL_OBJID;
	  }
      }

      // Cycle through to send off
      for(j = 0; j < locNum; j = j + 1) {

	  // Pass it off
	  if (locOEs[j].obj_id.objid != NULL_OBJID) {
	      
	      cmdInfo->locatedOE = locOEs[j];
	      for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
		  formInfo->locatedObject(); 
	      }
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
  //traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,gadget);
  }
  
  // Store
  g_cmdInfo->form   = form;
  g_cmdInfo->gadget = gadget;

  // do it
  VDct1CmdNotifyRootLocate(g_cmdInfo->form,g_cmdInfo->gadget,NULL);

  // Break out of locate loop
  VDputResponse(response);
  
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
IGRstat VDct1CmdInitRootCmdInfo(TVDct1CmdInfo *cmdInfo,
			        VDobjid        pplObjid,
				VDosnum        pplOsnum)
{
  VDASSERT_FN("VDct1CmdInitRootCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    existingForm;

  IGRint i;
  TVDct1CmdFormInfo *formInfo;

  TVDct1JD nodeJD;
  
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

  // Reinit tree function system
  VDct1InitSystem(1);
  
  // Init
  VDASSERTW(cmdInfo);
  memset(cmdInfo,0,sizeof(TVDct1CmdInfo));
  g_cmdInfo = cmdInfo;

  // Test the dom stuff
  // VDct1CmdTestLoadXml();
  
  // Reset label counter
  formLabel = 100;

  // Default filter
  cmdInfo->classList.p_classes = cmdInfo->classIDs;
  cmdInfo->classList.w_flags   = OM_CLST_subclass;
  cmdInfo->cmdID.objid         = pplObjid;
  cmdInfo->cmdID.osnum         = pplOsnum;
  cmdInfo->sleep               = 0;
  cmdInfo->eventID.objid       = NULL_OBJID;

  nodeJD.id.objid = NULL_OBJID;
  nodeJD.cl = VDct1GetRootTreeClass();
  VDjt1GetFilter(&nodeJD,&cmdInfo->classList);

  // Treat Root Special
  VDct1CmdInitRootFormInfo(&cmdInfo->root,NULL);

  // Cycle through and reset each available form structure
  for(i = 0; formInfo = VDct1CmdGetNthFormInfo(cmdInfo,i); i++) {
    VDct1CmdInitRootFormInfo(formInfo,NULL);
  }
  
  // Each Form Has a Custom Init to override functions
  sts = VDct1CmdInitTest(cmdInfo);
  VDASSERTW(sts & 1);

  sts = VDct1CmdInitMgrCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitSetCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitTreeCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitPartCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitStruCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitLibCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitAttrCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitNodeCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitDbTblCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitFreeCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  sts = VDct1CmdInitBoxCmdInfo(cmdInfo);
  VDASSERTW(sts & 1);
  
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
