/* $Id: VDct1Free.c,v 1.1 2001/01/14 16:21:13 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1Free.C
 *
 * Description: Freeze Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Free.c,v $
 *      Revision 1.1  2001/01/14 16:21:13  art
 *      sp merge
 *
 * Revision 1.4  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.3  2000/11/17  14:03:14  pinnacle
 * pn
 *
 * Revision 1.2  2000/11/16  19:48:34  pinnacle
 * pn
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/16/00  pn      Creation
 *
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Attrs.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd2/VDct1Node.C");

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */

static TVDct1CmdInfo *cmdInfo;
static TGRid          activeNodeID;
static TVDct1JD       activeNodeJD;
static IGRstat        activateNode(TGRid *nodeID);

/* -------------------------------------------
 * Called to activate the form
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->free;
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Display It
  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);

  // get the activeNodeID and set up the appropriate display location
  activateNode(&activeNodeID);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * marks node deleted and cans the kids
 */
static IGRstat markActiveDeleted()
{
  VDASSERT_FN("markActiveDeleted");
  IGRstat retFlag = 1; 
  IGRstat sts;
  IGRint  i;
  IGRchar buf[128],msg[128];
  Form    form  = cmdInfo->free.form;
  TVDct1JD childJD;
  TVDctBaseInfo baseInfo;
  IGRint  noFlag; 
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  sts = VDjt1IsMarkDeletedOK(&activeNodeJD);

  // is it ok to do?
  if(!(sts & 1)) {
    strcpy(buf,"Node is not Active");
    VDfrmSetSts(form,buf);
    goto wrapup;
  }

  // get the baseInfo
  _RTCJDB(&activeNodeJD)->getBaseInfo(&activeNodeJD,&baseInfo);

  // ask if you really want to do this!
  // Confirm Deletion
  sprintf(msg,"Mark Deleted %s?",baseInfo.nodeName);
  VDct1CmdBoxYesOrNo(msg,&noFlag);
  if (noFlag) goto wrapup;
  
  // mark it deleted
  VDjt1SetAttr(&activeNodeJD,VDCT1_ATTR_FROZEN,VDCT1_DEFAULT_FROZEN_D);
  //activateNode(&activeNodeID);

  // delete the kids
  VDjt1DeleteAllChildNodes(&activeNodeJD);

  // notify the other forms
  cmdInfo->mgr.createdNode (&activeNodeJD.id);
  cmdInfo->mgr.activateNode(&activeNodeJD.id);
  VDfrmSetSts(cmdInfo->node.form,"");
  
  // tell this form what happened
  strcpy(buf,"Node Marked Deleted");
  VDfrmSetSts(form,buf);

  // Done
  activateNode(&activeNodeID);
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}
 
/* -------------------------------------------
 * marks deleted node active again
 */
