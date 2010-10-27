/* $Id: VDct1Lib.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/Vct1Lib.C
 *
 * Description: Library Forms Manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Lib.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.7  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.6  2000/08/25  19:59:44  pinnacle
 * ah
 *
 * Revision 1.5  2000/08/18  17:29:14  pinnacle
 * js
 *
 * Revision 1.4  2000/08/17  11:31:40  pinnacle
 * js
 *
 * Revision 1.3  2000/08/15  15:04:10  pinnacle
 * js
 *
 * Revision 1.2  2000/08/08  16:35:14  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/04  19:28:24  pinnacle
 * Created: vds/vdct1/cmd2/VDct1Lib.C by jdsauby for Service Pack
 *
 * Revision 1.1  2000/07/27  15:13:14  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDris2.h"
#include "VDvla2.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Part.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd/VDct1Lib.C");

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */
static TVDct1CmdInfo *cmdInfo;
static TGRid activeNodeID;

//static IGRint   clipBoardCount;
static TVDvlaid clipBoardVLAID;
static TGRid    pasteNodeID;


/* ------------------------------------------
 *  Clears Clipboard of nodes to copy
 */
static IGRstat notifyClearClip()
{
  VDASSERT_FN("notifyClearClip");
  
  IGRstat retFlag = 0;
  IGRint  i, rows;
  IGRchar buf[128];
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  

  // Empty the clipBoardNodeID
  VDvlaidEmpty(&clipBoardVLAID);
 
  // get the number of rows
  VDfrmGetNumRows(cmdInfo->lib.form,VDCT_FORM_LIB_G_TREE,&rows,NULL,NULL);

  // turn off the hilight
  for (i = 0; i < rows; i++) {
    FImcf_set_select(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE, i, FALSE );
  }

  strcpy(buf,"Buffer Cleared");
  VDfrmSetSts(cmdInfo->lib.form,buf);

  // Done
  retFlag = 1;
  goto wrapup;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * Expose the last pasted objects to the world xxx
 */
IGRstat VDct1GetLastIDFromVLAID(TGRid *nodeID)
{
  VDASSERT_FN("VDct1LastIDFromVLAID");
  
  IGRstat retFlag = 0;
  IGRint  cnt;
  
  // Arg check
  VDASSERTW(nodeID);
    
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Do it
  VDvlaidGetCnt(&clipBoardVLAID,&cnt);
  
  // FIXME: This should always fail, should be cnt - 1
  VDvlaidGetNth(&clipBoardVLAID,cnt,nodeID,NULL);
    
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -------------------------------------------
 * Expose the pasted objects to the world xxx
 */
IGRstat VDct1GetNthIDFromVLAID(IGRint nth, TGRid *nodeID)
{
  VDASSERT_FN("VDct1GetNthIDFromVLAID");
  
  IGRstat retFlag = 0;
    
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Do it
  retFlag = VDvlaidGetNth(&clipBoardVLAID,nth,nodeID,NULL);
    
  // Done
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Write xml file
 */
static IGRstat notifyWriteToTextFile(IGRint type)
{
  VDASSERT_FN("notifyWriteToTextFile");
    
  IGRstat retFlag = 0;
  
  Form form = cmdInfo->lib.form;

  IGRchar msg[256];
  
  TVDct1JD nodeJD;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Tree interface
  nodeJD.cl = VDct1GetTreeClassForNode(&activeNodeID);
  if (nodeJD.cl == NULL) {
    VDfrmSetSts(form,"Pick a node before writing");
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
  
  VDfrmSetSts(form,msg);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* --------------------------------------------
 * delete the nth ID from buffer, and decrement
 * vla.cnt as required
 */
static IGRstat deletNthIDFromVLAID(nth)
{
  VDASSERT_FN("deletNthIDFromVLAID");
  
  IGRstat retFlag = 0;
  TGRid   *vlaID;
  TGRid   plusOneVlaID;
  IGRint  i, plusOne;
  
  
  //VDASSERTW(nth);
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Do it FIXME: Does this really work?
  for (i = nth; i < clipBoardVLAID.vla.cnt ; i++) {
    plusOne = i + 1;
    VDvlaidGetNth(&clipBoardVLAID,i,NULL,&vlaID);
    VDvlaidGetNth(&clipBoardVLAID,plusOne,&plusOneVlaID,NULL);
    *vlaID = plusOneVlaID;
  }
  clipBoardVLAID.vla.cnt--;
  
  // Done
  retFlag = 1;
    
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Determine if current pasteJD has a child already
 * in buffer
 * O - 0 if child is not in buffer
 * O - 1 if child is in buffer
 */
static IGRstat isChildInVLAID(TVDct1JD  *pasteJD)
{
  VDASSERT_FN("isChildInVLAID");
  
  IGRstat  retFlag = 0;
  TVDct1JD testJD;
  TVDct1JD parentJD;
  
  IGRint i,cnt;
  
  VDASSERTW(pasteJD);
  //VDASSERTW(nth != NULL);
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Get it
  testJD.cl = pasteJD->cl;
  VDvlaidGetCnt(&clipBoardVLAID,&cnt);
  
  for(i = 0; i < cnt; i++){
    
    VDvlaidGetNth(&clipBoardVLAID,i,&testJD.id,NULL);

    // Is it the parent
    while ( _RTCJDB(&testJD)->getTreeParent(&testJD,&parentJD) ) {
      
      if ( (parentJD.id.osnum == pasteJD->id.osnum) && 
	   (parentJD.id.objid == pasteJD->id.objid) ) {
	
	deletNthIDFromVLAID(i);
	retFlag = 1;
	goto wrapup; 
      } 
      testJD = parentJD;
      
    }  // end of while
  
  } // end of for-loop
  
  // done
  goto wrapup;
    
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
  
}


/* -------------------------------------------
 * Copy the active library id into a buffer
 */
static IGRstat copyIntoBuffer(TGRid *pasteID)
{
  VDASSERT_FN("copyIntoBuffer");
  
  IGRstat        retFlag = 0;
  IGRint         i, cnt, rows;
  TGRid          testID,swapID;
  TVDct1JD       newParentJD;
  TVDct1JD       workJD;
  TVDct1JD       pasteJD;
  TVDctBaseInfo  baseInfo;
  IGRchar        buf[128];

  // args check
  VDASSERTW(pasteID);
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  

  // Transfer id
  pasteJD.cl = VDct1GetTreeClassForNode(pasteID); 
  if (pasteJD.cl == NULL) goto wrapup;

  pasteJD.id = *pasteID;
  if (pasteJD.id.objid == NULL_OBJID) goto wrapup;
  
  // Cycle through current buffer
  VDvlaidGetCnt(&clipBoardVLAID,&cnt);
  for (i = 0; i < cnt ; i++) {

    VDvlaidGetNth(&clipBoardVLAID,i,&testID,NULL);   
    
    // If it already exists in buffer, don't put it in again
    if ( (testID.osnum == pasteJD.id.osnum) && (testID.objid == pasteJD.id.objid) ) {
      goto wrapup; 
    }
    
    // If any of its parents exist, don't put it in the buffer
    workJD = pasteJD; 
    while (_RTCJDB(&workJD)->getTreeParent(&workJD,&newParentJD)) {
      
      if ( (testID.osnum == newParentJD.id.osnum) && (testID.objid == newParentJD.id.objid) ) {
	goto wrapup;
      } 
      workJD = newParentJD;
    }  
    
  }  // end of for loop
  
  // Make sure no children are already in buffer
  // and if so, take them out. 
  while (isChildInVLAID(&pasteJD));

  
  // Children are cleaned out from VLAID,  now append to VLAID
  VDvlaidAppend(&clipBoardVLAID,pasteID);
  if (traceFlag) printf("###Final clipboard.vla.cnt = %d\n",clipBoardVLAID.vla.cnt);

  // Update status
  _RTCJDB(&pasteJD)->getBaseInfo(&pasteJD,&baseInfo);
  
  sprintf(buf,"BUF: %s %s %s %s",
	  baseInfo.setType,
	  baseInfo.setName,
	  baseInfo.nodeType,
	  baseInfo.nodeName);
    
  VDfrmSetSts(cmdInfo->lib.form,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}
/* -------------------------------------------
 * Copy the active library id into a buffer controller
 */
static IGRstat notifyCopyIntoBuffer()
{  

  IGRstat     retFlag   = 0;
  IGRstat     sts       = 0;
  IGRint      len, sel, rows, i;
  TGRid       objID;
  
  //cycle through the form
  // get the number of rows
  VDfrmGetNumRows(cmdInfo->lib.form,VDCT_FORM_LIB_G_TREE,&rows,NULL,NULL);

  for (i = 0;i < rows; i++){

    // get the select status
    VDfrmGetSelect(cmdInfo->lib.form,VDCT_FORM_LIB_G_TREE,i,4,&sel);

    if (sel){

      //get the objID if it is selected
      VDfrmGetfID(cmdInfo->lib.form,VDCT_FORM_LIB_G_TREE,i,5,&objID);

      // feed it to the worksite
      sts = copyIntoBuffer(&objID);
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
static IGRstat notifyDoit()
{
  VDASSERT_FN("notifyDoit");
  
  IGRstat retFlag = 0;
  IGRchar buf[128];
  IGRchar cmd;
  

  // Get the command
  VDfrmGetgText(cmdInfo->lib.form,VDCT_FORM_LIB_G_DOIT,buf);
  cmd = *buf;

  // Say hi
  if (traceFlag) printf(">>> %s %s %c\n",ffn(),fn,cmd);
  
  
  // Process it
  switch(cmd) {

  case '1':
    retFlag = notifyCopyIntoBuffer();
    break;

  case '2':
    retFlag = notifyClearClip();
    break;

  case '3':
    // Xml file
    retFlag = notifyWriteToTextFile(0);
    break;

  case '4':
    // Xml schema file
    retFlag = notifyWriteToTextFile(1);
    break;
      
  }
  
wrapup:
  if (traceFlag) ("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* --------------------------------------
 * Fill in the list of trees for the osnum
 * returns 0 when os is invalid
 */
static IGRstat fillTreeListForOS(TVDosnum osnum)
{
  VDASSERT_FN("fillTreeListForOS");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD mgrJD;
  TVDct1JD setJD;
  
  IGRint  i;

  Form   form   = cmdInfo->lib.form;
  IGRint gadget = VDCT_FORM_LIB_G_TREE;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,osnum);
  }
  
  // Validate os
  sts = VDosValidate(osnum);
  if (!(sts & 1)) goto wrapup;
  retFlag = 1;

  // Get the manager
  mgrJD.cl = VDct1GetRootTreeClass(); VDASSERTW(mgrJD.cl);
  mgrJD.id.osnum = osnum;
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  if (mgrJD.id.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  for(i = 0; _RTCJDB(&mgrJD)->getMgrChild(&mgrJD,i,&setJD); i++) {

    VDct1FormAppendTree(form,gadget,&setJD.id);
    
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
  VDASSERT_FN("fillTreeList");
  
  IGRstat retFlag = 0;
  
  Form    form   = cmdInfo->lib.form;
  IGRint  gadget = VDCT_FORM_LIB_G_TREE;
  
  VDosnum osnum;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // This resets the tree form
  VDct1FormAppendTree(form,gadget,NULL);

  // Cycle through all osnums
  for(osnum = 0; fillTreeListForOS(osnum); osnum++);
  
  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag); 
  return retFlag;
}

/* -------------------------------------------
 * Expose the standard parts in the type4 table
 * to the user
 */
static IGRstat notifyStandardParts()
{
  IGRstat retFlag = 0;
  
  // Create Transient Standard Library
  VDct1CreateStandardLibrary();

  // Refresh the form
  fillTreeList();

  // Done
  retFlag = 1;
  
//wrapup:
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
  
  Form   form   = cmdInfo->lib.form;
  IGRint gadget = VDCT_FORM_LIB_G_TREE;
    
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Standard tree handler
  VDct1FormNotifyTree(form,gadget,&nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;
    
  // Activate It
  cmdInfo->mgr.activateNode(&nodeID);
 
  // update everybody on the form
  //if (traceFlag) printf("going to the new update of all rows\n");
  //VDct1FormUpdateVRTree(form,gadget);
    
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
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->lib;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Process It
  switch(cmdInfo->gadget) {

  case VDCT_FORM_LIB_G_TREE:
    notifyTreeGadget();
    break;
    
  case VDCT_FORM_LIB_G_DISPLAY:
    fillTreeList();
    break;

  case VDCT_FORM_LIB_B_CLEAR:
    retFlag = notifyClearClip();
    break;

  case VDCT_FORM_LIB_B_COPY:
    retFlag = notifyCopyIntoBuffer();
    break;    

  case VDCT_FORM_LIB_B_WRITE:
    retFlag = notifyWriteToTextFile(0);
    break;

  case FI_EXECUTE:
    sts = notifyDoit();
    break;
    
  case FI_ACCEPT:
    sts = notifyDoit();
    if (sts & 1) {
      VDfrmDisplayForm(cmdInfo->lib.form,0,&cmdInfo->lib.displayed);
    }
    break;

  case FI_CANCEL:
    VDfrmDisplayForm(cmdInfo->lib.form,0,&cmdInfo->lib.displayed);
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

  Form form = cmdInfo->lib.form;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // args check
  VDASSERTW(nodeID);
  
  // Find it
  VDct1FormFindTreeRow(form,VDCT_FORM_LIB_G_TREE,nodeID,&row);
  if (row < 0) goto wrapup;
  
  // Refresh it
  VDct1FormRefreshNodeName(form,VDCT_FORM_LIB_G_TREE,row,nodeID);

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
  
  Form form = cmdInfo->lib.form;
  
  // Arg check
  VDASSERTW(nodeID);
  VDASSERTW(parentID);
  
  // Delete the row
  VDct1FormDeleteTreeRowID(form, VDCT_FORM_LIB_G_TREE, nodeID);

  // Refresh the parent
  VDct1FormUpdateTreeRow(form, VDCT_FORM_LIB_G_TREE, parentID);

  // update the summary
  // VDct1FormUpdateVRTree(form, VDCT_FORM_LIB_G_TREE);

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
  
  Form  form = cmdInfo->lib.form;
  
  TVDct1JD nodeJD;
  TVDct1JD parentJD;
  
  // Arg check
  VDASSERTW(nodeID);

  // Get parent
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (nodeJD.cl == NULL) goto wrapup;
  
  nodeJD.id = *nodeID;
  _RTCJDB(&nodeJD)->getTreeParent(&nodeJD,&parentJD);

  // Update form
    sts = VDct1FormUpdateTreeRow(form, VDCT_FORM_LIB_G_TREE, &parentJD.id);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  createdNode(&parentJD.id);
  VDct1FormUpdateTreeRow(form, VDCT_FORM_LIB_G_TREE, &parentJD.id);

  // update the summary
  // VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_LIB_G_TREE);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Called when a node is activated
 * The original code did not here so 
 * comment it out for now
 */
static IGRstat activateNode(TGRid *nodeID)
{  
  VDASSERT_FN("activateNode");
  
  IGRstat       retFlag = 0;
  IGRchar       buf[128];

  Form form = cmdInfo->lib.form;
  
  IGRint i;
  TVDct1JD      nodeJD;
  TVDctBaseInfo baseInfo;
  
  // Save it
  VDASSERTW(nodeID);
  activeNodeID = *nodeID;

#if 0
  // Update selected tree name
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (nodeJD.cl) {
    nodeJD.id = *nodeID;
    _RTCJDB(&nodeJD)->getBaseInfo(&nodeJD,&baseInfo);
  }
  else memset(&baseInfo,0,sizeof(TVDctBaseInfo));
  
  // Build display name
  sprintf(buf,"%s %s",baseInfo.setType,baseInfo.setName);
  VDfrmSetgText(form,VDCT_FORM_LIB_G_SET_NAME,buf);
#endif

  // Update the display pick list
  // VDct1CmdResetGadgetList(nodeID,form,VDCT_FORM_LIB_G_DISPLAY,1);
  
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

/* ----------------------------------------------
 * Form is deleted
 */
static IGRstat delet(void *a_formInfo)     
{

  VDASSERT_FN("delete");
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->lib;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // free vla
  VDvlaidFree(&clipBoardVLAID);

  // send if up to root delet
  cmdInfo->root.delet(formInfo);

wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return 1; 
}


/* -----------------------------------------------
 * Regular Init
 */
static IGRstat init()
{
  VDASSERT_FN("init");
  IGRstat retFlag = 0;
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Clear
  activeNodeID.objid = NULL_OBJID;

  // init vla
  VDvlaidInit(&clipBoardVLAID);
  
  
  // fill
  fillTreeList();
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  
  return retFlag;
}

/* -------------------------------------------
 * Called to activate the form (from the manager)
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");
  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->lib;

  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitLibCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitLibCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Say Hi
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_LIB);

  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;

  pasteNodeID.objid  = NULL_OBJID;
  activeNodeID.objid = NULL_OBJID;
  
  // Default init
  formInfo = &cmdInfo->lib;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_LIB_F_NAME);
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
  formInfo->delet        = delet;

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
