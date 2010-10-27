/* $Id: VDatTree.I,v 1.3 2001/03/13 22:42:17 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatTree.I
 *
 * Description: Tree Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatTree.I,v $
 *      Revision 1.3  2001/03/13 22:42:17  ramarao
 *      Added Event button to the form.
 *
 *      Revision 1.2  2001/03/09 20:33:53  paul_noel
 *      Fix TR 4418 Up/Down buttons
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/02/09  20:35:32  pinnacle
# Replaced: vdat/cmd/VDatTree.I for:  by vsrivast for vds
#
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/25  15:44:20  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 03/13/01  RR	     Added Event button to the form.
 ***************************************************************************/
class implementation VDatBase;

#include "VDatCmd.h"
#include "VDctx.h"

#define VDAT_FORM_TREE_G_TREE          26
#define VDAT_FORM_TREE_B_UNSELECT_ALL  12
#define VDAT_FORM_TREE_B_UNHILITE_ALL  13
#define VDAT_FORM_TREE_B_HILITE_SELECT 14
#define VDAT_FORM_TREE_B_EVENT         17

#define VDAT_FORM_TREE_B_UP   15
#define VDAT_FORM_TREE_B_DOWN 16

IGRstat VDatCMDTreeNotifyTree  (TVDatFrmList *fl, IGRint gadget);
IGRstat VDatCMDTreeNotifyForm  (TVDatFrmList *fl);

IGRstat VDatCMDTreeActivateForm(TVDatFrmList *fl);
IGRstat VDatCMDTreeActivateSet (TVDatFrmList *fl);
IGRstat VDatCMDTreeGetSelectedLeafs(TVDatFrmList *fl, TVDvlaID *leafVLA);

IGRstat VDatCMDTreeGetSelectedRows(TVDatFrmList *fl,  TVDvlaID *rowVLA);

IGRstat VDatCMDTreeNotifyObject(TVDatFrmList *fl, TVDvlaOE *setVLA);
IGRstat VDatCMDTreeGetNextAboveRow(TVDatFrmList *fl, TGRid *nodeID,TGRid *outID);
IGRstat VDatCMDPutNodesInPosition(TGRid *upID, TGRid *nodeID);

/* ---------------------------------------------------
 * Moves object either up or down on parent channel
 */
