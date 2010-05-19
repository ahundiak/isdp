/* $Id: VDct1Tree.c,v 1.7 2002/05/16 21:22:49 jdsauby Exp $  */

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
 *      $Log: VDct1Tree.c,v $
 *      Revision 1.7  2002/05/16 21:22:49  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.6  2002/01/10 19:10:34  jdsauby
 *      JTSMP CR 5679, added event gadgets to LIB and TREE forms.
 *
 *      Revision 1.5  2002/01/07 18:55:25  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.4  2001/10/18 20:43:29  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/17 14:45:07  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/06 15:14:46  jdsauby
 *      Added VDct1ScanTree
 *
 *      Revision 1.1  2001/01/14 16:21:13  art
 *      sp merge
 *
 * Revision 1.9  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.8  2000/11/16  19:48:34  pinnacle
 * pn
 *
 * Revision 1.7  2000/09/20  21:08:34  pinnacle
 * js
 *
 * Revision 1.5  2000/09/20  21:05:08  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDos.h"
#include "VDctx.h"
#include "VDfrmc.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd/VDct1Tree.c");

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */
static TVDct1CmdInfo *cmdInfo;
static TGRid activeNodeID;

/* --------------------------------------
 * Fill in the list of trees for the osnum
 * returns 0 when os is invalid
 */
static IGRstat fillTreeListForOS(TVDosnum osnum)
{
  VDASSERT_FN("fillTreeListForOS");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid mgrID,setID;
  
  IGRint  i,flag;

  Form   form   = cmdInfo->tree.form;
  IGRint gadget = VDCT_FORM_TREE_G_TREE;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,osnum);
  }
  
  // Validate os
  sts = VDosValidate(osnum);
  if (!(sts & 1)) goto wrapup;
  retFlag = 1;

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

      VDct1FormAppendTree(form,gadget,&setID);
    
  }
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d %d\n",ffn(),fn,osnum,retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------------
 * Initial fill of the tree gadget
 */
static IGRstat fillTreeList()
{
  VDASSERT_FN("filTreeList");
  
  IGRstat retFlag = 0;
  
  Form    form   = cmdInfo->tree.form;
  IGRint  gadget = VDCT_FORM_TREE_G_TREE;
  IGRint  i;
  
  VDosnum osnum;
  
  TGRid mgrID,setID;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // This resets the tree form
  VDct1FormAppendTree(form,gadget,NULL);

  // Only show active os trees
  EX_findmod(NULL, &osnum);
  fillTreeListForOS(osnum);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag); 
  return retFlag;
}
/* -------------------------------------------
 * Tree notification routine
 */
