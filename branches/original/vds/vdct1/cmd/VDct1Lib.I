/* $Id: VDct1Lib.I,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1Lib.I
 *
 * Description: Tree Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Lib.I,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.10  2000/07/20  13:07:14  pinnacle
# ah
#
# Revision 1.9  2000/07/17  19:50:06  pinnacle
# ah
#
# Revision 1.8  2000/07/06  16:11:14  pinnacle
# ah
#
# Revision 1.7  2000/06/30  18:55:30  pinnacle
# pn
#
# Revision 1.6  2000/06/02  15:02:14  pinnacle
# ah
#
# Revision 1.5  2000/05/31  13:37:36  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Lib.I for:  by pnoel for Service Pack
#
# Revision 1.4  2000/05/26  11:34:38  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Lib.I for:  by pnoel for Service Pack
#
# Revision 1.3  2000/05/23  18:29:34  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Lib.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/04/27  14:56:22  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Lib.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:35:44  pinnacle
# Created: vds/vdct1/cmd/VDct1Lib.I by pnoel for Service Pack
#
# Revision 1.4  2000/03/10  21:59:34  pinnacle
# (No comment)
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
 * 06/17/99  ah      creation
 * 05/23/00  pn      some improvements
 * 05/31/00  pn      installed view controls
 * 07/06/00  ah      xml now drops the [] from object names
 ***************************************************************************/
class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDxml.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Xml.h"
#include "VDct1Tree.h"

#include "VDct1Forms.h"
#include "VDct1Cmd.h"
#include "VDct1CmdTree.h"

static int traceFlag;
static TVDct1CmdInfo *cmdInfo;
static int clipBoardCount;
static TGRid activeNodeID;

static TGRid clipBoardNodeID[500];
static TGRid pasteNodeID;


IGRstat VDct1CmdLibFillTreeListForOS(TVDosnum osnum);
IGRstat VDct1CmdLibFillTreeList();
IGRstat VDct1CmdLibNotifyWriteToTextFile(IGRint type);
IGRstat VDct1CmdLibNotifyStandardParts();

/* -------------------------------------------
 * Expose the standard parts in the type4 table
 * to the user
 */
IGRstat VDct1CmdLibNotifyStandardParts()
{
  IGRstat retFlag = 0;
  
  // Create Transient Standard Library
  VDct1CreateStandardLibrary();

  // Refresh the form
  VDct1CmdLibFillTreeList();

  // Done
  retFlag = 1;
  
//wrapup:
  return retFlag;
}
/* ------------------------------------------
 *  Clears Clipboard of nodes to copy
 */
IGRstat VDct1CmdLibClearClip()
{
  IGRstat retFlag = 0;
  IGRint  i, rows;
  IGRchar buf[128];
  
  // start at the top
  clipBoardCount = 0;
  for(i = 0; i <= 500;i++){
    clipBoardNodeID[i].objid = NULL_OBJID;
    clipBoardNodeID[i].osnum = NULL;
  }

 // get the number of rows
  vdfrm$GetText(form   = cmdInfo->lib.form,
		gadget = VDCT_FORM_LIB_G_TREE, 
		row    = 0, 
		col    = 4, 
		rows   = &rows);
  // turn off the hilight
  for (i = 0; i < rows; i++) {

    FImcf_set_select(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE, i, FALSE );
  }

  strcpy(buf,"Buffer Cleared");
  vdfrm$SetStatus(form   = cmdInfo->lib.form,
		  gadget = 10,
		  txt    = buf);

  retFlag = 1;
  
  return retFlag;
}

/* -------------------------------------------
 * Expose the pasted objects to the world xxx
 */
