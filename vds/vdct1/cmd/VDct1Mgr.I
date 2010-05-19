/* $Id: VDct1Mgr.I,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/VDctMgr.I
 *
 * Description: Manager Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Mgr.I,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.11  2000/07/25  13:04:40  pinnacle
# ah
#
# Revision 1.9  2000/07/20  20:15:28  pinnacle
# js
#
# Revision 1.7  2000/07/18  19:32:20  pinnacle
# ah
#
# Revision 1.6  2000/07/17  19:50:06  pinnacle
# ah
#
# Revision 1.5  2000/06/23  12:57:54  pinnacle
# pn
#
# Revision 1.4  2000/06/02  15:02:14  pinnacle
# ah
#
# Revision 1.3  2000/05/23  18:30:12  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Mgr.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/11  13:20:40  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Mgr.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:36:26  pinnacle
# Created: vds/vdct1/cmd/VDct1Mgr.I by pnoel for Service Pack
#
# Revision 1.5  2000/03/28  16:08:16  pinnacle
# pn.
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
 * 05/29/99  ah      creation
 * 01/10/00  pn      updated controls/safeops
 * 05/23/00  pn      updated form calls and notices
 * 06/23/00  pn      altered posting per CR 179901682
 * 07/17/00  ah      Tree Interface
 ***************************************************************************/

class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Forms.h"

#include "VDct1Cmd.h"

#include "VDassert.h"

#include "coparamac.h"

VDASSERT_FFN("vdct1/cmd/VDct1Mgr.I");

static int traceFlag;

static TVDct1CmdInfo *cmdInfo;

extern VDclassid OPP_GRgrset_class_id;


/* -----------------------------------------------------
 * A single model object 
 *
 */
IGRstat VDct1CmdMgrLocatedObject(TGRobj_env *objOE) 
{ 
  IGRstat     sts   = 0;
  IGRchar     buf[128];
  
  
  // Tell the world
  // vdobj$Print(objOE = objOE); 

  /////////////////////// Construction //////////////////////////////////////////
  // This is because the software is under construction to prevent user accidents
  // prevent all but this type of Tree
    // message of construction
  // sts = vdct1cmd$CmdNodeMsgBox();
  //  strcpy(buf,"Select Another Node Operation\\n\nOn Node Form\n\n");
    // message to choose another tree type
  //  sts = vdct1cmd$CmdNodeMsgBox(msg = buf);
  
  // REMOVE this and alter as more trees come into operation
  ///////////////////////////////////////////////////////////////////////////////

  VDct1CmdNodeLocatedObject(objOE);
  
  return 1;
}

/* -----------------------------------------------------
 * An object was selected
 */
