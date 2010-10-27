/* $Id: VDct1Attr.I,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1Attr.I
 *
 * Description: Attribute Manupilation Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Attr.I,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.6  2000/07/20  20:15:06  pinnacle
# js
#
# Revision 1.5  2000/05/26  11:34:02  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Attr.I for:  by pnoel for Service Pack
#
# Revision 1.4  2000/05/23  18:29:02  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Attr.I for:  by pnoel for Service Pack
#
# Revision 1.3  2000/05/15  15:19:04  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Attr.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/11  13:20:12  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Attr.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:34:48  pinnacle
# Created: vds/vdct1/cmd/VDct1Attr.I by pnoel for Service Pack
#
# Revision 1.5  2000/03/28  16:08:16  pinnacle
# pn.
#
# Revision 1.4  2000/03/24  20:33:18  pinnacle
# ah
#
# Revision 1.3  2000/01/11  22:28:50  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:29:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/17/99  ah      Creation
 * 03/28/00  pn      Updated to access PPL's and post user data with
 *                   DB lookup in PPL to node
 * 05/11/00  pn      Setup for mgt of altered Attr.form to provide view of
 *                   Attributes while protected  Includes altered header.h in 
 *                   vds/vdct1/ppl/
 * 05/22/00  pn      Updated form access and updates
 ***************************************************************************/

class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Cmd.h"
#include "VDct1Forms.h"

static int traceFlag;
static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;
static TGRid lockedNodeID;


/* -------------------------------------------
 * Updates row by pasting from buffer
 */
IGRstat VDct1CmdAttrPasteAttrRow(Form    form,
				 IGRint  gadget,
				 IGRint  row,
				 IGRint  cnt,
				 TVDfld *flds)
{
  IGRstat retFlag = 0;

  IGRint  i;
  IGRchar buf[256];
  IGRint pGadget = VDCT_FORM_ATTR_L_ATTRS_PVT;
  // Get the name
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_NAME,
                txt    = buf);
  
  // Find it
  for(i = 0; (i < cnt) && (strcmp(buf,flds[i].name)); i++);
  if (i == cnt) goto wrapup;

  // Update the form with any changes
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,
                txt    = flds[i].val.txt);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Paste Attribute Values from buffer
 */
#argsused
IGRstat VDct1CmdAttrNotifyPaste(IGRchar cmd)
{
  IGRstat retFlag = 0;
  
  Form   form   = cmdInfo->attr.form;
  IGRint gadget = VDCT_FORM_ATTR_L_ATTRS;
  IGRint pGadget = VDCT_FORM_ATTR_L_ATTRS_PVT;
  
  IGRint row,rows;
  
  TGRid   copiedNodeID;
  TVDfldS flds;
  
  // This is the list of pased attributes
  VDct1CmdLibGetCopiedNode(&copiedNodeID);
  vdcol$GetAttrs(objID = &copiedNodeID, cnt = &flds.cnt, fld = flds.fld);
    // Cycle through each row pGadget
  vdfrm$GetNumRows(form = form, gadget = pGadget, rows = &rows);
  for(row = 0; row < rows; row++) {
    VDct1CmdAttrPasteAttrRow(form,pGadget,row,flds.cnt,flds.fld);
  } 
  // Cycle through each row gadget
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &rows);
  for(row = 0; row < rows; row++) {
    VDct1CmdAttrPasteAttrRow(form,gadget,row,flds.cnt,flds.fld);
  }

  // Done
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Reads one row from the gadget
 * and updates the list of fields
 */