static IGRstat markDeletedActive()
{
  VDASSERT_FN("markActiveDeleted");
  IGRstat retFlag = 1; 
  IGRstat sts;
  IGRint  i;
  Form    form  = cmdInfo->free.form;
  IGRchar buf[128];

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // is it ok to do?
  sts = VDjt1IsUnmarkDeletedValid(&activeNodeJD);
  if(!(sts & 1)) {
    strcpy(buf,"Node is not marked Deleted");
    VDfrmSetSts(form,buf);
    goto wrapup;
  }

  // mark it active
  VDjt1SetAttr(&activeNodeJD,VDCT1_ATTR_FROZEN,VDCT1_DEFAULT_FROZEN_A);
  //activateNode(&activeNodeID);

  // notify the other forms
  cmdInfo->mgr.createdNode (&activeNodeJD.id);
  cmdInfo->mgr.activateNode(&activeNodeJD.id);
  VDfrmSetSts(cmdInfo->node.form,"");

  // tell this form what happened
  strcpy(buf,"Node Activated");
  VDfrmSetSts(form,buf);

  // Done
  activateNode(&activeNodeID);
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

  TVDct1CmdFormInfo *formInfo = &cmdInfo->free;
  Form    form  = cmdInfo->free.form;
  IGRchar buf[128];
  IGRchar cmd;
    
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the command string
  VDfrmGetgText(formInfo->form,VDCT_FORM_FREE_G_DOIT,buf);  
  cmd = *buf;

  // Switch it
  switch(cmd) {
    case '1':
      // mark Deleted
      markActiveDeleted();
      break;
      
    case '2':
      markDeletedActive();
      // activate the Deleted 
      break;
      
    case '3':
      //notifyDeleteTree();
      break;
      
    case '4':
      //notifyRenameTree();
      break;
      
    case '5':
      //notifyPostTree();
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

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
static IGRstat notifyForm()
{
  VDASSERT_FN("notifyForm");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->free;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Reset Status (needed for testing)
  VDfrmSetSts(cmdInfo->free.form,"");
  
  // Process It
  switch(cmdInfo->gadget) {

    case FI_EXECUTE:
      sts = notifyDoit();
      break;

    case FI_ACCEPT:
      sts = notifyDoit();
      if (sts & 1) {
	VDfrmDisplayForm(formInfo->form,0,&formInfo->displayed);
      }
      break;

    case FI_RESET:
      // reset the ID's
      if(traceFlag) printf("Testing the Reset\n");
      activeNodeID.objid   == NULL_OBJID;
      activeNodeJD.id = activeNodeID;
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
  
  Form    form  = cmdInfo->free.form;
  IGRint           gadget;
  TVDctBaseInfo    baseInfo;
  TVDctSetTypeInfo setTypeInfo;
  
  TVDct1JD        activeJD;
  TVDct1JD        activeTreeJD;
    
  IGRchar buf[128],attrFrozen[128],attrAssyRev[128],cmd,bufGadget[128];
  IGRint  sts;
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
 
  // args check
  VDASSERTW(nodeID);

  // Store it
  activeNodeID = *nodeID;
  strcpy(attrFrozen,"");
  strcpy(attrAssyRev,"");

  // get the class
  activeNodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeNodeJD.cl == NULL) goto wrapup;
  activeNodeJD.id = activeNodeID;

  // check the node status for deleted/active/frozen
  sts = VDjt1GetAttr(&activeNodeJD,VDCT1_ATTR_FROZEN,attrFrozen);
  
  cmd = *attrFrozen;

  // get the Revision of the node
  sts = VDjt1GetAttr(&activeNodeJD,VDCT1_ATTR_ASSY_REV,attrAssyRev);

  // get the baseInfo stuff
  _RTCJDB(&activeNodeJD)->getBaseInfo(&activeNodeJD,&baseInfo);
  sprintf(buf,"%s %s",baseInfo.nodeType,baseInfo.nodeName);
  
  // reset the form each time a node is selected
  FIf_reset(form);
  gadget = VDCT_FORM_FREE_G_DOIT;

  switch(cmd) {
    case 'A':   
      // copy in the name to the proper gadget
      VDfrmSetgText(form,VDCT_FORM_FREE_G_NODE_ACTIVE,buf);
 
      // copy the rev in the right gadget
      VDfrmSetgText(form,VDCT_FORM_FREE_G_REV_ACTIVE,attrAssyRev);

      sts = VDjt1IsMarkDeletedOK(&activeNodeJD);
      if(sts & 1) {
        VDfrmSetSts(form,"Node may be marked Deleted");
      }
      else {
        VDfrmSetSts(form,"Node Status cannot be changed");
      }
      break;
      
    case 'D':
      // copy in the name to the proper gadget
      VDfrmSetgText(form,VDCT_FORM_FREE_G_NODE_DEL,buf);
      VDfrmSetSts  (form,"Node may be made Active");
      break;
      
    case 'F':
      // copy in the name to the proper gadget
      VDfrmSetgText(form,VDCT_FORM_FREE_G_NODE_FROZEN,buf);

      // copy the rev in the right gadget
      VDfrmSetgText(form,VDCT_FORM_FREE_G_REV_FROZEN,attrAssyRev);
      break;
      
    default:
      // copy in the name to the proper gadget
      VDfrmSetgText(form,VDCT_FORM_FREE_G_NODE_ACTIVE,buf);

      // copy the rev in the right gadget
      VDfrmSetgText(form,VDCT_FORM_FREE_G_REV_ACTIVE,"");

      VDfrmSetSts(form,"Node Status cannot be changed");

      break;
  }

  // reset the gadget list
  VDct1CmdResetGadgetList(&activeNodeID,form,gadget,1);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}


/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitFreeCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitFreeCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_FREE);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Set the statics
  cmdInfo =  a_cmdInfo;
  
  // Default init
  formInfo = &cmdInfo->free;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_FREE_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->notifyForm          = notifyForm;
  formInfo->activateForm        = activateForm;
  formInfo->activateNode        = activateNode;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}




















