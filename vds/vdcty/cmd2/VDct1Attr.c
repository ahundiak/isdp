/* $Id: VDct1Attr.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1Attr.C
 *
 * Description: Attribute Manipulation Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Attr.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.10  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.9  2000/11/16  19:48:34  pinnacle
 * pn
 *
 * Revision 1.8  2000/10/11  20:29:04  pinnacle
 * js
 *
 * Revision 1.7  2000/09/20  21:08:34  pinnacle
 * js
 *
 * Revision 1.6  2000/08/25  16:45:20  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDdom.h"
#include "VDctx.h"
#include "VDcty.h"
#include "VDfrmc.h"

#include "VDct1Cmdx.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Part.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"
#include "VDct1Attrs.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/cmd2/VDct1Attr.C");

static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;
static TGRid lockedNodeID;

static IGRstat renamedNode(TGRid *nodeID)
{ 
  VDASSERT_FN("renamedNode");
  
  IGRstat retFlag = 0;
  Form form = cmdInfo->attr.form;

  TVDctxBaseInfo baseInfo;
  IGRint         state; 
  
  VDASSERTW(nodeID);

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Set up active
  activeNodeID = *nodeID;
  VDctxGetBaseInfoID(NULL,nodeID,&baseInfo);
  VDfrmSetgText(form,VDCT_FORM_ATTR_G_ACTIVE_NODE,baseInfo.baseName);

  // And the locked if not locked
  VDfrmGetState(form,VDCT_FORM_ATTR_T_LOCKED_NODE,&state);

  if ((state == 0) || (nodeID->objid == NULL_OBJID)) {

    lockedNodeID = *nodeID;

    VDfrmSetgText(form,VDCT_FORM_ATTR_G_LOCKED_NODE,baseInfo.baseName);
  }

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

static IGRstat deletedNode(TGRid *nodeID, TGRid *parentID)
{    
  VDASSERT_FN("deletedNode");
  
  IGRstat     sts;
  
  Form        form = cmdInfo->attr.form;
  TGRid       workID;
  
  VDASSERTW(nodeID);
  VDASSERTW(parentID);
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  VDfrmSetSts(form,"Active Node Deleted.");

  // clear up the attr.form
  cmdInfo->attr.activateNode(&workID);
  
wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return 1;
}


static IGRstat deletedTree(TGRid *treeID)
{ 
  VDASSERT_FN("deletedTree");
  
  IGRstat   sts;
  
  Form      form = cmdInfo->attr.form;
  TGRid     workID;
  
  VDASSERTW(treeID);

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
  // notify of deletion on attr.form 
  VDfrmSetSts(form,"Active Node Deleted.");

  // clear up the attr.form
  cmdInfo->attr.activateNode(&workID);
    
 wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return 1;
}

/* -------------------------------------------
 * Updates row by pasting from buffer
 */