IGRstat VDct1CmdAttrReadAttrRow(Form    form,
				IGRint  gadget,
				IGRint  row,
				IGRint  cnt,
				TVDfld *flds)
{
  IGRstat retFlag = 0;

  IGRint  i;
  IGRchar buf[256];
  
  // Get the name
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_NAME,
                txt    = buf);
  
  // Find it
  for(i = 0; (i < cnt) && (strcmp(buf,flds[i].name)); i++);
  if (i == cnt) goto wrapup;
  
  // Pull the value
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,
                txt    = buf);

  VDstrupr(buf);

  // Update the form with any changes
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,
                txt    = buf);

  // Store it
  strcpy(flds[i].val.txt,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* ---------------------------------------------------
 * Fill 1 row in the attribute list
 */
IGRstat VDct1CmdAttrFillAttrListRow(TGRid *nodeID, 
				    Form    form, 
				    IGRint  gadget, 
				    IGRint *row, 
				    TVDfld *fld)
{
  IGRstat retFlag = 0;
  IGRchar buf[256];
  
  TVDctAttrInfo attrInfo;
  
  // Arg check
  if (fld == NULL) goto wrapup;
  if (row == NULL) goto wrapup;
  
  // Lookup attribute information
  vdct1$GetAttrInfo(objID    = nodeID,
		    attrName = fld->name,
		    attrInfo = &attrInfo);
  
  // Base
  if (*attrInfo.base) {
    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = *row,
		  col    = VDCT_FORM_ATTR_L_ATTRS_COL_BASE,
		  txt    = attrInfo.base);
  }
  else {  
    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = *row,
		  col    = VDCT_FORM_ATTR_L_ATTRS_COL_BASE,
		  txt    = fld->name);
  }
  
  // Type
  vdfld$GetTypeText(type = fld->type, txt = buf);
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = *row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_TYPE,
		txt    = buf);

  // The value
  // vdfld$Get(fld = fld, txt = buf);
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = *row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,
		txt    = fld->val.txt);

  // Hidden name
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = *row,
		col    = VDCT_FORM_ATTR_L_ATTRS_COL_NAME,
		txt    = fld->name);
   
  // Done
  *row = *row + 1;
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -------------------------------------------
 * Fill the list gadget
 */