IGRstat VDct1CmdMgrNotifyObject(TGRobj_env *objOE)
{
  IGRstat  retFlag = 0;
  IGRstat  sts, sts1;

  TGRobj_env *locOEs;
  IGRint      locNum;
  IGRint      i; 
  IGRchar     buf[128];
  
  // Have a set
  sts = vdobj$IsAncestryValid(objOE = objOE,
			      superClassID = OPP_GRgrset_class_id);

  if (!(sts & 1)) {
    VDct1CmdNodeDupFlag(0);  
    VDct1CmdMgrLocatedObject(objOE);
    retFlag = 1;
    goto wrapup;
  }

  // Process the set
  as$start_fence(set       = &objOE->obj_id,
		 set_env   = &objOE->mod_env,
		 nb_obj    = &locNum,
		 p_obj_env = &locOEs);

  // set up the VDnotice_box() control 
  if (locNum > 2) 
  VDct1CmdNodeDupFlag(1);    

  for(i = 0; i < locNum; i = i + 1) {
    VDct1CmdMgrLocatedObject(&locOEs[i]);
  }

  ASend_fence();

  // wrap up the business
  VDct1CmdNodeDupFlagOff();

  // Done
  retFlag = 1;
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
#argsused
IGRstat VDct1CmdMgrNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat msg;
  traceFlag = 0;
  
  // See which form caused message
  if (cmdInfo->form == cmdInfo->set.form) {
    
// a trace flag option
    if (traceFlag) {
      printf(">>> Seeing which form caused message \n");
      printf("cmdInfo->form == cmdInfo->set.form\n\n");
      
    }
     
    retFlag = VDct1CmdSetNotifyForm();
    goto wrapup;
  }

  if (cmdInfo->form == cmdInfo->lib.form) { 

// a trace flag option
    if (traceFlag) {
      printf(">>> Seeing which form caused message \n");
      printf("cmdInfo->form == cmdInfo->lib.form\n\n");
      
    }

    retFlag = VDct1CmdLibNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->tree.form) { 


// a trace flag option
    if (traceFlag) {
      printf(">>> Seeing which form caused message \n");
      printf("cmdInfo->form == cmdInfo->tree.form\n\n");
      
    }

    retFlag = VDct1CmdTreeNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->attr.form) { 

// a trace flag option
    if (traceFlag) {
      printf(">>> Seeing which form caused message \n");
      printf("cmdInfo->form == cmdInfo->attr.form\n\n");
      
    }

    retFlag = VDct1CmdAttrNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->node.form) { 

// a trace flag option
    if (traceFlag) {
      printf(">>> Seeing which form caused message \n");
      printf("cmdInfo->form == cmdInfo->node.form\n\n");
      
    }

    retFlag = VDct1CmdNodeNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->free.form) {     

// a trace flag option
    if (traceFlag) {
      printf(">>> Seeing which form caused message \n");
      printf("cmdInfo->form == cmdInfo->free.form\n\n");
      
    }

    retFlag = VDct1CmdFreeNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->part.form) {     

// a trace flag option
    if (traceFlag) {
      printf(">>> Seeing which form caused message \n");
      printf("cmdInfo->form == cmdInfo->part.form\n\n");
      
    }

    retFlag = VDct1CmdPartNotifyForm();
    goto wrapup;
  }

  // Should be the manager itself
  if (cmdInfo->form != cmdInfo->mgr.form) goto wrapup;
  
  switch(cmdInfo->gadget) {

  case VDCT_FORM_MGR_B_POST:
    retFlag =  VDct1SetPostTrees();
    goto wrapup;

  case VDCT_FORM_MGR_B_UNHILITE:
    if (traceFlag) printf("UNHILITE option selected \n");

    dp$erase_hilite(msg = &msg);
    retFlag = 1;
    goto wrapup;

  case VDCT_FORM_MGR_B_HILITE:
    //VDatCmdMgrHiLiteSet(fl);
    retFlag = 1;
    goto wrapup;

  case FI_CANCEL:
    retFlag = 1;
    cmdInfo->shutdown = 1;
    goto wrapup;

  case VDCT_FORM_MGR_B_SETS:
    retFlag = VDct1CmdSetActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_LIBS:
    retFlag = VDct1CmdLibActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_TREES:
    retFlag = VDct1CmdTreeActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_ATTRS:
    retFlag = VDct1CmdAttrActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_NODES:
    retFlag = VDct1CmdNodeActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_FREE:
    retFlag = VDct1CmdFreeActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_PART:    
    retFlag = VDct1CmdPartActivateForm();
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to start everything up
 */
IGRstat VDct1CmdMgrInit(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdMgrInit");
  
  IGRstat retFlag = 0;
  IGRstat msg;

  TGRid mgrID;

  // Say hi
  traceFlag = VDdbgGetTraceFlag(42);
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    fflush(stdout);
  }

  // Arg check
  VDASSERTW(a_cmdInfo);
  cmdInfo = a_cmdInfo;
  
  // Make sure have a manager or create one
  vdct1$GetManager(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    vdct1$CreateManager(mgrID = &mgrID);
  }
  VDASSERTW(mgrID.objid != NULL_OBJID);

  if (traceFlag) {
    printf("Got The Manager %s %s\n",ffn(),fn);
    fflush(stdout);
  }

  // Create Transient Standard Library
  // VDct1CreateStandardLibrary();

  // Default class selection list
  VDct1CmdMgrGetDefaultFilter();
  if (traceFlag) {
    printf("Got The Default Filter %s %s\n",ffn(),fn);
    fflush(stdout);
  }

  // Init individual routines
  VDct1CmdLibInit (cmdInfo);
  VDct1CmdSetInit (cmdInfo);
  VDct1CmdTreeInit(cmdInfo);
  VDct1CmdNodeInit(cmdInfo);
  VDct1CmdAttrInit(cmdInfo);
  VDct1CmdFreeInit(cmdInfo);
  VDct1CmdPartInit(cmdInfo);

  if (traceFlag) {
    printf("Inited Everything %s %s\n",ffn(),fn);
    fflush(stdout);
  }

  /* Erase any existing highlites */
  dp$erase_hilite(msg = &msg);

  /* Done */
  UI_status("Tree Manager Ready");
  retFlag = 1;

  cmdInfo->inittedOK = 1;

wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    fflush(stdout);
  }  
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to shut things down
 * Not much to do anymore
 */
#argsused
IGRstat VDct1CmdMgrDelete()
{
  IGRstat retFlag = 0;
  IGRstat msg;

  dp$erase_hilite(msg = &msg);
  cmdInfo = NULL;
  
  retFlag = 1;

  return retFlag;
}

#argsused
IGRstat VDct1CmdMgrWakeup()
{
  /* Wakup all active forms, need to deal with hilite later */
  vdfrm$DisplayForm(form=cmdInfo->mgr.form,   show=cmdInfo->mgr.displayed);
  vdfrm$DisplayForm(form=cmdInfo->set.form,   show=cmdInfo->set.displayed);
  vdfrm$DisplayForm(form=cmdInfo->leaf.form,  show=cmdInfo->leaf.displayed);
  vdfrm$DisplayForm(form=cmdInfo->tree.form,  show=cmdInfo->tree.displayed);
  vdfrm$DisplayForm(form=cmdInfo->attr.form,  show=cmdInfo->attr.displayed);
  vdfrm$DisplayForm(form=cmdInfo->node.form,  show=cmdInfo->node.displayed);
  vdfrm$DisplayForm(form=cmdInfo->pcmk.form,  show=cmdInfo->pcmk.displayed);
  vdfrm$DisplayForm(form=cmdInfo->lib.form,   show=cmdInfo->lib.displayed);
  vdfrm$DisplayForm(form=cmdInfo->free.form,  show=cmdInfo->free.displayed);
  //printf("set up display of part form\n");
  //vdfrm$DisplayForm(form=cmdInfo->part.form,  show=cmdInfo->part.displayed); 
  // Maybe rehilite tree/leaf

  return 1;
}

#argsused
IGRstat VDct1CmdMgrSleep()
{
  return 1;
}

/* --------------------------------------------------------
 * By default, allow picking all VDSroot stuff
 */
IGRstat VDct1CmdMgrGetDefaultFilter()
{
  IGRstat retFlag = 0;

  om$get_classid( 
    classname = "VDSroot",
    p_classid = &cmdInfo->classIDs[0]
  ) ;

  cmdInfo->classList.p_classes = cmdInfo->classIDs;
  cmdInfo->classList.w_count   = 1;
  cmdInfo->classList.w_flags   = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

/* -------------------------------------------------------
 * Adjust filter based on set type
 */
IGRstat VDct1CmdMgrGetFilter(TGRid *nodeID)
{
  IGRint retFlag = 0;
  IGRstat traceFlag = 0;
  

  TGRid  pplID;
  IGRint pplRet;

  TVDctBaseInfo baseInfo;

  TVDct1JD nodeJD;
  
  if (traceFlag){
    
  // Say hi
    printf(">>> VDct1CmdMgrGetFilter\n");
  }
  
  // Sets the pointer and gets default info
  VDct1CmdMgrGetDefaultFilter();

  // Tree interface
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (nodeJD.cl) {
    nodeJD.id = *nodeID;
    return _RTCJDB(&nodeJD)->getFilter(&nodeJD,&cmdInfo->classList);
  }
  
  // Load the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    retFlag = 0;
    goto wrapup;
  }

  vdppl$SetData(pplID = &pplID,
                name  = "CLASS_LIST",
                size  = sizeof( cmdInfo->classList),
                data  = (char*)&cmdInfo->classList);

  vdppl$Run(pplID = &pplID, name = "getFilter", ret = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "CLASS_LIST",
                size  = sizeof( cmdInfo->classList),
                data  = (char*)&cmdInfo->classList);

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdMgrGetFilter %d\n",retFlag);
  return retFlag;
}

/* ------------------------------------------------------------
 * Low level traffic redirectors
 */
IGRstat VDct1CmdMgrCreatedTree(TGRid *treeID)
{
  TGRid nodeID;
  
  VDct1CmdLibCreatedTree (treeID);
  VDct1CmdSetCreatedTree (treeID);
  VDct1CmdTreeCreatedTree(treeID);
  VDct1CmdNodeCreatedTree(treeID);
  VDct1CmdAttrCreatedTree(treeID);  
  VDct1CmdFreeCreatedTree(treeID);  
  VDct1CmdPartCreatedTree(treeID);  

  // Activate it's top node
  vdct1$GetSetTree(setID = treeID, treeID = &nodeID);
  VDct1CmdMgrActivateNode(&nodeID);
  
  return 1;
}
IGRstat VDct1CmdMgrDeletedTree(TGRid *treeID)
{
  TGRid fakeID;
  
  VDct1CmdLibDeletedTree (treeID);
  VDct1CmdSetDeletedTree (treeID);
  VDct1CmdTreeDeletedTree(treeID);
  VDct1CmdNodeDeletedTree(treeID);
  VDct1CmdAttrDeletedTree(treeID);  
  VDct1CmdFreeDeletedTree(treeID);  
  VDct1CmdPartDeletedTree(treeID);  

  fakeID.objid = NULL_OBJID;
  VDct1CmdMgrActivateNode(&fakeID);
  
  return 1;
}

#argsused
IGRstat VDct1CmdMgrRenamedTree(TGRid *treeID)
{
  TGRid fakeID;
  
  VDct1CmdLibRenamedTree (treeID);
  VDct1CmdSetRenamedTree (treeID);
  VDct1CmdTreeRenamedTree(treeID);
  VDct1CmdNodeRenamedTree(treeID);
  VDct1CmdAttrRenamedTree(treeID);  
  VDct1CmdFreeRenamedTree(treeID);  
  VDct1CmdPartRenamedTree(treeID);  

  fakeID.objid = NULL_OBJID;
  VDct1CmdMgrActivateNode(&fakeID);
  
  return 1;

}

IGRstat VDct1CmdMgrCreatedNode(TGRid *nodeID)
{ 
  VDct1CmdLibCreatedNode (nodeID);
  VDct1CmdSetCreatedNode (nodeID);
  VDct1CmdTreeCreatedNode(nodeID);
  VDct1CmdNodeCreatedNode(nodeID);
  VDct1CmdAttrCreatedNode(nodeID);  
  VDct1CmdFreeCreatedNode(nodeID);  
  VDct1CmdPartCreatedNode(nodeID);  
  
  VDct1CmdMgrActivateNode(nodeID);
  
  return 1;
}

IGRstat VDct1CmdMgrDeletedNode(TGRid *nodeID, TGRid *parentID)
{ 
  VDct1CmdLibDeletedNode (nodeID,parentID);
  VDct1CmdSetDeletedNode (nodeID,parentID);
  VDct1CmdTreeDeletedNode(nodeID,parentID);
  VDct1CmdNodeDeletedNode(nodeID,parentID);
  VDct1CmdAttrDeletedNode(nodeID,parentID);  
  VDct1CmdFreeDeletedNode(nodeID,parentID);  
  VDct1CmdPartDeletedNode(nodeID,parentID);  
  
  return 1;
}

IGRstat VDct1CmdMgrRenamedNode(TGRid *nodeID)
{ 
  VDct1CmdLibRenamedNode (nodeID);
  VDct1CmdSetRenamedNode (nodeID);
  VDct1CmdTreeRenamedNode(nodeID);
  VDct1CmdNodeRenamedNode(nodeID);
  VDct1CmdAttrRenamedNode(nodeID);
  VDct1CmdFreeRenamedNode(nodeID);  
  VDct1CmdPartRenamedNode(nodeID);  

  return 1;
}

IGRstat VDct1CmdMgrActivateNode(TGRid *nodeID)
{
  VDct1CmdMgrGetFilter    (nodeID);
  VDct1CmdLibActivateNode (nodeID);
  VDct1CmdTreeActivateNode(nodeID);
  VDct1CmdNodeActivateNode(nodeID);
  VDct1CmdAttrActivateNode(nodeID);  
  VDct1CmdFreeActivateNode(nodeID);
  VDct1CmdPartActivateNode(nodeID);
  
  vdct1$CmdSetActivateNode(nodeID = nodeID);

  return 1;
}

IGRstat VDct1CmdRenamedTree(TGRid *treeID)
{ 
  //VDct1CmdLibRenamedTree (treeID);
  //printf("VDct1CmdLibRenamedTree executed\n");
  //VDct1CmdSetRenamedTree (treeID);
  //printf("VDct1CmdSetRenamedTree executed\n");
  //VDct1CmdTreeRenamedTree(treeID);
  //printf("VDct1CmdTreeRenamedTree executed\n");
  //VDct1CmdNodeRenamedTree(treeID);
  //printf("VDct1CmdNodeRenamedTree executed\n");
  //VDct1CmdAttrRenamedTree(treeID);
  // printf("VDct1CmdAttrRenamedTree executed\n");
  //VDct1CmdFreeRenamedTree(treeID); 
  //printf("VDct1CmdFreeRenamedTree executed\n"); 

  return 1;
}

/* -----------------------------------------------
 * Reset Gadget List using a call to a custom routine
 */
IGRstat VDct1CmdResetGadgetList(TGRid *nodeID, 
				Form   form, 
				IGRint gadget,
				IGRint keepDefault)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD nodeJD;

  IGRchar bufFirst  [128];
  IGRchar bufCurrent[128];
  IGRchar bufDefault[128];
  
  IGRchar buf[128];
  IGRchar formName[64];
  
  IGRint i;
  
  // Get the class pointer
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (!nodeJD.cl) nodeJD.cl =  VDct1GetRootTreeClass();
  if (nodeID) nodeJD.id = *nodeID;
  else        nodeJD.id.objid = NULL_OBJID;

  // Get the form name
  *formName = 0;
  FIf_get_name(form,formName);
  if (*formName == 0) goto wrapup;
  
  // Get the first value
  sts = _RTCJDC(&nodeJD)->getGadgetText(&nodeJD,formName,gadget,0,bufFirst);
  if (!(sts & 1)) goto wrapup;
  
  // Save the existing selection (if any)
  vdfrm$GetText(form = form, gadget = gadget, txt = bufCurrent);
  
  // if default is not set the first entry is always default
  if (keepDefault == 0) strcpy(bufCurrent,bufFirst);
  strcpy(bufDefault,bufFirst);
  
  // Reset list rows
  vdfrm$SetListNumRows(form = form, gadget = gadget, rows = 0);
  
  // Cycle through
  for(i = 0; 
      _RTCJDC(&nodeJD)->getGadgetText(&nodeJD,formName,gadget,i,buf);
      i++) {

    vdfrm$SetListText(form = form, gadget = gadget, row = i, txt = buf);

    if (keepDefault) {

      // Ensure previous value is in the list of options
      if (!strcmp(bufCurrent,buf)) strcpy(bufDefault,bufCurrent);
    }
  }
  
  // Fill in actual value
  vdfrm$SetText(form = form, gadget = gadget, txt = bufDefault);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation VDct1Base;

#if 0
IGRstat VDct1CmdCreatedTree(TGRid *treeID)
{  
  return 1;
}
IGRstat VDct1CmdDeletedTree(TGRid *treeID)
{  
  return 1;
}
IGRstat VDct1CmdRenamedTree(TGRid *treeID)
{  
  return 1;
}
IGRstat VDct1CmdCreatedNode(TGRid *nodeID)
{  
  return 1;
}
IGRstat VDct1CmdDeletedNode(TGRid *nodeID, TGRid *parentID)
{  
  return 1;
}
IGRstat VDct1CmdRenamedNode(TGRid *nodeID)
{  
  return 1;
}
IGRstat VDct1CmdActivateNode(TGRid *nodeID)
{  
  return 1;
}
#endif