static IGRstat attrPasteAttrRow(Form    form,
				IGRint  gadget,
				IGRint  row,
				IGRint  cnt,
				TVDfld *flds)
{
  VDASSERT_FN("attrPasteAttrRow");
  IGRstat retFlag = 0;

  IGRint  i;
  IGRchar buf[256];

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Get the name
  VDfrmGetfText(form,gadget,row,VDCT_FORM_ATTR_L_ATTRS_COL_NAME,buf);
  
  // Find it
  for(i = 0; (i < cnt) && (strcmp(buf,flds[i].name)); i++);
  if (i == cnt) goto wrapup;

  // Update the form with any changes
  VDfrmSetfText(form,gadget,row,VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,flds[i].val.txt);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * Paste Attribute Values from buffer
 */
static IGRstat attrNotifyPaste(IGRchar cmd)
{
 VDASSERT_FN("attrNotifyPaste");
  IGRstat retFlag = 0;
  
  Form   form   = cmdInfo->attr.form;
  IGRint gadget = VDCT_FORM_ATTR_L_ATTRS;
   
  IGRint row,rows;
  
  TGRid   copiedNodeID;
  TVDfldS flds;

    // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  // This is the list of passed attributes 

  VDct1GetLastIDFromVLAID(&copiedNodeID);
  
  VDctxGetFldAtrsID(NULL,&copiedNodeID,&flds.cnt,flds.fld);
 
  // Cycle through each row gadget
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  for(row = 0; row < rows; row++) {
    attrPasteAttrRow(form,gadget,row,flds.cnt,flds.fld);
  }

  // Done
  retFlag = 1;
  
//wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * Reads one row from the gadget
 * and updates the list of fields
 */
static IGRstat attrReadAttrRow(TVDct1JD *nodeJD,
			       Form      form,
			       IGRint    gadget,
			       IGRint    row,
			       IGRint    cnt,
			       TVDfld   *flds,
			       IGRchar  *msg)
{
  VDASSERT_FN("attrReadAttrRow");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  i;
  IGRchar attrName  [256];
  IGRchar attrValue [256];
  IGRchar attrValuex[256];

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  //init
  strcpy(attrValuex,"");
    
  // Get the name
  VDfrmGetfText(form,gadget,row,VDCT_FORM_ATTR_L_ATTRS_COL_NAME,attrName);
  
  // Find it
  for(i = 0; (i < cnt) && (strcmp(attrName,flds[i].name)); i++);
  if (i == cnt) goto wrapup;
  
  // Pull the value
  VDfrmGetfText(form,gadget,row,VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,attrValue);

  // Validate the value of the attribute
  sts = _RTCJDC(nodeJD)->validateAttrValue(nodeJD,attrName,attrValue,attrValuex,msg);
  if (!(sts & 1)) goto wrapup;

  // Update the form with any changes
  VDfrmSetfText(form,gadget,row,VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,attrValuex);

  // Store it
  strcpy(flds[i].val.txt,attrValuex);

  // Propagate attribute value down to the children
  if (strcmp(attrValuex,"")) {
    //printf("Going to Test VDct1Attr.C: calling isAttrPropagateValid\n");
    
    if ( _RTCJDC(nodeJD)->isAttrPropagateValid(nodeJD,attrName) )
      //printf("attrName [%s]\n",attrName);
      _RTCJDC(nodeJD)->updateChildAttrValue(nodeJD,attrName,attrValuex);
  }
  //printf("Returned from Test VDct1Attr.C: calling isAttrPropagateValid\n");
    
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------------
 * Fill 1 row in the attribute list
 */
static IGRstat attrFillAttrListRow(TGRid *nodeID, 
				   Form    form, 
				   IGRint  gadget, 
				   IGRint *row, 
				   TVDfld *fld)
{
  VDASSERT_FN("attrFillAttrListRow");
  IGRstat retFlag = 0;
  IGRchar buf[256];
  
  TVDctAttrInfo attrInfo;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Arg check
  if (fld == NULL) goto wrapup;
  if (row == NULL) goto wrapup;
  
  // Lookup attribute information
  VDct1GetAttrInfo(nodeID,fld->name,&attrInfo);
  
  // Base
  if (*attrInfo.base) {
    VDfrmSetfText(form,gadget,*row,VDCT_FORM_ATTR_L_ATTRS_COL_BASE,attrInfo.base);
  }
  else {  
    VDfrmSetfText(form,gadget,*row,VDCT_FORM_ATTR_L_ATTRS_COL_BASE,fld->name);
  }
  
  // Type
  VDfldGetTypeText(NULL,fld->type,buf);
  VDfrmSetfText(form,gadget,*row,VDCT_FORM_ATTR_L_ATTRS_COL_TYPE,buf);

  // The value
  VDfrmSetfText(form,gadget,*row,VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,fld->val.txt);

  // Hidden name
  VDfrmSetfText(form,gadget,*row,VDCT_FORM_ATTR_L_ATTRS_COL_NAME,fld->name);
   
  // Done
  *row = *row + 1;
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * Fill the list gadget
 */
static IGRstat attrFillAttrList(TGRid  *nodeID,
				Form    form,
				IGRint  gadget,
				IGRint  cnt, 
				TVDfld *flds)
{
  VDASSERT_FN("attrFillAttrList");
  
  IGRstat retFlag = 0;
  IGRint  i,row, sts;
  IGRint  review;
  IGRchar buf[128];
  
  TVDctAttrInfo attrInfo;
  TVDct1JD      nodeJD;
  
  //  Form  form = cmdInfo->attr.form;

  // Arg check
  VDASSERTW(flds != NULL);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // get the state of the form
  VDfrmGetState(form,VDCT_FORM_ATTR_T_UPDATE,&review);
  
  // Doit
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (nodeJD.cl == NULL) goto wrapup;
  nodeJD.id = *nodeID;
    
  VDfrmSetNumRows(form,gadget,0);
  row = 0;
  
  for(i = 0; i < cnt; i++) {

    // Lookup attribute information
    VDct1GetAttrInfo(nodeID,flds[i].name,&attrInfo);
   
    // set the gadget to the active set
    if ((review) && (!(_RTCJDC(&nodeJD)->isAttrUpdateValid(&nodeJD,flds[i].name)))) {
      gadget = VDCT_FORM_ATTR_L_ATTRS;
      attrFillAttrListRow(nodeID,form,gadget,&row,&flds[i]);
    }
    if ((!review) && (_RTCJDC(&nodeJD)->isAttrUpdateValid(&nodeJD,flds[i].name))) {
      gadget = VDCT_FORM_ATTR_L_ATTRS;
      attrFillAttrListRow(nodeID,form,gadget,&row,&flds[i]);
    }
  }

 
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ------------------------------------------
 * update node attributes and children
 */
static IGRstat updateAttributesForNodeAndChildren(TVDct1JD  *nodeJD,
						  IGRchar   *msg)
{
  VDASSERT_FN("updateAttributesForNodeAndChildren");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,rows;
    
  TVDfldS   flds;
  TVDct1JD  childJD;

  Form form   = cmdInfo->attr.form;
  
  TGRid   nodeID;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  nodeID = nodeJD->id;
    
  // Get the active list of attributes
  VDctxGetAttrs(&nodeID,&flds.cnt,flds.fld);

  // Get the number of rows
  VDfrmGetNumRows(form,VDCT_FORM_ATTR_L_ATTRS,&rows,NULL,NULL);

  // read the attributes
  for(i = 0; i < rows; i++) {
    sts = attrReadAttrRow(nodeJD,form,VDCT_FORM_ATTR_L_ATTRS,i,flds.cnt,flds.fld,msg);
    if (!(sts & 1)) goto wrapup;
    
  }  
  
  // Now update the node itself
  VDctxUpdAttrs(&nodeID,flds.cnt,flds.fld);

  // update the active node attributes
  _RTCJDC(nodeJD)->updateNodeAttributes(nodeJD);

#if 0
  // now do the children
  for (i = 0;
       _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD);
       i++) {
    updateAttributesForNodeAndChildren(&childJD);
  }
#endif

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* -------------------------------------------
 * Updates all the attributes in the node
 */
static IGRstat attrNotifyUpdateNode()
{
  VDASSERT_FN("attrNotifyUpdateNode");
  
  IGRstat         retFlag = 0;
  TGRid           parentID;
  TVDctBaseInfo   baseInfo;
  Form            form   = cmdInfo->attr.form;
  IGRint          gadget;
  IGRint          i,rows, sts;
  IGRchar         buf[128],msg[128];
  TVDfld          frozenFld;
  
  IGRint          review;
    
  TVDct1JD        activeNodeJD;
  TVDct1JD        parentJD;
  
  VDASSERTW(activeNodeID.objid != NULL_OBJID);

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init 
  *msg = 0;
  
  // if form is set to review, then do nothing
  VDfrmGetState(form,VDCT_FORM_ATTR_T_UPDATE,&review);
  if (review) {
    strcpy(msg,"Review Only, Attributes not Updated");
    goto wrapup;
  }
    
  // if the node if frozen, do nothing
  VDctxGetAttr(&activeNodeID,VDCT1_ATTR_FROZEN,&frozenFld);
  strcpy(buf,frozenFld.val.txt);
  
  if (!strcmp(buf,"FROZEN")) {
    strcpy(msg,"Update Invalid: Node is Frozen");
    goto wrapup;
    
  }
  

  // update the attributes for the node and children
  activeNodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (activeNodeJD.cl == NULL) goto wrapup;
  activeNodeJD.id = activeNodeID;
  
  sts = updateAttributesForNodeAndChildren(&activeNodeJD,msg);
  if (!(sts & 1)) {
    
    goto wrapup;
  }
  
#if 0
  // Need current parent
  activeNodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  activeNodeJD.id = activeNodeID;
  _RTCJDB(&activeNodeJD)->getTreeParent(&activeNodeJD,&parentJD);
  parentID = parentJD.id;

  if (parentID.objid == NULL_OBJID) {
    VDfrmSetSts(form,"Active node has no parent to update");
    cmdInfo->mgr.activateNode(&activeNodeID);
    retFlag = 1;
    goto wrapup;
  }
  // update the parent node attribute sums
  VDct1SummaryNode(&parentID);
  VDfrmSetSts(form,"Active node and parent nodes updated");

#endif
  
  cmdInfo->mgr.activateNode(&activeNodeID);
 
  // Done
  if (*msg == 0) strcpy(msg,"Node Updated.");
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);

  VDfrmSetSts(form,msg);

  return retFlag;
}

/* -------------------------------------------
 * Doit was pressed
 */
static IGRstat attrNotifyDoit()
{
  VDASSERT_FN("attrNotifyDoit");
  
  IGRstat retFlag = 0;
  IGRchar buf[128];
  IGRchar cmd;
 
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
 
  // Get the command
  VDfrmGetgText(cmdInfo->attr.form,VDCT_FORM_ATTR_G_DOIT,buf);
  cmd = *buf;
     
  // Process it
  switch(cmd) {

  case '1':
    retFlag = attrNotifyUpdateNode();
    break;

  case 'p':
  case 'P':
    retFlag = attrNotifyPaste(cmd);
    break;
    
  }
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Called when a node is activated
 */
static IGRstat activateNode(TGRid *nodeID)
{  
  VDASSERT_FN("activateNode");
  
  IGRstat       retFlag = 0;

  Form form = cmdInfo->attr.form;
  
  TVDct1JD nodeJD;
  TVDfldS flds;
  TVDctBaseInfo baseInfo;

  IGRint review,state;

  VDASSERTW(nodeID);

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // set up form display, based on update/review toggle
  VDfrmGetState(form,VDCT_FORM_ATTR_T_UPDATE,&review);

  if (review) {
    VDfrmSetMode(form,VDCT_FORM_ATTR_L_ATTRS,VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,FI_REVIEW);
  }
  else {
    VDfrmSetMode(form,VDCT_FORM_ATTR_L_ATTRS,VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,FI_INSERT);
  }

  // Set up active
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (nodeJD.cl) {
    nodeJD.id = *nodeID;
    _RTCJDB(&nodeJD)->getBaseInfo(&nodeJD,&baseInfo);
  }
  else memset(&baseInfo,0,sizeof(TVDctBaseInfo));
  
  activeNodeID = *nodeID;

  VDfrmSetgText(form,VDCT_FORM_ATTR_G_ACTIVE_NODE,baseInfo.baseName);

  // And the locked if not locked
  VDfrmGetState(form,VDCT_FORM_ATTR_T_LOCKED_NODE,&state);
  
  if ((state == 0) || (nodeID->objid == NULL_OBJID)) {
    
    lockedNodeID = *nodeID;
    VDfrmSetgText(form,VDCT_FORM_ATTR_G_LOCKED_NODE,baseInfo.baseName);
    
    // Grab the attributes
    VDctxGetAttrs(nodeID,&flds.cnt,flds.fld);
    
    // Fill the gadget
    attrFillAttrList(nodeID,form,VDCT_FORM_ATTR_L_ATTRS,flds.cnt,flds.fld);
    
    VDfrmSetSts(form,"Select an Active Node.");
      
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
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
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->attr;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Process It
  switch(cmdInfo->gadget) {

  case VDCT_FORM_ATTR_T_UPDATE:
    activateNode(&activeNodeID);
    break;
    
  case FI_EXECUTE:
    sts = attrNotifyDoit();
    break;
    
  case FI_ACCEPT:
    sts = attrNotifyDoit();
    if (sts & 1) {
      VDfrmDisplayForm(cmdInfo->attr.form,0,&cmdInfo->attr.displayed);
    }
    break;
    
  case FI_CANCEL:
    VDfrmDisplayForm(cmdInfo->attr.form,0,&cmdInfo->attr.displayed);
    break;
    
  }
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }
  return retFlag;
}


/* -------------------------------------------
 * Called to activate the form
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");
  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->attr;
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);
     
wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitAttrCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitAttrCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Say Hi
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_ATTR);

  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;
 
  activeNodeID.objid = NULL_OBJID;
  lockedNodeID.objid = NULL_OBJID;
  
  // Default init
  formInfo = &cmdInfo->attr;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_ATTR_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->notifyForm   = notifyForm;  
  formInfo->activateForm = activateForm;

  formInfo->activateNode = activateNode;

  formInfo->deletedTree  = deletedTree; 
  //  formInfo->renamedTree  = renamedTree;
  
  formInfo->deletedNode  = deletedNode; 
  formInfo->renamedNode  = renamedNode; 
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