static IGRstat notifyTreeGadget()
{
  VDASSERT_FN("notifyTreeGadget");
  
  IGRstat retFlag = 0;
  TGRid   nodeID;
  
  Form   form   = cmdInfo->tree.form;
  IGRint gadget = VDCT_FORM_TREE_G_TREE;
    
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Standard tree handler  
  VDct1FormNotifyTree(form,gadget,&nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Activate It
  cmdInfo->mgr.activateNode(&nodeID);
    
  // Done
  retFlag = 1;
  
wrapup:
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

  TVDct1CmdFormInfo *formInfo = &cmdInfo->tree;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Process It
  switch(cmdInfo->gadget) {

    case VDCT_FORM_TREE_G_TREE:
      notifyTreeGadget();
      break;

    case VDCT_FORM_TREE_G_EVENT:
      cmdInfo->event = 1;
      break;
    
    case FI_CANCEL:
      VDfrmDisplayForm(formInfo->form,0,&formInfo->displayed);
      break;
  }
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Renamed a node
 */
static IGRstat renamedNode(TGRid *nodeID)
{ 
  VDASSERT_FN("renamedNode");
  
  IGRstat retFlag   = 0;
  
  IGRint row;

  Form form = cmdInfo->tree.form;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // args check
  VDASSERTW(nodeID);
  
  // Find it
  VDct1FormFindTreeRow(form,VDCT_FORM_TREE_G_TREE,nodeID,&row);
  if (row < 0) goto wrapup;
  
  // Refresh it
  VDct1FormRefreshNodeName(form,VDCT_FORM_TREE_G_TREE,row,nodeID);

  // refresh the entire thing
  VDct1FormUpdateTreeRow(form, VDCT_FORM_TREE_G_TREE, nodeID);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Deleted a node
 */
static IGRstat deletedNode(TGRid *nodeID, TGRid *parentID)
{
  VDASSERT_FN("deletedNode");
  IGRstat retFlag = 0;
  
  Form form = cmdInfo->tree.form;
  
  // Arg check
  VDASSERTW(nodeID);
  VDASSERTW(parentID);
  
  // Delete the row
  VDct1FormDeleteTreeRowID(form, VDCT_FORM_TREE_G_TREE, nodeID);

  // Refresh the parent
  VDct1FormUpdateTreeRow(form, VDCT_FORM_TREE_G_TREE, parentID);

  // update the summary
  // VDct1FormUpdateVRTree(form, VDCT_FORM_TREE_G_TREE);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Created a Node
 */
static IGRstat createdNode(TGRid *nodeID)
{  
  VDASSERT_FN("createdNode");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form  form = cmdInfo->tree.form;
  
  TGRid parentID;
  
  // Arg check
  VDASSERTW(nodeID);

  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s %d,%d\n",ffn(),fn,nodeID->osnum,nodeID->objid);
  }
  
  // Get parent
  VDctxGetTreeParent(nodeID,&parentID);
  VDASSERTW(parentID.objid != NULL_OBJID);

  if (traceFlag) {
    VDobjPrint2(NULL,&parentID);
  }
  
  // Update form
  sts = VDct1FormUpdateTreeRow(form,VDCT_FORM_TREE_G_TREE,&parentID);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Expand it if needed
  createdNode(&parentID);
  VDct1FormUpdateTreeRow(form,VDCT_FORM_TREE_G_TREE,&parentID);

  // update the summary
  // VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Called when a node is activated
 *
 * Note, by design, activateNode does NOT select node
 * In the tree, not positive why but leave for now
 */
static IGRstat activateNode(TGRid *nodeID)
{  
  VDASSERT_FN("activateNode");
  
  IGRstat       retFlag = 0;
  IGRchar       buf[128];

  Form form = cmdInfo->tree.form;
  
  IGRint i;
  TVDctxBaseInfo baseInfo;
  
  // Save it
  VDASSERTW(nodeID);
  activeNodeID = *nodeID;

  // Update selected tree name
  VDctxGetBaseInfo(nodeID,&baseInfo);
    
  // Build display name
  sprintf(buf,"%s %s",baseInfo.setType,baseInfo.setName);
  VDfrmSetgText(form,VDCT_FORM_TREE_G_SET_NAME,buf);

  // Update the display pick list
  VDct1CmdResetGadgetList(nodeID,form,VDCT_FORM_TREE_G_DISPLAY,1);
  
  // Done
  retFlag = 1;
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Standard tree changes
 */
static IGRstat createdTree(TGRid *treeID)
{  
  fillTreeList();
  return 1;
}

static IGRstat deletedTree(TGRid *treeID)
{  
  fillTreeList();

  // update the summary
  // VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
 
  return 1;
}

static IGRstat renamedTree(TGRid *treeID)
{  
  fillTreeList();
  return 1;
}

/* -----------------------------------------------
 * Regular Init
 */
static IGRstat init()
{
  VDASSERT_FN("init");
  IGRstat retFlag = 0;
  
  // Clear
  activeNodeID.objid = NULL_OBJID;
  
  // fill
  fillTreeList();
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Called to activate the form (from the manager)
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");
  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->tree;
  
  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);

  // disable EVENT buttons if not in sleep mode
  if (!cmdInfo->sleep) VIg_disable(formInfo->form,VDCT_FORM_TREE_G_EVENT);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitTreeCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitTreeCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Say Hi
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_TREE);
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;
  
  // Default init
  formInfo = &cmdInfo->tree;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_TREE_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->activateNode = activateNode;
  formInfo->activateForm = activateForm;
  formInfo->notifyForm   = notifyForm;

  formInfo->renamedNode  = renamedNode;
  formInfo->deletedNode  = deletedNode;
  formInfo->createdNode  = createdNode;

  formInfo->renamedTree  = renamedTree;
  formInfo->deletedTree  = deletedTree;
  formInfo->createdTree  = createdTree;

  formInfo->init         = init;
  
  // Pop it up
  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);

  // disable EVENT buttons if not in sleep mode
  if (!cmdInfo->sleep) VIg_disable(formInfo->form,VDCT_FORM_TREE_G_EVENT);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