IGRstat VDct1CmdAttrFillAttrList(TGRid  *nodeID,
				 Form    form,
				 IGRint  gadget,
				 IGRint  cnt, 
				 TVDfld *flds)
{
  IGRstat retFlag = 0;
  IGRint  i,row, sts;
  IGRint  attrOffset;
  IGRchar buf[128];
  
  // Arg check
  if (flds == NULL) goto wrapup;

  // get the offset
  vdct1$GetAttrOffset(nodeID     = nodeID,
		      attrOffset = &attrOffset);

  // Doit
  vdfrm$SetNumRows(form = form, gadget = gadget, rows = 0);
  row = 0;
  for(i = 0; i < cnt; i++) {
    // reset the row count when switching back to the other gadget
    if (i == attrOffset) row = 0;
    
    // set the gadget to the active set
    gadget = VDCT_FORM_ATTR_L_ATTRS;

    // if below the offset hit the private attributes list gadget
    if (i < attrOffset) gadget = VDCT_FORM_ATTR_L_ATTRS_PVT;
    
    VDct1CmdAttrFillAttrListRow(nodeID,form,gadget,&row,&flds[i]);
  }
  // special case of erasure no attrOffset is there
  if (nodeID->objid == NULL_OBJID){
    gadget = VDCT_FORM_ATTR_L_ATTRS_PVT;
    attrOffset = cnt;
    row = 0;
    // clear them all up no matter what!
    VDct1CmdAttrFillAttrListRow(nodeID,form,gadget,&row,&flds[i]);
  }
  

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Updates all the attributes in the node
 */
IGRstat VDct1CmdAttrNotifyUpdateNode()
{
  IGRstat         retFlag = 0;
  TGRid           parentID;
  TVDctBaseInfo   baseInfo;
  Form            form   = cmdInfo->attr.form;
  IGRint          gadget;
  IGRint          row,rows, sts;
  IGRchar         buf[128];
  TVDfld          frozenFld;
  TVDfldS         flds;
  IGRstat         attrProtect = 1;  // turn on/off update protection if the node is frozen
  
  if (activeNodeID.objid == NULL_OBJID) goto wrapup;

  vdcol$GetAttr(objID = &activeNodeID, name = "frozen", fld = &frozenFld);
  strcpy(buf,frozenFld.val.txt);
  // This is the active list of attributes
  vdcol$GetAttrs(objID = &activeNodeID, cnt = &flds.cnt, fld = flds.fld);
  
  // Cycle through each row for the PVT
  vdfrm$GetNumRows(form = form, gadget = VDCT_FORM_ATTR_L_ATTRS_PVT, rows = &rows);
  
  for(row = 0; row < rows; row++) {
    VDct1CmdAttrReadAttrRow(form,VDCT_FORM_ATTR_L_ATTRS_PVT,row,flds.cnt,flds.fld);
  }
 // Cycle through each row for the regular
  vdfrm$GetNumRows(form = form, gadget = VDCT_FORM_ATTR_L_ATTRS, rows = &rows);
  for(row = 0; row < rows; row++) {
    VDct1CmdAttrReadAttrRow(form,VDCT_FORM_ATTR_L_ATTRS,row,flds.cnt,flds.fld);
  }  
  
  if ((!strcmp(buf,"FROZEN")) && (attrProtect & 1)) {
    VDct1CmdMgrActivateNode(&activeNodeID);
    goto wrapup;
  }
  
  // Now update the node itself
  vdcol$UpdAttrs(objID = &activeNodeID,
		 cnt   = flds.cnt,
		 fld   = flds.fld);

  // Grab the attributes
  vdcol$GetAttrs(objID = &activeNodeID, cnt = &flds.cnt, fld = flds.fld);

  // Fill the gadget
  VDct1CmdAttrFillAttrList(&activeNodeID,form,VDCT_FORM_ATTR_L_ATTRS,flds.cnt,flds.fld);

  // update the active node attributes
  vdct1$UpdateAttributes(nodeID = &activeNodeID);

  // Need current parent
  vdct1$GetTree1Parent(objID = &activeNodeID, outID = &parentID);

  if (parentID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form,
		    txt  = "Active node has no parent to update.");
    VDct1CmdMgrActivateNode(&activeNodeID);

    retFlag = 1;
    goto wrapup;
  }
  // update the parent node attribute sums
  vdct1$SummaryNode (parentID = &parentID);
  vdfrm$SetStatus(form = form,
		  txt  = "Active node and parent nodes updated.");
 
  VDct1CmdMgrActivateNode(&activeNodeID);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -------------------------------------------
 * Doit was pressed
 */
IGRstat VDct1CmdAttrNotifyDoit()
{
  IGRstat retFlag = 0;
  IGRchar buf[128];
  IGRchar cmd;
  
  // Get the command
  vdfrm$GetText(form   = cmdInfo->attr.form,
		gadget = VDCT_FORM_ATTR_G_DOIT,
		txt    = buf);
  cmd = *buf;
  
  // Process it
  switch(cmd) {

  case '1':
    retFlag = VDct1CmdAttrNotifyUpdateNode();
    break;

  case 'p':
  case 'P':
    retFlag = VDct1CmdAttrNotifyPaste(cmd);
    break;
    
  }
//wrapup:
  return retFlag;
}


/* -------------------------------------------
 * Node was activated
 */
IGRstat VDct1CmdAttrActivateNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  Form form = cmdInfo->attr.form;

  TVDfldS flds;
  TVDctBaseInfo baseInfo;

  IGRint state;
  
  // Set up active
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
 
  activeNodeID = *nodeID;
  
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_ATTR_G_ACTIVE_NODE,
		txt    = baseInfo.baseName);

  // And the locked if not locked
  vdfrm$GetState(form   = form,
		 gadget = VDCT_FORM_ATTR_T_LOCKED_NODE,
		 state  = &state);

  if ((state == 0) || (nodeID->objid == NULL_OBJID)) {

    lockedNodeID = *nodeID;
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_ATTR_G_LOCKED_NODE,
		  txt    = baseInfo.baseName);
    
    // Grab the attributes
    vdcol$GetAttrs(objID = nodeID, cnt = &flds.cnt, fld = flds.fld);

    // Fill the gadget
    VDct1CmdAttrFillAttrList(nodeID,form,VDCT_FORM_ATTR_L_ATTRS,flds.cnt,flds.fld);

    vdfrm$SetStatus(form = form,
		  txt  = "Active Node Selected.");
    //if (nodeID->objid == NULL_OBJID) {
      vdfrm$SetStatus(form = form,
		      txt  = "Select an Active Node.");
      // Fill the gadget
      VDct1CmdAttrFillAttrList(nodeID,form,VDCT_FORM_ATTR_L_ATTRS_PVT,flds.cnt,flds.fld);	
      // }
    
  }

  // Done
  retFlag = 1;
  