IGRstat VDatCMDTreeNotifyMove(TVDatFrmList *fl, IGRint dir)
{
  IGRstat retFlag = 0;

  Form    form    =fl->tree;
  IGRint  gadget  = VDAT_FORM_TREE_G_TREE;

  TVDvlaID rowVLA;
  TGRid    rowID,parentID,parentIDx,upID,checkID;
  IGRint   i,sts = 0;

  // Init
  VDvlaID_Construct(&rowVLA);
  upID.objid = NULL_OBJID;
  checkID.objid == NULL_OBJID;

  // Start be getting list of hilited rows
  VDatCMDTreeGetSelectedRows(fl,&rowVLA);

  // First one determines the parent
  VDvlaID_GetAt(&rowVLA,&rowID,0);
  if (rowID.objid == NULL_OBJID) goto wrapup;

  // Get the parent
  VDatGetParentNode(&rowID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;

  // Move all hilited objects with the same parent
  for(i = 0; VDvlaID_GetAt(&rowVLA,&rowID,i); i++) {
    /* get the node above this rowID on the form */
    VDatCMDTreeGetNextAboveRow(fl,&rowID,&upID);
    /* order the data to get ready to move the object as requested */
    sts = VDatCMDPutNodesInPosition(&upID,&rowID);
    VDatGetParentNode(&rowID,&parentIDx);
    if ((parentID.objid == parentIDx.objid) && 
        (parentID.osnum == parentIDx.osnum)) {
      if(!((sts & 1) && (dir & 1)))
        VDatMoveChildObject(&parentID,&rowID,dir);
    }
  }
  /* if the command is to go up */
  if(dir == 0) {
    VDatFormUpdateTreeRow(form,gadget,&parentID);
    /* double check to see that the command operated to end result */
    VDatCMDTreeGetNextAboveRow(fl,&rowID,&checkID);
    
    if(checkID.objid == upID.objid) {
      /* if it is still not moved kick it again */
      VDatMoveChildObject(&parentID,&rowID,dir);
    }
    VDatFormUpdateTreeRow(form,gadget,&parentID);
  } else {
  // Update the parent row
    VDatFormUpdateTreeRow(form,gadget,&parentID);
  }

  retFlag = 1;
wrapup:
  VDvlaID_Delete(&rowVLA);
  return retFlag;
}

/* ---------------------------------------------------
 * Selection clearing and hiliting
 */
IGRstat VDatCMDTreeNotifyUnSelectAll(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form    =fl->tree;
  IGRint  gadget  = VDAT_FORM_TREE_G_TREE;
 
  VDatFormUnSelectGadget(form,gadget,2,3);

  retFlag = 1;
  return retFlag;
}

#argsused
IGRstat VDatCMDTreeNotifyUnHiLiteAll(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
 
  VDatFormUnHiLiteAll();

  retFlag = 1;
  return retFlag;
}

IGRstat VDatCMDTreeNotifyHiLiteSelect(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form    = fl->tree;
  IGRint  gadget  = VDAT_FORM_TREE_G_TREE;

  VDatFormUnHiLiteAll();
  VDatFormHiLiteGadget(form,gadget,2,3);
 
  retFlag = 1;
  return retFlag;
}

IGRstat VDatCMDTreeEventLeafs( TVDatFrmList *fl)
{
  IGRstat  retFlag = 0;

  TVDvlaID leafVLA;
  TGRid    leafID;
  IGRlong  msg;

  TGRobj_env modelOE;
  Form       form = fl->tree;

  // Make sure active
  //if (VDatFormIsActive(form) != 1) goto wrapup;

  // Init
  VDvlaID_Construct(&leafVLA);

  // Get the leafs
  VDatCMDTreeGetSelectedLeafs(fl,&leafVLA);
  if( !VDvlaID_GetCnt(&leafVLA) ) goto wrapup;

  // Get the First Leaf Object.
  VDvlaID_GetAt(&leafVLA,&leafID,0);

  // Get The Model Object
  VDtrget_modelObject( &leafID, &modelOE );

  // Put the object in the Event
  ASputobj( &msg, modelOE.obj_id.objid, modelOE.obj_id.osnum,
            &modelOE.mod_env );

wrapup:

  // Set the button state to off.
  FIg_set_state_off ( form, VDAT_FORM_TREE_B_EVENT );

  VDvlaID_Delete(&leafVLA);
  return retFlag;
}

/* ---------------------------------------------------
 * Removes node from tree form
 */
IGRstat VDatCMDTreeRemoveRow(TVDatFrmList *fl, TGRid *rowID)
{
  IGRstat retFlag = 0;
  
  Form    form = fl->tree;
  IGRint  gadget = VDAT_FORM_TREE_G_TREE;

  IGRint  type,row;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Arg Check
  if ((rowID == NULL) || (rowID->objid == NULL_OBJID)) goto wrapup;

  // Special case, don't remove tree rows
  VDatGetBaseType(rowID,&type);
  if (type != VDAT_CLASSI_TREE) {
    VDatFormDeleteTreeRowID(form, gadget, rowID);
    retFlag = 1;
    goto wrapup;
  }

  VDatFormFindTreeRow  (form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  VDatFormUpdateTreeRow(form,gadget,rowID);
  VIfld_set_select     (form,gadget,row,2,0);  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Returns first selected row
 */
IGRstat VDatCMDTreeGetFirstSelectedRow(TVDatFrmList *fl, TGRid *rowID)
{
  IGRstat retFlag = 0;
  
  Form    form = fl->tree;
  IGRint  gadget = VDAT_FORM_TREE_G_TREE;
  IGRint  row,rows,sel;

  // Ignore if the form is not active
  rowID->objid = NULL_OBJID;
  if (VDatFormIsActive(form) != 1) goto wrapup;

  rows = -1;
  VIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    sel = -1;
    VIfld_get_select(form,gadget,row,2,&sel);
    if (sel == 1) {
  
      VDahFrmGetGRid(form,gadget,row,3,rowID);
      if (rowID->objid != NULL_OBJID) {
        retFlag = 1;
        goto wrapup;
      }
    }
  }

wrapup:
  return retFlag;
}
/* ---------------------------------------------------
 * Returns row ID just above the selected row 
 */
IGRstat VDatCMDTreeGetNextAboveRow(TVDatFrmList *fl, TGRid *nodeID,TGRid *outID)
{
  IGRstat retFlag = 0;
  
  TGRid   rowID;
  Form    form = fl->tree;
  IGRint  gadget = VDAT_FORM_TREE_G_TREE;
  IGRint  row,rows,sel;
  TGRid   testID;

  /* init */
  if(outID) outID->objid == NULL_OBJID;
  testID.objid == NULL_OBJID;
  sel = 0;
  
  /* args check */
  if(!outID) goto wrapup;
  if(!nodeID) goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  rows = -1;
  VIfld_get_num_rows(form,gadget,&rows);
  /* start at row one since there cannot be a row above 0 */
  for(row = 1; row < rows; row++) {
    VDahFrmGetGRid(form,gadget,row,3,&testID);
    if((testID.objid == nodeID->objid) && (testID.osnum == nodeID->osnum)) {
      row--;
      VDahFrmGetGRid(form,gadget,row,3,outID);
      break;
    }
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Returns list of highlited rows
 */
IGRstat VDatCMDTreeGetSelectedRows(TVDatFrmList *fl, TVDvlaID *rowVLA)
{
  IGRstat retFlag = 0;
  
  TGRid   rowID;
  Form    form = fl->tree;
  IGRint  gadget = VDAT_FORM_TREE_G_TREE;
  IGRint  row,rows,sel;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  rows = -1;
  VIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    sel = -1;
    VIfld_get_select(form,gadget,row,2,&sel);
    if (sel == 1) {
  
      VDahFrmGetGRid(form,gadget,row,3,&rowID);
      if (rowID.objid != NULL_OBJID) VDvlaID_Append(rowVLA,&rowID);

    }
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Returns list of highlited leafs
 * Or leafs below selected stages
 */
IGRstat VDatCMDTreeGetSelectedLeafs(TVDatFrmList *fl, TVDvlaID *leafVLA)
{
  IGRstat retFlag = 0;
  
  TGRid   nodeID;
  Form    form = fl->tree;
  IGRint  gadget = VDAT_FORM_TREE_G_TREE;
  IGRint  row,rows,sel;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  rows = -1;
  VIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    sel = -1;
    VIfld_get_select(form,gadget,row,2,&sel);
    if (sel == 1) {
  
      VDahFrmGetGRid(form,gadget,row,3,&nodeID);
      VDatGetLeafsVLA(&nodeID,leafVLA);

    }
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * A node was updated (or possibly created)
 */
IGRstat VDatCMDTreeUpdateNode(TVDatFrmList *fl, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  TGRid   parentID;
  Form    form = fl->tree;
  IGRint  gadget = VDAT_FORM_TREE_G_TREE;
  IGRint  row;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Arg Check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // Scan for it
  VDatFormFindTreeRow(form,gadget,nodeID,&row);
  if (row >= 0) {
    VDatFormRefreshNodeName(form,gadget,row,nodeID);
    VDatFormContractTreeRow(form,gadget,row);
    VDatFormExpandTreeRow  (form,gadget,row);
    retFlag = 1;
    goto wrapup;
  }

  // Get the parent
  VDatGetParentNode(nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;

  // Scan for parent
  VDatFormFindTreeRow(form,gadget,&parentID,&row);
  if (row < 0) goto wrapup;

  // Expand the parent
  VDatFormContractTreeRow(form,gadget,row);
  VDatFormExpandTreeRow  (form,gadget,row);

  // Show the node
  VDatFormFindTreeRow(form,gadget,nodeID,&row);
  if (row < 0) goto wrapup;

  VDatFormContractTreeRow(form,gadget,row);
  VDatFormExpandTreeRow  (form,gadget,row);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * A node was made active
 */
IGRstat VDatCMDTreeActivateNode(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form = fl->tree;
//IGRint  gadget = VDAT_FORM_TREE_G_TREE;
  
  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Nothing for now

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstat VDatCMDTreeActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  Form    form = fl->tree;

  TGRid   setID;
  IGRchar setName[128];

  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // get the active set, if none just clear gadgets
  *setName = 0;
  VDatCMDAllGetActiveSet(fl,&setID,setName);

  // Update form
  VIg_set_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Gadgets
  if (VDatIsSetATree(&setID))  {
    VIg_enable(form,VDAT_FORM_TREE_B_UP);
    VIg_enable(form,VDAT_FORM_TREE_B_DOWN);
  }
  else {
    VIg_disable(form,VDAT_FORM_TREE_B_UP);
    VIg_disable(form,VDAT_FORM_TREE_B_DOWN);
  }

  // Updates the tree
  VDatFormFillTree(form,VDAT_FORM_TREE_G_TREE,&setID);

  retFlag = 1;
wrapup:
  return retFlag;
}

IGRstat VDatCMDTreeNotifyTree(TVDatFrmList *fl, IGRint gadget)
{
  IGRstat retFlag = 0;
  Form    form = fl->tree;
  TGRid   nodeID;
  IGRint  type;

  // Standard routine
  VDatFormNotifyTree(form,gadget,&nodeID);
  if (nodeID.objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  // Keep leafs and nodes apart for now
  VDatGetBaseType(&nodeID,&type);
  switch(type) {
    case VDAT_CLASSI_LEAF: {
      VDatCMDAllSetActiveLeaf(fl,&nodeID);
      retFlag = 1;
      goto wrapup;
    }
    case VDAT_CLASSI_TREE:
    case VDAT_CLASSI_NODE: {
      VDatCMDAllSetActiveNode(fl,&nodeID);
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDatCMDTreeNotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form;
  IGRint  gadget;

  // Form has all global data
  form   = fl->form;
  gadget = fl->gadget;

  switch(gadget) {

  case VDAT_FORM_TREE_B_UP:  {
    retFlag = VDatCMDTreeNotifyMove(fl,0);
    goto wrapup;
  }
  case VDAT_FORM_TREE_B_DOWN:  {
    retFlag = VDatCMDTreeNotifyMove(fl,1);
    goto wrapup;
  }
  case VDAT_FORM_TREE_B_UNSELECT_ALL:  {
    retFlag = VDatCMDTreeNotifyUnSelectAll(fl);
    goto wrapup;
  }
  case VDAT_FORM_TREE_B_UNHILITE_ALL:  {
    retFlag = VDatCMDTreeNotifyUnHiLiteAll(fl);
    goto wrapup;
  }
  case VDAT_FORM_TREE_B_HILITE_SELECT: {
    retFlag = VDatCMDTreeNotifyHiLiteSelect(fl);
    goto wrapup;
  }

  case VDAT_FORM_TREE_G_TREE: {
    retFlag = VDatCMDTreeNotifyTree(fl,gadget);
    goto wrapup;
  }

  case VDAT_FORM_TREE_B_EVENT: {
    retFlag = VDatCMDTreeEventLeafs(fl);
    goto wrapup;
  }

  case FI_CANCEL: {
    VIf_erase(form);
    VDatFormSetActive(form,0);
    retFlag = 1;
    goto wrapup;
  }
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDatCMDTreeActivateForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    form;

  // Arg check
  if ((fl == NULL) || (fl->tree == NULL)) goto wrapup;
  form = fl->tree;

  // Ignore if already active for now
  sts = VDatFormIsActive(form);
  if (sts == 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Just display
  VIf_display(form);
  VDatFormSetActive(form,1);

  // Fill In
  VDatCMDTreeActivateSet(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}

  
/* -----------------------------------------
 * Some objects were picked
 */
IGRstat VDatCMDTreeNotifyObject(TVDatFrmList *fl, TVDvlaOE *setVLA)
{
  IGRstat retFlag = 0;
  
  Form    form = fl->tree;
  TGRid   setID,leafID,lastID;
  IGRint  i;

  TGRobj_env objOE;
  
  // Ignore if the form is not active
  //if (VDatFormIsActive(form) != 1) goto wrapup;

  // Get the active set
  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // The last leaf processed will become the active leaf
  lastID.objid = NULL_OBJID;

  // Cycle through
  for(i = 0; VDvlaOE_GetAt(setVLA,&objOE,i); i++ ) {

    // See if already in set
    VDatGetObjectLeaf(&objOE, &setID, &leafID);

    if (leafID.objid != NULL_OBJID) {
      VDatExpandTree(form, VDAT_FORM_TREE_G_TREE, &setID, &leafID);
      lastID = leafID;
    }

}
retFlag = 1;
wrapup:
	return retFlag;

}
/* ------------------------------------------------
 * Sees if selected nodeID and swap above node are in
 * position to match display on form for users
 * and moves to that position for execution of commands
 */
IGRstat VDatCMDPutNodesInPosition(TGRid *upID, TGRid *nodeID)
{
  IGRstat         retFlag  = 0;
  IGRstat         traceFlag = 0;
  TGRid           parentID,testID;
  IGRint          i,j,swaps,sts = 0;
  IGRchar         nodeType[128];
  TVDctxBaseInfo  baseInfo;

  /* say hi */
  if(traceFlag) printf("***>>> vds/vdat/cmd/VDatTree.I: VDatCMDPutNodeInPosition\n");

  /* args check */
  if(!upID) goto wrapup;
  if(!nodeID) goto wrapup;
  if(upID->objid == NULL_OBJID) goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  /* if the upID is the nodeID */
  if(upID->objid == nodeID->objid) goto wrapup;

  /* init */
  testID.objid = NULL_OBJID;
  nodeType[0] = '\0';

  /* check to make sure that the types match */
  VDctxGetBaseInfo(nodeID,&baseInfo);
  strcpy(nodeType,baseInfo.nodeType);
  VDctxGetBaseInfo(upID,&baseInfo);
  if((strcmp(baseInfo.nodeType,nodeType)) && (!strcmp(nodeType,"PM"))) goto wrapup;

  /* Find the object in quest */
  VDatGetParentNode(nodeID,&parentID);
  if(parentID.objid == NULL_OBJID) goto wrapup;
  sts = VDatGetChildIndex(&parentID,nodeID,&i);
 
 /* if we are at the top or if we don't get a parent go home */
  if((!(sts & 1)) || (i & 1)) goto wrapup;
  sts = VDatGetChildIndex(&parentID,upID,&j);

  /* if the position is wrong */
  if((!(sts & 1)) || (j >= i)) goto wrapup;

  /* just be extra careful */
  if(upID->objid == parentID.objid) goto wrapup;

  /* set the number of swaps */
  swaps = i - j;
  swaps--;
  if(swaps < 1) goto wrapup;
  for(i = 0; i < swaps;i++) {
    VDatMoveChildObject(&parentID,nodeID,0);
  }

  /* success */
  retFlag = 1;
 wrapup:
  /* say bye */
  if(traceFlag) printf("<<<*** vds/vdat/cmd/VDatTree.I: VDatCMDPutNodeInPosition(%d)\n",retFlag);
  return retFlag;
}



end implementation VDatBase;