IGRstat VDct1CmdLibGetCopiedNodes(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRint  i = 0;
  IGRchar buf[128];
  TGRid testID;

  // Arg check
  if (nodeID == NULL) goto wrapup;
  if (clipBoardNodeID[0].objid == NULL_OBJID) goto wrapup;
  
  // Copy It
  // nodeID = clipBoardNodeID;
  for (i = 0;i <= 500;i++)
    {
  nodeID[i] = clipBoardNodeID[i];
      testID = nodeID[i];
      if (testID.objid == 0) i = 501; 
    }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* -------------------------------------------
 * Expose the pasted objects to the world xxx
 */
IGRstat VDct1CmdLibGetCopiedNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;

  // Arg check
  if (nodeID == NULL) goto wrapup;

  // Copy It
   *nodeID = clipBoardNodeID[clipBoardCount];// getting the last pasted node on list.
   // *nodeID = pastNodeID;  

   // just in case
   if (nodeID->objid == 0)  nodeID->objid = NULL_OBJID;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write xml file
 */
IGRstat VDct1CmdLibNotifyWriteToTextFile(IGRint type)
{
  IGRstat retFlag = 0;
  
  Form form = cmdInfo->lib.form;

  IGRchar msg[256];
  
  TVDct1JD nodeJD;
  
  // Tree interface
  nodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (nodeJD.cl == NULL) {
    vdfrm$SetStatus(form = form,
		    txt  = "Pick a node before writing");

    goto wrapup;
  }
  nodeJD.id = activeNodeID;
  
  // Doit
  *msg = 0;
  switch(type) {

  case 0: 
    _RTCJDX(&nodeJD)->writeFile(&nodeJD,NULL,msg);
    break;

  case 1:
    _RTCJDX(&nodeJD)->writeSchemaFile(&nodeJD,NULL,msg);
    break;
  }
  
  vdfrm$SetStatus(form = form, txt = msg);
  
  // Done
  retFlag = 1;
  
wrapup:
  
  return retFlag;
}


/* -------------------------------------------
 * Copy the active library id into a buffer
 */
IGRstat VDct1CmdLibPasteCopyIntoBuffer(TGRid *pasteID)
{
  IGRstat        retFlag = 0;
  IGRint         i, j, k, rows;
  IGRint         clip = 0;
  TGRid          testID;
  TGRid          newParentID;
  TGRid          workID, objID;
  TVDctBaseInfo  baseInfo;
  IGRchar        buf[128];

  // args check
  if (pasteID == 0) goto wrapup;  

  // Transfer id
  pasteNodeID = *pasteID;
  // args check
  if (pasteNodeID.objid == NULL_OBJID) goto wrapup;
  
  // prevent duplicates
  for (i = 0;i <= clipBoardCount;i++){
    testID = clipBoardNodeID[i];
    // no duplicates
    if ((testID.osnum == pasteNodeID.osnum) && (testID.objid == pasteNodeID.objid)){
      clip = 1;
      i= clipBoardCount + 1;  // turn off this paste and the loop

    }
    // no parents already!
    workID = pasteNodeID;
    while (vdct1$GetTree1Parent(objID = &workID, outID = &newParentID)) {
      if ((testID.osnum == newParentID.osnum) && (testID.objid == newParentID.objid)){
      clip = 1;
      i= clipBoardCount + 1;  // turn off this paste and the loop

      } 
      workID = newParentID;
    }  

  }
  // yank out any kids 
  // if we passed the tests above
  if(!clip) {
    // load up
    testID = pasteNodeID;
    for (j = 0; j <= clipBoardCount;j++){
      workID = clipBoardNodeID[j];
      while(vdct1$GetTree1Parent(objID = &workID, outID = &newParentID)) {

	if ((testID.osnum == newParentID.osnum) && (testID.objid == newParentID.objid)){

	  for (k = j;k <= clipBoardCount; k++){
	      clipBoardNodeID[k] = clipBoardNodeID[k+1];
	  }
	  clipBoardCount--;
	  j--;
	}
	workID = newParentID;
      }
    }
  }
  
 
  
  if (!clip){
   clipBoardNodeID[clipBoardCount] = pasteNodeID;
  // set to the next available array location
   clipBoardCount++;
  }

  // Update status
  vdct1$GetBaseInfo(objID    = &pasteNodeID,
		    baseInfo = &baseInfo);

  sprintf(buf,"BUF: %s %s %s %s",
	  baseInfo.setType,
	  baseInfo.setName,
	  baseInfo.nodeType,
	  baseInfo.nodeName);


  vdfrm$SetStatus(form   = cmdInfo->lib.form,
		  gadget = 10,
		  txt    = buf);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* -------------------------------------------
 * Copy the active library id into a buffer controller
 */
IGRstat VDct1CmdLibNotifyCopyIntoBuffer()
{  

  IGRstat     retFlag   = 0;
  IGRstat     traceFlag = 0;
  IGRstat     sts       = 0;
  IGRint      len, sel, rows, i;
  TGRid       objID;
  
  //cycle through the form
 // get the number of rows
  vdfrm$GetText(form   = cmdInfo->lib.form,
		gadget = VDCT_FORM_LIB_G_TREE, 
		row    = 0, 
		col    = 4, 
		rows   = &rows);

  for (i = 0;i < rows; i++){
    // get the select status
    vdfrm$GetText(form   = cmdInfo->lib.form,
		  gadget = VDCT_FORM_LIB_G_TREE, 
		  row    = i, 
		  col    = 4, 
		  sel   = &sel);

    if (sel){
      //get the objID if it is selected
      vdfrm$GetText(form    = cmdInfo->lib.form,
		    gadget  = VDCT_FORM_LIB_G_TREE, 
		    row     = i, 
		    col     = 5, 
		    objID   = &objID);

      // feed it to the worksite
      sts = VDct1CmdLibPasteCopyIntoBuffer(&objID);
    }
  }
  

// Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Doit was pressed
 */
IGRstat VDct1CmdLibNotifyDoit()
{
  IGRstat retFlag = 0;
  IGRchar buf[128];
  IGRchar cmd;
  
  // Get the command
  vdfrm$GetText(form   = cmdInfo->lib.form,
		gadget = VDCT_FORM_LIB_G_DOIT,
		txt    = buf);
  cmd = *buf;
  
  // Process it
  switch(cmd) {

  case '1':
    retFlag = VDct1CmdLibNotifyCopyIntoBuffer();
    break;

  case '2':
    retFlag = VDct1CmdLibClearClip();
    break;

  case '3':
    // Xml file
    retFlag = VDct1CmdLibNotifyWriteToTextFile(0);
    break;

  case '4':
    // Xml schema file
    retFlag = VDct1CmdLibNotifyWriteToTextFile(1);
    break;
      
  }
  
//wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Tree notification routine
 */
IGRstat VDct1CmdLibNotifyTree()
{
  IGRstat retFlag = 0;
  TGRid   nodeID;

  // Standard tree handler
  VDct1FormNotifyTree(cmdInfo->lib.form,VDCT_FORM_LIB_G_TREE,&nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;
  
  // Save It
  activeNodeID = nodeID;

  // Direct call to update ops form
  VDct1CmdPartActivateNode(&nodeID);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDct1CmdLibNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Process it
  if (traceFlag) printf(">>> VDct1CmdLibNotifyForm\n(%d)",cmdInfo->gadget);
  switch(cmdInfo->gadget) {
    
  case VDCT_FORM_LIB_G_TREE:
    VDct1CmdLibNotifyTree();
    break;

  case VDCT_FORM_LIB_G_DISPLAY:
    VDct1CmdLibFillTreeList();
    break;

  case VDCT_FORM_LIB_B_CLEAR:
    retFlag = VDct1CmdLibClearClip();
    break;

  case VDCT_FORM_LIB_B_COPY:
    retFlag = VDct1CmdLibNotifyCopyIntoBuffer();
    break;    

  case VDCT_FORM_LIB_B_WRITE:
    retFlag = VDct1CmdLibNotifyWriteToTextFile(0);
    break;

  case FI_EXECUTE:
    sts = VDct1CmdLibNotifyDoit();
    break;
    
  case FI_ACCEPT:
    sts = VDct1CmdLibNotifyDoit();
    if (sts & 1) {
      vdfrm$EraseForm(form =  cmdInfo->lib.form, 
		      flag = &cmdInfo->lib.displayed);

    }
    break;

  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->lib.form, 
                    flag = &cmdInfo->lib.displayed);
    break;
  }
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdLibNotifyForm\n");
  return retFlag;
}

/* --------------------------------------
 * Fill in the list of trees for the osnum
 */
IGRstat VDct1CmdLibFillTreeListForOS(TVDosnum osnum)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid  mgrID;
  TGRid  setID;

  IGRint  i;

  // Validate os
  sts = vdos$Validate(osnum = osnum);
  if (!(sts & 1)) goto wrapup;
  retFlag = 1;

  // Get the manager
  vdct1$GetManager(osnum = osnum, mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  for(i = 0; vdct$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {

    VDct1FormAppendTree(cmdInfo->lib.form,VDCT_FORM_LIB_G_TREE,&setID);
    
  }
  
wrapup:
  return retFlag;
}

/* --------------------------------------
 * Fills in the list of available trees
 */
IGRstat VDct1CmdLibFillTreeList()
{
  IGRstat retFlag = 0;
  Form    form    = cmdInfo->lib.form;
  IGRint  gadget  = VDCT_FORM_LIB_G_TREE;
  
  VDosnum osnum;
  
  // This resets the tree form
  VDct1FormAppendTree(form,gadget,NULL);

  // Show all trees
  for(osnum = 0;
      VDct1CmdLibFillTreeListForOS(osnum);
      osnum++);
  
  // Done
  retFlag = 1;
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDct1CmdLibActivateForm()
{
  IGRstat retFlag = 1;

  // Ignore if already active for now
  if (cmdInfo->lib.displayed) {
    retFlag = 1;
    goto wrapup;
  }
  if (traceFlag) printf(">>> VDct1CmdLibActivateForm\n");

  // Display
  vdfrm$DisplayForm(form =  cmdInfo->lib.form, 
                    flag = &cmdInfo->lib.displayed);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdLibActivateForm\n");
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDct1CmdLibInit(TVDct1CmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;
  IGRchar buf[128];
  IGRstat sts;

  traceFlag = 0;
  if (traceFlag) printf(">>> VDct1CmdLibInit\n");
  
  cmdInfo = a_cmdInfo;

   pasteNodeID.objid = NULL_OBJID;
  activeNodeID.objid = NULL_OBJID;
  
  VDct1CmdLibFillTreeList();
  // clear the clipboard when we startup
  sts = VDct1CmdLibClearClip();
  retFlag = 1;

  if (traceFlag) printf("<<< VDct1CmdLibInit\n");
  return retFlag;
}

/* -------------------------------------------------------
 * Standard Event Handling
 */
#argsused
IGRstat VDct1CmdLibCreatedTree(TGRid *treeID)
{  
  VDct1CmdLibFillTreeList();

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  
  return 1;
}
#argsused
IGRstat VDct1CmdLibDeletedTree(TGRid *treeID)
{  
  VDct1CmdLibFillTreeList();

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);  

  return 1;
}
#argsused
IGRstat VDct1CmdLibRenamedTree(TGRid *treeID)
{  
  VDct1CmdLibFillTreeList();
  return 1;
}
IGRstat VDct1CmdLibCreatedNode(TGRid *nodeID)
{
  TGRid parentID;
  
  vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);
  
  VDct1FormUpdateTreeRow(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE, &parentID);

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);  

  return 1;
}
IGRstat VDct1CmdLibDeletedNode(TGRid *nodeID, TGRid *parentID)
{  
  // Delete the row
  VDct1FormDeleteTreeRowID(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE, nodeID);

  // Refresh the parent
  VDct1FormUpdateTreeRow(cmdInfo->lib.form,   VDCT_FORM_LIB_G_TREE, parentID);

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE); 
 
  return 1;
}
#argsused
IGRstat VDct1CmdLibRenamedNode(TGRid *nodeID)
{ 
  IGRstat    retFlag   = 0;
  IGRstat    traceFlag = 0;
  
  IGRint row;
  if (traceFlag) printf(">>> VDct1CmdLibRenamedNode\n");
    
  
  VDct1FormFindTreeRow(cmdInfo->lib.form,
		       VDCT_FORM_LIB_G_TREE,
		       nodeID,
		       &row);
  if (row < 0) goto wrapup;
  
  VDct1FormRefreshNodeName(cmdInfo->lib.form, 
			   VDCT_FORM_LIB_G_TREE, 
			   row, 
			   nodeID);
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1CmdLibRenamedNode %d\n",retFlag);
  return retFlag;  
}
#argsused
IGRstat VDct1CmdLibActivateNode(TGRid *nodeID)
{  
  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);  
  return 1;
}

end implementation VDct1Base;