//wrapup:

  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDct1CmdAttrNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Process it
  if (traceFlag) printf(">>> VDct1CmdAttrNotifyForm\n");
  switch(cmdInfo->gadget) {
    
  case FI_EXECUTE:
    sts = VDct1CmdAttrNotifyDoit();
    break;
    
  case FI_ACCEPT:
    sts = VDct1CmdAttrNotifyDoit();
    if (sts & 1) {
      vdfrm$EraseForm(form =  cmdInfo->attr.form, 
		      flag = &cmdInfo->attr.displayed);
    }
    break;
    
  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->attr.form, 
                    flag = &cmdInfo->attr.displayed);
    break;
  }
  retFlag = 1;

//wrapup:
  if (traceFlag) printf("<<< VDct1CmdAttrNotifyForm\n");
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDct1CmdAttrActivateForm()
{
  IGRstat retFlag = 0;

  // Ignore if already active for now
  if (cmdInfo->attr.displayed) {
    retFlag = 1;
    goto wrapup;
  }
  if (traceFlag) printf(">>> VDct1CmdAttrActivateForm\n");

  // Display
  vdfrm$DisplayForm(form =  cmdInfo->attr.form, 
                    flag = &cmdInfo->attr.displayed);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdAttrActivateForm\n");
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDct1CmdAttrInit(TVDct1CmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;

  traceFlag = 0;
  if (traceFlag) printf(">>> VDct1CmdAttrInit\n");

  cmdInfo = a_cmdInfo;

  activeNodeID.objid = NULL_OBJID;
  lockedNodeID.objid = NULL_OBJID;
  
  retFlag = 1;

  if (traceFlag) printf("<<< VDct1CmdAttrInit\n");
  return retFlag;
}

/* ---------------------------------------------------------
 * Standard event handlers
 */
#argsused
IGRstat VDct1CmdAttrCreatedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdAttrDeletedTree(TGRid *treeID)
{ 
  Form      form = cmdInfo->attr.form;
  TGRid     workID;
  

  
  // notify of deletion on attr.form 
    vdfrm$SetStatus(form   = form,
		    gadget = 10,
		    txt    = "Active Node Deleted.");

    // clear up the attr.form
    VDct1CmdAttrActivateNode(&workID);

  return 1;
}
#argsused
IGRstat VDct1CmdAttrRenamedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdAttrCreatedNode(TGRid *nodeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdAttrDeletedNode(TGRid *nodeID, TGRid *parentID)
{    
  Form        form = cmdInfo->attr.form;
  TGRid       workID;
  
  vdfrm$SetStatus(form   = form,
		  gadget = 10,
		  txt    = "Active Node Deleted.");

  // clear up the attr.form
  VDct1CmdAttrActivateNode(&workID);
  
  ////////////////////////////////////////////////////////////////
  return 1;
}

IGRstat VDct1CmdAttrRenamedNode(TGRid *nodeID)
{ 
  IGRstat retFlag = 0;
  Form form = cmdInfo->attr.form;

  TVDctBaseInfo baseInfo;
  IGRint state; 
  
  // Set up active
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  activeNodeID = *nodeID;
  
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_ATTR_G_ACTIVE_NODE,
		txt    = baseInfo.baseName);

  // And the locked if not locked
  vdfrm$GetState(form   = form,
		 gadget = VDCT_FORM_ATTR_T_LOCKED_NODE,
		 state  = &state);

  if ((state == 0) || (nodeID->objid == NULL_OBJID)) {

    lockedNodeID = *nodeID;

    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_ATTR_G_LOCKED_NODE,
		  txt    = baseInfo.baseName);
  }

  // Done
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

end implementation VDct1Base;






